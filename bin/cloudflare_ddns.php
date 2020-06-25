#!/usr/bin/env php
<?php
date_default_timezone_set('Europe/Sofia');
error_reporting(E_ALL | E_STRICT);
ini_set('display_startup_errors', 1);
ini_set('display_errors', 1);
ini_set('max_execution_time', 30);
ini_set('memory_limit', '64M');
mb_internal_encoding('UTF-8');

set_error_handler("exception_error_handler");

$params = get_opts_custom();
if (!empty($params['new'])) {
    // print response
    echo create_new_record($params) . PHP_EOL;
    exit;
}
if (need_action($params)) {
    fwrite(STDERR, 'Updating... ' . PHP_EOL);
    cloudflare_update_record_id($params);
} else {
    fwrite(STDERR, 'No need to update... ' . PHP_EOL);
}
exit;

function determine_fqdn($host, $domain)
{
    if ($host === '@') {
        $fqdn = $domain;
    } else {
        $fqdn = $host . '.' . $domain;
    }
    return $fqdn;
}

function need_action(& $params)
{
    $lastIpData = dns_get_record(determine_fqdn($params['host'], $params['domain']) . '.', DNS_A);
    $lastIp = isset($lastIpData[0]['ip']) ? $lastIpData[0]['ip'] : '';
    if (!isset($params['current_ip'])) {
        $params['current_ip'] = shell_exec("ip route get 1 | grep -Po '(?<=src )(\d{1,3}.){4}' | tr -d '[:space:]'");
    }

    if ($params['current_ip'] !== $lastIp) {
        return true;
    }
    return false;
}

function exception_error_handler($severity, $message, $file, $line)
{
    if (!(error_reporting() & $severity)) {
        // This error code is not included in error_reporting
        return;
    }
    throw new ErrorException($message, 0, $severity, $file, $line);
}

function get_opts_custom()
{
    $reqSpec = [0 => ':', 1 => '::', -1 => ''];
    $optSpecs = [
        ['d', 'domain', 0],
        ['h', 'host', 0],
        ['i', 'ini_file', 0],
        ['z', 'zone_id', 0],
        ['r', 'dns_record_id', 0],
        ['p', 'current_ip', 0],
        ['t', 'dns_cloudflare_api_token', 0],
        ['g', 'debug', 0]
    ];
    $shortOptSpec = '';
    $longOptSpec = [];
    $mapper = [];
    foreach ($optSpecs as $optSpec) {
        $shortOptSpec .= $optSpec[0] . $reqSpec[$optSpec[2]];
        $longOptSpec[] = $optSpec[1] . $reqSpec[$optSpec[2]];
        $mapper[$optSpec[1]] = $optSpec[0];
    }
    $longOptSpec[] = 'r_type' . ':';
    $longOptSpec[] = 'r_value' . ':';
    $longOptSpec[] = 'r_priority' . ':';
    $longOptSpec[] = 'r_ttl' . ':';
    $longOptSpec[] = 'r_proxied' . ':';
    $longOptSpec[] = 'new' . ':';
    $params = getopt($shortOptSpec, $longOptSpec);
    foreach ($mapper as $longOptName => $shortOptName) {
        // exit if both are passed
        if (isset($params[$longOptName]) && isset($params[$shortOptName])) {
            throw new Exception('Both -"' . $shortOptName . '" and "--' . $longOptName . '" are set !');
        }
        // load long opt from short opt
        if (isset($params[$shortOptName])) {
            $params[$longOptName] = $params[$shortOptName];
        }
        // unset short opt to force usage of long opts in php code
        unset($params[$shortOptName]);
    }
    // token is more restrictive
    if (empty($params['dns_cloudflare_api_token'])) {
        $iniArray = parse_ini_file($params['ini_file']);
        $params['dns_cloudflare_email'] = $iniArray['dns_cloudflare_email'];
        $params['dns_cloudflare_api_key'] = $iniArray['dns_cloudflare_api_key'];
        unset($params['ini_file']);
    }
    return $params;
}

function cloudflare_request($params, $endpoint, $method = 'GET')
{
    // TODO: updating data
    $url = 'https://api.cloudflare.com/client/v4/' . $endpoint . '/';
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_VERBOSE, false);
    curl_setopt($ch, CURLOPT_NOBODY, false);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);
    curl_setopt($ch, CURLOPT_TIMEOUT, 60);

    if ($method !== 'GET') {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($params['payload']));
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "$method");
    }
    $headers = [
        'Content-Type: application/json',
    ];
    if (isset($params['dns_cloudflare_api_token'])) {
        $headers[] = 'Authorization: Bearer ' . $params['dns_cloudflare_api_token'];
    } else {
        $headers[] = 'X-Auth-Email: ' . $params['dns_cloudflare_email'];
        $headers[] = 'X-Auth-Key: ' . $params['dns_cloudflare_api_key'];
    }
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    $response = curl_exec($ch);
    curl_close($ch);
    return json_decode($response, true);
}

function cloudflare_get_zone_id(&$params)
{
    if (!isset($params['zone_id'])) {
        $data = cloudflare_request($params, 'zones');
        if (!(isset($data['success']) && $data['success'] === true)) {
            fwrite(STDERR, print_r($data, true) . PHP_EOL);
            fwrite(STDERR, print_r($params, true) . PHP_EOL);
            throw new Exception('Zone fetch failed!');
        }
        foreach ($data['result'] as $zone) {
            if ($zone['name'] === $params['domain']) {
                $params['zone_id'] = $zone['id'];
                break;
            }
        }
        if (empty($params['zone_id'])) {
            fwrite(STDERR, print_r($data, true) . PHP_EOL);
            fwrite(STDERR, print_r($params, true) . PHP_EOL);
            throw new Exception('Empty Zone Id!');
        }
    }
    if(!empty($params['debug'])){
      fwrite(STDERR,print_r($params['zone_id'],true).PHP_EOL);
    }
    return $params['zone_id'];
}

function cloudflare_get_dns_record_id(& $params)
{
    if (!isset($params['dns_record_id'])) {
        cloudflare_get_zone_id($params);
        $data = cloudflare_request($params, 'zones/' . $params['zone_id'] . '/dns_records');
        if (!(isset($data['success']) && $data['success'] === true)) {
            fwrite(STDERR, print_r($data, true) . PHP_EOL);
            fwrite(STDERR, print_r($params, true) . PHP_EOL);
            throw new Exception('DNS record fetch failed!');
        }
        foreach ($data['result'] as $dnsRecord) {
            if (
                $dnsRecord['name'] === determine_fqdn($params['host'], $params['domain'])
                && $dnsRecord['type'] === 'A'
            ) {
                $params['dns_record_id'] = $dnsRecord['id'];
                break;
            }
        }
        if (empty($params['dns_record_id'])) {
            fwrite(STDERR, print_r($data, true) . PHP_EOL);
            fwrite(STDERR, print_r($params, true) . PHP_EOL);
            throw new Exception('Empty DNS Record Id!');
        }
    }
    if(!empty($params['debug'])){
      fwrite(STDERR,print_r($params['dns_record_id'],true).PHP_EOL);
    }
    return $params['dns_record_id'];
}

function cloudflare_update_record_id(& $params)
{
    $params['payload'] = [
        'type' => 'A',
        'name' => determine_fqdn($params['host'], $params['domain']),
        'content' => $params['current_ip']
    ];
    cloudflare_get_dns_record_id($params);
    $data = cloudflare_request(
        $params,
        'zones/' . $params['zone_id'] . '/dns_records/' . $params['dns_record_id']
        , 'PUT'
    );
    if (!(isset($data['success']) && $data['success'] === true)) {
        fwrite(STDERR, print_r($data, true) . PHP_EOL);
        fwrite(STDERR, print_r($params, true) . PHP_EOL);
        throw new Exception('DNS record update failed!');
    }
    return true;
}

function create_new_record(&$params)
{
    cloudflare_get_zone_id($params);
    $params['payload'] = [
        'type' => $params['r_type'],
        'name' => determine_fqdn($params['host'], $params['domain']),
        'content' => $params['r_value'],
    ];
    $options = ['proxied' => [false, 'bool'], 'ttl' => [1, 'int'], 'priority' => [null, 'int']];
    foreach ($options as $optKey => $optData) {
        if (isset($params['r_' . $optKey])) {
            $params['payload'][$optKey] = call_user_func_array($optData[1] . 'val', [$params['r_' . $optKey]]);
        } elseif ($optData[0] !== 0) {
            $params['payload'][$optKey] = $optData[0];
        }
    }
    $req = cloudflare_request($params, 'zones/' . $params['zone_id'] . '/dns_records', 'POST');
    return $req;
}

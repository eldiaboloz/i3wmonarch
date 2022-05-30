<?php

date_default_timezone_set('Europe/Sofia');
error_reporting(E_ALL | E_STRICT);
ini_set('display_startup_errors', 1);
ini_set('display_errors', 1);
ini_set('max_execution_time', 30);
ini_set('memory_limit', '128M');
mb_internal_encoding('UTF-8');

/**
 * $myDict =
 * [
 *  'rig1' => [
 *      'wallet' => '0x0000000000000000000000000000000000000000',
 *      'type' => 'ethermine',
 *      'hashrate' => 1.0,
 *      'min_percent'=>80.0
 *  ]
 * ];
 */
require_once getenv('HOME') . '/.ssh/secrets/crypto_addr.php';

$keyInDict = $argv[1] ?? -1;
if (!isset($myDict[$keyInDict])) {
    throw new Exception('Unknown wallet');
}

$params = init_pool_params($myDict[$keyInDict]);

$response = parse_api_response($params);

$notifyMessage = $response['notify'];
$message = $response['message'];
$color = $response['color'];

handle_mouse_button($params['info'], $params['api']);

if ($notifyMessage) {
    $tempFile = '/tmp/rigmon_' . $response['hash'] . '.last';
    if (!is_file($tempFile) || (filemtime($tempFile) < (time() - 1200))) {
        file_put_contents($tempFile, time() . PHP_EOL);
        $notifyMessage = $notifyMessage ? $notifyMessage : $message;
        notify_desktop($notifyMessage);
    }
}

echo $message . PHP_EOL;
echo $message . PHP_EOL;
echo $color . PHP_EOL;
exit;

function init_pool_params(array $params)
{
    $type = $params['type'];
    $wallet = $params['wallet'];
    $expectedHashRate = (float)($params['hashrate'] ?? 0.0);
    $hashRateMinPercent = (float)($params['min_percent'] ?? 80.0);

    switch ($type) {
        case 'ethermine':
            $walletRegex = '#^0x[0-9a-z]{40}$#';
            $apiUrl = 'https://api.ethermine.org/miner/' . $wallet . '/currentStats';
            $infoUrl = 'https://ethermine.org/miners/' . $wallet;
            break;
        case "ubiqpool":
            $walletRegex = '#^0x[0-9a-z]{40}$#';
            $apiUrl = 'https://ubiqpool.io/api/accounts/' . $wallet;
            $infoUrl = 'https://ubiqpool.io/#/account/' . $wallet;
            break;
        default:
            throw new Exception('Unknown pool type: ' . $type);
    }

    if (!preg_match($walletRegex, $wallet)) {
        echo 'invalid wallet';
        exit(1);
    }

    return [
        'api' => $apiUrl,
        'info' => $infoUrl,
        'wallet' => $wallet,
        'type' => $type,
        'hashrate' => $expectedHashRate,
        'min_percent' => $hashRateMinPercent,
    ];
}

function parse_api_response($params)
{
    $type = $params['type'];
    $apiUrl = $params['api'];
    $json = json_decode(file_get_contents($apiUrl), true);
    switch ($type) {
        case 'ethermine':
            $response = parse_api_response_ethermine($json,$params);
            break;
        case "ubiqpool":
            $response = parse_api_response_ubiqpool($json,$params);
            break;
        default:
            throw new Exception('Unknown pool type: ' . $type);
    }
    $response['hash'] = sha1($apiUrl);
    return $response;
}

function parse_api_response_ubiqpool($json,$params)
{
    $color = '#00FF00';
    $message = 'UBIQ:';
    $notifyMessage = '';
    if (!empty($json)) {
        $totalHashSent = (float)$json['currentHashrate'] / (1000 * 1000);
        $totalHashCalc = (float)$json['hashrate'] / (1000 * 1000);
        $balance = 0;
        if (isset($json['stats']['balance'])) {
            $balance = round((float)$json['stats']['balance'] / (1000 * 1000 * 1000), 6);
        }
        if ($totalHashCalc <= (0.7 * $totalHashSent)) {
            // lower than 80% hashrate
            $color = '#FF0000';
            $notifyMessage .= ' Low hashrate!';
        }
        $lastShare = time() - $json['stats']['lastShare'];
        if ($lastShare > 600) {
            // last share was longer before 10 min
            $color = '#FF0000';
            $notifyMessage .= ' No Shares!';
        }
        $message .= ' ' . number_format($totalHashSent, 2) . ' - ' . number_format($totalHashCalc, 2) . ' MH/s';

        $message .= ' | LS: ' . $lastShare . 's';
        $message .= ' | B: ' . $balance;

    } else {
        $message .= 'ERROR';
        $notifyMessage = 'Empty json!';
    }
    return array('message' => $message, 'notify' => $notifyMessage, 'color' => $color);
}

function parse_api_response_ethermine($json,$params)
{
    $color = '#00FF00';
    $message = 'ETH:';
    $notifyMessage = '';
    if (!empty($json)) {
        $totalHashSent = (float)$json['data']['reportedHashrate'] / (1000 * 1000);
        $currentHashCalc = (float)$json['data']['currentHashrate'] / (1000 * 1000);
        $balance = 0;
        if (isset($json['data']['unpaid'])) {
            $balance = round((float)$json['data']['unpaid'] / (pow(10, 18)), 6);
        }
        if ($currentHashCalc <= ($params['min_percent'] * 0.01 * $params['hashrate'])) {
            // calculated hashrate is lower than allowed
            $color = '#FFFF00';
        }
        if ($totalHashSent <= ($params['min_percent'] * 0.01 * $params['hashrate'])) {
            // sent hashrate is lower than allowed
            $color = '#FF0000';
            $notifyMessage .= ' Low hashrate!';
        }

        $lastShare = $json['data']['time'] - $json['data']['lastSeen'];
        if ($lastShare > 600) {
            // last share was longer before 10 min
            $color = '#FF0000';
            $notifyMessage .= ' No Shares!';
        }
        $message .= ' ' . number_format($totalHashSent, 2)
//                . ' - ' . number_format($totalHashCalc, 2)
            . ' MH/s';

        $message .= ' | LS: ' . $lastShare . 's';
        $message .= ' | B: ' . $balance;

    } else {
        $message .= 'ERROR';
        $notifyMessage = 'Empty json!';
    }
    return array('message' => $message, 'notify' => $notifyMessage, 'color' => $color);
}


function handle_mouse_button($infoUrl, $apiUrl)
{
    $mouseBtn = getenv('BLOCK_BUTTON');
    switch ($mouseBtn) {
        case '1':
            shell_exec('chromium ' . $infoUrl . ' > /dev/null 2>&1 &');
            break;
        case '3':
            shell_exec('chromium ' . $apiUrl . ' > /dev/null 2>&1 &');
            break;
        default:
            break;
    }
}

function notify_desktop($shortMessage)
{
    putenv('HOME=' . $_SERVER['HOME']);
    $cmd = 'zenity --info --text=' . escapeshellarg(htmlspecialchars($shortMessage)) . ' --title="Mining rig problem" --display=:0';
    exec($cmd . '>/dev/null 2>&1', $output, $return_var);
}

function determineIndexToShow(&$inputData)
{
    // TODO: show more than 1
    return 0;
}

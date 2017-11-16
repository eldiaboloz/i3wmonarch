<?php

date_default_timezone_set('Europe/Sofia');
error_reporting(E_ALL | E_STRICT);
ini_set('display_startup_errors', 1);
ini_set('display_errors', 1);
ini_set('max_execution_time', 30);
ini_set('memory_limit', '128M');
mb_internal_encoding('UTF-8');

$poolParams = init_pool_params($argv);
$indexToUse = determineIndexToShow($poolParams);
$params = $poolParams[$indexToUse];

$response = parse_api_response($params);

$notifyMessage = $response['notify'];
$message = $response['message'];
$color = $response['color'];

handle_mouse_button($params['info'], $params['api']);

if ($notifyMessage)
{
    $tempFile = '/tmp/rigmon_' . $response['hash'] . '.last';
    if (!is_file($tempFile) || (filemtime($tempFile) < (time() - 1200)))
    {
        file_put_contents($tempFile, time() . PHP_EOL);
        $notifyMessage = $notifyMessage ? $notifyMessage : $message;
        notify_desktop($notifyMessage);
    }
}

echo $message . PHP_EOL;
echo $message . PHP_EOL;
echo $color . PHP_EOL;
exit;

function init_pool_params($argv)
{
    unset($argv[0]);
    $return = array();
    foreach ($argv as $arg)
    {
        $argArray = explode(';', $arg);
        $type = strtolower($argArray[0]);
        $wallet = $argArray[1];
        $email = (isset($argArray[2])) ? (strtolower($argArray[2])) : '';
        $expectedHashRate = (isset($argArray[3])) ? (floatval($argArray[3])) : 0.0;
        $coinSymbol = (isset($argArray[4]) ? $argArray[4] : '');

        switch ($type)
        {
            case 'dwarfpool-eth':
            case "dwarfpool":
                $walletRegex = '#^0x[0-9a-z]{40}$#';
                $apiUrl = 'http://dwarfpool.com/eth/api?wallet=' . $wallet . '&email=' . $email;
                $infoUrl = 'https://dwarfpool.com/eth/address?wallet=' . $wallet;
                break;
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
            case 'dwarfpool-exp':
                $walletRegex = '#^0x[0-9a-z]{40}$#';
                $apiUrl = 'http://dwarfpool.com/exp/api?wallet=' . $wallet . '&email=' . $email;
                $infoUrl = 'https://dwarfpool.com/exp/address?wallet=' . $wallet;
                break;
            case 'nomnom-music':
                $walletRegex = '#^0x[0-9a-z]{40}$#';
                $apiUrl = 'http://musicoin.nomnom.technology/api/accounts/' . $wallet;
                $infoUrl = 'http://musicoin.nomnom.technology/#/account/' . $wallet;
                break;
            case 'suprnova':
                $walletRegex = '#^[0-9a-zA-Z]{64}$#';
                $apiUrl = 'https://' . $coinSymbol . '.suprnova.cc/index.php?page=api&action=getuserstatus&api_key=' . $wallet . '&id=' . $email;
                $infoUrl = 'https://' . $coinSymbol . '.suprnova.cc/index.php?page=dashboard';
                break;
            default:
                throw new Exception('Unknown pool type: ' . $type);
        }

        if (!preg_match($walletRegex, $wallet))
        {
            echo 'invalid wallet';
            exit(1);
        }

        $return[] = array('api' => $apiUrl, 'info' => $infoUrl, 'wallet' => $wallet, 'type' => $type, 'hashrate' => $expectedHashRate, 'coin' => $coinSymbol);
    }
    return $return;

}

function parse_api_response($params)
{
    $type = $params['type'];
    $apiUrl = $params['api'];
    $response = null;
    $json = json_decode(file_get_contents($apiUrl), true);
    switch ($type)
    {
        case 'dwarfpool-eth':
        case "dwarfpool":
            $response = parse_api_response_dwarfpool($json);
            break;
        case 'ethermine':
            $response = parse_api_response_ethermine($json);
            break;
        case "dwarfpool-exp":
            $response = parse_api_response_dwarfpool_exp($json);
            break;
        case "ubiqpool":
            $response = parse_api_response_ubiqpool($json);
            break;
        case "nomnom-music":
            $response = parse_api_response_nomnom_music($json);
            break;
        case "suprnova":
            $response = parse_api_response_suprnova($json,$params);
            break;
        default:
            throw new Exception('Unknown pool type: ' . $type);
    }
    $response['hash'] = sha1($apiUrl);
    return $response;
}

function parse_api_response_dwarfpool($json)
{
    $color = '#00FF00';
    $message = 'ETH:';
    $notifyMessage = '';
    if (!empty($json))
    {
        if ($json['error'])
        {
            $message .= ' ERROR';
            $notifyMessage .= ' JSON error!';
        } else
        {
            $totalHashSent = (float)$json['total_hashrate'];
            $totalHashCalc = (float)$json['total_hashrate_calculated'];
            $balance = 0;
            if (isset($json['wallet_balance']))
            {
                $balance = round((float)$json['wallet_balance'], 6);
            }
            if ($totalHashCalc <= (0.8 * $totalHashSent))
            {
                // lower than 80% hashrate
                $color = '#FF0000';
                $notifyMessage .= ' Low hashrate!';
            }
            $lastShare = time() - strtotime($json['last_share_date']);
            if ($lastShare > 600)
            {
                // last share was longer before 10 min
                $color = '#FF0000';
                $notifyMessage .= ' No Shares!';
            }
            $message .= ' ' . number_format($totalHashSent, 2) . ' - ' . number_format($totalHashCalc, 2) . ' MH/s';
            $message .= ' | LS: ' . $lastShare . 's';
            $message .= ' | B: ' . $balance;
        }
    } else
    {
        $message .= 'ERROR';
        $notifyMessage = 'Empty json!';
    }
    return array('message' => $message, 'notify' => $notifyMessage, 'color' => $color);
}

function parse_api_response_dwarfpool_exp($json)
{
    $color = '#00FF00';
    $message = 'EXP:';
    $notifyMessage = '';
    if (!empty($json))
    {
        if ($json['error'])
        {
            $message .= ' ERROR';
            $notifyMessage .= ' JSON error!';
        } else
        {
            $totalHashSent = (float)$json['total_hashrate'];
            $totalHashCalc = (float)$json['total_hashrate_calculated'];
            $balance = 0;
            if (isset($json['wallet_balance']))
            {
                $balance = round((float)$json['wallet_balance'], 6);
            }
            if ($totalHashCalc <= (0.7 * $totalHashSent))
            {
                // lower than 80% hashrate
                $color = '#FF0000';
                $notifyMessage .= ' Low hashrate!';
            }
            $lastShare = time() - strtotime($json['last_share_date']);
            if ($lastShare > 600)
            {
                // last share was longer before 10 min
                $color = '#FF0000';
                $notifyMessage .= ' No Shares!';
            }
            $message .= ' ' . number_format($totalHashSent, 2) . ' - ' . number_format($totalHashCalc, 2) . ' MH/s';
            $message .= ' | LS: ' . $lastShare . 's';
            $message .= ' | B: ' . $balance;
        }
    } else
    {
        $message .= 'ERROR';
        $notifyMessage = 'Empty json!';
    }
    return array('message' => $message, 'notify' => $notifyMessage, 'color' => $color);
}

function parse_api_response_ubiqpool($json)
{
    $color = '#00FF00';
    $message = 'UBIQ:';
    $notifyMessage = '';
    if (!empty($json))
    {
        $totalHashSent = (float)$json['currentHashrate'] / (1000 * 1000);
        $totalHashCalc = (float)$json['hashrate'] / (1000 * 1000);
        $balance = 0;
        if (isset($json['stats']['balance']))
        {
            $balance = round((float)$json['stats']['balance'] / (1000 * 1000 * 1000), 6);
        }
        if ($totalHashCalc <= (0.7 * $totalHashSent))
        {
            // lower than 80% hashrate
            $color = '#FF0000';
            $notifyMessage .= ' Low hashrate!';
        }
        $lastShare = time() - $json['stats']['lastShare'];
        if ($lastShare > 600)
        {
            // last share was longer before 10 min
            $color = '#FF0000';
            $notifyMessage .= ' No Shares!';
        }
        $message .= ' ' . number_format($totalHashSent, 2) . ' - ' . number_format($totalHashCalc, 2) . ' MH/s';

        $message .= ' | LS: ' . $lastShare . 's';
        $message .= ' | B: ' . $balance;

    } else
    {
        $message .= 'ERROR';
        $notifyMessage = 'Empty json!';
    }
    return array('message' => $message, 'notify' => $notifyMessage, 'color' => $color);
}

function parse_api_response_ethermine($json)
{
    $color = '#00FF00';
    $message = 'ETH:';
    $notifyMessage = '';
    if (!empty($json))
    {
        $totalHashSent = (float)$json['data']['currentHashrate'] / (1000 * 1000);
//        $totalHashCalc = (float)$json['data']['averageHashrate'] / (1000 * 1000);
        $balance = 0;
        if (isset($json['data']['unpaid']))
        {
            $balance = round((float)$json['data']['unpaid'] / (pow(10, 18)), 6);
        }
//        if ($totalHashCalc <= (0.7 * $totalHashSent))
//        {
//            // lower than 80% hashrate
//            $color = '#FF0000';
//            $notifyMessage .= ' Low hashrate!';
//        }
        $lastShare = $json['data']['time'] - $json['data']['lastSeen'];
        if ($lastShare > 600)
        {
            // last share was longer before 10 min
            $color = '#FF0000';
            $notifyMessage .= ' No Shares!';
        }
        $message .= ' ' . number_format($totalHashSent, 2)
//                . ' - ' . number_format($totalHashCalc, 2)
                . ' MH/s';

        $message .= ' | LS: ' . $lastShare . 's';
        $message .= ' | B: ' . $balance;

    } else
    {
        $message .= 'ERROR';
        $notifyMessage = 'Empty json!';
    }
    return array('message' => $message, 'notify' => $notifyMessage, 'color' => $color);
}

function parse_api_response_nomnom_music($json)
{
    $color = '#00FF00';
    $message = 'MUSIC:';
    $notifyMessage = '';
    if (!empty($json))
    {
        $totalHashSent = (float)$json['currentHashrate'] / (1000 * 1000);
        $totalHashCalc = (float)$json['hashrate'] / (1000 * 1000);
        $balance = 0;
        if (isset($json['stats']['balance']))
        {
            $balance = round((float)$json['stats']['balance'] / (1000 * 1000 * 1000), 6);
        }
        if ($totalHashCalc <= (0.7 * $totalHashSent))
        {
            // lower than 80% hashrate
            $color = '#FF0000';
            $notifyMessage .= ' Low hashrate!';
        }
        $lastShare = time() - $json['stats']['lastShare'];
        if ($lastShare > 600)
        {
            // last share was longer before 10 min
            $color = '#FF0000';
            $notifyMessage .= ' No Shares!';
        }
        $message .= ' ' . number_format($totalHashSent, 2) . ' - ' . number_format($totalHashCalc, 2) . ' MH/s';

        $message .= ' | LS: ' . $lastShare . 's';
        $message .= ' | B: ' . $balance;

    } else
    {
        $message .= 'ERROR';
        $notifyMessage = 'Empty json!';
    }
    return array('message' => $message, 'notify' => $notifyMessage, 'color' => $color);
}

function parse_api_response_suprnova($json,$params)
{
    var_dump($json);exit;
    $color = '#00FF00';
    $message = strtoupper($params['coin']).':';
    $notifyMessage = '';
    if (!empty($json))
    {
        $totalHashSent = (float)$json['getuserstatus']['data']['hashrate'] / (1000);
        $message .= ' ' . number_format($totalHashSent, 2) . ' MH/s';
        $validShares = (int)(isset($json['getuserstatus']['data']['shares']['valid']) ? $json['getuserstatus']['data']['shares']['valid'] : 0);
        $invalidShares = (int)(isset($json['getuserstatus']['data']['shares']['invalid']) ? $json['getuserstatus']['data']['shares']['invalid'] : 0);
        $validPercent = 100;
        if ($invalidShares > 0)
        {
            $validPercent = round($validShares / ($validShares + $invalidShares), 0);
        }
        $message .= ' | ' . $validPercent . '% S';
        $shareRate = (int)(isset($json['getuserstatus']['data']['sharerate']) ? $json['getuserstatus']['data']['sharerate'] : 0);
        $message .= ' | SR: ' . number_format($shareRate, 2);
    } else
    {
        $message .= 'ERROR';
        $notifyMessage = 'Empty json!';
    }
    return array('message' => $message, 'notify' => $notifyMessage, 'color' => $color);
}

function handle_mouse_button($infoUrl, $apiUrl)
{
    $mouseBtn = getenv('BLOCK_BUTTON');
    switch ($mouseBtn)
    {
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
<?php

date_default_timezone_set('Europe/Sofia');
error_reporting(E_ALL | E_STRICT);
ini_set('display_startup_errors', 1);
ini_set('display_errors', 1);
ini_set('max_execution_time', 60);
ini_set('memory_limit', '128M');
mb_internal_encoding('UTF-8');

$currencies = array(
        'XMY' => array('low' => 150, 'high' => 400),
        'UBQ' => array('low' => 35000, 'high' => 43000),
        'XRP' => array('low' => 13000, 'high' => 20000),
        'MUSIC' => array('low' => 300, 'high' => 800)
);

foreach ($currencies as $currency => $data)
{
    $currentData = json_decode(file_get_contents('https://bittrex.com/api/v1.1/public/getticker?market=BTC-' . $currency), true);
    if (is_array($currentData) && isset($currentData['success']) && $currentData['success'] === true)
    {
        $buyPrice = $currentData['result']['Bid'] * pow(10, 8);
        $sellPrice = $currentData['result']['Ask'] * pow(10, 8);
        $lastPrice = $currentData['result']['Last'] * pow(10, 8);

        echo $currency . ' : ' . $buyPrice . ' / ' . $sellPrice . ' / ' . $lastPrice;

        if ($buyPrice <= $data['low'])
        {
            // good time to buy
            echo ' / BUY!';
        }
        if ($sellPrice >= $data['high'])
        {
            // goot time to sell
            echo ' / SELL!';
        }
        echo PHP_EOL;
    }
}

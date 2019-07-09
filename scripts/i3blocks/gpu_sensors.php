#!/usr/bin/env php
<?php

date_default_timezone_set( 'Europe/Sofia' );
error_reporting( E_ALL | E_STRICT );
ini_set( 'display_startup_errors', 1 );
ini_set( 'display_errors', 1 );
ini_set( 'max_execution_time', 5 );
ini_set( 'memory_limit', '64M' );
mb_internal_encoding( 'UTF-8' );

function amdGpuSensors( $rawData )
{
    $sensorsData = json_decode( $rawData );
    $rigLabel = getenv( 'BLOCK_INSTANCE' ) ? getenv( 'BLOCK_INSTANCE' ) : 'rig';
    $longResponse = $rigLabel . ':';
    $shortResponse = $rigLabel . ':';
    $hasHighTemp = false;
    $hasCriticalTemp = false;
    $highTemp = 75.0;
    $criticalTemp = 80.0;
    foreach ( $sensorsData as $sensorName => $sensorDatum )
    {
        if ( stripos( $sensorName, 'amdgpu-pci-' ) !== 0 )
        {
            continue;
        }
        $fanSpeed = round( ( $sensorDatum->fan1->fan1_input / $sensorDatum->fan1->fan1_max ) * 100 );
        $temp = $sensorDatum->temp1->temp1_input;
        $power = $sensorDatum->power1->power1_average;
        $longResponse .= ' ' . $temp . '-' . $fanSpeed . '-' . round( $power );
        $shortResponse .= ' ' . $temp;
        if ( $temp >= $highTemp )
        {
            $hasHighTemp = true;
        }
        if ( $temp >= $criticalTemp )
        {
            $hasCriticalTemp = true;
        }
    }
    echo $longResponse . PHP_EOL;
    echo $shortResponse . PHP_EOL;
    if ( $hasCriticalTemp )
    {
        echo '#FF0000' . PHP_EOL;
    }
    elseif ( $hasHighTemp )
    {
        echo '#FFFF00' . PHP_EOL;
    }
    else
    {
        echo '#00FF00' . PHP_EOL;
    }
}

function nvidiaSmiSensors( $rawData )
{
    $rigLabel = getenv( 'BLOCK_INSTANCE' ) ? getenv( 'BLOCK_INSTANCE' ) : 'rig';
    $longResponse = $rigLabel . ':';
    $shortResponse = $rigLabel . ':';
    $hasHighTemp = false;
    $hasCriticalTemp = false;
    // using mining gpus so expect lower temps
    $highTemp = 70.0;
    $criticalTemp = 75.0;
    $lines = explode( PHP_EOL, $rawData );
    $count = count( $lines );
    for ( $i = 0; $i < $count; $i++ )
    {
        $line = trim( $lines[$i] );
        if ( $line === '' )
        {
            continue;
        }
        $row = str_getcsv( $line, ',' );
        $fanSpeed = round( trim( $row[2] ) );
        $temp = trim( $row[1] );
        $power = trim( $row[0] );
        $longResponse .= ' ' . $temp . '-' . $fanSpeed . '-' . round( $power );
        $shortResponse .= ' ' . $temp;
        if ( $temp >= $highTemp )
        {
            $hasHighTemp = true;
        }
        if ( $temp >= $criticalTemp )
        {
            $hasCriticalTemp = true;
        }
    }
    echo $longResponse . PHP_EOL;
    echo $shortResponse . PHP_EOL;
    if ( $hasCriticalTemp )
    {
        echo '#FF0000' . PHP_EOL;
    }
    elseif ( $hasHighTemp )
    {
        echo '#FFFF00' . PHP_EOL;
    }
    else
    {
        echo '#00FF00' . PHP_EOL;
    }
}

if ( !isset( $argv[1] ) )
{
    echo 'No host for ssh passed' . PHP_EOL;
    exit( 1 );
}
if ( !isset( $argv[2] ) )
{
    echo 'No sensor type passed' . PHP_EOL;
    exit( 1 );
}

switch ( $argv[2] )
{
    case 'amd-gpu':
        $funcName = 'amdGpuSensors';
        $sensorsCmd = 'sensors -j';
        break;
    case 'nvidia-smi':
        $funcName = 'nvidiaSmiSensors';
        $sensorsCmd = 'nvidia-smi --query-gpu=power.draw,temperature.gpu,fan.speed --format=csv,noheader,nounits';
        break;
    default:
        echo 'Unknown sensor type!' . PHP_EOL;
        exit( 1 );
        break;
}

$rawData = shell_exec( 'ssh ' . escapeshellarg( $argv[1] ) . ' -- ' . escapeshellarg( $sensorsCmd ) );
if ( $rawData === null )
{
    echo 'Error or no output in command ! args: ' . print_r( $argv, true ) . PHP_EOL;
    exit( 1 );
}

call_user_func_array( $funcName, [ $rawData, $argv[1] ] );
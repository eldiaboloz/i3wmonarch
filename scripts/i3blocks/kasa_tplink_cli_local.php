<?php

date_default_timezone_set( 'Europe/Sofia' );
error_reporting( E_ALL | E_STRICT );
ini_set( 'display_startup_errors', 1 );
ini_set( 'display_errors', 1 );
ini_set( 'max_execution_time', 10 );
ini_set( 'memory_limit', '32M' );
mb_internal_encoding( 'UTF-8' );

// based on https://github.com/softScheck/tplink-smartplug

class TPLinkKasaCli
{
    protected $_target = '';
    protected $_label = '';
    protected $_startKey = 171;
    protected $_tcpPort = 9999;


    public function __construct( $target = '', $label = '' )
    {
        $this->_target = $target;
        $this->_label = $label;
    }

    public function encrypt( $input )
    {
        $key = $this->_startKey;
        $len = strlen( $input );
        $result = pack( 'N', $len );
        for ( $i = 0; $i < $len; $i++ )
        {
            $temp = $key ^ ord( $input[$i] );
            $key = $temp;
            $result .= chr( $temp );
        }
        return $result;

    }

    public function decrypt( $output )
    {
        // fix
        $output = substr( $output, 4 );
        $key = $this->_startKey;
        $result = '';
        $len = strlen( $output );
        for ( $i = 0; $i < $len; $i++ )
        {
            $temp = $key ^ ord( $output[$i] );
            $key = ord( $output[$i] );
            $result .= chr( $temp );
        }
        return $result;
    }

    public function send( array $payload )
    {
        $input = $this->encrypt( json_encode( $payload ) );
        $fp = fsockopen( $this->_target, $this->_tcpPort, $errno, $errstr, 3 );
        if ( !$fp )
        {
            throw new Exception( 'fsockopen : ' . $errstr, $errno );
        }
        fwrite( $fp, $input );
        $output = fread( $fp, 2048 );
        fclose( $fp );
        return $this->decrypt( $output );
    }

    public function restart()
    {
        $return = '';
        $return .= $this->stop() . PHP_EOL;
        sleep( 3 );
        $return .= $this->start() . PHP_EOL;
        return $return;
    }

    public function i3blockPrint($minWAT = 700,$maxWAT = 850)
    {
        $minWAT=(float)$minWAT;$maxWAT=(float)$maxWAT;
        $current = json_decode( $this->power(), true );
        if ( !( isset( $current['emeter']['get_realtime']['err_code'] ) && $current['emeter']['get_realtime']['err_code'] === 0 ) )
        {
            return '';
        }
        $power = round( $current['emeter']['get_realtime']['power'] );
        if ( $power <= $minWAT )
        {
            $color = '#FFFF00';
        }
        elseif ( $power >= $maxWAT )
        {
            $color = '#FF0000';
        }
        else
        {
            $color = '#00FF00';
        }
        return (
            // long
            $this->_label . ': ' . $power . ' W' . PHP_EOL .
            // short
            $power . PHP_EOL .
            // color
            $color . PHP_EOL
        );
    }

    public function __call( $name, $arguments )
    {
        $result = '';
        switch ( $name )
        {
            case 'start':
                $payload = [ "system" => [ "set_relay_state" => [ "state" => 1 ] ] ];
                break;
            case 'stop':
                $payload = [ "system" => [ "set_relay_state" => [ "state" => 0 ] ] ];
                break;
            case 'power';
                $payload = [ "emeter" => [ "get_realtime" => [] ] ];
                break;
            case 'query';
                $payload = [ "system" => [ "get_sysinfo" => [] ] ];
                break;
            default:
                throw new Exception( 'Unknown command: ' . $name );
                break;
        }
        return ( $result = $this->send( $payload ) );
    }


}

$myObj = new TPLinkKasaCli( $argv[1], $argv[2] );
echo $myObj->{$argv[3]}(array_slice($argv,4));


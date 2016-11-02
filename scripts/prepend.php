<?php
mb_internal_encoding( 'UTF-8' );
date_default_timezone_set( 'Europe/Sofia' );
error_reporting( E_ALL | E_STRICT );
ini_set( 'display_startup_errors', 1 );
ini_set( 'display_errors', 1 );

function d()
{
    $input = func_get_args();
    foreach ( $input as $value )
    {
        $dumped = false;
        if ( is_object( $value ) && method_exists( $value, 'toArray' ) )
        {
            $dumped = true;
            var_dump( $value->toArray() );
        }
        if ( !$dumped )
        {
            var_dump( $value );
        }
    }
}

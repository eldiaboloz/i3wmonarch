#!/usr/bin/env php
<?php
date_default_timezone_set( 'Europe/Sofia' );
error_reporting( E_ALL | E_STRICT );
ini_set( 'display_startup_errors', 1 );
ini_set( 'display_errors', 1 );
ini_set( 'max_execution_time', 30 );
ini_set( 'memory_limit', '128M' );
mb_internal_encoding( 'UTF-8' );

set_error_handler( "exception_error_handler" );

$payload = json_encode( gen_payload() );
$url = 'https://mandrillapp.com/api/1.0/messages/send.json';

// Prepare new cURL resource
$ch = curl_init( $url );
curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
curl_setopt( $ch, CURLINFO_HEADER_OUT, true );
curl_setopt( $ch, CURLOPT_POST, true );
curl_setopt( $ch, CURLOPT_POSTFIELDS, $payload );
curl_setopt( $ch, CURLOPT_USERAGENT, 'Mandrill-Curl/1.0' );

// Set HTTP Header for POST request
curl_setopt( $ch, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json',
        'Content-Length: ' . strlen( $payload ) )
);

// Submit the POST request
$result = curl_exec( $ch );

echo $result . PHP_EOL;

// Close cURL session handle
curl_close( $ch );

function gen_payload()
{
    $params = get_opts_custom();
    $recipients = [];
    foreach ( $params['recipients'] as $recipient )
    {
        $temp = explode( ';;', $recipient );
        $recipientArr = [ 'email' => trim( $temp[0] ), 'type' => 'to' ];
        if ( isset( $temp[1] ) )
        {
            $recipientArr['name'] = trim( $temp[1] );
        }
        $recipients[$recipientArr['email']] = $recipientArr;
    }

    $attachments = [];
    foreach ( $params['attachments'] as $attachment )
    {
        $temp = explode( ';;', $attachment );
        $filePath = trim( $temp[0] );
        $attachmentArr = [
            'content' => base64_encode( file_get_contents( $filePath ) ),
            'type' => mime_content_type( $filePath )
        ];
        if ( !isset( $temp[1] ) )
        {
            $attachmentArr['name'] = basename( $filePath );
        }
        else
        {
            $attachmentArr['name'] = trim( $temp[1] );
        }
        $attachments[] = $attachmentArr;
    }

    $payload = [
        'key' => $params['mandrill_key'],
        'message' => [
            "text" => $params['text'],
            "subject" => $params['subject'],
            "from_email" => $params['mandrill_email_from'],
            "from_name" => $params['mandrill_email_name'],
            "to" => $recipients,
            "headers" => [ "Reply-To" => $params['mandrill_email_from'] ],
            "important" => false,
            "track_opens" => null,
            "track_clicks" => null,
            "auto_text" => null,
            "auto_html" => null,
            "inline_css" => null,
            "url_strip_qs" => null,
            "preserve_recipients" => null,
            "view_content_link" => null,
            "tracking_domain" => null,
            "signing_domain" => null,
            "return_path_domain" => null,
            "tags" => [ "borg" ],
            "async" => false,
            "ip_pool" => "Main Pool",
            "attachments" => $attachments
        ]
    ];
    return $payload;
}

function exception_error_handler( $severity, $message, $file, $line )
{
    if ( !( error_reporting() & $severity ) )
    {
        // This error code is not included in error_reporting
        return;
    }
    throw new ErrorException( $message, 0, $severity, $file, $line );
}

function get_opts_custom()
{
    $reqSpec = [ 0 => ':', 1 => '::', -1 => '' ];
    $optSpecs = [
        [ 'k', 'mandrill_key', 0 ],
        [ 'e', 'mandrill_email_from', 0 ],
        [ 'n', 'mandrill_email_name', 0 ],
        [ 's', 'subject', 0 ],
        [ 't', 'text', 0 ],
        [ 'r', 'recipients', 0 ],
        [ 'a', 'attachments', 0 ],
    ];
    $shortOptSpec = '';
    $longOptSpec = [];
    $mapper = [];
    foreach ( $optSpecs as $optSpec )
    {
        $shortOptSpec .= $optSpec[0] . $reqSpec[$optSpec[2]];
        $longOptSpec[] = $optSpec[1] . $reqSpec[$optSpec[2]];
        $mapper[$optSpec[1]] = $optSpec[0];
    }
    $params = getopt( $shortOptSpec, $longOptSpec );
    foreach ( $mapper as $longOptName => $shortOptName )
    {
        // exit if both are passed
        if ( isset( $params[$longOptName] ) && isset( $params[$shortOptName] ) )
        {
            throw new Exception( 'Both -"' . $shortOptName . '" and "--' . $longOptName . '" are set !' );
        }
        // load long opt from short opt
        if ( isset( $params[$shortOptName] ) )
        {
            $params[$longOptName] = $params[$shortOptName];
        }
        // unset short opt to force usage of long opts in php code
        unset( $params[$shortOptName] );
    }
    // fix for arrays being strings if there is a single option
    if ( isset( $params['recipients'] ) && !is_array( $params['recipients'] ) )
    {
        $params['recipients'] = [ $params['recipients'] ];
    }
    if ( isset( $params['attachments'] ) && !is_array( $params['attachments'] ) )
    {
        $params['attachments'] = [ $params['attachments'] ];
    }
    return $params;
}

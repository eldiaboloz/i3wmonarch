<?php

date_default_timezone_set('Europe/Sofia');
error_reporting(E_ALL | E_STRICT);
ini_set('display_startup_errors', 1);
ini_set('display_errors', 1);
ini_set('max_execution_time', 30);
ini_set('memory_limit', '32M');
mb_internal_encoding('UTF-8');

if (!function_exists('my_exception_error_handler')) {
    /**
     * @throws ErrorException
     */
    function my_exception_error_handler($severity, $message, $file, $line)
    {
        if (!(error_reporting() & $severity)) {
            return;
        }

        throw new ErrorException($message, 0, $severity, $file, $line);
    }

    set_error_handler('my_exception_error_handler');
}

function loadHostConfig()
{
    $yamlPath = getenv("HOME") . '/dev/i3wmonarch' . '/hosts.yaml';
    $config = json_decode(`cat '$yamlPath' | yq -c .`, true);
    $hostname = gethostname();
    if ($hostname === 'portable') {
        // @TODO: think how to handle "portable" setup
        $hostname = 'work-vm';
    }
    return $config['hosts'][$hostname];
}

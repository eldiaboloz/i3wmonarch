#!/usr/bin/env php
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

class I3WM
{
    public $i3Path = '';

    public function __construct(string $i3Path = '')
    {
        if ($i3Path === '') {
            $i3Path = getenv('HOME') . '/dev/i3wmonarch';
        }
        $this->i3Path = $i3Path;
    }

    protected $_hostConfig = [];

    public function getHostConfig()
    {
        if ($this->_hostConfig === []) {
            $config = json_decode(shell_exec('cat "' . $this->i3Path . '/hosts.yaml" | yq -c "."'), true);
            $hostname = gethostname();
            if ($hostname === 'portable') {
                // @TODO: think how to handle "portable" setup
                $hostname = 'work-vm';
            }
            $this->_hostConfig = $config['hosts'][$hostname];
        }

        return $this->_hostConfig;
    }

    public function saveI3Config()
    {
        $config = $this->getHostConfig();
        $configDir = getenv("HOME") . '/.config/i3';
        $configText = PHP_EOL;

        foreach ($config['i3conf'] as $file) {
            $configText .= file_get_contents($this->i3Path . '/templates/i3config/' . $file);
        }

        $outputs = $config['outputs'] ?? [];
        if (count($outputs) == 0) {
            $outputs[0] = shell_exec("xrandr --query | grep connected | grep -v disconnected | cut -d ' ' -f1 | head -n 1 | tr -d '\n'");
        }
        $configText = str_replace(
            ['{{%leftout%}}', '{{%rightout%}}'],
            [$outputs[0], $outputs[1] ?? $outputs[0]],
            $configText
        );
        shell_exec('mkdir -pv "' . $configDir . '"');
        file_put_contents($configDir . '/config', $configText);
    }

    public function xinit()
    {
        $config = $this->getHostConfig();
        foreach ($config['xinit'] as $xinitCmd) {
            shell_exec($xinitCmd);
        }
    }

    public function startup()
    {
        $config = $this->getHostConfig();
        $currentWorkspaces=json_decode(shell_exec('i3-msg -t get_workspaces'),true);
        $currentWorkspacesNames=[];
        foreach ($currentWorkspaces as $currentWorkspace){
            $currentWorkspacesNames[$currentWorkspace['name']]=true;
        }

        foreach ($config['workspaces'] as $workspace => $workspaceData) {
            if (!isset($workspaceData['file']) || isset($currentWorkspacesNames[$workspace])) {
                // if there is no defined layout or workspace exists - skip it
                continue;
            }
            shell_exec('i3-msg "workspace \"' . $workspace . '\" ; append_layout ' . $this->i3Path . '/.i3layouts/' . $workspaceData['file'] . '"');
        }

        foreach ($config['cmds'] as $cmd) {
            shell_exec($cmd);
        }
        foreach ($config['services'] as $service) {
            shell_exec('systemctl --user start ' . $service);
        }
    }
}

$i3WM = new I3WM();
if ($argc < 2) {
    exit(1);
}
switch ($argv[1]) {
    case 'i3conf':
        $i3WM->saveI3Config();
        break;
    case 'xinit':
        $i3WM->xinit();
        break;
    case 'startup':
        $i3WM->startup();
        break;
    default:
        break;
}

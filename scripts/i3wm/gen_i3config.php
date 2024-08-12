#!/usr/bin/env php
<?php

$H = getenv("HOME");
$i3 = $H . '/dev/i3wmonarch';

require_once $i3 . '/scripts/phplib.php';

$config = loadHostConfig();
$configDir = $H . '/.config/i3';
$configText = PHP_EOL;

foreach ($config['i3conf'] as $section => $file) {
    $configText .= file_get_contents($i3 . '/templates/i3config/' . $file);
}

$outputs = $config['outputs'] ?? [];
if (count($outputs) == 0) {
    $outputs[0] = `xrandr --query | grep connected | grep -v disconnected | cut -d ' ' -f1 | head -n 1 | tr -d '\n'`;
}
$configText = str_replace(['{{%leftout%}}', '{{%rightout%}}'], [$outputs[0], $outputs[1] ?? $outputs[0]], $configText);

`mkdir -pv "{$configDir}"`;
file_put_contents($configDir . '/config', $configText);

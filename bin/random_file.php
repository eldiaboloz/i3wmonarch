#!/usr/bin/php
<?php
date_default_timezone_set( 'Europe/Sofia' );
error_reporting( E_ALL | E_STRICT );
ini_set( 'display_startup_errors', 1 );
ini_set( 'display_errors', 1 );
ini_set( 'max_execution_time', 30 );
ini_set( 'memory_limit', '32M' );
mb_internal_encoding( 'UTF-8' );

if($argc<2)
{
	echo 'empty input'.PHP_EOL;
	exit;
}
$allFiles = array();
for($i=1;$i<$argc;$i++)
{

	$dir = realpath($argv[$i]);
	if($dir===false)
	{
		echo 'no such dir'.PHP_EOL;
		exit;
	}
	$files = glob($dir.DIRECTORY_SEPARATOR.'*');
	foreach($files as $file)
	{
		$allFiles[]=$file;
	}
}
$total = count($allFiles);
if($total == 0)
{
	echo 'no files Found'.PHP_EOL;
	exit;
}
$index = rand(0,$total-1);
echo $allFiles[$index];

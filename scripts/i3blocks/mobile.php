#!/usr/bin/php
<?php
$data=json_decode(file_get_contents('/work/tmp/datafromphone.txt'),true);
$battery='';
$bat = (int)$data['bat'];
if( $bat > 90 )
{
	$battery='';
}
elseif($bat > 75)
{
	$battery='';
}
elseif($bat > 50)
{
	$battery='';
}
elseif($bat > 25)
{
	$battery='';
}
else
{
	$battery='';
}
$str=' '.$battery.' '.$bat.'%';
echo $str.PHP_EOL;
echo $str.PHP_EOL;
exit(0);
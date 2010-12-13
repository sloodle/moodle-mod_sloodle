<?php
// Simulates an ajax object-rezzing request

require_once '../../../lib/json/json_encoding.inc.php';
$content = array(
	'result' => 'rezzed'
);
$rand = rand(0,10);
sleep($rand);
print json_encode($content);
?>

<?php

if ( !defined('SLOODLE_MESSAGE_QUEUE_TASK') || !SLOODLE_MESSAGE_QUEUE_TASK) {
    echo 'This task should be run by the sloodled daemon';
    exit;
}

// $url and $body should already have been defined.

$ch = curl_init();    // initialize curl handle
curl_setopt($ch, CURLOPT_URL, $address); // set url to post to
curl_setopt($ch, CURLOPT_FAILONERROR,0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
curl_setopt($ch, CURLOPT_TIMEOUT, 10); // times out after 4s
curl_setopt($ch, CURLOPT_POST, 1); // set POST method
curl_setopt($ch, CURLOPT_POSTFIELDS,$body); // add POST fields
/*
if ($proxy = $this->httpProxyURL()) {
    curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 1);
    curl_setopt($ch, CURLOPT_PROXY, $this->httpProxyURL() );
}
*/

$result = curl_exec($ch); // run the whole process
$info = curl_getinfo($ch);
curl_close($ch);

?>

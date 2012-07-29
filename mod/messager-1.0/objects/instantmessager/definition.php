<?php
/*
This object sends an instant message to a user when asked to do so by the server.
It has been written to deal messages saying email postcard processing is finished, but probably has other applications.
Collection being set to SLOODLE 2.2 for now, although we may bring it forward.
*/
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Instant Messager';
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('SLOODLE 2.2');
$sloodleconfig->aliases    = array();
$sloodleconfig->notify     = array('message_to_user'); // If this happens on the server side, tell me about it.
$sloodleconfig->field_sets = array( );

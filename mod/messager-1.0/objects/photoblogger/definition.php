<?php
/*
This object sends an instant message to a user when asked to do so by the server.
*/
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE Photo Blogger'; 
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
/*
$sloodleconfig->collections= array('SLOODLE 2.0 Disabled');
if (defined('SLOODLE_FREEMAIL_ACTIVATE') && SLOODLE_FREEMAIL_ACTIVATE) {
    $sloodleconfig->collections= array('SLOODLE 2.0');
}
*/
$sloodleconfig->aliases    = array();
$sloodleconfig->notify     = array('message_to_user'); // If this happens on the server side, tell me about it.
global $FREEMAIL_SETTINGS;
$blogdefault = '';
if ( isset($FREEMAIL_SETTINGS) && isset($FREEMAIL_SETTINGS->sloodle_freemail_mail_email_address) ) {
    $blogdefault = $FREEMAIL_SETTINGS->sloodle_freemail_mail_email_address;
}

$sloodleconfig->field_sets = array( 
    'generalconfiguration' => array(
            'sloodleblogaddress' => new SloodleConfigurationOptionText( 'sloodleblogaddress', 'freemail:sloodleblogaddress', '', $blogdefault, 40 ),
    )
);

<?php

// This selection box determines whether or not auto-registration is allowed on the site
 
$settings->add( new admin_setting_configtext(
                'freemail_mail_email_address',
                get_string('freemail:emailtosend', 'freemail'),
                '',
                ''));


$settings->add( new admin_setting_configtext(
                'freemail_mail_user_name',
                get_string('freemail:mailaccount', 'freemail'),
                '',
                ''));
                
$settings->add( new admin_setting_configtext(
                'freemail_mail_user_pass',
                get_string('freemail:mailaccountpassword', 'freemail'),
                '',
                ''));
  
$settings->add( new admin_setting_configtext(
                'freemail_mail_box_settings',
                get_string('freemail:mailboxsettings', 'freemail'),
                get_string('freemail:gmailuse','freemail').'{imap.gmail.com:993/imap/ssl}INBOX',
                ''));
 
/*
$settings->add( new admin_setting_configselect(
                'freemail_pop3_or_imap',
                get_string('freemail:mailaccounttype','freemail'),
                '',
                0,
                array('pop3' => 'POP3', 'imap' => 'IMAP')
));
*/
  
$settings->add( new admin_setting_configtext(
                'freemail_mail_admin_email',
                get_string('freemail:adminmail', 'freemail'),
                '',
                ''));
  
  
$settings->add( new admin_setting_configtext(
                'freemail_mail_maxcheck',
                get_string('freemail:maxcheck', 'freemail'),
                '',
                ''));
 
$settings->add( new admin_setting_configtext(
                'freemail_mail_maxsize',
                get_string('freemail:delete', 'freemail'),
                '',
                ''));

/*
$settings->add( new admin_setting_configselect(
                'freemail_usepassword',
                get_string('freemail:usepass','freemail'),
                '',
                0,
                array('0' => 'No', '1' => 'Yes')
));
*/


?>

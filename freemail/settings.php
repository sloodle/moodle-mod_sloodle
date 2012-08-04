<?php

// This selection box determines whether or not auto-registration is allowed on the site
 
$settings->add( new admin_setting_configtext(
                'sloodle_freemail_mail_email_address',
                get_string('freemail:emailtosend', 'sloodle'),
                '',
                ''));


$settings->add( new admin_setting_configtext(
                'sloodle_freemail_mail_user_name',
                get_string('freemail:mailaccount', 'sloodle'),
                '',
                ''));
                
$settings->add( new admin_setting_configtext(
                'sloodle_freemail_mail_user_pass',
                get_string('freemail:mailaccountpassword', 'sloodle'),
                '',
                ''));
  
$settings->add( new admin_setting_configtext(
                'sloodle_freemail_mail_box_settings',
                get_string('freemail:mailboxsettings', 'sloodle'),
                get_string('freemail:gmailuse','sloodle').'{imap.gmail.com:993/imap/ssl}INBOX',
                ''));
 
/*
$settings->add( new admin_setting_configselect(
                'sloodle_freemail_pop3_or_imap',
                get_string('freemail:mailaccounttype','sloodle'),
                '',
                0,
                array('pop3' => 'POP3', 'imap' => 'IMAP')
));
*/
  
$settings->add( new admin_setting_configtext(
                'sloodle_freemail_mail_admin_email',
                get_string('freemail:adminmail', 'sloodle'),
                '',
                ''));
  
  
$settings->add( new admin_setting_configtext(
                'sloodle_freemail_mail_maxcheck',
                get_string('freemail:maxcheck', 'sloodle'),
                '',
                ''));
 
$settings->add( new admin_setting_configtext(
                'sloodle_freemail_mail_maxsize',
                get_string('freemail:delete', 'sloodle'),
                '',
                ''));


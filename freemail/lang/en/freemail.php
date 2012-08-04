<?php 
 /**
* Freemail v1.1 with SL patch
*
* @package freemail
* @copyright Copyright (c) 2008 Serafim Panov
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @author Serafim Panov
* 
*
*/
$string['modulename'] = 'Freemail';
$string['modulenameplural'] = 'Freemail';
$string['freemail_001'] = 'Please change CHMOD to 777 (writable) on \"freemail\" folder in your moodle module directory!';
$string['freemail_002'] = 'Don\'t forget to set cron job to \"check_mail.php\" file. Full path is ';
$string['freemail_003'] = 'or Moodle main cron file:';
$string['freemail_004'] = 'Don\'t forget to setup smtp settings in the admin area.';
$string['freemail_005'] = 'Test Mail Check:';
$string['freemail_006'] = 'Mailbox user login';
$string['freemail_007'] = 'Mailbox user password';
$string['freemail_008'] = 'Mailbox settings';
$string['freemail_010'] = 'Mail header';
$string['freemail_011'] = 'Mail footer';
$string['freemail_012'] = 'Mail subject';
$string['freemail_013'] = 'Upload profile image';
$string['freemail_014'] = 'Incorrect email';
$string['freemail_015'] = 'Incorrect password (image)';
$string['freemail_016'] = 'No commands';
$string['freemail_017'] = 'No image';
$string['freemail_018'] = 'Wrong image size';
$string['freemail_019'] = 'Help';
$string['freemail_020'] = 'Blog add';
$string['freemail_021'] = 'Incorrect password (blog)';
$string['freemail_022'] = 'No file (gallery)';
$string['freemail_023'] = 'Item is added';
$string['freemail_024'] = 'Parse mail begin, total number: ';
$string['freemail_025'] = 'send help';
$string['freemail_026'] = 'change profile image';
$string['freemail_027'] = 'add blog';
$string['freemail_028'] = 'gallery albom';
$string['freemail_029'] = 'Parse mail is ended';
$string['freemail_030'] = 'upload attached files';
$string['freemail_031'] = 'Email address (FreeMail)';
$string['freemail:cronnotice'] = '<b>Welcome to the Freemail module which has been modified for Second Life!</b>';
$string['freemail:cronnotice'] .= "<br>For more information about this module, please visit: <a href='http://slisweb.sjsu.edu/sl/index.php/Sloodle_Postcard_Blogger_(Freemail)'>The Sloodle Wiki Link for the Postcard Blogger</a>";
$string['freemail:cronnotice'] .="<br>If you are running this manually, we suggest that you set up a <a href='http://slisweb.sjsu.edu/sl/index.php/Cron'>cron job on your server</a>";    
$string['freemail:cronnotice'] .='<br>This will enable you to run a mail check automatically.  ';
$string['freemail:cronnotice'] .='<br><br>In addition, if you are getting no-write errors, you probably forgot to make http://yoursite.com/moodle/mod/freemail/log.php chmod to 777';
$string['freemail:cronnotice'] .="<br>Good luck! And please join our <a href='http://slisweb.sjsu.edu/sl/index.php/Cron'>";
$string['freemail:cronnotice'] .='Discussion forums on http://sloodle.org</a>';
$string['freemail:confignotice'] = '<b>Welcome to the Freemail module for Second Life!</b>';
$string['freemail:confignotice'] = '<br><br><b>About:</b><br>Using Freemod, your moodle users can send blog posts to Moodle directly from Second Life!';
$string['freemail:confignotice'] .= "<br><b>Wiki:<b><a href='http://slisweb.sjsu.edu/sl/index.php/Sloodle_Postcard_Blogger_(Freemail)'>(Freemail) Postcard Blogger</a>";
$string['freemail:mailaccount']='Mail Account Name';
$string['freemail:mailaccountpassword']='Mail account password';
$string['freemail:mailboxsettings']='Mailbox settings';
$string['freemail:mailaccounttype']='Mail account Type';
$string['freemail:emailtosend']='Address people will send their posts to';
$string['freemail:maxcheck']='Max. number of email messages that script checks each time it is run';
$string['freemail:delete']='Delete messages that are larger than (bytes)';
$string['freemail:usepass']='Use passwords to upload content';
$string['freemail:decodes']='Decodes/encoded subject line';
$string['freemail:decodes2']='Decodes 2 byte characters';
$string['freemail:mailheader']='Mail header';
$string['freemail:footer']='Mail footer';
$string['freemail:mailsubject']='Mail message subject';
$string['freemail:upload']='Upload profile image';
$string['freemail:incorrect']='Incorrect email';
$string['freemail:incorrectimage']='Incorrect password (image)';
$string['freemail:nocommands']='No commands';
$string['freemail:noimage']='No image';    
$string['freemail:wrongsize']='Incorrect image size';    
$string['freemail:helpcommands']='Help commands';    
$string['freemail:blogentry']='Blog entry upload';    
$string['freemail:wrongblogpass']='Incorrect password (blog)';    
$string['freemail:777']='Make sure  you use chmod to set to 777';   
$string['freemail:adminmail']='Send Error Reports and Security bulletins to:';   
$string['freemail:gmailuse']='For Gmail use:  ';
$string['freemail:log']='Freemail Log:';   
$string['freemail:testaccount']='Test Account Settings';   
$string['freemail:forums']='Discussion Forums';  
$string['freemail_subjectline']='1:'; 

$string['freemail_explanation_wheretosend'] = 'To blog from Second Life or OpenSim, email a postcard to {$a}.';
$string['freemail_explanation_howtoblog'] = 'Put the title of your blog in the subject line and the text in the body of the email.'; 
$string['freemail_testbutton'] = 'Click this button to test.'; 
$string['freemail_delete_message'] = 'Skip message deletion. (May result in duplicate blog entries.';

?>

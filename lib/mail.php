<?php


/**
* Send an email to a specific address, using the Moodle system.
* This function is heavily based on "email_to_user()" from Moodle's libraries.
*
* @uses $CFG
* @uses $FULLME
* @param string $to The address to send the email to
* @param string $subject Plain text subject line of the email
* @param string $messagetext Plain text of the message
* @return bool Returns true if mail was sent OK, or false otherwise
*/
function sloodle_text_email($to, $subject, $messagetext)
{
    global $CFG, $FULLME;

    // Fetch the PHP mailing functionality
    include_once($CFG->libdir .'/phpmailer/class.phpmailer.php');

    // We are going to use textlib services here
    $textlib = textlib_get_instance();

    // Construct a new PHP mailer
    $mail = new phpmailer;
    $mail->Version = 'Moodle '. $CFG->version;           // mailer version
    $mail->PluginDir = $CFG->libdir .'/phpmailer/';      // plugin directory (eg smtp plugin)
    // We will use Unicode UTF8
    $mail->CharSet = 'UTF-8';

    // Determine which mail system to use
    if ($CFG->smtphosts == 'qmail') {
        $mail->IsQmail();                              // use Qmail system
        
    } else if (empty($CFG->smtphosts)) {
        $mail->IsMail();                               // use PHP mail() = sendmail

    } else {
        $mail->IsSMTP();                               // use SMTP directly
        if (!empty($CFG->debugsmtp)) {
            echo '<pre>' . "\n";
            $mail->SMTPDebug = true;
        }
        $mail->Host = $CFG->smtphosts;               // specify main and backup servers

        if ($CFG->smtpuser) {                          // Use SMTP authentication
            $mail->SMTPAuth = true;
            $mail->Username = $CFG->smtpuser;
            $mail->Password = $CFG->smtppass;
        }
    }

    // Use the admin's address for the Sender field
    $adminuser = get_admin();
    $mail->Sender   = $adminuser->email;
    // Use the 'noreply' address    
    $mail->From     = $CFG->noreplyaddress;
    $mail->FromName = $CFG->wwwroot;

    // Setup the other headers
    $mail->Subject = substr(stripslashes($subject), 0, 900);
    $mail->AddAddress(stripslashes($to), 'Sloodle' );
    //$mail->WordWrap = 79; // We don't want to do a wordwrap
    
    // Add our message text
    $mail->IsHTML(false);
    $mail->Body = $messagetext;

    // Attempt to send the email
    if ($mail->Send()) {
        $mail->IsSMTP();                               // use SMTP directly
        if (!empty($CFG->debugsmtp)) {
            echo '</pre>';
        }
        return true;
        
    } else {
        mtrace('ERROR: '. $mail->ErrorInfo);
        add_to_log(SITEID, 'library', 'mailer', $FULLME, 'ERROR: '. $mail->ErrorInfo);
        if (!empty($CFG->debugsmtp)) {
            echo '</pre>';
        }
        return false;
    }
}


/**
* Send an email to an object in SL.
*
* @param string $uuid The UUID of the object to send the email to
* @param string $subject Plain text subject line of the email
* @param string $messagetext Plain text of the message
* @return bool Returns true if mail was sent OK, or false otherwise
*/
function sloodle_text_email_sl($uuid, $subject, $messagetext)
{
    return sloodle_text_email($uuid.'@lsl.secondlife.com', $subject, $messagetext);
}


?>
<?php
    /**
    * Sloodle avatar registration page.
    *
    * Allows users who have clicked an in-world registration booth to complete their
    *  avatar registration by logging-in to their Moodle account (or creating one).
    *
    * @package sloodleregenrol
    * @copyright Copyright (c) 2007 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    * @contributor Peter R. Bloomfield
    *
    */
    
    // This script is expected to be visited by a user with a web browser.
    // The following request parameters (GET or POST) are required for an initial page view:
    //
    //  sloodleuuid - the UUID of the avatar which is being registered
    //  sloodlelst - the login security token generated for the registration attempt
    //
    // Optionally, objects which need to know when registration has been accomplished can provide the following:
    //
    //  sloodlechannel - UUID of an XMLRPC channel
    //
    // In most cases, after login, the above parameters will be sufficient.
    // However, where the same avatar is already registered to another Moodle user,
    //  the user will be asked for confirmation. At this point, an additional
    //  parameter will be added:
    //
    //  sloodleconfirm - 'true' if the change/overwrite of existing details is confirmed
    //
    // A new optional parameter is the following:
    //
    //  sloodlecourseid - the integer ID of the course which the user should be enrolled in after registration
    
    /** Include Sloodle/Moodle configuration. */
    require_once('../init.php');
    require_once(SLOODLE_LIBROOT.'/general.php');
    
    sloodle_require_login_no_guest();

    // Make sure the user has permission to register their avatar
    require_capability('mod/sloodle:registeravatar', get_context_instance(CONTEXT_SYSTEM));
    
    /** Include the Sloodle API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Display the page header
    print_header_simple(get_string('welcometosloodle', 'sloodle'), "&nbsp;", get_string('welcometosloodle', 'sloodle'), "", "", true);
    
    
    // Process the request data
    $sloodle = new SloodleSession();
    
    // Check parameters
    $sloodleuuid = required_param('sloodleuuid', PARAM_TEXT);
    $sloodlelst = required_param('sloodlelst', PARAM_TEXT);
    $sloodlechannel = optional_param('sloodlechannel', NULL, PARAM_RAW);
    $sloodlecourseid = optional_param('sloodlecourseid', NULL, PARAM_INT);
    
    // Attempt to find a pending avatar entry which matches the given details
    $pa = sloodle_get_record('sloodle_pending_avatars', 'uuid', $sloodleuuid, 'lst', $sloodlelst);
    if (!$pa) {
        ?>
        <div style="text-align:center;">
         <h3><?php print_string('error', 'sloodle'); ?></h3>
         <p><?php print_string('pendingavatarnotfound', 'sloodle'); ?></p>
        </div>
        <?php
        print_footer();
		exit();
    }
    
    // Add the new avatar
    if (!$sloodle->user->add_linked_avatar($USER->id, $sloodleuuid, $pa->avname)) {
        // Failed
        ?>
        <div style="text-align:center;">
         <h3><?php print_string('error', 'sloodle'); ?></h3>
         <p><?php print_string('failedcreatesloodleuser', 'sloodle'); ?></p>
        </div>
        <?php
        print_footer();
        exit();
    }

/// /// MOODLE-SPECIFIC /// ///

    // This is a slightly dirty hack, but is needed just now to prevent multiple avatar registrations.
    // Delete any avatar belonging to this user, which doesn't match the one just registered.
    sloodle_delete_records_select_params('sloodle_users', "userid = ? AND uuid <> ?", array($USER->id, $sloodleuuid));

/// /// END MOODLE-SPECIFIC /// ///
    
    echo "<div style=\"text-align:center; font-size:140%;\">\n";
    echo get_string('welcometosloodle','sloodle').', '.$pa->avname.'<br /><br />'.get_string('userlinksuccessful','sloodle');
    echo "</div>\n";
    
    // If the object passed us a channel parameter, we'll use it to tell the object that the authentication is done.
    // (Parameter name: sloodlechannel)
    if (is_string($sloodlechannel) && !empty($sloodlechannel)) {
        flush();
        
        // XMLRPC messages going into SL strip \n, so we use \\n instead
        $sloodle->response->set_line_separator("\\n");
        // Prepare a response as a string
        $str = '';
        $sloodle->response->set_status_code(1);
        $sloodle->response->set_status_descriptor('USER_AUTH');
        $sloodle->response->add_data_line('User has been successfully registered.');
        $sloodle->response->render_to_string($str);
        
        // Send the message
        $xmlrpcresult = sloodle_send_xmlrpc_message($channel, 0, $str);
        if (!$xmlrpcresult) {
            echo '<div style="text-align:center;">';
            echo 'ERROR: Unable to tell the object that sent you here that you have been authenticated.';
            echo '</div>';
        }
    }
    
    
    // We we asked to enrol the user as well?
    if ($sloodlecourseid != NULL) {
        echo "<br/><br/><br/>";
        redirect("{$CFG->wwwroot}/course/enrol.php?id=$sloodlecourseid", get_string('nowenrol','sloodle'), 3);
    }
    
    
    print_footer();
    exit();

?>

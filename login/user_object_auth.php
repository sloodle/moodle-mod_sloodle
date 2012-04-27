<?php
    // This script is part of the Sloodle project

    /**
    * User object authorisation interface.
    * After an object in-world has initiated user-centric object authorisation,
    *  the user should visit this page using a link they were provided in-world.
    * It will finish registering the avatar (if necessary), and finish authorising the object.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */
    
    /*
    * The following parameter is always required:
    *
    *  sloodleauthid = the ID of the entry being authorised
    *
    * If an avatar is being registered at the same time, then both of the following parameters are also required:
    *
    *  sloodleuuid = UUID of the avatar
    *  sloodlelst = the system-generated login security token
    *
    */
    
    /** Include Sloodle/Moodle configuration. */
    require_once('../init.php');
    require_once(SLOODLE_LIBROOT.'/general.php');
    
    // Make sure the Moodle user is logged-in
    sloodle_require_login_no_guest();
    
    /** Include the Sloodle API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
    // Display the page header
    $strsloodle = get_string('modulename', 'sloodle');
    print_header_simple(get_string('userobjectauth', 'sloodle'), "", get_string('userobjectauth', 'sloodle'), "", "", true);
    
    // Make sure it's not a guest who is logged in
    if (isguestuser()) {
        ?>
        <div style="text-align:center;">
         <h3><?php print_string('error', 'sloodle'); ?></h3>
         <p><?php print_string('noguestaccess', 'sloodle'); ?></p>
        </div>
        <?php
        print_footer();
		exit();
    }
    
    // Process the request data
    $sloodle = new SloodleSession();
    // Load the Moodle user and linked avatar
    $sloodle->user->load_user($USER->id);
    $sloodle->user->load_linked_avatar();
    
    // Get the authorisation ID
    $sloodleauthid = required_param('sloodleauthid', PARAM_INT);
    
    // Does the avatar need to be registered?
    if (!$sloodle->user->is_avatar_loaded()) {
        // Make sure the user has permission to register their avatar
        require_capability('mod/sloodle:registeravatar', get_context_instance(CONTEXT_SYSTEM));
    
        // Get the parameters
        $sloodleuuid = required_param('sloodleuuid', PARAM_TEXT);
        $sloodlelst = required_param('sloodlelst', PARAM_TEXT);
        
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
    }
    
    // Make sure the user has permission to authorise user objects
    require_capability('mod/sloodle:userobjectauth', get_context_instance(CONTEXT_SYSTEM));

    // Attempt to authorise the object
    if ($sloodle->user->authorise_user_object($sloodleauthid)) {
        ?>
        <div style="text-align:center;">
         <p><?php print_string('objectauthsuccessful', 'sloodle'); ?></p>
        </div>
        <?php
    } else {
        ?>
        <div style="text-align:center;">
         <h3><?php print_string('error', 'sloodle'); ?></h3>
         <p><?php print_string('objectauthfailed', 'sloodle'); ?></p>
        </div>
        <?php
    }
    
    
    print_footer();
    exit();
    
    
?>

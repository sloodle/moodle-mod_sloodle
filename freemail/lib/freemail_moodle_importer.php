<?php
/*
This is a base class for email processors.
It needs to be extended by a specific moodle importer, stored in the moodle_importers directory.
*/
abstract class freemail_moodle_importer {

    var $_title;
    var $_body;
    var $_images = array();
    var $_userid;

    var $_user = null;

    // Return true to say that this processor can process the email.
    // For example, if we have a rule that blog subjects have to begin with "b:", we'll check for that.
    function can_process() {
        return false;
    }

    // Return the user ID
    function get_user_id() {
        return $this->_userid;
    }

    function set_user_id($u) {
        $this->_userid = $u;
    }

    // Return the body body
    function get_body() {
        return $this->_body;
    }

    function set_body($m) {
        $this->_body = $m;
    }

    function set_title($s) {
        $this->_title = $s;
    }

    function get_title() {
        return $this->_title;
    }

    function add_image($filename, $imgdata) {
        $this->_images[$filename] = $imgdata;
    }

    function get_images() {
        return $this->_images;
    }

    // Fetch, cache and return a Moodle user record, loading if necessary.
    // Return null on failure.
    function user($reload = false) {

        if (!$userid = intval($this->_userid)) {
            return null;
        }

        if ( !$reload && !is_null($this->_user) ) {
            return $this->_user;
        }

        global $DB;
        $this->_user = $DB->get_record('user', array('id'=>$userid));

        return $this->_user;

    }
 
    // Notify the user that their content has been imported.
    // In most cases this is probably OK as is. 
    // but you'll want to override user_notification_title() and user_notification_text() 
    // ...to customized the content of the email.
    // In the SLOODLE case we'll do some exotic stuff like sending an in-world instant message, so this will be overloaded..
    public function notify_user() {

        if (!$user = $this->user()) {
            return false;
        }

        if (!$subject = $this->user_notification_title()) {
            return false;
        }

        if (!$messagetext = $this->user_notification_text()) {
            return false;
        }

        $supportuser = generate_email_supportuser();

        email_to_user($user, $supportuser, $subject, $messagetext);

    }

    // The title of the notification sent to the user to say their content has been imported.
    // You will probably want to overload this.
    function user_notification_title() {
        return 'Content has been imported';
    }

    // The title of the notification sent to the user to say their content has been imported.
    // You will probably want to overload this to give them specific instructions about where to find their content
    // ...and if it's been imported in draft form, where to go to publish it.
    function user_notification_text() {
        return 'Your content has been imported into Moodle.'."\n";
    }

    static function available_moodle_importers() {

        global $CFG;
        $importer_dir = $CFG->dirroot.'/mod/freemail/moodle_importers';

        if (!$dh = opendir($importer_dir)) {
            return false;
        }

        $importers = array();

        while (($importer_file = readdir($dh)) !== false) {
            //print "looking at $importer_file";

            if (preg_match('/^(freemail_\w+_moodle_importer).php$/', $importer_file, $matches)) {
                
                $clsname = $matches[1];
                require_once($importer_dir.'/'.$importer_file);
                if (!class_exists($clsname)) {
                    continue;
                }
                if (!$clsname::is_available()) {
                    continue;
                }
                $importers[] = new $clsname;

            }

        }

        return $importers;

    }

    static function config_options() {
    }

}

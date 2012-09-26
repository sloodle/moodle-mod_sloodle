<?php
/*
Importer for getting the results of a message into a blog.
*/
class sloodle_freemail_blog_moodle_importer extends sloodle_freemail_moodle_importer {

    /*
    var $_title;
    var $_body;
    var $_images = array();
    var $_userid;
    */

    var $_blogid = null;

    function is_available() {
        return true;
    }

    function is_email_importable() {
        return true;
    }

    // Return true to say that this processor can process the email.
    // For example, if we have a rule that blog subjects have to begin with "b:", we'll check for that.
    // For now we'll take anything with a subject and a body.
    function can_process() {

        if ($this->_title == '') {
            return false;
        }
        if ($this->_body == '') {
            return false;
        }
        if (!$this->_userid) {
            return false;
        }
        return true;

    }

    function import() {

        global $CFG;

        if (!file_exists($CFG->dirroot.'/blog/locallib.php')) {
            return false;
        }

        require_once($CFG->dirroot.'/blog/locallib.php');
        require_once($CFG->dirroot.'/tag/lib.php');

        $format = 0; // Moodle format - some tags and links.
        $options = array('overflowdiv'=>true); // Blog did this, we probably should too.

        $publishstate = defined('SLOODLE_FREEMAIL_PUBLISH_STATE') ? SLOODLE_FREEMAIL_PUBLISH_STATE : 'draft'; // Can be 'site' or 'public'.

        $data = array(
            'subject' => format_string($this->_title),
            'summary' => format_text($this->_body, $format, $options),
            'userid'  => $this->_userid,
            'publishstate' => $publishstate
            //'tags' => array('SLOODLE')
        );

        $blogentry = new blog_entry(null, $data, $blogeditform);
        $blogentry->add();

        if (!$id = $blogentry->id) {
            return false;
        }

        $this->_blogid = $id;

        $fs = get_file_storage();

        foreach($this->_images as $name => $data) {
            
            $fileinfo = array(
                'contextid' => 1, // Hope this is right...
                'component' => 'blog',     // 
                'filearea' => 'attachment',     // 
                'itemid' => $id,
                'userid' => $this->_userid,
                'filepath' => '/',
                'filename' => time().'-'.$name
            );

            $fs->create_file_from_string( $fileinfo, $data);

        }

        return true;

    }

    // TODO: Need to either localize this or make it editable.
    function user_notification_title() {

        return 'Blog entry created by email';

    }

    function user_notification_text() {

        if (!$blogid = intval($this->_blogid)) {
            print "no blogid";
            return false;
        }

        $publishstate = defined('SLOODLE_FREEMAIL_PUBLISH_STATE') ? SLOODLE_FREEMAIL_PUBLISH_STATE : 'draft'; // Can be 'site' or 'public'.

        global $CFG;
        //$url = $CFG->wwwroot.'/blog/index.php?entryid='.$blogid;
        $editurl = $CFG->wwwroot.'/blog/edit.php?action=edit&entryid='.$blogid;

        $str  = 'This is the blog import program at '.$CFG->wwwroot."\n";

        if ($publishstate == 'draft') {
            $str .= 'Your blog entry has been created as a draft'."\n";
            $str .= 'To publish your blog entry, go to:'."\n";
        } else {
            $str .= 'Your blog entry has been created'."\n";
            $str .= 'To edit it, go to:'."\n";
        }
        $str .= $editurl."\n";

        return $str;

    }
}

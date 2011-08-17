<?php
/**
* Defines a class for viewing the SLOODLE Distributor module in Moodle.
* Derived from the module view base class.
*
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*/

/** The base module view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view_module.php');



/**
* Class for rendering a view of a Distributor module in Moodle.
* @package sloodle
*/
class sloodle_view_distributor extends sloodle_base_view_module
{
    /**
    * SLOODLE data about a Distributor, retrieved directly from the database (table: sloodle_distributor)
    * @var object
    * @access private
    */
    var $distributor = false;


    /**
    * Constructor.
    */
    function sloodle_base_view_module()
    {
    }

    /**
    * Processes request data to determine which Distributor is being accessed.
    */
    function process_request()
    {
        // Process the basic data
        parent::process_request();
        // Grab the Distributor data
        if (!$this->distributor = sloodle_get_record('sloodle_distributor', 'sloodleid', $this->sloodle->id)) error('Failed to get SLOODLE Distributor data.');
    }

    /**
    * Process any form data which has been submitted.
    */
    function process_form()
    {
    }


    /**
    * Render the view of the Distributor.
    */
    function render()
    {
        global $CFG, $USER;
    
        // Fetch a list of all distributor entries
        $entries = sloodle_get_records('sloodle_distributor_entry', 'distributorid', $this->distributor->id, 'name');
        // If the query failed, then assume there were simply no items available
        if (!is_array($entries)) $entries = array();
        $numitems = count($entries);
        
        
        // A particular default user can be requested (by avatar name) in the HTTP parameters.
        // This could be used with a "send to this avatar" button on a Sloodle user profile.
        $defaultavatar = optional_param('defaultavatar', null, PARAM_TEXT);
        
        
        // // SEND OBJECT // //
        
        // If the user and object parameters are set, then try to send an object
        if (isset($_REQUEST['user'])) $send_user = $_REQUEST['user'];
        if (isset($_REQUEST['object'])) $send_object = $_REQUEST['object'];
        if (!empty($send_user) && !empty($send_object)) {

            // Convert the HTML entities back again
            $send_object = htmlentities(stripslashes($send_object));

            // Construct and send the request
            $request = "1|OK\\nSENDOBJECT|$send_user|$send_object";
            $ok = sloodle_send_xmlrpc_message($this->distributor->channel, 0, $request);
            
            // What was the result?
            print_box_start('generalbox boxaligncenter boxwidthnarrow centerpara');
            if ($ok) {
                print '<h3 style="color:green;text-align:center;">'.get_string('sloodleobjectdistributor:successful','sloodle').'</h3>';
            } else {
                print '<h3 style="color:red;text-align:center;">'.get_string('sloodleobjectdistributor:failed','sloodle').'</h3>';
            }
            print '<p style="text-align:center;">';
                print get_string('Object','sloodle').': '.$send_object.'<br/>';
                print get_string('uuid','sloodle').': '.$send_user.'<br/>';
                print get_string('xmlrpc:channel','sloodle').': '.$this->distributor->channel.'<br/>';
                print '</p>';
            print_box_end();
        }
        
        // // ----------- // //
        

        // If there are no items in the distributor, then simply display an error message
        if ($numitems < 1) print_box('<span style="font-weight:bold; color:red;">'.get_string('sloodleobjectdistributor:noobjects','sloodle').'</span>', 'generalbox boxaligncenter boxwidthnormal centerpara');
        //error(get_string('sloodleobjectdistributor:noobjects','sloodle'));
        // If there is no XMLRPC channel specified, then display a warning message
        $disabledattr = '';
        if (empty($this->distributor->channel)) {
            print_box('<span style="font-weight:bold; color:red;">'.get_string('sloodleobjectdistributor:nochannel','sloodle').'</span>', 'generalbox boxaligncenter boxwidthnormal centerpara');
            $disabledattr = 'disabled="true"';
        }
        
        // Construct the selection box of items
        $selection_items = '<select name="object" size="1">';
        foreach ($entries as $e) {
            $escapedname = stripslashes($e->name);
            $selection_items .= "<option value=\"{$e->name}\">{$escapedname}</option>\n";
        }
        $selection_items .= '</select>';
        
        // Get a list of all avatars on the site
        $avatars = sloodle_get_records('sloodle_users', '', '', 'avname');
        if (!$avatars) $avatars = array();
        // Construct the selection box of avatars
        $selection_avatars = '<select name="user" size="1">';
        foreach ($avatars as $a) {
            // Skip avatars who do not have a UUID or associated Moodle account
            if (empty($a->uuid) || empty($a->userid)) continue;
            // Make sure the associated Moodle user can view the current course
            if (!has_capability('mod/sloodle:courseparticipate', $this->course_context, $a->userid)) continue;
            // Make sure the associated Moodle user does not have a guest role (Moodle 1.x only)
	    if (!SLOODLE_IS_ENVIRONMENT_MOODLE_2) {
                if (has_capability('moodle/legacy:guest', $this->course_context, $a->userid, false)) continue;
	    }

            $sel = '';
            if ($a->avname == $defaultavatar) $sel = 'selected="true"';
            $selection_avatars .= "<option value=\"{$a->uuid}\" $sel>{$a->avname}</option>\n";
        }
        $selection_avatars .= '</select>';
        

        // There will be 3 forms:
        //  - send to self
        //  - send to another avatar on the course
        //  - send to custom UUID
        // The first 1 will be available to any registered user whose avatar is in the database.
        // The other 2 will only be available to those with the activity management capability.
        // Furthermore, the 2nd form will only be available if there is at least 1 avatar registered on the site.

        // Start of the sending forms
        print_box_start('generalbox boxaligncenter boxwidthnormal centerpara');
        
    // // SEND TO SELF // //
        
        // Start the form
        echo '<form action="" method="POST">';
        
        // Use a table for layout
        $table_sendtoself = new stdClass();
        $table_sendtoself->head = array(get_string('sloodleobjectdistributor:sendtomyavatar','sloodle'));
        $table_sendtoself->align = array('center');
        
        // Fetch the current user's Sloodle info
        $this->sloodleuser = sloodle_get_record('sloodle_users', 'userid', $USER->id);
        if (!$this->sloodleuser) {
            $table_sendtoself->data[] = array('<span style="color:red;">'.get_string('avatarnotlinked','sloodle').'</span>');
        } else {
            // Output the hidden form data
            echo <<<XXXEODXXX
 <input type="hidden" name="s" value="{$this->sloodle->id}">
 <input type="hidden" name="user" value="{$this->sloodleuser->uuid}">
XXXEODXXX;
        
            // Object selection box
            $table_sendtoself->data[] = array(get_string('selectobject','sloodle').': '.$selection_items);
            // Submit button
            $table_sendtoself->data[] = array('<input type="submit" '.$disabledattr.' value="'.get_string('sloodleobjectdistributor:sendtomyavatar','sloodle').' ('.$this->sloodleuser->avname.')" />');
        }
        
        // Print the table
        print_table($table_sendtoself);
        
        // End the form
        echo "</form>";
        
        
        // Only show the other options if the user has permission to edit stuff
        if ($this->canedit) {
        // // SEND TO ANOTHER AVATAR // //
            
            // Start the form
            echo '<br><form action="" method="POST">';
            
            // Use a table for layout
            $table = new stdClass();
            $table->head = array(get_string('sloodleobjectdistributor:sendtoanotheravatar','sloodle'));
            $table->align = array('center');
            
            // Do we have any avatars?
            if (count($avatars) < 1) {
                $table->data[] = array('<span style="color:red;">'.get_string('nosloodleusers','sloodle').'</span>');
            } else {
                // Output the hidden form data
                echo <<<XXXEODXXX
     <input type="hidden" name="s" value="{$this->sloodle->id}">
XXXEODXXX;
                // Avatar selection box
                $table->data[] = array(get_string('selectuser','sloodle').': '.$selection_avatars);
                // Object selection box
                $table->data[] = array(get_string('selectobject','sloodle').': '.$selection_items);
                // Submit button
                $table->data[] = array('<input type="submit" '.$disabledattr.' value="'.get_string('sloodleobjectdistributor:sendtoanotheravatar','sloodle').'" />');
            }
            
            // Print the table
            print_table($table);
            
            // End the form
            echo "</form>";
            
        // // SEND TO A CUSTOM AVATAR // //
            
            // Start the form
            echo '<br><form action="" method="post">';
            
            // Use a table for layout
            $table = new stdClass();
            $table->head = array(get_string('sloodleobjectdistributor:sendtocustomavatar','sloodle'));
            $table->align = array('center');
            
            // Output the hidden form data
            echo <<<XXXEODXXX
<input type="hidden" name="s" value="{$this->sloodle->id}">
XXXEODXXX;
        
            // UUID box
            $table->data[] = array(get_string('uuid','sloodle').': '.'<input type="text" name="user" size="46" maxlength="36" />');
            // Object selection box
            $table->data[] = array(get_string('selectobject','sloodle').': '.$selection_items);
            // Submit button
            $table->data[] = array('<input type="submit" '.$disabledattr.' value="'.get_string('sloodleobjectdistributor:sendtocustomavatar','sloodle').'" />');
            
            // Print the table
            print_table($table);
            
            // End the form
            echo "</form>";
            
        // // ---------- // //
        }
    
        
        print_box_end();
    
    }

}


?>

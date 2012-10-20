<?php
/**
* Defines a base class for viewing SLOODLE Controller modules.
* Class is inherited from the base module view class.
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
* The base class for viewing a SLOODLE Controller module.
* @package sloodle
*/
class sloodle_view_controller extends sloodle_base_view_module
{
    /**
    * SLOODLE Controller data object, retreived directly from the database (table: sloodle_controller).
    * @var object
    * @access private
    */
    var $controller = null;

    /**
    * Constructor.
    */
    function sloodle_view_controller()
    {
    }

    /**
    * Uses the parent class to process basic request information, then obtains additional Controller data.
    */
    function process_request()
    {
        // Process basic data first
        parent::process_request();
        // Obtain the Controller-specific data
        if (!$this->controller = sloodle_get_record('sloodle_controller', 'sloodleid', $this->sloodle->id)) error('Failed to locate Controller data');
    }

    /**
    * Process any form data which has been submitted.
    */
    function process_form()
    {
    }

    /**
    * Render the view of the Controller.
    */
    function render()
    {
        global $CFG;
        
        // Fetch the controller data
        $this->controller = sloodle_get_record('sloodle_controller', 'sloodleid', $this->sloodle->id);
        if (!$this->controller) return false;
        
        // The name, type and description of the module should already be displayed by the main "view.php" script.
        echo "<div style=\"text-align:center;\">\n";
        
        // Check if some kind of action has been requested
        $action = optional_param('action', '', PARAM_TEXT);
        
        // Indicate whether or not this module is enabled
        echo '<p style="font-size:14pt;">'.get_string('status', 'sloodle').': ';
        if ($this->controller->enabled) {
            echo '<span style="color:green; font-weight:bold;">'.get_string('enabled','sloodle').'</span>';
        } else {
            echo '<span style="color:red; font-weight:bold;">'.get_string('disabled','sloodle').'</span>';
        }
        echo "</p>\n";
        
        // Can the user access protected data?
        if ($this->canedit) {
       
            // Active (authorised) objects
            print_box_start('generalbox boxaligncenter boxwidthwide');
            echo '<h3>'.get_string('authorizedobjects','sloodle').'</h3>';
            
            // Has a delete objects action been requested
            if ($action == 'delete_objects') {
                
                // Count how many objects we delete
                $numdeleted = 0;
                
                // Go through each request parameter
                foreach ($_REQUEST as $name => $val) {
                    // Is this a delete objects request?
                    if ($val != 'true') continue;
                    $parts = explode('_', $name);
                    if (count($parts) == 2 && $parts[0] == 'sloodledeleteobj') {
                        // Only delete the object if it belongs to this controller
                        if (sloodle_delete_records('sloodle_active_object', 'controllerid', $this->cm->id, 'id', (int)$parts[1])) {
                            $numdeleted++;
                            // Delete any associated configuration settings too
                            sloodle_delete_records('sloodle_object_config', 'object', (int)$parts[1]);
                        }
                        
                    }
                }
                
                // Indicate our results
                echo '<span style="color:red; font-weight:bold;">'.get_string('numdeleted','sloodle').': '.$numdeleted.'</span><br><br>';
            }
            
            // Get all objects authorised for this controller
            $recs = sloodle_get_records('sloodle_active_object', 'controllerid', $this->cm->id, 'timeupdated DESC');
            if (is_array($recs) && count($recs) > 0) {
                // Construct a table
                //TODO: add authorising user link
                $objects_table = new stdClass();
                $objects_table->head = array(get_string('objectname','sloodle'),get_string('objectuuid','sloodle'),get_string('objecttype','sloodle'),get_string('lastupdated','sloodle'),'');
                $objects_table->align = array('left', 'left', 'left', 'left', 'center');
                foreach ($recs as $obj) {
                    // Skip this object if it has no type information
                    if (empty($obj->type)) continue;
                    // Construct a link to this object's configuration page
                    $config_link = "<a href=\"{$CFG->wwwroot}/mod/sloodle/classroom/configure_object.php?sloodleauthid={$obj->id}\">";
                    $objects_table->data[] = array($config_link.$obj->name.'</a>', $obj->uuid, $obj->type, date('Y-m-d H:i:s T', (int)$obj->timeupdated), "<input type=\"checkbox\" name=\"sloodledeleteobj_{$obj->id}\" value=\"true\" /");
                }
                
                // Display a form and the table
                echo '<form action="" method="POST">';
                echo '<input type="hidden" name="id" value="'.$this->cm->id.'"/>';
                echo '<input type="hidden" name="action" value="delete_objects"/>';
                
                print_table($objects_table);
                echo '<input type="submit" value="'.get_string('deleteselected','sloodle').'"/>';
                
                echo '</form>';
                
            } else {
                echo '<span style="text-align:center;color:red">'.get_string('noentries','sloodle').'</span><br>';
            }
            
            print_box_end();
        }
        
        echo "</div>\n"; 
    }

}


?>

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
        if (!$this->controller = get_record('sloodle_controller', 'sloodleid', $this->sloodle->id)) error('Failed to locate Controller data');
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
        $this->controller = get_record('sloodle_controller', 'sloodleid', $this->sloodle->id);
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
        
            // Display a link to the configuration notecard page, as a popup window
            print_box_start('generalbox boxaligncenter boxwidthwide');
            echo '<h3>'.get_string('objectconfig:header', 'sloodle').'</h3>';
            echo '<p>'.get_string('objectconfig:body', 'sloodle').'</p>';
            
            // Is Prim Password access available?
            if (empty($this->controller->password)) {
                // No - display an error message
                echo '<span style="color:red; font-weight:bold;">'.get_string('objectconfig:noprimpassword','sloodle').'</span>';
            } else {
                print_string('objectconfig:select','sloodle');
                // Go through each installed type to produce our own array of objects.
                // (Our array will associate translated names and version numbers with complete object ID's).
                $objects = array();
                $mods = SloodleObjectConfig::AllAvailableAsNameVersionHash();
                if (!$mods) error('Error fetching installed object types.');
                
                foreach ($mods as $name => $versions) {
                    // Get the translated name
                    $translatedname = get_string("object:$name", 'sloodle');
                    // Reverse-sort the version
                    $sortedversions = $versions;
                    krsort($sortedversions);
                    foreach ($sortedversions as $v => $cfg) {
                        // Construct and store the complete object ID
                        $objectid = "$name-$v";
                        $objects[$translatedname][$v] = $objectid;
                    }
                }
                
                // Sort the objects by name
                ksort($objects);
                
                // Display our list of objects
                echo '<br><br><table style="text-align:left; margin-left:auto; margin-right:auto;">';
                foreach ($objects as $name => $versions) {
                    // The primary link will always be the latest version
                    $num = 0;
                    echo '<tr><td>';
                    $multipleversions = (count($versions) > 1);
                    // Go through each version (this will be latest first)
                    foreach ($versions as $v => $objectid) {
                        // Construct a link for this object's configuration
                        $link = SLOODLE_WWWROOT."/classroom/notecard_configuration_form.php?sloodlecontrollerid={$this->cm->id}&sloodleobjtype=$objectid";
                    
                        // Is this the latest version?
                        if ($num == 0) {
                            // Yes - display the object name for the link
                            echo "<span style=\"font-size:14pt;\"><a href=\"$link\">$name</a>";
                        }
                        // Do we have multiple versions available?
                        if ($multipleversions) {
                            // Yes - add the version in brackets afterwards
                            if ($num == 0) echo ' <span style="font-size:11pt; font-style:italic;">[';
                            else if ($num > 0) echo ', ';
                            echo "<a href=\"$link\">$v</a>";
                        }
                        
                        $num++;
                    }
                    
                    // Close the extra versions section if necessary
                    if ($multipleversions) echo "]</span>";
                    echo "</td></tr>";
                }
                
                echo '</table>';
            }

            print_box_end();
            
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
                        if (delete_records('sloodle_active_object', 'controllerid', $this->cm->id, 'id', (int)$parts[1])) {
                            $numdeleted++;
                            // Delete any associated configuration settings too
                            delete_records('sloodle_object_config', 'object', (int)$parts[1]);
                        }
                        
                    }
                }
                
                // Indicate our results
                echo '<span style="color:red; font-weight:bold;">'.get_string('numdeleted','sloodle').': '.$numdeleted.'</span><br><br>';
            }
            
            // Get all objects authorised for this controller
            $recs = get_records('sloodle_active_object', 'controllerid', $this->cm->id, 'timeupdated DESC');
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

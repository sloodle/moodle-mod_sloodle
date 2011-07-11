<?php
    /**
    * Sloodle module add/edit form.
    * This script defines a form used to add/edit instances of the Sloodle module.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    *
    */


/** Core Sloodle configuration/functionality */
require_once($CFG->dirroot.'/mod/sloodle/sl_config.php');
/** The base class for the Moodle module form */
require_once ($CFG->dirroot.'/course/moodleform_mod.php');


/** General Sloodle functionality */
require_once(SLOODLE_LIBROOT.'/general.php');


/**
* Used to define the Sloodle module instance add/edit form.
* @package sloodle
*/
class mod_sloodle_mod_form extends moodleform_mod {

    /**
    * Defines the form
    * @return void
    * @uses $CFG
    * @uses $COURSE
    * @uses $SLOODLE_TYPES
    */                         
    function definition() {

        global $CFG, $COURSE, $SLOODLE_TYPES;
        $mform    =& $this->_form;

//-------------------------------------------------------------------------------

        // We need to know which type is being added/edited
        $sloodletype = SLOODLE_TYPE_CTRL; // default
        
        // Are we adding a new instance?
        if (empty($this->_instance)) {
            // Yes - check for a 'type' parameter
            $sloodletype = required_param('type', PARAM_TEXT);
        } else {
            // Fetch the instance data
            $rec = sloodle_get_record('sloodle', 'id', $this->_instance);
            if (!$rec) error(get_string('modulenotfound'));
            // Get the module type
            if (empty($rec->type)) {
                error(get_string('moduletypeunknown', 'sloodle'));
            }
            $sloodletype = $rec->type;
        }
        
        // Store the fullname of the type
        $sloodletypefull = get_string("moduletype:$sloodletype", 'sloodle');
        
//-------------------------------------------------------------------------------
        
        // General info section
        $mform->addElement('header', 'general', get_string('general', 'form'));
        
        // The type is not changeable with this form
        // However, well present it as a frozen selection box, so it appears to the user with the full name,
        //  but has the short-name underlying value
        $typeelem = &$mform->addElement('select', 'type', get_string('moduletype','sloodle'), array($sloodletype => $sloodletypefull));
        $mform->setDefault('type', $sloodletype);
        $typeelem->freeze();
        $typeelem->setPersistantFreeze(true);
        $mform->setHelpButton('type', array("moduletype_$sloodletype", get_string('moduletype','sloodle'), 'sloodle'));
                
        // Make a text box for the name of the module
        $mform->addElement('text', 'name', get_string('name', 'sloodle'), array('size'=>'64'));
        // Make it text type
        $mform->setType('name', PARAM_TEXT);
        // Set a client-size rule that an entry is required
        $mform->addRule('name', null, 'required', null, 'client');

	if (method_exists($this,'add_intro_editor')) {
		$this->add_intro_editor(true);
	} else {
		// Create an HTML editor for module description (intro text)
		$mform->addElement('htmleditor', 'intro', get_string('description'));
		// Make it raw type (so the HTML isn't filtered out)
		$mform->setType('intro', PARAM_RAW);
		// Make it required
		$mform->addRule('intro', get_string('required'), 'required', null, 'client'); // Don't require description - PRB
		// Provide an HTML editor help button
		$mform->setHelpButton('intro', array('writing', 'questions', 'richtext'), false, 'editorhelpbutton');
	}


        
        
//-------------------------------------------------------------------------------
        
        // This section adds form elements which are specific to module types.
        // Each type-specific data element will be prefixed with the type name, to avoid confusion.
        // The "add_instance" and "update_instance" functions in Sloodle's "lib.php" file will then
        //  process these data items, and write them to the appropriate tables.
        
        // NOTE: the Moodle framework will NOT automatically put the default/existing values here.
        // Instead, they need to be added later, in the functions below.

        // Check which type is being added
        switch ($sloodletype) {
        
        // // CONTROLLER // //
        
        case SLOODLE_TYPE_CTRL:
            // Add the type-specific Header
            $mform->addElement('header', 'typeheader', $sloodletypefull);
            
            // Add a checkbox for whether or not this module is enabled
            $mform->addElement('checkbox', 'controller_enabled', get_string('enabled', 'sloodle'), get_string('controlaccess', 'sloodle'));
            $mform->setDefault('controller_enabled', 1);
            
            // Add a text-box for the prim password, with a help button describing it
            $mform->addElement('text', 'controller_password', get_string('primpass', 'sloodle'), array('size'=>'12','maxlength'=>'9'));
            $mform->setHelpButton('controller_password', array('prim_password', get_string('help:primpassword','sloodle'), 'sloodle'));
            // Set the field requirements
            $mform->setDefault('controller_password', mt_rand(100000000, 999999999));
            $mform->addRule('controller_password', null, 'numeric', null, 'client');
            
            // Prim Password can be omitted to disable it now (so don't require it)
            //$mform->addRule('controller_password', null, 'required', null, 'client');
            
            break;
            
            
            
        // // DISTRIBUTOR // //
        
        case SLOODLE_TYPE_DISTRIB:
        
            // Add the type-specific Header
            $mform->addElement('header', 'typeheader', $sloodletypefull);
            
            // Add a note of the current distributor channel (read-only)
            $mform->addElement('text', 'distributor_channel', get_string('xmlrpc:channel', 'sloodle').': ', array('size'=>'40', 'readonly'=>'true', 'disabled'=>'true'));
            $mform->setDefault('distributor_channel', '');
            
            // Add a note of the number of objects associated with this Distributor
            $mform->addElement('text', 'distributor_numobjects', get_string('numobjects', 'sloodle').': ', array('size'=>'4', 'readonly'=>'true', 'disabled'=>'true'));
            $mform->setDefault('distributor_numobjects', '0');
            
            // Add a checkbox option to reset the Distributor, but only if this is an existing entry being updated
            if (!empty($this->_instance)) {
                $mform->addElement('checkbox', 'distributor_reset', get_string('reset').': ', get_string('sloodleobjectdistributor:reset', 'sloodle'));
            }
            
            break;
            
            
        // // SLIDESHOW // //
        
        case SLOODLE_TYPE_PRESENTER:
        
            // Add the type-specific Header
            $mform->addElement('header', 'typeheader', $sloodletypefull);

            // Add boxes to enter the size of the frame
            $mform->addElement('text', 'presenter_framewidth', get_string('framewidth', 'sloodle').': ', array('size'=>'4'));
            $mform->addRule('presenter_framewidth', null, 'numeric', null, 'client');
            $mform->setDefault('presenter_framewidth', 512);
            
            $mform->addElement('text', 'presenter_frameheight', get_string('frameheight', 'sloodle').': ', array('size'=>'4'));
            $mform->addRule('presenter_frameheight', null, 'numeric', null, 'client');
            $mform->setDefault('presenter_frameheight', 512);

            break;
            
            
        // // TRACKER // //
        
        case SLOODLE_TYPE_TRACKER:
        	// Nothing to do
        	break;


        // // MAP // //

        case SLOODLE_TYPE_MAP:

            // Add the type-specific header
            $mform->addElement('header', 'typeheader', $sloodletypefull);
            
            // Add boxes for the initial coordinates of the map
            $mform->addElement('text', 'map_initialx', 'Initial position (X): ', array('size'=>'10')); $mform->setDefault('map_initialx', '1000.0');
            $mform->addElement('text', 'map_initialy', 'Initial position (Y): ', array('size'=>'10')); $mform->setDefault('map_initialy', '1000.0');
            
            // Add the initial zoom factor
            $mform->addElement('text', 'map_initialzoom', 'Initial zoom level (1-6): ', array('size'=>'3')); $mform->setDefault('map_initialzoom', '2');
            $mform->addRule('map_initialzoom', null, 'numeric', null, 'client');
            
            // Add a checkbox for showing pan controls
            $mform->addElement('checkbox', 'map_showpan', 'Pan controls: ', 'If checked, pan controls will be visible on the map.');
            $mform->setDefault('map_showpan', 1);
            
            // Add a checkbox for showing zoom controls
            $mform->addElement('checkbox', 'map_showzoom', 'Zoom controls: ', 'If checked, zoom controls will be visible on the map.');
            $mform->setDefault('map_showzoom', 1);
            
            // Add a checkbox for allowing dragging of the map
            $mform->addElement('checkbox', 'map_allowdrag', 'Allow dragging: ', 'If checked, users will be able to click-and-drag the map to pan it.');
            $mform->setDefault('map_allowdrag', 1);

            break;
        
        case SLOODLE_TYPE_AWARDS:
        
            global $CFG;           
            //This switch occures when the user adds a new award activity
            // Add the type-specific header
            $mform->addElement('header', 'typeheader', $sloodletypefull);           
            //get all the assignments for the course
            $mform->addElement('image','SloodleAwardImage',SLOODLE_WWWROOT.'/lib/media/awardsmall.gif' );
            break;  
         } 
//-------------------------------------------------------------------------------
        // Add the standard course module elements, except the group stuff (as Sloodle doesn't support it)
        $this->standard_coursemodule_elements(false);
        
//-------------------------------------------------------------------------------
        // Form buttons
        $this->add_action_buttons();
    }

    /**
    * Performs extra processing on the form after existing/default data has been specified.
    * @return void
    */
    function definition_after_data() {
    }
    
    /**
    * Pre-processes form initial values.
    * Given an array of default values (element name => value) by reference, this function
    *  can edit the initial values the user sees.
    * Note that this is typically only used for editing existing modules, as the initial defaults
    *  can be coded into the form definition.
    * @param array $default_values Array of element names to values/
    * @return void
    */
    function data_preprocessing(&$default_values) {
        // Get the form
        $mform =& $this->_form;
        
        // Is this a new instance?
        if (empty($this->_instance)) return;
        // Check which type this is
        switch ($default_values['type']) {
        case SLOODLE_TYPE_CTRL:
            // Fetch the controller record
            $controller = sloodle_get_record('sloodle_controller', 'sloodleid', $this->_instance);
            if (!$controller) error(get_string('secondarytablenotfound', 'sloodle'));
            
            // Add in the 'enabled' value
            $default_values['controller_enabled'] = $controller->enabled;
            // Add in the prim password value
            $default_values['controller_password'] = $controller->password;
            
            break;
            
        case SLOODLE_TYPE_DISTRIB:
            // Fetch the distributor record
            $distributor = sloodle_get_record('sloodle_distributor', 'sloodleid', $this->_instance);
            if (!$distributor) error(get_string('secondarytablenotfound', 'sloodle'));
            
            // Add in the 'channel' value
            $default_values['distributor_channel'] = $distributor->channel;
            
            // Retrieve all object entries for this Distributor
            $objects = sloodle_get_records('sloodle_distributor_entry', 'distributorid', $distributor->id);
            if (is_array($objects)) {
                $default_values['distributor_numobjects'] = count($objects);
            }
        
            break;
                
        case SLOODLE_TYPE_AWARDS:
            // Fetch the awards record
            $awards = sloodle_get_record('sloodle_awards', 'sloodleid', $this->_instance);
            if (!$awards) error(get_string('secondarytablenotfound', 'sloodle'));
            
            $default_values['icurrency'] = $awards->icurrency;
            $default_values['assignmentid'] = $awards->assignmentid;
            $default_values['maxpoints'] =$awards->maxpoints;
            
            break;
  
        case SLOODLE_TYPE_PRESENTER:
            // Fetch the Presenter record.
            $presenter = sloodle_get_record('sloodle_presenter', 'sloodleid', $this->_instance);
            if (!$presenter) error(get_string('secondarytablenotfound', 'sloodle'));

            // Add in the dimensions of the frame
            $default_values['presenter_framewidth'] = (int)$presenter->framewidth;
            $default_values['presenter_frameheight'] = (int)$presenter->frameheight;

            break;
            
        case SLOODLE_TYPE_TRACKER:
        	// Nothing to do
        	break;

        case SLOODLE_TYPE_MAP:
            // Fetch the map record
            $map = sloodle_get_record('sloodle_map', 'sloodleid', $this->_instance);
            if (!$map) error(get_string('secondarytablenotfound', 'sloodle'));
            
            // Add in all the values from the database
            $default_values['map_initialx'] = $map->initialx;
            $default_values['map_initialy'] = $map->initialy;
            $default_values['map_initialzoom'] = $map->initialzoom;
            $default_values['map_showpan'] = $map->showpan;
            $default_values['map_showzoom'] = $map->showzoom;
            $default_values['map_allowdrag'] = $map->allowdrag;
            
            break;
            
        default:
            // Nothing to do?
            break;
        }
    }


    /**
     * Validates the form data.
     * If there are errors return array of errors ("fieldname"=>"error message"),
     * otherwise true if ok.
     *
     * @param array $data array of ("fieldname"=>value) of submitted data
     * @return bool,array Array of fieldnames to error messages, or boolean true if OK
     */
    function validation($data) {
        global $SLOODLE_TYPES;
        // Prepare an array of error messages
        $errors = array();
    
        // Check which type is being used
		switch ($data['type']) {
        
        case SLOODLE_TYPE_CTRL:
            // Check that the prim password is OK
            $pwd = '';
            if (isset($data['controller_password'])) $pwd = $data['controller_password'];
            // The password can be left unspecified
            if (empty($pwd)) break;
            
            // Validate the password we have been given
            $pwderrors = array();
            if (!sloodle_validate_prim_password_verbose($pwd, $pwderrors)) {
                $errors['controller_password'] = '';
                // Add our password errors
                foreach ($pwderrors as $pe) {
                    $errors['controller_password'] .= get_string("primpass:$pe", 'sloodle') . '<br>';
                }
            }
            
            break;
            
            
        case SLOODLE_TYPE_DISTRIB:
            // Nothing to error check
            break;
         
        
        case SLOODLE_TYPE_PRESENTER:
            // Nothing to error check
            break;
            
        case SLOODLE_TYPE_TRACKER:
        	// Nothing to error check
        	break;
        
        case SLOODLE_TYPE_MAP:
            // Nothing to error check
            break; 

        // ADD FUTURE TYPES HERE
           case SLOODLE_TYPE_AWARDS:           //MOVED TO 0.41
            // Nothing to error check
           break; 

        // ADD FUTURE TYPES HERE
        
            
        default:
            // We don't know the type
            $errors['type'] = get_string('moduletypeunknown', 'sloodle');
            break;
        }
        
        // Return the errors if there were any
        if (count($errors) > 0) return $errors;
        // Everything seems OK
        return true;
    }

}
?>

<?php
    /**
    * Choice 1.0 configuration form.
    *
    * This is a fragment of HTML which gives the form elements for configuration of a choice object, v1.0.
    * ONLY the basic form elements should be included.
    * The "form" tags and submit button are already specified outside.
    * The $auth_obj and $sloodleauthid variables will identify the object being configured.
    *
    * @package sloodlechoice
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    * @contributor Edmund Edgar
    *
    */
    
    // IMPORTANT: make sure this is called from within a Sloodle script
    if (!defined('SLOODLE_VERSION')) {
        error('Not called from within a Sloodle script.');
        exit();
    }
    
    // Execute everything within a function to ensure we don't mess up the data in the other file
    sloodle_display_config_form($sloodleauthid, $auth_obj);
    
    
    
    function sloodle_display_config_form($sloodleauthid, $auth_obj)
    {
    //--------------------------------------------------------
    // SETUP

	$def = $auth_obj->objectDefinition();
	$fieldsets = $def->field_sets;

        $settings = $auth_obj->config_name_value_hash();
	if ($auth_obj->id > 0) {
		$def->populateDefaults( $settings );
	}

        $courseid = $auth_obj->course->get_course_id();

	if ( $module_choice = $def->module_choice($courseid) ) {
		// Historically, these forms have put the module choice under "General Configuration"
		// This seems wrong, but for now we'll levae it as it is.
		if (!isset($fieldsets['generalconfiguration'])) {
			$fieldsets = array_merge(array('generalconfiguration'=>array()), $fieldsets);
		}
		array_unshift($fieldsets['generalconfiguration'], $module_choice);
	}
        
	foreach($fieldsets as $fieldsetname => $fieldset) {

		sloodle_print_box_start('generalbox boxaligncenter');
		echo '<h3>'.get_string($fieldsetname,'sloodle').'</h3>';

		foreach($fieldset as $field) {
			echo get_string($field->title,'sloodle').': ';
			if ($field->type == 'yesno' ) {
				choose_from_menu_yesno($field->fieldname, $field->default);
			} else if ( ($options = $field->translatedOptions()) && is_array($options) ) {
				choose_from_menu($options, $field->fieldname, $field->default, '');
			} else {
				echo '<input type="text" name="'.$field->fieldname.'" value="'.htmlspecialchars( $field->default, ENT_QUOTES) .'" size="8" maxlength="8" />';

			}
			echo "<br><br>\n";
		}


		sloodle_print_box_end();

	}

        
    }
    
?>

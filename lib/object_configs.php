<?php
class SloodleObjectConfig {

	// The main, canonical name of the object corresponding to this config
	var $primname; 

	// A name without spaces etc by which we can refer to this object.
	// Doesn't matter what as long as it's unique for the object
	var $object_code;

	// An array of other things the object could be known by. 
	// This can be passed to the rezzed, and should be rezzed in the order specified here
	// ...so if the rezzer has two matching objects, it will rez the first one.
	// NB. We may decide to generate this automatically for multiple versions if we insist on including the version number in the object name
	var $aliases = array();

	// The Sloodle tool corresponding to this object, eg. quiz-1.0.
	// Null if there isn't one.
	var $modname;

	// The Moodle module tool corresponding to this object, eg. quiz.
	// Null if there isn't one.
	var $module;

	// The instance types to which we should limit the module selection, eg. array( 'type' => SLOODLE_TYPE_PRESENTER )
	// Null if there isn't one
	var $module_filters = array();

	// The group of objects to which this one should belong.
	// Used in displaying objects in groups in the set.
	var $group;

	// Whether the object should be displayed by default.
	// Was previously controlled using a file called "noshow".
	var $show;

	// An array of groupings containing an array of SloodleInputWidget objects
	// One used for each configuration control.
	// The keys of this array should correspond to a translation which appends 'fieldset:'
	// eg. if you define a field_set called 'access', there should be a Sloodle translation key to display it called 'fieldset:access'.
	var $field_sets = array();

	// The value of the config as currently set. 
	// Needs to be filled from somewhere, eg. an object_config or layout_entry_config record
	// For a newly created config, this will be null.
	var $value = null;
		
	// static function returning an object configuration for an object with the given name, or none if none is found
	function ForObjectName($objname) {
		$allconfigs = SloodleObjectConfig::AllAvailableAsArray();
		if (isset($allconfigs[$objname])) {
			return $allconfigs[$objname];
		}
		return null;
	}

	// ultimately: loads all the object configs from their various tool directories
	// for now, grabs them all from a single file
	function AllAvailableAsArray() {
		require(SLOODLE_DIRROOT.'/mod/object_configs_load_temporary.php');
		return $object_configs;
        }

	function AllAvailableAsArrayByGroup() {

		$objectconfigsbygroup = array();
		foreach(SloodleObjectConfig::AllAvailableAsArray() as $objname => $objconfig) {
			$group = $objconfig->group;
			if (!isset($objectconfigsbygroup[$group])) {
				$objectconfigsbygroup[$group] = array();
			}
			$objectconfigsbygroup[$group][$objname] = $objconfig;
		}
		return $objectconfigsbygroup;

	}

	// returns a SloodleObjectConfig object for the specified tool (eg. chat-1.0).
	// TODO: This currently pulls the config out of a single big list.
	// The list needs to be split into each module directory, and pulled in from there.
	// This is intended to be used where we're currently include()ing a file from its mod/object_config.php
	function ForModName( $modname ) {
			
	}

	function possibleObjectNames() {
		$names = array($this->primname);
		if ( is_array($this->aliases) ) {
			foreach($this->aliases as $al) {
				array_push( $names, $al );
			}
		}
		return $names;
	}

	// return an input widget for server access level
	function access_level_server_option() {

		$ctrl = new SloodleConfigurationOptionSelectOne();
		$ctrl->fieldname = 'sloodleserveraccesslevel';
		$ctrl->title = 'accesslevelserver';
		$ctrl->description = '';
		$ctrl->options = array(
			SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC => 'accesslevel:public',
			SLOODLE_SERVER_ACCESS_LEVEL_COURSE => 'accesslevel:course',
			SLOODLE_SERVER_ACCESS_LEVEL_SITE   => 'accesslevel:site',
			SLOODLE_SERVER_ACCESS_LEVEL_STAFF  => 'accesslevel:staff'
		);
		$ctrl->default = SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC;
		$ctrl->type = 'radio'; // This is the recommended display type for the object.

		return $ctrl;

	}

	// return an input widget for object use
	function access_level_object_use_option() {

		$ctrl = new SloodleConfigurationOptionSelectOne();
		$ctrl->fieldname = 'sloodleobjectaccessleveluse';
		$ctrl->title = 'accesslevelobject:use';
		$ctrl->description = '';
		$ctrl->options = array(
			SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC => 'accesslevel:public',
			SLOODLE_OBJECT_ACCESS_LEVEL_GROUP  => 'accesslevel:group',
			SLOODLE_OBJECT_ACCESS_LEVEL_OWNER  => 'accesslevel:owner'
		);
		$ctrl->default = SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC;
		$ctrl->type = 'radio'; // This is the recommended display type for the object.

		return $ctrl;

	}

	// return an input widget for object control
	function access_level_object_control_option() {

		$ctrl = new SloodleConfigurationOptionSelectOne();
		$ctrl->fieldname = 'sloodleobjectaccesslevelctrl';
		$ctrl->title = 'accesslevelobject:control';
		$ctrl->description = '';
		$ctrl->options = array(
			SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC => 'accesslevel:public',
			SLOODLE_OBJECT_ACCESS_LEVEL_GROUP  => 'accesslevel:group',
			SLOODLE_OBJECT_ACCESS_LEVEL_OWNER  => 'accesslevel:owner'
		);
		$ctrl->default = SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC;
		$ctrl->type = 'radio'; // This is the recommended display type for the object.

		return $ctrl;

	}

	function course_module_select( $courseid, $val = null ) {

		if (!$options = $this->course_module_options( $courseid )) {
			return false;
		}
		$str = '<select name="sloodlemoduleid">'."\n";
		foreach($options as $n => $v) {
			$selectedattr = ($val == $n) ? ' selected ' : '';
			$str .= '<option '.$selectedattr.'value="'.htmlentities( $n ).'">'.htmlentities( $v ).'</option>'."\n";
		}
		$str .= '</select>';
		/*
		foreach($options as $n => $v) {
			$selectedattr = ($val == $n) ? ' checked="checked"' : '';
			$str .= '<input type="radio" name="sloodlemoduleid" '.$selectedattr.'" value="'.htmlentities( $n ).'">'.htmlentities( $v ).''."<br />\n";
		}
		*/
		return $str;	
		
	}

	function course_module_options( $courseid )  {

		$options = array();

		$modtype = $this->module;
		if (!$modtype) {
			return false;
		}

		// Determine which course is being accessed
		//$courseid = $auth_obj->course->get_course_id();

		// We need to fetch a list of visible quizzes on the course
		// Get the ID of the chat type
		$rec = get_record('modules', 'name', $modtype);
		if (!$rec) {
			return false;
		}
		$moduleid = $rec->id;

		// Get all visible quizzes in the current course
		$recs = get_records_select('course_modules', "course = ".intval($courseid)." AND module = ".intval($moduleid)." AND visible = 1");
		if (!$recs) {
			return false;
		    //error(get_string('noquizzes','sloodle'));
		}

		foreach ($recs as $cm) {
			// Fetch the quiz instance
			$inst = get_record($modtype, 'id', $cm->instance);
			if (!$inst) {
				continue;
			}

			$skip = false;
			if (is_array($this->module_filters)) {
				foreach($this->module_filters as $n => $v) {
					if ($inst->$n != $v) {
						$skip = true;
						break;
					}
				}
			}

			if ($skip) {
				continue;
			}

			// Store the quiz details
			$options[$cm->id] = $inst->name;
		}
		// Sort the list by name
		natcasesort($options);

		return $options;
	
	}
}

// Represents a single entry or potential entry in an object configuration.
// eg. sloodlemoduleid or sloodlerefreshtime
// 
class SloodleConfigurationOption {

	// the fieldname of the option
	var $fieldname;

	// the displayed title of the widget to be fed to get_string
	var $title;

	// the description of the widget	
	var $description;

	// a set of name-value pairs of keys and their display values
	var $options = array(); 

	// the size of the display element, if applicable
	var $size = 255;

	// the maximum number of characters allowed
	var $max_length = 255;

	// the default value. should be one of the keys listed in options.
	var $default;
	
	// the recommended display type for the object.
	// currently support radio, select
	var $ctrl;

	// the type of the object, eg. yesno, select etc.
	// TODO: It would be better if these objects could render their own html, then we wouldn't need to tell anyone the type
	var $type;

	function renderForMoodleForm() {

	}

	function renderForIUIForm() {

	}

}

class SloodleConfigurationOptionYesNo extends SloodleConfigurationOption {

	function SloodleConfigurationOptionYesNo( $fieldname, $title, $description = '', $default = 0 ) {
		$this->fieldname = $fieldname;
		$this->title = $title;
		$this->description = $description;
		$this->options = array(1 => 'Yes', 0 => 'No');
		$this->default = $default;
		$this->type = 'yesno';
	}

}

class SloodleConfigurationOptionText extends SloodleConfigurationOption {

	function SloodleConfigurationOptionText( $fieldname, $title, $description, $default = '', $length = 8 ) {
		$this->fieldname = $fieldname;
		$this->title = $title;
		$this->description = $description;
		$this->options = array(0 => 'Yes', 1 => 'No');
		$this->size = $length;
		$this->max_length = $length;
		$this->default= $default;
		$this->type = 'input';
	}

}

// NB This could be presented as a set of radio buttons rather than a select
class SloodleConfigurationOptionSelectOne extends SloodleConfigurationOption {

	function SloodleConfigurationOptionSelectOne( $fieldname = null, $title = null, $description = null, $length = 8, $default = null) {
		$this->fieldname = $fieldname;
		$this->title = $title;
		$this->description = $description;
		$this->options = array(0 => 'Yes', 1 => 'No');
		$this->default = $default;
		$this->type = 'radio';
	}

}

// A setting needing a choice of course modules
class SloodleConfigurationOptionCourseModuleChoice extends SloodleConfigurationOptionSelectOne {

	// The message displayed if there are no module instances available
	var $noneavailablemessage = '';

	// An array of key-value pairs for filtering the instance modules
	var $instancefilters = array();

	function SloodleConfigurationOptionText( $fieldname, $title, $description, $noneavailablemessage, $instancefilters ) {
		$this->fieldname = $fieldname;
		$this->title = $title;
		$this->description = $description;
		$this->options = $this->course_module_options_for_config();
	}




}
?>

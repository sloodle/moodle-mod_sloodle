<?php
    // This file is part of the Sloodle project (www.sloodle.org)

    /**
    * This page shows and/or allows editing of Sloodle course settings.
    * Used as an interface script by the Moodle framework.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    * @contributor Edmund Edgar
    *
    */

    /** Sloodle/Moodle configuration script. */
    require_once('sl_config.php');
    /** Sloodle core library functionality */
    require_once(SLOODLE_DIRROOT.'/lib.php');
    /** General Sloodle functions. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** Sloodle course data. */
    require_once(SLOODLE_LIBROOT.'/course.php');   
    require_once(SLOODLE_LIBROOT.'/layout_profile.php');   
 
    // Get the Sloodle course data
    $courseid = required_param('courseid', PARAM_INT);
    $layoutid = optional_param('layoutid', -1, PARAM_INT); // 0 to add a layout, -1 just to display

    $sloodle_course = new SloodleCourse();
    if (!$sloodle_course->load($courseid)) error(get_string('failedcourseload','sloodle'));
    
    // Ensure that the user is logged-in to this course
    require_login($courseid);
    $course_context = get_context_instance(CONTEXT_COURSE, $courseid);
    
    // Do not allow guest access
    if (isguestuser()) {
        error(get_string('noguestaccess', 'sloodle'));
        exit();
    }

    // Make sure the user is logged-in and is not a guest
    if (isloggedin() == false || isguestuser() == true) {
        error(get_string('noguestaccess','sloodle'));
        exit();
    }

    // Make sure the user has permission to manage activities on this course
    $course_context = get_context_instance(CONTEXT_COURSE, $courseid);
    require_capability('moodle/course:manageactivities', $course_context);

///////////////////
    
    // Fetch string table text
    $strsloodle = get_string('modulename', 'sloodle');
    $strsloodles = get_string('modulenameplural', 'sloodle');
    $strsavechanges = get_string('savechanges');
    $stryes = get_string('yes');
    $strno = get_string('no');
    
        
    // Attempt to fetch the course module instance
    if ($courseid) {
        if (!$course = get_record('course', 'id', $courseid)) {
            error('Could not find course');
        }
    } else {
        error('Must specify a course ID');
    }
       
    // Log the view
    add_to_log($courseid, 'course', 'view sloodle layout page', "mod/sloodle/view_layout.php?courseid={$courseid}", "$course->id");
    
    // Is the user allowed to edit this course?
    require_capability('moodle/course:update', $course_context);

    // Display the page header
    $navigation = "<a href=\"{$CFG->wwwroot}/mod/sloodle/view_course.php?id={$course->id}#layouts\">".get_string('courseconfig','sloodle')."</a>";
    print_header_simple(get_string('layoutpage','sloodle'), "", $navigation, "", "", true, '', navmenu($course));
    
    
//------------------------------------------------------    
    
    // Check the user's permissions regarding layouts
    $layouts_can_use = has_capability('mod/sloodle:uselayouts', $course_context);
    $layouts_can_edit = has_capability('mod/sloodle:editlayouts', $course_context);
    
    // Only display the layouts if they can use them
    if (!$layouts_can_edit) {
        print get_string('layoutmanager:nopermission', 'sloodle');
        exit;
    }

    // Show a list of layouts, if there are any
    $layout_names = $sloodle_course->get_layout_names();

//------------------------------------------------------    

    if (isset($_POST['courseid'])) {

       /// Update

          $layoutid = required_param('layoutid', PARAM_INT);
          $layoutname = required_param('layoutname', PARAM_TEXT);

          if ( in_array($layoutname,$layout_names) ) {
              $layoutnamestoids = array_flip($layout_names);
              if ( $layoutnamestoids[$layoutname] != $layoutid )  {
                  print get_string("layoutmanager:namealreadyexists",'sloodle');
                  exit;
              }
          }

          // Define parameter names we will ignore
          $IGNORE_PARAMS = array('sloodleauthid', 'sloodledebug');
          // This structure will store our values

          $entries = array();

          $num_items = required_param('num_items', PARAM_INT);
          for ($i=0; $i<=$num_items; $i++) {

             $checkedfield = "layout_entry_on_".$i;
             $idchecked = optional_param($checkedfield, false, PARAM_TEXT);

             if ( $idchecked == "on" ) {

                $entry_id = optional_param("layout_entry_id_$i", 0, PARAM_INT);
                $object_type = required_param("object_type_$i", PARAM_TEXT);
                $layout_entry_x = required_param("layout_entry_x_$i", PARAM_TEXT);
                $layout_entry_y = required_param("layout_entry_y_$i", PARAM_TEXT);
                $layout_entry_z = required_param("layout_entry_z_$i", PARAM_TEXT);
                $rotation = required_param("layout_entry_rotation_$i", PARAM_RAW);
                $position = "<$layout_entry_x,$layout_entry_y,$layout_entry_z>";

		if ($object_type == '') {
			print "error: object_type missing";
			exit;
		}
		
                $entry = new SloodleLayoutEntry();
		if ($entry_id > 0) {
			$entry->load($entry_id);
		}
                $entry->name = $object_type;
                $entry->position = $position;
                $entry->rotation = $rotation;
                $entry->layout = $layoutid; // NB if this is a new entry, layoutid will be 0 and will need to be set on insert
                $configoptions = array('sloodlemoduleid', 'sloodleserveraccesslevel', 'sloodleobjectaccesslevelctrl', 'sloodleobjectaccessleveluse');
                foreach($configoptions as $configoption) {
                    $paramname = 'layout_entry_config_'.$configoption.'_'.$i;
                    $configval = optional_param($paramname, null, PARAM_TEXT);
                    if ($configval != null) {
                        $entry->set_config($configoption, $configval);
                    }
                }
                
                $entries[] = $entry;

             }
          }

          // Define parameter names we will ignore
          $result = $sloodle_course->save_layout_by_id($layoutid, $layoutname, $entries, $add=false);

          if ($result) {
             $next = 'view_course.php?id='.$courseid.'#layouts';
             //print '<a href="'.$next.'">next</a>';
             redirect($next);
          } else {
             print "<h3>".get_string('layoutmanager:savefailed','sloodle')."</h3>";
             exit;
	  }

    }

//------------------------------------------------------    

// Edmund Edgar, 2009-02-07: Killing this stuff for now - we'll use the list on the sloodle course page instead
/*
    if (count($layout_names) > 0) {

        echo "<center>";
        echo "<table border=\"1\">";
        foreach($layout_names as $lid=>$ln) {
            $en_cnt = count($sloodle_course->get_layout_entries($ln));
            echo "<tr><td>$ln</td><td>$en_cnt</td><td><a href=\"view_layout.php?courseid=".$courseid."&layoutid=".$lid."\">Edit</a></td></tr>";
        }
        echo "<tr><td colspan=\"2\">&nbsp;</td><td><a href=\"view_layout.php?courseid=".$courseid."&layoutid=0\">Add</a></td></tr>";
        echo "</table>";
        echo "<center>";

    } else {

        // show the add page even if the url didn't specify layoutid=0
        $layoutid = 0;

    }
*/

//------------------------------------------------------    
// Fetch current layout

    $currentlayoutentries = array();
    $recommendedon = true; // Whether by default we turn on modules that aren't already in the layout we're looking at
    $layoutname = 'Layout '.date('Y-m-d H:i:s');

    if ($layoutid > 0) {
         
        $layout = new SloodleLayout();
        $layout->load($layoutid);
        $currentlayoutentries = $sloodle_course->get_layout_entries_for_layout_id($layoutid);
        $recommendedon = false; // The user got a chance to use our recommended defaults when they added. Now we'll only turn on things that they did.
        $layoutname = $layout_names[$layoutid];
    } 

//------------------------------------------------------    
// Fetch possible options
//
 
    if ($layoutid >= 0) { // add or edit layout
    $modinfo =& get_fast_modinfo($COURSE);

    $cmsmodules = $modinfo->cms;
    $instancemodulearrays = $modinfo->instances;
    $instancemodules = array();
    if (count($instancemodulearrays) > 0) {
	    foreach($instancemodulearrays as $ima) {
		foreach($ima as $imaitem) {
			$instancemodules[] = $imaitem;
		}
	    }
    }

    $objects_to_configs = array(
	'SLOODLE Access Checker' => 'accesschecker-1.0',
	'SLOODLE Access Checker Door' => 'accesscheckerdoor-1.0',
	'SLOODLE Choice (Horizontal)' => 'choice-1.0',
	'SLOODLE Choice (Vertical)' => 'choice-1.0',
	'SLOODLE LoginZone' => 'loginzone-1.0',
	'SLOODLE MetaGloss' => 'glossary-1.0',
	'SLOODLE Password Reset' => 'pwreset-1.0',
	'SLOODLE Presenter (alpha)' => 'presenter-1.0',
	'SLOODLE PrimDrop' => 'primdrop-1.0',
	'SLOODLE Quiz Chair' => 'quiz-1.0',
	'SLOODLE Quiz Pile-On' => 'quiz-1.0',
	'SLOODLE RegEnrol Booth' => 'regbooth-1.0',
	'SLOODLE Stipend Giver (alpha)' => 'stipendgiver-1.0',
	'SLOODLE Vending Machine' => 'distributor-1.0',
	'SLOODLE WebIntercom' => 'chat-1.0'
    );

    $configs_to_access_options = array(
        'accesschecker-1.0' => array(true, false, false),
        'accesscheckerdoor-1.0' => array(true, false, false),
        'choice-1.0' => array(true, false, true),
        'demo-1.0' => array(true, true, true),
        'distributor-1.0' => array(true, true, false),
        'enrolbooth-1.0' => array(true, false, false),
        'presenter-1.0' => array(false, true, false),
        'pwreset-1.0' => array(true, false, true),
        'quiz-1.0' => array(true, false, true),
        'quiz_pile_on-1.0' => array(true, true, true),
        'regbooth-1.0' => array(true, false, false),
        'stipendgiver-1.0' => array( true, true, true)
    );

    $standardobjects = array(
        'SLOODLE RegEnrol Booth',
        'SLOODLE Access Checker Door',
        'SLOODLE Vending Machine',
        'SLOODLE LoginZone'
    );
    $instanceobjectmappingspercourse = array(
        'quiz'=>array('SLOODLE Quiz Chair','SLOODLE Quiz Pile-On'),
        'glossary'=>array('SLOODLE MetaGloss'),
        'chat'=>array('SLOODLE WebIntercom') 
    );
    $instanceobjectmappingsperstudent = array(
        // TODO: Deal with what happens when we want to rez one object per student in the class 
    );

    $rezoptions = array();
    foreach($standardobjects as $obj) {
       $rezoptions[] = array($obj);
    }
 
    // When putting in default spacing, space objects out 2 meters apart along the y axis
    define('DEFAULT_SPACING_X', 1);
    define('DEFAULT_SPACING_Y', 2);
    define('DEFAULT_CENTER_Y', 0);
    define('DEFAULT_CENTER_X', 0);
  
    // increment and return the position variables
	/*

                O O  
	       O O O
              O O O O
             O O O O O
            O O O O O O
	*/

    function rowForItem($index) {
        $index++;
        $itemsPerRow = 1;
        $row = 1;
        $itemsInThisRow = 0;
        for ($i=0; $i<$index; $i++) {
             
        }
        return $row;
    }

    function xForIndex($index) {
        return 1;
    }

    function yForIndex($index) {
        return $index;
    }

    $pageitem = 0;
    $item = 0;

    $posx = 1;
    $posy = 1;
    $posz = -2; // they'll need to be below the rezzer
    // make a list of potential objects and their potential and default configuration settings
    $possiblemoduleobjects = array();
    $allpossiblemodules = array_merge($cmsmodules, $instancemodules);
    $modulesbyid = array();
    foreach($allpossiblemodules as $mod) {

        // for easy access later
        $modid = $mod->id;
        $modulesbyid[$modid] = $mod;

        $modname = $mod->modname;
        if (isset($instanceobjectmappingspercourse[$modname])) {
           $modobjects = $instanceobjectmappingspercourse[$modname];
           
           $isdefault = true;
           foreach($modobjects as $mo) {
              $pm = array(
                 'object'=>$mo, 
                 'id'=>$mod->id, 
                 'name'=>$mod->name, 
                 'isdefault'=>($isdefault && $recommendedon)
              );
              $possiblemoduleobjects[] = $pm;
              $isdefault = false;  // By default, only turn on the first object for each module
           }
        }
    }

    //------------------------------------------------------

    echo "<center>";

    // Create a form
    echo "<form action=\"view_layout.php\" method=\"POST\">\n";
    echo "<input type=\"hidden\" name=\"courseid\" value=\"{$course->id}\">\n";
    echo "<input type=\"hidden\" name=\"layoutid\" value=\"{$layoutid}\">\n";

    $description_table = new stdClass();
    $description_table->head = array(get_string('layoutmanager:Layouts', 'sloodle'));
    $description_table->data[] = array(get_string('layoutmanager:layoutaddpageexplanation', 'sloodle'));

    print '<br />';
    print_table($description_table);

    $name_table = new stdClass();
    $name_table->data[] = array(get_string('layoutmanager:layoutname', 'sloodle'),"<input type=\"text\" name=\"layoutname\" maxlength=\"40\" size=\"40\" value=\"{$layoutname}\" />");

    print '<br />';
    print_table($name_table);

    print '<br />';

    if (!empty($currentlayoutentries)) {


	    $table = new stdClass();
	    $table->head = array('&nbsp;','&nbsp;',get_string('layoutmanager:currentobjects','sloodle'),get_string('layoutmanager:module','sloodle'),get_string('layoutmanager:x','sloodle'),get_string('layoutmanager:y','sloodle'),get_string('layoutmanager:z','sloodle'),get_string('accesslevelobject:use','sloodle'),get_string('accesslevelobject:control','sloodle'),get_string('accesslevel','sloodle'));



	    foreach($currentlayoutentries as $co) {

	       $sloodlemoduleid = '';
	       $modname = '';
	       $confighash = $co->get_layout_entry_configs_as_name_value_hash();
	       if (isset($confighash['sloodlemoduleid'])) {
		   $sloodlemoduleid = $confighash['sloodlemoduleid'];
		   if (isset($modulesbyid[$sloodlemoduleid])) {
		      $modobj = $modulesbyid[$sloodlemoduleid];
		      $modname = $modobj->name;
		   }
	       }
	       $posxyz = $co->position;
	       //if (preg_match('/^<(-?\d+)\,(-?\d+)\,(-?\d+)>$/', $posxyz, $matches)) {
	       if (preg_match('/^<(.*?)\,(.*?)\,(.*?)>$/', $posxyz, $matches)) {
		  $posx = $matches[1];
		  $posy = $matches[2];
		  $posz = $matches[3];
	       } 
	       $accesssettings = array(true, true, true);
	       if (isset($objects_to_configs[$co->name])) {
		  $linkertype = $objects_to_configs[$co->name];
		  if (isset($configs_to_access_options[$linkertype])) {
		     $accesssettings = $configs_to_access_options[$linkertype];
		  }
	       }
	       echo "\n";
	       echo "<input type=\"hidden\" name=\"layout_entry_id_{$item}\" value=\"{$co->id}\" />";
	       echo "<input type=\"hidden\" name=\"object_type_{$item}\" value=\"{$co->name}\" />";
	       echo "<input type=\"hidden\" name=\"layout_entry_rotation_{$item}\" value=\"{$co->rotation}\" />";
	       echo $co->get_layout_entry_configs_as_hidden_fields('layout_entry_config_', '_'.$item); 
	       echo "\n";

	       $table->data[] = array(
		  $co->id,
		  "<input type=\"checkbox\" name=\"layout_entry_on_{$item}\" value=\"on\" checked=\"checked\" />",
		  $co->name,
		  $modname,
		  "<input type=\"text\" name=\"layout_entry_x_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posx\" />",
		  "<input type=\"text\" name=\"layout_entry_y_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posy\" />",
		  "<input type=\"text\" name=\"layout_entry_z_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posz\" />",
		  sloodle_access_level_option_choice('sloodleobjectaccessleveluse', $confighash, $accesssettings[0], $prefix = 'layout_entry_config_', $suffix = '_'.$item),
		  sloodle_access_level_option_choice('sloodleobjectaccesslevelctrl', $confighash, $accesssettings[1], $prefix = 'layout_entry_config_', $suffix = '_'.$item),
		  sloodle_access_level_option_choice('sloodleserveraccesslevel', $confighash, $accesssettings[2], $prefix = 'layout_entry_config_', $suffix = '_'.$item)

	       );
	       $item++; 
	       $pageitem++;
	    }

        print_table($table);

	print '<br />';

    }

    $table = new stdClass();
    $table->head = array('&nbsp; &nbsp; &nbsp; ','&nbsp;',get_string('layoutmanager:addobjects','sloodle'),get_string('layoutmanager:module','sloodle'),get_string('layoutmanager:x','sloodle'),get_string('layoutmanager:y','sloodle'),get_string('layoutmanager:z','sloodle'),get_string('accesslevelobject:use','sloodle'),get_string('accesslevelobject:control','sloodle'),get_string('accesslevel','sloodle'));

    $checkedflag = '';
    if ($recommendedon) {
        $checkedflag = 'checked="checked" ';
    }
    foreach($standardobjects as $so) {

       $confighash = array();		       

       $posy = yForIndex($pageitem);
       $posx = xForIndex($pageitem);
     
       $accesssettings = array(true, true, true);
       if (isset($objects_to_configs[$so])) {
          $linkertype = $objects_to_configs[$so];
          if (isset($configs_to_access_options[$linkertype])) {
             $accesssettings = $configs_to_access_options[$linkertype];
          }
       }
       echo "<input type=\"hidden\" name=\"object_type_{$item}\" value=\"{$so}\" />";
       echo "<input type=\"hidden\" name=\"layout_entry_rotation_{$item}\" value=\"<0,0,0>\" />";

       $table->data[] = array(
           "&nbsp;",
           "<input type=\"checkbox\" name=\"layout_entry_on_{$item}\" value=\"on\" {$checkedflag} />",
           "{$so}",
           "-",
           "<input type=\"text\" name=\"layout_entry_x_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posx\" />",
           "<input type=\"text\" name=\"layout_entry_y_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posy\" />",
           "<input type=\"text\" name=\"layout_entry_z_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posz\" />",
           sloodle_access_level_option_choice('sloodleobjectaccessleveluse', $confighash, $accesssettings[0], $prefix = 'layout_entry_config_', $suffix = '_'.$item),
           sloodle_access_level_option_choice('sloodleobjectaccesslevelctrl', $confighash, $accesssettings[1], $prefix = 'layout_entry_config_', $suffix = '_'.$item),
           sloodle_access_level_option_choice('sloodleserveraccesslevel', $confighash, $accesssettings[2], $prefix = 'layout_entry_config_', $suffix = '_'.$item)
       );
       //$posy = $posy + DEFAULT_SPACING_Y;
      //$posx = $posx + DEFAULT_SPACING_X;
       $item++; 
       $pageitem++; 
    }

    foreach($possiblemoduleobjects as $pmo) {

       $posy = yForIndex($pageitem);
       $posx = xForIndex($pageitem);

       $accesssettings = array(true, true, true);
       $objname = $pmo['object'];
       if (isset($objects_to_configs[$objname])) {
          $linkertype = $objects_to_configs[$objname];
          if (isset($configs_to_access_options[$linkertype])) {
             $accesssettings = $configs_to_access_options[$linkertype];
          }
       }
 
       echo "\n";
       echo "<input type=\"hidden\" name=\"object_type_{$item}\" value=\"{$pmo['object']}\" />";
       echo "<input type=\"hidden\" name=\"layout_entry_rotation_{$item}\" value=\"<0,0,0>\" />";
       echo "<input type=\"hidden\" name=\"layout_entry_config_sloodlemoduleid_{$item}\" value=\"{$pmo['id']}\" />";

       $checkedflag = '';
       if ($pmo['isdefault']) {
           $checkedflag = "checked=\"checked\""; 
       }
       $table->data[] = array(
           "&nbsp;",
           "<input type=\"checkbox\" name=\"layout_entry_on_{$item}\" {$checkedflag} />",
           "{$pmo['object']}",
           "{$pmo['name']}",
           "<input type=\"text\" name=\"layout_entry_x_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posx\" />",
           "<input type=\"text\" name=\"layout_entry_y_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posy\" />",
           "<input type=\"text\" name=\"layout_entry_z_{$item}\" size=\"4\" maxlength=\"9\" value=\"$posz\" />",
           sloodle_access_level_option_choice('sloodleobjectaccessleveluse', $confighash, $accesssettings[0], $prefix = 'layout_entry_config_', $suffix = '_'.$item),
           sloodle_access_level_option_choice('sloodleobjectaccesslevelctrl', $confighash, $accesssettings[1], $prefix = 'layout_entry_config_', $suffix = '_'.$item),
           sloodle_access_level_option_choice('sloodleserveraccesslevel', $confighash, $accesssettings[2], $prefix = 'layout_entry_config_', $suffix = '_'.$item)
       );
      //$posy = $posy + DEFAULT_SPACING_Y;
      // $posx = $posx + DEFAULT_SPACING_X;
       $item++; 
       $pageitem++; 
    }
    print_table($table);

    // TODO: localize
    echo '<input type="hidden" name="num_items" value="'.($item-1).'" />';
    echo '<input type="submit" value="'.get_string('layoutmanager:savelayout','sloodle').'" />';
    // Determine how many allocations there are for this course
    echo "</form>\n";

    echo "</center>";

    }

    print_box_end();

//------------------------------------------------------
    
    print_footer($course);
    
?>

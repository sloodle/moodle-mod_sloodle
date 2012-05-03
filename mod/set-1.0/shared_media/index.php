<?php
    // This script is part of the Sloodle project
    // Created for Avatar Classroom, with the intention of eventually being ported back to regular Sloodle.
    // Some assumptions that are true for Avatar Classroom won't be true for arbitrary Moodle sites.
    // I'll try to comment these REGULAR SLOODLE TODO.

    /*
    * This script is intended to be shown on the surface of the Set.
    *
    * It will need to be passed all the paramters necessary to register the set in Authorized Objects.
    * This will include an http-in channel, it will use to send instructions to the set.
    * 
    * It will allow the user to browse their courses, layouts and objects.
    * They will then be able to rez layouts by creating AJAX requests which the server will then pass on to the rezzer object.
    *
    * When used for regular Sloodle, it will have the user login before showing them anything.
    * With Avatar Classroom the user will instead login to the Avatar Classroom site.
    * The Avatar Classroom site will then proxy to this page, attaching a token which will be used to authenticate the user.
    */

    /**
    * @package sloodleset
    * @copyright Copyright (c) 2010 various contributors (see below)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    *
    */

    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../../init.php');
    /** Include the Sloodle PHP API. */
    /** Sloodle core library functionality */
    require_once(SLOODLE_DIRROOT.'/lib.php');
    /** General Sloodle functions. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** Sloodle course data. */
    require_once(SLOODLE_LIBROOT.'/course.php');
    require_once(SLOODLE_LIBROOT.'/layout_profile.php');
    require_once(SLOODLE_LIBROOT.'/active_object.php');
    require_once(SLOODLE_LIBROOT.'/user.php');

    include('index.template.php');

    $object_uuid = required_param('sloodleobjuuid', PARAM_RAW);
    $objname = '';
    $httpinurl = '';
    $sloodleobjuuid = '';
    $sloodleavname = '';

//ini_set('display_errors', 1);
//error_reporting(E_ALL);

    // Prior to 2012-03-07, we put a whole bunch of parameters in the URL.
    // This turned out to have issues with URLs getting too long, 
    // ...so we changed it to have the rezzer send them direct to the server
    // ...where they were saved in the active_objects table. 
    // For backwards compatibility, we'll keep using the old method if you pass us the full list of parameters.
    $baseurl = 'index.php?sloodleobjuuid='.$object_uuid;

    if (isset($_REQUEST['sloodleavname'])) {

        // Old method
        // Deprecated - can remove when no more alpha users are expected

        $baseurl = 'index.php?sloodleobjuuid='.htmlentities($_REQUEST['sloodleobjuuid']).'&sloodleavname='.htmlentities($_REQUEST['sloodleavname']).'&sloodleobjuuid='.htmlentities($_REQUEST['sloodleobjuuid']).'&sloodleobjname='.htmlentities($_REQUEST['sloodleobjname']).'&httpinurl='.htmlentities($_REQUEST['httpinurl']);

        $httpinurl = optional_param('httpinurl', NULL, PARAM_RAW);
        $objname = required_param('sloodleobjname', PARAM_RAW);

		$sloodleobjuuid = optional_param('sloodleobjuuid', '', PARAM_RAW);
		$sloodleavname = optional_param('sloodleavname', '', PARAM_RAW);

    } else {

        // We should have an active object record. 
        $ao = new SloodleActiveObject();
        $sloodleuser = new SloodleUser();
        $sloodleuser->user_data = $USER;

        $timeupdated = 0;
        if ( $ao->loadByUUID($object_uuid) ) {

                $object_uuid = $ao->uuid;
                $httpinurl = $ao->httpinurl;
                $objname = $ao->name;
                $timeupdated = $ao->timeupdated;

        } 
             
        // Do legacy sites the legacy way
        if (!isset($_REQUEST['sloodleavname'])) {

            // For Avatar Classroom, the rezzer config may have been stored on the avatar classroom server.
            // This URL should already have a parameter name and an =, if required.
            // NB This will fail on PHP < 5.
            if (defined('SLOODLE_SHARED_MEDIA_REZZER_CONFIG_WEB_SERVICE') && (SLOODLE_SHARED_MEDIA_REZZER_CONFIG_WEB_SERVICE != '') ) {

                // Initializing curl
                $ch = curl_init( SLOODLE_SHARED_MEDIA_REZZER_CONFIG_WEB_SERVICE.$_REQUEST['sloodleobjuuid'] );
                $options = array(
                    CURLOPT_RETURNTRANSFER => true,
                );
                curl_setopt_array( $ch, $options );
                if ($result = curl_exec($ch)) {
                    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                    if ($http_code == 200) {
                        $ao_obj = json_decode($result);
                        // If the server has been updated after our active object list because of a rezzer reset, use the new information.
                        if ( ( !$timeupdated ) || ($ao_obj->timeupdated >= $timeupdated) ) {
                            $object_uuid = $ao_obj->uuid;
                            $httpinurl = $ao_obj->httpinurl;
                            $objname = $ao_obj->name;
                        }
                    } 
                } 

            }
        }

    }

	$hasCourses = false;
	$hasControllers = false;
	$hasControllersWithPermission = false;

	$sitesURL = '';
	if (defined('SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL') && (SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL != '') ) {
		$sitesURL = SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL.SLOODLE_SHARED_MEDIA_SITE_LIST_TOP.'?sloodleobjuuid='.$object_uuid;
	}

	if (isset($_GET['logout'])) {
		if ( defined('SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE') && ( SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE != '' ) ) {
			require(SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE);	
		} else {
			require_logout();
			header('Location: '.$baseurl);
			exit;
		}
	}

	if ( (!$USER || !$USER->id) || (function_exists('isguestuser') && isguestuser()) ) {
		if ( defined('SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE') && ( SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE != '' ) ) {
			require(SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE);	
		} else {
			// If we have auto login guests on, we have to simulate a logout first
			// ...before require_login will force a login.
			if (function_exists('isguestuser') && isguestuser()) {
				$USER = null;
			}
			require_login(null, false);
		}
	}

	if ( defined('SLOODLE_SHARED_MEDIA_AUTOLINK_REZZER_OWNER') && SLOODLE_SHARED_MEDIA_AUTOLINK_REZZER_OWNER ) {
		if( ( $sloodleobjuuid != '' ) && ( $sloodleavname != '' ) ) {
			$su = new SloodleUser();
			if (!$su->load_avatar($sloodleobjuuid, $sloodleavname)) {
				if (!$su->load_avatar_by_user_id(intval($USER->id))) {
					$su->add_linked_avatar($USER->id, $sloodleobjuuid, $sloodleavname);
				}
			}
		}
	}

	if (false && !preg_match('/SecondLife/', $_SERVER['HTTP_USER_AGENT']) && !isset($_REQUEST['frame'] ) ) {
		$baseurl .= '&frame=1';
		echo '<html><body><div style="width:100%; text-align:center"><iframe width="1000" height="1000" src="'.$baseurl.'"></div></body></html>';
		exit;
	}

	// Register the set using URL parameters
	$ao = new SloodleActiveObject();
    if (!$ao->loadByUUID($object_uuid)) {

		$ao->controllerid = 0; // Hope that's OK...
		$ao->userid = $USER->id;
		$ao->uuid = $object_uuid;
		$ao->httpinurl = $httpinurl;
		$ao->httpinpassword = sloodle_random_prim_password();
		$ao->password = rand(100000,9999999999);
		$ao->name = $objname;
		$ao->type = 'set-1.0';
		$ao->save();
	} else {
		if ($httpinurl) {
			if ($ao->httpinurl != $httpinurl) {
				$ao->httpinurl = $httpinurl;
				$ao->save();
			} 
		}
	}

	// A list of all the sites the user has - gets passed by avatar classroom - won't be used for regular sloodle sites
	// If supplied, adds an extra layer at the top above courses allowing you to switch between sites.
        $sites = ( isset($_REQUEST['sites']) && is_array($_REQUEST['sites']) ) ? $_REQUEST['sites'] : array();
	$hasSites = count($sites) > 0;

	$courses = get_courses();
	$coursesbyid = array();
	foreach($courses as $course) {
		$id = $course->id;
		$coursesbyid[ $id ] = $course;
	 	$hasCourses = true;
	}

        // Get a list of controllers which the user is permitted to authorise objects on
        $controllers = array();
        $recs = sloodle_get_records('sloodle', 'type', SLOODLE_TYPE_CTRL);
        // Make sure we have at least one controller
        if ($recs == false || count($recs) == 0) {
        //    error(get_string('objectauthnocontrollers','sloodle'));
         //   exit();
        }

        foreach ($recs as $r) {
            // Fetch the course module
            $cm = get_coursemodule_from_instance('sloodle', $r->id);
	    $hasControllers = true;
            // Check that the person can authorise objects of this module
            if (has_capability('mod/sloodle:objectauth', get_context_instance(CONTEXT_MODULE, $cm->id))) {
                // Store this controller
                $controllers[$cm->course][$cm->id] = $r;
		$hasControllersWithPermission = true;
            }
        }

	$courselayouts = array();

	//$object_configs = SloodleObjectConfig::AllAvailableAsArrayByGroup();
	$object_configs = SloodleObjectConfig::AllAvailableAsArray();
	$objectconfigsbygroup  = SloodleObjectConfig::AllAvailableAsArrayByGroup();
	if (!isset($objectconfigsbygroup['misc'])) {
		$objectconfigsbygroup['misc'] = array(); // always make sure we have this group so that we can add misc objects added to the rezzer.
	}
//	include('object_configs.array.php');

        // Construct the list of course names
        $coursenames = array();
	$layoutentries = array();
        foreach ($controllers as $cid => $ctrls) {

		$sloodle_course = new SloodleCourse();
		if (!$sloodle_course->load($cid)) {
			continue;
		}
		$moodle_course = $sloodle_course->get_course_object();
		$coursenames[$cid] = $moodle_course->fullname;
		$courselayouts[$cid] = array();

		foreach($ctrls as $contid => $ctrl) {
			$sloodle_course->ensure_at_least_one_layout('Scene ', $contid);
			$layouts = $sloodle_course->get_layouts($contid);
			$courselayouts[$cid][$contid] = array();
			foreach($layouts as $l) {
				$entries = $sloodle_course->get_layout_entries_for_layout_id($l->id);
				$entriesbygroup = array('communication'=>array(), 'activity'=>array(), 'registration'=>array(), 'misc'=>array() );
				foreach($entries as $e) {
					$objectname = $e->name;
					$grp = 'misc';
					if (isset($object_configs[$objectname])) {
						$grp = $object_configs[$objectname]->group;
					}
					if (!isset($entriesbygroup[ $grp ] )) {
						$entriesbygroup[ $grp ] = array();
					}
					$entriesbygroup[ $grp ][] = $e;	
				}
				$layoutentries[$l->id] = $entriesbygroup;
				$courselayouts[$cid][$contid][] = $l;
			}
		}

        }


	$full = false; 

	print_html_top();
	print_toolbar( $baseurl, $sitesURL );

	print_site_placeholder( $sitesURL );
	/*
	if ($hasSites) {
		print_site_list( $sites );
	}
	*/

	print_controller_list( $courses, $controllers, $hasSites = false, $sitesURL, $hasCourses, $hasControllers, $hasControllersWithPermission); 

	print_layout_list( $courses, $controllers, $courselayouts );


	print_add_layout_forms( $courses, $controllers, $object_uuid );

	print_layout_lists( $courses, $controllers, $courselayouts, $layoutentries, $object_uuid);

	print_layout_add_object_groups( $courses, $controllers, $courselayouts, $objectconfigsbygroup );


	print_add_object_forms($courses, $controllers, $courselayouts, $object_configs, $object_uuid); 
	print_edit_object_forms($courses, $controllers, $courselayouts, $object_configs, $layoutentries, $object_uuid); 

	print_html_bottom();

exit;
?>

<?php
    /**
    * Sloodle core script.
    *
    * Sets up the basic Sloodle information, and includes the necessary Moodle data/functionality.
    *
    * @package sloodle
    *
    */

    /*
    Linker scripts don't maintain cookies.
    We need to set NO_MOODLE_COOKIES to prevent Moodle from creating a new session on every request.
    */
    if (defined('SLOODLE_LINKER_SCRIPT')) {
        define('NO_MOODLE_COOKIES', true);
    }

    // Pull in the main moodle config
    // NB the following is necessary for when we pull in this config.php from a module under sloodle/mod
    require_once (realpath(dirname(__FILE__) . "/" . "../../config.php"));

    require_once (realpath(dirname(__FILE__) . "/" . "lib/db.php"));
    
    // Is this a linker script?
    if (defined('SLOODLE_LINKER_SCRIPT')) {
        // If the site is in maintenance mode, then stop the script
        if (file_exists($CFG->dataroot.'/'.SITEID.'/maintenance.html')) {
            exit("-111|SYSTEM\nThe Moodle site is in maintenance mode. Please try again later.");
        }
        
        // Use Unicode UTF-8 encoding to support non-English alphabets
        if (!headers_sent()) header('Content-Type: text/plain; charset=UTF-8');
    }
    
    
//---------------------------------------------------------------------    
    
    /** The path for browsing to the root of the Sloodle folder. */
    define('SLOODLE_WWWROOT', $CFG->wwwroot.'/mod/sloodle');
    /** The data path for the root of the Sloodle folder. */
    define('SLOODLE_DIRROOT', $CFG->dirroot.'/mod/sloodle');
    /** The data path for the root of the Sloodle library folder. */
    define('SLOODLE_LIBROOT', $CFG->dirroot.'/mod/sloodle/lib');
    
    /** The Sloodle version number. */
    define('SLOODLE_VERSION', 2.0); // This is the release version, not the module version (which is in version.php)

    // The following tells us whether Moodle is at > version 2  or not. 
    define('SLOODLE_IS_ENVIRONMENT_MOODLE_2', ($CFG->version >= 2010060800) );

    
//---------------------------------------------------------------------

    /** The name of the HTTP parameter which can be used to activate Sloodle debug mode. */
    define('SLOODLE_DEBUG_MODE_PARAM_NAME', 'sloodledebug');

    // Check if debug mode is active
    $sloodle_debug = 'false';
    if (isset($_REQUEST[SLOODLE_DEBUG_MODE_PARAM_NAME])) $sloodle_debug = $_REQUEST[SLOODLE_DEBUG_MODE_PARAM_NAME];
    if (strcasecmp($sloodle_debug, 'true') == 0 || $sloodle_debug == '1') {
        define('SLOODLE_DEBUG', true);
    } else {
        define('SLOODLE_DEBUG', false);
    }

    
    // Apply the effects of debug mode
    if (SLOODLE_DEBUG) {
        // Report all errors and warnings
        @ini_set('display_errors', '1');
        // Since we're in basic UTF8 text mode, disable the HTML in error codes
        @ini_set('html_errors', '0');
        //@error_reporting(2047);
    } else {
        // Debug mode is NOT active. Are we in a linker script?
        if (defined('SLOODLE_LINKER_SCRIPT') && SLOODLE_LINKER_SCRIPT == true) {
            // Yes - suppress the display of messages
            @ini_set('display_errors', '0');
        }
    }
    
            @ini_set('display_errors', '0');
    /**
    * Outputs messages if in debug mode.
    * @uses SLOODLE_DEBUG
    * @param string $msg The debug message to output
    * @return void
    */
    function sloodle_debug($msg)
    {
         if (SLOODLE_DEBUG) echo $msg;
    }
    
//---------------------------------------------------------------------
    // Types of Sloodle module
    // These correspond to the "type" field in the "Sloodle" DB table
    // Each name should be lower-case letters only (max 50)
    // The full name should be specified in the appropriate language file, as "moduletype:type".
    
    // Each course needs to have at least one Sloodle Access Controller before it can be accessed from in-world.
    // This is what grants access to the course as a whole, and sets prim passwords.
    define('SLOODLE_TYPE_CTRL', 'controller');
                                   
    // These are the regular module types
    define('SLOODLE_TYPE_DISTRIB', 'distributor');
    define('SLOODLE_TYPE_PRESENTER', 'presenter');
    define('SLOODLE_TYPE_MAP', 'map');
    define('SLOODLE_TYPE_TRACKER', 'tracker');
    
    // Store the types in an array (used in lists)
    global $SLOODLE_TYPES;   
    $SLOODLE_TYPES = array();
      
    $SLOODLE_TYPES[] = SLOODLE_TYPE_CTRL;
    $SLOODLE_TYPES[] = SLOODLE_TYPE_DISTRIB;
    $SLOODLE_TYPES[] = SLOODLE_TYPE_PRESENTER;
    $SLOODLE_TYPES[] = SLOODLE_TYPE_TRACKER;
    
    
    
//---------------------------------------------------------------------

    // Access level constants
    
    /** Indicates that anybody may access an object in-world. */
    define('SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC', 0);
    /** Indicates that only the owner may access an object in-world. */
    define('SLOODLE_OBJECT_ACCESS_LEVEL_OWNER', 1);
    /** Indicates that only in-world group-members may access an object in-world. */
    define('SLOODLE_OBJECT_ACCESS_LEVEL_GROUP', 2);
    
    /** Indicates that anybody may access a server resource (still requires an authenticated request). */
    define('SLOODLE_SERVER_ACCESS_LEVEL_PUBLIC', 0);
    /** Indicates that only those registered and enrolled in a specific course may access a server resource. */
    define('SLOODLE_SERVER_ACCESS_LEVEL_COURSE', 1);
    /** Indicates that only those registered on the site may access a server resource. */
    define('SLOODLE_SERVER_ACCESS_LEVEL_SITE', 2);
    /** Indicates that only those with Sloodle staff status on a course may access a server resource. */
    define('SLOODLE_SERVER_ACCESS_LEVEL_STAFF', 3);    
    

//---------------------------------------------------------------------

    // Debugging / development constants 

    /** The following will turn on logging of requests coming from LSL and responses going back */
    /*   
        On a production server, this should usually be off ('') unless you're trying to trouble-shoot something.
        If you do use it, your web server user (usually apache or www-data) will need to be able to write to this file.
        It will contain all data sent to and from the server by LSL scripts, including sensitive data like prim passwords
        ...so if you turn this on, be careful about who has access to the file it creates.
    */
    define('SLOODLE_DEBUG_REQUEST_LOG', '');

    /** The following tells objects that we want them to persist their config over resets, and copy it to new objects that are copied.
    * The object will try to use the persistent config if if doesn't get a start_param from the rezzer.
    * This should usually be on, but if you're developing a set to share with other people, it's better to turn it off
    * That way the objects you rez won't try to use your server if the start_param somehow fails, which seems to happen sometimes.
    * 
    */
    define('SLOODLE_ENABLE_OBJECT_PERSISTANCE', true);

//---------------------------------------------------------------------
   
    // Login and top-level navigation customization
    /** 
    * By default, the shared-media version of the set (and potentially other tools) will use the regular Moodle pages to login or logout the user.
    * This isn't ideal UI-wise, because those screens are designed to be displayed in a browser, not on a shared-media prim.
    * By setting an include here, you can supply your own login screen code.
    * This was designed for Avatar Classroom, where we want to redirect you to our shared login screen at avatarclassroom.com
    * ...but it may also be useful if you want to make a shared-media-specific login screen
    * ...or you have an unusual login flow that requires customization.
    */
    //define('SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE', SLOODLE_DIRROOT.'/mod/set-1.0/shared_media/login.avatarclassroom.php');
    //define('SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE', SLOODLE_DIRROOT.'/mod/set-1.0/shared_media/logout.avatarclassroom.php');

    // Site list customization
    /**
    * This allows you to have a back button on the shared media screen to take you one level above the course/controller list.
    * Used in Avatar Classroom to provide a list of your hosted Moodle sites so that you can switch between them or create a new one.
    * Probably not useful to anyone else.
    */
    //define('SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL', 'http://api.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/');

    /*
    * Set this to true if you want the rezzer to automatically link its owner to the person logged in and using it in Moodle.
    * This is used by Avatar Classroom. Will normally be off for regular sloodle.
    */
    define('SLOODLE_SHARED_MEDIA_AUTOLINK_REZZER_OWNER', false);

     /*
     This can be defined to cause the rezzer screen to fetch the initial object config from another site.
     It is used in Avatar Classroom to allow the initial setup to be done via the avatar classroom site, before we know which site they want to connect to.
     The UUID of the object will be appended to this URL, and the service will be expected to return a JSON representation of the active object.
     See mod/set-1.0/shared_media/index.php to see how this is used.
     */
     //define('SLOODLE_SHARED_MEDIA_REZZER_CONFIG_WEB_SERVICE', '');


//---------------------------------------------------------------------

    /** General functionality. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    /** Sloodle core library functionality */
    require_once(SLOODLE_DIRROOT.'/lib.php');
    /** Request and response functionality. */
    require_once(SLOODLE_LIBROOT.'/io.php');
    /** User functionality. */
    require_once(SLOODLE_LIBROOT.'/user.php');
    /** Course functionality. */
    require_once(SLOODLE_LIBROOT.'/course.php');
    /** Sloodle Controller functionality. */
    require_once(SLOODLE_LIBROOT.'/controller.php');
    /** Module functionality. */
    require_once(SLOODLE_LIBROOT.'/modules.php');
    /** Plugin management. */
    require_once(SLOODLE_LIBROOT.'/plugins.php');
    /** Active Objects config definitions. */
    require_once(SLOODLE_LIBROOT.'/object_configs.php');
    /** Active Objects and their definitions. */
    require_once(SLOODLE_LIBROOT.'/active_object.php');


?>

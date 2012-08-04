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
    define('SLOODLE_VERSION', 2.1); // This is the release version, not the module version (which is in version.php)

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

    /*
    Customizable parameters follow.
    Normally these will be defined in an optional 'sloodle_config.php' file.
    For ease of upgrading, the sloodle_config.php will not be included in the release, although we will provide a sample.
    */

    if ( file_exists(SLOODLE_DIRROOT.'/sloodle_config.php') ) {
        require_once(SLOODLE_DIRROOT.'/sloodle_config.php');
    }

    /*
    Constants that need to have a default parameter for people with no config.php should set it below this line
    ... conditional on it being undefined.
    */

    /** 
    The collections of objects the rezzer supports. 
    This corresponds to the collections parameter in the object definition of each object.
    NB The array should be serialized because PHP won't do arrays as constants.
    */
    if ( !defined('SLOODLE_SUPPORTED_OBJECT_COLLECTIONS') ) {
        define('SLOODLE_SUPPORTED_OBJECT_COLLECTIONS', serialize(array('SLOODLE 2.0') ) ); //
    }

    /*
    How often objects should be told to ping us to let us know they're alive.
    NB The initial ping from an object will be at a random proportion of this number
    ...to provide some jitter and prevent the server being hammered by all the scripts at the same time.
    */
    if ( !defined('SLOODLE_PING_INTERVAL') ) {
        define('SLOODLE_PING_INTERVAL', 3600);
    }

    /*
    How often the rezzer should poll to check which objects may be rezzed
    ...and provide a report of which, in any, are missing.
    Since there is usually only one rezzer, you should be able to make this happen fairly fast without worrying about killing your server.
    If you aren't worried about server resources, it would be meaningful to bring it down as low as 3 seconds.
    */
    if ( !defined('SLOODLE_REZZER_STATUS_CONFIRM_INTERVAL')) {
        define('SLOODLE_REZZER_STATUS_CONFIRM_INTERVAL', 15);
    }

    // This activates freemail blogging.
    // This is off by default in sloodle 2.1, as we haven't tested it properly yet.
    // We will probably turn it on in 2.2.
    // NB it will only work on Moodle 2.0 or higher.
    if ( !defined('SLOODLE_FREEMAIL_ACTIVATE')) {
        define('SLOODLE_FREEMAIL_ACTIVATE', false);
    }

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

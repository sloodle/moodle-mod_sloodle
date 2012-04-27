<?php
    /**
    * Sloodle configuration settings
    *
    * This file is for settings that can be configured on a site-by-site basis.
    * It needs to be renamed as config.php to be used.
    * For a normal sloodle installation you shouldn't have to bother with this.
    *
    * @package sloodle
    *
    */

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
     define('SLOODLE_SHARED_MEDIA_REZZER_CONFIG_WEB_SERVICE', '');

    /*
    The collections of objects the rezzer supports.
    This corresponds to the collections parameter in the object definition of each object.
    NB The array should be serialized because PHP won't do arrays as constants.
    */
    define('SLOODLE_SUPPORTED_OBJECT_COLLECTIONS', serialize(array('SLOODLE 2.0') ) ); //


//---------------------------------------------------------------------

?>

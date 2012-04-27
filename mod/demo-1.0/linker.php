<?php
    /**
    * Sloodle demo linker (for Sloodle 0.4).
    * Allows a demo object to link to Moodle.
    *
    * @package sloodle
    * @copyright Copyright (c) 2009 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
    
    // Common parameters for linker scripts
    //  sloodlecontrollerid = ID of a Sloodle Controller through which to access Moodle
    //  sloodlepwd = the prim password or object-specific session key to authenticate the request
    //  sloodlemoduleid = ID of a module to load (corresponds to a course module instance ID, i.e. the 'id' field of the 'course_modules' db table).
    //  sloodleuuid = UUID of the avatar
    //  sloodleavname = name of the avatar
    //
    // Less common parameters:
    //  sloodleserveraccesslevel = how strict should access be? Handled entirely by the SloodleSession object
    //
    //
    // The following parameter is optional:
    //  sloodledebug = if 'true', then Sloodle debugging mode is activated -- should only be used from a web-browser as it outputs lots of extra info
    

    /** Lets Sloodle know we are in a linker script. */
    define('SLOODLE_LINKER_SCRIPT', true);
    
    /** Grab the Sloodle/Moodle configuration. */
    require_once('../../init.php');
    /** Include the Sloodle PHP API. */
    require_once(SLOODLE_LIBROOT.'/sloodle_session.php');
    
///// SETTING UP THE SESSION //////
    
    // Construct a SloodleSession to handle this request.
    // This provides a framework to handle all the common SLOODLE-related things.
    // By default, this immediately processes important incoming data, but you can suppress that with optional parameters. (See API documentation.)
    $sloodle = new SloodleSession();
    
    // Check that the object is allowed to access Moodle.
    // This checks that a SLOODLE Controller has been identified, and that a password has been given too.
    // If it fails, it will normally terminate the script with an error, but you can suppress that using optional parameters.
    $sloodle->authenticate_request();
    
    // At this stage, you are guaranteed that the request is secure... or at least as secure as we can make it. :-)
    
    // Note:
    // There are two types of authentication - prim password, and object-specific password.
    // In both cases, a SLOODLE Controller must be identified in the "sloodlecontrollerid" HTTP parameter, and the password in the "sloodlepwd" HTTP parameter.
    // A prim-password is just a 5 to 9 digit number, and it is the same for any object using the Controller.
    // An object-specific password is a 9-digit number PLUS the object's UUID, and it is unique for every object.
    
    // * See the SLOODLE PHP API documentation for more information about the "SloodleSession" class *
    
    
///// HANDLING THE USER /////

    // Many requests either deal with or are originated by a particular avatar.
    // For example, the WebIntercom needs to know who is chatting a message.
    // This information is passed-in using two parameters: sloodleavname, sloodleuuid.
    // It is good practice to provide both in your script, but just one will usually suffice (unless you want to auto-register a new avatar).
    
    // You can use the following method to check that an avatar has been specified.
    // This will also check to see if they are registered in Moodle, and enrolled on the course.
    // If it fails, it will normally terminate the script with an error, but you can suppress that using optional parameters.
    // Note that this function will auto-register and/or auto-enrol avatars if necessary and if the Moodle site/course allow it.
    // An important side-effect of this function is that it forces Moodle to think the registered Moodle user is actually logged-in for the duration of this script.
    $sloodle->validate_user();
    
    // At this stage, you are guaranteed to have a valid avatar AND Moodle user.
    // You can now access the user information like this: $sloodle->user->...
    // For example, let's get the names of the avatar and Moodle user.
    $avatarname = $sloodle->user->get_avatar_name();
    $moodlename = $sloodle->user->get_user_firstname() .' '. $sloodle->user->get_user_lastname();
    
    // * See the SLOODLE PHP API documentation for more information about the SloodleUser class. *
    // SloodleUser is defined in: sloodle/lib/user.php
    
    
///// LOADING MODULES /////
    
    // In order to improve portability and code-reusability, a modules system was created.
    // It is not essential, but can help keep linker scripts clean and free of Moodle-specific database code.
    // The SloodleModule base class provides a common base for any SLOODLE code which 'wraps' a Moodle module.
    // For example, the SloodleModuleChat class provides simple functions to handle a Moodle chatroom.
    // Similarly, the SloodleModuleBlog class provides simple functions to handle the Moodle blog.
    
    // Note that these will NOT necessarily correspond to actual Moodle modules (although they usually do).

    // The following method can be used to load a module wrapper for a chatroom.
    // The first argument names the module, and the second indicates whether or not there is database data to be loaded.
    // Note that this will load the module identified by HTTP parameter 'sloodlemoduleid'.
    // If that parameter is not provided in the request, then this method will terminate the script with an error message.
    // If the module loading fails (e.g. due to a database error) then the script will also be terminated, although that behaviour can be suppressed by addition optional arguments.
    $sloodle->load_module('chat', true);
    
    // You can now access the module like this: $sloodle->module->...
    // There are some common functions, such as getting the name of the module, and various functions specific to the module class that was loaded.
    $modulename = $sloodle->module->get_name();
    $chatmessages = $sloodle->module->get_chat_history();
    
    
    // * See the SLOODLE PHP API documentation for more information about the "SloodleModule" class *
    
    // SloodleModule is defined in: sloodle/lib/modules/module_base.php
    // The sub-classes are defined in: sloodle/lib/modules
    // The module loading code is define in: sloodle/lib/modules.php
    
    
    
///// GETTING INPUT /////

    // You will often want to pass data from SL to Moodle as HTTP parameters. This can be done using GET or POST parameters.
    // You can fetch either type of data easily using the "SloodleRequest" object within the SloodleSession.
    // You access it using: $sloodle->request->...
    
    // If there is a parameter called 'message' that you absolutely MUST receive for the script to work properly, you can fetch it like this:
    $requiredmessage = $sloodle->request->required_param('message');
    
    // If the parameter was not given in the HTTP request, then the script is immediately terminate with an error message.
    // The argument gives the name of the parameter to fetch.
    // If the parameter was specified, then it is returned as a raw string (you MUST do proper data cleanup before putting it into a database query, otherwise you'll be vulnerable to SQL injections).
    
    
    
    // If a particular parameter is optional (i.e. you may or may not receive it), then you can use the following method:
    $optionalmessage = $sloodle->request->optional_param('anothermessage', '');
    
    // The first argument gave the name of the paramter.
    // The second argument gave the default value that would be returned if that parameter was not passed to this script.
    // If the parameter *was* provided for this script, then the raw string value is returned.
    
    
    // * See the SLOODLE PHP API documentation for more information about the "SloodleRequest" class *
    // SloodleRequest is defined in: sloodle/lib/io.php
    
    
///// RETURNING A RESPONSE /////

    // After you have done some processing, you have to provide a response.
    // There is information in the developer documentation on the SLOODLE wiki about the appropriate communications specification.
    // Note that *anything* you output, e.g. using "echo" or "print" becomes part of the response.
    // The SloodleResponse object within SloodleSession provides some assistance.
    // You can access the response object like this: $sloodle->response->...
    
    // You must always provide a status code (see the wiki for a list of these):
    // http://slisweb.sjsu.edu/sl/index.php/Sloodle_status_codes
    // If you need to create your own status codes, pick a range of unused numbers. 
    // Document the status codes on the wiki before you start using them in your script.
    $sloodle->response->set_status_code(1); // Positive means OK, negative means an error
    
    // You must also provide a simple, generic, status 'descriptor' (a short human-readable string):
    $sloodle->response->set_status_descriptor('OK');
    
    // You can optionally add data, line by line. Each line can have several fields, usually separated by | characters.
    // There are several ways to add the data.
    $sloodle->response->add_data_line("Avatar name is: {$avatarname}"); // Just add a string on each line
    $sloodle->response->add_data_line(array('Moodle name', $moodlename)); // Add several fields on a single line
    $sloodle->response->add_data_line(array('module', 'name', $modulename));
    
    // Just some more usage of input data
    $sloodle->response->add_data_line("Required message: {$requiredmessage}");
    if (empty($optionalmessage)) $sloodle->response->add_data_line("No optional message provided");
    else $sloodle->response->add_data_line("Optional message: {$optionalmessage}");

    
    // Finally, you MUST remember to render the response!
    $sloodle->response->render_to_output();
    
    // Alternatively, you can render the output to a string, like this:
    $output = '';
    //$sloodle->response->render_to_output($output); // Passed in by reference
    // You can then output that string yourself, or send it by XMLRPC or similar.
    // NOTE: for XMLRPC into SL, you need to replace newlines (\n) with \\n before sending.
    
    
    // * See the SLOODLE PHP API documentation for more information about the "SloodleResponse" class *
    // SloodleResponse is defined in: sloodle/lib/io.php
    
    
?>

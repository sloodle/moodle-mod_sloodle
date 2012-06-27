//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Set manager script (for Sloodle 0.3).
// Performs the overall management of a Sloodle Set's configuration.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield


///// DATA /////
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_OBJECT_CREATOR_TYPE_BASIC_SET = 0;
integer SLOODLE_OBJECT_CREATOR_TYPE_MOTHERSHIP = 1;

integer SLOODLE_THIS_OBJECT_TYPE = 0;


integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_SET_LINKER = "/mod/sloodle/mod/set-1.0/linker.php";
string SLOODLE_COURSEINFO_LINKER = "/mod/sloodle/classroom/course_info_linker.php";
string SLOODLE_EOF = "sloodleeof";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string SLOODLE_OBJECT_TYPE = "set-1.0";

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0; 
string sloodlecoursename_full = "";
integer sloodleobjectaccessleveluse = 0; 

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httpcheckcourse = NULL_KEY;
list cmddialog = []; // Alternating list of keys and timestamps, indicating who activated a dialog, and when

string MENU_BUTTON_RESET = "0";
string MENU_BUTTON_OPEN_REZ_DIALOG = "1"; // The same as touching the cargo bay
string MENU_BUTTON_OPEN_LAYOUT_DIALOG = "2"; // The same as touching the layout button
string MENU_BUTTON_KILL_ALL = "3"; // The same as touching the kill button

integer TEX_SIDE = 2; // The side to apply our texture to for "ready" or otherwise

///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

integer SLOODLE_CHANNEL_SET_CONFIGURED = -1639270091;
integer SLOODLE_CHANNEL_SET_RESET = -1639270092; 

integer SLOODLE_CHANNEL_SET_MENU_BUTTON_OPEN_REZ_DIALOG = -1639270093;
integer SLOODLE_CHANNEL_SET_MENU_BUTTON_OPEN_LAYOUT_DIALOG = -1639270094;
integer SLOODLE_CHANNEL_SET_MENU_BUTTON_KILL_ALL = -1639270095;

// Translation output methods
string SLOODLE_TRANSLATE_LINK = "link";             // No output parameters - simply returns the translation on SLOODLE_TRANSLATION_RESPONSE link message channel
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_WHISPER = "whisper";       // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SHOUT = "shout";           // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_REGION_SAY = "regionsay";  // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";  // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

///// ----------- /////


///// FUNCTIONS /////
/******************************************************************************************************************************
* sloodle_error_code - 
* Author: Paul Preibisch
* Description - This function sends a linked message on the SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST channel
* The error_messages script hears this, translates the status code and sends an instant message to the avuuid
* Params: method - SLOODLE_TRANSLATE_SAY, SLOODLE_TRANSLATE_IM etc
* Params:  avuuid - this is the avatar UUID to that an instant message with the translated error code will be sent to
* Params: status code - the status code of the error as on our wiki: http://slisweb.sjsu.edu/sl/index.php/Sloodle_status_codes
*******************************************************************************************************************************/
sloodle_error_code(string method, key avuuid,integer statuscode){
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|"+(string)statuscode, NULL_KEY);
}

// Send debug info
sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}

// Reset the whole object
sloodle_reset()
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reset", NULL_KEY);
    llResetScript();
}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
    sloodle_debug("Handling command: " + str);
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);
    string value1 = "";
    string value2 = "";
    
    if (numbits > 1) value1 = llList2String(bits,1);
    if (numbits > 2) value2 = llList2String(bits,2);
    
    if (name == "set:sloodleserverroot") sloodleserverroot = value1;
    if (name == "set:sloodlecoursename_full") sloodlecoursename_full = value1;
    else if (name == "set:sloodlepwd") {
        // The password may be a single prim password, or a UUID and a password
        if (value2 != "") sloodlepwd = value1 + "|" + value2;
        else sloodlepwd = value1;
        
    } else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
    else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0);
}

// Checks if the given agent is permitted to control this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_ctrl(key id)
{
    // Only the owner can control this
    return (id == llGetOwner());
}

// Checks if the given agent is permitted to user this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_use(key id)
{
    // The owner can always use this
    if (id == llGetOwner()) return TRUE;
    
    // Check the access mode
    if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_GROUP) {
        return llSameGroup(id);
    } else if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC) {
        return TRUE;
    }
    return FALSE;
}

// Show a command dialog to the specified user
sloodle_show_command_dialog(key id)
{
    if (SLOODLE_THIS_OBJECT_TYPE == SLOODLE_OBJECT_CREATOR_TYPE_BASIC_SET) {
                sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG, MENU_BUTTON_RESET, MENU_BUTTON_OPEN_REZ_DIALOG], "sloodleset:cmddialog_simple", [MENU_BUTTON_RESET, MENU_BUTTON_OPEN_REZ_DIALOG], id, "set");
    } else {
        sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG, MENU_BUTTON_RESET, MENU_BUTTON_OPEN_REZ_DIALOG , MENU_BUTTON_OPEN_LAYOUT_DIALOG , MENU_BUTTON_KILL_ALL ], "sloodleset:cmddialog_mothership", [MENU_BUTTON_RESET, MENU_BUTTON_OPEN_REZ_DIALOG , MENU_BUTTON_OPEN_LAYOUT_DIALOG , MENU_BUTTON_KILL_ALL], id, "set");
    }
}

// Add the given agent to our command dialog list
sloodle_add_cmd_dialog(key id)
{
    // Does the person already exist?
    integer pos = llListFindList(cmddialog, [id]);
    if (pos < 0) {
        // No - add the agent to the end
        cmddialog += [id, llGetUnixTime()];
    } else {
        // Yes - update the time
        cmddialog = llListReplaceList(cmddialog, [llGetUnixTime()], pos + 1, pos + 1);
    }
}

// Remove the given agent from our command dialog list
sloodle_remove_cmd_dialog(key id)
{
    // Is the person in the list?
    integer pos = llListFindList(cmddialog, [id]);
    if (pos >= 0) {
        // Yes - remove them and their timestamp
        cmddialog = llDeleteSubList(cmddialog, pos, pos + 1);
    }
}

// Purge the command dialog list of old activity
sloodle_purge_cmd_dialog()
{
    // Store the current timestamp
    integer curtime = llGetUnixTime();
    // Go through each command dialog
    integer i = 0;
    while (i < llGetListLength(cmddialog)) {
        // Is the current timestamp more than 12 seconds old?
        if ((curtime - llList2Integer(cmddialog, i + 1)) > 12) {
            // Yes - remove it
            cmddialog = llDeleteSubList(cmddialog, i, i + 1);
        } else {
            // No - advance to the next
            i += 2;
        }
    }
}


default
{
    state_entry()
    {
        // Starting again with a new configuration
       // llSetTexture("touch_to_set_moodle", TEX_SIDE);
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_RESET, "", NULL_KEY);
        llSetText("", <0.0,0.0,0.0>, 0.0);
        isconfigured = FALSE;
        eof = FALSE;
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        sloodlecoursename_full = "";
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                    if (sloodlecoursename_full == "") state check_course;
                    else state ready;
                } else {
                    // No more data, but we're not configured yet...
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], NULL_KEY, "");
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);
                    eof = FALSE;
                }
            }
        }  
    }
    
    touch_start(integer num_detected)
    {
        // Attempt to request a reconfiguration
        if (llDetectedKey(0) == llGetOwner()) {
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
        }
    }
    
    on_rez(integer par)
    {
        llResetScript();
    }
}


// This state will check which course we are connecting to (only necessary for notecard setups)
state check_course
{
    state_entry()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 1.0], "checkingcourse", [], NULL_KEY, "");
        // Send our course check request
        httpcheckcourse = llHTTPRequest(sloodleserverroot + SLOODLE_COURSEINFO_LINKER + "?sloodlecontrollerid=" + (string)sloodlecontrollerid + "&sloodlepwd=" + sloodlepwd, [HTTP_METHOD, "GET"], "");
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the data we expect
        if (id != httpcheckcourse) return;
        httpcheckcourse = NULL_KEY;
        
        // Check that we got a proper response
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httperror:code", [status], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 1.0], "errortouchtoreset", [], NULL_KEY, "");
            return;
        }
        if (body == "") {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httpempty", [], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 1.0], "errortouchtoreset", [], NULL_KEY, "");
            return;
        }
        
        // Split the response at each line, then at each field
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        
        // Make sure there were enough lines
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 1.0], "errortouchtoreset", [], NULL_KEY, "");
            return;
        }
        
        // The first item should be the status code
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = llList2Integer(statusfields, 0);
        
        // The status could should be positive if successful
        if (statuscode == -106) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "sloodlenotinstalled", [], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 1.0], "errortouchtoreset", [], NULL_KEY, "");
            return;
        } else if (statuscode <= 0) {
            // Get the error message if one was given
            if (llGetListLength(lines) > 1) {
                string errmsg = llList2String(lines, 1);
                sloodle_debug("ERROR " + (string)statuscode + ": " + errmsg);
            }
            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 1.0], "errortouchtoreset", [], NULL_KEY, "");
            return;
        }
        
        // Everything seems fine - extract the data
        list coursenames = llParseStringKeepNulls(llList2String(lines, 1), ["|"], []);
        if (llGetListLength(coursenames) > 1) sloodlecoursename_full = llList2String(coursenames, 1);
        else sloodlecoursename_full = "???";
        
        state ready;
    }
    
    on_rez(integer param)
    {
        state default;
    }
}


// The Set has been configured
state ready
{
    state_entry()
    {
        // Display the site and course info in the hover text
       // llSetTexture("sloodle_ready", TEX_SIDE);
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_CONFIGURED, "", NULL_KEY);
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 1.0], "readyconnectedto:sitecourse", [sloodleserverroot, sloodlecoursename_full], NULL_KEY, "");
        // Run a regular timer to cancel expired dialogs
        llSetTimerEvent(12.0);
        // Listen for dialog input
        llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", NULL_KEY, "");
    }
    
    touch_start(integer num_detected)
    {
        // Go through each toucher
        integer i = 0;
        key id = NULL_KEY;
        for (; i < num_detected; i++) {
            id = llDetectedKey(i);
            // Check the use access level here
            if (sloodle_check_access_use(id)) {
                // Show the command dialog to the user
                sloodle_show_command_dialog(id);
                sloodle_add_cmd_dialog(id);
            } else {
                // Inform the user that they do not have permission
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(id)], NULL_KEY, "");
            }
        }
    }
    
    listen(integer channel, string name, key id, string msg)
    {
        // Check the channel
        if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG) {
            // Make sure we are actually listening to this user
            if (llListFindList(cmddialog, [id]) < 0) return;
            // Check the use access level here
            if (!sloodle_check_access_use(id)) return;
            // The user no longer needs the dialog
            sloodle_remove_cmd_dialog(id);
            
            // Check the command
            if (msg == MENU_BUTTON_RESET) {
                // Reset the object
                sloodle_reset();
                return;
            } else if (msg == MENU_BUTTON_OPEN_REZ_DIALOG) {
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_MENU_BUTTON_OPEN_REZ_DIALOG , "", id);
                return;
            } else if (msg == MENU_BUTTON_OPEN_LAYOUT_DIALOG) {
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_MENU_BUTTON_OPEN_LAYOUT_DIALOG , "", id);                
                return;                
            } else if (msg == MENU_BUTTON_KILL_ALL) {
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_MENU_BUTTON_KILL_ALL , "", id);        
                return;                
            }
        }
    }
    
    timer()
    {
        sloodle_purge_cmd_dialog();
    }
    
    on_rez(integer param)
    {
        state default;
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_mod_set-1.0.lslp 

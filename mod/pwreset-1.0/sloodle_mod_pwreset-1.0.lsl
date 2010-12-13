// Sloodle Password Reset object
// Allows avatar with auto-registered Moodle accounts to reset their Moodle password from in-world.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2008 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Peter R. Bloomfield
//

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_PWRESET_LINKER = "/mod/sloodle/mod/pwreset-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";

string SLOODLE_OBJECT_TYPE = "pwreset-1.0";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = "";
string sloodlecoursename_full = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

list avatars = []; // A list of avatars with pending requests
list httprequests = []; // A list of http request keys, corresponding to the "avatars" list


///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

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
sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
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
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0);
}

// Checks if the given agent is permitted to control this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_ctrl(key id)
{
    // Check the access mode
    if (sloodleobjectaccesslevelctrl == SLOODLE_OBJECT_ACCESS_LEVEL_GROUP) {
        return llSameGroup(id);
    } else if (sloodleobjectaccesslevelctrl == SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC) {
        return TRUE;
    }
    
    // Assume it's owner mode
    return (id == llGetOwner());
}

// Checks if the given agent is permitted to user this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_use(key id)
{
    // Check the access mode
    if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_GROUP) {
        return llSameGroup(id);
    } else if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC) {
        return TRUE;
    }
    
    // Assume it's owner mode
    return (id == llGetOwner());
}

// Initiate a password reset
sloodle_password_reset(key av)
{
    // Start the request
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodleuuid=" + (string)av;
    body += "&sloodleavname=" + llEscapeURL(llKey2Name(av));
    body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
    key newhttp = llHTTPRequest(sloodleserverroot + SLOODLE_PWRESET_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);

    // Is the avatar already in the list?
    integer pos = llListFindList(avatars, [av]);
    if (pos >= 0) {
        // Yes - replace the entry
        httprequests = llListReplaceList(httprequests, [newhttp], pos, pos);
    } else {
        // No - add a new entry
        avatars += [av];
        httprequests += [newhttp];
    }
}

// Remove an avatar from the lists
sloodle_remove_password_reset(key av)
{
    // Check for the entry in the list
    integer pos = llListFindList(avatars, [av]);
    if (pos >= 0) {
        avatars = llDeleteSubList(avatars, pos, pos);
        httprequests = llDeleteSubList(httprequests, pos, pos);
    }
}


// Default state - waiting for configuration
default
{
    state_entry()
    {
        // Starting again with a new configuration
        llSetText("", <0.0,0.0,0.0>, 0.0);
        isconfigured = FALSE;
        eof = FALSE;
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        sloodleobjectaccessleveluse = 0;
        sloodleobjectaccesslevelctrl = 0;
        sloodleserveraccesslevel = 0;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
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
                    state ready;
                } else {
                    // Got all configuration but, it's not complete... request reconfiguration
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
}

// Ready to receive requests for password resets
state ready
{
    on_rez( integer param)
    {
        state default;
    }    
    
    state_entry()
    {
        // Display status
        if (sloodleserveraccesslevel == 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.9], "pwresetready:course", [sloodleserverroot, sloodlecoursename_full], NULL_KEY, "pwreset");
        } else if (sloodleserveraccesslevel == 3) {
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.9], "pwresetready:staff", [sloodleserverroot, sloodlecoursename_full], NULL_KEY, "pwreset");
        } else {
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.9], "pwresetready:site", [sloodleserverroot], NULL_KEY, "pwreset");
        }
    }
    
    state_exit()
    {
        // Clear status tet
        llSetText("", <0.0,0.0,0.0>, 0.0);
    }
        
    touch_start( integer total_number)
    {
        // Activating this requires access permission
        if (sloodle_check_access_use(llDetectedKey(0)) == FALSE) {
            llWhisper(0, "Sorry " + llDetectedName(0) + ". You do not have permission to control this object.");
            return;
        }
        // Do the password reset
        sloodle_password_reset(llDetectedKey(0));
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Ignore any unexpected responses
        integer pos = llListFindList(httprequests, [id]);
        if (pos < 0) return;
        // Extract the data
        key av = llList2Key(avatars, pos);
        string name = llKey2Name(av);
        sloodle_remove_password_reset(av);
        
        // Check the response status
        if (status != 200) {
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            return;
        }
        
        // Check the response body
        if (body == "") {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httpempty", [], NULL_KEY, "");
            return;
        }
        
        // Parse the response
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the status code
        if (statuscode == -341) {
            // User cannot have their password reset in-world
            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "pwreseterror:hasemail", [name, sloodleserverroot], av, "pwreset");
            sloodle_debug("ERROR reported in response: " + body);
            return;
            
        } else if (statuscode == -331) {
            // User cannot use this device
            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "nopermission:use", [name], av, "");
            return;
            
        } else if (statuscode <= 0) {
            // Error occurred
            //sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "pwreseterror:failed:code", [name, statuscode], av, "pwreset");
            sloodle_error_code(SLOODLE_TRANSLATE_IM, av,statuscode); //send message to error_message.lsl
            sloodle_debug("ERROR reported in response: " + body);
            return;
        }
        
        // Check that there are enough lines
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            sloodle_debug("ERROR: not enough lines in response: " + body);
            return;
        }
        
        // Attempt to parse the data line
        list datafields = llParseStringKeepNulls(llList2String(lines, 1), ["|"], []);
        if (llGetListLength(datafields) < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            sloodle_debug("ERROR: not enough data fields in response: " + body);
            return;
        }
        
        // Extract the data items
        string username = llList2String(datafields, 0);
        string password = llList2String(datafields, 1);
        
        // Inform the user of their new password
        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "pwreset:success", [name, sloodleserverroot, username, password], av, "pwreset");
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/pwreset-1.0/sloodle_mod_pwreset-1.0.lsl 

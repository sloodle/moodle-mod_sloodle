// Sloodle user-centric configuration script.
// Allows users (e.g. students) to authorise and configure user-centric objects themselves.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2008 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield

integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
string SLOODLE_EOF = "sloodleeof";
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;

string SLOODLE_VERSION_LINKER = "/mod/sloodle/version_linker.php";
string SLOODLE_USER_AUTH_LINKER = "/mod/sloodle/login/user_object_linker.php";
string SLOODLE_USER_AUTH_INTERFACE = "/mod/sloodle/login/user_object_auth.php";
string SLOODLE_AUTH_CHECKER = "/mod/sloodle/login/check_user_auth_linker.php";

float SLOODLE_VERSION_MIN = 0.3; // Minimum required version of Sloodle

key httpcheckmoodle = NULL_KEY;
key httpauthobject = NULL_KEY;
key httpcheckauth = NULL_KEY;

string sloodleserverroot = "";
string sloodlepwd = ""; // stores the object-specific session key (UUID|pwd)

string sloodleauthurl = ""; // URL which will be used to complete the authorisation process

string password = ""; // stores the self-generated part of the password





///// TRANSLATION /////

// Link message channels
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
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter, containing the URL.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";  // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_IM = "instantmessage";             // Recipient avatar should be identified in link message keyval. No output parameters.


//functions
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

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

///// ----------- /////


sloodle_tell_other_scripts(string msg)
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, msg, NULL_KEY);   
}

sloodle_debug(string msg)
{
    llMessageLinked(LINK_SET, DEBUG_CHANNEL, msg, NULL_KEY);
}

// Generate a random password string
string sloodle_random_object_password()
{
    return (string)(10000 + (integer)llFrand(999989999)); // Gets a random integer between 10000 and 999999999
}

// Load the authorisation URL
sloodle_load_auth_url(key av)
{
    sloodle_translation_request(SLOODLE_TRANSLATE_LOAD_URL, [sloodleauthurl], "userauthurl", [], av, "");
}

// Initiate an authorisation check.
// Returns the key of the HTTP request.
key sloodle_check_user_auth()
{
    string body = "sloodleuuid=" + (string)llGetOwner();
    body += "&sloodlepwd=" + sloodlepwd;
    return llHTTPRequest(sloodleserverroot + SLOODLE_AUTH_CHECKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
}

///// STATES /////

default
{    
    state_entry()
    {
        sloodle_debug("Setup user in default state.");
        // Pause for a moment, in case all scripts were reset at the same time
        llSleep(0.2);
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodleauthurl = "";
        password = "";
    
        // Check to see if the server URL is in the object description
        string desc = llGetObjectDesc();
        if (desc != "" && llSubStringIndex(desc, "http") == 0) sloodleserverroot = desc;
        
        // Did we get a server root?
        if (sloodleserverroot == "") {
            // No - ask the owner for it
            llListen(0, "", llGetOwner(), "");
            llListen(1, "", llGetOwner(), "");
            
            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "chatserveraddress", [], llGetOwner(), "");
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.8], "waitingforserveraddress", [], NULL_KEY, "");
        } else {
            // Immediately start processing the Moodle site
            state check_moodle;
        }
    }
    
    state_exit()
    {
        llSetText("", <0.0,0.0,0.0>, 0.0);
    }
    
    listen(integer channel, string name, key id, string msg)
    {        
        // Check the channel
        if (channel == 0 || channel == 1) {
            // Ignore anybody but the owner
            if (id != llGetOwner()) return;
            // If the message starts with "http" then store it as the Moodle address
            msg = llStringTrim(msg, STRING_TRIM);
            if (llSubStringIndex(msg, "http") == 0) {
                sloodleserverroot = msg;
                state check_moodle;
                return;
            }
        }
    }
    
    touch_start(integer num_detected)
    {
        if (llDetectedKey(0) == llGetOwner()) {
            // Remind the owner of what is needed
            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "chatserveraddress", [], llGetOwner(), "");
        }
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset command?
            if (sval == "do:reset") {
                llResetScript();
                return;
            }
        }
    }
    
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            llResetScript();
    }
}

// Check that the Moodle site is valid
state check_moodle
{
    state_entry()
    {
        sloodle_debug("Checking Moodle...");
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.8], "checkingserverat", [sloodleserverroot], NULL_KEY, "");
        httpcheckmoodle = llHTTPRequest(sloodleserverroot + SLOODLE_VERSION_LINKER, [HTTP_METHOD, "GET"], "");
    }
    
    state_exit()
    {
        llSetText("", <0.0,0.0,0.0>, 0.0);
        httpcheckmoodle = NULL_KEY;
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure it's the response we're expecting
        if (id != httpcheckmoodle) return;
        httpcheckmoodle = NULL_KEY;
        // Check the status code
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "httperror:code", [status], NULL_KEY, "");
            return;
        }
        
        // Split the response into lines and get the status line info
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Make sure the status code was OK
        if (statuscode == -106) {
            sloodle_debug("ERROR -106: the Sloodle module is not installed on the specified Moodle site (" + sloodleserverroot + ")");
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "sloodlenotinstalled", [], NULL_KEY, "");
            return;
        } else if (statuscode <= 0) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "failedcheckcompatibility", [], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            return;
        }
        
        // Make sure we have enough other data
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            return;
        }
        
        // Extract the Sloodle version number
        list datafields = llParseStringKeepNulls(llList2String(lines, 1), ["|"], []);
        float installedversion = (float)llList2String(datafields, 0);
        
        // Check compatibility
        if (installedversion < SLOODLE_VERSION_MIN) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "sloodleversioninstalled", [installedversion], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "sloodleversionrequired", [SLOODLE_VERSION_MIN], NULL_KEY, "");
            return;
        }
        
        // Initiate object authorisation
        state auth_object;
    }
    
    touch_start(integer num_detected)
    {
        // Revert to the default state if the owner touched
        if (llDetectedKey(0) != llGetOwner()) return;
        state default;
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset command?
            if (sval == "do:reset") {
                llResetScript();
                return;
            }
        }
    }
    
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            llResetScript();
    }
}

// Object authorisation
state auth_object
{
    state_entry()
    {
        sloodle_debug("Object authorisation...");
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0, 1.0, 0.0>, 0.8], "initobjectauth", [], NULL_KEY, "");
        
        // Generate a random password
        password = sloodle_random_object_password();
        sloodlepwd = (string)llGetKey() + "|" + password;
        // Initiate the object authorisation
        string body = "sloodleobjuuid=" + (string)llGetKey();
        body += "&sloodleobjname=" + llGetObjectName();
        body += "&sloodleobjpwd=" + password;
        body += "&sloodleuuid=" + (string)llGetOwner();
        body += "&sloodleavname=" + llEscapeURL(llKey2Name(llGetOwner()));
        httpauthobject = llHTTPRequest(sloodleserverroot + SLOODLE_USER_AUTH_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    }
    
    state_exit()
    {
        llSetText("", <0.0,0.0,0.0>, 0.0);
        httpauthobject = NULL_KEY;
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the response we're expecting
        if (id != httpauthobject) return;
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "httperror:code", [status], NULL_KEY, "");
            return;
        }
        
        // Split the response into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the statuscode
        if (statuscode <= 0) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "objectauthfailed:code", [statuscode], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            return;
        }
        
        // Attempt to get the auth ID
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            return;
        }
        
        // The dataline will contain our URL
        sloodleauthurl = llList2String(lines, 1);
        sloodle_load_auth_url(llGetOwner());
        
        state check_auth;
    }
    
    touch_start(integer num_detected)
    {
        // Revert to the default state if the owner touched
        if (llDetectedKey(0) != llGetOwner()) return;
        state default;
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset command?
            if (sval == "do:reset") {
                llResetScript();
                return;
            }
        }
    }
    
    on_rez(integer start_param)
    {
        state default;
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            state default;
    }
}


// Check the object's authorisation status
state check_auth
{
    state_entry()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "checkingauth", [], NULL_KEY, "");

        // Check the authorisation regularly until it passes or we need to reset
        llSetTimerEvent(0.0);
        llSetTimerEvent(15.0);

        // Initiate the authorisation check
        httpcheckauth = sloodle_check_user_auth();
    }
    
    timer()
    {
        // Initiate the authorisation check
        httpcheckauth = sloodle_check_user_auth();
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
        httpcheckauth = NULL_KEY;
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the response we're expecting
        if (id != httpcheckauth) return;
        httpcheckauth = NULL_KEY;
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httperror", [status], NULL_KEY, "");
            state idle;
            return;
        }
        
        // Split the response into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the statuscode.
        // If it reports that the object hasn't been authorised yet, then keep checking.
        // For any other error, go back to the start of the process.
        if (statuscode == -214) {
            sloodle_debug("Not authorised yet...");
            return;
        } else if (statuscode <= 0) {
            //sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "servererror", [statuscode], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            state default;
            return;
        }
        
        // Looks like we're authorised OK
        state send_config;
    }
    
    touch_start(integer num_detected)
    {
        // Initiate the authorisation check
        httpcheckauth = sloodle_check_user_auth();
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset command?
            if (sval == "do:reset") {
                llResetScript();
                return;
            }
        }
    }
    
    on_rez(integer start_param)
    {
        state default;
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            state default;
    }
}


// Send the user to the authorisation page on the site.
state send_config
{
    state_entry()
    {
        sloodle_debug("Sending configuration...");
        // Send the configuration data to the other scripts
        string config = "set:sloodleserverroot|" + sloodleserverroot;
        config += "\nset:sloodlepwd|" + sloodlepwd;
        config += "\n" + SLOODLE_EOF;
        sloodle_tell_other_scripts(config);
        
        state idle;
    }
}


// Configuration finished
state idle
{
    state_entry()
    {
        sloodle_debug("Configuration finished.");
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Check the command type
            if (sval == "do:reset") {
                llResetScript();
            } else if (sval == "do:requestconfig") {
                sloodle_debug("Configuration requested.");
                state check_auth;
            } else if (sval == "do:reconfigure") {
                sloodle_debug("Reconfiguration requested.");
                state default;
            }
            return;
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: lsl/sloodle_setup_user.lsl 

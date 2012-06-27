//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Glossary (for Sloodle 0.3)
// Allows users in-world to search a Moodle glossary.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-8 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Jeremy Kemp
//  Peter R. Bloomfield
//  Paul Preibisch (Fire Centaur in SL)
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_GLOSSARY_LINKER = "/mod/sloodle/mod/glossary-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";

string SLOODLE_OBJECT_TYPE = "glossary-1.0";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
integer sloodlepartialmatches = 1;
integer sloodlesearchaliases = 0;
integer sloodlesearchdefinitions = 0;
integer sloodleidletimeout = 120; // How many seconds before automatic idle timeout? (0 means don't timeout)
string sloodleglossaryname = ""; // Name of the glossary

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httpcheck = NULL_KEY; // Request used to check the glossary
key httpsearch = NULL_KEY; // Request used to search the glossary
float HTTP_TIMEOUT = 10.0; // Period of time to wait for an HTTP response before giving up

string SLOODLE_METAGLOSS_COMMAND = "/def "; // The command prefix for searching via chat message
string searchterm = ""; // The term to be searched
key searcheruuid = NULL_KEY; // Key of the avatar searching


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

sloodle_reset()
{
    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], NULL_KEY, "");
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reset", NULL_KEY);
    llResetScript();
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
    else if (name == "set:sloodlepwd") {
        // The password may be a single prim password, or a UUID and a password
        if (value2 != "") sloodlepwd = value1 + "|" + value2;
        else sloodlepwd = value1;
        
    } else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
    else if (name == "set:sloodlemoduleid") sloodlemoduleid = (integer)value1;
    else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
    else if (name == "set:sloodlepartialmatches") sloodlepartialmatches = (integer)value1;
    else if (name == "set:sloodlesearchaliases") sloodlesearchaliases = (integer)value1;
    else if (name == "set:sloodlesearchdefinitions") sloodlesearchdefinitions = (integer)value1;
    else if (name == "set:sloodleidletimeout") sloodleidletimeout = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0 && sloodlemoduleid > 0);
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


///// STATES /////

// Default state - waiting for configuration
default
{
    state_entry()
    {
        // Starting again with a new configuration
        isconfigured = FALSE;
        eof = FALSE;
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        sloodlemoduleid = 0;
        sloodleobjectaccessleveluse = 0;
        sloodleserveraccesslevel = 0;
        sloodlepartialmatches = 1;
        sloodlesearchaliases = 0;
        sloodlesearchdefinitions = 0;
        sloodleidletimeout = 120;
        sloodleglossaryname = "";
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
                    state check_glossary;
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
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


// If necessary, check the name of the glossary
state check_glossary
{
    on_rez(integer par)
    {
        state default;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset message?
            if (str == "do:reset") llResetScript();
        }
    }

    state_entry()
    {
        // Lookup the glossary name
        sloodleglossaryname = "";
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.8], "metagloss:checking", [], NULL_KEY, "metagloss");        
        httpcheck = llHTTPRequest(sloodleserverroot + SLOODLE_GLOSSARY_LINKER + "?sloodlecontrollerid=" + (string)sloodlecontrollerid + "&sloodlepwd=" + sloodlepwd + "&sloodlemoduleid=" + (string)sloodlemoduleid, [HTTP_METHOD, "GET"], "");
        llSetTimerEvent(0.0);
        llSetTimerEvent(HTTP_TIMEOUT);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
        llSleep(0.1);
        sloodle_reset();
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the response we're expecting
        if (id != httpcheck) return;
        if (status != 200) {
        sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            sloodle_reset();
            return;
        }

        // Split the response into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the statuscode
        if (statuscode <= 0) {
            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            sloodle_reset();
            return;
        }
        
        // Make sure we have enough data
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            sloodle_reset();
            return;
        }
        
        // Store the glossary name
        sloodleglossaryname = llList2String(lines, 1);
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "metagloss:checkok", [sloodleglossaryname], NULL_KEY, "metagloss");
        state ready;
    }
}


// Ready for definition requests
state ready
{
    on_rez( integer param)
    {
        state default;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset message?
            if (str == "do:reset") llResetScript();
        }
    }
    
    state_entry()
    {
        // Update the hover text
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 0.9], "metagloss:ready", [sloodleglossaryname, SLOODLE_METAGLOSS_COMMAND], NULL_KEY, "metagloss");
        // Listen for chat messages
        llListen(0, "", NULL_KEY, "");
    
        // We may need to de-activate after a period of idle time
        llSetTimerEvent(0.0);
        if (sloodleidletimeout > 0) llSetTimerEvent((float)sloodleidletimeout);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    listen( integer channel, string name, key id, string message)
    {
        // Check the channel
        if (channel == 0) {
            // Check use of this object
            if (sloodle_check_access_use(id) == FALSE) return;
            // Is this a definition request?
            if (llSubStringIndex(message, SLOODLE_METAGLOSS_COMMAND) != 0) return;
    
            // Store the term to be searched and search it
            searchterm = llGetSubString(message, llStringLength(SLOODLE_METAGLOSS_COMMAND), -1);
            searcheruuid = id;
            state search;
            return;
        }
    }

    timer()
    {
        // Shutdown due to idle timeout
        state shutdown;
    }
    
}

state shutdown
{
    on_rez(integer par)
    {
        state default;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset message?
            if (str == "do:reset") llResetScript();
        }
    }
    
    state_entry()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.5,0.1,0.1>, 0.6], "metagloss:idle", [sloodleglossaryname], NULL_KEY, "metagloss");
    }
    
    touch_start(integer num_detected)
    {
        // Go through each toucher
        integer i = 0;
        key id = NULL_KEY;
        for (; i < num_detected; i++) {
            id = llDetectedKey(i);
            // Does this user have permission to use this object?
            if (sloodle_check_access_use(id)) {
                state ready;
            } else {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [], NULL_KEY, "");
            }
        }
    }
}

state search
{
    on_rez(integer par)
    {
        state default;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset message?
            if (str == "do:reset") llResetScript();
        }
    }

    state_entry()
    {
        // Search the specified term
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.5,0.0>, 0.9], "metagloss:searching", [sloodleglossaryname], NULL_KEY, "metagloss");
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        body += "&sloodleuuid=" + (string)searcheruuid;
        body += "&sloodleavname=" + llEscapeURL(llKey2Name(searcheruuid));
        body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
        body += "&sloodleterm=" + searchterm;
        body += "&sloodlepartialmatches=" + (string)sloodlepartialmatches;
        body += "&sloodlesearchaliases=" + (string)sloodlesearchaliases;
        body += "&sloodlesearchdefinitions=" + (string)sloodlesearchdefinitions;
        // Check if it's an object sending this message
        if (searcheruuid != llGetOwnerKey(searcheruuid)) {
            // This makes sure Moodle doesn't try to auto-register an object
            body += "&sloodleisobject=true";
        }
        // Send the request
        httpsearch = llHTTPRequest(sloodleserverroot + SLOODLE_GLOSSARY_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        
        llSetTimerEvent(0.0);
        llSetTimerEvent(HTTP_TIMEOUT);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
        state ready;
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the response we're expecting
        if (id != httpsearch) return;
        if (status != 200) {
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            sloodle_reset();
            return;
        }
        
        // Split the response into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the statuscode
        if (statuscode <= 0) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
            sloodle_reset();
            return;
        }
        
        // Indicate how many definitions were found
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "metagloss:numdefs", [searchterm, (numlines - 1)], NULL_KEY, "metagloss");
        
        // Go through each definition
        integer defnum = 1;
        list fields = [];
        for (; defnum < numlines; defnum++) {
            // Split this definition into fields
            fields = llParseStringKeepNulls(llList2String(lines, defnum), ["|"], []);
            if (llGetListLength(fields) >= 2) {
                llSay(0, llList2String(fields, 0) + " = " + llList2String(fields, 1));
            } else {
                llSay(0, llList2String(fields, 0));
            }
        }

        state ready;
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/glossary-1.0/objects/default/assets/sloodle_mod_glossary-1.0.lslp 

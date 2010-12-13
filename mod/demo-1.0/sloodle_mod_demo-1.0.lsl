// Sloodle Demo object (for Sloodle 0.4)
// Part of the SLOODLE project (www.sloodle.org)
//
// Note: all language output in this script SHOULD use translation requests, but it doesn't yet!
//
// Copyright (c) 2009 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//

// These are common constants
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_EOF = "sloodleeof";
integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

// This variable identifies the type of object this is
string SLOODLE_OBJECT_TYPE = "demo-1.0";
// This string identifies the location of the linker script relative to this Moodle root
string SLOODLE_DEMO_LINKER = "/mod/sloodle/mod/demo-1.0/linker.php";

// These are common configuration settings
string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
integer sloodleautodeactivate = 1; // Should the WebIntercom auto-deactivate when not in use?

// These are object-specific configuration settings
string sloodlerandomtext = "";
integer sloodleshowhovertext = 1;
// TODO: add other object-specific configuration settings...

// These are used when receiving configuration so we know when to move on
integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

// TODO: add other data your script needs
key http = NULL_KEY;


///// TRANSLATION /////
// This is common translation code.
// Leave it alone! But feel free to copy it to other scripts.

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

// Common SLOODLE debug output
sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}

// Configure by receiving a linked message from another script in the object.
// Returns TRUE if the object has all the data it needs.
// Copy the basic structure for other objects, but add/remove specific configuration settings as necessary.
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
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
    else if (name == "set:sloodlerandomtext") sloodlerandomtext = value1;
    else if (name == "set:sloodleshowhovertext") sloodleshowhovertext = (integer)value1;
    // TODO: Add additional configuration parameters here
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    // This line figures out if we have all the core data we need.
    // TODO: If you absolutely need any other core data in the configuration, then add it to this condition.
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0 && sloodlemoduleid > 0);
}

// Checks if the given agent is permitted to control this object.
// Returns TRUE if so, or FALSE if not.
// You can leave this out if you don't need to check for control authority.
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

// Checks if the given agent is permitted to user this object.
// Returns TRUE if so, or FALSE if not.
// You can leave this out if you don't need to check for usage authority.
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

// TODO: add other functions your script might need

///// STATES /////

// Default state - waiting for configuration.
// The first state of your main script should ALWAYS be something like this.
// However, you'll need to tweak it for each object.
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
        sloodlemoduleid = 0;
        sloodleobjectaccessleveluse = 0;
        sloodleobjectaccesslevelctrl = 0;
        sloodleserveraccesslevel = 0;
        sloodlerandomtext = "";
        sloodleshowhovertext = 0;
        
        // TODO: Add other custom reset stuff here...
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Received a link message possibly containing configuration data.
        // Split it up and process it.
    
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                    
                    // TODO: customize the state change if you need to
                    state ready;
                    return;
                    
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
        // Attempt to request a reconfiguration.
        if (llDetectedKey(0) == llGetOwner()) {
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
        }
    }
}

// TODO: from this point on, the structure of the script is largely up to you!

// Common name for the primary state in which the tool operates.
state ready
{
    on_rez( integer param)
    {
        state default;
    }    
    
    state_entry()
    {
        // Should we show hover text?
        // (This is set in object configuration)
        if (sloodleshowhovertext) {
            llSetText("Random text:\n" + sloodlerandomtext, <1.0, 0.0, 0.0>, 1.0);
        } else {
            llSay(0, "");
        }
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
        
    touch_start( integer total_number)
    {
        // Check to see if the user has permission to control or use this object.
        if (sloodle_check_access_ctrl(llDetectedKey(0))) {
            llSay(0, llDetectedName(0) + " has permission to control this object.");
            
        } else if (sloodle_check_access_use(llDetectedKey(0))) {
            llSay(0, llDetectedName(0) + " has permission to use this object.");
            
        } else {
            // No permission
            llSay(0, llDetectedName(0) + " does not have permission to control or use this object.");
        }
    
        // We want to communicate with the linker script.
        // Construct the body of the request, and then send it all as POST parameters.
        // First, we will pass the configuration data that needs to be passed:
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + (string)sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
        // Add our other data
        body += "&sloodleavname=" + llEscapeURL(llDetectedName(0));
        body += "&sloodleuuid=" + (string)llDetectedKey(0);
        body += "&message=testing";
        body += "&anothermessage=testing_some_more";
        
        // Now send the data
        http = llHTTPRequest(sloodleserverroot + SLOODLE_DEMO_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        
        llSetTimerEvent(10.0);
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // An HTTP response has been received.
        // Ignore anything that's not expected.
        if (id != http) return;
        http = NULL_KEY;
        llSetTimerEvent(0.0);
        
        // Check the status code
        if (status != 200) {
            // An error occurred
            llSay(0, "HTTP request failed with status code " + (string)status);
            return;
        }
        
        // Output the whole response
        llSay(0, "HTTP response:\n\n" + body);
    }

    timer()
    {
        llSetTimerEvent(0.0);
        llSay(0, "HTTP Timeout");
    }
    
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/demo-1.0/sloodle_mod_demo-1.0.lsl 

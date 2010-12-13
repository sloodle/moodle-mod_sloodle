// Sloodle Choice (for Sloodle 0.3)
// Allows avatars to interact graphically with a Moodle choice.
//
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//  Paul Preibisch (Fire Centaur in SL)
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
integer SLOODLE_CHANNEL_OBJECT_CHOICE = -1639270051;
string SLOODLE_CHOICE_LINKER = "/mod/sloodle/mod/choice-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";

string SLOODLE_OBJECT_TYPE = "choice-1.0";

// Choice commands
// Update the specified option. Followed by "|num|text|colour|count|prop"
//  - num is a local option identifier
//  - text is the caption to display for this option
//  - colour is a colour vector (cast to a string)
//  - count is the number selected so far (or -1 if we don't want to display any)
//  - prop is the proportion of maximum size to show (between 0 and 1)
string SLOODLE_CHOICE_UPDATE_OPTION = "do:updateoption";
// Update the choice text. Followed by "|text"
string SLOODLE_CHOICE_UPDATE_TEXT = "do:updatetext";
// Select the specified option. Followed by "|num" (num is a local option identifier).
// The UUID of the toucher should be passed as the key value.
string SLOODLE_CHOICE_SELECT_OPTION = "do:selectoption";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodlerefreshtime = 600; // Number of seconds between automatic refreshes
integer sloodlerelative = FALSE; // Should the results be displayed in a relativistic way?
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httpstatus = NULL_KEY; // Request to check status of choice
list httpselect = []; // Requests to make selections

string choicetext = ""; // The choice text... i.e. the question being asked.
list optionids = []; // List of IDs of available options (integers)
list optiontexts = []; // List of option texts (strings)
list optionselections = []; // Number of times each option has been selected (integers)
integer numunanswered = -1; // Number of people who have not answered yet

// A list of colors for the options (note: after running out of colours, the list will wrap around)
list optioncolours = [
    <1.0, 0.0, 0.0>, // Red
    <0.0, 1.0, 0.0>, // Green
    <0.0, 0.0, 1.0>, // Blue
    <1.0, 1.0, 0.0>, // Yellow
    <1.0, 0.0, 1.0>, // Magenta
    <0.0, 1.0, 1.0>, // Cyan
    <0.5, 0.0, 0.0>, // Dark red
    <0.0, 0.5, 0.0>, // Dark green
    <0.0, 0.0, 0.5>, // Dark blue
    <1.0, 0.5, 0.0>, // Orange
    <0.5, 0.0, 0.5>, // Purple
    <0.0, 0.5, 0.5> // Indigo
];


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
    else if (name == "set:sloodlerefreshtime") sloodlerefreshtime = (integer)value1;
    else if (name == "set:sloodlerelative") sloodlerelative = (integer)value1;
    else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
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

// Gets the colour for a specified option (local option number)
vector get_option_colour(integer num)
{
    // Make sure we don't run out of colours
    num = num % llGetListLength(optioncolours);
    return llList2Vector(optioncolours, num);
}

// Send a reset command to all options
send_reset()
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_CHOICE, "do:reset", NULL_KEY);
}

// Send an update to all parts of the display
send_update()
{
    // Update the choice text itself
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_CHOICE, SLOODLE_CHOICE_UPDATE_TEXT + "|" + choicetext, NULL_KEY);
    
    // We want to determine the value that represents a full bar on the graph.
    // In relative mode, this is the maximum number of selections for a given option (so everything is relative to that).
    // Otherwise, it is the total number of people who have selected or could have selected.
    integer fullbar = 0;
    integer num_options = llGetListLength(optionids);
    integer i = 0;
    integer numsels = 0;
    for (i = 0; i < num_options; i++) {
        // Get the number of selections for this option
        numsels = llList2Integer(optionselections, i);
        // Relative mode?
        if (sloodlerelative) {
            // Store the maximum
            if (numsels > fullbar) fullbar = numsels;
        } else {
            // Add to the total
            fullbar += numsels;
        }
    }
    
    // Add the number who have not answered yet, if necessary
    if (sloodlerelative == 0 && numunanswered > 0) fullbar += numunanswered;

    // Go through each option we have
    string data = "";
    for (i = 0; i < num_options; i++) {
        // Send all the data
        data = SLOODLE_CHOICE_UPDATE_OPTION;
        data += "|" + (string)i;
        data += "|" + llList2String(optiontexts, i);
        data += "|" + (string)get_option_colour(i);
        data += "|" + (string)llList2Integer(optionselections, i);
        
        // Do we have results to add?
        numsels = llList2Integer(optionselections, i);
        if (numsels > 0 && fullbar > 0) {
            // At this point, all results are relative to the 'fullbar' value
            data += "|" + (string)((float)numsels / (float)fullbar);
        } else {
            data += "|0.0";
        }
        
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_CHOICE, data, NULL_KEY);
    }
}

// Request an update of the choice status.
// Returns the HTTP key.
key request_status()
{
    // Send a request to select the option
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
    
    return llHTTPRequest(sloodleserverroot + SLOODLE_CHOICE_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
}


///// STATES /////

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
        sloodlemoduleid = 0;
        sloodlerefreshtime = 0;
        sloodleobjectaccessleveluse = 0;
        sloodleserveraccesslevel = 0;
        // Reset our display
        send_reset();
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

state ready
{
    on_rez( integer param)
    {
        state default;
    }
    
    state_entry()
    {
        // Start by requesting an update
        httpstatus = request_status();
        httpselect = [];
        
        // If we've been given a refresh timer, then use it
        llSetTimerEvent(0.0);
        if (sloodlerefreshtime > 0) {
            // Validate the value - shouldn't check more often than every 10 seconds
            if (sloodlerefreshtime < 10) sloodlerefreshtime = 10;
            llSetTimerEvent((float)sloodlerefreshtime);
        }
    }
    
    timer()
    {
        // Request another status update
        httpstatus = request_status();
    }
    
    touch_start(integer total_number)
    {
        // Request another status update (but only if it this exact prim which was touched)
        if (llDetectedLinkNumber(0) == llGetLinkNumber()) {
            httpstatus = request_status();
        }
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Is this a status update?
        if (id == httpstatus) {
            httpstatus = NULL_KEY;
            //sloodle_debug("HTTP response: " + body);
            
            // Make sure the HTTP response was OK
            if (status != 200) {
                sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
                return;
            }
            
            // Parse the response data
            list lines = llParseStringKeepNulls(body, ["\n"], []);
            integer numlines = llGetListLength(lines);
            list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
            integer statuscode = (integer)llList2String(statusfields, 0);
            
            // Did an error occur?
            if (statuscode <= 0) {
                //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
                sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
                sloodle_debug(body);
                return;
            }
            
            // Make sure we have enough body data
            if (numlines < 5) {
                sloodle_debug("Not enough response data.");
                return;
            }
            
            // Extract the necessary choice data
            choicetext = llList2String(lines, 1) + "\n\"" + llList2String(lines, 2) + "\"";
            numunanswered = (integer)llList2String(lines, 4);
            // (There is more data provided that we could use later)
            
            // Determine how many options there are.
            // If there are a different number now than we already had, then reset all our options
            integer numoptions = numlines - 5;
            if (numoptions != llGetListLength(optionids)) {
                send_reset();
            }
            
            // Reset our data
            optionids = [];
            optiontexts = [];
            optionselections = [];
            
            // Go through each option
            integer i = 5;
            list fields = [];
            for (; i < numlines; i++) {
                // Parse the option data
                fields = llParseStringKeepNulls(llList2String(lines, i), ["|"], []);
                if (llGetListLength(fields) >= 3) {
                    optionids += [(integer)llList2String(fields, 0)];
                    optiontexts += [llList2String(fields, 1)];
                    optionselections += [(integer)llList2String(fields, 2)];
                }
            }
            
            sloodle_debug("Number of options received: " + (string)llGetListLength(optionids));
            
            // Update all our components
            send_update();
            
            return;
        }
        
        // Is this a selection response?
        integer pos = llListFindList(httpselect, [id]);
        if (pos >= 0) {
            httpselect = llDeleteSubList(httpselect, pos, pos);
            
            // Make sure the HTTP response was OK
            if (status != 200) {
                sloodle_debug("HTTP request failed with status code " + (string)status);
                return;
            }
            
            // Parse the response
            list lines = llParseStringKeepNulls(body, ["\n"], []);
            integer numlines = llGetListLength(lines);
            list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
            integer numstatusfields = llGetListLength(statusfields);
            if (numstatusfields < 7) return;
            
            // Extract the relevant data
            integer statuscode = (integer)llList2String(statusfields, 0);
            key uuid = (key)llList2String(statusfields, 6);
            string name = llKey2Name(uuid);
            
            // Did an error occur?
            if (statuscode == -10011) sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noupdate", [name], NULL_KEY, "choice");
            else if (statuscode == -10012) sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "maxselections", [name], NULL_KEY, "choice");
            else if (statuscode == -10013) sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "notopen", [name], NULL_KEY, "choice");
            else if (statuscode == -10014) sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "closed", [name], NULL_KEY, "choice");
            else if (statuscode == -10016) sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "selectionerror", [name], NULL_KEY, "choice");
            else if (statuscode <= 0) {
                //    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
                sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            }
            if (statuscode <= 0) {
                sloodle_debug(body);
                return;
            }
            
            // What was the nature of the selection?
            if (statuscode == 10012) sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "selectionupdated", [name], NULL_KEY, "choice");
            else if (statuscode == 10013) sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "selectionalreadymade", [name], NULL_KEY, "choice");
            else sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "selectionmade", [name], NULL_KEY, "choice");
            
            // Make sure to update the status
            httpstatus = request_status();
            return;
        }
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_CHOICE) {
            // Parse the string
            list parts = llParseString2List(sval, ["|"], []);
            integer numparts = llGetListLength(parts);
            string cmd = llList2String(parts, 0);
            
            // Check the command
            if (cmd == SLOODLE_CHOICE_SELECT_OPTION && kval != NULL_KEY && numparts > 1) {
                // Determine which option ID is being selected
                integer optionnum = (integer)llList2String(parts, 1);
                if (optionnum < 0 || optionnum >= llGetListLength(optionids)) return;
                integer optionid = llList2Integer(optionids, optionnum);
                string name = llKey2Name(kval);
                
                sloodle_debug("Selecting option ID " + (string)optionid + " for " + name);
                
                // Send a request to select the option
                string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
                body += "&sloodlepwd=" + sloodlepwd;
                body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
                body += "&sloodleuuid=" + (string)kval;
                body += "&sloodleavname=" + llEscapeURL(name);
                body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
                body += "&sloodleoptionid=" + (string)optionid;
                
                key newhttp = llHTTPRequest(sloodleserverroot + SLOODLE_CHOICE_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
                httpselect += [newhttp];
            }
            
        } else if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            if (sval == "do:reset") llResetScript();
        }
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/choice-1.0/sloodle_mod_choice-1.0.lsl 

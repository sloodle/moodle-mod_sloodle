//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle object layout script.
// Allows individual objects to store themselves in a Sloodle layout.
//
// Part of the Sloodle project (www.sloodle.org)
// Copyright (c) 2008 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Peter R. Bloomfield
//  Edmund Edgar
//  Paul Preibisch - Fire Centaur in SL
//
///// DATA /////
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_LAYOUT_LINKER = "/mod/sloodle/mod/set-1.0/layout_linker.php";
string SLOODLE_EOF = "sloodleeof";

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
key sloodlemyrezzer = NULL_KEY;

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httpstore = NULL_KEY; // Request to store this object's location
float HTTP_TIMEOUT = 8.0; // Time to wait for an HTTP response before failing

integer attemptnum = 0; // Which attempt number is this?
integer attemptmax = 2; // How many attempts should be allowed [0,max)

float DELAY_MIN = 0.0; // Minimum delay before sending an HTTP request (seconds)
float DELAY_RANGE = 3.5; // Added to DELAY_MIN gives the maximum delay time before sending HTTP request (seconds)

key useruuid = NULL_KEY; // User agent requesting profile storage
string layoutname = ""; // Name of the layout to save to
vector layoutpos = <0.0,0.0,0.0>; // Relative position from the rezzer to this object


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

// Send debug info
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
    else if (name == "set:sloodlemyrezzer") sloodlemyrezzer = (key)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    else if (name == "do:reset") llResetScript();
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0);
}

// Generate a random delay time
float random_delay()
{
    return (DELAY_MIN + llFrand(DELAY_RANGE));
}


///// STATES /////

default
{
    state_entry()
    {
        // Starting again with a new configuration
        isconfigured = FALSE;
        eof = FALSE;
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE && isconfigured == TRUE) {
                state ready;
            }
        }  
    }
}

state ready
{
    state_entry()
    {
        // Reset our data
        useruuid = NULL_KEY;
        layoutname = "";
        // Listen for chat messages on the object dialog channel
        llListen(SLOODLE_CHANNEL_OBJECT_DIALOG, "", sloodlemyrezzer, "");
    }
    
    listen(integer channel, string name, key id, string msg)
    {
        // Ignore anything if we don't know who our rezzer is
        if (sloodlemyrezzer == NULL_KEY) return;
        
        // Ignore anything but object chat
        if (channel != SLOODLE_CHANNEL_OBJECT_DIALOG) return;
        // Ignore anything owned by a different agent
        if (llGetOwnerKey(id) != llGetOwner()) return;
        
        // Parse the message
        // We are expecting: cmd|rezzer|uuid|pos|layoutname
        // "cmd" should be "do:storelayout"
        // "rezzer" is the UUID of the Set whose items should be stored
        // "uuid" is the UUID of the user agent storing the layout
        // "pos" is the vector giving the position of the root of the rezzer
        // "layoutname" should be the name of the layout to save to
        list fields = llParseStringKeepNulls(msg, ["|"], []);
        integer numfields = llGetListLength(fields);
        if (numfields < 4) return;
        // Get the command and UUID
        string cmd = llList2String(fields, 0);
        key rezzer = (key)llList2String(fields, 1);
        useruuid = (key)llList2String(fields, 2);
        vector rezzerpos = (vector)llList2String(fields, 3);
        layoutname = llList2String(fields, 4);
        
        // Check that everything looks OK
        if (cmd != "do:storelayout") return;
        if (rezzer != sloodlemyrezzer || sloodlemyrezzer == NULL_KEY) return;
        if (useruuid == NULL_KEY) return;
        if (layoutname == "") return;
        
        // Calculate the relative position of us compared to the rezzer
        layoutpos = llGetPos() - rezzerpos;
        // If the distance is more than can be rezzed later on, then ignore it
        if (llVecMag(layoutpos) > 10.0) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "layout:toofar", [], NULL_KEY, "");
            return;
        }
        
        // Attempt to store the layout
        attemptnum = 0;
        state store_layout;
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
}

// This is a dummy state... it can be used to start the store process again
state store_layout
{
    state_entry()
    {
        // Move on immediately...
        state delay;
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
}

// Wait for a delay before actually sending the request
state delay
{
    state_entry()
    {
        // Generate a random delay
        llSetTimerEvent(random_delay());
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        // Send the storage request
        attemptnum += 1;
        state request;
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
}

// Send a request to store the object data
state request
{
    state_entry()
    {
        // Construct our request
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlelayoutname=" + layoutname;
        body += "&sloodleuuid=" + (string)useruuid;
        body += "&sloodlelayoutentries=" + llGetObjectName() + "|" + (string)layoutpos + "|" + (string)llGetRot();
        body += "&sloodleadd=true";
        
        httpstore = llHTTPRequest(sloodleserverroot + SLOODLE_LAYOUT_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        httpstore = NULL_KEY;
        state failed;
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Ignore this response if it is not expected
        if (id != httpstore) return;
        llSetTimerEvent(0.0);
        httpstore = NULL_KEY;
        
        // Check the HTTP status
        if (status != 200) {
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            state failed;
            return;
        }
        
        // Check the body of the response
        if (body == "") {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httpempty", [], NULL_KEY, "");
            state failed;
            return;
        }
        
        // Parse the response
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
                
        // Did an error occur?
        if (statuscode <= 0) {
            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            sloodle_debug("HTTP response: " + body);
            state failed;
            return;
        }
        
        // Everything must be OK... send the data to the object. Format:
        state success;
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
}

// Update failed... try again?
state failed
{
    state_entry()
    {
        // Do we have any attempts left?
        if (attemptnum < attemptmax) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "layout:failedretrying", [], NULL_KEY, "");
            state store_layout;
        } else {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "layout:failedaborting", [], NULL_KEY, "");
            state ready;
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
}

// Update successful
state success
{
    state_entry()
    {
        // Done!
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "layout:stored", [], NULL_KEY, "");
        state ready;
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
}


// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: lsl/sloodle_layout_object.lsl 

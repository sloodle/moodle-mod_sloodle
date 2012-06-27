//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle AviLister
// When touched, lists the Moodle names of any known avatars nearby (up to a maximum of 16)
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-8 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//
//


///// CONSTANTS /////
// Timeout values
float SENSOR_TIMEOUT = 15.0; // Time to wait for a sensor
float HTTP_TIMEOUT = 10.0; // Time to wait for an HTTP response

// What channel should configuration data be received on?
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;

// Colours for different states
vector COL_NOT_INIT = <1.0,0.0,0.0>;
vector COL_READY = <1.0,1.0,1.0>;
vector COL_PROCESSING = <0.4,0.1,1.0>;

// Sensor radius (in metres) for detecting avatars
float SENSOR_RADIUS = 48.0;

// End of file identfier for configuration data
string SLOODLE_EOF = "sloodleeof";

///// --- /////


///// DATA /////

// The address of the moodle installation
string sloodleserverroot = "";
// The prim password for accessing the site
string sloodlepwd = "";
// The ID of a controller, if we are using course-centric authorisation
integer sloodlecontrollerid = 0;

// Have we reached the end of the config data, and is this item configured?
integer eof = FALSE;
integer isconfigured = FALSE;

// Relative paths to the AviLister linker script
string LINKER_SCRIPT = "/mod/sloodle/toolbar/avilister_linker.php";

// Keys of the pending HTTP requests
key httpavilistrequest = NULL_KEY;

///// --- /////


///// TRANSLATIONS /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

// Translation output methods
string SLOODLE_TRANSLATE_LINK = "link";                     // No output parameters - simply returns the translation on SLOODLE_TRANSLATION_RESPONSE link message channel
string SLOODLE_TRANSLATE_SAY = "say";                       // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_WHISPER = "whisper";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SHOUT = "shout";                   // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_REGION_SAY = "regionsay";          // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";            // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";                 // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";              // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_LOAD_URL_PARALLEL = "loadurlpar";  // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";          // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_IM = "instantmessage";             // Recipient avatar should be identified in link message keyval. No output parameters.

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}


///// FUNCTIONS /////
// Send a debug message (requires the "sloodle_debug" script in the same link)
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
        
    }
    else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "");
}

///// --- /////


/// INITIALISING STATE ///
// Waiting for configuration
default
{    
    state_entry()
    {
        // Set to our non-initialised colour initially
        llSetColor(COL_NOT_INIT, ALL_SIDES);
        
        // Reset our values
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        eof = FALSE;
        isconfigured = FALSE;
    }
    
    state_exit()
    {
    }
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
        	// Reset message?
			if (msg == "do:reset") {
				llResetScript();
				return;
			}
        
            // Split the message into lines
            list lines = llParseString2List(msg, ["\n"], []);
            integer numlines = llGetListLength(lines);
           integer i;
            for ( i=0 ; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    state ready;
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
                    eof = FALSE;
                }
            }
        }
    }
    
    touch_start(integer num)
    {
        if (llDetectedKey(0) == llGetOwner()) llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            llResetScript();
    }
}


/// READY STATE ///
// Ready to be used
state ready
{    
    state_entry()
    {
        // Change colour
        llSetColor(COL_READY, ALL_SIDES);
    }
    
    
    touch_start( integer num )
    {
        // Start searching for avatars
        state searching;
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            state default;
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
    	if (sender_num == llGetLinkNumber()) return;
    	if (num == SLOODLE_CHANNEL_OBJECT_DIALOG && sval == "do:reset") llResetScript();
    }
}


/// SEARCHING ///
// Searching for nearby avatars and waiting for a response
state searching
{   
    state_entry()
    {
        // Change colour
        llSetColor(COL_PROCESSING, ALL_SIDES);

        // Start a sensor scan within 
        llSensor("", NULL_KEY, AGENT, SENSOR_RADIUS, PI);
        llSetTimerEvent(SENSOR_TIMEOUT);
    }
    
    state_exit()
    {
    }

    no_sensor()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "noavatars", [], NULL_KEY, "avilister");
        state ready;
    }

    sensor(integer total_number)
    {
        llSetTimerEvent(0.0);
        // Build the argument list for our HTTP request
        string arglist = "sloodleuuid=" + (string)llGetOwner();
        arglist += "&sloodlepwd=" + sloodlepwd;
        arglist += "&sloodleavnamelist=";
        integer i;
        for ( i=0 ; i < total_number; i++) {
            if (i > 0) arglist += "|";
            arglist += llEscapeURL(llDetectedName(i));
        }

        // Send the HTTP request
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "requesting", [total_number, sloodleserverroot], NULL_KEY, "avilister");
        httpavilistrequest = llHTTPRequest(sloodleserverroot + LINKER_SCRIPT, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], arglist);
        llSetTimerEvent(HTTP_TIMEOUT);
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Ignore unexpected response
        if (id != httpavilistrequest) return;
        llSetTimerEvent(0.0);
        sloodle_debug("HTTP Response ("+(string)status+"): "+body);
        
        // Was the HTTP request successful?
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httperror", [status], NULL_KEY, "");
            state ready;
            return;
        }
        
        // Split the response into lines and extract the status fields
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
        integer statuscode = llList2Integer(statusfields, 0);
        // We expect at most 1 data line
        string dataline = "";
        if (numlines > 1) dataline = llList2String(lines, 1);
        
        // Was the status code an error?
        if (statuscode <= 0) {
            // Report the error
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "servererror", [statuscode], NULL_KEY, "");
            sloodle_debug(dataline);
            state ready;
            return;
        }

        // Make sure some data was returned
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "nonerecognised", [], NULL_KEY, "avilister");
            state ready;
            return;
        }
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "numidentified", [(numlines - 1)], NULL_KEY, "avilister");
        
        // Go through each line
        integer i;
        for ( i=1 ; i < numlines; i++) {
            // Split this line into separate fields
            list fields = llParseStringKeepNulls(llList2String(lines, i), ["|"], []);
            // Make sure there are enough fields
            if (llGetListLength(fields) >= 2) {
                // Display the data
                llOwnerSay("(SL) " + llList2String(fields, 0) + " -> " + llList2String(fields, 1));
            }
        }
        
        state ready;
    }
    
    timer()
    {
        // We have timed-out waiting for an HTTP response
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httptimeout", [], NULL_KEY, "");
        httpavilistrequest = NULL_KEY;
        state ready;
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            state default;
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
    	if (sender_num == llGetLinkNumber()) return;
    	if (num == SLOODLE_CHANNEL_OBJECT_DIALOG && sval == "do:reset") llResetScript();
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: toolbar/lsl/sloodle_avilister.lsl 

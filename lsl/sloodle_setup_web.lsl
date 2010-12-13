// Sloodle web-configuration script
// In the absence of a configuration notecard, allows an object to be authorised/configured via the web
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2008 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//  Edmund Edgar
//  Paul Preibisch - Fire Centaur in SL

integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
string SLOODLE_CONFIG_NOTECARD = "sloodle_config";
string SLOODLE_EOF = "sloodleeof";
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;

string SLOODLE_VERSION_LINKER = "/mod/sloodle/version_linker.php";
string SLOODLE_AUTH_LINKER = "/mod/sloodle/classroom/auth_object_linker.php";
string SLOODLE_CONFIG_INTERFACE = "/mod/sloodle/classroom/configure_object.php";
string SLOODLE_CONFIG_LINKER = "/mod/sloodle/classroom/object_config_linker.php";
string SLOODLE_PING_LINKER = "/mod/sloodle/classroom/active_object_ping_linker.php";

float PING_DELAY = 10800.0; // Number of seconds between pings (does not need to be very frequent)

string SLOODLE_SCRIPT_PREFIX = "sloodle_mod_";

float SLOODLE_VERSION_MIN = 0.3; // Minimum required version of Sloodle

key httpcheckmoodle = NULL_KEY;
key httpauthobject = NULL_KEY;
key httpconfig = NULL_KEY;

string sloodleserverroot = "";
string sloodlepwd = ""; // stores the object-specific session key (UUID|pwd)
string sloodleauthid = ""; // The ID which is passed to Moodle in the URL for the user authorisation step
key sloodlemyrezzer = NULL_KEY; // Stores the UUID of the object that rezzed this one (if applicable)
integer sloodlecontrollerid = 0; // So we know which Controller to access when PING-in the server later

string password = ""; // stores the self-generated part of the password

integer request_config = FALSE; // This is used when jumping from the idle state back to a configuration request
integer show_config_url = TRUE; // By default, we will automatically show the config URL to the owner when config starts
integer url_shown = FALSE; // At first we simply want to show the URL, but thereafter we can show the menu
string SLOODLE_OBJECT_TYPE = "";




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

//FUNCTIONS
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
    sloodle_debug("Web configuration sending message to other scripts: "+msg);
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, msg, NULL_KEY);   
}

sloodle_debug(string msg)
{
    //llWhisper(0,msg);
}

// Determines if the objet has a configuration notecard
// Returns true if so, or false otherwise
integer sloodle_has_config_notecard()
{
    return (llGetInventoryType(SLOODLE_CONFIG_NOTECARD) == INVENTORY_NOTECARD);
}

// Generate a random password string
string sloodle_random_object_password()
{
    return (string)(10000 + (integer)llFrand(999989999)); // Gets a random integer between 10000 and 999999999
}

// Show a menu letting the user choose between configuring the object, and downloading the configuration into SL
sloodle_show_config_menu(key av)
{
    sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG, "0", "1"], "webconfigmenu", ["0", "1"], av, "");
    llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", av, "0");
    llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", av, "1");
}

// Load the configuration URL
sloodle_load_config_url(key av)
{
    string url = sloodleserverroot + SLOODLE_CONFIG_INTERFACE + "?sloodleauthid=" + sloodleauthid + "&sloodleobjtype=" + SLOODLE_OBJECT_TYPE;
    sloodle_translation_request(SLOODLE_TRANSLATE_LOAD_URL, [url], "configlink", [], av, "");
}

// Check to see what type this script is to use
// Returns the type/version identifier as a string, e.g. "chat-1.0"
string sloodle_check_type()
{
    // Find out how many scripts there are
    integer numscripts = llGetInventoryNumber(INVENTORY_SCRIPT);
    string type = "";
    string itemname = "";
    
    // Go through each item
    integer i = 0;
    for (i = 0; i < numscripts; i++) {
        // Get the name of this item
        itemname = llGetInventoryName(INVENTORY_SCRIPT, i);
        // Does this have the necessary prefix?
        if (llSubStringIndex(itemname, SLOODLE_SCRIPT_PREFIX) == 0) {
            // Ignore the script if it's not running... unless we don't already have a type identified
            if (llGetScriptState(itemname) == TRUE || type == "") {
                // Looks like this is our type
                type = llGetSubString(itemname, llStringLength(SLOODLE_SCRIPT_PREFIX), -1);
            }
        }
    }
    
    return type;
}


default
{    
    state_entry() 
    {
        // Pause for a moment, in case all scripts were reset at the same time
        llSleep(0.2);
        sloodleserverroot = "";
    
        // Attempt to get the object type if we don't already have it
        if (SLOODLE_OBJECT_TYPE == "") {
            SLOODLE_OBJECT_TYPE = sloodle_check_type();
            if (SLOODLE_OBJECT_TYPE == "") {
                sloodle_translation_request(SLOODLE_TRANSLATE_WHISPER, [0], "notypeid", [], NULL_KEY, "");
                
            } else {
                sloodle_translation_request(SLOODLE_TRANSLATE_WHISPER, [0], "gottype", [SLOODLE_OBJECT_TYPE], NULL_KEY, "");
            }
        }
    
        // Listen for anything on the object dialog channel
        llListen(SLOODLE_CHANNEL_OBJECT_DIALOG, "", NULL_KEY, "");
        request_config = FALSE;
        
        // Do we have a configuration notecard?
        if (!sloodle_has_config_notecard()) {
            // No - if we have no starting parameter, then invite the user to use web-configuration
            if (llGetStartParameter() == 0) {
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 1.0], "touchforwebconfig", [], NULL_KEY, "");
            }
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
            show_config_url = TRUE;
            // If the message starts with "http" then store it as the Moodle address
            msg = llStringTrim(msg, STRING_TRIM);
            if (llSubStringIndex(msg, "http") == 0) {

                // If the message ends with a slash, remove it.
                if ( llGetSubString(msg, -1, -1) == "/" ) {
                    msg = llGetSubString(msg, 0, -2);    
                }            
                
                sloodleserverroot = msg;
                state check_moodle;
                return;
            }
            
        } else if (channel == SLOODLE_CHANNEL_OBJECT_DIALOG) {
        
            // Check for standard messages, then for anything else
            if (msg == "CLEANUP") {
                // Did it come from the rezzer?
                if (id == sloodlemyrezzer && id != NULL_KEY) {
                    // Delete this object
                    sloodle_debug("Received CLEANUP command from object \"" + name + "\".");
                    llDie();
                }
            } else {
                // Ignore anything not owned by the same person
                if (llGetOwnerKey(id) != llGetOwner()) return;
                // This should be a Sloodle initialisation message:
                //  sloodle_init|<rezzer>|<target-uuid>|<moodle-address>|<authid>
                // (the last part is optional)
                list parts = llParseStringKeepNulls(msg, ["|"], []);
                integer numparts = llGetListLength(parts);
                string cmd = llList2String(parts, 0);
                
                // Check what the command is
                if (cmd == "sloodle_init") {
                    // Make sure we have enough parts in the message
                    if (llGetListLength(parts) < 4) return;
                    key rezzer = (key)llList2String(parts, 1);
                    key target = (key)llList2String(parts, 2);
                    string url = llList2String(parts, 3);
                    string auth = "";
                    string isconfigured = "0";
                    if (numparts >= 5) auth = llList2String(parts, 4);
                    if (numparts >= 6) isconfigured = llList2String(parts, 5);
                                        
                    // Make sure the command is correct, the UUIDs are OK, and that the URL looks valid
                    if (rezzer == NULL_KEY) return;
                    if (target != llGetKey()) return;
                    url = llStringTrim(url, STRING_TRIM);
                    if (llSubStringIndex(url, "http") != 0) return;
                    
                    // Store the settings
                    sloodleserverroot = url;
                    sloodleauthid = auth;
                    sloodlemyrezzer = rezzer;
                    
                    // Do we have a password *and* an authorisation ID?
                    if (llGetStartParameter() != 0 && (integer)auth > 0) {
                        // Store the password
                        password = (string)llGetStartParameter();
                        sloodlepwd = (string)llGetKey() + "|" + password;
                        
                        if (isconfigured == "1") {
                            request_config = TRUE; // we're already configured by a layout, so we can go right ahead and get our config off the server
                        } 
                        
                        // Allow the user to configure the object
                        show_config_url = FALSE;
                        state configure_object;
                    
                        return;
                    }
                    
                    // Begin self-authorisation
                    state check_moodle;
                }
            }
        }
    }
    
    touch_start(integer num_detected)
    {
        // Only pay attention to the object owner
        if (llDetectedKey(0) != llGetOwner()) return;
        // Do nothing if there is a configuration script present
        if (sloodle_has_config_notecard()) return;
        
        // We can do nothing without a server root
        if (sloodleserverroot == "") {
            llListen(0, "", llGetOwner(), "");
            llListen(1, "", llGetOwner(), "");
            
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "chatserveraddress", [], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.8], "waitingforserveraddress", [], NULL_KEY, "");
            return;
        }
        
        // Start the configuration process
        state check_moodle;
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

// Check that the Moodle site is valid
state check_moodle
{
    state_entry()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.8], "checkingserverat", [sloodleserverroot], NULL_KEY, "");
        httpcheckmoodle = llHTTPRequest(sloodleserverroot + SLOODLE_VERSION_LINKER, [HTTP_METHOD, "GET"], "");
        // Listen for chat messages from the rezzer
        if (sloodlemyrezzer != NULL_KEY) llListen(SLOODLE_CHANNEL_OBJECT_DIALOG, "", NULL_KEY, "");
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
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httperror:code", [status], NULL_KEY, "");
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
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "sloodlenotinstalled", [], NULL_KEY, "");
            return;
        } else if (statuscode <= 0) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "failedcheckcompatibility", [], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            return;
        }
        
        // Make sure we have enough other data
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            return;
        }
        
        // Extract the Sloodle version number
        list datafields = llParseStringKeepNulls(llList2String(lines, 1), ["|"], []);
        float installedversion = (float)llList2String(datafields, 0);
        
        // Check compatibility
        if (installedversion < SLOODLE_VERSION_MIN) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "sloodleversioninstalled", [installedversion], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "sloodleversionrequired", [SLOODLE_VERSION_MIN], NULL_KEY, "");
            return;
        }
        
        // Initiate object authorisation
        state auth_object_initial;
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
    
    listen(integer channel, string name, key id, string msg)
    {
        // Check the channel
        if (channel == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Parse the message
            list parts = llParseStringKeepNulls(msg, ["|"], []);
            if (llGetListLength(parts) < 2) return;
            string cmd = llList2String(parts, 0);
            string val = llList2String(parts, 1);
        
            // Is it a recognised command?
            if (cmd == "do:cleanup") {
                // Did it come from our rezzer?
                key kval = (key)val;
                if (kval == sloodlemyrezzer && kval != NULL_KEY) {
                    // Delete this object
                    sloodle_debug("Received CLEANUP command from object \"" + name + "\".");
                    llDie();
                    return;
                }
            }
        }
    }
    
    on_rez(integer start_param)
    {
        llResetScript();
    }
}

// Initial object authorisation (stores details in the database)
state auth_object_initial
{
    state_entry()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0, 1.0, 0.0>, 0.8], "initobjectauth", [], NULL_KEY, "");
        
        // Generate a random password
        password = sloodle_random_object_password();
        sloodlepwd = (string)llGetKey() + "|" + password;
        // Initiate the object authorisation
        string body = "sloodleobjuuid="+(string)llGetKey()+"&sloodleobjname="+llGetObjectName()+"&sloodleobjpwd="+password+"&sloodleobjtype="+SLOODLE_OBJECT_TYPE;
        httpauthobject = llHTTPRequest(sloodleserverroot + SLOODLE_AUTH_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        
        // Listen for chat messages from the rezzer
        if (sloodlemyrezzer != NULL_KEY) llListen(SLOODLE_CHANNEL_OBJECT_DIALOG, "", NULL_KEY, "");
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
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httperror:code", [status], NULL_KEY, "");
            return;
        }
        
        // Split the response into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the statuscode
        if (statuscode <= 0) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "objectauthfailed:code", [statuscode], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            return;
        }
        
        // Attempt to get the auth ID
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            return;
        }
        sloodleauthid = llList2String(lines, 1);
        
        // Start the configuration
        state configure_object;
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
    
    listen(integer channel, string name, key id, string msg)
    {
        // Check the channel
        if (channel == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Parse the message
            list parts = llParseStringKeepNulls(msg, ["|"], []);
            if (llGetListLength(parts) < 2) return;
            string cmd = llList2String(parts, 0);
            string val = llList2String(parts, 1);
        
            // Is it a recognised command?
            if (cmd == "do:cleanup") {
                // Did it come from our rezzer?
                key kval = (key)val;
                if (kval == sloodlemyrezzer && kval != NULL_KEY) {
                    // Delete this object
                    sloodle_debug("Received CLEANUP command from object \"" + name + "\".");
                    llDie();
                    return;
                }
            }
        }
    }
}


// Send the user to the configuration page on the Moodle site.
// (That page will present authorisation options as necessary).
// If touched, ask the user if they want the URL again, or to download the configuration.
state configure_object
{
    state_entry()
    {
        url_shown = FALSE;
        sloodlecontrollerid = 0;
        
        // Has object configuration been requested?
        if (request_config) {
            request_config = FALSE;
            llSetText("Requesting configuration...", <0.0,1.0,0.0>, 0.8);
            httpconfig = llHTTPRequest(sloodleserverroot + SLOODLE_CONFIG_LINKER + "?sloodlepwd="+sloodlepwd+"&sloodleauthid="+sloodleauthid, [HTTP_METHOD, "GET"], "");
        } else {
            llSetText("Waiting for configuration.\nTouch me for a URL, or to download the configuration.", <0.0,1.0,0.0>, 0.8);
            // Load the URL immediately 
            if (show_config_url) {
                sloodle_load_config_url(llGetOwner());
                url_shown = TRUE;
            }
        }
        
        // Listen for chat messages from the rezzer
        if (sloodlemyrezzer != NULL_KEY) llListen(SLOODLE_CHANNEL_OBJECT_DIALOG, "", NULL_KEY, "");
    }
    
    state_exit()
    {
        llSetText("", <0.0,0.0,0.0>, 0.0);
        httpconfig = NULL_KEY;
    }
    
    touch_start(integer num_detected)
    {
        // Ignore anybody but the owner
        if (llDetectedKey(0) != llGetOwner()) return;
        // If the URL has already been shown, then display the menu.
        // Otherwise, offer the URL
        if (url_shown) sloodle_show_config_menu(llGetOwner());
        else {
            sloodle_load_config_url(llGetOwner());
            url_shown = TRUE;
        }
    }
    
    listen(integer channel, string name, key id, string msg)
    {
        // Check the channel
        if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG)
        {
            // Check it's the owner talking to us
            if (id != llGetOwner()) return;
            // What was the message?
            if (msg == "0") {
                // Load the configuration URL
                sloodle_load_config_url(llGetOwner());
            } else if (msg == "1") {
                // Download the configuration from the site
                httpconfig = llHTTPRequest(sloodleserverroot + SLOODLE_CONFIG_LINKER + "?sloodlepwd="+sloodlepwd+"&sloodleauthid="+sloodleauthid, [HTTP_METHOD, "GET"], "");
            }
            
        } else if (channel == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Parse the message
            list parts = llParseStringKeepNulls(msg, ["|"], []);
            if (llGetListLength(parts) < 2) return;
            string cmd = llList2String(parts, 0);
            string val = llList2String(parts, 1);
        
            // Is it a recognised command?
            if (cmd == "do:cleanup") {
                // Did it come from our rezzer?
                key kval = (key)val;
                if (kval == sloodlemyrezzer && kval != NULL_KEY) {
                    // Delete this object
                    sloodle_debug("Received CLEANUP command from object \"" + name + "\".");
                    llDie();
                    return;
                }
            }
        }
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Is this the response we're expecting?
        if (id == httpconfig) {
            httpconfig = NULL_KEY;
            // Check the return code
            if (status != 200) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httperror:code", [status], NULL_KEY, "");
                return;
            }
            
            // Split the response into lines
            list lines = llParseStringKeepNulls(body, ["\n"], []);
            integer numlines = llGetListLength(lines);
            // Fetch the status line
            list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
            integer statuscode = (integer)llList2String(statusfields, 0);
            if (statuscode == -103) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noconfigavailable", [], NULL_KEY, "");
                return;
            } else if (statuscode <= 0) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "objectconfigfailed:code", [statuscode], NULL_KEY, "");
                sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
                state default;
                return;
            }
            
            // Indicate that we are sending configuration data
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0, 1.0, 0.0>, 0.8], "sendingconfig", [], NULL_KEY, "");
            
            // This will be our buffer of configuration commands
            string cmdbuffer = "";
            integer maxbufferlength = 300;
            integer cmdbufferlength = 0;
            
            // Add the server address and password in as the first commands. Also add the rezzer key if we have one
            cmdbuffer = "set:sloodleserverroot|"+sloodleserverroot+"\nset:sloodlepwd|" + sloodlepwd + "\n";
            if (sloodlemyrezzer != NULL_KEY) cmdbuffer += "set:sloodlemyrezzer|" + (string)sloodlemyrezzer + "\n";
            cmdbufferlength = llStringLength(cmdbuffer);
            
            // Go through each data line
            integer linenum = 1;
            string cmd = "";
            integer cmdlen = 0;
            string curline = "";
            for (linenum=0; linenum < numlines; linenum++) {
                curline = llList2String(lines, linenum);
                
                // If this is a controller ID, then store the value.
                // (Don't bother checking if we already have a controller id)
                if (sloodlecontrollerid == 0 && llSubStringIndex(curline, "sloodlecontrollerid") == 0) {
                    list parts = llParseStringKeepNulls(curline, ["|"], []);
                    if (llGetListLength(parts) > 1) sloodlecontrollerid = (integer)llList2String(parts, 1);
                }
            
                // This should be "name|value" format, so just prefix it with "set:"
                cmd = "set:" + curline + "\n";
                cmdlen = llStringLength(cmd);
                // Ignore lengths of less than 5
                if (cmdlen >= 5) {
                    // If the addition of this command will overflow the buffer, then send the buffer first
                    if ((cmdbufferlength + cmdlen) > maxbufferlength) {
                        sloodle_tell_other_scripts(cmdbuffer);
                        cmdbuffer = "";
                        cmdbufferlength = 0;
                    }
                    // Add the current command to the buffer
                    cmdbuffer += cmd;
                    cmdbufferlength += cmdlen;
                }
            }
            
            // If there is anything left in the buffer, then send it
            if (cmdbufferlength > 0) {
                sloodle_tell_other_scripts(cmdbuffer);
                cmdbuffer = "";
                cmdbufferlength = 0;
            }
            
            // After a brief pause, send the EOF command
            llSleep(0.15);
            sloodle_tell_other_scripts(SLOODLE_EOF);
            
            // We're now finished
            state idle;
        }
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Ignore anything from this script
        if (sender_num == llGetLinkNumber()) return;
        
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
}


// In this state, the script has either finished, or been instructed not to execute
// It will only respond to a reset command
state idle
{
    state_entry()
    {
        // Listen for chat messages from the rezzer
        if (sloodlemyrezzer != NULL_KEY) llListen(SLOODLE_CHANNEL_OBJECT_DIALOG, "", NULL_KEY, "");
        
        // Regularly ping the server to notify it that this object is still 'alive'.
        // (But only if we have a valid controller id)
        llSetTimerEvent(0.0);
        if (sloodlecontrollerid > 0) llSetTimerEvent(PING_DELAY);
    }
    
    timer()
    {
        // Send our ping request and ignore the response
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodleobjuuid=" + (string)llGetKey();
        llHTTPRequest(sloodleserverroot + SLOODLE_PING_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    }
    
    listen(integer channel, string name, key id, string msg)
    {
        // Check the channel
        if (channel == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Parse the message
            list parts = llParseStringKeepNulls(msg, ["|"], []);
            if (llGetListLength(parts) < 2) return;
            string cmd = llList2String(parts, 0);
            string val = llList2String(parts, 1);
        
            // Is it a recognised command?
            if (cmd == "do:cleanup") {
                // Did it come from our rezzer?
                key kval = (key)val;
                if (kval == sloodlemyrezzer && kval != NULL_KEY) {
                    // Delete this object
                    sloodle_debug("Received CLEANUP command from object \"" + name + "\".");
                    llDie();
                    return;
                }
            }
        }
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Check the command type
            if (sval == "do:reset") {
                llResetScript();
                return;
            } else if (sval == "do:requestconfig") {
                // Send the configuration data again, so long as there isn't a notecard
                if (sloodle_has_config_notecard() == FALSE) {
                    request_config = TRUE;
                    state configure_object;
                } else {
                    state default;
                }
                return;
            } else if (sval == "do:reconfigure") {
                // Let the user re-configure from the start
                show_config_url = TRUE;
                state configure_object;
            }
        }
    }
    
    on_rez(integer param)
    {
        // Temporary measure: request the existing configuration.
        // (this allows a pre-configured object to be rezzed from inventory, assuming the active object entry has not yet expired)
        request_config = TRUE;
        state configure_object;
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: lsl/sloodle_setup_web.lsl 

// Sloodle Set object cleanup script.
// Sends a cleanup chat-message when touched.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield



///// DATA /////

integer SLOODLE_CHANNEL_AVATAR_RECYCLE_BIN_MENU = -1639270031;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_EOF = "sloodleeof";

integer SLOODLE_CHANNEL_OBJECT_CLEANUP_STARTING = -1639270085;

integer sloodleobjectaccessleveluse = 1; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object? 

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

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
    
    if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    else if (name == "do:reset") llResetScript();
    
    return TRUE; // None of the config is required
}

// Handle a batch of commands
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command_batch(string str)
{
    // Split the message into lines
    list lines = llParseString2List(str, ["\n"], []);
    integer numlines = llGetListLength(lines);
    // Process each line
    integer i;
    integer ret = FALSE;
    for (i=0; i < numlines; i++) {
        ret = sloodle_handle_command(llList2String(lines, i));
    }
    
    return ret;
}

// Checks if the given agent is permitted to user this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_use(key id)
{
    // Currently only the owner for this object
    return (id == llGetOwner());
}

// Checks if the given agent is permitted to control this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_ctrl(key id)
{
    // Currently only the owner for this object
    return (id == llGetOwner());
}


default
{
    state_entry()
    {
        sloodle_debug("Cleanup: default state");
        isconfigured = FALSE;
        eof = FALSE;
        // Reset our data
        sloodleobjectaccessleveluse = 0;
        sloodleobjectaccesslevelctrl = 0;
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Handle the commands
            isconfigured = sloodle_handle_command_batch(str);
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE && isconfigured == TRUE) {
                state ready;
            }
        } else if (num == SLOODLE_CHANNEL_SET_MENU_BUTTON_KILL_ALL) {
            // same as touch
            // Can the user use this object
            if (sloodle_check_access_use(id)) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "notconfiguredyet", [llKey2Name(id)], NULL_KEY, "");
            } else {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(id)], NULL_KEY, "");
            }
       }
    }
    
    touch_start(integer num_detected)
    {
        // Can the user use this object
        if (sloodle_check_access_use(llDetectedKey(0))) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "notconfiguredyet", [llDetectedName(0)], NULL_KEY, "");
        } else {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llDetectedName(0)], NULL_KEY, "");
        }
    }
}


// Ready to be used
state ready
{
    state_entry()
    {
        sloodle_debug("Cleanup: ready state");
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    touch_start(integer num_detected)
    {
        // Can the toucher use this?
        key id = llDetectedKey(0);
        if (!sloodle_check_access_use(id)) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(id)], NULL_KEY, "");
            return;
        }
        
        // Listen for the user's response to a dialog (after a set period of time, we'll cancel the listen)
        llListen(SLOODLE_CHANNEL_AVATAR_RECYCLE_BIN_MENU, "", llDetectedKey(0), "1");
        llSetTimerEvent(10.0);
        // Display a confirmation dialog
        sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_RECYCLE_BIN_MENU, "0", "1"], "confirmclearup", ["0", "1"], llDetectedKey(0), "set");
    }
        
    listen(integer channel, string name, key id, string msg)
    {
        // Only listen on the specified channel, for a particular message
        if (channel != SLOODLE_CHANNEL_AVATAR_RECYCLE_BIN_MENU || msg != "1") return;
        
        // Figure out the root key of this object
        key rootkey = llGetLinkKey(1);
        if (rootkey == NULL_KEY) rootkey = llGetLinkKey(0);        
        
        llSleep(4);
        llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CLEANUP_STARTING , "", NULL_KEY);
        
        // Send the cleanup command
        sloodle_debug("Sending cleanup command");
        llSay(SLOODLE_CHANNEL_OBJECT_DIALOG, "do:cleanup|" + (string)rootkey);
        
        // Cancel the listen
        state cancel_listen;
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        state cancel_listen;
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (num == SLOODLE_CHANNEL_SET_MENU_BUTTON_KILL_ALL) {
            if (!sloodle_check_access_use(id)) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(id)], NULL_KEY, "");
                return;
            }
        
            // Figure out the root key
            key rootkey = llGetLinkKey(1);
            if (rootkey == NULL_KEY) rootkey = llGetLinkKey(0);        
        
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CLEANUP_STARTING , "", NULL_KEY);
            llSleep(4);
                    
            // Send the cleanup command
            sloodle_debug("Sending cleanup command");
            llSay(SLOODLE_CHANNEL_OBJECT_DIALOG, "do:cleanup|" + (string)rootkey);
        }
    }
}

// Cancel listen events, and revert to the ready state.
// (Changing states stops all listens)
state cancel_listen
{
    state_entry()
    {
        state ready;
    }
    
    on_rez(integer par)
    {
        llResetScript();
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_cleanup_master.lsl 

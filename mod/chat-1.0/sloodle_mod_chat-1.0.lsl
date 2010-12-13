// Sloodle WebIntercom (for Sloodle 0.4)
// Links in-world SL (text) chat with a Moodle chatroom
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-8 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Paul Andrews
//  Daniel Livingstone
//  Jeremy Kemp
//  Edmund Edgar
//  Peter R. Bloomfield
//
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_CHAT_LINKER = "/mod/sloodle/mod/chat-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";

string SLOODLE_OBJECT_TYPE = "chat-1.0";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodlelistentoobjects = 0; // Should this object listen to other objects?
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
integer sloodleautodeactivate = 1; // Should the WebIntercom auto-deactivate when not in use?

string SoundFile = ""; // Sound file used for the beep
string MOODLE_NAME = "(SL)";
string MOODLE_NAME_OBJECT = "(SL-object)";

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

integer listenctrl = 0; // Listening for initial control... i.e. activation/deactivation
list cmddialog = []; // Alternating list of keys and timestamps, indicating who activated a command dialog (during logging) and when

list recordingkeys = []; // Keys of people we're recording
list recordingnames = []; // Names of people we're recording

key httpchat = NULL_KEY; // Request used to send/receive chat
integer message_id = 0; // ID of the last message received from Moodle

float sensorrange = 30.0; // Senses somewhat beyond chat range
float sensorrate = 60.0; // Scan every minute
integer nosensorcount = 0; // How many recent sensor sweeps (while logging) have detected no avatars?
integer nosensormax = 2; // How many failed sensor sweeps should we allow before auto-deactivating?


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
    else if (name == "set:sloodlelistentoobjects") sloodlelistentoobjects = (integer)value1;
    else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
    else if (name == "set:sloodleautodeactivate") sloodleautodeactivate = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0 && sloodlemoduleid > 0);
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

// Start recording the specified agent
sloodle_start_recording_agent(key id)
{
    // Do nothing if the person is already on the list
    if (llListFindList(recordingkeys, [id]) >= 0) {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:alreadyrecording", [llKey2Name(id)], NULL_KEY, "webintercom");
        return;
    }
    
    // Add the key and name to the lists
    recordingkeys += [id];
    recordingnames += [llKey2Name(id)];
    
    // Announce the update
    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:startedrecording", [llKey2Name(id)], NULL_KEY, "webintercom");
    sloodle_update_hover_text();
    
    // Inform the Moodle chatroom
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
    body += "&sloodleuuid=" + (string)llGetKey();
    body += "&sloodleavname=" + llEscapeURL(llGetObjectName());
    body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
    body += "&sloodleisobject=true&message=" + MOODLE_NAME_OBJECT + " " + llKey2Name(id) + " has entered this chat";
    
    httpchat = llHTTPRequest(sloodleserverroot + SLOODLE_CHAT_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
}

// Stop recording the specified agent
sloodle_stop_recording_agent(key id)
{
    // Do nothing if the person is not already on the list
    integer pos = llListFindList(recordingkeys, [id]);
    if (pos < 0) {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:notrecording", [llKey2Name(id)], NULL_KEY, "webintercom");
        return;
    }
    
    // Remove the key and name from the list
    recordingkeys = llDeleteSubList(recordingkeys, pos, pos);
    recordingnames = llDeleteSubList(recordingnames, pos, pos);
    
    // Announce the update
    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:stoppedrecording", [llKey2Name(id)], NULL_KEY, "webintercom");
    sloodle_update_hover_text();
    
    // Inform the Moodle chatroom
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
    body += "&sloodleuuid=" + (string)llGetKey();
    body += "&sloodleavname=" + llEscapeURL(llGetObjectName());
    body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
    body += "&sloodleisobject=true&message=" + MOODLE_NAME_OBJECT + " " + llKey2Name(id) + " has left this chat";
    
    httpchat = llHTTPRequest(sloodleserverroot + SLOODLE_CHAT_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
}

// Is the specified agent currently being recorded?
// Returns TRUE if so, or FALSE otherwise
integer sloodle_is_recording_agent(key id)
{
    return (llListFindList(recordingkeys, [id]) >= 0);
}

// Update the hover text while logging
sloodle_update_hover_text()
{
    string recordlist = llDumpList2String(recordingnames, "\n");
    if (recordlist == "") recordlist = "-";
    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0, 0.2, 0.2>, 1.0], "webintercom:recording", [recordlist], NULL_KEY, "webintercom");
}


// Default state - waiting for configuration
default
{
    state_entry()
    {
        // Set the texture on the sides to indicate we're deactivated
        llSetTexture("sloodle_chat_off",ALL_SIDES);
        // Starting again with a new configuration
        llSetText("", <0.0,0.0,0.0>, 0.0);
        isconfigured = FALSE;
        eof = FALSE;
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        sloodlemoduleid = 0;
        sloodlelistentoobjects = 0;
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
        llSetTimerEvent(0);
        // Set the texture on the sides to indicate we're deactivated
        llSetTexture("sloodle_chat_off",ALL_SIDES);
        // Reset the list of recorded keys and names
        recordingkeys = [];
        recordingnames = [];
        cmddialog = [];

        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0, 1.0, 1.0>, 1.0], "off", [], NULL_KEY, "");
        // Determine our "beep" sound file name
        SoundFile = llGetInventoryName(INVENTORY_SOUND, 0);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
        
    touch_start( integer total_number)
    {
        // Activating this requires access permission
        if (sloodle_check_access_ctrl(llDetectedKey(0)) == FALSE) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:ctrl", [llDetectedName(0)], NULL_KEY, "");
            return;
        }
    
        llListenRemove(listenctrl);
        listenctrl = llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", llDetectedKey(0), "");
        sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG, "0", "1"], "webintercom:ctrlmenu", ["0", "1"], llDetectedKey(0), "webintercom");
        llSetTimerEvent(10.0);
    }
    
    listen( integer channel, string name, key id, string message)
    {
        // Check the channel
        if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG) {
            // Check access to this object
            if (sloodle_check_access_ctrl(id) == FALSE) return;
    
            // Has chat logging been activated?
            if (message == "1") {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:chatloggingon", [llDetectedName(0)], NULL_KEY, "webintercom");
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:joinchat", [sloodleserverroot + "/mod/chat/view.php?id="+(string)sloodlemoduleid], NULL_KEY, "webintercom");
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:touchtorecord", [], NULL_KEY, "webintercom");
                
                // Initially record the one who activated us
                recordingkeys = [id];
                recordingnames = [name];
                
                state logging;
                return;
            }
        }
    }

    timer()
    {
        // Cancel the control listen 
        llSetTimerEvent(0.0);
        llListenRemove(listenctrl);
    }
    
}

state logging
{
    on_rez( integer param)
    {
        state default;
    }
    
    state_entry()
    {
        // Udpate the texture on the side to indicate we're logging
        llSetTexture("sloodle_chat_on",ALL_SIDES);
        // Listen for chat and commands
        llListen(0,"",NULL_KEY,"");
        llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", NULL_KEY, "");
        
        // Update our caption indicating whom we're recording
        sloodle_update_hover_text();
        // Regularly update the chat history and purge our list of command dialogs
        llSetTimerEvent(12.0);
        
        // Perform a regular scan to see if the WebIntercom has been abandoned
        if (sloodleautodeactivate != 0) {
            llSensorRepeat("", NULL_KEY, AGENT, sensorrange, PI, sensorrate);
        }
        nosensorcount = 0;
        
        // Inform the Moodle chatroom
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        body += "&sloodleuuid=" + (string)llGetKey();
        body += "&sloodleavname=" + llEscapeURL(llGetObjectName());
        body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
        body += "&sloodleisobject=true&message=" + MOODLE_NAME_OBJECT + " " + llList2String(recordingnames, 0) + " has activated this WebIntercom";
        
        httpchat = llHTTPRequest(sloodleserverroot + SLOODLE_CHAT_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    }
    
    state_exit()
    {
        // Inform the Moodle chatroom
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        body += "&sloodleuuid=" + (string)llGetKey();
        body += "&sloodleavname=" + llEscapeURL(llGetObjectName());
        body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
        body += "&sloodleisobject=true&message=" + MOODLE_NAME_OBJECT + " WebIntercom deactivated";
        
        httpchat = llHTTPRequest(sloodleserverroot + SLOODLE_CHAT_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    }
    
    touch_start( integer total_number)
    {
        key id = llDetectedKey(0);
        // Determine what this user can do
        integer canctrl = sloodle_check_access_ctrl(id);
        integer canuse = sloodle_check_access_use(id);
        
        // Can the agent control AND use this item?
        if (canctrl) {
            sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG, "0", "1", "2","cmd"], "webintercom:usectrlmenu", ["0", "1", "2","cmd"], id, "webintercom");
            sloodle_add_cmd_dialog(id);
        } else if (canuse) {
            sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG, "0", "1","2"], "webintercom:usemenu", ["0", "1","2"], id, "webintercom");
            sloodle_add_cmd_dialog(id);
        } else {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(id)], NULL_KEY, "webintercom");
        }
    }
    
    listen( integer channel, string name, key id, string message)
    {
        // Check the channel
        if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG) {
            // Ignore this person if they are not on the list
            if (llListFindList(cmddialog, [id]) < 0) return;
            sloodle_remove_cmd_dialog(id);
            
            // Find out what the user can do
            integer canctrl = sloodle_check_access_ctrl(id);
            integer canuse = sloodle_check_access_use(id);
            
            // Check what the command is
            if (message == "0") {
                // Make sure the user can use this
                if (!(canctrl || canuse)) return;
                // Stop recording the user
                sloodle_stop_recording_agent(id);
                
            } else if (message == "1") {
                // Make sure the user can use this
                if (!(canctrl || canuse)) return;
                // Start recording the user
                sloodle_start_recording_agent(id);
                
            } else if (message == "cmd") {
                // Make sure the user can control this 
                if (!canctrl) return;                
                  sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:enterchatroom", [sloodleserverroot + "/mod/chat/view.php?id="+(string)sloodlemoduleid], NULL_KEY, "webintercom");                
            } else if (message == "2") {
                // Make sure the user can use this
                if (!(canctrl || canuse)) return;
                // Display chatroom
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [id], "webintercom:anouncechatroom", [sloodleserverroot + "/mod/chat/view.php?id="+(string)sloodlemoduleid], id, "webintercom");
                state ready;
                
            }           
        } else if (channel == 0) {
            // Is this an avatar?
            integer isavatar = FALSE;
            if (llGetOwnerKey(id) == id) {
                // Yes - check that we are listening to them
                if (!sloodle_is_recording_agent(id)) return;
                isavatar = TRUE;
            } else {
                // No - it is an object - ignore it if necessary
                if (sloodlelistentoobjects == 0) return;
            }
            
            // Is this a SLurl command?
            if(message == "/slurl")     {        
                string region = llEscapeURL(llGetRegionName());
                vector vec = llGetPos();
                string posX = (string)((integer)vec.x);
                string posY = (string)((integer)vec.y);
                string posZ = (string)((integer)vec.z);
                // Replace the message with a SLurl
                message = "http://slurl.com/secondlife/" + region + "/" + posX + "/" + posY + "/" + posZ + "/?title=" + region;
            }
            
            // Send the request as POST data
            string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
            body += "&sloodlepwd=" + sloodlepwd;
            body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
            body += "&sloodleuuid=" + (string)id;
            body += "&sloodleavname=" + llEscapeURL(name);
            body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
            if (isavatar) body += "&message=" + MOODLE_NAME + " ";
            else body += "&sloodleisobject=true&message=" + MOODLE_NAME_OBJECT + " ";
            body += name + ": " + message;
            
            httpchat = llHTTPRequest(sloodleserverroot + SLOODLE_CHAT_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        }
    }
    
    timer()
    {
        // Get updated chat from Moodle
        if (httpchat == NULL_KEY) {
            string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
            body += "&sloodlepwd=" + sloodlepwd;
            body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
            
            httpchat = llHTTPRequest(sloodleserverroot + SLOODLE_CHAT_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        }
        
        // Purge any expired command dialogs
        sloodle_purge_cmd_dialog();
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Is this the expected data?
        if (id != httpchat) return;
        httpchat = NULL_KEY;
        // Make sure the request worked
        if (status != 200) {
            sloodle_debug("Failed HTTP response. Status: " + (string)status);
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            return;
        }

        // Make sure there is a body to the request
        if (llStringLength(body) == 0) return;
        // Debug output:
        sloodle_debug("Receiving chat data:\n" + body);
        
        // Split the data up into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);  
        integer numlines = llGetListLength(lines);
        // Extract all the status fields
        list statusfields = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
        // Get the statuscode
        integer statuscode = llList2Integer(statusfields,0);
        
        // Was it an error code?
        if (statuscode <= 0) {
            
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            // Do we have an error message to go with it?
            string msg = "ERROR: linker script responded with status code " + (string)statuscode;
            if (numlines > 1) {
                msg += "\n" + llList2String(lines,1);
            }
            sloodle_debug(msg);
            return;
        }
        
        // We will use these to store each item of data
        integer msgnum = 0;
        string name = "";
        string text = "";
        
        // Every other line should define a chat message "id|name|text"
        // Start at the line after the status line
        integer i = 1;
        for (i = (numlines - 1); i > 0; i--) {
            // Get all the different fields for this line
            list fields = llParseStringKeepNulls(llList2String(lines,i),["|"],[]);
            // Make sure we have enough fields
            if (llGetListLength(fields) >= 3) {
                // Extract each item of data
                msgnum = llList2Integer(fields,0);
                name = llList2String(fields,1);
                text = llList2String(fields,2);
                
                // Make sure this is a new message
                if (msgnum > message_id) {
                    message_id = msgnum;
                    // Make sure this wasn't an SL message originally
                    if (llSubStringIndex(text, MOODLE_NAME) != 0 && llSubStringIndex(text, MOODLE_NAME_OBJECT) != 0) {
                        // Is this a Moodle beep?
                        if (llSubStringIndex(text, "beep ") == 0) {
                            // Yes - play a beep sound
                            llStopSound();
                            if (SoundFile == "") 
                            { // There is no sound file in inventory - plsy default
                                llPlaySound("34b0b9d8-306a-4930-b4cd-0299959bb9f4", 1.0);
                            } else { // Play the included one
                                llPlaySound(SoundFile, 1.0);
                            }
                        }
                        // Finally... just an ordinary chat message... output it
                        llSay(0, name + ": " + text);
                    }
                }
            }
        }
    }
    
    sensor(integer num_detected)
    {
        // Nearby avatars have been detected
        nosensorcount = 0;
    }
    
    no_sensor()
    {
        // Ignore this if auto-deactivation has been disabled
        if (sloodleautodeactivate == 0) return;
    
        // No nearby avatars detected.
        // Is the object attached to an avatar? (Sensors won't detect the avatar the object is attached to)
        if (llGetAttached() > 0) {
            // Yes - treat it as though avatars have been detected
            nosensorcount = 0;
        } else {
            // No  - increment our count of failed scans
            nosensorcount++;
            // Is it time to deactivate?
            if (nosensorcount >= nosensormax) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "webintercom:autodeactivate", [], NULL_KEY, "webintercom");
                state ready;
                return;
            }
        }
    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/chat-1.0/sloodle_mod_chat-1.0.lsl 

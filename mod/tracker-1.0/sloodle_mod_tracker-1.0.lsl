// This file is part of SLOODLE Tracker.
// Copyright (c) 2009-11 Sloodle community (various contributors)
    
// SLOODLE Tracker is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
    
// SLOODLE Tracker is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License.
// If not, see <http://www.gnu.org/licenses/>
//
// Contributors:
// Peter R. Bloomfield  
// Julio Lopez (SL: Julio Solo)
// Michael Callaghan (SL: HarmonyHill Allen)
// Kerri McCusker  (SL: Kerri Macchi)

// A project developed by the Serious Games and Virtual Worlds Group.
// Intelligent Systems Research Centre.
// University of Ulster, Magee    


// IN-WORLD CONFIGURATION //    

string NAME = "Unnamed task";
string DESCRIPTION = "-";
    
integer PREDEFINED_ORDER = 0;  // Does the task have to be done in a specific order? 0 -> NO, 1 -> YES
integer POSITION = 0; // Position of the task in the pre-defined sequence
integer TOTAL = 0;  // Number of tasks in the assignment

// END IN-WORLD CONFIGURATION //



integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_TRACKER_LINKER = "/mod/sloodle/mod/tracker-1.0/linker.php";
string SLOODLE_TOOL_LINKER = "/mod/sloodle/mod/tracker-1.0/auth_tool_linker.php";
string SLOODLE_EOF = "sloodleeof";

integer CHANNEL = 447851; // Channel for the tasks to comunicate   
string SLOODLE_OBJECT_TYPE = "tracker-1.0";    

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = "";    
string sloodlepwd = "";   
integer sloodlecontrollerid = 0;    
integer sloodlemoduleid = 0;    
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
integer sloodleautodeactivate = 1; // Should the WebIntercom auto-deactivate when not in use?

list allowed = [];  // List of avatars who have completed the previous task

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httpinteraction = NULL_KEY; // Request used to send interaction
key httpreg = NULL_KEY; // Request used to register Tracker tool

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

// Has the current avatar completed the previous task?
integer isAllowed(key k) {

    return (llListFindList(allowed,[k])>=0);
    
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



// Default state - waiting for configuration
default
{
    state_entry()
    {
         
        // Starting again with a new configuration
        llSetText("", <0.0,0.0,0.0>, 0.0);
        isconfigured = FALSE;
        eof = FALSE;
        allowed = [];
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        sloodlemoduleid = 0;
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
            for (i = 0; i < numlines; i++)
            {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                    llSleep(2.0);
                    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
                    body += "&sloodlepwd=" + sloodlepwd;
                    body += "&sloodleobjuuid="+(string)llGetKey();
                    body += "&sloodleobjname="+llGetObjectName();
                    body += "&sloodleobjtype="+SLOODLE_OBJECT_TYPE;
                    body += "&sloodlemoduleid="+(string)sloodlemoduleid;
                    body += "&sloodledescription="+DESCRIPTION;
                    body += "&sloodletaskname="+NAME;
                    httpreg = llHTTPRequest(sloodleserverroot + SLOODLE_TOOL_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
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
    
    state_entry()
    {
        llListen(CHANNEL, "", NULL_KEY, "");
    }

    listen(integer channel, string name, key id, string msg)
    {
        // Is the message in the correct channel?
        if (channel == CHANNEL)
        {
            // Ignore anything from a different owner
            if (llGetOwnerKey(id) != llGetOwner()) return;
        
            // Get the different parts of the message
            list elements = llParseStringKeepNulls(msg,["|"],[]);
            if (llGetListLength(elements) < 3) return;
            
            // Ignore anything attached to a different module ID
            integer incomingModuleID = (integer)llList2String(elements, 2);
            if (incomingModuleID != sloodlemoduleid) return;
            
            // If the message cames from the previous task, insert the avatar UUID in the list so we know they are allowed to continue
            if ((integer)llList2String(elements,0) == (POSITION-1))
            {
                allowed += [llList2Key(elements,1)];
            }
        }
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        //llOwnerSay("link message (" + (string)num + "):\n" + sval + "\nKey: " + (string)kval);
    
        // Was this a tracker message?
        if (num == CHANNEL)
        {
            // Another script is informing us that an interaction has taken place
            // e.g. a button click or a scanner
        
            // Extract incoming data
            key id_avatar = kval;
            string name_avatar = llKey2Name(id_avatar);
            list fields = llParseStringKeepNulls(sval, ["|"], []);
            integer numfields = llGetListLength(fields);
            // Make sure it was an incoming interaction message
            if (llList2String(fields, 0) != "INTERACTION") return;
            string type = llList2String(fields, 1);
            integer suppressOrderWarning = FALSE;
            if (numfields >= 3)
            {
                suppressOrderWarning = ((integer)llList2String(fields, 2)) != 0;
            }
            
            // If there is a predefined order and the avatar has not completed the previous task
            // he can't complete the current task
            if (PREDEFINED_ORDER && suppressOrderWarning == FALSE && !(isAllowed(id_avatar)) && (POSITION > 2))
            {
                llSay(0, name_avatar + ", please make sure you have completed the previous task, or make sure you have not completed this task already.");
            } else {
            
                // We can remove this person from the allowed list
                integer pos = llListFindList(allowed, [id_avatar]);
                if (pos >= 0) allowed = llDeleteSubList(allowed, pos, pos);
                
                // If the current task is not the last one, the next task is notified
                if (POSITION < TOTAL)
                {
                    string msg = (string)POSITION;
                    msg += "|"+(string)id_avatar+"|"+(string)sloodlemoduleid; 
                    llSay(CHANNEL, msg);
                }
                
                // Send a response message back to the tool to indicate that the interaction was processed
                llMessageLinked(LINK_THIS, CHANNEL, "INTERACTION_RESPONSE", id_avatar);
                
                // Notify Moodle of the interaction
                key id_object = llGetKey();      
                string body = "sloodlemoduleid=" + (string)sloodlemoduleid;
                body += "&sloodlecontrollerid=" + (string)sloodlecontrollerid;
                body += "&sloodlepwd=" + (string)sloodlepwd;
                body += "&sloodleobjuuid=" + (string) id_object;
                body += "&sloodleuuid=" + (string) id_avatar;
                body += "&sloodleavname=" + name_avatar;
                body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
                httpinteraction = llHTTPRequest(sloodleserverroot + SLOODLE_TRACKER_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
                llSleep(1.0);            
            }    
        }
    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/tracker-1.0/sloodle_mod_tracker-1.0.lsl


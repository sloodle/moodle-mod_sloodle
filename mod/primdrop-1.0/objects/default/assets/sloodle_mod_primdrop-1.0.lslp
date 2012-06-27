//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle PrimDrop (for Sloodle 0.3)
// Allows students to submit SL objects as Moodle assignments.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Jeremy Kemp
//  Peter R. Bloomfield
//  Paul Preibisch (Fire Centaur in SL)


/// DATA ///

// Sloodle constants
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_PRIMDROP_LINKER = "/mod/sloodle/mod/primdrop-1.0/linker.php";
string SLOODLE_ASSIGNMENT_VIEW = "/mod/assignment/view.php";
string SLOODLE_EOF = "sloodleeof";
integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string SLOODLE_OBJECT_TYPE = "primdrop-1.0";


integer SLOODLE_CHANNEL_PRIMDROP_INVENTORY = -1639270071;
string PRIMDROP_RECEIVE_DROP = "do:receivedrop"; // Instructs the object to receive a drop
string PRIMDROP_CANCEL_DROP = "do:canceldrop"; // Cancel drop receiving
string PRIMDROP_FINISHED_DROP = "set:droppedobject"; // The drop has finished (object name passed as parameter after pipe character)


// Configuration settings
string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)

// Configuration status
integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

// This defines who is currently dropping or rezzing an item
key current_user = NULL_KEY;

// These lists are used when determining what inventory has been added
list old_inventory = [];
list new_inventory = [];
// The name of the object which is being submitted
string submit_obj = "";

// HTTP request keys
key httpcheck = NULL_KEY; // Request used to check the assignment
key httpsubmit = NULL_KEY; // Request used to submit objects

// Assignment information
string assignmentname = "";
string assignmentsummary = "";

// Alternating list of keys, timestamps and page numbers, indicating who activated a dialog and when
list cmddialog = [];

// Menu button labels
string MENU_BUTTON_CANCEL = "0";
string MENU_BUTTON_SUMMARY = "1";
string MENU_BUTTON_SUBMIT = "2";
string MENU_BUTTON_ONLINE = "3";
string MENU_BUTTON_TAKE_ALL = "4";

// List of button labels ('cos otherwise the compiler runs out of memory!)
//list teacherbuttons = [MENU_BUTTON_SUBMIT, MENU_BUTTON_ONLINE,  MENU_BUTTON_TAKE_ALL,MENU_BUTTON_CANCEL, MENU_BUTTON_SUMMARY];
 // OpenSim chokes on this
list teacherbuttons = ["3", "2",  "4", "0", "1"];
//list userbuttons = [MENU_BUTTON_SUMMARY, MENU_BUTTON_SUBMIT,MENU_BUTTON_ONLINE,MENU_BUTTON_CANCEL];
list userbuttons = ["1", "2",  "3", "0"];

// The relative position at which items will be rezzed
vector rez_pos = <0.0, 2.0, 1.0>;

///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;

// Translation output methods
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
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


/// FUNCTIONS ///
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
    llSetText("", <0.0,0.0,0.0>, 0.0);
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
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
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

// Does the object have valid permissions?
// Returns TRUE if so, or FALSE otherwise
integer valid_perms(string obj)
{
    integer perms_owner = llGetInventoryPermMask(obj, MASK_OWNER);
    integer perms_next = llGetInventoryPermMask(obj, MASK_NEXT);
    
    return (!((perms_owner & PERM_COPY) && (perms_owner & PERM_TRANSFER) && (perms_next & PERM_COPY) && (perms_next & PERM_TRANSFER)));
}

// Returns a list of all inventory
list get_inventory(integer type)
{
    list inv = [];
    integer num = llGetInventoryNumber(type);
    integer i = 0;
    for (i=0; i < num; i++) {
        if (llGetInventoryName(type, i)!="sloodle_config") //dont give away configuration files!
            inv += [llGetInventoryName(type, i)];
    }
    
    return inv;
}

// Checks and validates an inventory drop.
// Returns TRUE if it is OK, or FALSE if not.
integer sloodle_check_drop()
{
    // Our new object is stored in variable "submit_obj"
    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 0.9], "assignment:checkingitem", [], NULL_KEY, "assignment");
    
    // Make sure it exists
    if (llGetInventoryType(submit_obj) == INVENTORY_NONE || submit_obj == "") {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:submissionerror", [], NULL_KEY, "assignment");
        return FALSE;
    }
    
    // Make sure it is the correct type  
    // *** Fire Centaur Change January 2010
    //--- changed this to accept all objects EXCEPT scripts.
    //if (llGetInventoryType(submit_obj) == INVENTORY_OBJECT) {
    if (llGetInventoryType(submit_obj) == INVENTORY_SCRIPT) {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:objectsonly", [], NULL_KEY, "assignment");
        llRemoveInventory(submit_obj);
        return FALSE;
    }

    // Determine the object ID and creator
    key obj_id = llGetInventoryKey(submit_obj);
    key obj_creator = llGetInventoryCreator(submit_obj);
    
    // Make sure the creator is the expected user
    if (obj_creator != current_user) {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:creatoronly", [], NULL_KEY, "assignment");
        llRemoveInventory(submit_obj);
        return FALSE;
    }
    
    // Make sure the permissions are correct
    if (valid_perms(submit_obj)) {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:invalidperms", [], NULL_KEY, "assignment");
        llRemoveInventory(submit_obj);
        return FALSE;
    }

    // Seems OK - submit it
    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:itemok", [submit_obj, llKey2Name(current_user)], NULL_KEY, "assignment");
    return TRUE;
}


/// STATES ///

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
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                    state check_assignment;
                } else {
                    // Got all configuration but, it's not complete... request reconfiguration
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

// Checking that the assignment is accessible
state check_assignment
{
    state_entry()
    {
        // Check the assignment details
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.9], "assignment:checking", [], NULL_KEY, "assignment");
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        httpcheck = llHTTPRequest(sloodleserverroot + SLOODLE_PRIMDROP_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        
        llSetTimerEvent(0.0);
        llSetTimerEvent(8.0);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
        httpcheck = NULL_KEY;
        llSetText("", <0.0,0.0,0.0>, 0.0);
    }
    
    timer()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], NULL_KEY, "");
        sloodle_reset();
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Is this the expected data?
        if (id != httpcheck) return;
        httpcheck = NULL_KEY;
        // Check that we got a proper response
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httperror:code", [status], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            sloodle_reset();
            return;
        }
        if (body == "") {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httpempty", [], NULL_KEY, "");
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], NULL_KEY, "");
            sloodle_reset();
            return;
        }
        
        // Split the data up into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);  
        integer numlines = llGetListLength(lines);
        // Extract all the status fields
        list statusfields = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
        // Get the statuscode
        integer statuscode = llList2Integer(statusfields,0);
        
        // Was it an error code?
        if (statuscode == -601) {
            // Failed to connect to the assignment, possibly because it is the wrong type, or because it is invisible
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:connectionfailed", [], NULL_KEY, "assignment");
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], NULL_KEY, "");
            sloodle_reset();
            return;
            
        } else if (statuscode <= 0) {
            // Get the error message if one was given
            if (numlines > 1) {
                string errmsg = llList2String(lines, 1);
                sloodle_debug("ERROR " + (string)statuscode + ": " + errmsg);
            }
            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], NULL_KEY, "");
            sloodle_reset();
            return;
        }
        
        // Extract the assignment information
        assignmentname = llList2String(lines, 1);
        assignmentsummary = llList2String(lines, 2);
        llSay(0, assignmentsummary);
        
        state ready;
    }
    
    on_rez(integer param)
    {
        state default;
    }
}


// Ready to be used
state ready
{
    state_entry()
    {
        // Display summary information
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.5,0.0>, 1.0], "assignment:ready", [assignmentname], NULL_KEY, "assignment");
        
        // Listen for dialog commands from any avatar
        llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", NULL_KEY, "");
        
        // Regularly purge the list of dialog user entries
        llSetTimerEvent(0.0);
        llSetTimerEvent(12.0);
        
        // Clear our current user, to avoid any confusion
        current_user = NULL_KEY;
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
        llSetText("", <0.0,0.0,0.0>, 0.0);
    }
    
    touch_start(integer num_detected)
    {
        // Go through each toucher
        integer i = 0;
        key id = NULL_KEY;
        integer level = 0;
        for (i=0; i < num_detected; i++) {
            id = llDetectedKey(i);
            // Can this avatar use and/or control this item?
            if (sloodle_check_access_ctrl(id)) level = 2;
            else if (sloodle_check_access_use(id)) level = 1;
            // Show the appropriate menu, or report the lack of permission
            if (level == 2) {
                // Teacher menu
                sloodle_add_cmd_dialog(id);
                sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG] + teacherbuttons, "assignment:primdropteachermenu", [0,1,2,3,4], id, "assignment");
            } else if (level == 1) {
                // General user menu
                sloodle_add_cmd_dialog(id);
                sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG] + userbuttons, "assignment:primdropmenu", [0,1,2,3], id, "assignment");
            } else {
                // Report the lack of permission
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llDetectedName(i)], NULL_KEY, "");
            }
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        // Check the channel
        if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG) {
            // Ignore non-avatars
            if (llGetOwnerKey(id) != id) return;
            // Make sure we are listening to this user
            if (llListFindList(cmddialog, [id]) < 0) return;
            sloodle_remove_cmd_dialog(id);
            
            // Make sure the given user is allowed to use this object
            if (!sloodle_check_access_use(id)) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [name], NULL_KEY, "");
                return;
            }
            // Check if the user can control this item
            integer canctrl = sloodle_check_access_ctrl(id);
            
            // Store the user
            current_user = id;
            
            // Check the command            
            if (msg == MENU_BUTTON_CANCEL) {
                // Cancel the menu
                // Nothing to do
                return;
                
            } else if (msg == MENU_BUTTON_SUMMARY) {
                // Chat the assignment summary text
                llSay(0, assignmentsummary);
                
            } else if (msg == MENU_BUTTON_SUBMIT) {
                // Wait for a drop
                state drop;
            
            } else if (msg == MENU_BUTTON_ONLINE) {
                // Give the user a URL
                llLoadURL(id, assignmentname, sloodleserverroot + SLOODLE_ASSIGNMENT_VIEW + "?id=" + (string)sloodlemoduleid);
            
            } else if (msg == MENU_BUTTON_TAKE_ALL && canctrl) {
                // User wants to take all objects to their inventory
                list inv;
                inv+= get_inventory(INVENTORY_ANIMATION);
                inv+= get_inventory(INVENTORY_GESTURE);
                inv+= get_inventory(INVENTORY_LANDMARK);
                inv+= get_inventory(INVENTORY_NOTECARD);
                inv+= get_inventory(INVENTORY_OBJECT);
                
                
                if (inv == []) {
                    // No submissions available
                    sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "assignment:nosubmissions", [], id, "assignment");
                } else {
                    // Give all items into a new folder
                    llGiveInventoryList(id, assignmentname, inv);
                    sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "assignment:allgiven", [assignmentname], id, "assignment");
                }
            }
        }
    }
    
    on_rez(integer param)
    {
        state default;
    }
}

// Waiting for an object to be dropped
state drop
{
    state_entry()
    {
        // Instruct the inventory manager to receive a drop
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_PRIMDROP_INVENTORY, PRIMDROP_RECEIVE_DROP, NULL_KEY);
    
        // Prepare to receive a submission
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,0.5,1.0>, 1.0], "assignment:waitingforsubmission", [llKey2Name(current_user)], NULL_KEY, "assignment");
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:dropsubmission", [llKey2Name(current_user)], NULL_KEY, "assignment");
        
        // Allow the user 60 seconds to make their submission
        llSetTimerEvent(0.0);
        llSetTimerEvent(60.0);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        // Submission timed-out
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:submittimeout", [llKey2Name(current_user)], NULL_KEY, "assignment");
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_PRIMDROP_INVENTORY, PRIMDROP_CANCEL_DROP, NULL_KEY);
        state ready;
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_PRIMDROP_INVENTORY) {
            // Split the message
            list parts = llParseStringKeepNulls(sval, ["|"], []);
            if (llGetListLength(parts) < 2) return;
            string cmd = llList2String(parts, 0);
            string val = llList2String(parts, 1);
            // Check the command
            if (cmd == PRIMDROP_FINISHED_DROP) {
                // Cancel the timeout
                llSetTimerEvent(0.0);
                // Store the submitted object and check it
                submit_obj = val;
                if (sloodle_check_drop()) state submitting;
                else state ready;
            }
        }
    }
    
    on_rez(integer param)
    {
        state default;
    }
}

// Submitting an object which was dropped
state submitting
{
    state_entry()
    {
        if (submit_obj == "") {
            llSay(0, "ERROR: no object to submit.");
            state ready;
            return;
        }
        
        // Check the assignment details
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 0.9], "assignment:submitting", [llKey2Name(current_user)], NULL_KEY, "assignment");
        
        // Build the body of data
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        body += "&sloodleuuid=" + (string)current_user;
        body += "&sloodleavname=" + llEscapeURL(llKey2Name(current_user));
        body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
        body += "&sloodleobjname=" + submit_obj;
        body += "&sloodleprimcount=" + (string)llGetObjectPrimCount(llGetInventoryKey(submit_obj));
        body += "&sloodleprimdropname=" + llGetObjectName();
        body += "&sloodleprimdropuuid=" + (string)llGetKey();
        body += "&sloodleregion=" + llGetRegionName();
        body += "&sloodlepos=" + (string)llGetPos();
        // Send the HTTP request
        httpsubmit = llHTTPRequest(sloodleserverroot + SLOODLE_PRIMDROP_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        llSetTimerEvent(0.0);
        llSetTimerEvent(8.0);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
        httpsubmit = NULL_KEY;
        llSetText("", <0.0,0.0,0.0>, 0.0);
    }
    
    timer()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
        state ready;
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Is this the expected data?
        if (id != httpsubmit) return;
        httpsubmit = NULL_KEY;
        // Check that we got a proper response
        if (status != 200) {
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            state ready;
            return;
        }
        if (body == "") {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httpempty", [], NULL_KEY, "");
            state ready;
            return;
        }
        
        // Split the data up into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);  
        integer numlines = llGetListLength(lines);
        // Extract all the status fields
        list statusfields = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
        integer statuscode = llList2Integer(statusfields,0);
        
        // Get the user's name
        string current_user_name = llKey2Name(current_user);
        
        // Has an error been reported?
        if (statuscode < 0) {
            // Check if it's a known code
            if (statuscode == -10201)       sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:nopermission", [current_user_name], NULL_KEY, "assignment");
            else if (statuscode == -10202)  sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:early", [current_user_name], NULL_KEY, "assignment");
            else if (statuscode == -10203)  sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:late", [current_user_name], NULL_KEY, "assignment");
            else if (statuscode == -10205)  sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:noresubmit", [current_user_name], NULL_KEY, "assignment");
            else {
                 sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:submissionfailed", [current_user_name, statuscode], NULL_KEY, "assignment");
                 sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            }
            
            // Debug output, if possible
            if (numlines > 1) {
                string errmsg = llList2String(lines, 1);
                sloodle_debug("ERROR " + (string)statuscode + ": " + errmsg);
            }
            
            state ready;
            return;
        }
        
        // Success
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "assignment:submissionok", [current_user_name], NULL_KEY, "assignment");        
        state ready;
    }
    
    on_rez(integer param)
    {
        state default;
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/primdrop-1.0/objects/default/assets/sloodle_mod_primdrop-1.0.lslp 


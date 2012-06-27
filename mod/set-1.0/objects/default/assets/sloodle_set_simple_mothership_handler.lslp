//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Set Mothership Handler
// Rezzes and controls the rezzer as a seperate object
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield

integer SLOODLE_OBJECT_CREATOR_TYPE_BASIC_SET = 0;
integer SLOODLE_OBJECT_CREATOR_TYPE_MOTHERSHIP = 1;

vector SLOODLE_OBJECT_CREATOR_REZ_OFFSET_BASIC_SET = <0.0, 2.5, 0.0>; // The basic set rezzes things 2 meters in front of it
vector SLOODLE_OBJECT_CREATOR_REZ_OFFSET_MOTHERSHIP = <0.0, 0.0, -2.0>; // The mothership rezzes things 2 meters below it

integer SLOODLE_THIS_OBJECT_TYPE = SLOODLE_OBJECT_CREATOR_TYPE_BASIC_SET;
//integer SLOODLE_THIS_OBJECT_TYPE = SLOODLE_OBJECT_CREATOR_TYPE_MOTHERSHIP;

integer SLOODLE_CHANNEL_SET_LAYOUT_REZZER_SHOW_DIALOG = -1639270094;
integer SLOODLE_CHANNEL_SET_LAYOUT_REZZER_PING = -1639270095;


///// DATA /////

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343 ;
integer SLOODLE_CHANNEL_AVATAR_DIALOG_OBJECT_REZZER = -1639270033 ;
string SLOODLE_AUTH_LINKER = "/mod/sloodle/classroom/auth_object_linker.php"; 
string SLOODLE_EOF = "sloodleeof";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = ""; 
string sloodlepwd = "";
integer sloodlecontrollerid = 0; 
string sloodlecoursename_full = "";
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httpcheckcourse = NULL_KEY;
list cmddialog = []; // Alternating list of keys, timestamps and page numbers, indicating who activated a dialog, when, and which page they are on
list inventory = []; // A list of names of inventory items available for rezzing (copyable objects)

list autorez_names = []; // List of names of items to autorez
list autorez_pos = []; // Autorez positions
list autorez_rot = []; // Autorez rotations
list autorez_layout_entry_id = []; // Autorez layout entry ids
string autorez_layout_name = ""; // Name of layout being rezzed

string MENU_BUTTON_PREVIOUS = "<<";
string MENU_BUTTON_NEXT = ">>";

key mothership_uuid;

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

integer SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_FINISHED = -1639270083;

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

// Generate a random integer password
integer sloodle_random_password()
{
    return (100000 + (integer)llFrand(999899999.0));
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
    if (name == "set:sloodlecoursename_full") sloodlecoursename_full = value1;
    else if (name == "set:sloodlepwd") {
        // The password may be a single prim password, or a UUID and a password
        if (value2 != "") sloodlepwd = value1 + "|" + value2;
        else sloodlepwd = value1;
        
    } else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
    else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    else if (name == "do:reset") llResetScript();
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0);
}

// Checks if the given agent is permitted to control this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_ctrl(key id)
{
    // Only the owner can control this
    return (id == llGetOwner());
}

// Checks if the given agent is permitted to user this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_use(key id)
{
    // The owner can always use this
    if (id == llGetOwner()) return TRUE;
    
    // Check the access mode
    if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_GROUP) {
        return llSameGroup(id);
    } else if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC) {
        return TRUE;
    }
    return FALSE;
}

// Add the given agent to our command dialog list
sloodle_add_cmd_dialog(key id, integer page) 
{
    // Does the person already exist?
    integer pos = llListFindList(cmddialog, [id]);
    if (pos < 0) {
        // No - add the agent to the end
        cmddialog += [id, llGetUnixTime(), page];
    } else {
        // Yes - update the time
        cmddialog = llListReplaceList(cmddialog, [llGetUnixTime(), page], pos + 1, pos + 2);
    }
}

// Get the number of the page the current user is on in the dialogs
// (Returns 0 if they are not found)
integer sloodle_get_cmd_dialog_page(key id)
{
    // Does the person exist in the list?
    integer pos = llListFindList(cmddialog, [id]);
    if (pos >= 0) {
        // Yes - get the page number
        return llList2Integer(cmddialog, pos + 2);
    }
    return 0;
}

// Remove the given agent from our command dialog list
sloodle_remove_cmd_dialog(key id)
{
    // Is the person in the list?
    integer pos = llListFindList(cmddialog, [id]);
    if (pos >= 0) {
        // Yes - remove them and their timestamp
        cmddialog = llDeleteSubList(cmddialog, pos, pos + 2);
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
        // Is the current timestamp more than 24 seconds old?
        if ((curtime - llList2Integer(cmddialog, i + 1)) > 24) {
            // Yes - remove it
            cmddialog = llDeleteSubList(cmddialog, i, i + 2);
        } else {
            // No - advance to the next
            i += 3;
        }
    }
}


// Shows the given user a dialog of objects, starting at the specified page
sloodle_show_object_dialog(key id, integer page)
{
    // Each dialog can display 12 buttons
    // However, we'll reserve the top row (buttons 10, 11, 12) for the next/previous buttons.
    // This leaves use with 9 others.

    // Check how many objects we have
    integer numobjects = llGetListLength(inventory);
    if (numobjects == 0) {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "sloodleset:noobjects", [llKey2Name(id)], NULL_KEY, "set");
        return;
    }
    
    // How many pages are there?
    integer numpages = (integer)((float)numobjects / 9.0) + 1;
    // If the requested page number is invalid, then cap it
    if (page < 0) page == 0;
    else if (page >= numpages) page = numpages - 1;
    
    // Build our list of item buttons (up to a maximum of 9)
    list buttonlabels = [];
    string buttondef = ""; // Indicates which button does what
    integer numbuttons = 0;
    integer itemnum = 0;
    for (itemnum = page * 9; itemnum < numobjects && numbuttons < 9; itemnum++, numbuttons++) {
        // Add the button label (a number) and button definition
        buttonlabels += [(string)(itemnum + 1)]; // Button labels are 1-based
        buttondef += (string)(itemnum + 1) + " = " + llList2String(inventory, itemnum) + "\n";
    }
    
    // Add our page buttons if necessary
    if (page > 0) buttonlabels += [MENU_BUTTON_PREVIOUS];
    if (page < (numpages - 1)) buttonlabels += [MENU_BUTTON_NEXT];
    
    // Display the basic object menu
    sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG_OBJECT_REZZER] + buttonlabels, "sloodleset:objectmenu", [buttondef], id, "set");
}


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
        sloodlecoursename_full = "";
        sloodleobjectaccessleveluse = 0;
        sloodleserveraccesslevel = 0;

    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i;
            for (i=0 ; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE && isconfigured == TRUE) {
                state ready;
            }
        }  
    }
}

state ready {

    state_entry() {
        mothership_uuid = NULL_KEY;    
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is this a reset command?
            if (str == "do:reset") {
                llResetScript();
                return;
            } 
        } else if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_FINISHED) {
            mothership_uuid = id;
        }
       
    }
    
    touch_start(integer total_number)
    {
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:rez\n\nSLOODLE Mothership|<0.5, 2.0, 0.0>|<0.0, 0.0, 0.0, 1>|0", NULL_KEY);
        state rezzed_one;
    }
    
}

state rezzed_one {
    
    // Expect a ping every 60 seconds from the rezzed mothership
    state_entry() {
        llListen( SLOODLE_CHANNEL_SET_LAYOUT_REZZER_PING , "", NULL_KEY, (string)llGetOwner() );
    }

    listen( integer channel, string name, key id, string message ) {
        mothership_uuid = id;
        //llOwnerSay("got ping from mothership");
        llSetTimerEvent(25);
    }

    timer() {
        //llOwnerSay("no pings for a while, reverting to ready state");
        state ready;    
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is this a reset command?
            if (str == "do:reset") {
                llResetScript();
                return;
            } 
        }  
    }
    
    touch_start(integer total_number)
    {        
        //llOwnerSay("telling object");
        llShout(SLOODLE_CHANNEL_SET_LAYOUT_REZZER_SHOW_DIALOG, (string)llDetectedKey(0));
        // options:
        // - call home
        // - rez another
        // - delete
        
       // llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:rez\n\nSLOODLE Mothership|<0.5, 2.0, 0.0>|<0.0, 0.0, 0.0, 1>", NULL_KEY);
    }    
        
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/sloodle_set_simple_mothership_handler.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle object distributor.
// Allows Sloodle objects to be distributed in-world to Second Life users,
//  either by an in-world user touching it and using a menu,
//  or via http-in from Moodle.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield
//

// When configured, reports its inventory list to the Moodle server.
// Note that non-copyable items are NOT made available, and neither will scripts or items whose name is on the ignore list below.
// Can send avatars inventory based on them touching and choosing, or based on an http-in message.

// ***** IGNORE LIST *****
//
// This is a list of names of items which should NOT be handed out
list ignorelist = ["sloodle_config","sloodle_object_distributor","sloodle_setup_notecard","sloodle_slave_object","sloodle_debug","awards_sloodle_config"];
//
// ***** ----------- *****
// Returns number of Strides in a List
integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
integer SLOODLE_CHANNEL_OPEN_IN_BROWSER= -1639277000;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_HTTP_RESPONSE = -1639260101;  // Tells the sloodle_rezzer_object script to send the contents as an http-in response, to the key specified as key, which should be waiting for a response.

integer SLOODLE_CHANNEL_AVATAR_SETTING = 1;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
integer SLOODLE_CHANNEL_AVATAR_IGNORE = -1639279999;

integer SLOODLE_CHANNEL_DISTRIBUTOR_REQUEST_GIVE_OBJECT = 1639271151; // start the process to give the specified object to the specified avatar, if they are allowed it.
integer SLOODLE_CHANNEL_DISTRIBUTOR_DO_GIVE_OBJECT = 1639271152; // actually do give the specified object to the specified avatar


string SLOODLE_DISTRIB_LINKER = "/mod/sloodle/mod/distributor-2.0/linker.php";
string SLOODLE_EOF = "sloodleeof";

string SLOODLE_OBJECT_TYPE = "distributor-2.0";

string sloodleserverroot = ""; 
integer sloodlecontrollerid = 0;
string sloodlepwd = ""; 
integer sloodlemoduleid = 0;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodlerefreshtime = 0; // Number of seconds between each automated server update (doesn't need to be high-volume... every hour should suffice)

integer lastrefresh = 0; // Timestamp of the last refresh

integer isconfigured = FALSE;
integer eof = FALSE;
integer isconnected = FALSE;

key ch = NULL_KEY; // UUID of the XMLRPC channel opened by this object
key httpupdate = NULL_KEY; // UUID of the HTTP request to update the server

list inventory = []; // Will contain the names of all available inventory items
string inventorystr = ""; // Will contain a URL-escaped, pipe-delimited list of object names
list cmddialog = []; // Alternating list of keys, timestamps and page numbers, indicating who activated a dialog, when, and which page they are on (where applicable)

// Menu button texts
string MENU_BUTTON_RECONNECT = "A";
string MENU_BUTTON_RESET = "B";


string MENU_BUTTON_PREVIOUS = "<<";
string MENU_BUTTON_NEXT = ">>";
string MENU_BUTTON_CMD = "cmd";
string MENU_BUTTON_WEB = "web";


///// TRANSLATION /////
// These items are standard... do not change them!

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
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";  // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.
integer DIALOG_CHANNEL;
// Send a translation request link message
// Parameter: output_method = should identify an output method, as given by the "SLOODLE_TRANSLATE_..." constants above
// Parameter: output_params = a list of parameters which controls the output, such as chat channel or buttons for a dialog
// Parameter: string_name = the name of the localization string to output
// Parameter: string_params = a list of parameters which will be included in the translated string (or an empty list if none)
// Parameter: keyval = a key to send in the link message
// Parameter: batch = the name of the localization batch which should handle this request
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

///// ----------- /////


///// FUNCTIONS /////

sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}

sloodle_reset()
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reset", NULL_KEY);
    llResetScript();
}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
    list bits = llParseStringKeepNulls(str,["|"],[]);
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
    else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0);
}
    
integer sloodle_initial_inventory_avatar_check(key avatartogiveto, string objecttogive) {
      
    // Make sure we have the named object
    if (llGetInventoryType(objecttogive) == INVENTORY_NONE) {
        sloodle_debug("Object \"" + objecttogive + "\" not found.");
       // llOwnerSay("object fail");    
        return 0;
    }
                
    // Make sure we can find the identified avatar
    if (avatartogiveto == NULL_KEY || llGetOwnerKey(avatartogiveto) != avatartogiveto) {
      //  llOwnerSay("avatar fail");                
        sloodle_debug("Could not find identified avatar.");
        return 0;
    }
    
    return 1;
    
}   

integer sloodle_kick_off_inventory_giving_or_say_error(key avatartogiveto, string objecttogive) {
            
  //  llOwnerSay("plan to give "+objecttogive+" to avatar "+(string)avatartogiveto);

    if (sloodle_initial_inventory_avatar_check(avatartogiveto, objecttogive) != 1) {
        return 0;
    }

    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodleobjuuid=" + (string)llGetKey();        
    body += "&sloodleuuid=" + (string)avatartogiveto;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
    body += "&sloodlegiveobject=" + objecttogive;

    llHTTPRequest(sloodleserverroot + SLOODLE_DISTRIB_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body); 
    
    return 1;

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
        // Is the current timestamp more than 12 seconds old?
        if ((curtime - llList2Integer(cmddialog, i + 1)) > 12) {
            // Yes - remove it
            cmddialog = llDeleteSubList(cmddialog, i, i + 2);
        } else {
            // No - advance to the next
            i += 3;
        }
    }
}


// Update our inventory list
update_inventory()
{
    // We're going to build a string of all copyable inventory items
    inventory = [];
    inventorystr = "";
    integer numitems = llGetInventoryNumber(INVENTORY_ALL);
    string itemname = "";
    integer numavailable = 0;
    
    // Go through each item
    integer i = 0;

    for (i = 0; i < numitems; i++) {
        // Get the name of this item
        itemname = llGetInventoryName(INVENTORY_ALL, i);
        // Make sure it's copyable, not a script, and not on the ignore list
        if((llGetInventoryPermMask(itemname, MASK_OWNER) & PERM_COPY) && llGetInventoryType(itemname) != INVENTORY_SCRIPT && llListFindList(ignorelist, [itemname]) == -1) {
            inventory += [itemname];
        
            if (numavailable > 0) inventorystr += "|";
            inventorystr += llEscapeURL(itemname);
            numavailable++;
        }
    }
    
}
 
integer Key2AppChan(key ID, integer App) {
    return 0x80000000 | ((integer)("0x"+(string)ID) ^ App);
}
// Update the server with our channel and inventory.
// Returns the key of the HTTP request.
key update_server()
{
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
    body += "&sloodlechannel=" + (string)ch;
    body += "&sloodleinventory=" + inventorystr;
    return llHTTPRequest(sloodleserverroot + SLOODLE_DISTRIB_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
}


// Shows the given user a dialog of objects, starting at the specified page
// If parameter "showcmd" is TRUE, then the "command" menu option will be shown.
sloodle_show_object_dialog(key id, integer page, integer showcmd)
{
        
    // Edmund Edgar, 2012-04-12: Turning off showcmd for now
    // We should replace it with the reset button and the open in browser button.
    showcmd = 0;

    // Each dialog can display 12 buttons, but we need 4 reserved for:
    // Previous page, next page,  command menu, and web.

    // Check how many objects we have
    integer numobjects = llGetListLength(inventory);
    // How many pages are there?
    integer numpages = (integer)((float)numobjects / 9.0);
    if (numobjects%9 > 0) numpages+=1;
    
    
    // If the requested page number is invalid, then cap it
    if (page < 0) {
            page = 0;
            }
    else if (page >= numpages) page = numpages - 1;
    // Build our list of item buttons (up to a maximum of 9)
    list buttonlabels = [];
    
    string buttondef = ""; // Indicates which button does what
    integer numbuttons = 0;
    integer itemnum = 0;
    if (page <0) page=0;
    for (itemnum = page * 9; itemnum < numobjects && numbuttons < 9; itemnum++, numbuttons++) {
        // Add the button label (a number) and button definition
        buttonlabels += [(string)(itemnum + 1)]; // Button labels are 1-based
        
        buttondef += (string)(itemnum + 1) + " = " + llList2String(inventory, itemnum) + "\n";
    }
   
    
    // Add our page buttons if necessary
    if (page > 0) {
        buttonlabels += ["<<"];//MENU_BUTTON_PREVIOUS];
    }
    
    if (page < (numpages - 1)) buttonlabels += [MENU_BUTTON_NEXT];
    if (showcmd) {
        buttonlabels +=[MENU_BUTTON_CMD];
    }
       
       
       
    
    list box1=[];list box2=[];list box3=[];list box4=[];
    integer i;
    string lab="";
    
    buttonlabels = llListSort(buttonlabels,1,FALSE);
    /*
    * LSL Dialog buttons get printed on a max of 4 rows in the following order:
    *
    * 9 10 11  <--- consider this to be box 4
    * 6 7 8      <--- consider this to be box 3
    * 3 4 5      <--- consider this to be box 2
    * 0 1 2      <--- consider this to be box 1
    *
    * We want the higher numbers to be printed on the bottom row, not the top row, so put them into box1, and the lowest numbers in box 4
    * Do this by sorting the buttonlabels in decending order, and then place each label one by one into the boxes starting with box 1 first.
    */
         
    for (i=0; i<llGetListLength(buttonlabels);i++){
        lab = llList2String(buttonlabels,i);
            if (llGetListLength(box1)<3) box1+=lab; else
            if (llGetListLength(box2)<3) box2+=lab; else
            if (llGetListLength(box3)<3) box3+=lab; else
            if (llGetListLength(box4)<3) box4+=lab; 
    }
    //now sort each box so the numbers on each row get printed in ascending order eg: 3,4,5 etc
    box1=llListSort(box1, 1, TRUE); 
    box2=llListSort(box2, 1, TRUE); 
    box3=llListSort(box3, 1, TRUE); 
    box4=llListSort(box4, 1, TRUE); 
    // now build our buttonlabel array, starting with the highest numbers first - this will allow us to display numbers correctly on the dialog    
    
    
    buttonlabels = box1+box2+box3+box4;
    if (llGetListLength(buttonlabels)==0){
            sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [DIALOG_CHANNEL] + "ok", "distributor:distributerisempty", [buttondef,MENU_BUTTON_WEB], id, "distributor");
    }else{
            sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [DIALOG_CHANNEL] + buttonlabels, "dialog:distributorobjectmenu", [buttondef,MENU_BUTTON_WEB], id, "distributor");
    }
    
   
   
} 
integer random_integer( integer min, integer max ){  
    return min + (integer)( llFrand( max - min + 1 ) );
}


///// STATES /////

// In this state, we are uninitialised, waiting for configuration
default
{
    state_entry()
    {
         DIALOG_CHANNEL = Key2AppChan(llGetKey(),SLOODLE_CHANNEL_AVATAR_DIALOG);
         
        sloodle_debug("Distributor: default state");
        // Reset to empty settings
        sloodleserverroot = "";
        sloodlecontrollerid = 0;
        sloodlepwd = "";
        sloodlemoduleid = 0;
        sloodlerefreshtime = 0;

        ch = NULL_KEY;
        inventory = [];
        inventorystr = "";
        
        llSetText("", <0.0,0.0,0.0>, 0.0);
        isconfigured = FALSE;
        eof = FALSE;
        
        isconnected = FALSE;
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
            
                    update_inventory();
                    update_server();
                
                    state ready;
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

// Dummy state to jump straight back into "connecting"
state reconnect
{
    state_entry()
    {
        state ready;
    }
}


// Ready to receive http-in requests (if applicable) or user touches
state ready
{
    state_entry()
    {
        sloodle_debug("Distributor: ready state");
        // Display status text
        if (sloodlemoduleid > 0) {
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.1,0.9,0.1>, 0.9], "readyconnectedto", [sloodleserverroot], NULL_KEY, "");
        } else {
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.1,0.9,0.1>, 0.9], "readynotconnected", [sloodleserverroot], NULL_KEY, "");
        }
        
        // Make sure the refresh timer is not too often... no more than once per minute
        if (sloodlerefreshtime > 0 && sloodlerefreshtime < 60) sloodlerefreshtime = 60;
        else if (sloodlerefreshtime < 0) sloodlerefreshtime = 0;
        
        // Set a regular timer going
        llSetTimerEvent(12.0);
        lastrefresh = llGetUnixTime();
        
        // Listen for settings coming in on the avatar dialog channel
        llListen(DIALOG_CHANNEL, "", NULL_KEY, "");
    }
    
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    touch_start(integer num_detected)
    {
        // Go through each toucher
        integer i = 0;
        key id = NULL_KEY;
        for (i=0; i < num_detected; i++) {
            id = llDetectedKey(0);
            // Make sure the user is allowed to use this object
            if (sloodle_check_access_use(id) || sloodle_check_access_ctrl(id)) {
                // Show a menu of objects
                sloodle_show_object_dialog(id, 0, sloodle_check_access_ctrl(id));
                sloodle_add_cmd_dialog(id, 0);
            } else {
                // Inform the user of the problem
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(id)], NULL_KEY, "");
            }
        }
    }
    
    listen(integer channel, string name, key id, string msg)
    {
    
        // Check what channel it is
        if (channel == DIALOG_CHANNEL) {
            // Ignore the message if the user is not on our list
            if (llListFindList(cmddialog, [id]) == -1) {
           
                return;
            }
            // Find out what the current page number is
            integer page = sloodle_get_cmd_dialog_page(id);
            
            msg = llStringTrim(msg, STRING_TRIM);
        
            // Check what message is
            if (msg == MENU_BUTTON_NEXT) {
                // Show the next menu of objects
                sloodle_show_object_dialog(id, page + 1, sloodle_check_access_ctrl(id));
                sloodle_add_cmd_dialog(id, page + 1);
            } else if (msg == MENU_BUTTON_PREVIOUS) {
                // Show the previous menu of objects
                sloodle_show_object_dialog(id, page - 1, sloodle_check_access_ctrl(id));
                sloodle_add_cmd_dialog(id, page - 1);
            }else {
                 
                // Treat the message as a number (objects are numbered from 1)
                integer objnum = (integer)msg;
                if (objnum > 0 && objnum <= llGetListLength(inventory)) {
                    // Attempt to give the specified item                
                     
                    sloodle_kick_off_inventory_giving_or_say_error(id, llList2String(inventory, objnum - 1));
                }
                sloodle_remove_cmd_dialog(id);
            }
            
        }
    }
                
    link_message( integer sender_num, integer num, string str, key id)
    {                
              //  llOwnerSay("got message on num"+(string)num);
              //  llOwnerSay(str);
        // Check the channel
        if (num ==SLOODLE_CHANNEL_OPEN_IN_BROWSER){
              string urltoload = sloodleserverroot+"/mod/sloodle/view.php?id=" +( string)sloodlemoduleid; //the  url to load
              string transLookup = "dialog:distributorobjectmenu:visitmoodle" ; //the translation lookup as defined in your translation script which will be displayed on the dialog
              key avuuid = id; // this is the avatar the dialog will be displayed to
              if (isconfigured&&sloodlemoduleid>0) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_LOAD_URL, [urltoload], transLookup , [], avuuid, "distributor" );
              }
        
        }
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
                    state ready;
                } else {
                    // Got all configuration but, it's not complete... request reconfiguration
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], NULL_KEY, "");
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);
                    eof = FALSE;
                }
            }
        } else if (num == SLOODLE_CHANNEL_DISTRIBUTOR_REQUEST_GIVE_OBJECT) {
            
            list lines = llParseString2List(str, ["\n"], []);
            
            key avatartogiveto = llList2Key(lines,1);
            string objecttogive = llList2String(lines, 2);

            string errors = "";
            string ok = "1";
            if (llGetInventoryType(objecttogive) == INVENTORY_NONE) {
                errors = "sloodleobjectnotfound"+"\n";
                ok = "0";
            }
                
            // Make sure we can find the identified avatar
            if (avatartogiveto == NULL_KEY || llKey2Name(avatartogiveto) == "") {        
                errors += "sloodleavatarnotfound"+"\n"; 
                ok = "0";
            }

            // We don't get to find out if llGiveInventory actually works or not
            // ...so if the checks worked out, we'll consider it a "yes" and go ahead and send the response to the server.
            // That will get the user a faster response, avoiding the need to wait for llGiveInventory and its 2-second delay.                
            llMessageLinked( sender_num, SLOODLE_CHANNEL_HTTP_RESPONSE, ok+"\n"+errors, id ); 

            llGiveInventory(avatartogiveto, objecttogive);    

            return;
                    
        }
                                
    }
    
    changed(integer change)
    {
        // Was it an inventory change?
        if ((change & CHANGED_INVENTORY) == CHANGED_INVENTORY) {
            update_inventory();
        }
    }
    
    timer()
    {
        // Purge the list of expired dialog
        sloodle_purge_cmd_dialog();
        // Do we have a distributor module to connect to?
        if (sloodlemoduleid > 0) {
            // Has the timer period been exceeded?
            if ((llGetUnixTime() - lastrefresh) > sloodlerefreshtime) {
                // Yes - do an automatic refresh
                state reconnect;
            }
        }
    }

    http_response(key request_id, integer status, list metadata, string body) {
        
        if (status < 200) {
            return;
        }
        if (status >= 300) {
            return;
        }
                            
        list lines = llParseString2List(body, ["\n"], []);        
        list bits = llParseStringKeepNulls(llList2String(lines,0),["|"],[]);
        integer response_code = llList2Integer(bits,0);
        
       // llOwnerSay(body);
        if (response_code == SLOODLE_CHANNEL_DISTRIBUTOR_DO_GIVE_OBJECT){
            key avuuid = llList2Key(lines,1);
            string object_to_give= llList2String(lines,2);
            llDialog(avuuid, "An item called ("+object_to_give+")"+" has been delivered to your inventory, please open your recent items in your inventory", ["ok"], DIALOG_CHANNEL);
            llGiveInventory(avuuid,object_to_give);
            return;
        } else if (response_code < 0) {        
            if (llGetListLength(bits) > 5) {
               key avuuid = llList2Key(bits,6);    
                if (llGetListLength(lines) > 0) {
                    if (llKey2Name(avuuid) != "") {
                        // Report an error to the user, eg they didn't have enough money.
                        llSay(0, llKey2Name(avuuid)+", "+llList2String(lines,1));
                        return;
                    }
                }
            }
        }
        return;
    }
    
}        
        

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/distributor-2.0/object_scripts/vendor/sloodle_vendor.lsl

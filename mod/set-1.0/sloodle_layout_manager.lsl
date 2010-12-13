// Sloodle Set layout manager script.
// Allows users in-world to use and manage layouts.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield
//

///// DATA /////

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_LAYOUT_MANAGER  = -1639270034 ;
integer SLOODLE_CHANNEL_OBJECT_LAYOUT = -1639270013;
string SLOODLE_LAYOUT_LINKER = "/mod/sloodle/mod/set-1.0/layout_linker.php";
string SLOODLE_EOF = "sloodleeof";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = "";
string sloodlepwd = ""; 
integer sloodlecontrollerid = 0;
key sloodlemyrezzer = NULL_KEY;

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httplayoutbrowse = NULL_KEY; // Request for a list of layouts
key httplayoutquery = NULL_KEY; // Request for the contents of a layout
key httplayoutupdate = NULL_KEY; // Request to update a layout

integer layoutspagenum = 0; // Which page of object layouts is being viewed?
integer menutime = 0; // When was the menu last activated? (expires after a period of time)
integer loadmenu = FALSE; // Does the menu relate to loading profiles? Otherwise saving.
list availablelayouts = []; // A list of names of layouts which are available on the current course



string currentlayout = ""; // Name of the currently loaded layout, if any

string MENU_BUTTON_NEXT = ">>";
string MENU_BUTTON_PREVIOUS = "<<";
string MENU_BUTTON_LOAD = "A";
string MENU_BUTTON_SAVE = "B";
string MENU_BUTTON_SAVE_AS = "C";
string MENU_BUTTON_CANCEL = "X";


///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

integer SLOODLE_CHANNEL_SET_MENU_BUTTON_OPEN_LAYOUT_DIALOG = -1639270094;
integer SLOODLE_CHANNEL_SET_GO_HOME = -1639270093;

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

integer SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVE = -1639270101;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE = -1639270102; 
integer SLOODLE_CHANNEL_SET_LAYOUT_REZZER_SHOW_DIALOG = -1639270094;


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
    
    if (name == "set:sloodleserverroot") sloodleserverroot = value1;
    else if (name == "set:sloodlepwd") {
        // The password may be a single prim password, or a UUID and a password
        if (value2 != "") sloodlepwd = value1 + "|" + value2;
        else sloodlepwd = value1;
        
    } else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    else if (name == "do:reset") llResetScript();
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0); 
}

// Checks if the given agent is permitted to control this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_ctrl(key id)
{
    // Presently only the owner
    if (id == llGetOwner()) return TRUE;
    return FALSE;
}

// Checks if the given agent is permitted to user this object
// Returns TRUE if so, or FALSE if not
integer sloodle_check_access_use(key id)
{
    // Presently only the owner
    if (id == llGetOwner()) return TRUE;
    return FALSE;
}

// Shows the given user a dialog of layouts, starting at the specified page.
// If "load" is TRUE, then each button label will be prefixed with "L" and a "load" dialog will be shown.
// Otherwise, each button label will be prefixed with "S" and a "save" dialog will be shown.
sloodle_show_layout_dialog(key id, integer load)
{
    // Each dialog can display 12 buttons
    // However, we'll reserve the top row (buttons 10, 11, 12) for the next/previous buttons.
    // This leaves us with 9 others.

    // Check how many layouts we have
    integer numlayouts = llGetListLength(availablelayouts);
    if (numlayouts == 0) {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "layout:noneavailable", [llKey2Name(id)], NULL_KEY, "set");
        return;
    }
    
    // How many pages are there?
    integer numpages = (integer)((float)numlayouts / 9.0) + 1;
    // If the requested page number is invalid, then cap it
    if (layoutspagenum < 0) layoutspagenum = 0;
    else if (layoutspagenum >= numpages) layoutspagenum = numpages - 1;
    
    // Build our list of item buttons (up to a maximum of 9)
    list buttonlabels = [];
    string buttondef = ""; // Indicates which button does what
    integer numbuttons = 0;
    integer layoutnum = 0;
    for (layoutnum = layoutspagenum * 9; layoutnum < numlayouts && numbuttons < 9; layoutnum++, numbuttons++) {
        // Add the button label (a number) and button definition
        buttonlabels += [(string)(layoutnum + 1)]; // Button labels are 1-based
        buttondef += (string)(layoutnum + 1) + " = " + llList2String(availablelayouts, layoutnum) + "\n";
    }
        
    // Add our page buttons if necessary
    if (layoutspagenum > 0) buttonlabels += [MENU_BUTTON_PREVIOUS];
    if (layoutspagenum < (numpages - 1)) buttonlabels += [MENU_BUTTON_NEXT];
    
    // Display the appropriate menu
    if (load) sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_LAYOUT_MANAGER ] + buttonlabels, "layout:loadmenu", [buttondef], id, "set");
    else sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_LAYOUT_MANAGER ] + buttonlabels, "layout:savemenu", [buttondef], id, "set");
}

// Request an updated list of layouts on behalf of the specified user.
// Returns the HTTP request key.
key sloodle_update_layout_list(key id)
{
    llSay(0, "Checking available layouts...");

    // Start authorising the object
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodleuuid=" + (string)id;
    body += "&sloodleavname=" + llKey2Name(id);
    
    //llOwnerSay(body);
    return llHTTPRequest(sloodleserverroot + SLOODLE_LAYOUT_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
}

// Display the command dialog to the specified user
sloodle_show_command_dialog(key id)
{
    // Use letters for this menu
    list btns = [MENU_BUTTON_LOAD, MENU_BUTTON_SAVE, MENU_BUTTON_SAVE_AS, MENU_BUTTON_CANCEL];
    sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_LAYOUT_MANAGER ] + btns, "layout:cmdmenu", btns, id, "set");
}


///// STATES /////

// Waiting for configuration
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

        availablelayouts = [];
        currentlayout = "";
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
    
    touch_start(integer num_detected)
    {
        // Can the user use this object
        if (sloodle_check_access_use(llDetectedKey(0))) {
            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "notconfiguredyet", [llDetectedName(0)], NULL_KEY, "");
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
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
        // Do we currently have a layout loaded?
        // If so, show its name. Otherwise, show no hover tet
     //   if (currentlayout == "") llSetText("", <0.0,0.0,0.0>, 0.0);
    //  else sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "layoutcaption:layout", [currentlayout], NULL_KEY, "set");
        // Listen for owner dialog responses
        
        
        llListen(SLOODLE_CHANNEL_SET_LAYOUT_REZZER_SHOW_DIALOG , "", NULL_KEY, "");
        
    }
    
//    touch_start(integer num_detected)
//    {
//        // Make sure the user is allowed to use this object
//        key id = llDetectedKey(0);
//        if (!sloodle_check_access_use(id) && !sloodle_check_access_ctrl(id)) {
//            // Inform the user of the problem
//            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(id)], NULL_KEY, "");
//            return;
//        }
//        // Check te user's server access, and get all layouts they are allowed to use
//        httplayoutbrowse = sloodle_update_layout_list(id);
//    }
        
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the expected HTTP response
        if (id != httplayoutbrowse) return;
        httplayoutbrowse = NULL_KEY;
        
        sloodle_debug("HTTP Response ("+(string)status+"): "+body);
        
        // Was the HTTP request successful?
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httperror", [status], NULL_KEY, "toolbar");
            return;
        }
        
        // Split the response into lines and extract the status fields
        list lines = llParseString2List(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
        integer statuscode = llList2Integer(statusfields, 0);
        
        // Check the status code
        if (statuscode == -321) {
            // Avatar is probably not registered
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "nopermission:use", [llKey2Name(llGetOwner())], NULL_KEY, "");
            return;
                        
        } else if (statuscode == -301) {
            // User does not have permission
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:nopermission", [llKey2Name(llGetOwner())], NULL_KEY, "set");
            return;
            
        } else if (statuscode <= 0) {
            // Don't know what kind of error it was
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "servererror", [(string)statuscode], NULL_KEY, "");
            sloodle_debug(body);
            return;
        }
        
        // Store the list of layouts
        if (numlines > 1) availablelayouts = llDeleteSubList(lines, 0, 0);
        else availablelayouts = [];
        lines = [];
        
        // Show the command menu
        menutime = llGetUnixTime();
        
        llListen(SLOODLE_CHANNEL_AVATAR_LAYOUT_MANAGER , "", llGetOwner(), "");        
        sloodle_show_command_dialog(llGetOwner());
    }
    
    listen(integer channel, string name, key id, string msg)
    {
                
        // Check the channel
        if (channel == SLOODLE_CHANNEL_AVATAR_LAYOUT_MANAGER ) {
            // Ignore anybody but the owner
            if (id != llGetOwner()) return;
            // Make sure the menu has not yet expired
            integer curtime = llGetUnixTime();
            if ((curtime - menutime) > 20) return;
            
            // Check what message is
            if (msg == MENU_BUTTON_NEXT) {
                // Show the next menu of layouts
                layoutspagenum += 1;
                menutime = curtime;
                sloodle_show_layout_dialog(id, loadmenu);
                
            } else if (msg == MENU_BUTTON_PREVIOUS) {
                // Show the previous menu of layouts
                if (layoutspagenum > 0) layoutspagenum -= 1;
                menutime = curtime;
                sloodle_show_layout_dialog(id, loadmenu);
                
            } else if (msg == MENU_BUTTON_LOAD) {
                // Display the loading dialog
                loadmenu = TRUE;
                layoutspagenum = 0;
                menutime = curtime;
                sloodle_show_layout_dialog(id, loadmenu);
                
            } else if (msg == MENU_BUTTON_SAVE) {
                // Do we currently have a layout loaded?
                if (currentlayout == "") {
                    // Treat this as a "save as"
                    menutime = 0;
                    state save_as;
                } else {
                    // Save the current layout
                    menutime = 0;
                    state save;
                
                    // Show the save dialog
                    //loadmenu = FALSE;
                    //layoutspagenum = 0;
                    //menutime = curtime;
                    //sloodle_show_layout_dialog(id, loadmenu);
                }
                
            } else if (msg == MENU_BUTTON_SAVE_AS) {
                menutime = 0;
                state save_as;
                
            } else if (msg == MENU_BUTTON_CANCEL) {
                menutime = 0;
                
            } else if (llStringLength(msg) >= 1) {
                // This should be a number identifying a layout.
                // The dialog buttons are 1-based, but the list is 0-based, so we'll need to compensate.
                menutime = 0;
                integer num = (integer)msg;
                if (num < 1 || num > llGetListLength(availablelayouts)) return;
                num -=1;
                
                // Attempt to load or save the given laout
                currentlayout = llList2String(availablelayouts, num);
                if (currentlayout == "") return;
                if (loadmenu) state load;
                else state save;
            }         
        
        // Listen for instructions from the layout panel on the Simple Set
        } else if (channel == SLOODLE_CHANNEL_SET_LAYOUT_REZZER_SHOW_DIALOG) { 
            //llOwnerSay(msg);
                                
            key kval = (key)msg;                                
                                
           // Can the user use this object
            if (!sloodle_check_access_use(kval) && !sloodle_check_access_ctrl(kval)) {
                // Inform the user of the problem
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(kval)], NULL_KEY, "");
                return;
            }
            // Check te user's server access, and get all layouts they are allowed to use
            httplayoutbrowse = sloodle_update_layout_list(kval);             
                        
        }            
        
    }

    on_rez(integer par)
    {
        state default;
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG && sval == "do:reset") { 
            state default;
        } else if (num == SLOODLE_CHANNEL_SET_MENU_BUTTON_OPEN_LAYOUT_DIALOG ) {
            // Can the user use this object
            if (!sloodle_check_access_use(kval) && !sloodle_check_access_ctrl(kval)) {
                // Inform the user of the problem
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(kval)], NULL_KEY, "");
                return;
            }
            // Check te user's server access, and get all layouts they are allowed to use
            httplayoutbrowse = sloodle_update_layout_list(kval);          
        }
    }
}

// State in which we get the name of a layout for a "save as" operation
state save_as
{
    state_entry() 
    {
        // Listen to the owner's chat
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layoutcaption:savingas", [], NULL_KEY, "set");
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:chatlayoutname", [], NULL_KEY, "set");
        llListen(0, "", llGetOwner(), "");
        llListen(1, "", llGetOwner(), "");
        
        // Timeout after a minute
        llSetTimerEvent(0.0);
        llSetTimerEvent(60.0);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:chatlayoutname", [], NULL_KEY, "set");
        state ready;
    }
    
    listen(integer channel, string name, key id, string msg)
    {
        // Only listen to the owner, on channels 0 and 1
        if (id != llGetOwner() || (channel != 0 && channel != 1)) return;
        // Trim and store the layout name
        currentlayout = llStringTrim(msg, STRING_TRIM);
        state save;
    }
    
    on_rez(integer par)
    {
        state default;
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG && sval == "do:reset") state default;
    }
}

// Save the current layout
state save
{
    state_entry()
    {
        // Make sure the current layout name isn't blank
        if (currentlayout == "") {
            state ready;
            return;
        }
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [<0.0,0.0,0.0>, 0.8], "layoutcaption:saving", [], NULL_KEY, "set");
        
        // Start by clearing the current layout (update it with no entries)
        // Construct the body of the request
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodleuuid=" + (string)llGetOwner();
        body += "&sloodleavname=" + llEscapeURL(llKey2Name(llGetOwner()));
        body += "&sloodlelayoutname=" + llEscapeURL(currentlayout);
        body += "&sloodlelayoutentries=";

        // the sensor stuff and message transmission is offloaded to another script to save memor.
        llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVE, sloodleserverroot + SLOODLE_LAYOUT_LINKER+"\n"+body, NULL_KEY);
        
        llSetTimerEvent(0.0);
        llSetTimerEvent(30.0); // have to do lots of sensing and things, so it could be a while...
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httptimeout", [], NULL_KEY, "");
        state ready;
    }
    
    on_rez(integer par)
    {
        state default;
    } 
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        if ( (num == SLOODLE_CHANNEL_OBJECT_DIALOG) && (sval == "do:reset") ) {
            state default;
        } else if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE) { 
            llSetTimerEvent(0.0);
            state ready;
        } 
    }
    
}

// Load a new layout
state load
{
    state_entry()
    {
        // Make sure the current layout name isn't blank
        if (currentlayout == "") {
            state ready;
            return;
        }
       // sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [<0.0,0.0,0.0>, 0.8], "layoutcaption:loading", [currentlayout], NULL_KEY, "set");
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:loading", [currentlayout], NULL_KEY, "set");
        
        // Request the contents of the layout
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodleuuid=" + (string)llGetOwner();
        body += "&sloodleavname=" + llEscapeURL(llKey2Name(llGetOwner()));
        body += "&sloodlelayoutname=" + llEscapeURL(currentlayout);


        sloodle_debug("Querying for layout contents...");
        httplayoutquery = llHTTPRequest(sloodleserverroot + SLOODLE_LAYOUT_LINKER, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"], body);
        
        // Apply a timeout
        llSetTimerEvent(0.0);
        llSetTimerEvent(8.0);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httptimeout", [], NULL_KEY, "");
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the expected HTTP response
        if (id != httplayoutquery) return;
        httplayoutquery = NULL_KEY;
        
        //sloodle_debug("HTTP Response ("+(string)status+"): "+body);
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
        
        // Check the status code
        if (statuscode == -301) {
            // User does not have permission
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:nopermission", [llKey2Name(llGetOwner())], NULL_KEY, "set");
            state ready;
            return;
            
        } else if (statuscode == -901) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:savefailed", [], NULL_KEY, "set");
            state ready;
            return;
            
        } else if (statuscode == -902) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:notexist", [], NULL_KEY, "set");
            state ready;
            return;
            
        } else if (statuscode == -903) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:alreadyexists", [], NULL_KEY, "set");
            state ready;
            return;
            
        } else if (statuscode <= 0) {
            // Don't know what kind of error it was
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "servererror", [(string)statuscode], NULL_KEY, "");
            sloodle_debug(body);
            state ready;
            return;
        }
        
        // Everything looks fine.
        // We can just use all the layout data directly from the HTTP response.
        // All we need to do is replace the first line with an appropriate command.
        lines = llListReplaceList(lines, ["do:rez"], 0, 0);
        
        body = llDumpList2String(lines, "\n");
        // Send the link message
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, body, NULL_KEY);
        //llOwnerSay(body);
        
        state ready;
    }
    
    on_rez(integer par)
    {
        state default;
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG && sval == "do:reset") state default;
    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_layout_manager.lsl 

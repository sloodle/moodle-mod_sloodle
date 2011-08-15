// Sloodle Scoreboard
// 
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2011-06 contributors (see below)
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Paul Preibisch
//
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;

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
integer sloodlegroupid = 0;
integer sloodleshowallcontrollers = 0;
integer sloodleroundid = 0;
integer sloodlerefreshtime  = 0;

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

integer lastmessagetimestamp = 0;
integer messagetimestamp = 0;
 
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

sloodle_error_code(string method, key avuuid,integer statuscode)
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|"+(string)statuscode, NULL_KEY);
} 

sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}

handle_points_notification(string str) {

    string changeduserid;
    string newbalance;

    list lines = llParseStringKeepNulls(str,["\n"],[]);
    integer l;
   // llOwnerSay("points notification: "+str);
    for(l=0; l<llGetListLength(lines); l++) {
        string line = llList2String(lines, l);
        list bits = llParseStringKeepNulls(line,["|"],[]);
        integer numbits = llGetListLength(bits);
        string name = llList2String(bits,0);
        string value = ""; 
        if (llGetListLength(bits) > 1) {
            value = llList2String(bits,1);
        }
        if (name == "balance") newbalance = value;
        if (name == "userid") changeduserid = value;
        if (name == "lastmessagetimestamp") lastmessagetimestamp = (integer)value;
        if (name == "messagetimestamp") messagetimestamp = (integer)value;
    }

    string hash = "#"+changeduserid+"_"+newbalance+"_"+(string)lastmessagetimestamp+"_"+(string)messagetimestamp;
   // llOwnerSay("About to update scoreboard for "+newbalance+" for user "+changeduserid);
    update_media(hash);
    
    lastmessagetimestamp = messagetimestamp;
 
}
    
update_media(string hash) {
    
    string paramstr;
    paramstr = "&sloodleobjuuid=" + (string)llGetKey();
    
    string view_url = sloodleserverroot+"/mod/sloodle/mod/scoreboard-1.0/shared_media/index.php?" + paramstr + hash;
    string admin_url =  sloodleserverroot+"/mod/sloodle/mod/scoreboard-1.0/shared_media/index.php?" + paramstr + "&mode=admin" + hash;
    
//   llOwnerSay("updating media "+view_url);
                          
    llSetPrimMediaParams( 1, [ PRIM_MEDIA_CURRENT_URL, view_url, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_ANYONE ] );
    llSetPrimMediaParams( 1, [ PRIM_MEDIA_HOME_URL,  view_url, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_ANYONE ] );  
    
    // setup the control screen
    integer media_control;
    if ( sloodleobjectaccesslevelctrl == 0 ) media_control = PRIM_MEDIA_PERM_ANYONE;
    else if ( sloodleobjectaccesslevelctrl == 2 ) media_control = PRIM_MEDIA_PERM_GROUP;
    else media_control = PRIM_MEDIA_PERM_OWNER;
    
    // send a message to update the admin screen, which is on another prim.
    llMessageLinked( LINK_ALL_OTHERS, media_control, admin_url, NULL_KEY );    

}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
       // llOwnerSay(str);
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
    else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;    
    else if (name == "set:sloodlerefreshtime") sloodlerefreshtime = (integer)value1;
    else if (name == "set:sloodleshowallcontrollers") sloodleshowallcontrollers = (integer)value1;
    else if (name == "set:sloodlegroupid") sloodlegroupid = (integer)value1;
    else if (name == "set:sloodleroundid") sloodleroundid = (integer)value1;
    
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0);
}

// Default state - waiting for configuration
default
{
    state_entry()
    {
     
        llClearPrimMedia(4);    
    
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
        sloodlegroupid = 0;
        sloodleshowallcontrollers = 0;
        sloodleroundid = 0;
        sloodlerefreshtime = 0;
        
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
        update_media("");                              
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    } 
        
    touch_start( integer total_number)
    {

    }
    
    listen( integer channel, string name, key id, string message)
    {

    }

    timer()
    {

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
            
        } else if (num == 10601) { // Awards points change notification
            handle_points_notification( str );
        }
    } 
    
    
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/scoreboard-1.0/sloodle_mod_scoreboard.lsl

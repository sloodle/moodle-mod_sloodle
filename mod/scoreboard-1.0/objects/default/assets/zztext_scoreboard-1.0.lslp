//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle ZZText Scoreboard
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
integer SLOODLE_CHANNEL_SCOREBOARD_UPDATE_COMPLETE = 1639271140;
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
integer SLOODLE_AWARDS_POINTS_CHANGE_NOTIFICATION= 10601;
integer SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_SET_ADMIN_URL_CHANNEL= -1639271128; // This is the channel that the scoreboard shouts out its admin URL
integer SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_CHANGE_ADMIN_URL_CHANNEL= -1639271129; // This is the channel that the scoreboard shouts out its admin URL WHEN It has changed due to a region event (lost its url etc)
integer SLOODLE_SCOREBOARD_CONNECT_HUD= -1639271130; // channel which gets sent a linked message by the connect a hud button when it is touched.
 string SLOODLE_SCOREBOARD_LINKER = "/mod/sloodle/mod/scoreboard-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";
integer SLOODLE_SCOREBOARD_OPEN_IN_BROWSER= -1639277000;
string SLOODLE_OBJECT_TYPE = "scoreboard-1.0";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1; 
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
key httpscoreboard = NULL_KEY; // Request used to receive scores
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
integer MENU_CHANNEL; //random channel used for dialogs
integer listenHandle;
string paramstr;
string view_url;
string admin_url;

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

///// ----------- /////


///// FUNCTIONS /////
integer randInt(integer n)
{
     return (integer)llFrand(n + 1);
}

integer randIntBetween(integer min, integer max)
{
    return min + randInt(max - min);
}
sloodle_error_code(string method, key avuuid,integer statuscode)
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|"+(string)statuscode, NULL_KEY);
} 

sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}
debug (string message){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay(llGetObjectName()+"."+llGetScriptName()+": "+message);
     }
}

requestScores(){
 paramstr = "&sloodleobjuuid=" + (string)llGetKey();

        // Inform the Moodle chatroom
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        body += "&sloodleuuid=" + (string)llGetKey();
        body += "&sloodleavname=" + llEscapeURL(llGetObjectName());
        body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
        body += "&sloodleisobject=true";
        body += "&format=paddedtext";
         httpscoreboard = llHTTPRequest(sloodleserverroot + SLOODLE_SCOREBOARD_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);       
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
integer face=4;
default
{
    on_rez( integer param)
    {
       llResetScript();
    }
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
       llResetScript();
    }    
    
    state_entry()
    {         
       requestScores();                            
    }
     http_response(key id, integer status, list meta, string body){
        // Is this the expected data?
        if (id != httpscoreboard) return;
        httpscoreboard = NULL_KEY;
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
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SCOREBOARD_UPDATE_COMPLETE, body, NULL_KEY);
        
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    
    } 
        
    link_message( integer sender_num, integer num, string str, key id)
    {
            debug("linked message: "+str);
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }

            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                    admin_url = sloodleserverroot+"/mod/sloodle/mod/scoreboard-1.0/shared_media/index.php?" + paramstr + "&mode=admin";        
                    requestScores();
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], NULL_KEY, "");
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);
                    eof = FALSE;
                }
            }
    
        } else if (num == SLOODLE_CHANNEL_SCOREBOARD_UPDATE_COMPLETE) { // Awards points change notification
            
            // Nothing to do here: The sloodle_rezzer_object gets this and sends it directly to the scoreboard.

        } else if (num == SLOODLE_SCOREBOARD_OPEN_IN_BROWSER){
                llOwnerSay("You can access the scoreboard administration screen by going to: "+(string)admin_url);                
                llLoadURL(llGetOwner(),"You can load your scoreboard administration screen by going to the following url:",(string)admin_url);
        } else if (num == SLOODLE_SCOREBOARD_CONNECT_HUD){
               llOwnerSay("Contacting owner's HUD"); 
               llRegionSay(SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_SET_ADMIN_URL_CHANNEL, (string)admin_url+"|"+(string)id+"|"+(string)llGetKey()); 
               llShout(SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_SET_ADMIN_URL_CHANNEL,(string)admin_url+"|"+(string)id+"|"+(string)llGetKey());
        
        } 
    } 
        
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/scoreboard-1.0/objects/default/assets/zztext_scoreboard-1.0.lslp


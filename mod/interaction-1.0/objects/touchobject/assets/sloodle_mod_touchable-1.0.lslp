//
// The line above should be left blank to avoid script errors in OpenSim.

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
string SLOODLE_INTERACTION_LINKER = "/mod/sloodle/mod/interaction-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";
integer SLOODLE_OBJECT_INTERACTION= -1639271132; //channel interaction objects speak on
integer SLOODLE_OBJECT_REGISTER_INTERACTION= -1639271133; //channel objects send interactions to the mod_interaction-1.0 script on to be forwarded to server
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

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

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

key httprequest = NULL_KEY;
key avuuid = NULL_KEY;

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

sloodle_error_code(string method, key avuuid,integer statuscode, string msg){
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|"+(string)statuscode+"|"+(string)msg, NULL_KEY);
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
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0);
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


// Start recording the specified agent
register_interaction(key id,string task)
{
    
    // Inform the Moodle chatroom
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
    body += "&sloodleuuid=" + (string)id;
    body += "&sloodleobjuuid=" + (string)llGetKey();
    body += "&sloodleavname=" + llEscapeURL(llKey2Name(id));
    body += "&task=" + llEscapeURL(task);
    
    httprequest = llHTTPRequest(sloodleserverroot + SLOODLE_INTERACTION_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    
       // llOwnerSay("sending httprequest: "+sloodleserverroot + SLOODLE_INTERACTION_LINKER+ "?"+body);
}


// Default state - waiting for configuration
default
{
    state_entry()
    {
        // Set the texture on the sides to indicate we're deactivated
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
       // llOwnerSay(str);
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
}
                
state ready {
     on_rez(integer start_param) {
         llResetScript();
     
     }
     link_message(integer sender_num, integer num, string str, key id) {
        
        if (num==SLOODLE_OBJECT_REGISTER_INTERACTION){        
            register_interaction(id,str);
        }
     
     }
   state_entry() {
       llOwnerSay("ready");
   }
        

    http_response(key id, integer status, list meta, string body)
    {
      

        // Is this the expected data?
        if (id != httprequest) return;
        
        httprequest = NULL_KEY;
        // Make sure the request worked
        llMessageLinked(LINK_SET, SLOODLE_OBJECT_INTERACTION, body, NULL_KEY);
        if (status != 200) {
            sloodle_debug("Failed HTTP response. Status: " + (string)status);
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, avuuid,status,""); //send message to error_message.lsl
            
            return;
        }

        // Make sure there is a body to the request
        if (llStringLength(body) == 0) return;
     
        
        // Split the data up into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);  
        integer numlines = llGetListLength(lines);
        // Extract all the status fields
        list statusfields = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
        // Get the statuscode
        integer statuscode = llList2Integer(statusfields,0);
        
        // Was it an error code?
        if (statuscode <= 0) {
            
            string msg;
            if (numlines > 1) {
                msg = llList2String(lines, 1);
            }
            sloodle_debug(msg);
            //Sloodle 2.0 Change - output custom errorcode to other scripts
            sloodle_error_code(SLOODLE_TRANSLATE_IM, avuuid,statuscode, msg); //send message to error_message.lsl      
            return;
        }
            
      
    }    
            
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/interaction-1.0/sloodle_mod_touchable-1.0.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

// LoginZone script (for Sloodle 0.3).
// Allows avatar-Moodle identification by teleporting into pre-defined space in-world.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield


///// DATA /////
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string SLOODLE_LOGINZONE_LINKER = "/mod/sloodle/mod/loginzone-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";

string SLOODLE_OBJECT_TYPE = "pwreset-1.0";

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
string sloodlecoursename_full = "";
integer sloodlerefreshtime = 0; // How often to automatically update

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httpupdate = NULL_KEY; // The request for sending an update
list httpreqs = []; // A list of HTTP requests we're expecting


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

// Send debug info
sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}


// Tell Sloodle our position, size and region.
sloodle_update_server()
{
    // Construct the data
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlepos=" + (string)llGetPos();
    body += "&sloodlesize=" + (string)llGetScale();
    body += "&sloodleregion=" + llEscapeURL(llGetRegionName());
    // Send the request to update the server (we don't care about the response)
    httpupdate = llHTTPRequest(sloodleserverroot + SLOODLE_LOGINZONE_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
}

// Tell Sloodle about a detected avatar
sloodle_detected_avatar(key id, vector pos)
{
    // Construct the data
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlepos=" + (string)pos;
    body += "&sloodleuuid=" + (string)id;
    body += "&sloodleavname=" + llEscapeURL(llKey2Name(id));
    // Send the request to update the server (we don't care about the response)
    key newhttp = llHTTPRequest(sloodleserverroot + SLOODLE_LOGINZONE_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    if (newhttp != NULL_KEY) httpreqs += [newhttp];
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
    else if (name == "set:sloodlerefreshtime") sloodlerefreshtime = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0);
}



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
        sloodlecoursename_full = "";
    }
    
    link_message(integer sender_num, integer num, string str, key id)
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
                    state running;
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
    
    on_rez(integer par)
    {
        llResetScript();
    }
}


state running
{
    on_rez(integer param)
    {
        state default;
    }

    state_entry()
    {
        // Update the server
        sloodle_update_server();
        // Enable volume detection
        llVolumeDetect(TRUE);
        
        // Validate the update timer
        if (sloodlerefreshtime < 0) sloodlerefreshtime = 0;
        else if (sloodlerefreshtime > 0 && sloodlerefreshtime < 60) sloodlerefreshtime = 60;
        // Regularly update the server
        llSetTimerEvent((float)sloodlerefreshtime);
    }

    collision_start(integer num_detected)
    {
        // Go through each detected avatar
        integer i = 0;
        for (; i < num_detected; i++)
        {
            sloodle_detected_avatar(llDetectedKey(i), llDetectedPos(i));
        }
    }

    timer() 
    {
        sloodle_update_server();
    }

    moving_end()
    {
        sloodle_update_server();
        // We don't need to automatically update right away again
        llSetTimerEvent((float)sloodlerefreshtime);
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        integer statuscode; // added for OpenSim
        // Was this our update response?
        if (id == httpupdate) {
            httpupdate = NULL_KEY;
            sloodle_debug("HTTP response: " + body);
            // Check the HTTP response
            if (status != 200) {
                sloodle_debug("Update failed with HTTP status " + (string)status);
                sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
                return;
            }
            // Extract the status code of the response
            list bits = llParseString2List(body, ["|"], []);
            statuscode = (integer)llList2String(bits, 0); // deleted "integer" for OpenSim
            if (statuscode <= 0) {
                sloodle_debug("Update failed with Sloodle status " + (string)statuscode);
                sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
                return;
            }
            return;
        }
    
        // Was this an avatar response?
        integer listpos = llListFindList(httpreqs, [id]);
        if (listpos < 0) return;
        httpreqs = llDeleteSubList(httpreqs, listpos, listpos);
        sloodle_debug("HTTP response: " + body);
        
        // Check that it was a successful response
        if (status != 200) {
            sloodle_debug("Avatar notification failed with HTTP status " + (string)status);
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            return;
        }
        if (body == "") {
            sloodle_debug("Empty response body from avatar notification.");
            return;
        }
        
        // Parse the response
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer numfields = llGetListLength(statusfields);
        statuscode = (integer)llList2String(statusfields, 0); // deleted "integer" for OpenSim
        key av = NULL_KEY;
        if (numfields >= 7) av = (key)llList2String(statusfields, 6);
        
        // Check if it was successful
        if (statuscode == 301) {
            if (av != NULL_KEY) {
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "alreadyauthenticated", [llKey2Name(av)], av, "regenrol");
                return;
            }
        } else if (statuscode > 0) {
            if (av != NULL_KEY) {
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "userauthenticated", [llKey2Name(av)], av, "regenrol");
                return;
            }
        } else if (statuscode == -301) {
            // No user found with the specified position allocated
            // Nothing to do...
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            return;
        } else {
            if (av != NULL_KEY) {
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "userauthenticationfailed:code", [llKey2Name(av), statuscode], av, "regenrol");
                return;
            } else {
                sloodle_debug("Authentication of unknown avatar failed with status code " + (string)statuscode);
                sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
                return;
            }
        }
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/loginzone-1.0/objects/default/assets/sloodle_mod_loginzone-1.0.lslp

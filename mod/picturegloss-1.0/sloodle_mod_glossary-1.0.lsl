// "PictureGloss" -- SLOODLE MetaGloss modified to show textures instead of text definitions

///////////////////////////////////////////
// Allows users in-world to search the Moodle glossary
// for images and displays them while resizing the prim.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-9 SLOODLE (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Jeremy Kemp
//  Peter R. Bloomfield
//
///////////////////////////////////////////
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG;
string SLOODLE_GLOSSARY_LINKER = "/mod/sloodle/mod/glossary-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";
integer MENU_CHANNEL;
string SLOODLE_OBJECT_TYPE = "glossary-1.0"; // We just use the regular glossary tools server-side

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
integer objChat=1;
integer ON =1;
integer OFF = 2;
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
integer sloodlepartialmatches = 1;
integer sloodlesearchaliases = 0;
integer sloodlesearchdefinitions = 0;
integer sloodleidletimeout = 120; // How many seconds before automatic idle timeout? (0 means don't timeout)
string sloodleglossaryname = ""; // Name of the glossary

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httpcheck = NULL_KEY; // Request used to check the glossary
key httpsearch = NULL_KEY; // Request used to search the glossary
float HTTP_TIMEOUT = 10.0; // Period of time to wait for an HTTP response before giving up

string SLOODLE_METAGLOSS_COMMAND = "/pix "; // The command prefix for searching via chat message
string searchterm = ""; // The term to be searched
key searcheruuid = NULL_KEY; // Key of the avatar searching

string PICTUREGLOSS_TEXTURE = "SLOODLE PictureGloss texture"; // Name of the default texture to display on the PictureGloss


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
    sloodle_translation_request(SLOODLE_TRANSLATE_IM, [llGetOwner()], "resetting", [], NULL_KEY, "");
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
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
    else if (name == "set:sloodlepartialmatches") sloodlepartialmatches = (integer)value1;
    else if (name == "set:sloodlesearchaliases") sloodlesearchaliases = (integer)value1;
    else if (name == "set:sloodlesearchdefinitions") sloodlesearchdefinitions = (integer)value1;
    else if (name == "set:sloodleidletimeout") sloodleidletimeout = (integer)value1;
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


///// STATES /////

// Default state - waiting for configuration
default
{
    state_entry()
    {
        SLOODLE_CHANNEL_AVATAR_DIALOG = 6000000 + (integer)(llFrand( 6000001 )); //create a random channel to listen on so that your object doesnt cause another objects menu to appear!
        llListen(MENU_CHANNEL,"",llGetOwner(),"");
        llListen(MENU_CHANNEL,"",llGetOwner(),"");
        
        // Starting again with a new configuration
        isconfigured = FALSE;
        eof = FALSE;
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        sloodlemoduleid = 0;
        sloodleobjectaccessleveluse = 0;
        sloodleserveraccesslevel = 0;
        sloodlepartialmatches = 1;
        sloodlesearchaliases = 0;
        sloodlesearchdefinitions = 0;
        sloodleidletimeout = 120;
        sloodleglossaryname = "";
        
        // Reset to our default texture and size
        llSetScale(<1.0, 1.0, 1.0>);
        llSetTexture(PICTUREGLOSS_TEXTURE, ALL_SIDES);
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
                    sloodle_translation_request(SLOODLE_TRANSLATE_IM, [llGetOwner()], "configurationreceived", [], NULL_KEY, "");
                    state check_glossary;
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [llGetOwner()], "configdatamissing", [], NULL_KEY, "");
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);
                    eof = FALSE;
                }
            }
        }
    }
    
    touch_start(integer num_detected)
    {
        
        key id = llDetectedKey(0);
        // Determine what this user can do
      
        // Attempt to request a reconfiguration
        if (llDetectedKey(0) == llGetOwner()) {
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
        }
    }
}


// If necessary, check the name of the glossary
state check_glossary
{
    on_rez(integer par)
    {
        state default;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset message?
            if (str == "do:reset") llResetScript();
        }
    }

    state_entry()
    {
        // Lookup the glossary name
        sloodleglossaryname = "";
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0,1.0,0.0>, 0.8], "picturegloss:checking", [], NULL_KEY, "picturegloss");        
        httpcheck = llHTTPRequest(sloodleserverroot + SLOODLE_GLOSSARY_LINKER + "?sloodlecontrollerid=" + (string)sloodlecontrollerid + "&sloodlepwd=" + sloodlepwd + "&sloodlemoduleid=" + (string)sloodlemoduleid, [HTTP_METHOD, "GET"], "");
        llSetTimerEvent(0.0);
        llSetTimerEvent(HTTP_TIMEOUT);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
        llSleep(0.1);
        sloodle_reset();
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the response we're expecting
        if (id != httpcheck) return;
        if (status != 200) {
            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httperror:code", [status], NULL_KEY, "");
             sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status);
            sloodle_reset();
            return;
        }

        // Split the response into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the statuscode
        if (statuscode <= 0) {
            string errmsg = (string)statuscode;
            if (numlines > 1) errmsg += ": " + llList2String(lines, 1);
            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [errmsg], NULL_KEY, "");
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode);     
            sloodle_reset();
            return;
        }
        
        // Make sure we have enough data
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            sloodle_reset();
            return;
        }
        
        // Store the glossary name
        sloodleglossaryname = llList2String(lines, 1);
        if (objChat==ON)
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "picturegloss:checkok", [sloodleglossaryname], NULL_KEY, "picturegloss");
        state ready;
    }
}


// Ready for definition requests
state ready
{
    on_rez( integer param)
    {
        state default;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset message?
            if (str == "do:reset") llResetScript();
        }
    }
    
    state_entry()
    {
        // Update the hover text
        
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.0,0.0>, 0.9], "picturegloss:ready", [sloodleglossaryname, SLOODLE_METAGLOSS_COMMAND], NULL_KEY, "picturegloss");
        // Listen for chat messages
        llListen(0, "", NULL_KEY, ""); 
        llListen(SLOODLE_CHANNEL_AVATAR_DIALOG,"",llGetOwner(),"");       
        // We may need to de-activate after a period of idle time
        llSetTimerEvent(0.0);
        if (sloodleidletimeout > 0) llSetTimerEvent((float)sloodleidletimeout);
    }
    touch_start(integer num_detected) {
        key id = llDetectedKey(0);
         integer canctrl = sloodle_check_access_ctrl(id);
        integer canuse = sloodle_check_access_use(id);
        if (!(canctrl || canuse)) return;        
        //display menu for owner to turn off object chat
        list buttons = ["1","2"]; //maximum of 12!
        string translationLookup = "picturegloss:ctrlmenu"; //Turn object chat on or off        
        list stringParams = ["1","2"];
        key uuidToSendDialogTo = llDetectedKey(0);
        sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG]+buttons, translationLookup, stringParams, uuidToSendDialogTo, "picturegloss");
    }
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    listen( integer channel, string name, key id, string message)
    {
        // Check the channel
        if (channel == 0) {
            // Check use of this object
            if (sloodle_check_access_use(id) == FALSE) return;
            // Is this a definition request?
            if (llSubStringIndex(message, SLOODLE_METAGLOSS_COMMAND) != 0) return;
    
            // Store the term to be searched and search it
            searchterm = llGetSubString(message, llStringLength(SLOODLE_METAGLOSS_COMMAND), -1);
            searcheruuid = id;
            state search;
            return;
        }else if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG){
            if (message=="1"){
                objChat=ON;
                string batch = "picturegloss"; //the sloodle tool we are translating                
                sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "picturegloss:objChat", ["ON"], NULL_KEY, batch);
            }else 
            if (message=="2"){
                objChat=OFF;                
                string batch = "picturegloss"; //the sloodle tool we are translating                
                sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "picturegloss:objChat", ["OFF"], NULL_KEY, batch);
            }
        }
    }

    timer()
    {
        // Shutdown due to idle timeout
        state shutdown;
    }
    
}

state shutdown
{
    on_rez(integer par)
    {
        state default;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset message?
            if (str == "do:reset") llResetScript();
        }
    }
    
    state_entry()
    {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.5,0.1,0.1>, 0.6], "picturegloss:idle", [sloodleglossaryname], NULL_KEY, "picturegloss");
    }
    
    touch_start(integer num_detected)
    {
        // Does this user have permission to use this object?
        if (sloodle_check_access_use(llDetectedKey(0))) {
            state ready;
        } else {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [], NULL_KEY, "");
        }
    }
}

state search
{
    on_rez(integer par)
    {
        state default;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Is it a reset message?
            if (str == "do:reset") llResetScript();
        }
    }

    state_entry()
    {
        // Search the specified term
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.0,0.5,0.0>, 0.9], "picturegloss:searching", [sloodleglossaryname], NULL_KEY, "picturegloss");
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        body += "&sloodleuuid=" + (string)searcheruuid;
        body += "&sloodleavname=" + llEscapeURL(llKey2Name(searcheruuid));
        body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
        body += "&sloodleterm=" + searchterm;
        body += "&sloodlepartialmatches=" + (string)sloodlepartialmatches;
        body += "&sloodlesearchaliases=" + (string)sloodlesearchaliases;
        body += "&sloodlesearchdefinitions=" + (string)sloodlesearchdefinitions;
        // Check if it's an object sending this message
        if (searcheruuid != llGetOwnerKey(searcheruuid)) {
            // This makes sure Moodle doesn't try to auto-register an object
            body += "&sloodleisobject=true";
        }
        // Send the request
        httpsearch = llHTTPRequest(sloodleserverroot + SLOODLE_GLOSSARY_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        
        llSetTimerEvent(0.0);
        llSetTimerEvent(HTTP_TIMEOUT);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
        state ready;
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the response we're expecting
        if (id != httpsearch) {
            return;
        }

        httpsearch = NULL_KEY;
        llSetTimerEvent(0.0);
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httperror:code", [status], NULL_KEY, "");
            state ready;
            return;
        }
        
        // Split the response into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the statuscode
        if (statuscode <= 0) {
            string errmsg = (string)statuscode;
            if (numlines > 1) errmsg += ": " + llList2String(lines, 1);
           // sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [errmsg], NULL_KEY, "");
           sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode);
            state ready;
            return;
        }
        
        // Indicate how many definitions were found
        if (objChat ==ON)
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "picturegloss:numdefs", [searchterm, (numlines - 1)], NULL_KEY, "picturegloss");
        
        // Go through each definition
        integer defnum = 1;
        list fields = [];
        for (; defnum < numlines; defnum++) {
            // Split this definition into fields
            fields = llParseStringKeepNulls(llList2String(lines, defnum), ["|"], []);
            if (llGetListLength(fields) >= 2) {
              //  llSay(0, llList2String(fields, 0) + " = " + llList2String(fields, 1)); 
//-------------------
//The definition is spoken here - and here is hte added code
                list TextureList=llParseString2List(llList2String(fields, 1),[":"],[]);
                
                // Make sure the appropriate number of fields have been specified
                if (llGetListLength(TextureList) >= 3) {                
                    string TextureUUID=llList2String(TextureList,0);
                    string PrimScaleWidth=llList2String(TextureList,1);
                    string PrimScaleHeight=llList2String(TextureList,2); 
                    llOwnerSay(TextureUUID+"/"+PrimScaleWidth+"/"+PrimScaleHeight);
                      
                    llSetTexture( llStringTrim( TextureUUID, STRING_TRIM) , ALL_SIDES);
                    llSetPrimitiveParams([PRIM_SIZE,<(integer)PrimScaleWidth/100,(integer)PrimScaleWidth/100,(integer)PrimScaleHeight/100>]);
                } else {
                    llSay(0, "ERROR: invalid texture data in glossary. Please ensure the definition has the format \"UUID:width:height\".");
                }
//------------------------

            } else {
//                llSay(0, llList2String(fields, 0));
            }
        }

        state ready;
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/picturegloss-1.0/sloodle_mod_glossary-1.0.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Presenter (for Sloodle 0.4.1)
// Lets the educator display a presentation of images. videos and webpages hosted on the web.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2008-9 Sloodle project contributors
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//  Paul G. Preibisch (Fire Centaur)
//  
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
string SLOODLE_PRESENTER_LINKER = "/mod/sloodle/mod/presenter-2.0/linker.php";
string SLOODLE_EOF = "sloodleeof";
list parcelInfo = []; //var for parcel owner 
integer MENU_CHANNEL = -1;
string SLOODLE_OBJECT_TYPE = "presenter-2.0";
integer reset;
integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodleobjectaccesslevelctrl = 1; // Who can control this object?


string PRESENTER_TEXTURE= "sloodle_presenter_texture";
integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

key httploadpresentation = NULL_KEY; // Request for presentation data

string presentername = ""; // The name of the Presenter
integer numslides = 0; // Total number of slides in the presentation
integer curslidenum = 0; // Number of the current slide in the presentation (starting from 1)
string curslidetype = ""; // Mimetype of the current slide
string curslidesource = ""; // Source of the current slide media (usually a URL)
string curslidename = ""; // Name of the current slide

// requestConfigData = 0 this is set to 1 after the presenter has been deeded - afterwhich if "update" is 
//  selected, the presenter will go back into the default state and re-request config data.  This is necessary since the teacher may change prentations the presenter is pointing to via the web.  
integer requestConfigData = 0;

key myOwnerKey; // The key of the agent who initially rezzed this object -- useful for remembering permission after group deeding.


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
string SLOODLE_TRANSLATE_HOVER_TEXT_BASIC = "hovertextbasic";


// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

// Request the translation of a standard SLOODLE error code
sloodle_error_code(string method, key avuuid,integer statuscode)
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|"+(string)statuscode, NULL_KEY);
}

///// ----------- /////


///// FUNCTIONS /////

// Just returns a random integer - used for setting channels
integer random_integer( integer min, integer max )
{
    return min + (integer)( llFrand( max - min + 1 ) );
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
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;
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

// Update the image display (e.g. change the media URL).
// Does nothing if the data we currently have isn't valid
update_image_display()
{
        
    // Make sure an error didn't occur with the slide plugin
    if (curslidetype == "ERROR") return;
    // Make sure we have a valid slide number and valid data
    if (curslidenum < 1 || curslidenum > numslides) return;
    if (curslidetype == "" || curslidesource == "") return;
   // llOwnerSay(curslidetype);
    string showurl;
    if (curslidetype == "image/*") {
        // Wrap in an HTML page to force the scaling to happen right.
        showurl = "data:text/html," + "<html><body><img width=\"1000\" height=\"1000\" src=\""+curslidesource+"\"></body></html>";
    } else {
        showurl = curslidesource;
    }

    llSetPrimMediaParams( 2, [ PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI, PRIM_MEDIA_CURRENT_URL, showurl, PRIM_MEDIA_AUTO_PLAY, 1, PRIM_MEDIA_AUTO_SCALE, 1, PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_NONE, PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE ] );
    vector size = llGetScale();
    
    doAlign((integer)size.x,(integer)size.y,(integer)size.x);
}

// Request the specified slide
request_slide(integer num)
{
    // Indicate that we are requesting a slide
    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<1.29037, 1.42417, 0.00000>, 0.9], "loadingslide", [num], NULL_KEY, "presenter");

    // Construct and send our HTTP request for data
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
    body += "&sloodleslidenum=" + (string)num;
    
    httploadpresentation = llHTTPRequest(sloodleserverroot + SLOODLE_PRESENTER_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    llSetTimerEvent(8.0);
}

doAlign(integer w, integer h, integer face)
{
    // compute scale factors based on next bigger power of 2
    integer div;
    div = 2;
    while (div < w) div*=2;    
    float scale_s = (float)w / div;
    div = 2;
    while (div < h) div*=2;
    float scale_t = (float)h / div;
 
    // compute offset from scale
    float offset_u = -(1.0 - scale_s) / 2.0;
    float offset_v = -(1.0 - scale_t) / 2.0;
 
    // do the "Align":   
    llOffsetTexture(offset_u, offset_v, face);
    llScaleTexture(scale_s, scale_t, face);
}
    
// Move to the next slide
next_slide()
{
    if (curslidenum < 1 || curslidenum >= numslides) request_slide(1);
    else request_slide(curslidenum + 1);
}

// Move to the previous slide
previous_slide()
{
    if (curslidenum <= 1 || curslidenum > numslides) request_slide(numslides);
    else request_slide(curslidenum - 1);
}

// Update the hover text to indicate which image is being displayed
update_hover_text()
{
    // Make sure we actually have some slide data
    if (numslides == 0) {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.5, 0.0, 0.0>, 1.0], "error:nodata", [], NULL_KEY, "presenter");
        return;
    }
    
    // Make sure an error didn't occur with the slide plugin
    if (curslidetype == "ERROR") {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.5, 0.0, 0.0>, 1.0], "error:pluginnotfound", [presentername, curslidenum, numslides], NULL_KEY, "presenter");
        return;
    }
    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0, 1.0, 0.0>, 1.0], "showingslidename", [presentername, curslidenum, numslides, curslidename], NULL_KEY, "presenter");
    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "showingentryurl", [curslidenum, numslides, curslidesource], NULL_KEY, "presenter");
}


///// STATES /////


// Default state - waiting for configuration
// Default state - waiting for configuration
default{
 on_rez(integer start_param) {    
        myOwnerKey = llGetOwner();            
    }
 state_entry() {
         myOwnerKey = llGetOwner();
         llOwnerSay("Owner set to: " + llKey2Name(llGetOwner())+ " with UUID: " + (string)llGetOwner());
         reset=FALSE; //used in the last state - if someone deletes the sloodle_presenter_texture, we set a timer, so need to distinguish in timer event, what to do - ie: was the timer set because the texture was deleted? then set reset to TRUE. 
         state initialize; 
         
 }

}

state initialize
{

    on_rez(integer start_param) {  
        llOwnerSay("Reseting...");  
        myOwnerKey = llGetOwner();
        llResetScript();
                  
    }
    
    state_entry()
    {
        llClearPrimMedia(2);    
           if ((string)llGetInventoryKey("sloodle_config")!="00000000-0000-0000-0000-000000000000")
              sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_BASIC, [<0.00000,1, 0>, 1.0], "touchforwebconfig", [], NULL_KEY, "presenter");
        // Starting again with a new configuration
        llSetText("", <0.0,0.0,0.0>, 0.0);
        isconfigured = FALSE;
        eof = FALSE;
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        sloodlemoduleid = 0;
        sloodleobjectaccesslevelctrl = 0;
        if (requestConfigData==1){
         llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);                 
        }
        requestConfigData=1;
    }
    
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i;
            for (i = 0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                    state running;
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
        //if (llDetectedKey(0) == llGetOwner()) {
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
        //}
    }
}

state running
{
    state_entry()
    {
        // Request the first slide
        request_slide(1);
    }
    
    state_exit()
    {
        llSetText("", <0.0, 0.0, 0.0>, 0.0);
        llSetTimerEvent(0.0);
    }
    
    touch_start(integer num)
    {
        // Find out what was touched
        string buttonname = llGetLinkName(llDetectedLinkNumber(0));
        if (buttonname == "next") {
            next_slide();
        } else if (buttonname == "previous") {
            previous_slide();
        } else if (buttonname == "reset") {
            request_slide(1);
        } else if (buttonname == "update") {
            requestConfigData=1; // in default data state request config data to ensure
            //controller settings proliferate into SL - ie: someone changed the presentation this presenter is pointing to via the             requestConfigData=1; // in default data state request config data to ensure
            //controller settings proliferate into SL - ie: someone changed the presentation this presenter is pointing to via the web
            state default;
        }
    }
    
    on_rez(integer par) { llResetScript(); }
    
    timer()
    {
        
        llSetTimerEvent(0.0);
        if (reset == TRUE){
            reset = FALSE;
            llResetScript();
        } else {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
            update_hover_text();
            update_image_display();
        }
    }
    
    http_response(key id, integer status, list meta, string body)
    {
        // Is this the expected data?
        if (id != httploadpresentation) {
            return;
        }
        httploadpresentation = NULL_KEY;
        llSetTimerEvent(0.0);
        
        // Make sure the request worked
        if (status != 200) {
            sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
            return;
        }

        // Make sure there is a body to the request
        if (body == "") {
            sloodle_debug("Body of HTTP response was empty.");
            return;
        }
        
        // Split the data up into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);  
        integer numlines = llGetListLength(lines);
        if (numlines < 2) {
            sloodle_debug("HTTP response contained only 1 line - expected at least 2 for a correctly formatted response.");
            return;
        }
        // Extract all the status fields
        list statusfields = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
        // Get the statuscode
        integer statuscode = llList2Integer(statusfields,0);
        
        // Was it an error code?
        if (statuscode == -131) {
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0, 1.0, 0.0>, 1.0], "error:noplugins", [], NULL_KEY, "presenter");
            return;
            
        } else if (statuscode == -10501) {
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0, 1.0, 0.0>, 1.0], "error:noslides", [], NULL_KEY, "presenter");
            return;
            
        } else if (statuscode <= 0) {
            
            // Do we have an error message to go with it?
            if (numlines > 1) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "sloodleerror:desc", [statuscode, llList2String(lines, 1)], NULL_KEY, "");
            } else {
               // sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "sloodleerror", [statuscode], NULL_KEY, "");
               sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); //send message to error_message.lsl
            }
            
            return;
        }
        
        // The first data line contains two things: the number of slides, and the name of the Presenter
        list fields = llParseStringKeepNulls(llList2String(lines, 1), ["|"], []);
        if (llGetListLength(fields) < 2) {
            sloodle_debug("Expected at least 2 fields on first data line.");
            return;
        }
        numslides = (integer)llList2String(fields, 0);
        presentername = llList2String(fields, 1);
        fields = [];
        
        // Make sure we have another line, which will be the current slide data.
        if (numlines < 3) {
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [<0.0, 1.0, 0.0>, 1.0], "error:noslides", [], NULL_KEY, "presenter");
            return;
        }
        
        // This line should contain at least 4 fields: num | type | source | name.
        // If the "type" value is "ERROR" then the plugin could not be loaded.
        fields = llParseStringKeepNulls(llList2String(lines, 2), ["|"], []);
        if (llGetListLength(fields) < 4) {
            sloodle_debug("Expected at least 4 fields of slide data in second data line.");
            return;
        }
        curslidenum = (integer)llList2String(fields, 0);
        curslidetype = llList2String(fields, 1);
        curslidesource = llList2String(fields, 2);
        curslidename = llList2String(fields, 3);
        
        // Now that we've got all that data, update the display
        update_hover_text();
        update_image_display();
    }
    
    changed(integer change) {
     if (change ==CHANGED_INVENTORY){         
        if ((string)llGetInventoryKey(PRESENTER_TEXTURE)=="00000000-0000-0000-0000-000000000000"){                 
                  sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_BASIC, [<0.92748, 0.00000, 0.42705>, 1.0], "stilldoesntexistininventory", [], NULL_KEY, "presenter"); 
                  
            }else{
                llSetTexture(PRESENTER_TEXTURE,ALL_SIDES);
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_BASIC, [<0.92748, 0.00000, 0.42705>, 1.0], "foundsloodletexture", [], NULL_KEY, "presenter");
                reset=TRUE;
                llSetTimerEvent(3.0);
                      
            }
     }
    }

}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/presenter-2.0/sloodle_mod_presenter-shared-media-2.0.lsl


//
// The line above should be left blank to avoid script errors in OpenSim.

// UStream Viewer
// 
// Copyright (c) 2012 contributors (see below)
//
// Contributors:
//  Edmund Edgar
//  Paul Preibisch
//
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651; // this channel is used to send status codes for translation to the error_messages lsl script
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;

string SLOODLE_EOF = "sloodleeof";

string SLOODLE_OBJECT_TYPE = "ustreamviewer-1.0";

integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1; 
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
string sloodleustreamchannel = "";

integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?

integer lastmessagetimestamp = 0;
integer messagetimestamp = 0;
 
///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

integer SLOODLE_CHANNEL_OPEN_IN_BROWSER= -1639277000;

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

integer MEDIA_FACE=3;

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

//update screen    
update_media(string hash) {
    
    string url = view_url+hash;
    llSetPrimMediaParams( MEDIA_FACE, [     PRIM_MEDIA_CURRENT_URL, url,
                                PRIM_MEDIA_HOME_URL,  url, 
                                PRIM_MEDIA_FIRST_CLICK_INTERACT, TRUE, 
                                PRIM_MEDIA_AUTO_ZOOM, TRUE, 
                                PRIM_MEDIA_AUTO_PLAY, TRUE, 
                                PRIM_MEDIA_PERMS_INTERACT,  PRIM_MEDIA_PERM_ANYONE, 
                                PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE
                            ] );  
        
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
        
    } 
    else if (name == "set:sloodleustreamchannel") sloodleustreamchannel = (string)value1;

    
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "");
}

// Default state - waiting for configuration

default
{
    on_rez( integer param)
    {
       llResetScript();
    }
    state_entry()
    {
     
        llClearPrimMedia(MEDIA_FACE);    
    
        // Starting again with a new configuration
        isconfigured = FALSE;
        eof = FALSE;
        // Reset our data
        sloodleserverroot = "";
        sloodlepwd = "";
        sloodlecontrollerid = 0;
        sloodlemoduleid = 0;
        sloodleustreamchannel = "";
        
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
       llClearPrimMedia(MEDIA_FACE);  
        paramstr = "&sloodleobjuuid=" + (string)llGetKey();
        paramstr = paramstr + "&ts="+(string)llGetUnixTime();
        view_url= sloodleserverroot+"/mod/sloodle/mod/ustreamviewer-1.0/shared_media/index.php?" + paramstr;
        update_media("");
                                      
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
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
            
        } else if (num == SLOODLE_CHANNEL_OPEN_IN_BROWSER) {
                
            if (sloodleustreamchannel == "") {
                llSay(0, "The ustream channel to display on this viewer hasn't been set yet.");
            } else {
                llSay(0, "To view this screen in your browser, go to:\n"+"http://www.ustream.tv/channel/"+sloodleustreamchannel);
            }
        }

    } 
    
    
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/ustreamviewer-1.0/objects/default/assets/ustream_screen.lslp

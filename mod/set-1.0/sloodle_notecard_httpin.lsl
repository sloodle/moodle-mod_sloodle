// Sloodle configuration notecard reader
// Reads a configuration notecard and transmits the data via link messages to other scripts
// If the notecard changes, then it automatically resets.
//
// Part of the Sloodle project (www.sloodle.org)
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield


integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
string SLOODLE_CONFIG_NOTECARD = "sloodle_config";
string SLOODLE_EOF = "sloodleeof";

key sloodle_notecard_key = NULL_KEY;
integer sloodle_notecard_line = 0;

string COMMENT_PREFIX = "//";

key latestnotecard = NULL_KEY; // The most recently read notecard
string notecarddata = "";
string httpinurl = "";
integer isnotecarddone = 0;

string sloodlepwd = "";
string sloodleserverroot = "";
string sloodlecontrollerid = "";
    

string SLOODLE_HTTP_IN_REQUEST_LINKER = "/mod/sloodle/classroom/httpin_config_linker.php";
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL = -1639270089; //Object creator telling itself it wants to rez an object at a position (specified as key)

sloodle_start_reading_notecard()
{
    // Do we have a configuratio notecard?
    if (llGetInventoryType(SLOODLE_CONFIG_NOTECARD) == INVENTORY_NOTECARD) {
        // Start reading it
        sloodle_notecard_line = 0;
        sloodle_notecard_key = llGetNotecardLine("sloodle_config", 0); // read the first line. The dataserver event will get the next one.
        latestnotecard = llGetInventoryKey(SLOODLE_CONFIG_NOTECARD);
    } else {
        latestnotecard = NULL_KEY;
    }
}

register_config_if_ready()
{
    if ( (httpinurl == "") || (isnotecarddone == 0) ) {
        return;
    }
    if ( ( sloodleserverroot == "") || (sloodlepwd == "") ) {
        return;
    }

   // llOwnerSay("need to talk to "+sloodleserverroot+" and have them register me and send me my config");
                
    //send to httpin_config_linker
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodleobjuuid=" + (string)llGetKey();
    body += "&childobjectuuid=" + (string)llGetKey();
    body += "&httpinurl=" + httpinurl;
    body += "&sloodleobjname=" + llGetObjectName();
    body += notecarddata;
    //llOwnerSay("requested config with body "+body); 
    llHTTPRequest(sloodleserverroot + SLOODLE_HTTP_IN_REQUEST_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);        
}

default 
{
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    state_entry() 
    {
        // Pause for a moment, in case all scripts were reset at the same time
        llSleep(0.2);
        // Go!
        sloodle_start_reading_notecard();
    }
    
    dataserver(key requested, string data)
    {
        if ( requested == sloodle_notecard_key )  // make sure we are getting the data we want
        {
            sloodle_notecard_key = NULL_KEY;
            if ( data != EOF )
            {
                // If this is a comment line, then do not forward it
                string trimmeddata = llStringTrim(data, STRING_TRIM_HEAD);
                if (llSubStringIndex(trimmeddata, COMMENT_PREFIX) != 0) {
                
                    list bits = llParseString2List(data,["|"],[]);
                    integer numbits = llGetListLength(bits);
                    string name = llList2String(bits,0);
                    string value1 = "";    
                    if (numbits > 1) value1 = llList2String(bits,1);
                                    
                    if (name == "set:sloodleserverroot") sloodleserverroot = value1;
                    else if (name == "set:sloodlepwd") sloodlepwd = value1;
                    else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = value1;
                    else notecarddata = notecarddata + "&" + name + "=" + value1;              
                
                }
            
                // Advance to the next line
                sloodle_notecard_line++;
                sloodle_notecard_key = llGetNotecardLine("sloodle_config",sloodle_notecard_line);
            } else {
                isnotecarddone = 1;
                register_config_if_ready();
            }
        }
    }
    
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL) {
            httpinurl = str;
            register_config_if_ready();
        }
    }
    
    changed(integer change) {
        // If the inventory is changed, and we have a Sloodle config notecard, then use it to re-initialise
        if (change & CHANGED_INVENTORY && llGetInventoryType(SLOODLE_CONFIG_NOTECARD) == INVENTORY_NOTECARD) {
            // If the current notecard is not the same as the one we read most recently, then reset
            if (llGetInventoryKey(SLOODLE_CONFIG_NOTECARD) != latestnotecard) llResetScript();
        }
    }
    
    
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_notecard_httpin.lsl

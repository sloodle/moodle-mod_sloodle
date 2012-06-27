//
// The line above should be left blank to avoid script errors in OpenSim.

/*
* btn_connect_hud.lsl
* Part of the Sloodle project (www.sloodle.org)
* 
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
* 
* Contributors:
*  Edmund Edgar
*  Paul Preibisch
*/

string view_url;
string admin_url;
string sloodleserverroot = "";
string paramstr;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_SET_ADMIN_URL_CHANNEL= -1639271128; // This is the channel that the scoreboard shouts out its admin URL
integer SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_CHANGE_ADMIN_URL_CHANNEL= -1639271129; // This is the channel that the scoreboard shouts out its admin URL WHEN It has changed due to a region event (lost its url etc)
integer SLOODLE_SCOREBOARD_CONNECT_HUD= -1639271130; // channel which gets sent a linked message by the connect a hud button when it is touched.
sloodle_handle_command(string str) 
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
}

default
{
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
          paramstr = "&sloodleobjuuid=" + (string)llGetKey();
        view_url= sloodleserverroot+"/mod/sloodle/mod/scoreboard-1.0/shared_media/index.php?" + paramstr;
        admin_url =  sloodleserverroot+"/mod/sloodle/mod/scoreboard-1.0/shared_media/index.php?" + paramstr + "&mode=admin";
        
    
    }
 
    link_message(integer sender_num, integer num, string str, key id) {
     if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;

            for (i=0; i < numlines; i++) {
                sloodle_handle_command(llList2String(lines, i));
            }
     }
    
    }
touch_start( integer total_number)
    {
        if (llDetectedKey(0)!=llGetOwner())return;
        llMessageLinked(LINK_ALL_OTHERS, SLOODLE_SCOREBOARD_CONNECT_HUD, "", llDetectedKey(0));
   //  llOwnerSay("Connecting HUD "+(string)SLOODLE_SCOREBOARD_CONNECT_HUD);
        llTriggerSound("SND_TRANSMIT_SCOREBOARD_ID_TO_HUD", 1);
    }
}


// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/scoreboard-1.0/objects/default/assets/sloodle_connect_button.lslp 

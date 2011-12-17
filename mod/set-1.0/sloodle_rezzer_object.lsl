/*********************************************
*  Copyright (c) 2009 - 2011 various contributors (see below)
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  sloodle_rezzer_object
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL) fire@avatarclassroom.com  
*  Edmund Edgar (Edmund Earp in SL) ed@avatarclassroom.com
*
*  This script will get an httpin url, and shout it out to the rezzer.  It will then wait to receive its config via httpin, and send it as a linked message to all other scripts
*/

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;//configuration channel
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL = -1639270089; //Object creator telling itself it wants to rez an object at a position (specified as key)

string SLOODLE_HTTP_IN_REQUEST_LINKER = "/mod/sloodle/classroom/httpin_config_linker.php";
string SLOODLE_HTTP_IN_UPDATE_LINKER = "/mod/sloodle/classroom/httpin_url_update_linker.php";
string SLOODLE_PING_LINKER = "/mod/sloodle/classroom/active_object_ping_linker.php";

float PING_DELAY = 3600.0; // Number of seconds between pings. NB This is assumed to by 3600 by Active Object, which will stop trying to send http-in messages to objects older than that.
float PING_RETRY_DELAY = 600.0; // Number of seconds to wait before retrying a failed ping.

string SLOODLE_EOF = "sloodleeof";

vector rezzer_position_offset;
rotation rezzer_rotation_offset;
key rezzer_uuid;
integer isconfigured = 0;
integer has_position = 0;
integer http_in_password = 0;

string sloodlepwd = "";
string sloodleserverroot = "";
string sloodlecontrollerid = "";

string myUrl;
string persistent_config; 

integer is_pinging = 0;
integer is_ping_retry = 0;

move_to_layout_position() {
    
    // llOwnerSay("todo: move to position "+(string)rezzer_position_offset+", rot "+(string)rezzer_rotation_offset+ " in relation to rezzer "+(string)rezzer_uuid);
    list rezzerdetails = llGetObjectDetails( rezzer_uuid, [ OBJECT_POS, OBJECT_ROT ] );
    vector rezzerpos = llList2Vector( rezzerdetails, 0 );
    rotation rezzerrot = llList2Rot( rezzerdetails, 1 );
    sloodle_set_pos( rezzerpos + ( rezzer_position_offset * rezzerrot ) );
    llSetRot( rezzerrot * rezzer_rotation_offset );

}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str, integer do_persist) 
{
   // llOwnerSay("handling command "+str);
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    
    if (numbits >= 1 ) {
        string name = llList2String(bits,0);
            
        string value1 = "";
        string value2 = "";
            
        if (numbits > 1) value1 = llList2String(bits,1);
        if (numbits > 2) value2 = llList2String(bits,2);

        if (name == "set:sloodleserverroot") { sloodleserverroot = value1;
        } else if (name == "set:sloodlepwd") { sloodlepwd = value1 + "|" + value2;
        } else if (name == "set:sloodlecontrollerid") { sloodlecontrollerid = value1;
        } else if (name == "set:position") {        
            rezzer_position_offset = (vector)llList2String(bits,1);
            rezzer_rotation_offset = (rotation)llList2String(bits,2);
            rezzer_uuid = llList2Key(bits,3);
            has_position = 1;
        } else if (name == "do:derez") {
            llDie();
        } else if ( (name=="do:requestconfig") || (name=="do:reset") ) {           
            string this_script = llGetScriptName();                
            integer n = llGetInventoryNumber(INVENTORY_SCRIPT); 
            while(n) {
                string script_name = llGetInventoryName(INVENTORY_SCRIPT, --n);
                // Reset all sloodle scripts. If for some reason we make a sloodle script that we don't want reset, call it "sloodle_reset".
                if ( (script_name != this_script) && (llGetSubString( script_name, 0, 7) == "sloodle_" ) && (llGetSubString( script_name, 0, 15) != "sloodle_noreset_" ) ) {
                    llResetOtherScript( script_name );
                    // llOwnerSay("resetting script "+script_name);
                }
            }
            // Give them a second to get started to avoid trying to configure them before they're ready.
            llSleep(1);
           
            state reinitialize;
           
        } else {
            if (do_persist == 1) {
              //  llOwnerSay("adding to persist");
                    persistent_config = persistent_config + "&" + name + "=" + value1;                     
            }
        }
    } 
    
    if ( (sloodleserverroot != "") && (sloodlecontrollerid != "") && (sloodlepwd != "") ) {
        isconfigured = 1;
    }                                        
    
    return isconfigured;
}

sloodle_tell_other_scripts(string msg, integer channel)
{    
    integer status_code;
    if (channel == 0) {
    // Don't know the channel yet - get it from the message.
        list lines;
        lines = llParseStringKeepNulls( msg, ["\n"], [] );
        string status_line = llList2String(lines, 0);
        list status_bits;
        status_bits = llParseStringKeepNulls( status_line, ["|"], [] );
       
        status_code = (integer)llList2String(status_bits, 0);

        if (status_code == 1) {
            status_code = SLOODLE_CHANNEL_OBJECT_DIALOG;
        }
    } else {
        status_code = channel;        
    }
    // config requests need a SLOODLE_EOF on the end.
    // this is a legacy from sending notecards line-by-line. 
    if (status_code == SLOODLE_CHANNEL_OBJECT_DIALOG) {
        msg = msg + "\n"+SLOODLE_EOF;
    }
   // llOwnerSay("sending msg with status code "+(string)status_code+": "+msg);
    llMessageLinked(LINK_SET, status_code, msg, NULL_KEY);
    
}

initialize() 
{
        //set timer to ask for config if config not received
        llSetTimerEvent(30);
        llSetText("", <1.0, 1.0, 1.0>, 1.0);
        rezzer_position_offset = <0,0,0>;
        rezzer_rotation_offset = <0,0,0,0>;
        rezzer_uuid = NULL_KEY;
        isconfigured = 0;
        has_position = 0;
        
        // http_in_password = 0;
        //get an httpin url
        if (myUrl != "") {
            llReleaseURL(myUrl);
        }        
        llRequestURL();    
//llOwnerSay("initialize requesting url");        
} 
//sends our configuration to the server
configure_from_persistent_config()
{
        
    //llOwnerSay("got a persistent config, trying to use that");    
    //send to httpin_config_linker
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodleobjuuid=" + (string)llGetKey();
    body += "&childobjectuuid=" + (string)llGetKey();
    body += "&httpinurl=" + myUrl;
    body += "&sloodleobjname=" + llGetObjectName();
    body += persistent_config;
    //llOwnerSay("requested config with body "+body); 
    //tell the server to initialize via httpin using the specified parameters.  Server will respond by sending an http response, AND the config via httpin, however
    //we will ingnore the http response, and instead, just use the httpin
    llHTTPRequest(sloodleserverroot + SLOODLE_HTTP_IN_REQUEST_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body+persistent_config);
             
}

update_http_in_url()
{
        
    //llOwnerSay("got a persistent config, trying to use that");    
    //send to httpin_config_linker
    string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
    body += "&sloodlepwd=" + sloodlepwd;
    body += "&sloodleobjuuid=" + (string)llGetKey();
    body += "&httpinurl=" + myUrl;
    //llOwnerSay("requested config with body "+body); 
    llHTTPRequest(sloodleserverroot + SLOODLE_HTTP_IN_UPDATE_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
             
}
sloodle_set_pos(vector targetposition){
    integer counter=0;
    while ((llVecDist(llGetPos(), targetposition) > 0.001)&&(counter<50)) {
        counter+=1;
        llSetPos(targetposition);
    }

}

default{
    
    state_entry() {
           
        llSleep(1.0);
        initialize();
        
    }

    on_rez(integer start_param) {
        //llOwnerSay("default got start_param"+(string)start_param);
        //http_in_password is sent from the server - it is a random password per object so that malicious users can't send
        //commands to this object.
        http_in_password = start_param;
        //if no start_param, that means we were not rezzed by the rezzer (could have been by a user pulling fom inventory)
        if (start_param > 0) {
            //makesure config is clean
            sloodleserverroot = "";
            sloodlecontrollerid = "";
            sloodlepwd = "";
            persistent_config = "";
        }
        
        initialize();        

    }          
        
    http_request(key id, string method, string body){
          if ((method == URL_REQUEST_GRANTED)){
//llOwnerSay("got url");        
                myUrl=body;
                //shout it out to the rezzer our httpinUrl
                //persistant config is the data in memory from previous initialization                
                 // If we have a persistent config,  
                if (persistent_config != "") {
                   // llOwnerSay("config from persistent");
                   //tell the server to configure us based on a configuration we had before which will will send via http request
                   //we will then receive the returned config from the server via http-in
                    configure_from_persistent_config();
                } else {
                   // llOwnerSay("no persistent, contacting rezzer");
                   //tell the rezzer to send us a configuration.  Rezzer will tell the server to send us a configuration using our http-in
                    llRegionSay(SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL,myUrl);
                    //tell any other scripts our http-in
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL, myUrl, NULL_KEY);                    
                }
          } else if (method == "POST"){     
                                                   
               //this is where our object receives data from from our server via http-in
                      
                list lines;
                lines = llParseStringKeepNulls( body, ["\n"], [] );
                
                list header_line;
                header_line = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
                
                // Position 10 should be the http_in_password
                // This is set once on initial config.
                // Once we've implemented object persistance, it should always be set.
                if (http_in_password == 0) {
                   // llOwnerSay("First time, setting http in password");                    
                    http_in_password = (integer)llList2String(header_line, 10);
                }
                
                if (http_in_password != (integer)llList2String(header_line, 10)) {
                   // llOwnerSay("Ignoring message - password mismatch");
                    llHTTPResponse(id, 401, "Unauthorized - HTTP-in password mismatch");
                      
                    return;
                }                
                
                llHTTPResponse(id, 200, "OK");                 

                string descriptor = "";
                if (llGetListLength(header_line) > 1) descriptor = llList2String(header_line, 3);
                integer do_persist = 0;   
                if ( (descriptor == "CONFIG_PERSISTENT") || (descriptor == "CONFIG") ) {
                    // blow the existing config away and start again
                    sloodleserverroot = "";
                    sloodlecontrollerid = "";
                    sloodlepwd = "";
                    persistent_config = "";
                    //This CONFIG_PERSISTENT setting is primarily for development purposes.  We turn this setting off via serverside
                    //when shipping, so our old settings are not saved in shipped versions.  However, users server always defaults to 
                    //CONFIG_PERSISTENT so their settings are saved, not developmental ones
                    //when the server sends a configuration via http-in, it tells the object to keep it in its resident memory
                    if (descriptor == "CONFIG_PERSISTENT") {
                        //this means that the script should store the config in its memory so that when it is taken into inventory, and re-rezzed, it will 
                        //still have a configuration
                        do_persist = 1;                        
                    }
                }
                integer numlines = llGetListLength(lines);
                integer i = 1;          
                for (i=1; i < numlines; i++) {
                    isconfigured = sloodle_handle_command(llList2String(lines, i), do_persist);                                 
                }                                                         
                                
                sloodle_tell_other_scripts(body,0);
                // This is the end of the configuration data
                llSleep(0.2);
                sloodle_tell_other_scripts(SLOODLE_EOF, 0);
                
                if (isconfigured == 1) {   
                    if (has_position == 1) {                                 
                        move_to_layout_position();
                    }
                    llSetTimerEvent(0);
                    state ready;
                }                
          }//endif
     }//http
     
     changed(integer change) {

        if ( (change & CHANGED_REGION_START) || (change & CHANGED_REGION ) ) {
            //Request new URL
            if (myUrl != "") {
                llReleaseURL(myUrl);
            }
            llRequestURL();
        }

     }
        
    timer() {
        initialize();
    }    
}

state ready {    

    on_rez(integer start_param)
    {
       // llOwnerSay("ready got start_param"+(string)start_param);
        http_in_password = start_param;
                
        if (start_param > 0) {
            sloodleserverroot = "";
            sloodlecontrollerid = "";
            sloodlepwd = "";
            persistent_config = "";
            llSleep(2.0); // Give the rezzer time to register us. Seems to be an issue on OpenSim, where everything is faster than SL.
        }
                
        state default;        
        
    }            
                                    
    state_entry()
    {        
        // llOwnerSay("ready state");
        // llOwnerSay(persistent_config);
        llListen(232323, "", rezzer_uuid, "");   
    
        // Ping the server at a random interval of the normal ping delay, so the server doesn't get hit by all objects at once.
        llSetTimerEvent( llFrand(PING_DELAY) ); 
    } 

    listen(integer channel, string name, key id, string message) {
    
        // Listen to the rezzer telling us it's moved, and move accordingly.
        
        // llOwnerSay(message);
    
        list bits = llParseString2List( message, ["|"], [] );
        vector change_pos = (vector)llList2String( bits, 0 );
        rotation change_rot = (rotation)llList2String( bits, 1 );
        vector parent_pos = (vector)llList2String( bits, 2);
        // llOwnerSay("got message" + message);       

        // Apply the position changes first, then the rotation
        vector before_pos = llGetPos();
        if (before_pos.z > 0) { // sometimes this comes out at 0, but we don't want to go to the corner of the sim
            sloodle_set_pos( before_pos - change_pos );
        }

        before_pos = llGetPos();
        rotation before_rot = llGetRot();

        //llOwnerSay("Rot: "+(string)llRot2Euler(change_rot));
        // llOwnerSay((string)(before_rot - change_rot));
        // llOwnerSay("new pos: "+(string)(llGetPos() + ( before_pos - parent_pos) * change_rot));
        //change_rot = llEuler2Rot( < 0, 0, 15 * DEG_TO_RAD > ); // pretend we rotated 15 degrees
        vector currentPosition = llGetPos();
        vector currentOffset = currentPosition - parent_pos;
        //llOwnerSay("I plan to be "+(string)llVecDist(currentOffset, <0,0,0>)+" from parent");
        vector rotatedOffset = currentOffset * change_rot;
        vector newPosition = parent_pos + rotatedOffset;
        sloodle_set_pos(newPosition);
        
        //llOwnerSay("new pos: "+(string)(llGetPos() + ( ( before_pos - parent_pos) * change_rot ) ) );        
        // llSetPos( before_pos + ( ( parent_pos - before_pos ) * change_rot ) );        
        
        llSetRot( llGetRot() * change_rot );

        //  llGetPos() + vPosOffset * llGetRot(), ZERO_VECTOR, llGetRot()        
        
    }    

    timer()
    {
        // Send our ping request
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodleobjuuid=" + (string)llGetKey();
        is_pinging = 1;
        llHTTPRequest(sloodleserverroot + SLOODLE_PING_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
    }

    http_response( key request_id, integer status, list metadata, string body ){ 

        is_pinging = 0;
        if (status == 200) {
            if (is_ping_retry == 1) {
                // Reintroduce the randomness we may have lost if the server went down.
                llSetTimerEvent(llFrand(PING_DELAY));
            } else {
                llSetTimerEvent(PING_DELAY);
            }
            is_ping_retry = 0;
        } else {
            is_ping_retry = 1;
            llSetTimerEvent(PING_RETRY_DELAY);
        } 

    }
                
    http_request(key id, string method, string body){

        if (method == URL_REQUEST_GRANTED){

            myUrl=body;            
            update_http_in_url();
                
        } else if (method == "POST"){                            
          
               //this is where we receive data from from our server
                list lines;
                lines = llParseStringKeepNulls( body, ["\n"], [] );

                list header_line;
                header_line = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
                
                // Position 10 should be the http_in_password
                // This is set once on initial config.
                // Once we've implemented object persistance, it should always be set.
                if (http_in_password == 0) {
                   // llOwnerSay("First time, setting http in password");                    
                    http_in_password = (integer)llList2String(header_line, 10);
                }
                
                if (http_in_password != (integer)llList2String(header_line, 10)) {
                   // llOwnerSay("Ignoring message - password mismatch");
                    llHTTPResponse(id, 401, "Unauthorized - HTTP-in password mismatch");  
                    return;
                }
                                             
                integer numlines = llGetListLength(lines);
                integer i = 0;   
              // llOwnerSay(body);
                if (llList2String(header_line,3) == "REPORT_POSITION") {
                    list rezzerdetails = llGetObjectDetails( rezzer_uuid, [ OBJECT_POS, OBJECT_ROT ] );
                    vector rezzerpos = llList2Vector( rezzerdetails, 0 );
                    rotation rezzerrot = llList2Rot( rezzerdetails, 1 );
                    string reply = (string)( ( llGetPos() - rezzerpos ) / rezzerrot ) + "|" + (string)(llGetRot() / rezzerrot) + "|" + (string)rezzer_uuid;
                    llHTTPResponse(id, 200, reply);
                    return;
                }
           
                
                llHTTPResponse(id, 200, "OK");                 
                string status_descriptor = "";
                string request_descriptor = "";                             
                integer do_persist = 0;
                if (llGetListLength(header_line) > 1) status_descriptor = llList2String(header_line, 1);
                if (llGetListLength(header_line) > 2) request_descriptor = llList2String(header_line, 3);                
                if ( (request_descriptor == "CONFIG_PERSISTENT") || (request_descriptor == "CONFIG") ) {
                    // blow the existing config away and start again
                    sloodleserverroot = "";
                    sloodlecontrollerid = "";
                    sloodlepwd = "";
                    persistent_config = "";
                    if (request_descriptor == "CONFIG_PERSISTENT") {
                        do_persist = 1;                        
                    }
                }
                if ( (status_descriptor == "CONFIG") || (status_descriptor=="SYSTEM") ){
                    for (i=1; i < numlines; i++) {
                        isconfigured = sloodle_handle_command(llList2String(lines, i), do_persist);
                    }
                } 
                                
                sloodle_tell_other_scripts(body, 0);
                // This is the end of the configuration data
                llSleep(0.2);
                sloodle_tell_other_scripts(SLOODLE_EOF, 0);
                                                                       
          }//endif
     }//http

    // TODO: Need a changed event for region etc to get a new url
    changed(integer change) {
        if ( (change & CHANGED_REGION_START) || (change & CHANGED_REGION ) ) {
            //Request new URL
            if (myUrl != "") {
                llReleaseURL(myUrl);
            }
            llRequestURL();
        }
    }         

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            sloodle_handle_command(str, 0);
        }
    }
}
        
state reinitialize {
    // force us to go into state default and run state_entry, which calls initialize
    // this allows us to get to that state from a function that doesn't know whether it's already in state default or not.
    state_entry() {
        state default;
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_rezzer_object.lsl


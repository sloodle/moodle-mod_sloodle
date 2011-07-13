/*********************************************
*  Copyrght (c) 2009 various contributors (see below)
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  sloodle_rezzer_object
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL) fire@b3dMultiTech.com  
*  Edmund Edgar (Edmund Earp in SL) ed@socialminds
*
*  This script will get an httpin url, and shout it out to the rezzer.  It will then wait to receive its config via httpin, and send it as a linked message to all other scripts
*/

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;//configuration channel
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL = -1639270089; //Object creator telling itself it wants to rez an object at a position (specified as key)

string SLOODLE_EOF = "sloodleeof";

vector rezzer_position_offset;
rotation rezzer_rotation_offset;
key rezzer_uuid;
integer isconfigured = 0;

string myUrl;


move_to_layout_position() {
    
   // llOwnerSay("todo: move to position "+(string)rezzer_position_offset+", rot "+(string)rezzer_rotation_offset+ " in relation to rezzer "+(string)rezzer_uuid);   

    list rezzerdetails = llGetObjectDetails( rezzer_uuid, [ OBJECT_POS, OBJECT_ROT ] );
    vector rezzerpos = llList2Vector( rezzerdetails, 0 );
    rotation rezzerrot = llList2Rot( rezzerdetails, 1 );
    llSetPos( rezzerpos + ( rezzer_position_offset * rezzerrot ) );
    llSetRot( rezzerrot * rezzer_rotation_offset );

}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    
    if (numbits >= 1 ) {
        string name = llList2String(bits,0);
        if (name == "set:position") {        
            rezzer_position_offset = (vector)llList2String(bits,1);
            rezzer_rotation_offset = (rotation)llList2String(bits,2);
            rezzer_uuid = llList2Key(bits,3);
            return 1;
        } else if (name == "do:derez") {
            llDie();
        } else if (name=="do:requestconfig") {
            llResetScript(); 
        }
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

default{
    state_entry() {    
        llSleep(1.0);
        llRequestURL();
    }

    on_rez(integer start_param) {
        llResetScript();
    }          
        
    http_request(key id, string method, string body){
          if ((method == URL_REQUEST_GRANTED)){
                myUrl=body;
                //shout it out to the rezzer our httpinUrl
                llRegionSay(SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL,myUrl);
                
                llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL, myUrl, NULL_KEY);
                
               // llOwnerSay("got url "+myUrl);
          } else if (method == "POST"){                            
               //this is where we receive data from from our server
                llHTTPResponse(id, 200, "OK");                       
                list lines;
                lines = llParseStringKeepNulls( body, ["\n"], [] );
                
                integer numlines = llGetListLength(lines);
                integer i = 0;          
                for (i=0; i < numlines; i++) {
                    isconfigured = sloodle_handle_command(llList2String(lines, i));                
                }                                                         
                
                sloodle_tell_other_scripts(body,0);
                // This is the end of the configuration data
                llSleep(0.2);
                sloodle_tell_other_scripts(SLOODLE_EOF, 0);
                
                if (isconfigured == 1) {
                    move_to_layout_position();
                    state ready;
                }                
          }//endif
     }//http
     
     changed(integer change) {
         if (change ==CHANGED_INVENTORY){         
             llResetScript();
         }
     }
}

state ready {    
            
    state_entry()
    {
        // llOwnerSay("ready state");
        llListen(232323, "", rezzer_uuid, "");        
    } 

    listen(integer channel, string name, key id, string message) {
    
       // llOwnerSay(message);
    
        list bits = llParseString2List( message, ["|"], [] );
        vector change_pos = (vector)llList2String( bits, 0 );
        rotation change_rot = (rotation)llList2String( bits, 1 );
        vector parent_pos = (vector)llList2String( bits, 2);
       // llOwnerSay("got message" + message);       

        // Apply the position changes first, then the rotation
        vector before_pos = llGetPos();
        if (before_pos.z > 0) { // sometimes this comes out at 0, but we don't want to go to the corner of the sim
            llSetPos( before_pos - change_pos );
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
        llSetPos(newPosition);
        
        //llOwnerSay("new pos: "+(string)(llGetPos() + ( ( before_pos - parent_pos) * change_rot ) ) );        
        // llSetPos( before_pos + ( ( parent_pos - before_pos ) * change_rot ) );        
        
        llSetRot( llGetRot() * change_rot );

        //  llGetPos() + vPosOffset * llGetRot(), ZERO_VECTOR, llGetRot()        
        
    }
    on_rez(integer start_param)
    {
        llResetScript();
    }
        
    http_request(key id, string method, string body){
          if (method == "POST"){                            
               //this is where we receive data from from our server
                list lines;
                lines = llParseStringKeepNulls( body, ["\n"], [] );
                
                integer numlines = llGetListLength(lines);
                integer i = 0;   
              // llOwnerSay(body);
                if (llList2String(lines,0) == "do:reportposition") {
                    list rezzerdetails = llGetObjectDetails( rezzer_uuid, [ OBJECT_POS, OBJECT_ROT ] );
                    vector rezzerpos = llList2Vector( rezzerdetails, 0 );
                    rotation rezzerrot = llList2Rot( rezzerdetails, 1 );
                    string reply = (string)( ( llGetPos() - rezzerpos ) / rezzerrot ) + "|" + (string)(llGetRot() / rezzerrot) + "|" + (string)rezzer_uuid;
                    llHTTPResponse(id, 200, reply);
                    return;
                }
                       
                llHTTPResponse(id, 200, "OK");                   

                for (i=0; i < numlines; i++) {
                    isconfigured = sloodle_handle_command(llList2String(lines, i));
                }                                                         
                                
                sloodle_tell_other_scripts(body, 0);
                // This is the end of the configuration data
                llSleep(0.2);
                sloodle_tell_other_scripts(SLOODLE_EOF, 0);
                
                                    
                       
          }//endif
     }//http

     changed(integer change) {
         if (change ==CHANGED_INVENTORY){         
             llResetScript();
         }
     }    
}


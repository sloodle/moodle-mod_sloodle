/*
*  teleporter_using_crystals.lsl
*  Part of the Sloodle project (www.sloodle.org)
*
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
*  -------------------------------------------
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  All scripts must maintain this copyrite information, including the contributer information listed
*
*  DESCRIPTION
*  This script was built for an adventure game which involves access to hidden chambers etc.
*  A user must collect a blue crystal, drop it onto the ground, to insert it into this teleporter
*  Once a crystal has been inserted, the teleporter will be activated for 30 seconds.
*  The teleporter makes use of the objects description input field, which you can find in the edit
*  box inside the Second Life viewer. 
*  Enter in: CHANNEL:99882234,NAME:Teleporter,REZSOUND:SND_dancershort,DROPSOUND:SND_splash2
*  CHANNEL: is the channel the blue crystal will use to communicate with this teleporter
*  NAME is the name of the object which the blue crystal will set its sensors for, and when found, move towards
*  REZSOUND is the name of the sound file that will play when this teleporter is rezzed
*  After a crystal shouts an INSERT message into this script, this script will send a linked message to 
*  sloodle_mod_touchable to see if the interaction (teleport) is allowed
*  sloodle_mod_touchable will contact the server, and respond via linked message if teleporting is allowed
*  ie: if the user's currency matches any restrictions placed in this objects configuration
*  if all restrictions have been fulfilled, the teleporter will teleport the sitting user to the destination
*  in the config.
*
*  THIS VERSION IS FOR OPENSIM - llAvatarSitOnTarget doesnt work in Opensim, so the behavior is modified: 
*  User must sdrop a crystal in to activate the teleporter, then sit, then click to tp
*
*  For this script to function properly, it should have the following sounds inside 
*  SND_POWER_DOWN
*  SND_POWER_UP
*  SND_SPARKS
*  SND_VORTEX   
*
*  Accompaning scripts:
*  sloodle_mod_touchable-1.0
*  sloodle_rezzer_object
*  sloodle_setup_notecard_httpin
*
*  Contributors:
*  Paul Preibisch
*  Edmund Edgar

* SND_SPARKS: http://www.freesound.org/people/Connum/
*/

// The Long distance telport script license info is below:
//Long distance teleport version 1.1
// ----------------------------------
// This script is based on other public domain free scripts, so I don't
// take credit for any of the work here.
// Bits and pieces combined by Lisbeth Cohen - plus added show/hide.
//
// The basics of the script is based on Till Sterling's simple teleport
// script, with cross sim transportation routine developed by
// Keknehv Psaltery, modified by Strife Onizuka, Talarus Luan and
// Keknehv Psaltery.
// The transportation functionality is based upon Nepenthes Ixchel's
// 1000m Menu-driven Intra-Sim Teleporter
//
// Thank you to authors who have given me permission to publish this script.
// A special thank you to Keknehv Psaltery for suggesting small improvements!
//
// Realeased as public domain - you are NOT allowed to sell it without the
// permissions of all the authors I've credited above (except those who
// may have left sl at the time)!
// Feel free to use it in freebies and to give it to your friends :-)
//
// Please do not take credit for the work of all those great authors
// mentioned above!
// If you edit the script, please do not change the lines above - thanks!
// ------------------------------------------------------------------------
string SLOODLE_EOF = "sloodleeof";
integer eof = FALSE; // Have we reached the end of the configuration data?
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;//configuration channel
integer isconfigured = 0;
integer MAX=30;
key sitter;
integer counter=0;
integer SLOODLE_TELPORTER_POWER_UP= -1639277101;
integer SLOODLE_TELPORTER_POWER_DOWN= -1639277102;
integer SLOODLE_OBJECT_INTERACTION= -1639271132; //channel interaction objects speak on
integer TARGET_CHANNEL;
string TARGET_NAME;
integer SLOODLE_TOUCH_OBJECT_SUCCESS = -1639277100;
vector RED =<1.00000, 0.00000, 0.00000>;
vector ORANGE=<1.00000, 0.43763, 0.02414>;
vector YELLOW=<1.00000, 1.00000, 0.00000>;
vector GREEN=<0.00000, 1.00000, 0.00000>;
vector BLUE=<0.00000, 0.00000, 1.00000>;
vector BABYBLUE=<0.00000, 1.00000, 1.00000>;
vector PINK=<1.00000, 0.00000, 1.00000>;
vector PURPLE=<0.57338, 0.25486, 1.00000>;
vector BLACK= <0.00000, 0.00000, 0.00000>;
vector WHITE= <1.00000, 1.00000, 1.00000>;

//order of animation messages 
key userKey;
vector MYDEST;

integer SLOODLE_NOT_ENOUGH_CURRENCY= -1001;//     AWARDS     You do not have enough points to use this object. (There may be a customized message in the next line.)
integer SLOODLE_OBJECT_REGISTER_INTERACTION= -1639271133; //channel objects send interactions to the mod_interaction-1.0 script on to be forwarded to server
debug(string str){
    //llOwnerSay(str);
}
string objecttogive;
integer soundCounter=0;
integer DOOR_STATE;
vector rezzer_position_offset;
rotation rezzer_rotation_offset;
key rezzer_uuid;

/***********************************************
*  extractResponse()
*  Is used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  By adding a context to the messages, the programmer can understand whats going on when debugging
*  All this function does is strip off the text before the ":" char 
***********************************************/
string extractResponse(string cmd){     
     return llList2String(llParseString2List(cmd, [":"],[]),1);
}
move_to_layout_position() {
    // llOwnerSay("todo: move to position "+(string)rezzer_position_offset+", rot "+(string)rezzer_rotation_offset+ " in relation to rezzer "+(string)rezzer_uuid);
    list rezzerdetails = llGetObjectDetails( rezzer_uuid, [ OBJECT_POS, OBJECT_ROT ] );
    vector rezzerpos = llList2Vector( rezzerdetails, 0 );
    rotation rezzerrot = llList2Rot( rezzerdetails, 1 );
    sloodle_set_pos( rezzerpos + ( rezzer_position_offset * rezzerrot ) );
    llSetRot( rezzerrot * rezzer_rotation_offset );

}
sloodle_set_pos(vector targetposition){
    integer counter=0;
    while ((llVecDist(llGetPos(), targetposition) > 0.001)&&(counter<50)) {
        counter+=1;
        llSetPos(targetposition);
    }

}
vector getVector(string s){       
       list vector_parts = llParseString2List(s,["<",",",">"], []);
       vector result;
       result.x = llList2Float(vector_parts,0);
       result.y = llList2Float(vector_parts,1);
       result.z = llList2Float(vector_parts,2);
return result;
}

integer sloodle_handle_command(string str){
   // llOwnerSay("handling command "+str);
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    
   string name;
    if (numbits >= 1 ) {
        name = llList2String(bits,0);
           
        string value1 = ""; 
        string value2 = ""; 
           
        if (numbits > 1) value1 = llList2String(bits,1);
        if (numbits > 2) value2 = llList2String(bits,2);

     
    } 
        if (name == "set:destination") {
              MYDEST= getVector(llList2String(bits,1));
              llOwnerSay("Teleporter Destination: "+(string)MYDEST); 

        }else
         if (name == "set:position") {        
            rezzer_position_offset = (vector)llList2String(bits,1);
            rezzer_rotation_offset = (rotation)llList2String(bits,2);
            rezzer_uuid = llList2Key(bits,3);

         }
    
    return TRUE; 
}

trytoTp(key av){
        //when touched, tell mod_interaction script that a water action has occured
        llMessageLinked(LINK_SET, SLOODLE_OBJECT_REGISTER_INTERACTION, "accessteleporter", av);
          llSay(0,"Attempting to Teleport");
}
list give_in_folder;
integer item_no = 0;

 
//The target location .. change this to where you want to end up (x, y, z)
vector gTargetPos = <246, 181, 415>;
// Text for the "pie menu"
string gSitText="Teleport";
// Return position for tp object - no need to edit
vector gStartPos=<0,0,0>;
// Key for avatar sitting on object, if any
key gAvatarID=NULL_KEY;
// If you don't enable this the teleport object will be left at the destination.
integer gReturnToStartPos=TRUE;
 
// This routine do the actual transport
warpPos( vector destpos)
{   //R&D by Keknehv Psaltery, 05/25/2006
        //with a little pokeing by Strife, and a bit more
        //some more munging by Talarus Luan
        //Final cleanup by Keknehv Psaltery
        // Compute the number of jumps necessary
        integer jumps = (integer)(llVecDist(destpos, llGetPos()) / 10.0) + 1;
        // Try and avoid stack/heap collisions
        if (jumps > 100 )
        jumps = 100;    //  1km should be plenty
        list rules = [ PRIM_POSITION, destpos ];  //The start for the rules list
        integer count = 1;
        while ( ( count = count << 1 ) < jumps)
        rules = ([]) + rules + rules;   //should tighten memory use.
        llSetPrimitiveParams( rules + llList2List( rules, (count - jumps) << 1, count) );
        if (sitter!=NULL_KEY){
            llUnSit(sitter);
        }
        move_to_layout_position();
}
string teleporter="OFF";
        integer count=0;
default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        llSetText("OFF", RED, 1);
        llSitTarget ( <-0.00000, 0.00000, 1.20565>, <0.00000, 0.00000, 0.00000, 1.00000>);
        string objDesc=llGetObjectDesc();
        list objD = llParseString2List(objDesc, [","], []);
        TARGET_CHANNEL=(integer)extractResponse(llList2String(objD,0));
        TARGET_NAME=extractResponse(llList2String(objD,1));
        llTriggerSound("SND_POWER_DOWN", 1);
        llOwnerSay("Teleporter Starting up, listening for crystals on channel : "+(string)TARGET_CHANNEL);
        llListen(TARGET_CHANNEL, "", "", "");
        
    }
    listen(integer channel, string name, key id, string message) {
        if (channel==TARGET_CHANNEL){
            //llShout(TARGET_CHANNEL,"COMMAND:INSERT|NAME:"+llGetObjectName()+"|AVUUID:"+(string)llGetOwner());
            list data = llParseString2List(message, ["|"], []);
            string command = extractResponse(llList2String(data,0));
            if (command=="INSERT"){
                key user=extractResponse(llList2String(data,1));
                llSay(0,llKey2Name(user)+", the teleporter is ready! Sit on it to teleport and escape Devil's island!!"); 
                teleporter="ON";
                llTriggerSound("SND_POWER_UP", 1);
                integer SLOODLE_TELPORTER_POWER_UP= -1639277102;
                llSetTimerEvent(1);
                count =0;
            }
            
        }
    
    }
    timer() {
        count++;
        llSetText("You have ("+(string)(30-count)+") seconds left to sit and teleport!", RED, 1);
        if (count>30){
            llSetTimerEvent(0);
            teleporter="OFF";
            
            llTriggerSound("SND_POWER_DOWN", 1);
            llMessageLinked(LINK_SET, SLOODLE_TELPORTER_POWER_DOWN, "", NULL_KEY);
           llSetText("OFF", RED, 1);
        }
    }
    changed(integer change) {
         if ((change & CHANGED_LINK) != 0){
               if (teleporter=="OFF"){
                       llSay(0,"This teleporter needs energy! You must put a crystal into the teleporter first!!");
                       llTriggerSound("SND_SPARKS", 1);
               }else{
                       llSay(0,"Touch Teleporter to teleport!");
               } 
            
            } 
         
    }  
    touch_start(integer num_detected) {
    	 if (teleporter=="OFF"){
                       llSay(0,"This teleporter needs energy! You must put a crystal into the teleporter first!!");
                       llTriggerSound("SND_SPARKS", 1);
               }else{
			        sitter = llDetectedKey(0);
			        trytoTp(sitter);
			                      
               } 
        
    }
    link_message(integer sender_num, integer num, string str, key id) {
         // Split the data up into lines
        list lines = llParseStringKeepNulls(str, ["\n"], []);  

        integer numlines = llGetListLength(lines);
        // Extract all the status fields
        list statusfields = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
        // Get the statuscode
        integer statuscode = llList2Integer(statusfields,0);
        key user = llList2Key(statusfields,6);
        // Was it an error code?
        
     if (num==SLOODLE_TOUCH_OBJECT_SUCCESS){
                
      } 
      if (num==SLOODLE_OBJECT_INTERACTION){
      	if (statuscode==1){
      		if (llList2String(lines,1)=="accessteleporter"){
      			llSay(0,"Teleporting to: "+(string)MYDEST);
                llTriggerSound("SND_TELEPORTING", 0.7);
                warpPos(MYDEST);
      		}
      	}
      }
         if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            return;
        }
          
       
      }
}
 
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/interaction-1.0/object_scripts/teleporter_using_crystals_for_opensim.lsl 

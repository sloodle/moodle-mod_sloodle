/*
*  magicchest.lsl
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
*  A user must collect X currency in order to unlock and open this door through touch
*
*  
*  A touch action will check to see if the user has X currency in their inventory, and if so 
*  instruct the chest to open
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
//order of animation messages 
key userKey;
vector MYDEST;
vector RED =<1.00000, 0.00000, 0.00000>;
integer SLOODLE_NOT_ENOUGH_CURRENCY= -1001;//     AWARDS     You do not have enough points to use this object. (There may be a customized message in the next line.)
integer SLOODLE_OBJECT_REGISTER_INTERACTION= -1639271133; //channel objects send interactions to the mod_interaction-1.0 script on to be forwarded to server
debug(string str){
    //llOwnerSay(str);
}
string objecttogive;
integer soundCounter=0;
integer DOOR_STATE;


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
              MYDEST= llList2Vector(bits,1); 
        }
    
    return TRUE; 
}

trytoTp(){
        //when touched, tell mod_interaction script that a water action has occured
        llMessageLinked(LINK_SET, SLOODLE_OBJECT_REGISTER_INTERACTION, "accessteleporter", llDetectedKey(0));
        llSay(0,"Attempting to access the teleporter");
        llTriggerSound("SND_SPARKS", 0.7);
}
list give_in_folder;
integer item_no = 0;

 
//The target location .. change this to where you want to end up (x, y, z)
vector gTargetPos = <246, 181, 415>;
// Text for the "pie menu"
string gSitText="Teleport";
// Define channel number to listen to user commands from
integer myChannel = 123;
 
// No need to edit the global variables below
 
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
        rules = (rules=[]) + rules + rules;   //should tighten memory use.
        llSetPrimitiveParams( rules + llList2List( rules, (count - jumps) << 1, count) );
}
default {
    changed(integer change) {
         if(change & (CHANGED_LINK)){
             sitter = llAvatarOnSitTarget();
            if (sitter!=NULL_KEY){
                trytoTp();
            } 
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
        
         if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            return;
        }
        if (statuscode <= 0) {
            //error will come if u dont have enough water.
            if (statuscode==SLOODLE_NOT_ENOUGH_CURRENCY){
                                 
                 if (sitter!=NULL_KEY){
                    llUnSit(sitter);
                 }
            }
        }
        else{
            string task = llList2String(lines, 1);
            if (task=="tryopenchest"){
                llSay(0,"Prepare to Teleport!");
                llTriggerSound("SND_VORTEX", 1);
                warpPos(MYDEST);
            }
        
      } 
    }
}
 
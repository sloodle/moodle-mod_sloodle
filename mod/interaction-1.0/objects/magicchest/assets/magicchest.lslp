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

* SND_CHEST_OPEN: http://www.freesound.org/people/dobroide/ under http://creativecommons.org/licenses/by/3.0/
* SND_KEYS: http://www.freesound.org/people/dobroide/ under http://creativecommons.org/licenses/by/3.0/
* SND_CHEST_CLOSE: http://www.freesound.org/people/dobroide/ under http://creativecommons.org/licenses/by/3.0/
*/
string SLOODLE_EOF = "sloodleeof";
integer eof = FALSE; // Have we reached the end of the configuration data?
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;//configuration channel
integer isconfigured = 0;
integer MAX=30;
integer counter=0;
//order of animation messages 
key userKey;
vector RED =<1.00000, 0.00000, 0.00000>;
integer SLOODLE_NOT_ENOUGH_CURRENCY= -1001;//     AWARDS     You do not have enough points to use this object. (There may be a customized message in the next line.)
integer SLOODLE_OBJECT_REGISTER_INTERACTION= -1639271133; //channel objects send interactions to the mod_interaction-1.0 script on to be forwarded to server
debug(string str){
   // llSay(0,str);
}
string objecttogive;
integer soundCounter=0;
playDoorKnockSound(){
    list snds= ["SND_CHEST_KEYS"];
    llTriggerSound(llList2String(snds, soundCounter),1);
    soundCounter++;
    if (soundCounter>llGetListLength(snds)-1){
        soundCounter=0;
        snds=llListRandomize(snds, 1);
    }
}
integer DOOR_STATE;
integer OPEN=-1;
integer CLOSED=1;
doorClose(){
    counter=0;
    llSetTimerEvent(0);
    llTriggerSound("SND_CHEST_CLOSE", 1);
    llMessageLinked(LINK_SET, -99, "p0", NULL_KEY);
    
    llSetText("", RED, 1);
    DOOR_STATE=CLOSED;
    llSetText("", RED, 1);
}
doorOpen(){
    counter=0;
    DOOR_STATE=OPEN;
    //status is > 0 so it is a success, user has enough currency so we can open the door
    llTriggerSound("SND_CHEST_OPEN", 1);
    llSay(0,"Chest is opened!");
    llMessageLinked(LINK_SET, -99, "p1", NULL_KEY);
    llSleep(1);
    
    llSetTimerEvent(1);
}
knock(){
        //when touched, tell mod_interaction script that a water action has occured
        llMessageLinked(LINK_SET, SLOODLE_OBJECT_REGISTER_INTERACTION, "tryopenchest", llDetectedKey(0));
        llSay(0,"Attempting to open the chest");
        llTriggerSound("SND_KEYS", 1);
}
list give_in_folder;


 integer item_no = 0;
default {
    state_entry() {
      doorClose();
    }
    touch_start(integer num_detected) {
        integer j;
        for (j=0;j<num_detected;j++){
            if (DOOR_STATE==CLOSED){
                knock();
            }else{
                llTriggerSound("chimes", 1);
                item_no = 0;
                give_in_folder =[];
                for ( item_no= 0 ; item_no < llGetInventoryNumber( INVENTORY_ALL ) ;item_no++ ){
                    string name = llGetInventoryName( INVENTORY_ALL, item_no ); 
                     if ( name != llGetScriptName() ){
                        give_in_folder += [ name ];
                    }
                }
                llGiveInventoryList ( llDetectedKey(0), llGetObjectName(), give_in_folder );
            }
        }
    }
    link_message(integer sender_num, integer num, string str, key id) {
         // Split the data up into lines
         str = llStringTrim(str, STRING_TRIM);
         list lines = llParseStringKeepNulls(str, ["\n"], []);  
        integer numlines = llGetListLength(lines);
        // Extract all the status fields
        list statusfields = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
        // Get the statuscode
        integer statuscode = llList2Integer(statusfields,0);
        key user = llList2Key(statusfields,6);
        // Was it an error code?
        
        
        llSay(0,"*** status code is:"+(string)statuscode);
        if (statuscode==1){
            string task = llList2String(lines, 1);
            if (task=="tryopenchest"){
                doorOpen();
            }
           
        }else
        if (statuscode <= 0) {
            //error will come if u dont have enough water.
            if (statuscode==SLOODLE_NOT_ENOUGH_CURRENCY){
                 playDoorKnockSound();
            }
        }
        
      
    
    }
    
    timer() {
        counter++;
        if (counter>MAX){
            doorClose();
        }
        if ((MAX-counter)>0){
            llSetText("Closing chest in: "+(string)(MAX-counter)+" seconds!", RED, 1);
        }
        
    
    }
} 



// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/interaction-1.0/objects/magicchest/assets/magicchest.lslp 

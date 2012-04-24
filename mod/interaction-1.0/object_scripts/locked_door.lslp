/*
*  lockeddoor.lsl
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
*  instruct the door to open
*
*  Contributors:
*  Paul Preibisch
*  Edmund Edgar
*/
integer MAX=30;
integer counter=0;
//order of animation messages 
key userKey;
vector RED =<1.00000, 0.00000, 0.00000>;
integer SLOODLE_NOT_ENOUGH_CURRENCY= -1001;//     AWARDS     You do not have enough points to use this object. (There may be a customized message in the next line.)
integer SLOODLE_OBJECT_REGISTER_INTERACTION= -1639271133; //channel objects send interactions to the mod_interaction-1.0 script on to be forwarded to server
debug(string str){
    //llOwnerSay(str);
}
integer soundCounter=0;
playDoorKnockSound(){
    list snds= ["SND_DOOR_I_TOLD_U_GO_AWAY","SND_DOOR_COME_BACK_LATER","SND_GO_AWAY","SND_DOOR_DONT_MAKE_ME_COME_OUT_THERE_GO_AWAY","SND_DOOR_GETTING_ANGRY","SND_DOOR_HEARING_PROBLEM"];
    llTriggerSound(llList2String(snds, soundCounter),1);
    soundCounter++;
    if (soundCounter>llGetListLength(snds)-1){
        soundCounter=0;
        snds=llListRandomize(snds, 1);
    }
}
playDoorCloseSound(){
        list snds= ["SND_THANKYOU_DONT_COME_AGAIN","SND_DONT_COME_AGAIN"];
    llTriggerSound(llList2String(snds, soundCounter),1);
        soundCounter++;
        if (soundCounter>llGetListLength(snds)-1){
            soundCounter=0;
            snds=llListRandomize(snds, 1);
    }
}

playDoorOpenSound(){
        list snds= ["SND_U_LOOK_FAMILIAR","SND_COME_IN_1","SND_COMEIN_5"];
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
    llTriggerSound("SND_DOOR_CLOSE", 1);
    llMessageLinked(LINK_SET, -99, "p0", NULL_KEY);
    playDoorCloseSound();
    llSetText("", RED, 1);
    DOOR_STATE=CLOSED;
}
doorOpen(){
    counter=0;
    DOOR_STATE=OPEN;
    //status is > 0 so it is a success, user has enough currency so we can open the door
    llTriggerSound("SND_SQUEEKY_DOOR_OPEN", 1);
    llSay(0,"Door is opened!");
    llMessageLinked(LINK_SET, -99, "p1", NULL_KEY);
    llSleep(1);
    playDoorOpenSound();
    llSetTimerEvent(1);
}
knock(){
        //when touched, tell mod_interaction script that a water action has occured
        llMessageLinked(LINK_SET, SLOODLE_OBJECT_REGISTER_INTERACTION, "knockknock", llDetectedKey(0));
        llSay(0,"Attempting to open the door");
        llTriggerSound("SND_DOOR_KNOCK", 1);
}
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
                doorClose();
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
        debug(str);
        if (statuscode <= 0) {
            //error will come if u dont have enough water.
            if (statuscode==SLOODLE_NOT_ENOUGH_CURRENCY){
                 playDoorKnockSound();
            }
            string msg;
            if (numlines > 1) {
                msg = llList2String(lines, 1);
            }
             return;
        }else{
            string task = llList2String(lines, 1);
            if (task=="knockknock"){
                doorOpen();
            }
        }
    }
    
    timer() {
        counter++;
        if (counter>MAX){
            doorClose();
        }
        if ((MAX-counter)>0){
            llSetText("Closing door in: "+(string)(MAX-counter)+" seconds!", RED, 1);
        }
        
    
    }
} 

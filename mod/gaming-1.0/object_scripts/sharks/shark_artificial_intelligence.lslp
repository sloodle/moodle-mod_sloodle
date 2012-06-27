/*
*  shark attack.lsl
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
*  This script is the artificial intellegence for the sharks in the pool.
*
*  
*  This script causes a shark to swim around
*
*  Contributors:
*  Paul Preibisch
*  Edmund Edgar

* screams sound file comes from http://www.freesound.org/people/thanvannispen/sounds/9431/ and is licensed under Creative Commons with Attribution: 
Than van Nispen tot Pannerden - Composer for (non-linear) Media 
*/

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;//configuration channel
integer SLOODLE_CHANNEL_ENEMY_ATTACK= -163928666;//Channel to communicate on when attack occurs by an enemy
integer SLOODLE_CHANNEL_ENEMY_AIM = -163928665;//Channel to communicate on when enemy is aming at target, ie:delivering a laserbeam
float POOL_WIDTH=6;
float POOL_HEIGHT=6.525;
vector PUSH_STRENGTH=<25,15,10>;
// maximum swim distance for swimming up or down from last center
float height = 1.0;
// delay in seconds for next movement
float delay = 3.0;
// internal channel for communication
integer CHANNEL = -87;
integer MAX=30;
// last center position
vector center;
integer target_id;
list screams;
integer BLOOD=-999922110;
integer NOBLOOD=-999922111;
integer counter =0;
vector deathTarget;//the location of an avatar we want to attack
key deathKey;//the key of the avatar we will attack
integer attackTimes=0;
integer screamCounter=0;
vector rezzer_position_offset;
rotation rezzer_rotation_offset;
key rezzer_uuid=NULL_KEY;
integer    isconfigured;
integer  boundary_set;
integer SLOODLE_CHANNEL_POOL_BOUNDARIES_QUERY= -163928000;//sharks whisper on this channel requesting the boundaries from the shark pool
integer SLOODLE_CHANNEL_POOL_BOUNDARIES_RESPONSE= -163928001;//pool whispers on this channel telling sharks the boundaries from the shark pool
integer RANDOM_POS_SENSOR_RATE=5;
vector POOL_CENTER; //this is the location of the center of the pool and is determined by sensing an object called "Shark Pool"
list BOUNDING_BOX_POOL;
vector BOUNDING_BOX_MIN_CORNER;
vector BOUNDING_BOX_MAX_CORNER;
integer timeToMove=4;//this will get reset to a new value each time the shark moves, and will determined the next time that the shark shall move - so the shark doesnt move at predicatable intervals 
integer MAX_WAIT_TILL_MOVE_TIME=6;
integer MIN_WAIT_TILL_MOVE_TIME=2;
integer timeToMove_counter=0;
integer SAFETY_EDGE=2; //an extra padding so sharks noses dont stick out of the side of the pool
//sloodle_set_pos is an SL/OPENSIM friendly way of moving non-physical objects around 
sloodle_set_pos(vector targetposition){
    integer counter=0;
    while ((llVecDist(llGetPos(), targetposition) > 0.001)&&(counter<50)) {
        counter+=1;
        llSetPos(targetposition);
    }

}

debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay(llGetScriptName ()+": " +message );
     }
} 


//sloodle_handle_command, is what we use to interpret data that comes through linked messages from our sloodle_rezzer_objects script (who talks to the server)
integer sloodle_handle_command(string str){
   
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name;
    name = llList2String(bits,0);
    //set:position|<18.31369, 15.54828, 3.15605>|<0.00000, 0.00000, 0.25705, 0.96640>|0df19640-c2e9-43c1-4359-b805ef08dad0
    if (name == "set:position") {        
        rezzer_position_offset = (vector)llList2String(bits,1);
        rezzer_rotation_offset = (rotation)llList2String(bits,2);
        rezzer_uuid = llList2Key(bits,3);
        
        
    }
    if (rezzer_uuid!=NULL_KEY) return TRUE; else return FALSE; 
}
float randBetween(float min, float max){
    return llFrand(max - min) + min;
}
integer random_integer( integer min, integer max ){  return min + (integer)( llFrand ( max - min + 1 ) );}
//blood causes the shark to rez a bullet, which has particle effects for blood
blood(key av){
    llMessageLinked(LINK_SET, BLOOD, "", av);    
}
noblood(){
    llMessageLinked(LINK_SET, NOBLOOD, "", NULL_KEY);    
}
//getScreeam is used to play random sounds
string getScream(){
    screams = ["SND_SCREAM1","SND_SCREAM2","SND_SCREAM3","SND_SCREAM4"];
    integer screamLen = llGetListLength(screams);
    screamCounter++;
    if  (screamCounter>screamLen-1){
        screamCounter=0;
    }
    return llList2String(screams,screamCounter);
}


vector swim_in_boundary(vector dest, vector pos){
        if (dest.x > BOUNDING_BOX_MAX_CORNER.x-SAFETY_EDGE){
            dest.x=pos.x;
        }
        if (dest.x < BOUNDING_BOX_MIN_CORNER.x+SAFETY_EDGE){
            dest.x=pos.x;
        }
        if (dest.y > BOUNDING_BOX_MAX_CORNER.y-SAFETY_EDGE){
            dest.y=pos.y;
        }
        if (dest.y < BOUNDING_BOX_MIN_CORNER.y+SAFETY_EDGE){
            dest.y=pos.y;
        }                
        if (dest.z > BOUNDING_BOX_MAX_CORNER.z-0.5){
            dest.z=pos.z;
        }
        if (dest.z < BOUNDING_BOX_MIN_CORNER.z+0.5){
            dest.z=pos.z;
        }        
        return dest;        

}
integer is_in_boundary(vector dest){
    integer inBoundary =TRUE;
    if (dest.x > BOUNDING_BOX_MAX_CORNER.x-SAFETY_EDGE){
        
            inBoundary = TRUE;
        }
        if (dest.x < BOUNDING_BOX_MIN_CORNER.x+SAFETY_EDGE){
            inBoundary = FALSE;
        }
        if (dest.y > BOUNDING_BOX_MAX_CORNER.y-SAFETY_EDGE){
           inBoundary = FALSE;
        }
        if (dest.y < BOUNDING_BOX_MIN_CORNER.y+SAFETY_EDGE){
           inBoundary = FALSE;
        }                
        if (dest.z > BOUNDING_BOX_MAX_CORNER.z-0.5){
           inBoundary = FALSE;
        }
        if (dest.z < BOUNDING_BOX_MIN_CORNER.z+0.5){
            inBoundary = FALSE;
        }  
        if (inBoundary){
            debug("avatar is in the boundary");
        }else{
            debug("avatar is NOT in the boundary");
        }      
        return inBoundary;        

}

default{
   
    state_entry()
    {
        llTriggerSound("SND_JAWS", 1);
        isconfigured=FALSE;
        noblood(); //turn off particle effects
        counter=0;
    }
    
    link_message(integer sender_num, integer num, string str, key id) {
       
         // Split the data up into lines
        list lines = llParseStringKeepNulls(str, ["\n"], []);  
        integer numlines = llGetListLength(lines);
       
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
                if (isconfigured){
                  
                    state get_boundary;
                  }
              }
        }
    }
   
}
state get_boundary{
    on_rez(integer start_param) {
        llResetScript();
    }
    
    state_entry() {
        //llSensorRepeat("Shark Pool", "",PASSIVE,  10, TWO_PI, 5);
         debug("in get_boundary");
         llSetTimerEvent(2);
        
    }
    timer() {
        debug("trying to find: Shark Pool");
        llSensor("Shark Pool", "", SCRIPTED, 10, TWO_PI);
    }
    sensor(integer num_detected) {
        debug("found pool!");
        POOL_CENTER = llDetectedPos(0);
        BOUNDING_BOX_POOL= llGetBoundingBox(llDetectedKey(0));
        vector pool_lower_corner = llList2Vector(BOUNDING_BOX_POOL,0);
        vector pool_upper_corner = llList2Vector(BOUNDING_BOX_POOL,1);
        BOUNDING_BOX_MIN_CORNER =POOL_CENTER+pool_lower_corner;  
        BOUNDING_BOX_MAX_CORNER =POOL_CENTER+pool_upper_corner;
        POOL_WIDTH=pool_upper_corner.x+(-1*pool_lower_corner.x);
        POOL_HEIGHT=pool_upper_corner.z+(-1*pool_lower_corner.z);
        debug("found bounding box - height: "+(string)POOL_HEIGHT+" width: "+(string)POOL_WIDTH);
        
        state ready;     
    }
}
state ready{ 
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
            llListen(232323, "", "","");
            debug("in the ready state");
            llSetTimerEvent(1); //the timer event is set so that our shark moves around the pool every second 
            noblood();//TURN off blood;
            deathKey=NULL_KEY;
            deathTarget = ZERO_VECTOR;
            llSetText("", <0,0,1>, 1);
            llSetBuoyancy(0.9);
            llSensorRepeat("", "", AGENT, POOL_WIDTH/2, PI,timeToMove); //start searching for victems to eat!
        
    }
    listen(integer channel, string name, key id, string message) {
        //if pool moves
        if (channel==232323){
            llSleep(3);
            state get_boundary;
        }
    }
    sensor(integer num_detected) {
        integer i;
        
        //we found a victem so look at them and attack
        
        for (i=0;i<num_detected;i++){
            vector victim_pos=llDetectedPos(i);
            if (is_in_boundary(victim_pos)==FALSE){
                    return;
            }
            deathTarget = llDetectedPos(i);
            deathKey = llDetectedKey(i);
            vector pos = llGetPos();
            vector delta = pos - deathTarget;
            float angle = llAtan2(delta.y, delta.x) + PI / 2.0;
            rotation rot = llEuler2Rot(<0, 0, angle>);
            llRotLookAt(rot, 1.0, 1.0);
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ENEMY_AIM, "", deathKey); 
            state attack;
        }
        
    }
    timer(){
        timeToMove_counter++;
        if (timeToMove_counter<timeToMove){
            debug("timeToMove_counter is: "+(string)timeToMove_counter + " < "+(string)(timeToMove));
            return;
        }
        //set a new time which we should move next, do this so shark doesnt move so predicatbly
        timeToMove=random_integer(MIN_WAIT_TILL_MOVE_TIME,MAX_WAIT_TILL_MOVE_TIME);
        timeToMove_counter=0;
        
        // get current position
        vector pos = llGetPos();
        // calculate random next position
        vector dest = pos;
        dest.x += randBetween(-POOL_WIDTH/2, POOL_WIDTH/2);
        dest.y += randBetween(-POOL_WIDTH/2, POOL_WIDTH/2);
        dest.z += randBetween(-POOL_HEIGHT/2, POOL_HEIGHT/2);
        dest = swim_in_boundary(dest,pos);
        // calculate new rotation and move to target
        vector delta = pos - dest;
        float angle = llAtan2(delta.y, delta.x) + PI / 2.0;
        rotation rot = llEuler2Rot(<0, 0, angle>);
        llRotLookAt(rot, 1.0, 1.0);
        sloodle_set_pos(dest);
    }
}

state attack{
on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        llListen(232323, "", "", "");
        debug("in the attack state");
        attackTimes = 0;
        target_id = llTarget(deathTarget, 0.5);
        llTriggerSound("SND_JAWS", 1);
        sloodle_set_pos(deathTarget);
        llSensorRepeat("", "", AGENT, 10, PI,3);
        llSetTimerEvent(10);
    
    }
    listen(integer channel, string name, key id, string message) {
        //if pool moves
        if (channel==232323){
            llSleep(3);
            state get_boundary;
        }
    }
    sensor(integer num_detected) {
        integer i;
        for (i=0;i<num_detected;i++){        
            deathTarget =llDetectedPos(i);
            if (is_in_boundary(deathTarget)==FALSE){
                debug("not attacking because not in boundary");
                    return;
            } 
            
            deathKey = llDetectedKey(i);
            target_id = llTarget(deathTarget, 0.5);
            vector pos = llGetPos();
            vector delta = pos - deathTarget;
            float angle = llAtan2(delta.y, delta.x) + PI / 2.0;
            rotation rot = llEuler2Rot(<0, 0, angle>);
            llRotLookAt(rot, 1.0, 1.0);
            llLookAt( deathTarget + <0.0, 0.0, 1.0>, 3.0, 1.0 );
            sloodle_set_pos(deathTarget);
        }
        
    }
    timer() {
        llSetTimerEvent(0);
          vector dest=POOL_CENTER;
        sloodle_set_pos(dest);
        state ready;
    }
    at_target(integer tnum, vector targetpos, vector ourpos)    {
        if (tnum == target_id){
            debug("at the target");
            // llRezObject("redBubbles", llGetPos(), llGetVel(), ZERO_ROTATION, 0);
             llRezObject("blood_bath", llGetPos(), llGetVel(), ZERO_ROTATION, 0);
             llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ENEMY_ATTACK, "", deathKey);             
            llTriggerSound(getScream(), 1);
            llTriggerSound("SND_BITE", 1);
            attackTimes++;
            blood(deathKey);
            llPushObject(deathKey,PUSH_STRENGTH,PUSH_STRENGTH, TRUE);
            llTargetRemove(target_id);
            if (attackTimes>5) {
                attackTimes= 0;
                debug("attackTimes >5 going to ready state");
                state ready;
            }
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/gaming-1.0/object_scripts/sharks/shark_artificial_intelligence.lslp 

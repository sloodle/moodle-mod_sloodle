/*
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
*  Contributors:
*  Paul Preibisch
*
*  DESCRIPTION
* Contributors:
*  Edmund Edgar
*  Paul Preibisch
*
*  SND_JELLY_APPROACH - was mashed up from: http://www.freesound.org/people/suonho/ under the sampling license: http://creativecommons.org/licenses/sampling+/1.0/
*/

// bending fish
// 2007 Copyright by Shine Renoir (fb@frank-buss.de)
//
// The center position is stored on rez.

// maximum swim radius from last center
float radius = 6.0;

// maximum swim distance for swimming up or down from last center
float height = 1.0;

// delay in seconds for next movement
float delay = 3.0;
list colors;
// internal channel for communication
 
integer CHANNEL = -87;
integer MAX=30;
// last center position
vector center;
integer target_id;
list screams;
float randBetween(float min, float max)
{
    return llFrand(max - min) + min;
}

blood(key av){
    llMessageLinked(LINK_SET, BLOOD, "", av);    
}
noblood(){
    llMessageLinked(LINK_SET, NOBLOOD, "", NULL_KEY);    
}
integer BLOOD=-999922110;
integer NOBLOOD=-999922111;
init()
{
     llSetPrimitiveParams([ PRIM_PHYSICS, TRUE]);
    llSetStatus(STATUS_ROTATE_X, FALSE);
    llSetStatus(STATUS_ROTATE_Y, FALSE);
    float t = llSqrt(2.0) / 2.0;
    llSetRot(<0, 0, 0, 0>);
    llSetBuoyancy(0.9);
    llSetTimerEvent(delay);
}
integer counter =0;
vector deathTarget;
key deathKey;
integer attackTimes=0;
integer screamCounter=0;



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
vector AVCLASSBLUE= <0.06274,0.247058,0.35294>;
vector AVCLASSLIGHTBLUG=<0.8549,0.9372,0.9686>;//#daeff7

vector getColor(){
    
    list colors=[RED,ORANGE,YELLOW,BLUE,BABYBLUE,PINK,PURPLE];
    colors = llListRandomize(colors, 1);
    return llList2Vector(colors,0);
}
//returns a random scream sound
string getScream(){
    screams = ["scream1","scream2","scream3","scream4"];
    integer screamLen = llGetListLength(screams);
    screamCounter++;
    if  (screamCounter>screamLen-1){
        screamCounter=0;
    }
    return llList2String(screams,screamCounter);

}
string getApproachSound(){
    screams = ["SND_SNARL","SND_GROWL","SND_ZOMBIE_SQUEEL","SND_ZOMBIE_CAT"];
    integer screamLen = llGetListLength(screams);
    screamCounter++;
    if  (screamCounter>screamLen-1){
        screamCounter=0;
    }
    return llList2String(screams,screamCounter);

}


default{
    state_entry(){
        llSetPrimitiveParams([ PRIM_PHYSICS, FALSE]);
        noblood();
        counter=0;
        llSetTimerEvent(3);
    }
    on_rez(integer start_param) {
        llResetScript();
    }
    timer() {
       state myPos;
    }
}
state myPos{
    state_entry() {
        center = llGetPos();
        state ready;
    }
     on_rez(integer start_param) {
        llResetScript();
    }
}
state before_ready{
    state_entry() {
        state ready;
    }
}
state ready{
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
    llSetStatus(STATUS_ROTATE_X,FALSE);
         llSetStatus(STATUS_ROTATE_Y,FALSE); 
        llParticleSystem([]);
            
        noblood();
        deathKey=NULL_KEY;
        deathTarget = ZERO_VECTOR;
        llSetText("", <0,0,1>, 1);
        llSensorRepeat("", "", AGENT, 5, PI,5);
        init();
        llMoveToTarget(center, 1);
    }
    sensor(integer num_detected) {
        deathTarget = llDetectedPos(0);
        deathKey = llDetectedKey(0);
        vector pos = llGetPos();
        vector delta = pos - deathTarget;
        float angle = llAtan2(delta.y, delta.x) + PI / 2.0;
        rotation rot = llEuler2Rot(<0, 0, angle>);
        //llRotLookAt(rot, 1.0, 1.0);
        state attack;
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==-99){
            if (str=="DEAD"){
                llSleep(10);
                llSetTimerEvent(0);
                state before_ready;
            }
        }
    
    }
    
    timer()
    {
        // get current position
        vector pos = llGetPos();
        // calculate random next position
        vector dest = pos;
        dest.x += randBetween(-radius, radius);
        dest.y += randBetween(-radius, radius);
           // dest.z += randBetween(-radius, height);
        // move to center, if outside radius
        integer i;
        for (i = 0; i < 3; i++) {
            if (llVecMag(dest - center) > radius) {
                dest = (dest - pos) / 2.0 + pos;
            }
        } 
        // fallback: if other objects pushes the fish, move back to center
        if (llVecMag(dest - center) > radius) {
            dest = center;
        }

        // calculate new rotation and move to target
        vector delta = pos - dest;
        float angle = llAtan2(delta.y, delta.x) + PI / 2.0;
        rotation rot = llEuler2Rot(<0, 0, angle>);
      //  llRotLookAt(rot, 1.0, 1.0);
        llMoveToTarget(dest, 2);
    }

   
}

state attack{
on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        attackTimes = 0;
        target_id = llTarget(deathTarget, 0.5);
        llTriggerSound(getApproachSound(), 1);
        llMoveToTarget(deathTarget, 0.1);
        llSensorRepeat("", "", AGENT, 10, PI,1);
        llSetTimerEvent(10);
    
    }
    sensor(integer num_detected) {
        deathTarget =llDetectedPos(0);
        deathKey = llDetectedKey(0);
        target_id = llTarget(deathTarget, 0.5);
        vector pos = llGetPos();
        vector delta = pos - deathTarget;
        float angle = llAtan2(delta.y, delta.x) + PI / 2.0;
        rotation rot = llEuler2Rot(<0, 0, angle>);
    //    llRotLookAt(rot, 1.0, 1.0);
        llLookAt( deathTarget + <0.0, 0.0, 1.0>, 3.0, 1.0 );
        llMoveToTarget(deathTarget, 0.5);
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==-99){
            if (str=="DEAD"){
                llSleep(10);
                llSetTimerEvent(0);
                state ready;
            }
        }
    
    }
    timer() {
        llSetTimerEvent(0);
        integer i;
        // get current position
        vector pos = llGetPos();
        // calculate random next position
        vector dest = pos;
         for (i = 0; i < 3; i++) {
            if (llVecMag(dest - center) > radius) {
                dest = (dest - pos) / 2.0 + pos;
            }
        } 
        
        // fallback: if other objects pushes the fish, move back to center
        if (llVecMag(dest - center) > radius) {
            dest = center;
        }

        // calculate new rotation and move to target
        vector delta = pos - dest;
        float angle = llAtan2(delta.y, delta.x) + PI / 2.0;
        rotation rot = llEuler2Rot(<0, 0, angle>);
    //    llRotLookAt(rot, 1.0, 1.0);
        llMoveToTarget(dest, 2);
        state ready;
    
    }
    at_target(integer tnum, vector targetpos, vector ourpos)
    {
        if (tnum == target_id)
        {
            llTriggerSound(getScream(), 0.3);
            llTriggerSound(getApproachSound(),  0.5);
            attackTimes++;
            blood(deathKey);
            llPushObject(deathKey,<5,5,5>, <5,5,5>, TRUE);
            llTargetRemove(target_id);
            if (attackTimes>5) {
                attackTimes= 0;
                state ready;
            }
        }  
    } 
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/interaction-1.0/objects/enemyrezzer/assets/zombie_move.lslp 

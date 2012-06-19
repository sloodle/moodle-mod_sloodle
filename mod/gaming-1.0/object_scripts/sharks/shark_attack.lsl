// LSL script generated: mod.gaming-1.0.object_scripts.sharks.shark_attack.lslp Wed Jun 20 03:40:46 Tokyo Standard Time 2012
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

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SLOODLE_CHANNEL_ENEMY_ATTACK = -163928666;
integer SLOODLE_CHANNEL_ENEMY_AIM = -163928665;
float POOL_WIDTH = 6;
float POOL_HEIGHT = 6.525;
vector PUSH_STRENGTH = <25,15,10>;
// last center position
vector center;
integer target_id;
list screams;
integer BLOOD = -999922110;
integer NOBLOOD = -999922111;
integer counter = 0;
vector deathTarget;
key deathKey;
integer attackTimes = 0;
integer screamCounter = 0;
vector rezzer_position_offset;
rotation rezzer_rotation_offset;
key rezzer_uuid = NULL_KEY;
integer isconfigured;
vector POOL_CENTER;
list BOUNDING_BOX_POOL;
vector BOUNDING_BOX_MIN_CORNER;
vector BOUNDING_BOX_MAX_CORNER;
integer timeToMove = 4;
integer MAX_WAIT_TILL_MOVE_TIME = 6;
integer MIN_WAIT_TILL_MOVE_TIME = 2;
integer timeToMove_counter = 0;
integer SAFETY_EDGE = 2;
//sloodle_set_pos is an SL/OPENSIM friendly way of moving non-physical objects around 
sloodle_set_pos(vector targetposition){
    integer counter = 0;
    while (((llVecDist(llGetPos(),targetposition) > 1.0e-3) && (counter < 50))) {
        (counter += 1);
        llSetPos(targetposition);
    }
}
//sloodle_handle_command, is what we use to interpret data that comes through linked messages from our sloodle_rezzer_objects script (who talks to the server)
integer sloodle_handle_command(string str){
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name;
    (name = llList2String(bits,0));
    if ((name == "set:position")) {
        (rezzer_position_offset = ((vector)llList2String(bits,1)));
        (rezzer_rotation_offset = ((rotation)llList2String(bits,2)));
        (rezzer_uuid = llList2Key(bits,3));
    }
    if ((rezzer_uuid != NULL_KEY)) return TRUE;
    else  return FALSE;
}
float randBetween(float min,float max){
    return (llFrand((max - min)) + min);
}
integer random_integer(integer min,integer max){
    return (min + ((integer)llFrand(((max - min) + 1))));
}
//blood causes the shark to rez a bullet, which has particle effects for blood
blood(key av){
    llMessageLinked(LINK_SET,BLOOD,"",av);
}
noblood(){
    llMessageLinked(LINK_SET,NOBLOOD,"",NULL_KEY);
}
//getScreeam is used to play random sounds
string getScream(){
    (screams = ["SND_SCREAM1","SND_SCREAM2","SND_SCREAM3","SND_SCREAM4"]);
    integer screamLen = llGetListLength(screams);
    (screamCounter++);
    if ((screamCounter > (screamLen - 1))) {
        (screamCounter = 0);
    }
    return llList2String(screams,screamCounter);
}

//move back to the position saved in our configuration
move_to_layout_position(){
    list rezzerdetails = llGetObjectDetails(rezzer_uuid,[OBJECT_POS,OBJECT_ROT]);
    vector rezzerpos = llList2Vector(rezzerdetails,0);
    rotation rezzerrot = llList2Rot(rezzerdetails,1);
    sloodle_set_pos((rezzerpos + (rezzer_position_offset * rezzerrot)));
    llSetRot((rezzerrot * rezzer_rotation_offset));
    (center = llGetPos());
}
vector swim_in_boundary(vector dest,vector pos){
    if ((dest.x > (BOUNDING_BOX_MAX_CORNER.x - SAFETY_EDGE))) {
        (dest.x = pos.x);
    }
    if ((dest.x < (BOUNDING_BOX_MIN_CORNER.x + SAFETY_EDGE))) {
        (dest.x = pos.x);
    }
    if ((dest.y > (BOUNDING_BOX_MAX_CORNER.y - SAFETY_EDGE))) {
        (dest.y = pos.y);
    }
    if ((dest.y < (BOUNDING_BOX_MIN_CORNER.y + SAFETY_EDGE))) {
        (dest.y = pos.y);
    }
    if ((dest.z > (BOUNDING_BOX_MAX_CORNER.z - 0.5))) {
        (dest.z = pos.z);
    }
    if ((dest.z < (BOUNDING_BOX_MIN_CORNER.z + 0.5))) {
        (dest.z = pos.z);
    }
    return dest;
}
integer is_in_boundary(vector dest){
    if ((dest.x > (BOUNDING_BOX_MAX_CORNER.x - SAFETY_EDGE))) {
        return FALSE;
    }
    if ((dest.x < (BOUNDING_BOX_MIN_CORNER.x + SAFETY_EDGE))) {
        return FALSE;
    }
    if ((dest.y > (BOUNDING_BOX_MAX_CORNER.y - SAFETY_EDGE))) {
        return FALSE;
    }
    if ((dest.y < (BOUNDING_BOX_MIN_CORNER.y + SAFETY_EDGE))) {
        return FALSE;
    }
    if ((dest.z > (BOUNDING_BOX_MAX_CORNER.z - 0.5))) {
        return FALSE;
    }
    if ((dest.z < (BOUNDING_BOX_MIN_CORNER.z + 0.5))) {
        return FALSE;
    }
    return TRUE;
}

default {

   
    state_entry() {
        llTriggerSound("SND_JAWS",1);
        (isconfigured = FALSE);
        noblood();
        (counter = 0);
    }

    
    link_message(integer sender_num,integer num,string str,key id) {
        list lines = llParseStringKeepNulls(str,["\n"],[]);
        integer numlines = llGetListLength(lines);
        if ((num == SLOODLE_CHANNEL_OBJECT_DIALOG)) {
            integer i = 0;
            for ((i = 0); (i < numlines); (i++)) {
                (isconfigured = sloodle_handle_command(llList2String(lines,i)));
                if (isconfigured) {
                    move_to_layout_position();
                    state get_boundary;
                }
            }
        }
    }
}
state get_boundary {

    on_rez(integer start_param) {
        llResetScript();
    }

    
    state_entry() {
        llSensorRepeat("Shark Pool","",SCRIPTED,5,TWO_PI,2);
    }

    sensor(integer num_detected) {
        (POOL_CENTER = llDetectedPos(0));
        (BOUNDING_BOX_POOL = llGetBoundingBox(llDetectedKey(0)));
        vector pool_lower_corner = llList2Vector(BOUNDING_BOX_POOL,0);
        vector pool_upper_corner = llList2Vector(BOUNDING_BOX_POOL,1);
        (BOUNDING_BOX_MIN_CORNER = (POOL_CENTER + pool_lower_corner));
        (BOUNDING_BOX_MAX_CORNER = (POOL_CENTER + pool_upper_corner));
        (POOL_WIDTH = (pool_upper_corner.x + ((-1) * pool_lower_corner.x)));
        (POOL_HEIGHT = (pool_upper_corner.z + ((-1) * pool_lower_corner.z)));
        llOwnerSay(((("height: " + ((string)POOL_HEIGHT)) + " width: ") + ((string)POOL_WIDTH)));
        state ready;
    }
}
state ready {

        state_entry() {
        llSetTimerEvent(1);
        noblood();
        (deathKey = NULL_KEY);
        (deathTarget = ZERO_VECTOR);
        llSetText("",<0,0,1>,1);
        llSetBuoyancy(0.9);
        move_to_layout_position();
        llSensorRepeat("","",AGENT,(POOL_WIDTH / 2),PI,timeToMove);
    }

    sensor(integer num_detected) {
        integer i;
        for ((i = 0); (i < num_detected); (i++)) {
            vector victim_pos = llDetectedPos(i);
            if ((is_in_boundary(victim_pos) == FALSE)) {
                return;
            }
            (deathTarget = llDetectedPos(i));
            (deathKey = llDetectedKey(i));
            vector pos = llGetPos();
            vector delta = (pos - deathTarget);
            float angle = (llAtan2(delta.y,delta.x) + (PI / 2.0));
            rotation rot = llEuler2Rot(<0,0,angle>);
            llRotLookAt(rot,1.0,1.0);
            llMessageLinked(LINK_SET,SLOODLE_CHANNEL_ENEMY_AIM,"",deathKey);
            state attack;
        }
    }

    timer() {
        (timeToMove_counter++);
        if ((timeToMove_counter < timeToMove)) {
            return;
        }
        (timeToMove = random_integer(MIN_WAIT_TILL_MOVE_TIME,MAX_WAIT_TILL_MOVE_TIME));
        (timeToMove_counter = 0);
        vector pos = llGetPos();
        vector dest = pos;
        (dest.x += randBetween(((-POOL_WIDTH) / 2),(POOL_WIDTH / 2)));
        (dest.y += randBetween(((-POOL_WIDTH) / 2),(POOL_WIDTH / 2)));
        (dest.z += randBetween(((-POOL_HEIGHT) / 2),(POOL_HEIGHT / 2)));
        (dest = swim_in_boundary(dest,pos));
        vector delta = (pos - dest);
        float angle = (llAtan2(delta.y,delta.x) + (PI / 2.0));
        rotation rot = llEuler2Rot(<0,0,angle>);
        llRotLookAt(rot,1.0,1.0);
        sloodle_set_pos(dest);
    }
}

state attack {

on_rez(integer start_param) {
        llResetScript();
    }

    state_entry() {
        (attackTimes = 0);
        (target_id = llTarget(deathTarget,0.5));
        llTriggerSound("SND_JAWS",1);
        sloodle_set_pos(deathTarget);
        llSensorRepeat("","",AGENT,10,PI,3);
        llSetTimerEvent(10);
    }

    sensor(integer num_detected) {
        integer i;
        for ((i = 0); (i < num_detected); (i++)) {
            (deathTarget = llDetectedPos(i));
            if ((is_in_boundary(deathTarget) == FALSE)) {
                return;
            }
            (deathKey = llDetectedKey(i));
            (target_id = llTarget(deathTarget,0.5));
            vector pos = llGetPos();
            vector delta = (pos - deathTarget);
            float angle = (llAtan2(delta.y,delta.x) + (PI / 2.0));
            rotation rot = llEuler2Rot(<0,0,angle>);
            llRotLookAt(rot,1.0,1.0);
            llLookAt((deathTarget + <0.0,0.0,1.0>),3.0,1.0);
            sloodle_set_pos(deathTarget);
        }
    }

    timer() {
        llSetTimerEvent(0);
        vector dest = POOL_CENTER;
        sloodle_set_pos(dest);
        state ready;
    }

    at_target(integer tnum,vector targetpos,vector ourpos) {
        if ((tnum == target_id)) {
            llRezObject("redBubbles",llGetPos(),llGetVel(),ZERO_ROTATION,0);
            llRezObject("blood_bath",llGetPos(),llGetVel(),ZERO_ROTATION,0);
            llMessageLinked(LINK_SET,SLOODLE_CHANNEL_ENEMY_ATTACK,"",deathKey);
            llTriggerSound(getScream(),1);
            llTriggerSound("SND_BITE",1);
            (attackTimes++);
            blood(deathKey);
            llPushObject(deathKey,PUSH_STRENGTH,PUSH_STRENGTH,TRUE);
            llTargetRemove(target_id);
            if ((attackTimes > 5)) {
                (attackTimes = 0);
                state ready;
            }
        }
    }
}

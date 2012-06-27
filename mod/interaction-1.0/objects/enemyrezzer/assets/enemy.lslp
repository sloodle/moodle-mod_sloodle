/*
*  sloodle_quiz_router.lsl
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
*  This script will send messages to waiting quizServers.  When a player enters the game, this router
*  sends a message to all listening quizServers asking if anyone is available.
*  The quiz servers will report if they are AVAILABLE or BUSY.
*  The router will select an available quizServer and then send that quizServer the id of the player.
* 
* Contributors:
*  Edmund Edgar
*  Paul Preibisch
*/
integer TIMELIMIT=60; //five minutes
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
integer SLOODLE_ROUTER=-1639271139;
integer SLOODLE_PLAYERSERVER=-1639271140;
integer SLOODLE_DEREZ=-1639271141;
list waitingToPlay;
list playing;
string hover;
float alpha;
explosion(key id){
	if (id==NULL_KEY){
		llParticleSystem ([]);
		return;
	}

 llParticleSystem ([
    PSYS_SRC_PATTERN,8,
    PSYS_PART_FLAGS,(0|PSYS_PART_EMISSIVE_MASK|PSYS_PART_INTERP_COLOR_MASK|PSYS_PART_INTERP_SCALE_MASK|PSYS_PART_TARGET_POS_MASK),
    PSYS_PART_START_COLOR, <0.96,0.98,0.98>,
    PSYS_PART_END_COLOR, <0.40,0.83,0.89>,
    PSYS_PART_START_ALPHA, 0.58,
    PSYS_PART_END_ALPHA, 0.20,
    PSYS_PART_START_SCALE, <3.86,3.91,0>,
    PSYS_PART_END_SCALE, <3.89,3.82,0>,
    PSYS_SRC_BURST_SPEED_MIN, 1.11,
    PSYS_SRC_BURST_SPEED_MAX, 1.13,
    PSYS_SRC_ACCEL, <-8.15,-5.70,-10.00>,
    PSYS_SRC_OMEGA, <-8.99,-10.00,-10.00>,
    PSYS_SRC_ANGLE_END, 0.75,
    PSYS_SRC_ANGLE_BEGIN, 0.03,
    PSYS_PART_MAX_AGE, 1.20,
    PSYS_SRC_BURST_PART_COUNT, 1,
    PSYS_SRC_BURST_RATE, 0.00,
    PSYS_SRC_BURST_RADIUS, 1.56,
    PSYS_SRC_MAX_AGE, 0.00,
    PSYS_SRC_TEXTURE, "9c8eca51-53d5-42a7-bb58-cef070395db8",
    PSYS_SRC_TARGET_KEY, id 
    ]);
}
playDieSound(){
    llTriggerSound("SND_JELLY_SQUISH",1.0);
}
default {
    state_entry() {
        llListen(SLOODLE_ROUTER, "", "", "");
        llListen(SLOODLE_PLAYERSERVER, "", "", "");
        llListen(SLOODLE_DEREZ, "", "", "");
        //llSetText("ready"+(string)llFrand(10), BLUE, 1);
        explosion(NULL_KEY);
    }
    touch_start(integer num_detected) {
    	integer j;
    	for (j=0;j<num_detected;j++){
        	llRegionSay(SLOODLE_ROUTER, "ENEMY CLICKED|"+(string)llDetectedKey(j));
    	}
    }
    listen(integer channel, string name, key id, string message) {
    	list data = llParseString2List(message, ["|"], []);
    	string cmd = llList2String(data,0);
        if (cmd=="EXPLODE"){
        	llOwnerSay("message came in: "+message);
        	explosion(llList2Key(data,1));
            state DIEING;
        }
        if (channel == SLOODLE_DEREZ){
        	llDie();
        }
    }
    
}
state DIEING{

    state_entry() {
    	llListen(SLOODLE_DEREZ, "", "", "");
        playDieSound();
        alpha=1;
        llSetTimerEvent(0.2);
        llMessageLinked(LINK_SET, -99, "DEAD", NULL_KEY);
        
    }
    listen(integer channel, string name, key id, string message) {
        if (channel == SLOODLE_DEREZ){
        	llDie();
        }
    }
    timer() {
        alpha=alpha-0.1;
        llMessageLinked(LINK_SET, -99, "SET ALPHA|"+(string)alpha,NULL_KEY);
        llMessageLinked(LINK_THIS, -99, "SET ALPHA|"+(string)alpha,NULL_KEY);
        
        if (alpha<0){
            llSetTimerEvent(0);
            state restart;
            explosion(NULL_KEY);
        }
        integer num = llGetNumberOfPrims();
        integer j;
        for (j=0;j<num;j++){
        	llSetLinkPrimitiveParamsFast(j,[PRIM_COLOR,ALL_SIDES,BLACK,alpha]);
        }
        
         
    }
}
state restart{
    state_entry() {
    	llListen(SLOODLE_DEREZ, "", "", "");
        llSetTimerEvent(10);
        llParticleSystem([]);
    }
    listen(integer channel, string name, key id, string message) {
        if (channel == SLOODLE_DEREZ){
        	llDie();
        }
    }
    
    timer() {
        
        //llMessageLinked(LINK_SET, -99, "SET ALPHA|"+(string)counter,NULL_KEY);
        integer num = llGetNumberOfPrims();
        integer j;
        for (j=0;j<num;j++){
        	llSetLinkPrimitiveParamsFast(j,[PRIM_COLOR,ALL_SIDES,WHITE,1]);
        }
        llSetTimerEvent(0);
        state default;
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/interaction-1.0/objects/enemyrezzer/assets/enemy.lslp 

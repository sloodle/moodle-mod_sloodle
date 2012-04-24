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
list tmp;
key sound;
integer vulnerable=FALSE;
key enemy;
key player;
key myKey;
integer reward=10;
integer damage;
integer health=100;
string command;
integer QUIZER_CHANNEL=81;
integer ENEMY_CHANNEL=80;
integer SWORD_CHANNEL=55;
list angry_sounds;
list blood_textures;
list body_parts;
list commandList;
integer REMOTE_ACCESS_PIN= 445566; //enables the ability to copy scripts into this object
integer random_integer( integer min, integer max )
{
  return min + (integer)( llFrand( max - min + 1 ) );
}

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
//explode will cause an unlinked bunch of bones to appear, along with an explosion.  Inside the unlinked object is a script that causes an explosion particle effect
//along with an explosion sound, all of the zombie bones will also be set to invisible via a linked message, so that only the brain is left hovering around
//A message will be sent from this enemy to the playerServer asking to disburse a question
//if the question is answered correctly, the zombie brain will die
explode(){    
         llRezObject("EVZombieBones", llGetPos(),llGetVel(),llGetRot(), 1);
         llMessageLinked(LINK_SET, 1, "ENEMY:HIDEBONES","");
}


//playSound will simply play a sound from a random list of sounds based on type 
playSound(string soundType){  
    if (soundType="Zombie Growl") {
        angry_sounds=llListRandomize(angry_sounds, 0);
        llTriggerSound(llList2String(angry_sounds,0), 1.0);
    } 
    if (soundType="Dieing zombie"){
        angry_sounds=llListRandomize(angry_sounds, 0);
        llTriggerSound(llList2String(angry_sounds,0), 1.0);
    }
    
}  

loadSounds(){
        angry_sounds=["SND_SNARL","SND_GROWL","SND_ZOMBIE_SQUEEL","SND_ZOMBIE_CAT"];
         
}  
integer screamCounter;  
list screams;
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
integer SLOODLE_ROUTER=-1639271139;
integer SLOODLE_PLAYERSERVER=-1639271140;
integer SLOODLE_DEREZ=-1639271141;

default {
    on_rez(integer start_param) {
        llResetScript();
        llSetText((string)health+"%", <255,0,0>, 1.0);
    	
    }
    state_entry() {
    	llTriggerSound("SND_ALIVE", 1);
        //make sure all zombie parts are displaying their bone textures
        llMessageLinked(LINK_SET, 1, "ENEMY:SHOWBONES","");
        //allow scripts to be copied into this zombie
        llSetRemoteScriptAccessPin(REMOTE_ACCESS_PIN);
        //display health
        llSetText((string)health+"%", <255,0,0>, 1.0);
         
        loadSounds();
        myKey = llGetKey();
        llListen(ENEMY_CHANNEL,"","","");
        llListen(SWORD_CHANNEL,"","","");
         llListen(SLOODLE_ROUTER, "", "", "");
        llListen(SLOODLE_PLAYERSERVER, "", "", "");
        llListen(SLOODLE_DEREZ, "", "", "");
        //llSetText("ready"+(string)llFrand(10), BLUE, 1);
        explosion(NULL_KEY);
    }
   
    listen(integer channel, string name, key id, string message) {
         
         commandList = llParseString2List(message, ["|"],[]);
         //this enemy will listen to players swords as they play the game. Each sword has a sensor in it, and if it detects a zombie
         //it sends out a message on the sword channel saying a HIT was made
         //All zombies within range of a whisper will here the player's sword whisper this message
         // If the message sent from the sword applies to this enemy, this enemy will then start spurting blood and apply damage to itself
           command = llList2String(commandList,0);  
         if (channel==SLOODLE_PLAYERSERVER){
             if (command=="EXPLODE"){
                
                
                state myDeath;
            }
         }else
         if (channel == SLOODLE_DEREZ){
            llDie();
        }else
         if (channel==SWORD_CHANNEL){                  
                 
                 tmp= llParseString2List(llList2Key(commandList,1), [":"],[]);
             player =  llList2Key(tmp,1);
                 tmp= llParseString2List(llList2Key(commandList,2), [":"],[]);
             enemy=    llList2Key(tmp,1);
                 tmp= llParseString2List(llList2Key(commandList,3), [":"],[]);
             damage =  llList2Integer(tmp,1);
                 tmp= llParseString2List(llList2Key(commandList,4), [":"],[]);
             sound =  llList2Key(tmp,1);        
             //a hit message was received from a players swordHUD
             if (command=="SWORDHUD:HIT"){
                 //play sword sound
                 llMessageLinked(LINK_SET, 1, "SWORD:PLAY_SWORD_SOUND|"+(string)sound,"");
                 //find out if this hit message is actually for us
                 if (enemy==llGetKey()){
                     //it is, so lets play a zombie grow sound
                     playSound("Zombie Growl");
                     //player has hit the zombie so we must minus damage points of the weapon used                
                     health-=damage;
                     if (health<0) health=0;//make sure we don't go to negative health
                    //display updated health
                    llSetText((string)health+"%", <255,0,0>, 1.0);
                     //if the health of this enemy get's below 0, ask a question and only display the brain
                     llMessageLinked(LINK_SET,random_integer(0,4),"BLOOD","");
                     if (health<=0){                          
                        llRegionSay(SLOODLE_ROUTER, "ENEMY CLICKED|"+(string)player);             
                     } 
                 }           
             }
         }
    }
} 

state myDeath{ 
	 on_rez(integer start_param) {
        llResetScript();
        llSetText((string)health+"%", <255,0,0>, 1.0);
    	
    }
    state_entry() {
         llSetScriptState("ZombieMove",FALSE);
        explode();         
        llSetTimerEvent(3);
    }
    timer() {
        llDie();
    } 
 
} 

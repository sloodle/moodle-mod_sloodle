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
string SLOODLE_EOF = "sloodleeof";
integer eof = FALSE; // Have we reached the end of the configuration data?
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;//configuration channel
integer isconfigured = 0;
list enemies; 
integer TIMELIMIT=300; //five minutes
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
string ENEMY_TYPE;
integer sloodle_handle_command(string str)
{
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

     
        } if (name == "set:jellyfishenemy") {
              integer type = (integer)llList2String(bits,1);
              if (type==1){
                   ENEMY_TYPE="Jelly Fish";
              }else{
                   ENEMY_TYPE="Sloodle Zombie";
              }
           
    } 
   
    if ( ENEMY_TYPE!="")isconfigured=1;
                          
   
    return isconfigured;
}

// Strided Functions For working with Strided Lists.
// By Aakanaar LaSalle

// the intStride parameter is the length of the strides within the list
// the intIndex is which stride we're working with.
// the intSubIndex is which element of the stride we're working with.

// Returns number of Strides in a List

integer fncStrideCount(list lstSource, integer intStride)
{
  return llGetListLength(lstSource) / intStride;
}

// Find a Stride within a List (returns stride index, and item subindex)
list fncFindStride(list lstSource, list lstItem, integer intStride)
{
  integer intListIndex = llListFindList(lstSource, lstItem);
  
  if (intListIndex == -1) { return [-1, -1]; }
  
  integer intStrideIndex = intListIndex / intStride;
  integer intSubIndex = intListIndex % intStride;
  
  return [intStrideIndex, intSubIndex];
}

// Deletes a Stride from a List
list fncDeleteStride(list lstSource, integer intIndex, integer intStride)
{
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = intIndex * intStride;
    return llDeleteSubList(lstSource, intOffset, intOffset + (intStride - 1));
  }
  return lstSource;
}

// Returns a Stride from a List
list fncGetStride(list lstSource, integer intIndex, integer intStride)
{
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = intIndex * intStride;
    return llList2List(lstSource, intOffset, intOffset + (intStride - 1));
  }
  return [];
}

// Replace a Stride in a List
list fncReplaceStride(list lstSource, list lstStride, integer intIndex, integer intStride)
{
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (llGetListLength(lstStride) != intStride) { return lstSource; }
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = intIndex * intStride;
    return llListReplaceList(lstSource, lstStride, intOffset, intOffset + (intStride - 1));
  }
  return lstSource;
}

// Retrieve a single element from a Stride within a List
list fncGetElement(list lstSource, integer intIndex, integer intSubIndex, integer intStride)
{
  if (intSubIndex >= intStride) { return []; }
  
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = (intIndex * intStride) + intSubIndex;
    return llList2List(lstSource, intOffset, intOffset);
  }
  return [];
}

// Update a single item in a Stride within a List
list fncReplaceElement(list lstSource, list lstItem, integer intIndex, integer intSubIndex, integer intStride)
{
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (llGetListLength(lstItem) != 1) { return lstSource; }
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = (intIndex * intStride) + intSubIndex;
    return llListReplaceList(lstSource, lstItem, intOffset, intOffset);
  }
  return lstSource;
}
debug(integer channel, string message){
    return;
/*    string c;
        if (channel==SLOODLE_ROUTER){
        c="SLOODLE_ROUTER";
        llSay(0,"Message came in on: "+c+" : "+message);
        }else
        if (channel==SLOODLE_PLAYERSERVER){
        c="SLOODLE_PLAYERSERVER";
        llSay(0,"Message came in on: "+c+" : "+message);
        }else{
        llSay(0,message);
        }
    */
}
default {
    state_entry() {
        llListen(SLOODLE_ROUTER, "" , "", "");
        llSetTimerEvent(5);
        llSetText("Ready", RED, 1);
    }
    touch_start(integer num_detected) {
        integer j;
        key player;
        
        for (j=0;j<num_detected;j++){
            if (llDetectedKey(j)==llGetOwner()){
            llRezObject(ENEMY_TYPE, llGetPos()+<0,0,3>, <0,0,1>, ZERO_ROTATION, 1);
            } 
            
           
        }  
        llSetText("Touch to Rezz Killer Jelly Fish", YELLOW, 1);
         
    }
    object_rez(key id) {
        enemies+=id;
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==SLOODLE_DEREZ){
            integer j; 
            integer len = llGetListLength(enemies);
            for (j=0;j<len;j++){
                llRegionSayTo(llList2Key(enemies,j),SLOODLE_DEREZ,"");
            } 
            llDie(); 
        }  
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            
        }
    }  
    
    
   
    listen(integer channel, string name, key id, string message) { 
         debug(channel,message);
        list data = llParseString2List(message, ["|"], []);
        string cmd = llList2String(data,0);
        if (cmd=="ENEMY CLICKED"){
            
           list result;
           list playerData;
           //see if player is already playing
           key player = llList2Key(data,1);
           result = fncFindStride(playing, [player], 3);
           if (llList2Integer(result,0)==-1||llList2Integer(result,1)==-1){
                llRegionSay(SLOODLE_PLAYERSERVER, "ARE YOU AVAILABLE?|"+(string)player+"|"+(string)id);
                waitingToPlay+=player;
                hover=""; 
                return;
            
           }
           key clicker = llList2Key(data,1);
           debug(0,"fncFindStride("+llDumpList2String(playing,"***")+","+"["+(string)clicker+"], 3)");
           result = fncFindStride(playing, [clicker], 3);
           if (llList2Integer(result,0)!=-1||llList2Integer(result,1)!=-1){
                debug(0,"searching for "+(string)clicker + " in "+llDumpList2String(playing, ","));debug(0,"result is: "+llDumpList2String(result, ","));
                playerData = fncGetStride(playing,llList2Integer(result,0),3);
                debug(0,"playerDatais: "+llDumpList2String(playerData, ","));
           }
           if (llList2Integer(playerData,0)!=-1){ 
               llRegionSayTo(llList2Key (playerData,1),SLOODLE_PLAYERSERVER,"ASK QUESTION|"+(string)id);
            debug(0,"sending a message to: "+llList2String(playerData,1)+" ASK QUESTION for "+llKey2Name(llList2Key(playerData,0)));    
           }
           
           
           
        }else
        if (cmd=="QUIZ FINISHED"){
            key player= llList2Key(data,1);
            list result = fncFindStride(playing, [player], 3);
           if (llList2Integer(result,0)!=-1||llList2Integer(result,1)!=-1){
             playing = fncDeleteStride(playing, llList2Integer(result,0), 3);
             debug(0,"Deleted player from playing: "+llDumpList2String(playing, "**"));
              llSetText("Ready", RED, 1);
              hover="";
           }
        }
        else
        if (cmd=="AVAILABLE"){ 
            if (llGetListLength(waitingToPlay)>0){
                key selectedPlayer = llList2Key(waitingToPlay,0);
                llRegionSayTo(id,SLOODLE_PLAYERSERVER,"GUEST TRANSFER|"+(string)selectedPlayer);
                waitingToPlay= llDeleteSubList(waitingToPlay, 1, llGetListLength(waitingToPlay)-1);   
                hover+=llKey2Name(selectedPlayer)+"\n";   
                playing+=[selectedPlayer,id,llGetUnixTime()];
           }
        }else{
            hover+="AVAILABLE: "+(string)id+"\n";
        }
        llSetText(hover, YELLOW, 1);
    }
    timer(){
        integer j;
        integer len = llGetListLength(playing)/3;
        hover="";
        if (len >0){
            for (j=0;j<len;j++){
                list playerGameData= fncGetStride(playing, j, 3);
                integer timePlayed = llGetUnixTime()- llList2Integer(playerGameData,2);
                if (timePlayed>TIMELIMIT){
                    llRegionSayTo(llList2Key(playerGameData,1),SLOODLE_PLAYERSERVER, "STOP GAME");
                    playing = fncDeleteStride(playing, j, 3);
                }
                 
        }
         
        }
         
    
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/interaction-1.0/object_scripts/sloodle_quiz_router.lslp 

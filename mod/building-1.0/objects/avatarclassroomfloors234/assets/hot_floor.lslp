//
// The line above should be left blank to avoid script errors in OpenSim.

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
*  Animates the RIGHT door opening to the pool
*/

integer SLOODLE_HOT_FLOOR_ON=-1639271142;//used to for shark pool HOT FLOOR
integer SLOODLE_HOT_FLOOR_OFF=-1639271143;//used to for shark pool HOT FLOOR
vector RED =<1.00000, 0.00000, 0.00000>;
vector WHITE= <1.00000, 1.00000, 1.00000>;

integer OPEN=1;
integer CLOSED = 0;
integer door_status;
doAnim(integer s, integer n, string m, key id,string scriptName){
    integer stat=llGetStatus(1);
    if (n==SLOODLE_HOT_FLOOR_ON){
      llSetText("Closing, please wait..", RED, 1);
    }
    if (n!=-399) return;
    llTriggerSound("door_open_garage",1.0);
    if (scriptName=="LEFT DOOR"){
        if(m==CLOSE_DOOR){ //zF Animation Frame #1
            door_status=CLOSED;
            llSetText("CLOSED", <1,1,1>, 1);
            vector r=<6.13853,12.31528,0.05014>;
            llSetScale(r);
            vector Zfire=llGetScale();
            vector zFire=<0.00239,21.85618,2.99925>;
            vector zfIre=<6.13853,12.31528,0.05014>;
            vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
            vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
            llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.70714,0.70708> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);  
        }
        if(m=="p2"){ //zF Animation Frame #2
            vector r=<4.85209,12.31528,0.05014>;
            llSetScale(r);
            vector Zfire=llGetScale();
            vector zFire=<0.00240,21.21300,2.99930>;
            vector zfIre=<4.85209,12.31528,0.05014>;
            vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
            vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
            llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.70714,0.70708> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);  
        }
        if(m==OPEN_DOOR){ //zF Animation Frame #3
            llSetText("OPEN", <1,1,1>, 1);
            door_status=OPEN;
        vector r=<0.49612,12.31528,0.05014>;
        llSetScale(r);
        vector Zfire=llGetScale();
        vector zFire=<0.00260,19.03500,2.99930>;
        vector zfIre=<0.49612,12.31528,0.05014>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.70714,0.70708> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
        }
    }else
    if (scriptName=="RIGHT DOOR"){
        if(m==CLOSE_DOOR){ //zF Animation Frame #1
            door_status=CLOSED;
            llSetText("CLOSED", <1,1,1>, 1);
            vector r=<6.01566,12.31528,0.05014>;
            llSetScale(r);
            vector Zfire=llGetScale();
            vector zFire=<0.00187,27.93419,2.99925>;
            vector zfIre=<6.01566,12.31528,0.05014>;
            vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
            vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
            llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.70714,0.70708> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
        }
        if(m=="p2"){ //zF Animation Frame #2
            vector r=<5.22404,12.31528,0.05014>;
            llSetScale(r);
            vector Zfire=llGetScale();
            vector zFire=<0.00180,28.33000,2.99930>;
            vector zfIre=<5.22404,12.31528,0.05014>;
            vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
            vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
            llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.70714,0.70708> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
        }
        if(m==OPEN_DOOR){ //zF Animation Frame #3
            door_status=OPEN;
              llSetText("OPEN", <1,1,1>, 1);
            vector r=<0.35302,12.31528,0.05014>;
            llSetScale(r);
            vector Zfire=llGetScale();
            vector zFire=<0.00160,30.76550,2.99930>;
            vector zfIre=<0.35302,12.31528,0.05014>;
            vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
            vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
            llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.70714,0.70708> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
        }
    }
    
    if(stat){
        llSetStatus(1,1);
    }
}
string CLOSE_DOOR="p1";
string OPEN_DOOR="p3"; 
string myScriptName;
default{
    state_entry() {
        door_status=OPEN;
        myScriptName=llGetScriptName();
        doAnim(LINK_SET,-399,OPEN_DOOR,NULL_KEY,myScriptName);
        llMessageLinked(LINK_SET, -399, OPEN_DOOR, NULL_KEY);
        llMessageLinked(LINK_SET, SLOODLE_HOT_FLOOR_OFF, "", NULL_KEY);

        
    }
    
    on_rez(integer r){
    llSetText("", <0,0,0>,1);
        llResetScript();
    }
    touch_start(integer num_detected) {
        key owner= llGetOwner();
        string m;
        if (llDetectedKey(0)!=owner) return;
        if (door_status==CLOSED){
            
             m=OPEN_DOOR;
             llSensor("", "", AGENT, 10,TWO_PI);
             doAnim(LINK_SET,-399,m,owner,myScriptName);
             llMessageLinked(LINK_SET, -399, m, owner);
            door_status=OPEN;
       }else if (door_status==OPEN){
               llSetText("Closing, please wait..", RED, 1);
            llMessageLinked(LINK_SET, SLOODLE_HOT_FLOOR_ON, "", NULL_KEY);
            llSetTimerEvent(2);
            door_status=CLOSED;
            
        }
    }
    sensor(integer num_detected) {
       
        integer i=0; 
        key av;
        for (i=0;i<num_detected;i++){ 
            av=llDetectedKey(i); 
            llPushObject(av, <0,0,-20>, <0,0,90>, TRUE);
        } 
       
    }
    link_message(integer s, integer n, string m, key id){
        doAnim(s,n,m,id,myScriptName);
    }
    timer() {
        llSetTimerEvent(0);
        llMessageLinked(LINK_SET, -399, CLOSE_DOOR, NULL_KEY);
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/building-1.0/object_scripts/hot_floor.lsl

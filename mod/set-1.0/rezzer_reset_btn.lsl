//
// The line above should be left blank to avoid script errors in OpenSim.

// LSL script generated: mod.set-1.0.rezzer_reset_btn.lslp Tue Nov 15 15:49:28 Tokyo Standard Time 2011
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
*  Edmund Edgar
*  Paul Preibisch
*
*  DESCRIPTION
*  This script sits inside of the reset button.  When clicked, a countdown is started.
*  The countdown can be stopped, by clicking the button again as a toggle.
*  If zero is reached by the counter, a linked message is sent to the link_set with a do:reset command
*
*/

//reset
//gets a vector from a string
vector RED = <0.77278,4.391e-2,0.0>;
vector YELLOW = <0.82192,0.86066,0.0>;
vector WHITE = <1.0,1.0,1.0>;
float BTN_RESET_OFFSET = 0.25;
float BTN_CANCEL_OFFSET = -0.25;
integer FACE = 4;
integer counter = 0;
integer TIME_LIMIT = 7;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
list facilitators;
integer toggle = -1;
default {

    on_rez(integer start_param) {
        llResetScript();
    }

    state_entry() {
        llSetText("",RED,1.0);
        toggle = (-1);
        llSetTexture("btn_reset_cancel",FACE);
        llOffsetTexture(0,BTN_RESET_OFFSET,FACE);
        llSetObjectName("btn:Reset");
        facilitators += llStringTrim(llToLower(llKey2Name(llGetOwner())),STRING_TRIM);
    }
   touch_start(integer d) {
       integer j;
       for (j=0;j<d;j++){
               if (llDetectedKey(j)!=llGetOwner()){
                   llSay(0,"Sorry, only "+llKey2Name(llGetOwner())+" can reset this device.");
                   return;
               }
                llTriggerSound("click",1.0);
            if ((toggle == (-1))) {
                toggle *= (-1);
                llSetColor(YELLOW,FACE);
                llOffsetTexture(0,BTN_CANCEL_OFFSET,FACE);
                llSetObjectName("btn:Cancel");
                llSetTimerEvent(1);
            }
            else  {
                toggle *= (-1);
                llSetColor(WHITE,FACE);
                llOffsetTexture(0,BTN_RESET_OFFSET,FACE);
                llSetText("",RED,1.0);
                llSetTimerEvent(0);
                llSetObjectName("btn:Reset");
                counter = 0;
            }
       }
       
    }

  timer() {
        counter++;
        vector color;
        if ((llGetColor(FACE) == YELLOW)) {
            color = RED;
        } else {
            color = YELLOW;
        }
        llSetText((("(" + ((string)(TIME_LIMIT - counter))) + ")"),color,1.0);
        llSetColor(color,FACE);
        if ((counter >= TIME_LIMIT)) {
            llSetTimerEvent(0.0);
            llOffsetTexture(0,BTN_RESET_OFFSET,FACE);
            llSetObjectName("btn:Reset");
            toggle *= (-1);
            llSetText("",RED,1.0);
            llSetColor(WHITE,FACE);
            llMessageLinked(LINK_SET,SLOODLE_CHANNEL_OBJECT_DIALOG,"do:reset",NULL_KEY);
            counter = 0;
        }
        else  llTriggerSound("beepbeep",0.2);
    }

  changed(integer change) {
        if ((change == CHANGED_INVENTORY)) {
            llOffsetTexture(0,BTN_RESET_OFFSET,FACE);
            llSetObjectName("btn:Reset");
            llResetScript();
        }
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/rezzer_reset_btn.lsl 

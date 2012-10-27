//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*  Part of the Sloodle project (www.sloodle.org)
*
*  blinker.lslp
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
*  This script can be used to set the texture or make a linked prim blink.
  
*  Drop this script into a linked prim then send one of the following commands:
*
*  To set the texture:
*                                                      (linked prim name)        (face)          (texture name)
*  eg: llMessageLinked(LINK_SET, SLOODLE_SET_TEXTURE, "pie_slice"+(string)j+"|"+(string)face+"|"+texture,NULL_KEY);
*
*  If developer wants a prim to blink, you can send it two colors which it will toggle between every second for x seconds (timer) and then change back to default color
*                                             (linked prim name)                 (face) (color1)          (color2)              (default color)  (timer)
*  llMessageLinked(LINK_SET, SLOODLE_BLINKER, "blinker_prim|"+(string)ALL_SIDES+"|"+(string)BABY_BLUE+"|"+(string)BLUE+"|"+(string)REZZER_GREY+"|3", NULL_KEY);
*
*  Using this instead of llSetPrimitiveParamsFast because doesn't appear to work in opensim
*/
integer SLOODLE_SET_TEXTURE= -1639277010;
integer SLOODLE_BLINKER=1639277019;//used to send commands to a prim which should blink
vector YELLOW=<1.00000, 1.00000, 0.00000>;
init(){
    llSetTexture("blank_white", ALL_SIDES);
}
integer count=0;
integer TIME_LIMIT=0;

vector TOGGLE_COLOR_1;
vector TOGGLE_COLOR_2;
vector DEFAULT_COLOR;
string MESSAGE;
default {
    on_rez(integer start_param) {
        init();
    }
    state_entry() {
        init();
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==SLOODLE_SET_TEXTURE){
            list data = llParseString2List(str, ["|"], []);
            string prim=llList2String(data, 0);
            if (prim!=llGetObjectName()){
                return;
            }
            integer face=llList2Integer(data, 1);
            string texture=llList2String(data, 2);
            llSetTexture(texture, face);
        }
        else
        if (num==SLOODLE_BLINKER){
            //"blinker_prim|"+(string)ALL_SIDES+"|"+(string)BABYBLUE+"|"+(string)BLUE+"|"+(string)REZZER_GREY+"|3|Received Message from the Server", NULL_KEY);
            list data = llParseString2List(str, ["|"], []);
            string prim=llList2String(data, 0);
            integer face=llList2Integer(data, 1);
            vector TOGGLE_COLOR_1=llList2Vector(data, 2);
            vector TOGGLE_COLOR_2=llList2Vector(data, 3);
            vector DEFAULT_COLOR=llList2Vector(data, 4);
            TIME_LIMIT= llList2Integer(data,5);
            MESSAGE= llList2String(data,6);
            if (prim!=llGetObjectName()){
                return;
            }
            count=0;
            llSetColor(TOGGLE_COLOR_1, face);
             llSetText(MESSAGE, YELLOW, 1);
            llSetTimerEvent(1);
        }
    }
    timer() {
        count++;
        if (count<=TIME_LIMIT){
            if (count%2==0){
                llSetColor(TOGGLE_COLOR_1, ALL_SIDES);
            }else{
                llSetColor(TOGGLE_COLOR_2, ALL_SIDES);
            }    
        }else{
            llSetTimerEvent(0);
            llSetColor(DEFAULT_COLOR, ALL_SIDES);
            count=0;
            llSetText("", YELLOW, 1);
        }
        
    }
    
}

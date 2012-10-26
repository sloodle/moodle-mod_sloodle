//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*  Part of the Sloodle project (www.sloodle.org)
*
*  set_texture.lslp
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
*  waits for a linked message, sets the texture givien: prim_name(string)|face(integer)|texture(string)
*  eg: llMessageLinked(LINK_SET, SLOODLE_SET_TEXTURE, "pie_slice"+(string)j+"|"+(string)face+"|"+texture,NULL_KEY);
*  Using this instead of llSetPrimitiveParamsFast because doesn't appear to work in opensim
*/
integer SLOODLE_SET_TEXTURE= -1639277010;
init(){
	llSetTexture("blank_white", ALL_SIDES);
}
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
    }
}

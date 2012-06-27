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
*   Paul Preibisch
*   Edmund Edgar
*
*  DESCRIPTION
*/
integer SLOODLE_TOUCH_OBJECT_SUCCESS = -1639277100;

default {
    state_entry() {
    
    }
    link_message(integer sender_num, integer num, string str, key userkey) {
    	if (num ==SLOODLE_TOUCH_OBJECT_SUCCESS){
    		llMessageLinked(LINK_SET, -100,"p1", NULL_KEY);
    		llSay("Gave one "+llGetObjectName()+" to " +llKey2Name(userkey));
    		
    	}
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/interaction-1.0/object_scripts/well.lsl 


// The line above should be left blank to avoid script errors in OpenSim.
//child.lslp
//
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
*    Place this scrip into any child objects that at hexagon quizzer rezzes.  That way, when the hexagon quizzer receives a die emssage
* 	 from the root hex, it can clean up any other objects it rezzes
*/
integer SLOODLE_CHANNEL_PARENT=-1639277024;
integer master_listener;
key MASTERS_KEY;
integer SLOODLE_CHANNEL_CHILDREN=-1639277023;
default {
	on_rez(integer start_param) {
		llResetScript();
	}
    state_entry() {
        master_listener=llListen(SLOODLE_CHANNEL_PARENT, "", "", "");
        llSay(SLOODLE_CHANNEL_CHILDREN,"I AM YOUR CHILD");
    }
    listen(integer channel, string name, key id, string str) {
        
        if (MASTERS_KEY==NULL_KEY){
            MASTERS_KEY= id;
            //we now have the master's key, so stop listening to all other keys on the SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE channel
            //and only listen to the master on this channel from now on.
            llListenRemove(master_listener);
            master_listener=llListen(SLOODLE_CHANNEL_PARENT, "", MASTERS_KEY, "");
        }

        if (str=="I AM YOUR FATHER"){
            return;
        }else
        if (str=="die"){
            llDie();
        }
        
    }
    
}

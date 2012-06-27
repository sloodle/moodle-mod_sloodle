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
*   Paul Preibisch
*   Edmund Edgar
*
*  DESCRIPTION
*/


string view_url;
string admin_url;
string sloodleserverroot = "";
string paramstr;
integer SLOODLE_CHANNEL_OPEN_IN_BROWSER= -1639277000;


default{
    on_rez(integer start_param) {
        llResetScript();
    }
touch_start( integer total_number){
    integer j;
    for (j=0;j<total_number;j++){
        if (llDetectedKey(j)!=llGetOwner())return;
        llMessageLinked(LINK_ALL_OTHERS, SLOODLE_CHANNEL_OPEN_IN_BROWSER, "", llDetectedKey(j));
    }



    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/scoreboard-1.0/object_scripts/zztext/btn_open_in_browser.lsl

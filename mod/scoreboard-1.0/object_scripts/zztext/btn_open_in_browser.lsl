// LSL script generated: mod.zztext-scoreboard-1.0.object_scripts.btn_open_in_browser.lslp Sat Mar 31 19:53:39 Tokyo Standard Time 2012
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



integer SLOODLE_SCOREBOARD_OPEN_IN_BROWSER = -1639277000;


default {

    on_rez(integer start_param) {
        llResetScript();
    }

touch_start(integer total_number) {
        if ((llDetectedKey(0) != llGetOwner())) return;
        llMessageLinked(LINK_ALL_OTHERS,SLOODLE_SCOREBOARD_OPEN_IN_BROWSER,"",llDetectedKey(0));
    }
}
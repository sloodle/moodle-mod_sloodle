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
  
default {
    state_entry() {
        llOwnerSay("Hello Scripter");
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num!=-99) return;
        list data = llParseString2List(str, ["|"], []);
        string cmd= llList2String(data,0);
        if (cmd=="SET ALPHA"){
            llSetAlpha(llList2Float(data, 1), ALL_SIDES);
        }
    }
}

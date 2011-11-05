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

*
*  DESCRIPTION
*  This button will send a message to the shared_media screen to open the current_url in a users browser
*  Contributors:
*  Edmund Edgar
*  Paul Preibisch
*/


integer FACE = 4;
integer counter=0;
integer SLOODLE_LOAD_CURRENT_URL= -1639271137; //send message to shared media to open url that it is currently displaying in a browser.

default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
    }
   touch_start(integer d){
              
             
              integer j;
              
              for (j=0;j<d;j++){
                  if (llDetectedKey(j)!=llGetOwner()) return;
                   llTriggerSound("click", 1.0);//
                  llMessageLinked(LINK_SET, SLOODLE_LOAD_CURRENT_URL, "", llDetectedKey(j));
              }
  }//TOUCH
}//default
        
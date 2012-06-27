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
*  As mentioned, this script has been  licensed under GPL 3.0
*  Basically, that means, you are free to use the script, commercially etc, but if you include
*  it in your objects, you must make the source viewable to the person you are distributuing it to -
*  ie: it can not be closed source - GPL 3.0 means - you must make it open!
*  This is so that others can modify it and contribute back to the community.
*  The SLOODLE github can be found here: https://github.com/sloodle
*
*  Enjoy!
*
*  Contributors:
*   Paul Preibisch
*   Edmund Edgar
*
*  DESCRIPTION
* displays bloody red bubbles for 5 seconds then disapears - used for sharks and other under water enemies to rez blood effects  
*/
integer SLOODLE_CHANNEL_ENEMY_ATTACK= -163928666;//Channel to communicate on when attack occurs by an enemy
redBubbles(){
    llParticleSystem([PSYS_PART_MAX_AGE,1.20,
        PSYS_PART_FLAGS, 259,
        PSYS_PART_START_COLOR, <0.89235, 0.04807, 0.25145>,
        PSYS_PART_END_COLOR, <0.91157, 0.04489, 0.21028>,
        PSYS_PART_START_SCALE,<0.20782, 0.25554, 0.00000>,
        PSYS_PART_END_SCALE,<0.22479, 0.20700, 0.00000>,
        PSYS_SRC_PATTERN, 2,
        PSYS_SRC_BURST_RATE,0.00,
        PSYS_SRC_ACCEL, <0.00000, 0.00000, 0.51501>,
        PSYS_SRC_BURST_PART_COUNT,133,
        PSYS_SRC_BURST_RADIUS,0.00,
        PSYS_SRC_BURST_SPEED_MIN,0.05,
        PSYS_SRC_BURST_SPEED_MAX,0.64,
        PSYS_SRC_ANGLE_BEGIN, 0.00,
        PSYS_SRC_ANGLE_END, 0.00,
        PSYS_SRC_OMEGA, <0.00000, 0.00000, 0.72661>,
        PSYS_SRC_MAX_AGE, 0.0,
        PSYS_SRC_TEXTURE, "TEXTURE_BUBBLE",
        PSYS_PART_START_ALPHA, 0.07,
        PSYS_PART_END_ALPHA, 0.66]);
}
  particles_off(){
          llParticleSystem([]);
  }
integer counter=0;
default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        particles_off();
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==SLOODLE_CHANNEL_ENEMY_ATTACK){
                llTriggerSound("SND_BUBBLES", 1);
                 redBubbles();
                 llSetTimerEvent(3);
        }
    }
    timer() {
        
        particles_off();
        llSetTimerEvent(0);
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/gaming-1.0/object_scripts/sharks/redbubbles.lsl 

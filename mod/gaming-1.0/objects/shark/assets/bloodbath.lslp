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
* displays LOTS of blood for 7 seconds then disapears - used for sharks and other under water enemies to rez blood effects  
*/

lotsOfBlood(){
        
    llParticleSystem([PSYS_PART_MAX_AGE,3.19,
    PSYS_PART_FLAGS, 263,
    PSYS_PART_START_COLOR, <0.81514, 0.02902, 0.21840>,
    PSYS_PART_END_COLOR, <0.98654, 0.01346, 0.24787>,
    PSYS_PART_START_SCALE,<0.32215, 0.82749, 0.00000>,
    PSYS_PART_END_SCALE,<0.86394, 0.95700, 0.00000>,
    PSYS_SRC_PATTERN, 4,
    PSYS_SRC_BURST_RATE,0.02,
    PSYS_SRC_ACCEL, <0.00000, 0.00000, -2.31811>,
    PSYS_SRC_BURST_PART_COUNT,20,
    PSYS_SRC_BURST_RADIUS,0.44,
    PSYS_SRC_BURST_SPEED_MIN,0.51,
    PSYS_SRC_BURST_SPEED_MAX,0.37,
    PSYS_SRC_ANGLE_BEGIN, 1.85,
    PSYS_SRC_ANGLE_END, 0.00,
    PSYS_SRC_OMEGA, <0.00000, 0.00000, -50.83492>,
    PSYS_SRC_MAX_AGE, 0.0,
    PSYS_SRC_TEXTURE, "TEXTURE_BLOOD_CLOUD",
    PSYS_PART_START_ALPHA, 0.62,
    PSYS_PART_END_ALPHA, 0.53]);
    
}

default {
    state_entry() {
        lotsOfBlood();
        llSetTimerEvent(7);
    }
    timer() {
        llDie();
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/gaming-1.0/object_scripts/sharks/bloodbath.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*  fricken_laser_beams.lsl
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
*  DESCRIPTION
*  Inspired by the Movie Austin Powers, It is Dr. Evil's wish to have laser beams attached to his attack sharks.  Well Dr. Evil, you got your wish! 
*
*  
*  This script causes a shark to swim around
*
*  Contributors:
*  Paul Preibisch
*/
list particle_parameters=[]; // stores your custom particle effect, defined below.
list target_parameters=[]; // remembers targets found using TARGET TEMPLATE scripts.
integer SLOODLE_CHANNEL_ENEMY_ATTACK= -163928666;//Channel to communicate on when attack occurs by an enemy
integer SLOODLE_CHANNEL_ENEMY_AIM = -163928665;//Channel to communicate on when enemy is aming at target, ie:delivering a laserbeam
laser(key target){
        if (target==NULL_KEY){
            llParticleSystem([]);
            return;
        }
         particle_parameters = [  // start of particle settings
           // Texture Parameters:
           PSYS_SRC_TEXTURE, llGetInventoryName(INVENTORY_TEXTURE, 0),
           PSYS_PART_START_SCALE, <0.051, 1.0, FALSE>, PSYS_PART_END_SCALE, <0.05, 1.0, FALSE>, 
           PSYS_PART_START_COLOR, <1.00,.25,.25>,    PSYS_PART_END_COLOR, <.75,0.00,0.00>, 
           PSYS_PART_START_ALPHA, (float) 1.0,         PSYS_PART_END_ALPHA, (float) .5,     
           // Production Parameters:
           PSYS_SRC_BURST_PART_COUNT, (integer)  5, 
           PSYS_SRC_BURST_RATE,         (float) 0.1,  
           PSYS_PART_MAX_AGE,           (float)  1.0, 
            // PSYS_SRC_MAX_AGE,            (float)  0.00, 
           // Placement Parameters:
           PSYS_SRC_PATTERN, (integer) 4, // 1=DROP, 2=EXPLODE, 4=ANGLE, 8=CONE,
           // Placement Parameters (for any non-DROP pattern):
           PSYS_SRC_BURST_SPEED_MIN, (float) 0.00,   PSYS_SRC_BURST_SPEED_MAX, (float) 5.0, 
            // PSYS_SRC_BURST_RADIUS, (float) 00.00,
           // Placement Parameters (only for ANGLE & CONE patterns):
           PSYS_SRC_ANGLE_BEGIN, (float) 0.00 * PI,   PSYS_SRC_ANGLE_END, (float) 0.00 * PI,  
            // PSYS_SRC_OMEGA, <00.00, 00.00, 00.00>,  
           // After-Effect & Influence Parameters:
           PSYS_SRC_ACCEL, < 00.00, 00.00, 00.0>,
           PSYS_SRC_TARGET_KEY, (key)target, 
           PSYS_PART_FLAGS, (integer) ( 0                  // Texture Options:     
                                | PSYS_PART_INTERP_COLOR_MASK   
                                | PSYS_PART_INTERP_SCALE_MASK   
                                | PSYS_PART_EMISSIVE_MASK   
                                | PSYS_PART_FOLLOW_VELOCITY_MASK
                               // After-effect & Influence Options:
                             // | PSYS_PART_WIND_MASK            
                             // | PSYS_PART_BOUNCE_MASK          
                             // | PSYS_PART_FOLLOW_SRC_MASK     
                             // | PSYS_PART_TARGET_POS_MASK     
                              | PSYS_PART_TARGET_LINEAR_MASK    
                            ) 
            //end of particle settings                     
        ];
        llParticleSystem(particle_parameters);
}

default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
     laser(NULL_KEY);
    }
    
    link_message( integer sibling, integer num, string mesg, key target_key ) {
            if (num==SLOODLE_CHANNEL_ENEMY_AIM){
                llTriggerSound("SND_LASER", 1);
                laser(target_key);
                llSetTimerEvent(3);
            }
        }
       timer() {
                llSetTimerEvent(0);
                 laser(NULL_KEY);
       
       }
        
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/gaming-1.0/object_scripts/sharks/fricken_laser_beams.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Set effects motherscript script
// Sends a cleanup chat-message when touched.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield

integer SLOODLE_CHANNEL_SET_CONFIGURED = -1639270091;
integer SLOODLE_CHANNEL_SET_RESET = -1639270092; 
integer SLOODLE_CHANNEL_OBJECT_CREATOR_WILL_REZ_AT_POSITION = -1639270084;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REZ_FROM_POSITION = -1639270088;

integer SLOODLE_CHANNEL_OBJECT_CREATOR_AUTOREZ_STARTED = -1639270086;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_AUTOREZ_FINISHED = -1639270087;

integer SLOODLE_CHANNEL_SET_GO_HOME = -1639270093;

vector default_hover_offset = <0.0,0.0,3.6>; 
vector default_hover_offset_partway = <0.0,0.0,1.8>;

vector hover_position;
integer is_flying = 0;



take_off()
{
    is_flying = 1;    
    take_off_particles();
    hover_position = llGetPos()+default_hover_offset;    
    //llTargetOmega(<0,0,0.1>,1,1);
    llSleep(1);
    llSetPos(llGetPos()+default_hover_offset_partway);        
    llSleep(2);
    llSetPos(hover_position);    
    llSetTimerEvent(5.0);    
}

land()
{
    is_flying = 0;
    //llTargetOmega(ZERO_VECTOR,0,0);
    llSetPos(llGetPos()-default_hover_offset);     
} 
 
take_off_particles()
{
    llParticleSystem([  PSYS_SRC_ACCEL, <0.0, 0.0, -0.5>,
                        PSYS_PART_START_SCALE, <0.5, 0.5, 0.5>,     
                        PSYS_PART_END_SCALE, <0.05, 0.05, 0.05>,        
                        PSYS_PART_FLAGS, PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_INTERP_COLOR_MASK,
                        PSYS_PART_MAX_AGE, 3.0,                     //This gives us the lifetime of the particles
                        PSYS_SRC_BURST_RATE, 0.2,                    //There's a new burst every 1.0 seconds
                        PSYS_SRC_BURST_SPEED_MIN, 0.01,                //The minimum speed of the particles (in m/s)
                        PSYS_SRC_BURST_SPEED_MAX, 1.0,                //The maximum speed - so they move slowly
                        PSYS_SRC_BURST_PART_COUNT, 200,                //How many particles to make
                        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE, 
                        PSYS_SRC_ANGLE_BEGIN, 2.8,
                        PSYS_SRC_ANGLE_END, 3.2,
                        PSYS_PART_START_COLOR, <1.0, 0.0, 0.0>, //Starts it out normal colour (white)
                        PSYS_PART_END_COLOR, <1.0, 1.0, 0.0>//,
                    ]);    
} 

object_move_to(vector position) {
    vector last;
    do {
        last = llGetPos();
        llSetPos(position);  
    } while ((llVecDist(llGetPos(),position) > 0.001) && (llGetPos() != last));
}

default 
{
    state_entry() {
        is_flying = 0;
    }
    
    on_rez(integer int) {
        is_flying = 0;
    }
    
    timer()
    {
        llTargetOmega(ZERO_VECTOR,0,0);
        llParticleSystem([]);        
    }
    
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_REZ_FROM_POSITION) { // NB the position is relative to the hover_position
            vector rezzer_position = hover_position + (vector)str;
            object_move_to(rezzer_position);
        } else if (num == SLOODLE_CHANNEL_SET_CONFIGURED) {
            take_off();
        } else if (num == SLOODLE_CHANNEL_SET_RESET) {
            if (is_flying == 1) {
                land();
            }
        } else if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_AUTOREZ_STARTED) {
            hover_position = llGetPos(); // When we start autorezzing, save the original position. This will be the same as the hover_position set at takeoff unless somebody moved us around. TODO: Are there situations where this could get called while we're busy moving?
        } else if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_AUTOREZ_FINISHED) {
            object_move_to(hover_position); 
        } 
    } 
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_set_effects_mothership.lslp 

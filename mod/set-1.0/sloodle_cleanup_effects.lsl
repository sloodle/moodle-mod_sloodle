// Sloodle Set object cleanup effects script.
// Sends a cleanup chat-message when touched.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield

integer SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_STARTED = -1639270082;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_FINISHED = -1639270083;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_WILL_REZ_AT_POSITION = -1639270084;
integer SLOODLE_CHANNEL_SET_CONFIGURED = -1639270091;
integer SLOODLE_CHANNEL_SET_RESET = -1639270092;
integer SLOODLE_CHANNEL_OBJECT_CLEANUP_STARTING = -1639270085;

show_cleanup_button()
{
        llSetPos(llGetRootPosition() - <0, 0, 0.4>);
}

hide_cleanup_button()
{
        llSetPos(llGetRootPosition());
}

do_cleanup_effects()
{
    show_cleanup_button();
    llSetTimerEvent(2.0);
    llParticleSystem([  PSYS_SRC_ACCEL, <0.0, 0.0, -0.3>,
                        PSYS_PART_START_SCALE, <0.5, 0.5, 0.5>,     
                        PSYS_PART_END_SCALE, <0.5, 0.5, 0.5>,        
                        PSYS_PART_FLAGS, PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_INTERP_COLOR_MASK,
                        PSYS_PART_MAX_AGE, 10.0,                     
                        PSYS_SRC_BURST_RATE, 0.2,                    
                        PSYS_SRC_BURST_SPEED_MIN, 0.5,                
                        PSYS_SRC_BURST_SPEED_MAX, 2.0,              
                        PSYS_SRC_BURST_PART_COUNT, 100,             
                        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE, 
                        PSYS_SRC_ANGLE_BEGIN, PI_BY_TWO/2.0,
                        PSYS_SRC_ANGLE_END, PI_BY_TWO/1.0,
                        PSYS_PART_START_COLOR, <1.0, 1.0, 1.0>, 
                        PSYS_PART_END_COLOR, <6.0, 6.0, 6.0>//,
                    ]);    
}
default 
{
    timer()
    {
        llParticleSystem([]);
        hide_cleanup_button();
    }
    link_message(integer sender_num, integer num, string str, key id) {

        if (num == SLOODLE_CHANNEL_SET_CONFIGURED) {
           // show_cleanup_button();
        } else if (num == SLOODLE_CHANNEL_SET_RESET) {
            //hide_cleanup_button();
        } else if (num == SLOODLE_CHANNEL_OBJECT_CLEANUP_STARTING) {
            do_cleanup_effects();
        }
    }
  
} 


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_cleanup_effects.lsl 

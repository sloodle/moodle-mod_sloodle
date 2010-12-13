// Sloodle Set ufo top script.
// Sends a cleanup chat-message when touched.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar


integer SLOODLE_CHANNEL_SET_CONFIGURED = -1639270091;
integer SLOODLE_CHANNEL_SET_RESET = -1639270092; 

default 
{
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SLOODLE_CHANNEL_SET_CONFIGURED) {
            llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES, 0.2]);
        } else if (num == SLOODLE_CHANNEL_SET_RESET) {
            llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES, 0.0]);
        }
    }
    
    state_entry()
    {
        llSetTexture(TEXTURE_BLANK,0);
    }
}
 
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_ufo_top.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Set object door handle script.
// Sends a cleanup chat-message when touched.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar


integer SLOODLE_CHANNEL_SET_SIMPLE_DOOR_OPEN =-1639270101;
integer SLOODLE_CHANNEL_SET_SIMPLE_DOOR_CLOSED = -1639270102;

default
{
    link_message( integer sender_num, integer num, string str, key id ){ 
        if ( num == SLOODLE_CHANNEL_SET_SIMPLE_DOOR_OPEN ) {
            llSetAlpha(0.0, ALL_SIDES); // set entire prim 100% invisible.
        } else if ( num == SLOODLE_CHANNEL_SET_SIMPLE_DOOR_CLOSED ) {
            llSetAlpha(1.0, ALL_SIDES); // set entire prim 100% visible.
        }
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_set_simple_door_handle.lslp 

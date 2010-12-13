// Sloodle Set Pinger
// 
// Send pings from the mothership set to the simple set to let it know we're here.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2009 Contributors (see below)
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar

integer SLOODLE_CHANNEL_SET_LAYOUT_REZZER_PING  = -1639270095;

default
{
    state_entry()
    {
        llSetTimerEvent(15); // set a timer to ping every 15 seconds to say we're here
        llShout(SLOODLE_CHANNEL_SET_LAYOUT_REZZER_PING, (string)llGetOwner());
    }
    
    on_rez(integer param) 
    {
        llSetTimerEvent(15); // set a timer to ping every 15 seconds to say we're here
        llShout(SLOODLE_CHANNEL_SET_LAYOUT_REZZER_PING, (string)llGetOwner());        
    }
    
    timer() 
    {
        llShout(SLOODLE_CHANNEL_SET_LAYOUT_REZZER_PING, (string)llGetOwner());
        llSetTimerEvent(15);
    }

}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_set_mothership_pinger.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

// Sliding door script
// (c) Edmund Edgar, 2007-07-09
// Licensed under GPL v2

vector closedpos = <-1.0, 0.0, 0.0>; // relative to root prim
vector openpos = <0, 0.0, 0.0>;
integer SLOODLE_CHANNEL_OBJECT_ACCESS_CHECKER_PERMIT = -1639270032;

default {
    state_entry() {
        state closed;   
    }
}

state closed {
     
    state_entry() {
        llSetPos(closedpos);  
    }

    link_message(integer sender_num, integer num, string str, key id) {
        //llSay(0,"got linked message");
        if (num == SLOODLE_CHANNEL_OBJECT_ACCESS_CHECKER_PERMIT) {
            // ideally would also catch the uuid of the avatar here, and close once they've gone through...
            state open;          
        } 
    }
    
}

state open {

    state_entry() {
        llSetTimerEvent(8.0);        
        llSetPos(openpos);
    }

    timer() {
        state closed;
    }
    
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/accesscheckerdoor-1.0/sloodle_accesscheckerdoor_right.lsl 

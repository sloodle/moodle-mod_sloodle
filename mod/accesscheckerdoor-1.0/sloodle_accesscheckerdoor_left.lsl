// Sliding door script
// (c) Edmund Edgar, 2007-07-09
// Licensed under GPL v2 as part of the Sloodle Project

vector closedpos = <-2.0, 0.0, 0.0>; // relative to root prim
vector openpos = <-3.0, 0.0, 0.0>;
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
        if (num == SLOODLE_CHANNEL_OBJECT_ACCESS_CHECKER_PERMIT) {
            // ideally would also catch the uuid of the avatar here, and close once they've gone through...
            state open;
            //llSay(0,"opened");
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
// SLOODLE LSL Script Subversion Location: mod/accesscheckerdoor-1.0/sloodle_accesscheckerdoor_left.lsl 

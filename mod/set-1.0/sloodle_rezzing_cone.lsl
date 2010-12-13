// Sloodle Set rezzing cone script.
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

vector hidden_offset = <0.0,0.0,0.0>; // when hidden, put at the center of the prim
vector shown_offset = <0.0,0.0,-2.0>; // when hidden, put 2 meters below the prim

show()
{
    llSetPos(shown_offset);
    llSetScale(<4.0,4.0,4.0>);
    llSetAlpha(0.5,ALL_SIDES);
    llSetTimerEvent(5.0);
}

hide()
{
    llSetAlpha(0.0,ALL_SIDES);      
    llSetScale(<0.4,0.4,0.4>);  
    llSetPos(hidden_offset);    
}

default
{
    state_entry()
    {
        llSetPrimitiveParams([PRIM_PHANTOM,TRUE]);        
        hide();
    }
 
    timer()
    {
        hide();       
    }
    
   // touch_start(integer total_number)
    //{
    //    show();
 //   }
    
    link_message(integer sender_num, integer num, string str, key id) {
        //llOwnerSay((string)num);
        if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_STARTED) {
            show();
        } else if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_FINISHED) {
        }
    } 
          
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_rezzing_cone.lsl 

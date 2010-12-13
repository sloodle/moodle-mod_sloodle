// Sloodle Set object layout effects script.
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


show_layout_button()
{        
        llSetPos(<0, 1.1, -0.35>);
        llSetScale(<0.4,0.4,0.15>);
}

hide_layout_button()
{
        llSetScale(<0.2,0.2,0.01>);    
        llSetPos(<0, 0.5, 0>);
        
}

default 
{
    link_message(integer sender_num, integer num, string str, key id) {

        if (num == SLOODLE_CHANNEL_SET_CONFIGURED) {
            show_layout_button();
        } else if (num == SLOODLE_CHANNEL_SET_RESET) {
            hide_layout_button();
        }
    }
    
    state_entry()
    {
        llSetTexture("layouts_text",0);
        llSetTexture("layouts_text",1);
        llSetTexture("layouts_text",2);
        llSetTexture("layouts_text",3);
        llSetTexture("layouts_text",4);
        llSetTexture("layouts_graphic",5);
        hide_layout_button();
    }    
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_layout_effects.lsl 

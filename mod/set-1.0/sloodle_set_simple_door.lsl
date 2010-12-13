// Sloodle Set object simple door script.
// Sends a cleanup chat-message when touched.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar



integer open=FALSE; 
integer SLOODLE_CHANNEL_SET_SIMPLE_DOOR_OPEN =-1639270101;
integer SLOODLE_CHANNEL_SET_SIMPLE_DOOR_CLOSED = -1639270102;

default 
{ 
    state_entry() 
    {      
       llSetLocalRot(llEuler2Rot( <0, 0, 270 * DEG_TO_RAD> ));       
    } 
    touch_start(integer total_number) 
    { 
       // if(llDetectedKey(0) == llGetOwner())
        
        if (open==TRUE) { 
            llSetLocalRot(llEuler2Rot( <0, 0, 270 * DEG_TO_RAD> ));
            llMessageLinked(LINK_ALL_OTHERS,SLOODLE_CHANNEL_SET_SIMPLE_DOOR_CLOSED,"",NULL_KEY);  
            open = FALSE;            
        } else { 
            llMessageLinked(LINK_ALL_OTHERS,SLOODLE_CHANNEL_SET_SIMPLE_DOOR_OPEN,"",NULL_KEY);        
            llSetLocalRot(llEuler2Rot( <0, 0, 0 * DEG_TO_RAD> ));   open = TRUE; 
        } 
        
    } 
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_set_simple_door.lsl 

// Sloodle Set object simple door script.
//
// Part of the Sloodle project (www.sloodle.org).
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Paul Preibisch


integer open=FALSE; 
integer SLOODLE_CHANNEL_SET_SIMPLE_DOOR_OPEN =-1639270101;
integer SLOODLE_CHANNEL_SET_SIMPLE_DOOR_CLOSED = -1639270102;
integer SLOODLE_CHANNEL_OBJECT_DIALOG                   = -3857343;

default 
{ 
    state_entry() 
    {      
        llSetLocalRot(llEuler2Rot( <0, 0, 270.00 * DEG_TO_RAD> ));       
        llTriggerSound("close",1.0);
        llSleep(2); // Give it a couple of seconds for the texture inside the door to load, before we allow the user to open it. This prevents problems with auto-zoom that occur if you click too early.        
    }  
 link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // What was the message?
            if (str == "do:reset") llResetScript();
        }
    }
    touch_start(integer total_number)  
    { 
       // if(llDetectedKey(0) == llGetOwner())
        
        if (open==TRUE) { 
            llSetLocalRot(llEuler2Rot( <0, 0, 45 * DEG_TO_RAD> ));
            llMessageLinked(LINK_ALL_OTHERS,SLOODLE_CHANNEL_SET_SIMPLE_DOOR_CLOSED,"",NULL_KEY);  
            llTriggerSound("open",1.0);     
            llMessageLinked(LINK_SET, -99, "turn glow on", NULL_KEY);
            open = FALSE;             
        } else { 
            llMessageLinked(LINK_ALL_OTHERS,SLOODLE_CHANNEL_SET_SIMPLE_DOOR_OPEN,"",NULL_KEY);   
           // llSetPos( llGetRootPosition() );
            llTriggerSound("close",1.0);
            llSetLocalRot(llEuler2Rot( <0, 0, 270 * DEG_TO_RAD> ));   open = TRUE; 
            llMessageLinked(LINK_SET, -99, "turn glow off", NULL_KEY);
        } 
        
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_set_simple_door.lsl

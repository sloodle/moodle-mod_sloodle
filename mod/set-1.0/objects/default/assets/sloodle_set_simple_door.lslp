//
// The line above should be left blank to avoid script errors in OpenSim.

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

integer last_touch_ts = 0;

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
        integer j=0;
        for (j=0;j<total_number;j++){
            if (llDetectedKey(j)!=llGetOwner()){
                llInstantMessage(llDetectedKey(j),"Sorry, but you must be the owner to open this rezzer");
                return;
            }
        }
        
        // If less than three seconds have elapsed since the last touch we handled, ignore it.
        // This prevents a double-click closing the door as soon as it finishes opening.
        if (llGetUnixTime() - last_touch_ts < 2) {
            return;
        }
        
        vector theRot = llRot2Euler(llGetLocalRot());
        float theRotZ = theRot.z*RAD_TO_DEG;
        //the reason we are comparing to -80 instead of -90 is because opensim and sl have different precision for rotations, 90 would probably be ok, but lets be safe!
        if (theRotZ<=-80){ 
            llSetLocalRot(llEuler2Rot( <0, 0, 45 * DEG_TO_RAD> ));
            llMessageLinked(LINK_ALL_OTHERS,SLOODLE_CHANNEL_SET_SIMPLE_DOOR_CLOSED,"",NULL_KEY);  
            llTriggerSound("open",1.0);     
            llTriggerSound("powerup",1.0); 
            llMessageLinked(LINK_SET, -99, "turn glow on", NULL_KEY);                       
        } else { 
            llMessageLinked(LINK_ALL_OTHERS,SLOODLE_CHANNEL_SET_SIMPLE_DOOR_OPEN,"",NULL_KEY);   
           // llSetPos( llGetRootPosition() );
            llTriggerSound("close",1.0);
            llTriggerSound("powerdown",1.0); 
            llSetLocalRot(llEuler2Rot( <0, 0, 270 * DEG_TO_RAD> ));   open = TRUE; 
            llMessageLinked(LINK_SET, -99, "turn glow off", NULL_KEY);          
        } 
        last_touch_ts = llGetUnixTime();
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_set_simple_door.lslp


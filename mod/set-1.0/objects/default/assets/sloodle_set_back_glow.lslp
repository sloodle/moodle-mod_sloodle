//
// The line above should be left blank to avoid script errors in OpenSim.

integer SLOODLE_CHANNEL_OBJECT_DIALOG                   = -3857343;//configuration channel
integer counter;

default
{
    state_entry()
    {
       llSetPrimitiveParams(    [ PRIM_GLOW,2,0.0 ] );
                llSetPrimitiveParams(    [ PRIM_GLOW,0,0.0 ] );
          counter=0;
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
  // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // What was the message?
            if (str == "do:reset"){
                   llTriggerSound("powerdown",1.0);              
                llSetPrimitiveParams(    [ PRIM_GLOW,2,0.0 ] );
                llSetPrimitiveParams(    [ PRIM_GLOW,0,0.0 ] );
                }
        }
        if (num != -99) return;
        else {
            if (str == "do:reset") llResetScript();
            // What was the message?
            else
            if (str == "turn glow on"){
                llTriggerSound("powerup",1.0);
              llSetPrimitiveParams(    [ PRIM_GLOW,2,0.40 ] );
              llSetPrimitiveParams(    [ PRIM_GLOW,0,0.40 ] );
            }else
            if (str == "turn glow off"){
                llTriggerSound("powerdown",1.0);              
                llSetPrimitiveParams(    [ PRIM_GLOW,2,0.0 ] );
                llSetPrimitiveParams(    [ PRIM_GLOW,0,0.0 ] );
            }

        }  
    }              
   

}


// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_set_back_glow.lslp 

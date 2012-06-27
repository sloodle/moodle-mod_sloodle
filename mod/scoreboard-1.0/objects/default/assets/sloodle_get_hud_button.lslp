//
// The line above should be left blank to avoid script errors in OpenSim.

default
{
   

touch_start( integer total_number)
    {
        if (llDetectedKey(0)!=llGetOwner())return;
           
               llTriggerSound("SND_INTERFACE_BEEP", 1);
               llGiveInventory(llGetOwner(), "Avatar Classroom Scoreboard Admin HUD");
                
     
    }
}


// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/scoreboard-1.0/objects/default/assets/sloodle_get_hud_button.lslp 

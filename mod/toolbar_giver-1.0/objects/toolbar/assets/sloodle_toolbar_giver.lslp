//
// The line above should be left blank to avoid script errors in OpenSim.

// Edmund Edgar, 2012-05-12: Removing the full toolbar, just using the lite one.
// If we resurrect the full toolbar, get the old version of this script from Git.
default
{
    state_entry()
    {
        llSetText("Click to get your toolbar", <0,0,1>, 100);
    }

    touch_start(integer total_number)
    {
        integer i;
        for (i=0; i<total_number; i++) {
            llGiveInventory(llDetectedKey(i), "Sloodle Lite Toolbar v1.4");
        }        
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/toolbar_giver-1.0/objects/toolbar/assets/sloodle_toolbar_giver.lslp


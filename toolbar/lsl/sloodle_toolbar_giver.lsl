//
// The line above should be left blank to avoid script errors in OpenSim.

integer CHAT_CHANNEL;

//just returns a random integer - used for setting channels
integer random_integer( integer min, integer max ){
  return min + (integer)( llFrand( max - min + 1 ) );
}
default
{
    state_entry()
    {
        llSetText("Click to get your FREE SLOODLE Toolbar", <0,0,1>, 100);
        CHAT_CHANNEL= random_integer(80000,90000);
        llListen(CHAT_CHANNEL,"", "","");
        llSay(0, "Hello, Please click on the Tool Bar Giver Prim to get your FREE SLOODLE Toolbar!");
    }

    touch_start(integer total_number)
    {
        llDialog(llDetectedKey(0), "Please select a Toolbar", ["Toolbar 1.4","Toolbar Lite","Help"], CHAT_CHANNEL);
        
    }
    listen(integer channel, string name, key id, string message) {
        if (channel == CHAT_CHANNEL)
            if (message=="Toolbar 1.4") llGiveInventory(id, "Sloodle Toolbar v1.4");
            else if (message=="Toolbar Lite") llGiveInventory(id, "Sloodle Lite Toolbar v1.4");
            else if (message=="Help") llGiveInventory(id, "SLOODLE TOOLBAR RELEASE NOTES");
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: toolbar/lsl/sloodle_toolbar_giver.lsl

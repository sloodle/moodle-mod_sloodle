//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Choice text display
// Displays the text of a choice using hover text
//
// Copyright (c) 2008 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//

integer SLOODLE_CHANNEL_OBJECT_CHOICE = -1639270051;

// Update the choice text. Followed by "|text"
string SLOODLE_CHOICE_UPDATE_TEXT = "do:updatetext";


vector TEXT_COLOUR = <1.0, 0.5, 0.0>;
float TEXT_ALPHA = 1.0;


default
{
    state_entry()
    {
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_CHOICE) {
            // Parse the string
            list parts = llParseString2List(sval, ["|"], []);
            integer numparts = llGetListLength(parts);
            string cmd = llList2String(parts, 0);
            if (cmd == "do:reset") {
                llSetText("", <0.0, 0.0, 0.0>, 0.0); 
            } else if (cmd == SLOODLE_CHOICE_UPDATE_TEXT) {
                // There should be a parameter
                if (numparts > 1) llSetText(llList2String(parts, 1), TEXT_COLOUR, TEXT_ALPHA);
                else llSetText("", <0.0, 0.0, 0.0>, 0.0);
            }
        }
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/choice-1.0/objects/default/assets/sloodle_choice_text.lslp 

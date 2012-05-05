//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Blog visibility display
// Shows the current visibility setting of the Toolbar.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2008 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield - original design and implementation
//

///// CONSTANTS /////

// Channel used for object communications
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;

// The text to indicate a blog command
string SLOODLE_CMD_BLOG = "blog";
// The text to indicate a visibility setting
string SLOODLE_CMD_VISIBILITY = "visibility";

// Which side will the texture apply to?
integer TEXTURE_SIDE = 5;

///// STATES /////

default
{
    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check which channel this is on
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into its parts (separated by a pipe character)
            list parts = llParseStringKeepNulls(str, ["|"], []);
            // Make sure we have an additional command and a number
            if (llGetListLength(parts) < 3) return;
            
            // Make sure it is a blog command
            string cmd = llList2String(parts, 0);
            if (cmd != SLOODLE_CMD_BLOG) return;
            
            // Make sure it is a channel command
            string cmd2 = llList2String(parts, 1);
            if (cmd2 != SLOODLE_CMD_VISIBILITY) return;
            
            // Extract the name of the visibility mode
            string vismode = llToLower(llList2String(parts, 2));
            if (vismode == "draft") vismode = "private";
            
            // If we have an appropriate texture, then use it
            if (llGetInventoryType(vismode) == INVENTORY_TEXTURE) {
                llSetTexture(vismode, TEXTURE_SIDE);
            }
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: toolbar/lsl/sloodle_blog_visibility_display.lsl 

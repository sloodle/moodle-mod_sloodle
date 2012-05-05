//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Blog channel display
// Shows which channel the blog is currently listening on (for user input)
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
// The text to indicate a channel
string SLOODLE_CMD_CHANNEL = "channel";

// Name of each texture
list TEX_NAMES = [  "number_0_sans",
                    "number_1_sans",
                    "number_2_sans",
                    "number_3_sans",
                    "number_4_sans",
                    "number_5_sans",
                    "number_6_sans",
                    "number_7_sans",
                    "number_8_sans",
                    "number_9_sans" ];

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
            if (cmd2 != SLOODLE_CMD_CHANNEL) return;
            
            // Extract the channel number, and make sure it's valid
            integer ch = (integer)llList2String(parts, 2);
            if (ch < 0 || ch >= llGetListLength(TEX_NAMES)) return;
            
            // Set the texture
            llSetTexture(llList2String(TEX_NAMES, ch), TEXTURE_SIDE);
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: toolbar/lsl/sloodle_blog_channel_display.lsl 

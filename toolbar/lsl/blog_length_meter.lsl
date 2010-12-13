// Sloodle Blog Length meter
// Shows the length of the current blog entry, relative to the maximum allowable length
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2008 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//

// Usage:
//  Expects a link message on SLOODLE_CHANNEL_OBJECT_DIALOG channel,
//   containing text "bloglength|" followed by a float value between 0 and 1.
//  The float value indicates how full the blog is.



///// CONSTANTS /////

string SLOODLE_CMD_BLOG_LENGTH = "bloglength";
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;

// The minimum and maximum sizes of this object
float MIN_SIZE = 0.01;
float MAX_SIZE = 0.363;


///// FUNCTIONS /////

// Update the width of the meter
update_width( float f )
{
    // Make sure the propertion is valid
    if (f < 0.0) f = 0.0;
    else if (f > 1.0) f = 1.0;
    
    // Get the current size
    vector scale = llGetScale();
    // Calculate and apply the new width
    scale.y = MIN_SIZE + ((MAX_SIZE - MIN_SIZE) * f);
    llSetScale(scale);    
}


///// STATES /////
// Only 1 state
default
{
    state_entry()
    {
        // Start at the smallest size
        update_width(0.0);
    }
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        // Is this the right channel?
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message
            list parts = llParseStringKeepNulls(msg, ["|"], []);
            if (llGetListLength(parts) < 2) return;
            // Check the command
            string cmd = llList2String(parts, 0);
            if (cmd == SLOODLE_CMD_BLOG_LENGTH) {
                update_width((float)llList2String(parts, 1));
                return;
            }
        }
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: toolbar/lsl/blog_length_meter.lsl 

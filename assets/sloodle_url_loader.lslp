//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle URL loader
// Allows other scripts to transfer the loading of a *single* URL to another script
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2007 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//

//
// When receiving a link message, this script will load a URL for a given user.
// The URL should be in the string, and the user specified by their key.
// The integer number in the link message should be SLOODLE_CHANNEL_OBJECT_LOAD_URL
//
// The purpose of this script is to allow the continued execution of another script,
// even after a link has been presented.


///// DATA /////

// The link message integer code identifying the message to load a URL
integer SLOODLE_CHANNEL_OBJECT_LOAD_URL = -1639270041;

///// ---- /////

default
{
    link_message( integer sender_num, integer msg_num, string str, key id )
    {
        // Is this the correct message number and are the variables non-empty?
        if (msg_num == SLOODLE_CHANNEL_OBJECT_LOAD_URL && str != "" && id != NULL_KEY)
        {
            // Load the URL
            llLoadURL(id, "", str);
        }
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: lsl/sloodle_url_loader.lsl 

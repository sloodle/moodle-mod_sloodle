//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle parallel URL loader
// Allows the loading of a single URL on a specified channel.
// (NOTE: should be in the same prim as a "sloodle_multi_url_loader.lsl" script)
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
// NOTE: you MUST customize the "MY_CHANNEL_INDEX" value to indicate which script number this is.
//  Each of these scripts in a given object should have a unique channel index.
//  This identifies where the object appears in the sequence.
//  Channel indices should be numbered sequentially from 0.
//  It is recommended that you replace the "x" in the script name to correspond to the channel index.


///// DATA /////

// The index of the channel this script will receive requests on
// (NOTE: corresponds to indices in the list below)
integer MY_CHANNEL_INDEX = 3;


// OUTGOING link message numbers for parallel load requests
list SLOODLE_CHANNEL_LIST_LOAD_URL_x =  [
                                        -1699000001, //SLOODLE_CHANNEL_LOAD_URL_0
                                        -1699000002, //SLOODLE_CHANNEL_LOAD_URL_1
                                        -1699000003, //SLOODLE_CHANNEL_LOAD_URL_2
                                        -1699000004, //SLOODLE_CHANNEL_LOAD_URL_3
                                        -1699000005, //SLOODLE_CHANNEL_LOAD_URL_4
                                        -1699000006, //SLOODLE_CHANNEL_LOAD_URL_5
                                        -1699000007, //SLOODLE_CHANNEL_LOAD_URL_6
                                        -1699000008, //SLOODLE_CHANNEL_LOAD_URL_7
                                        -1699000009, //SLOODLE_CHANNEL_LOAD_URL_8
                                        -1699000010  //SLOODLE_CHANNEL_LOAD_URL_9
                                        ];

///// ---- /////

default
{
    state_entry()
    {
        if (MY_CHANNEL_INDEX < 0 || MY_CHANNEL_INDEX > llGetListLength(SLOODLE_CHANNEL_LIST_LOAD_URL_x)) {
            llOwnerSay("WARNING: script \"" + llGetScriptName() + "\" has an invalid channel index. Please alter value \"MY_CHANNEL_INDEX\".");
        }
    }
    
    link_message( integer sender_num, integer msg_num, string str, key id )
    {
        // Ignore this message if the variables are empty
        if (str == "" || id == NULL_KEY) return;
        // If this message is not on the correct channel, then ignore it
        if (msg_num != llList2Integer(SLOODLE_CHANNEL_LIST_LOAD_URL_x, MY_CHANNEL_INDEX)) return;
        
        // Load the URL
        llLoadURL(id, "", str);
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: assets/sloodle_parallel_url_loader_3.lslp 

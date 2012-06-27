//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle multiple URL loader
// Manages the parallelized loading of multiple (potentially) simultaneous URLs for different users
// (NOTE: requires copies of the "sloodle_parallel_url_loader_x.lsl" script to be in the SAME prim)
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2007 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Peter R. Bloomfield
//

//
// When receiving an appropriate link message, this will forward it on an appropriate channel to be handled.
// It will then move on to the next channel, allowing a sequence to be created, whereby URL loading can be parallelized.
// NOTE: you may need to customize the "NUM_PARALLEL_SCRIPTS" value if you have fewer parallel scripts.


///// DATA /////


// The maximum number of parallel scripts available (should not be bigger than list below)
integer NUM_PARALLEL_SCRIPTS = 10;



// INCOMING link message number for load requests
integer SLOODLE_CHANNEL_OBJECT_LOAD_URL = -1639270041;

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

// Current channel being used (corresponds to indices of above list)
integer current_request_channel = 0;

///// ---- /////

default
{
    link_message( integer sender_num, integer msg_num, string str, key id )
    {
        // Is this the correct message number and are the variables non-empty?
        if (msg_num == SLOODLE_CHANNEL_OBJECT_LOAD_URL && str != "" && id != NULL_KEY)
        {
            // Send the request to a parallel script
            llMessageLinked(LINK_THIS, llList2Integer(SLOODLE_CHANNEL_LIST_LOAD_URL_x, current_request_channel), str, id);
            current_request_channel += 1;
            
            // Wrap the request channel value round if necessary
            integer num = llGetListLength(SLOODLE_CHANNEL_LIST_LOAD_URL_x);
            if (NUM_PARALLEL_SCRIPTS < num) num = NUM_PARALLEL_SCRIPTS;
            current_request_channel %= num;
        }
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: assets/misc/sloodle_multi_url_loader.lslp 

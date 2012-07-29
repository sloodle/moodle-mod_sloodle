// Sloodle Instant Messager
// Gets instant messages on the HTTP-in channel from the sloodle_rezzer_object, instant messages the content to the user.
//
// Copyright (c) 2012 contributors (see below)
// Released under the GNU GPL
//
// Contributors:
//  Edmund Edgar
//  Paul Preibisch
//

integer SLOODLE_CHANNEL_MESSAGER_INSTANT_MESSAGE = 163290001;

// Only one state - all we ever do is relay instant messages.
default
{    
    link_message( integer sender_num, integer num, string str, key id)
    {
        
       // llOwnerSay("got message"+str+" with num "+(string)num);
        // Check the channel
        if (num == SLOODLE_CHANNEL_MESSAGER_INSTANT_MESSAGE) {
            
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            
            key avuuid = NULL_KEY;
            string message = "";
            
            integer i = 0;
            for (i=1; i < numlines; i++) { // start at line 1 and ignore the status line.
                list bits = llParseString2List(llList2String(lines, i), ["|"], []);
                if (llGetListLength(bits) > 1) {
                    string name = llList2String(bits, 0);
                    if (name == "avuuid") {                        
                        avuuid = llList2Key(bits, 1);
                    } else if (name == "message") {
                        message = llList2String(bits, 1);
                    }
                }
            }
            
            if ( (avuuid != NULL_KEY) && (message != "") ) {
                llInstantMessage(avuuid, message );
            }

        }
    }
    
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/messager-1.0/objects/instantmessager/assets/instantmessager.lslp


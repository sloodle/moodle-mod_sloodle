// Sloodle Blog "Ready" display
// Shows when the blog is ready, not ready, or in the error state
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
// The text to indicate each state
string SLOODLE_CMD_READY = "ready";
string SLOODLE_CMD_NOTREADY = "notready";
string SLOODLE_CMD_ERROR = "error";
string SLOODLE_CMD_SUBJECT = "subject";
string SLOODLE_CMD_BODY = "body";
string SLOODLE_CMD_CONFIRM = "confirm";
string SLOODLE_CMD_SENDING = "sending";

// Name of each texture
string SLOODLE_TEX_READY = "ready";
string SLOODLE_TEX_NOTREADY = "not_ready";
string SLOODLE_TEX_ERROR = "error";
string SLOODLE_TEX_SUBJECT = "subject";
string SLOODLE_TEX_BODY = "body";
string SLOODLE_TEX_CONFIRM = "confirm";
string SLOODLE_TEX_SENDING = "sending";

// Which side will the texture apply to?
integer TEXTURE_SIDE = 5;

///// STATES /////

default
{
    state_entry()
    {
        llSetTexture(SLOODLE_TEX_NOTREADY, TEXTURE_SIDE);
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check which channel this is on
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
        
            // Split the message into its parts (separated by a pipe character)
            list parts = llParseStringKeepNulls(str, ["|"], []);
            string cmd = llList2String(parts, 0);
            // If this is not a blog command, then ignore it
            if (cmd != SLOODLE_CMD_BLOG) return;
            // Make sure we have a status part
            if (llGetListLength(parts) < 2) return;
            string status = llList2String(parts, 1);
            
            // Check what the status is
            if (status == SLOODLE_CMD_READY) {
                llSetTexture(SLOODLE_TEX_READY, TEXTURE_SIDE);
                
            } else if (status == SLOODLE_CMD_NOTREADY) {
                llSetTexture(SLOODLE_TEX_NOTREADY, TEXTURE_SIDE);
                
            } else if (status == SLOODLE_CMD_ERROR) {
                llSetTexture(SLOODLE_TEX_ERROR, TEXTURE_SIDE);
                
            } else if (status == SLOODLE_CMD_SUBJECT) {
                llSetTexture(SLOODLE_TEX_SUBJECT, TEXTURE_SIDE);
                
            } else if (status == SLOODLE_CMD_BODY) {
                llSetTexture(SLOODLE_TEX_BODY, TEXTURE_SIDE);
                
            } else if (status == SLOODLE_CMD_CONFIRM) {
                llSetTexture(SLOODLE_TEX_CONFIRM, TEXTURE_SIDE);
                
            } else if (status == SLOODLE_CMD_SENDING) {
                llSetTexture(SLOODLE_TEX_SENDING, TEXTURE_SIDE);
                
            }
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: toolbar/lsl/sloodle_blog_ready_display.lsl 

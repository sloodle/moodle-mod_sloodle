//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle Blog HUD
// Allows SL users in-world to write to their Moodle blog
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-8 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Daniel Livingstone
//  Edmund Edgar
//  Peter R. Bloomfield
//

// Version history:
//
// 1.3 - updated to use new language system, new user-centric authorisation, and post visibility option (Sloodle 0.3)
// 1.2.2 - resolved another bug in multi-part blogging causing stack/heap collision with long subject
// 1.2.1 - resolved bug in multi-part blogging causing stack/heap collision is subject was too long
// 1.2 - multi-part blogging
// 1.1 - added channel menu and "ready" display
// 1.0 - updated to use new communications and avatar registration methods for Sloodle 0.2
// 0.9.2 - Corrected the reset calls from 0.9.1 to use "attach" event, and changed authentication link to a chat message
// 0.9.1 - Added appropriate reset calls for whenever the HUD object gets attached to the HUD
// 0.9 - Rewritten by Peter Bloomfield to allow full notecard initialisation
// 0.8 - Toolbar 2 in 1 - merge with gesture toolbar. Yikes.
// 0.7 - Textures from Jeremy Kemp, Authentication improvements
// 0.6 - Did some stuff... I forget
// 0.5 - Improved blogging. Also links to new simple authentication system.
// 0.4 - can't quite recall what I did
// 0.3 - adding in auto-update
//     - rewriting some code, to simplify things and allow for more control via buttons
// 0.2 - uses Edmund Earp's authentication data
//      - No longer asks user to set ID in notecard, but user
//        must be authenticated to use this successfully
// 0.1 - based on sloodle chat 0.72. DL
//


///// CONSTANTS /////
// Memory-saving hack!
key null_key = NULL_KEY;

// Timeout values
float CHAT_TIMEOUT = 600.0; // Time to wait for the user to chat something
float CONFIRM_TIMEOUT = 600.0; // Time to wait for the user to confirm the entry
float HTTP_TIMEOUT = 15.0; // Time to wait for an HTTP response

// What channel should configuration data be received on?
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
// What link channel should be used to communicate URLs?
integer SLOODLE_CHANNEL_OBJECT_LOAD_URL = -1639270041;
// What channel should we listen on for avatar dialogs?
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;

// End of file (config data) marker
string SLOODLE_EOF = "sloodleeof";

// Relative path of the blog linker script
string SLOODLE_BLOG_LINKER = "/mod/sloodle/toolbar/blog_linker.php";

// Maximum allowed length of blog body
integer MAX_BLOG_BODY_LENGTH = 1001;


// Commands to other parts of the object
string SLOODLE_CMD_BLOG = "blog";
string SLOODLE_CMD_CHANNEL = "channel";
string SLOODLE_CMD_VISIBILITY = "visibility";
string SLOODLE_CMD_BLOG_LENGTH = "bloglength";
// Command statuses
string SLOODLE_CMD_READY = "ready";
string SLOODLE_CMD_NOTREADY = "notready";
string SLOODLE_CMD_ERROR = "error";
string SLOODLE_CMD_SUBJECT = "subject";
string SLOODLE_CMD_BODY = "body";
string SLOODLE_CMD_CONFIRM = "confirm";
string SLOODLE_CMD_SENDING = "sending";

// Menu button labels
string MENU_BUTTON_PUBLIC = "1";
string MENU_BUTTON_SITE = "2";
string MENU_BUTTON_PRIVATE = "3";

///// --- /////


///// DATA /////

// What chat channel should we receive user info on?
integer user_chat_channel = 0;
// Handle for the current "listen" command for user dialog
integer user_listen_handle = 0;

// Configuration data
string sloodleserverroot = "";
string sloodlepwd = "";
integer isconfigured = FALSE;
integer eof = FALSE;

// The subject and body of the blog entry
string blogsubject = "";
string blogbody = "";
// Current length of the blog body
integer blogbodylength = 0;

// Keys of the pending HTTP requests for a blog entry, and for avatar registration
key httpblogrequest = null_key;
key httpregrequest = null_key;

// Is the edit in confirmation mode?
// (i.e. has the entry been made, but is the user editing it to correct something?)
integer confirmationmode = FALSE;

// These values indicate when we started listening for particular dialogs.
// If 0, then we are not listening.
integer dlglisten_channel = 0; // Channel change dialog
integer dlglisten_visibility = 0; // Post visibility dialog

// Current visibility setting
string visibility = "site";

///// --- /////



///// TRANSLATIONS /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

// Translation output methods
string SLOODLE_TRANSLATE_LINK = "link";                     // No output parameters - simply returns the translation on SLOODLE_TRANSLATION_RESPONSE link message channel
string SLOODLE_TRANSLATE_SAY = "say";                       // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_WHISPER = "whisper";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SHOUT = "shout";                   // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_REGION_SAY = "regionsay";          // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";            // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";                 // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";              // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_LOAD_URL_PARALLEL = "loadurlpar";  // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";          // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_IM = "instantmessage";             // Recipient avatar should be identified in link message keyval. No output parameters.

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

///// FUNCTIONS /////
// Send a debug message (requires the "sloodle_debug" script in the same link)
sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, null_key);
}

// Reset the entire script
sloodle_reset()
{
    sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "resetting", [], NULL_KEY, "");
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reset", NULL_KEY);
    llMessageLinked(LINK_ALL_CHILDREN,1," ",null_key);
    llMessageLinked(LINK_ALL_CHILDREN,2," ",null_key);
    llResetScript();
}

// Reset the display
resetDisplay()
{
    llMessageLinked(LINK_ALL_CHILDREN,1," ",null_key);
    llMessageLinked(LINK_ALL_CHILDREN,2," ",null_key);
}

// Reset the settings values
resetSettings()
{
    sloodleserverroot = "";
    sloodlepwd = "";
    eof = FALSE;
    isconfigured = FALSE;
}

// Reset the working values
resetWorkingValues()
{
    // Reset our variables
    blogsubject = "";
    blogbody = "";
    blogbodylength = 0;
    httpblogrequest = null_key;
    httpregrequest = null_key;
    confirmationmode = FALSE;
    // Cancel any timer request
    llSetTimerEvent(0.0);
    
    // Update display
    update_blog_length_display();
}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);
    string value1 = "";
    string value2 = "";
    
    if (numbits > 1) value1 = llList2String(bits,1);
    if (numbits > 2) value2 = llList2String(bits,2);
    
    if (name == "set:sloodleserverroot") sloodleserverroot = value1;
    else if (name == "set:sloodlepwd") {
        // The password may be a single prim password, or a UUID and a password
        if (value2 != "") sloodlepwd = value1 + "|" + value2;
        else sloodlepwd = value1;
        
    }
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "");
}

// Show the chat channel menu
// (Shows menu to owner, and starts listening for owner messages)
show_channel_menu()
{
    dlglisten_channel = llGetUnixTime();
    dlglisten_visibility = 0;
    llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", llGetOwner(), "");
    sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG, "0", "1", "2", "X"], "channelmenu", [(string)user_chat_channel], llGetOwner(), "toolbar");
}

// Show the post visibility menu
show_visibility_menu()
{
    dlglisten_channel = 0;
    dlglisten_visibility = llGetUnixTime();
    llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", llGetOwner(), "");
    sloodle_translation_request(SLOODLE_TRANSLATE_DIALOG, [SLOODLE_CHANNEL_AVATAR_DIALOG, MENU_BUTTON_PUBLIC, MENU_BUTTON_SITE, MENU_BUTTON_PRIVATE], "visibilitymenu", [MENU_BUTTON_PUBLIC, MENU_BUTTON_SITE, MENU_BUTTON_PRIVATE], llGetOwner(), "toolbar");
}

// Handle a channel change message
handle_channel_change(integer ch)
{
    // Make sure it's a valid number
    if (ch >= 0 || ch <= 2) {
        dlglisten_channel = 0;
        // Store the new channel number and change the "listen" command
        user_chat_channel = ch;
        llListenRemove(user_listen_handle);
        user_listen_handle = llListen(user_chat_channel, "", llGetOwner(), "");
        // Update the display
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG + "|" + SLOODLE_CMD_CHANNEL + "|" + (string)ch, null_key);
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "usingchannel", [(string)ch], null_key, "toolbar");
    }
}

// Handle a visibility change message
handle_visibility_change(string msg)
{
    dlglisten_visibility = 0;
    // Figure out which setting it was
    if (msg == MENU_BUTTON_PUBLIC) visibility = "public";
    else if (msg == MENU_BUTTON_SITE) visibility = "site";
    else if (msg == MENU_BUTTON_PRIVATE) visibility = "private";
    // Update the display
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG + "|" + SLOODLE_CMD_VISIBILITY + "|" + visibility, null_key);
    sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "visibility:" + visibility, [], null_key, "toolbar");
}

// Update the blog length display
update_blog_length_display()
{
    float len = (float)blogbodylength / (float)MAX_BLOG_BODY_LENGTH;
    if (len < 0.0) len = 0.0;
    if (len > 1.0) len = 1.0;
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG_LENGTH + "|" + (string)len, NULL_KEY);
}

///// --- /////


/// INITIALISING STATE ///
// Waiting for configuration
default
{    
    state_entry()
    {
        // Update the display to say "not ready"
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG + "|" + SLOODLE_CMD_NOTREADY, NULL_KEY);
        // Clear any item text
        llSetText("", <0.0,0.0,0.0>, 0.0);
        // Reset our channel and visibility display
        handle_channel_change(0);
        handle_visibility_change("site");
        
        // Make sure this is attached as a HUD object
        if (llGetAttached() < 30)
        {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "attachashud", [], NULL_KEY, "toolbar");
            state error;
        }

        // Reset all values
        resetDisplay();
        resetSettings();
        resetWorkingValues();
        
        // Request configuration data again
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
    }
    
    touch_start(integer num)
    {
        if (llDetectedKey(0) == llGetOwner()) {
            // Get the name of the prim that was touched
            string name = llGetLinkName(llDetectedLinkNumber(0));
            if (name == "reset") {
                sloodle_reset();
            } else {
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
            }
        }
    }
    
    state_exit()
    {
    }
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(msg, ["\n"], []);
            integer numlines = llGetListLength(lines);
            // TW inits for Opensim 6 Apr 09
            integer i;
            for ( i = 0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                    state ready;
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], NULL_KEY, "");
                    sloodle_debug("sloodleserverroot = " + sloodleserverroot + "\nsloodlepwd = " + sloodlepwd);
                    eof = FALSE;
                }
            }
        }
    }
}


/// ERROR STATE ///
// Initialisation and/or authentication has failed.
// Object can be clicked to retry setup.
state error
{    
    state_entry()
    {
        // Reset all values
        resetSettings();
        resetWorkingValues();
        // Inform the user that they can retry the setup process
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "errorstate", [], NULL_KEY, "toolbar");
        
        // Update the display to say "error"
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG + "|" + SLOODLE_CMD_ERROR, NULL_KEY);
    }
    
    state_exit()
    {
        // Clear the text caption
        llSetText("", <0.0,0.0,0.0>, 0.0);
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            sloodle_reset();
    }
    
    touch_start( integer num )
    {
        // Make sure it is the owner touching the HUD
        if (llDetectedKey(0) != llGetOwner()) return;
                
        // Get the name of the prim that was touched
        string name = llGetLinkName(llDetectedLinkNumber(0));
        if (name == "reset") {
            sloodle_reset();
        }
    }
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        // Ignore self
        if (sender_num == llGetLinkNumber()) return;
    
        // Check if it was a reset message
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG && msg == "do:reset") {
            sloodle_reset();
        }
    }
}


/// READY ///
// Ready to start blogging
state ready
{   
    state_entry()
    {
        // Reset all of the working values and display from the last blog entry
        resetDisplay();
        resetWorkingValues();
        
        // Update display to say "ready"
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG + "|" + SLOODLE_CMD_READY, NULL_KEY);
    }
    
    touch_start( integer num )
    {
        // Make sure it is the owner touching the HUD
        if (llDetectedKey(0) != llGetOwner()) return;
                
        // Get the name of the prim that was touched
        string name = llGetLinkName(llDetectedLinkNumber(0));
        if (name == "start_blog") {
            llOwnerSay("Blogging to: " + sloodleserverroot);
            state get_subject;
        } else if (name == "channel" || name == "channel_num") {
            show_channel_menu();
        } else if (name == "visibility") {
            show_visibility_menu();
        } else if (name == "reset") {
            sloodle_reset();
        }
    }
    
    listen( integer channel, string name, key id, string msg )
    {
        // Check which channel this is coming in on
        if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG) {
            // Make sure it's from the owner and that the message is not empty
            if (id != llGetOwner() || msg == "") return;
            // Ignore cancellation messages
            if (llToLower(msg) == "cancel" || llToLower(msg) == "x") return;
            
            // Determine the earliest time a menu could have active without expiring yet (give them 12 seconds)
            integer expirytime = llGetUnixTime() - 12;
            // Check which menu was most recently activated
            if (dlglisten_channel > dlglisten_visibility) {
                // Channel change
                if (dlglisten_channel >= expirytime) handle_channel_change((integer)msg);
            } else {
                // Visibility
                if (dlglisten_visibility >= expirytime) handle_visibility_change(msg);
            }
            return;
        }
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            state default;
    }
}


/// GET SUBJECT ///
// Listen for the subject of the blog
state get_subject
{   
    state_entry()
    {
        // Disable any existing timeout event
        llSetTimerEvent(0.0);
        
        // Listen for chat messages from the owner of this object
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "chatsubject", [], null_key, "toolbar");
        user_listen_handle = llListen(user_chat_channel, "", llGetOwner(), "");
        
        // Set a timeout
        llSetTimerEvent(CHAT_TIMEOUT);

        // Update display to say "subject"
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG + "|" + SLOODLE_CMD_SUBJECT, NULL_KEY);
    }
    
    state_exit()
    {
        // Cancel the timeout if necessary
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        // We have timed-out waiting for a response
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "timeout:subject", [], null_key, "toolbar");
        state ready;
    }
    
    touch_start( integer num )
    {
        // Make sure it was the owner who touched the object
        if (llDetectedKey(0) != llGetOwner()) return;
        // Get the name of the touched prim
        string name = llGetLinkName(llDetectedLinkNumber(0));
        
        // What was touched?
        if (name == "send") {
            // The "send" button was touched
            // We cannot send until we have a blog body
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "cannotsave:needsubjectbody", [], null_key, "toolbar");
            return;
            
        } else if (name == "cancel") {
            // The "cancel" button was touched
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "cancelled", [], null_key, "toolbar");
            state ready;
            
        } else if (name == "channel" || name == "channel_num") {
            show_channel_menu();
        } else if (name == "visibility") {
            show_visibility_menu();
        } else if (name == "reset") {
            sloodle_reset();
        }
    }
    
    listen( integer channel, string name, key id, string msg )
    {
        // Check which channel this is coming in on
        if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG) {
            // Make sure it's from the owner and that the message is not empty
            if (id != llGetOwner() || msg == "") return;
            // Ignore cancellation messages
            if (llToLower(msg) == "cancel" || llToLower(msg) == "x") return;
            
            // Determine the earliest time a menu could have active without expiring yet (give them 12 seconds)
            integer expirytime = llGetUnixTime() - 12;
            // Check which menu was most recently activated
            if (dlglisten_channel > dlglisten_visibility) {
                // Channel change
                if (dlglisten_channel >= expirytime) handle_channel_change((integer)msg);
            } else {
                // Visibility
                if (dlglisten_visibility >= expirytime) handle_visibility_change(msg);
            }
            return;
            
        } else if (channel == user_chat_channel) {
            // Make sure the message is not empty
            if (msg == "") {
                sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "needsubject", [], null_key, "toolbar");
                return;
            }
            
            // Store and display the blog subject
            if (llStringLength(msg) <= 128) blogsubject = msg;
            else blogsubject = llGetSubString(msg, 0, 127);
            llMessageLinked(LINK_ALL_CHILDREN, 1, blogsubject, NULL_KEY);

            state get_body;
            return;
        }
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            state default;
    }
}


/// GET BODY ///
// Listen for the body of the blog
state get_body
{   
    state_entry()
    {
        // Disable any existing timeout event
        llSetTimerEvent(0.0);
        
        // Set the initial blog body length to the length of the subject line
        blogbodylength = llStringLength(blogsubject);
        
        // Listen for chat messages from the owner of this object
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "chatbody", [(string)(MAX_BLOG_BODY_LENGTH - blogbodylength - 1)], null_key, "toolbar");
        
        user_listen_handle = llListen(user_chat_channel, "", llGetOwner(), "");
        
        // Set a timeout
        llSetTimerEvent(CHAT_TIMEOUT);

        // Update display to say "body"
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG + "|" + SLOODLE_CMD_BODY, NULL_KEY);
    }
    
    state_exit()
    {
        // Cancel the timeout if necessary
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        // We have timed-out waiting for a response
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "timeoutbody", [], null_key, "toolbar");
        state ready;
    }
    
    touch_start( integer num )
    {
        // Make sure it was the owner who touched the object
        if (llDetectedKey(0) != llGetOwner()) return;
        // Get the name of the touched prim
        string name = llGetLinkName(llDetectedLinkNumber(0));
        
        // What button was touched?
        if (name == "send") {
            // The "send" button was touched
            // Make sure a body has been typed
            if (blogbody == "") {
                sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "needbody", [], null_key, "toolbar");
                return;
            }
            // Send it
            state send;
        } else if (name == "cancel") {
            // The "cancel" button was touched
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "cancelled", [], null_key, "toolbar");
            state ready;
        } else if (name == "channel" || name == "channel_num") {
            show_channel_menu();
        } else if (name == "visibility") {
            show_visibility_menu();
        } else if (name == "reset") {
            sloodle_reset();
        }
    }
    
    listen( integer channel, string name, key id, string msg )
    {
        // Check which channel this is coming in on
        if (channel == SLOODLE_CHANNEL_AVATAR_DIALOG) {
            // Make sure it's from the owner and that the message is not empty
            if (id != llGetOwner() || msg == "") return;
            // Ignore cancellation messages
            if (llToLower(msg) == "cancel" || llToLower(msg) == "x") return;
            
            // Determine the earliest time a menu could have active without expiring yet (give them 12 seconds)
            integer expirytime = llGetUnixTime() - 12;
            // Check which menu was most recently activated
            if (dlglisten_channel > dlglisten_visibility) {
                // Channel change
                if (dlglisten_channel >= expirytime) handle_channel_change((integer)msg);
            } else {
                // Visibility
                if (dlglisten_visibility >= expirytime) handle_visibility_change(msg);
            }
            return;
            
        } else if (channel == user_chat_channel) {
            // If the body is already at maximum length, then ignore this
            if (blogbodylength >= MAX_BLOG_BODY_LENGTH) {
                sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "atmaximum", [llKey2Name(llGetOwner())], null_key, "toolbar");
                return;
            }
            // Make sure the message is not empty
            if (msg == "") return;
            
            // Add a space at the end of the message
            msg += " ";
            // Check that we can fit this message in
            integer msglen = llStringLength(msg);
            if ((blogbodylength + msglen) > MAX_BLOG_BODY_LENGTH) {
                sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "toolong", [llKey2Name(llGetOwner()), (string)(MAX_BLOG_BODY_LENGTH - blogbodylength - 1)], null_key, "toolbar");
                return;
            }
            
            // Store and display it
            blogbodylength += msglen;
            blogbody += msg;
            llMessageLinked(LINK_ALL_CHILDREN, 2, blogbody, NULL_KEY);
            update_blog_length_display();
            
            // Report the number of characters remaining
            integer charsleft = MAX_BLOG_BODY_LENGTH - blogbodylength - 1;
            if (charsleft > 0) sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "charsleft", [(string)charsleft], null_key, "toolbar");
            else sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "full", [], null_key, "toolbar");
        }
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            state default;
    }
}


/// SEND ///
// Send the blog entry to the server
state send
{   
    state_entry()
    {
        // Disable any existing timeout event
        llSetTimerEvent(0.0);
        
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "sending", [llKey2Name(llGetOwner())], null_key, "toolbar");
        
        // Update display to say "sending"
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, SLOODLE_CMD_BLOG + "|" + SLOODLE_CMD_SENDING, NULL_KEY);
        // Construct the body of the request
        string body = "sloodlepwd=" + sloodlepwd;
        body += "&sloodleuuid=" + (string)llGetOwner();
        body += "&sloodleblogsubject=" + llEscapeURL(blogsubject);
        body += "&sloodleblogbody=" + blogbody;
        body += "&sloodleblogvisibility=" + visibility;

        sloodle_debug("Sending request to update blog.");
        httpblogrequest = llHTTPRequest(sloodleserverroot + SLOODLE_BLOG_LINKER, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"], body);
        
        // Set a timeout event
        llSetTimerEvent(HTTP_TIMEOUT);
    }
    
    state_exit()
    {
        // Cancel the timeout if necessary
        llSetTimerEvent(0.0);
    }
    
    timer()
    {
        // We have timed-out waiting for an HTTP response
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httptimeout", [], NULL_KEY, "");
        state get_body;
    }
    
    http_response(key request_id, integer status, list metadata, string body)
    {
        // Make sure this is the expected HTTP response
        if (request_id != httpblogrequest) return;
        httpblogrequest = null_key;
        
        sloodle_debug("HTTP Response ("+(string)status+"): "+body);
        
        // Was the HTTP request successful?
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httperror", [status], null_key, "toolbar");
            state ready;
            return;
        }
        
        // Split the response into lines and extract the status fields
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
        integer statuscode = llList2Integer(statusfields, 0);
        // We expect at most 1 data line
        string dataline = "";
        if (numlines > 1) dataline = llList2String(lines, 1);
        
        // Check the status code
        if (statuscode <= -300 && statuscode > -400) {
            // It is a user authentication error - attempt re-authentication
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "autherror", [(string)statuscode], null_key, "toolbar");
            sloodle_debug(body);
            state default;
            return;
            
        } else if (statuscode <= 0) {
            // Don't know what kind of error it was
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "servererror", [(string)statuscode], null_key, "");
            sloodle_debug(body);
            state ready;
            return;
        }
        
        // If we get here, then it must have been successful
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "sent", [], null_key, "toolbar");
        state ready;
    }
    
    attach( key av )
    {
        if (av != NULL_KEY)
            state default;
    }
    
    touch_start( integer num )
    {
        // Make sure it is the owner touching the HUD
        if (llDetectedKey(0) != llGetOwner()) return;
                
        // Get the name of the prim that was touched
        string name = llGetLinkName(llDetectedLinkNumber(0));
        if (name == "reset") {
            sloodle_reset();
        }
    }
}// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: toolbar/lsl/sloodle_blog_hud.lsl 

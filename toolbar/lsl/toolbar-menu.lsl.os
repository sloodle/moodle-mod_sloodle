//////////
//
// Sloodle Toolbar menu script (v2.0)
// Controls the Toolbar as a whole, and runs the Classroom Gestures
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-8 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  - <unknown>
//  - Peter R. Bloomfield
//  - Fumi.Iseki for OpenSim
//
//////////
//
// Versions:
//  2.1 - added auto-hide feature (although it might not be very good yet... I think we need a better method!)
//  2.0 - centralised animation control in this script (rather than separate scripts)
//  - <history unknown>
//
//////////
//
// Usage:
//  This script should be in the *root* prim of an object, and expects that a series of linked
//   child prims are given names such as "gesture:wave". These objects should *not* process their
//   own "touch_start" events, but should pass them back to the parent (this is the default behaviour).
//  When "touch_start" is called, this object will get the name of the prim that was touched, and
//   look it up in a list of animation data. It will start/stop the associated animation as appropriate.
//
//  If the root prim is touched, then it flips between the two modes of operation.
//  If the "minimize_button" is touched, then it auto-hides or unhides itself.
//  
//
//////////

// Name of the button objects
string MINIMIZE_BUTTON = "minimize_button";
string RESTORE_BUTTON = "restore_button";
string HELP_BUTTON = "help_button";

// Name of the help notecard
string HELP_NOTECARD = "Sloodle Lite Toolbar Help";
// Is the toolbar currently hidden ('minimized')?
integer hidden = 0;
// Sound to be played when the toolbar is touched
string touchSound = "";

// This list stores information in sets of 3:
//  {string:name of gesture button} {string:name of animation} {integer:playing?}
// The name of the gesture button is also used as the name of a language string in the "toolbar" batch.
// That language string will be echoed to chat.
// The "playing?" item can have one of 3 values. If the animation only plays once at a time, it should be -1.
//  If the animation loops, but it is *not* currently playing, it should be 0. If it loops and is currently playing, it should be 1.
list animdata = [   "gesture:handup", "LongRaise", 0,
                    "gesture:wave", "Wave", 0,
                    "gesture:clap", "clap", -1,
                    "gesture:nodoff", "Nodoff", -1,
                    "gesture:huh", "IDontUnderstand", -1,
                    "gesture:gotit", "gotit", -1,
                    "gesture:yes", "Yes", -1,
                    "gesture:no", "No", -1
                ];


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

// Used for sending parallel URL loading messages
integer SLOODLE_CHANNEL_OBJECT_LOAD_URL = -1639270041;

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}
                
///// STATES /////

default
{
    state_entry()
    {
        // We need to get animation permissions
        llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
        // Preload the touching sound
        if(touchSound != ""){
            llPreloadSound(touchSound); 
        }
        hidden = 0;
        llSetLocalRot(ZERO_ROTATION);
    }
    
    on_rez(integer param)
    {
        llResetScript();
    }
    
    run_time_permissions(integer id)
    {
    }

    touch_start(integer total_number)
    {
        // Which link was touched?
        integer linknumber = llDetectedLinkNumber(0);
        string name = llGetLinkName(linknumber);

        // Is the toolbar currently hidden?
        if (hidden == 1) {
            // If the restore button was pressed, then unhide it. Otherwise, ignore the touch.
            if (name == RESTORE_BUTTON) {
                hidden = 0;
                llSetLocalRot(ZERO_ROTATION);
            }
            return;
        }
        // Was the minimize button pressed?
        if (name == MINIMIZE_BUTTON) {
            // Hide it
            hidden = 1;
            llSetLocalRot(llEuler2Rot(<0,PI * 0.5,0>));
            return;
        }

        // Ignore any other touches if we are hidden
        if (hidden == 1) return;
        
        // So what else was touched?
        if (name == HELP_BUTTON) {
            // The help button was touched - give the help notecard
            if (llGetInventoryType(HELP_NOTECARD) == INVENTORY_NOTECARD) {
                llGiveInventory(llDetectedKey(0), HELP_NOTECARD);
            } else {
                // Nothing to give
                sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "helpnotecardnotfound", [HELP_NOTECARD], NULL_KEY, "toolbar");
            }
            return;
        }
        
        // Was this a gesture command?
        integer pos = llListFindList(animdata, [name]);
        if (pos >= 0) {
            // Make sure there is enough data (there should be 2 more elements beyond the button name)
            if ((pos + 2) >= llGetListLength(animdata)) return;
            // Extract the animation data
            string animname = llList2String(animdata, pos + 1);
            integer playing = llList2Integer(animdata, pos + 2);
            string avname = llKey2Name(llGetOwner());
            
            // What do we do?
            if (playing < 0) {
                // Play the animation once and echo the gesture to chat
                llStartAnimation(animname);
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], name, [avname], NULL_KEY, "toolbar");
                
            } else if (playing == 0) {
                // Start playing the animation and echo the gesture to chat
                llStartAnimation(animname);
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], name, [avname], NULL_KEY, "toolbar");
                // Set the "playing" flag to 1
                animdata = llListReplaceList(animdata, [1], (pos + 2), (pos + 2));
                // Highlight the button
                llSetLinkColor(linknumber, <1.0,1.0,0.0>, ALL_SIDES);
                
            } else if (playing > 0) {
                // Stop playing the animation
                llStopAnimation(animname);
                // Set the "playing" flag back to 0
                animdata = llListReplaceList(animdata, [0], (pos + 2), (pos + 2));
                // Deactivate the button highlight
                llSetLinkColor(linknumber, <1.0,1.0,1.0>, ALL_SIDES);
            }
        }
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: toolbar/lsl/toolbar-menu.lsl.os

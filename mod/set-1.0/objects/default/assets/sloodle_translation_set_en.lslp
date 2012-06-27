//
// The line above should be left blank to avoid script errors in OpenSim.

// Standard translation script for Sloodle.
// Contains the common, re-usable words and phrases.
//
// The "locstrings" list is pairs of strings.
// The first of each pair is the name, and second is the translation.
//
// This script is part of the Sloodle project.
// Copyright (c) 2008 Sloodle (various contributors)
// Released under the GNU GPL v3
//
// Contributors:
//  Peter R. Bloomfield
//

// Note: where a translation string contains {{x}} (where x is a number),
//  it means that a parameter can be inserted. Please make sure to include these
//  parameters in the appropriate location in your translation.
// It may be sensible to add comments after your string to indicate what its parameters mean.
// NOTE: parameter numbering starts at 0 (unlike previous versions, which started at 1).

// Translations can be requested by sending a link message on the SLOODLE_CHANNEL_TRANSLATION_REQUEST channel.
// It is advisable simply to use the "sloodle_translation_request" function provided in this script.


///// TRANSLATION /////

// Localization batch - indicates the purpose of this file
string mybatch = "set"; // Sloodle Set


// List of string names and translation pairs.
// The name is the first of each pair, and should not be translated.
// The second of each pair is the translation.
// Additional comments are sometimes given afterward to aid translations.
list locstrings = [
    //  Sloodle Set
    "sloodleset:cmddialog_simple", "Sloodle Set Menu\n\n{{0}} = Reset\n{{1}} = Rez an object", // Parameter: button label    
    "sloodleset:cmddialog_mothership", "Sloodle Set Menu\n\n{{0}} = Reset\n{{1}} = Rez an object\n{{2}} = Manage layouts of multiple objects\n{{3}} = Destroy all objects", // Parameter: button label
    "sloodleset:objectmenu", "Sloodle Set.\nSelect object to rez:\n\n{{0}}", // The parameter should be a set of button labels and object names, e.g. "1 = WebIntercom, 2 = MetaGloss"
    "rezzingobject", "Rezzing Object:\n\"{{0}}\"", // Parameter should give the name of the object being rezzed
    "reztimeout", "Timeout while attempting to rez \"{{0}}\",", // Parameter should give the name of the object
    "sloodleset:noobjects", "Sorry {{0}}. This Sloodle Set does not contain any objects to be rezzed.", // Parameter: avatar name
    "notininventory", "Unable to rez \"{{0}}\". Item is not in inventory.", // Parameter: name of an object
    "notobject", "Unable to rez \"{{0}}\". Item is not an object.", // Parameter: name of an object

    //  Layouts
    "layout:failedretrying", "Failed to store layout position. Retrying...",
    "layout:failedaborting", "Failed to store layout position. Aborting.",
    "layout:toofar", "Failed to store layout position - too far from rezzer.",
    "layout:storedobject", "Object stored in layout.",
    "layout:noneavailable", "Sorry {{0}}. There are no layouts available.", // Parameter: name of avatar
    "layout:loadmenu", "Sloodle Set.\nSelect layout to load:\n\n{{0}}", // The parameter should be a set of button labels and layout names, e.g. "1 = blah, 2 = foobar"
    "layout:savemenu", "Sloodle Set.\nSelect layout to save:\n\n{{0}}", // The parameter should be a set of button labels and layout names, e.g. "1 = blah, 2 = foobar"
    "layout:cmdmenu", "Sloodle Set.\nWhat layout action would you like to perform?\n\n{{0}} = Load layout\n{{1}} = Save layout\n{{2}} = Save layout as...\n{{3}} = Cancel", // Parameters: button labels
    "layout:nolayouttosave", "Sorry {{0}}. There is no current layout to save to. Please Save As a new layout or Load an existing layout first.", // Parameter: avatar name
    "layout:chatlayoutname", "Please chat the name of the new layout on channel 0 or 1. Touch the layout manager to cancel the operation.",
    "layout:layoutnametimeout", "Timeout waiting for layout name. Cancelling operation.",
    "layout:cancelsave", "Cancelling save operation.",
    "layout:saving", "Saving layout \"{{0}}\".", // Parameter: name of a layout
    "layout:loading", "Loading layout \"{{0}}\".", // Parameter: name of a layout
    "layout:nopermission", "Sorry {{0}}, you do not have permission to use layouts on this course.", // Parameter: avatar name
    "layout:savefailed", "Failed to save layout.",
    "layout:notexist", "That layout does not exist.",
    "layout:alreadyexists", "That layout already exists.",
    
    "layoutcaption:saving", "Saving...",
    "layoutcaption:savingas", "Saving As...",
    "layoutcaption:loading", "Loading...",
    "layoutcaption:layout", "Current Layout:\n{{0}}" // Parameter: name of layout
    
];

///// ----------- /////


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

///// FUNCTIONS /////


// Send a translation request link message
// (Here for reference only)
// Parameter: output_method = should identify an output method, as given by the "SLOODLE_TRANSLATE_..." constants above
// Parameter: output_params = a list of parameters which controls the output, such as chat channel or buttons for a dialog
// Parameter: string_name = the name of the localization string to output
// Parameter: string_params = a list of parameters which will be included in the translated string (or an empty list if none)
// Parameter: keyval = a key to send in the link message
// Parameter: batch = the name of the localization batch which should handle this request
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

// Send a translation response link message
sloodle_translation_response(integer target, string name, string translation)
{
    llMessageLinked(target, SLOODLE_CHANNEL_TRANSLATION_RESPONSE, name + "|" + translation + "|" + mybatch, NULL_KEY);
}

// Get the translation of a particular string
string sloodle_get_string(string name)
{
    // Attempt to find the string name
    integer numstrings = llGetListLength(locstrings);
    integer pos = llListFindList(locstrings, [name]);
    
    // IMPORTANT: we must be careful not to match a translations instead of a name.
    // If this was an even number, then we have a string name.
    if ((pos % 2) == 0) {
        // Make sure there is a subsequent translation in the list
        if ((pos + 1) < numstrings) return llList2String(locstrings, pos + 1);
        // The translation is not there
        pos = -1;
    }
    
    // If we could not find the string, then return a placeholder
    if (pos < 0) return "[[" + name + "]]";
    
    // If we got here, then we matched a translation instead of a string name.
    // As such, we need to resort to searching through the list manually (which can be very slow).
    // To saved time, we can start from the position just beyond where we got to.
    // We advance by 2 each time to skip the translations completely.
    pos += 1;
    for (pos=pos; pos < numstrings; pos += 2) {
        // Do we have a match?
        if (llList2String(locstrings, pos) == name) {
            // Yes - make sure there is a translation following it
            if ((pos + 1) < numstrings) return llList2String(locstrings, pos + 1);
            // The translation is not there - skip the rest of the search
            pos = numstrings;
        }
    }
    
    // If we reached this point, then the string is not available. Return a placeholder.
    return "[[" + name + "]]";
}

// Send a debug link message
sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}


// Get a formatted translation of a string
string sloodle_get_string_f(string name, list params)
{
    // Get the string itself
    string str = sloodle_get_string(name);
    // How many parameters do we have?
    integer numparams = llGetListLength(params);
    
    // Go through each parameter we have been provided
    integer curparamnum;
    string curparamtok = "{{x}}";
    integer curparamtoklength = 0;
    string curparamstr = "";
    integer tokpos = -1;
    for (curparamnum=0; curparamnum < numparams; curparamnum++) {
        // Construct this parameter token
        curparamtok = "{{" + (string)(curparamnum) + "}}";
        curparamtoklength = llStringLength(curparamtok);
        // Fetch the parameter text
        curparamstr = llList2String(params, curparamnum);
        
        // Ensure the parameter text does NOT contain double braces (this avoids an infinite loop!)
        if (llSubStringIndex(curparamstr, "{{") < 0 && llSubStringIndex(curparamstr, "}}") < 0) {            
            // Go through every instance of this parameter's token
            while ((tokpos = llSubStringIndex(str, curparamtok)) >= 0) {
                // Replace the token with the parameter string
                str = llDeleteSubString(str, tokpos, tokpos + curparamtoklength - 1);
                str = llInsertString(str, tokpos, curparamstr);
            }
        }
    }
    
    return str;
}


///// STATES /////

default
{
    state_entry()
    {
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_TRANSLATION_REQUEST) {            
            
            // // PROCESS REQUEST // //
        
            // Split the incoming message into fields
            list fields = llParseStringKeepNulls(str, ["|"], []);
            integer numfields = llGetListLength(fields);
            
            // Extract and check the localization batch
            string batch = "";
            if (numfields > 4) batch = llList2String(fields, 4);
            if (batch != mybatch) return;
            
            // We expect at least 3 fields
            // ... or 4 if there are insertion parameters...
            // ... or 5 if there is a language code
            // ... anybody up for a 6th parameter? :)
            if (numfields < 3) {
                sloodle_debug("ERROR: Insufficient fields for translation of string.");
                return;
            }
            
            // Extract the key parts of the request
            string output_method = llList2String(fields, 0);
            list output_params = llCSV2List(llList2String(fields, 1));
            integer num_output_params = llGetListLength(output_params);
            string string_name = llList2String(fields, 2);
            list string_params = [];
            if (numfields > 3) {
                // Extract the string parameters (extra text added to the output)
                string string_param_text = llList2String(fields, 3);
                if (string_param_text != "") string_params = llCSV2List(string_param_text);
            }
            
            // // TRANSLATE STRING // //
            
            // This string will store the translation
            string trans = "";
            // Do nothing if the string name is empty
            if (string_name != "") {
                // If there are no string parameters, then it is only a basic translation
                if (llGetListLength(string_params) == 0) {
                    // Get the basic translation
                    trans = sloodle_get_string(string_name);
                } else {
                    // Construct the formatted string
                    trans = sloodle_get_string_f(string_name, string_params);
                }
            }
            
            // // OUTPUT STRING // //
            
            // Check what output method has been requested
            if (output_method == SLOODLE_TRANSLATE_LINK) {
                // Return the string via link message
                sloodle_translation_response(sender_num, string_name, trans);
                
            } else if (output_method == SLOODLE_TRANSLATE_SAY) {
                // Say the string
                if (num_output_params > 0) llSay(llList2Integer(output_params, 0), trans);
                else sloodle_debug("ERROR: Insufficient output parameters to say string \"" + string_name + "\".");
                
            } else if (output_method == SLOODLE_TRANSLATE_WHISPER) {
                // Whisper the string
                if (num_output_params > 0) llWhisper(llList2Integer(output_params, 0), trans);
                else sloodle_debug("ERROR: Insufficient output parameters to whisper string \"" + string_name + "\".");
                
            } else if (output_method == SLOODLE_TRANSLATE_SHOUT) {
                // Shout the string
                if (num_output_params > 0) llShout(llList2Integer(output_params, 0), trans);
                else sloodle_debug("ERROR: Insufficient output parameters to shout string \"" + string_name + "\".");
                
            } else if (output_method == SLOODLE_TRANSLATE_REGION_SAY) {
                // RegionSay the string
                if (num_output_params > 0) llRegionSay(llList2Integer(output_params, 0), trans);
                else sloodle_debug("ERROR: Insufficient output parameters to region-say string \"" + string_name + "\".");
                
            } else if (output_method == SLOODLE_TRANSLATE_OWNER_SAY) {
                // Ownersay the string
                llOwnerSay(trans);
                
            } else if (output_method == SLOODLE_TRANSLATE_DIALOG) {
                // Display a dialog - we need a valid key
                if (id == NULL_KEY) {
                    sloodle_debug("ERROR: Non-null key value required to show dialog with string \"" + string_name + "\".");
                    return;
                }
                // We need at least 2 additional output parameters (channel, and at least 1 button)
                if (num_output_params >= 2) {
                    // Extract the channel number
                    integer channel = llList2Integer(output_params, 0);
                    // Extract up to 12 button values
                    list buttons = llList2List(output_params, 1, 12);
                    
                    // Display the dialog
                    llDialog(id, trans, buttons, channel);
                    
                } else sloodle_debug("ERROR: Insufficient output parameters to show dialog with string \"" + string_name + "\".");
                
            } else if (output_method == SLOODLE_TRANSLATE_LOAD_URL) {
                // Display a URL - we need a valid key
                if (id == NULL_KEY) {
                    sloodle_debug("ERROR: Non-null key value required to load URL with string \"" + string_name + "\".");
                    return;
                }                
                // We need 1 additional parameter, containing the URL to load
                if (num_output_params >= 1) llLoadURL(id, trans, llList2String(output_params, 0));
                else sloodle_debug("ERROR: Insufficient output parameters to load URL with string \"" + string_name + "\".");
            
            } else if (output_method == SLOODLE_TRANSLATE_LOAD_URL_PARALLEL) {
                // Display a URL - we need a valid key
                if (id == NULL_KEY) {
                    sloodle_debug("ERROR: Non-null key value required to load URL with string \"" + string_name + "\".");
                    return;
                }
                
                // NOTE: currently the parallel URL loaders will drop any text.
                // TODO: make parallel URL loaders use text as well.
                
                // We need 1 additional parameter, containing the URL to load
                if (num_output_params >= 1) llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_LOAD_URL, llList2String(output_params, 0), id);
                else sloodle_debug("ERROR: Insufficient output parameters to load URL with string \"" + string_name + "\".");
            
            } else if (output_method == SLOODLE_TRANSLATE_HOVER_TEXT) {
                // We need 1 additional parameter, containing the URL to load
                if (num_output_params >= 2) llSetText(trans, (vector)llList2String(output_params, 0), (float)llList2String(output_params, 1));
                else sloodle_debug("ERROR: Insufficient output parameters to show hover text with string \"" + string_name + "\".");
            
            } else if (output_method == SLOODLE_TRANSLATE_IM) {
                // Send an IM - we need a valid key
                if (id == NULL_KEY) {
                    sloodle_debug("ERROR: Non-null key value required to send IM with string \"" + string_name + "\".");
                    return;
                }                
                // Send the IM
                llInstantMessage(id, trans);

            } else {
                // Don't know the output method
                sloodle_debug("ERROR: unrecognised output method \"" + output_method + "\".");
            }
        }
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_translation_set_en.lslp 

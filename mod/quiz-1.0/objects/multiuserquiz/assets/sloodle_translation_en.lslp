// Standard translation script for Sloodle.
// Contains the common, re-usable words and phrases.
//
// The "locstrings" list is pairs of strings.
// The first of each pair is the name, and second is the translation.
//
// This script is part of the Sloodle project.
// Copyright (c) 2008-9 Sloodle (various contributors)
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
string mybatch = ""; // Blank - this is the common Sloodle batch


// List of string names and translation pairs.
// The name is the first of each pair, and should not be translated.
// The second of each pair is the translation.
// Additional comments are sometimes given afterward to aid translations.
list locstrings = [
    //  Common terms
    "yes", "Yes",
    "no", "No",
    "on", "On",
    "off", "Off",
    "enabled", "Enabled",
    "disabled", "Disabled",

    //  Web-configuration
    "webconfigmenu", "Sloodle Web-Configuration Menu\n\n{{0}} = Access web-configuration page\n{{1}} = Download configuration", // Parameters are button labels
    "configlink", "Use this link to configure the object.",
    "chatserveraddress", "Please chat the address of your Moodle site, without a trailing slash. For example: http://www.yoursite.blah/moodle",
    "waitingforserveraddress", "Waiting for Moodle site address.\nPlease chat it on channel 0 or 1.",
    "checkingserverat", "Checking Moodle site at:\n{{0}}", // Parameter gives the address of a Moodle site
    "sendingconfig", "Sending configuration data...",
    "touchforwebconfig", "Touch me to start web-configuration",
    
    // User-centric authorisation
    "userauthurl", "Please login to Moodle with this URL to authorize the object for your own use.",

    //  General connection and authorisation
    "readynotconnected", "Ready\n[Not connected]",
    "shutdown", "Shutdown",
    "connected", "Connected successfully",
    "readyconnectedto", "Ready\n[Connected to: {{0}}]", // Parameter should identify what is connected to (e.g. URL of website)
    "readyconnectedto:sitecourse", "Ready\n[Site: {{0}}]\n[Course: {{1}}]", // Parameters: site address, course name
    "connectionfailed", "Connection failed",
    "httperror", "ERROR: HTTP request failed",
    "httperror:code", "ERROR: HTTP request failed with code {{0}}",
    "httpempty", "ERROR: HTTP response empty",
    "httptimeout", "ERROR: HTTP request timed out.",
    "servererror", "ERROR: server responded with status code {{0}}",
    "notypeid", "ERROR: failed to identify object type ID",
    "gottype", "Identified object type as {{0}}", // Parameter gives an object type ID
    "failedcheckcompatibility", "ERROR: failed to check compatibility with site",
    "badresponseformat", "ERROR: response from server was badly formatted",
    "objectauthfailed:code", "ERROR: object authorisation failed with code {{0}}",
    "objectconfigfailed:code", "ERROR: object configuration failed with code {{0}}",
    "initobjectauth", "Initiating object authorisation...",
    "autoreg:newaccount", "A new Moodle account has been automatically generated for you.\nWebsite: {{0}} \nUsername: {{1}}\nPassword: {{2}}", // Parameters: site address, username, password
    "configurationreceived", "Configuration received",
    "configdatamissing", "ERROR: some required data was missing from the configuration",
    "readingconfignotecard", "Reading configuration notecard...",
    "checkingcourse", "Checking course...",
    "errortouchtoreset", "ERROR\nTouch me to reset",
    "notconfiguredyet", "Sorry {{0}}. I am not configured yet.", // Parameter: avatar name
    "resetting", "Resetting...",
    "noconfigavailable", "There is no configuration available to download. Please visit the configuration web-page first.",
    "checkingauth", "Checking authorisation...",

    //  Sloodle installation/version
    "sloodlenotinstalled", "ERROR: Sloodle is not installed on specified site.",
    "sloodleversioninstalled", "Sloodle version installed on server: {{0}}", // Parameter gives a Sloodle version number
    "sloodleversionrequired", "ERROR: you require at least Sloodle version {{0}}", // Parameter gives a Sloodle version number

    //  Permissions
    "nopermission:use", "Sorry {{0}}. You do not have permission to use this object.", // Parameter should be the name of an avatar
    "nopermission:ctrl", "Sorry {{0}}. You do not have permission to control this object.", // Parameter should be the name of an avatar
    "nopermission:authobjects", "Sorry {{0}}. You do not have permission to authorise objects on this course.", // Parameter should be the name of an avatar
    
    // Layout (duplicated deliberately)
    "layout:failedretrying", "Failed to store layout position. Retrying...",
    "layout:failedaborting", "Failed to store layout position. Aborting.",
    "layout:toofar", "Failed to store layout position - too far from rezzer.",
    "layout:storedobject", "Object stored in layout.",
    
    // General error
    "sloodleerror", "SLOODLE error ({{0}}): please lookup SLOODLE wiki for error information", // Parameters: status code of error
    "sloodleerror:desc", "SLOODLE error ({{0}}): {{1}}" // Parameters: status code of error, text description of error
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
    //pos += 1;
    for (pos += 1; pos < numstrings; pos += 2) {
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

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: lang/en_utf8/sloodle_translation_en.lsl 

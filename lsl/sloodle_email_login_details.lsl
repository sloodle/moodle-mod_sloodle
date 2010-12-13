// How many seconds between each email check
float EMAIL_CHECK_PERIOD = 30.0;

// Subject of emails to check for
string EMAIL_SUBJECT_LOGIN = "SLOODLE_LOGIN";


///// TRANSLATION /////

integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

///// ----------- /////



default
{
    state_entry()
    {
        // Start the timer for email checking
        llSetTimerEvent(EMAIL_CHECK_PERIOD);
    }
    
    timer()
    {
        // Check for new emails
        llGetNextEmail("", EMAIL_SUBJECT_LOGIN);
    }
        
    email(string time, string address, string subject, string msg, integer num_left)
    {
        //llOwnerSay("Received email from \"" + address + "\".\nSubject: \"" + subject + "\"\nMessage: \"" + msg + "\"");
        
        // Reset the timer (in case this was triggered by this event, not by the timer)
        llSetTimerEvent(EMAIL_CHECK_PERIOD);
        
        // Check the subject line of the email
        if (subject == EMAIL_SUBJECT_LOGIN) {
            
            // Split off the headers
            list parts = llParseStringKeepNulls(msg, ["\n\n"], []);
            string body = "";
            if (llGetListLength(parts) >= 2) {
                body = llList2String(parts, 1);
            } else {
                body = msg;
            }
            
            // Parse the data fields
            list fields = llParseStringKeepNulls(body, ["|"], []);
            // Make sure we have enough
            if (llGetListLength(fields) >= 3) {
                // Extract the individual fields
                key useruuid = (key)llList2String(fields, 0);
                string website = llList2String(fields, 1);
                string username = llList2String(fields, 2);
                string password = llList2String(fields, 3);
                
                // Send the information to the user
                if (useruuid != NULL_KEY) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_IM, [], "autoreg:newaccount", [website, username, password], useruuid, "");
                }
            }
            
        }
        
        // Are there more emails to check for?
        if (num_left > 0) {
            // Yes - get the next one
            llGetNextEmail("", EMAIL_SUBJECT_LOGIN);
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: lsl/sloodle_email_login_details.lsl 

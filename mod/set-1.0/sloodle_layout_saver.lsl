///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

// Translation output methods
string SLOODLE_TRANSLATE_LINK = "link";             // No output parameters - simply returns the translation on SLOODLE_TRANSLATION_RESPONSE link message channel
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_WHISPER = "whisper";       // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SHOUT = "shout";           // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_REGION_SAY = "regionsay";  // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";  // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters. 

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

///// ----------- /////
 
 
///// FUNCTIONS /////



// Send debug info
sloodle_debug(string msg)
{
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}

integer SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVE = -1639270101;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE = -1639270102;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_FINISHED = -1639270083 ;

integer sensee = -1;

key httplayoutupdate;

list rezzed_objects = [];
string entry_body = "";
string body = "";
string url = "";

sense_next_object()
{
    sensee++;
    // llOwnerSay("considering  object" + (string)sensee);
    if ( sensee >= llGetListLength(rezzed_objects) ) {
        // Finished
        sensee = -1;
       // llOwnerSay("no more objects, doing http request "+body + entry_body +" to :" +url +":");
        httplayoutupdate = llHTTPRequest(url, [HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"], body + entry_body);
    } else {
       // llOwnerSay("trying sensor");
        llSensor("", llList2Key(rezzed_objects, sensee), SCRIPTED, 96, PI);
    }
} 

default { 

    http_response(key id, integer status, list meta, string body)
    {
        // Make sure this is the expected HTTP response
        if (id != httplayoutupdate) return; 
        httplayoutupdate = NULL_KEY;
  
        // Was the HTTP request successful?
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "httperror", [status], NULL_KEY, "toolbar");
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE, body, NULL_KEY);
            return;
        }
      
        sloodle_debug("HTTP Response ("+(string)status+"): "+body);
        
        // Split the response into lines and extract the status fields
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
        integer statuscode = llList2Integer(statusfields, 0);
        // We might get an error message on a data line
        string dataline = "";
        if (numlines > 1) dataline = llList2String(lines, 1);
         
        // Check the status code
        if (statuscode == -301) {
            // User does not have permission
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:nopermission", [llKey2Name(llGetOwner())], NULL_KEY, "set");
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE, body, NULL_KEY);
            return;
                        
        } else if (statuscode == -901) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:savefailed", [], NULL_KEY, "set");
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE, body, NULL_KEY);
            return;
            
        } else if (statuscode == -902) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:notexist", [], NULL_KEY, "set");
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE, body, NULL_KEY);
            return;
            
        } else if (statuscode == -903) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "layout:alreadyexists", [], NULL_KEY, "set");
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE, body, NULL_KEY);
            return;
            
        } else if (statuscode <= 0) {
            // Don't know what kind of error it was
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [], "servererror", [(string)statuscode], NULL_KEY, "");
            sloodle_debug(body);
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE, body, NULL_KEY);
            return;
        }
        
        // positive status code - we're good
        llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVING_DONE, body, NULL_KEY);
        return;
        
    }
    
    link_message( integer sender_num, integer num, string str, key id )
    {
        if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_LAYOUT_SAVE) {
            // The first line is the URL, so we have to pull that out
            body = llDeleteSubString(str, 0, llSubStringIndex( str, "\n") );            
            url = llDeleteSubString(str, llSubStringIndex( str, "\n"), -1 );
           // llOwnerSay("got url :"+url+":");
           // llOwnerSay("got body "+body);
            entry_body = "";     
            sensee = -1;
            sense_next_object();     
        } else if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_FINISHED) {
            rezzed_objects = rezzed_objects + [id]; 
           // llOwnerSay("got object rezzed message with id "+(string)id);
        }
    } 
    
    sensor(integer num_detected) { // should only be one object at a time
        // llOwnerSay("got an object");
        vector offset_pos = (llDetectedPos(0) - llGetRootPosition()) * llGetRootRotation();
        entry_body = entry_body + llDetectedName(0) + "|" + (string)offset_pos + "|" + (string)(llDetectedRot(0) * llGetRootRotation()) + "|" +  (string)llDetectedKey(0) + "\n";
        sense_next_object();
    }
    
    no_sensor() {
        sense_next_object();
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_layout_saver.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

/*********************************************
*  Copyrght (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  httpIn_forwarder.lsl
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
*
*  Edmund Edgar (Edmund Earp in SL) 
*  ed@socialminds
*

*/

string sloodleserverroot = "";
string sloodlepwd = "";
integer isconfigured=FALSE;
integer eof=FALSE;
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;


key listenHandle;
integer  SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL =  -1639270089; //Object creator telling itself it wants to rez an object  at a position (specified as key) 
string  SLOODLE_HTTP_IN_REQUEST_LINKER = "/mod/sloodle/classroom/httpin_config_linker.php";
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);
    string value1 = "";
    string value2 = ""; 

    string SLOODLE_EOF="sloodleeof";
    if (numbits > 1) value1 = llList2String(bits,1);
    if (numbits > 2) value2 = llList2String(bits,2);
   
    if (name == "set:sloodleserverroot") sloodleserverroot = value1;
    else if (name == "set:sloodlepwd") {
        // The password may be a single prim password, or a UUID and a password
        if (value2 != "") sloodlepwd = value1 + "|" + value2;
        else sloodlepwd = value1;
        
    } else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
    else if (name == SLOODLE_EOF) eof = TRUE;
    
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0 );
}
// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;

// Translation output methods
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
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
key httpchat;
default
{
    state_entry()
    {
   // llOwnerSay("Httpin_forwarder waiting for config");
    }


    // allow for reconfiguration without resetting
     link_message( integer sender_num, integer num, string str, key id)
    {
          //  llOwnerSay("http-in forwarder got mesage"+str);
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
        
            if (str == "do:reset") llResetScript();
        
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
       // llOwnerSay("got command "+llList2String(lines,i)+", configured is "+(string)isconfigured);
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    // The main script should deal with talking about configuration.
                    // We'll avoid confusing the user by saying it twice, and just hope we both got the same messages.
                     sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                     state ready;
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
                   // sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], NULL_KEY, "");
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);
                    eof = FALSE;
                }
            }
        }
    }                          
    
    on_rez(integer start_param) {
        llResetScript();
    }
    
}

state ready {

    
     state_entry()
    {        
       // llOwnerSay("Httpin_forwarder ready");
         llListen( SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL, "", NULL_KEY, ""    );
    }
        
    listen( integer channel, string name, key id, string str){ 
        if (channel != SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL ) return;
                
      // llOwnerSay("got config request"+str);
        
        if (llGetOwnerKey(id) != llGetOwner()) {

      // llOwnerSay("returning: id of getowner is "+(string)llGetOwner()+" but object owner is "+(string)llGetOwnerKey(id));
                            
            return;
        }

     //  llOwnerSay("stilll here t"+str);
        
                            
//send to httpin_config_linker
          string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
          body += "&sloodlepwd=" + sloodlepwd;
          body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
          body += "&sloodleobjuuid=" + (string)llGetKey();
          body += "&childobjectuuid=" + (string)id;
          body += "&httpinurl=" + str;   
//llOwnerSay("requested config with body "+body); 
          httpchat = llHTTPRequest(sloodleserverroot + SLOODLE_HTTP_IN_REQUEST_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);    
   }

    // allow for reconfiguration without resetting
     link_message( integer sender_num, integer num, string str, key id)
    {
           // llOwnerSay(str);
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
      //  llOwnerSay("got command "+llList2String(lines,i)+", configured is "+(string)isconfigured);
            }
            
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");;
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], NULL_KEY, "");
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);
                    eof = FALSE;
                }
            }
        }
    }                            
    on_rez(integer start_param) {
        llResetScript();
    }        
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_httpin_forwarder.lslp


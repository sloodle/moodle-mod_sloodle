//
// The line above should be left blank to avoid script errors in OpenSim.

/*********************************************
*  Copyrght (c) 2012 various contributors (see below)
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  sloodle_rez_status_confirmer.lsl
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@avatarclassroom.com
*
*  Edmund Edgar (Edmund Earp in SL)
*  ed@avatarclassroom.com
*
*  This script handles reporting to the server if objects that it rezzed are no longer there.
*/

string sloodleserverroot = "";
string sloodlepwd = "";
integer isconfigured=FALSE;
integer eof=FALSE;
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;

string  SLOODLE_CONFIRM_ACTIVE_OBJECTS_LINKER = "/mod/sloodle/classroom/confirm_active_objects.php";
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;

key requesthttp = NULL_KEY;
key reporthttp = NULL_KEY;

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

    
default
{
    state_entry()
    {        
   // llOwnerSay("waiting for config");
    }

    // allow for reconfiguration without resetting
    link_message( integer sender_num, integer num, string str, key id)
    {
          //  llOwnerSay("http-in forwarder got mesage"+str);
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            
            if (str == "do:reset") llResetScript();
            
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
       // llOwnerSay("got command "+llList2String(lines,i)+", configured is "+(string)isconfigured);
            }

            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                     state ready;
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
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
       // llOwnerSay("config rez status confirmer ready");
        llSetTimerEvent(10);
    }

    http_response(key request_id, integer status, list metadata, string body) {

        if (request_id != requesthttp) {
            return;
        }

        // Split the data up into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        // Extract all the status fields
        list statusfields = llParseStringKeepNulls( llList2String(lines,0), ["|"], [] );
        // Get the statuscode
        integer statuscode = llList2Integer(statusfields,0);
        float refreshseconds = 60;
       // llOwnerSay(body);
        if (llGetListLength(statusfields) >= 12) {
            if (llList2Float(statusfields,12) > 0) {
                refreshseconds = llList2Float(statusfields,12);
            }
        }

        string replybody = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        replybody += "&sloodlepwd=" + sloodlepwd; 
        replybody += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        replybody += "&sloodleobjuuid=" + (string)llGetKey();
        replybody += "&sloodlecmd=reportdisappeared";
        replybody += "&sloodlemissinguuids=";

        integer i;
        integer has_missing = 0;
        for (i=1; i<numlines; i++) {
            string uuidstr = llList2String( lines, i );
            if (llGetListLength( llGetObjectDetails( (key)uuidstr, [OBJECT_NAME]) )  == 0) {
                has_missing = 1;
                replybody += uuidstr + "|";
            } 
        }

        reporthttp = llHTTPRequest(sloodleserverroot + SLOODLE_CONFIRM_ACTIVE_OBJECTS_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], replybody );
       // llOwnerSay("requestiong " +sloodleserverroot + SLOODLE_CONFIRM_ACTIVE_OBJECTS_LINKER + replybody);
        llSetTimerEvent(refreshseconds);

    }

    timer() {
        
        // Ask if there's anything we need
        string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
        body += "&sloodlepwd=" + sloodlepwd;
        body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        body += "&sloodleobjuuid=" + (string)llGetKey();
        body += "&sloodlecmd=requestconfirmable";

        requesthttp = llHTTPRequest(sloodleserverroot + SLOODLE_CONFIRM_ACTIVE_OBJECTS_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
       // llOwnerSay("on timer requestiong " +sloodleserverroot + SLOODLE_CONFIRM_ACTIVE_OBJECTS_LINKER + body);
        llSetTimerEvent(30); // In case the request fails
        
    } 
                            
    // allow for reconfiguration without resetting
    link_message( integer sender_num, integer num, string str, key id)
    {
        // llOwnerSay(str);
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            
            if (str == "do:reset") llResetScript();        
        
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
      //  llOwnerSay("got command "+llList2String(lines,i)+", configured is "+(string)isconfigured);
            }

        }
    }
    on_rez(integer start_param) {
        llResetScript();
    } 
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_rez_status_confirmer.lsl


//
// The line above should be left blank to avoid script errors in OpenSim.

// LSL script generated: mod.interaction-1.0.object_scripts.touchobject.lslp Sat May 26 14:41:21 Tokyo Standard Time 2012
// Sloodle WebIntercom (for Sloodle 0.4)
// Links in-world SL (text) chat with a Moodle chatroom
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-8 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Paul Andrews
//  Daniel Livingstone
//  Jeremy Kemp
//  Edmund Edgar
//  Peter R. Bloomfield
//
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST = -1828374651;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
string SLOODLE_INTERACTION_LINKER = "/mod/sloodle/mod/interaction-1.0/linker.php";
string SLOODLE_EOF = "sloodleeof";
integer SLOODLE_TOUCH_OBJECT_SUCCESS = -1639277100;

string sloodleserverroot = "";
string sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodlelistentoobjects = 0;
integer sloodleobjectaccessleveluse = 0;
integer sloodleobjectaccesslevelctrl = 0;
integer sloodleserveraccesslevel = 0;
integer sloodleautodeactivate = 1;

integer isconfigured = FALSE;
integer eof = FALSE;

///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
string SLOODLE_TRANSLATE_SAY = "say";
string SLOODLE_TRANSLATE_IM = "instantmessage";

key httprequest = NULL_KEY;
key avuuid = NULL_KEY;

// Send a translation request link message
sloodle_translation_request(string output_method,list output_params,string string_name,list string_params,key keyval,string batch){
    llMessageLinked(LINK_THIS,SLOODLE_CHANNEL_TRANSLATION_REQUEST,((((((((output_method + "|") + llList2CSV(output_params)) + "|") + string_name) + "|") + llList2CSV(string_params)) + "|") + batch),keyval);
}

///// ----------- /////


///// FUNCTIONS /////
/******************************************************************************************************************************
* sloodle_error_code - 
* Author: Paul Preibisch
* Description - This function sends a linked message on the SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST channel
* The error_messages script hears this, translates the status code and sends an instant message to the avuuid
* Params: method - SLOODLE_TRANSLATE_SAY, SLOODLE_TRANSLATE_IM etc
* Params:  avuuid - this is the avatar UUID to that an instant message with the translated error code will be sent to
* Params: status code - the status code of the error as on our wiki: http://slisweb.sjsu.edu/sl/index.php/Sloodle_status_codes
*******************************************************************************************************************************/

sloodle_error_code(string method,key avuuid,integer statuscode,string msg){
    llMessageLinked(LINK_SET,SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST,((((((method + "|") + ((string)avuuid)) + "|") + ((string)statuscode)) + "|") + ((string)msg)),NULL_KEY);
}


sloodle_debug(string msg){
    llMessageLinked(LINK_THIS,DEBUG_CHANNEL,msg,NULL_KEY);
}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str){
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);
    string value1 = "";
    string value2 = "";
    if ((numbits > 1)) (value1 = llList2String(bits,1));
    if ((numbits > 2)) (value2 = llList2String(bits,2));
    if ((name == "set:sloodleserverroot")) (sloodleserverroot = value1);
    else  if ((name == "set:sloodlepwd")) {
        if ((value2 != "")) (sloodlepwd = ((value1 + "|") + value2));
        else  (sloodlepwd = value1);
    }
    else  if ((name == "set:sloodlecontrollerid")) (sloodlecontrollerid = ((integer)value1));
    else  if ((name == "set:sloodlemoduleid")) (sloodlemoduleid = ((integer)value1));
    else  if ((name == "set:sloodlelistentoobjects")) (sloodlelistentoobjects = ((integer)value1));
    else  if ((name == "set:sloodleobjectaccessleveluse")) (sloodleobjectaccessleveluse = ((integer)value1));
    else  if ((name == "set:sloodleobjectaccesslevelctrl")) (sloodleobjectaccesslevelctrl = ((integer)value1));
    else  if ((name == "set:sloodleserveraccesslevel")) (sloodleserveraccesslevel = ((integer)value1));
    else  if ((name == "set:sloodleautodeactivate")) (sloodleautodeactivate = ((integer)value1));
    else  if ((name == SLOODLE_EOF)) (eof = TRUE);
    return (((sloodleserverroot != "") && (sloodlepwd != "")) && (sloodlecontrollerid > 0));
}


// Start recording the specified agent
register_interaction(key id){
    string body = ("sloodlecontrollerid=" + ((string)sloodlecontrollerid));
    (body += ("&sloodlepwd=" + sloodlepwd));
    (body += ("&sloodlemoduleid=" + ((string)sloodlemoduleid)));
    (body += ("&sloodleuuid=" + ((string)id)));
    (body += ("&sloodleobjuuid=" + ((string)llGetKey())));
    (body += ("&sloodleavname=" + llEscapeURL(llKey2Name(id))));
    (httprequest = llHTTPRequest((sloodleserverroot + SLOODLE_INTERACTION_LINKER),[HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],body));
}


// Default state - waiting for configuration
default {

    state_entry() {
        llMessageLinked(LINK_SET,(-100),"p1",NULL_KEY);
        llSetText("",<0.0,0.0,0.0>,0.0);
        (isconfigured = FALSE);
        (eof = FALSE);
        (sloodleserverroot = "");
        (sloodlepwd = "");
        (sloodlecontrollerid = 0);
        (sloodlemoduleid = 0);
        (sloodlelistentoobjects = 0);
        (sloodleobjectaccessleveluse = 0);
        (sloodleobjectaccesslevelctrl = 0);
        (sloodleserveraccesslevel = 0);
    }

    
    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == SLOODLE_CHANNEL_OBJECT_DIALOG)) {
            list lines = llParseString2List(str,["\n"],[]);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for ((i = 0); (i < numlines); (i++)) {
                (isconfigured = sloodle_handle_command(llList2String(lines,i)));
            }
            if ((eof == TRUE)) {
                if ((isconfigured == TRUE)) {
                    state ready;
                }
                else  {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"configdatamissing",[],NULL_KEY,"");
                    llMessageLinked(LINK_THIS,SLOODLE_CHANNEL_OBJECT_DIALOG,"do:reconfigure",NULL_KEY);
                    (eof = FALSE);
                }
            }
        }
    }
}
                
state ready {

     state_entry() {
    }

    touch_start(integer num_detected) {
        integer j;
        for ((j = 0); (j < num_detected); (j++)) {
            llMessageLinked(LINK_SET,(-100),"p0",NULL_KEY);
            (avuuid = llDetectedKey(j));
            register_interaction(avuuid);
            llSetTimerEvent(3);
        }
    }

        

    http_response(key id,integer status,list meta,string body) {
        if ((id != httprequest)) return;
        (httprequest = NULL_KEY);
        if ((status != 200)) {
            sloodle_debug(("Failed HTTP response. Status: " + ((string)status)));
            sloodle_error_code(SLOODLE_TRANSLATE_SAY,avuuid,status,"");
            return;
        }
        if ((llStringLength(body) == 0)) return;
        list lines = llParseStringKeepNulls(body,["\n"],[]);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines,0),["|"],[]);
        integer statuscode = llList2Integer(statusfields,0);
        key userKey = llList2Key(statusfields,6);
        if ((statuscode <= 0)) {
            string msg;
            if ((numlines > 1)) {
                (msg = llList2String(lines,1));
            }
            sloodle_debug(msg);
            sloodle_error_code(SLOODLE_TRANSLATE_IM,avuuid,statuscode,msg);
            return;
        }
        llMessageLinked(LINK_SET,SLOODLE_TOUCH_OBJECT_SUCCESS,body,userKey);
    }

            

timer() {
        llSetTimerEvent(0);
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/interaction-1.0/object_scripts/touchobject.lsl 

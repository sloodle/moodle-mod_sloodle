//
// The line above should be left blank to avoid script errors in OpenSim.

/*********************************************
*  Copyrght (c) 2009 various contributors (see below)
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  sloodle_shared_media_setup
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL) fire@b3dMultiTech.com
*
*  Edmund Edgar (Edmund Earp in SL) ed@socialminds
*
*  Gets an httpin url, opens a shared media page showing the rezzer screen, listens for http-in commands to rez objects
*/

integer SLOODLE_CHANNEL_OBJECT_DIALOG                   = -3857343;//configuration channel
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL = -1639270089; //Object creator telling itself it wants to rez an object at a position (specified as key)

string SLOODLE_EOF = "sloodleeof";
string inventorystr = "";

integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_OWNER = -1639270111; // set the main shared media panel to the specified URL, accessible to the owner
integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_GROUP = -1639270112; // set the main shared media panel to the specified URL, accessible to the group
integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_ANYONE = -1639270114; // set the main shared media panel to the specified URL, accessible to anyone

// We define all of these
// ...but for now the rezzer should only be accessible to the owner.
// In future we could implement a switch to allow other people to use it.
integer SLOODLE_CHANNEL_SET_SET_BROWSER_URL_OWNER = -1639270121; // set the open browser button to url, accessible to owner
integer SLOODLE_CHANNEL_SET_SET_BROWSER_URL_GROUP = -1639270122; // set the open browser button to url, accessible to group
integer SLOODLE_CHANNEL_SET_SET_BROWSER_URL_ANYONE = -1639270124; // set the open browser button to url, accessible to anyone




// Translation output methods
string SLOODLE_TRANSLATE_LINK = "link";             // No output parameters - simply returns the translation on SLOODLE_TRANSLATION_RESPONSE link message channel
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_WHISPER = "whisper";       // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SHOUT = "shout";           // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_REGION_SAY = "regionsay";  // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter, containing the URL.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";  // 2 output parameters: colour <r,g,b>, and alpha value


// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;


string SLOODLE_AUTH_LINKER = "/mod/sloodle/classroom/auth_object_linker.php";

key httpauthobject;
integer urlform;

sloodle_handle_command(string str) {
    if (str=="do:requestconfig")llResetScript();
}

sloodle_tell_other_scripts(string msg)
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, msg, NULL_KEY);
}

// Update our inventory list
update_inventory()
{
    integer numitems=0;
    // We're going to build a string of all copyable inventory items

    inventorystr = "";
    numitems = llGetInventoryNumber(INVENTORY_OBJECT);
    string itemname = "";
    integer numavailable = 0;

    // Go through each item
    integer i = 0;

    for (i = 0; i < numitems; i++) {
        // Get the name of this item
        itemname = llGetInventoryName(INVENTORY_OBJECT, i);
        // Make sure it's copyable, not a script, and not on the ignore list
        if((llGetInventoryPermMask(itemname, MASK_OWNER) & PERM_COPY)) {
            if (numavailable > 0) inventorystr += "\n";
            inventorystr += itemname;
            numavailable++;
        }
    }

}

string publicurl;
string privateurl;
string sloodleserverroot;

// This will be set according to the object type in default state_entry
vector rez_offset = ZERO_VECTOR;

rotation default_rez_rot = ZERO_ROTATION; // The default rotation to rez new objects at

vector rez_pos = <0.0,0.0,0.0>; // This is used to store the actual rez position for a rez request
rotation rez_rot = ZERO_ROTATION; // This is used to store the actual rez rotation for a rez request
string rez_object = ""; // Name of the object we will rez
string rez_object_list = "";
integer rez_object_http_in_password = 0; // Shared media key of the object we will rez

string rez_object_prim_password = ""; // layout entry id of the object we will rez
string rez_object_layout_entry_id = ""; // layout entry id of the object we will rez


key http_incoming_request_id;

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}
    
// Generate a random password string
string sloodle_random_object_password()
{
    return (string)(10000 + (integer)llFrand(999989999)); // Gets a random integer between 10000 and 999999999
}

default {

     state_entry() {

        llSleep(1.0);

        string desc = llGetObjectDesc();

        if ( ( llGetSubString(desc, 0, 6) == "http://" ) || ( llGetSubString(desc, 0, 7) == "https://" ) ) {
            sloodleserverroot = desc;
            state got_site_url;
        } else {
            state ask_for_site;    
        }

    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // What was the message?
            if (str == "do:reset") llResetScript();
        }
    }

    on_rez(integer start_param) {
        llResetScript();
    }

    changed(integer change) {

        if (change & CHANGED_REGION_START) {
            llResetScript();
        }

    }

    timer() {
        llResetScript();
    }

}
    
state ask_for_site {

    state_entry() {
        
        if (llGetFreeURLs() == 0) {
            llOwnerSay("Error: No URLs are available on this land parcel.");
            string url = "data:text/html,<body style=\"width:1000px;height:1000px;background-color:#595c67;color:white;font-weight:bold;\"><div style=\"position:relative;top:200px;text-align:center;width:1000px;height:750px;font-size:200%\" >No Available URLs</div></body>";
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_OWNER, url, NULL_KEY);
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_SET_BROWSER_URL_OWNER, "", NULL_KEY);            

        } else {
            
            // No URL, need to get one.
            llSetTimerEvent(60);
        
            if (publicurl != "") {
                llReleaseURL(publicurl);
            }

            llRequestURL();
            
        }
        
    }        

    http_request(key id, string method, string body){

        if (method == URL_REQUEST_GRANTED){
                   
            publicurl = body;    
    
            // string url = "http://api.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/index.php?httpinurl="+llEscapeURL(myUrl) + paramstr // avatar classroom

            string url = "data:text/html,<body style=\"width:1000px;height:1000px;background-color:#595c67;color:white;font-weight:bold;\"><div style=\"position:relative;top:200px;text-align:center;width:1000px;height:750px;font-size:200%\" ><form method=\"POST\" action=\""+body+"\">Moodle URL<br /><input style=\"height:60px;width:800px;margin:50px;\" type=\"text\" name=\"n\"><br /><input style=\":border:1px solid;width:200px;height:50px\" type=\"submit\" value=\"Submit\"></form></div></body>";
            
            // The browser button can't use a URL, so fall back on giving the public URL, which will then serve the same page via GET.
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_OWNER, url, NULL_KEY); 
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_SET_BROWSER_URL_OWNER, "nourlmessage|usedescriptioninstead", NULL_KEY); 
                               
        } else if (method == "POST"){

            //llSetContentType( id, CONTENT_TYPE_HTML );
         //  llOwnerSay(body);

            // Form input should be a single line, beginning n=
            if (llGetSubString(body, 0, 1) == "n=" ) {
                
                sloodleserverroot = llUnescapeURL(llGetSubString(body, 2, -1));
                if ( (llGetSubString(sloodleserverroot, 0, 6) != "http://" ) && ( llGetSubString(sloodleserverroot, 0, 7) != "https://" ) ) {
                    sloodleserverroot = "http://"+sloodleserverroot;
                }

                string data =  "<html><body style=\"width:1000px;height:1000px;background-color:#595c67;color:white;font-weight:bold;\"><div style=\"position:relative;top:200px;text-align:center;width:1000px;height:750px;font-size:200%\" >Contacting site<br /><br />"+sloodleserverroot+"</div></body></html>";
    
                llHTTPResponse( id, 200, data );
                                           
                // llOwnerSay(sloodleserverroot);
                llReleaseURL(publicurl);
            
                state got_site_url;

            }   
                    
        } 

    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // What was the message?
            if (str == "do:reset") llResetScript();
        }
    }

}
    
state got_site_url {

    state_entry() {                    

        llSetTimerEvent(30);

        if (privateurl != "") {
            llReleaseURL(publicurl);
        }
        llRequestURL();
  
    }

    http_request(key id, string method, string body){
        
        if (method == URL_REQUEST_GRANTED){
        
            privateurl = body;
      
            string paramstr = "&sloodleobjuuid=" + (string)llGetKey() + "&sloodleobjname=" + llEscapeURL(llGetObjectName()) + "&sloodleuuid=" + (string)llGetOwner() + "&sloodleavname=" + llEscapeURL(llKey2Name(llGetOwner()));
        
            // register with the site
            string rqbody = "sloodleobjuuid="+(string)llGetKey()+"&sloodleobjname="+llGetObjectName()+"&sloodleobjpwd="+sloodle_random_object_password()+"&sloodleobjtype="+"set-1.0/default"+"&sloodlehttpinurl="+llEscapeURL(privateurl);
            httpauthobject = llHTTPRequest(sloodleserverroot + SLOODLE_AUTH_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], rqbody);
        
        }
        
    }  
                                
    on_rez(integer start_param) {
        llResetScript();
    }

    changed(integer change) {

        if (change & CHANGED_REGION_START) {
            llResetScript();
        }

    }
        
    http_response(key id, integer status, list meta, string body)
    {
       // llOwnerSay(body);
        // Make sure this is the response we're expecting
        if (id != httpauthobject) return;
        if (status != 200) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httperror:code", [status], NULL_KEY, "");
            llSleep(10);
            llResetScript();
        }
        
        // Split the response into lines
        list lines = llParseStringKeepNulls(body, ["\n"], []);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines, 0), ["|"], []);
        integer statuscode = (integer)llList2String(statusfields, 0);
        
        // Check the statuscode
        if (statuscode <= 0) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "objectauthfailed:code", [statuscode], NULL_KEY, "");
            llSleep(10);            
            llResetScript();
        }
        
        // Attempt to get the auth ID
        if (numlines < 2) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "badresponseformat", [], NULL_KEY, "");
            llSleep(10);        
            llResetScript();
        }
        //sloodleauthid = llList2String(lines, 1);
        
       // string paramstr = "&sloodleobjuuid=" + (string)llGetKey() + "&sloodleobjname=" + llEscapeURL(llGetObjectName()) + "&sloodleuuid=" + (string)llGetOwner() + "&sloodleavname=" + llEscapeURL(llKey2Name(llGetOwner()));
       // string path = "/mod/sloodle/mod/set-1.0/shared_media/index.php?httpinurl="+llEscapeURL(myUrl) + paramstr;
                
        string url = sloodleserverroot+"/mod/sloodle/mod/set-1.0/shared_media/frame.php?sloodleobjuuid="+llEscapeURL((string)llGetKey());

       // llOwnerSay("OK, redirecting to "+url);
        llSleep(3);

      //llGetKey() hacked in as a signal to force a clear, as the screen seems to fail to update in this particular situation.
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_OWNER, url, llGetKey());               
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SET_SET_BROWSER_URL_OWNER, url, NULL_KEY);         
                    
        state ready;
        
    } 

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // What was the message?
            if (str == "do:reset") llResetScript();
        }
    }            
}
        
state ready {

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // What was the message?
            if (str == "do:reset") llResetScript();
        }
    }

    on_rez(integer start_param) {
        llResetScript();
    }

    http_request(key id, string method, string body){

        if (method == "POST"){

               //this is where we receive data from from our server
                list lines;
                lines = llParseStringKeepNulls( body, ["\n"], [] );
              // llOwnerSay(body);
               // llOwnerSay("Got a request - need to check what it is and probably rez something");

                list statusbits =  llParseStringKeepNulls( llList2String(lines,0), ["|"], []);
                string requestType = llList2String( statusbits, 3 );
                if (requestType == "REZ_OBJECT") {
                    http_incoming_request_id = id;
                    rez_object_list = llList2String(lines, 1); // This will be a pipe-delimited string of object choices.
                    rez_pos = (vector)llList2String(lines, 2); 
                    rez_rot = (rotation)llList2String(lines, 3);
                    rez_object_http_in_password = (integer)llList2String(lines,4);
                    rez_object_prim_password = llList2String(lines,5);
                    rez_object_layout_entry_id = llList2String(lines,6);
                    state rezz_and_reply;

                } else if (requestType == "LIST_INVENTORY") {
                  //  llOwnerSay("got LIST_INVENTORY request");

                    update_inventory();
                    //numPages = numItems/
                    string resp="OK||||||||||"+"\n"+inventorystr;
                    llHTTPResponse(id, 200, resp);

                } else { // I don't know how to handle this - throw it to someone else...
              //  llOwnerSay("misc config message received");
                // Currently used for configuration of the rezzer
                    llHTTPResponse(id, 200, "OK");
               // llOwnerSay(body);
                //integer i = 0;
                //for (i=0; i<llGetListLength(lines); i++) {
                   // llOwnerSay( llList2String(lines, i) );
                  //  sloodle_tell_other_scripts(llList2String(lines, i));
                //}
                    sloodle_tell_other_scripts(body+"\n"+SLOODLE_EOF);
    
                  //  llHTTPResponse(id, 200, "OK");
                
              }//endif

          }//endif
     }//http

    changed(integer change) {

        if (change & CHANGED_REGION_START) {
            llResetScript();
        }

    }

}

// Rez an object and reply to the outstanding http request
state rezz_and_reply
{
    state_entry()
    {
        list objs = llParseStringKeepNulls( rez_object_list, ["|"], [] );
        integer i;
        integer objectFound = 0;
        while ( (objectFound == 0) && ( i < llGetListLength( objs ) ) ) {
            rez_object = llList2String(objs, i);
            if (llGetInventoryType(rez_object) == INVENTORY_OBJECT) {
                objectFound = 1;
            }
            i++;
        }

        if (objectFound == 0) {
           // llOwnerSay("could not find an object for the string "+rez_object_list);
            llHTTPResponse(http_incoming_request_id, 500, "INVENTORY_NOT_FOUND");
            http_incoming_request_id = NULL_KEY;
            state ready;
        }

        if (llGetFreeURLs() == 0) {
            //llOwnerSay("no free url");
            llHTTPResponse(http_incoming_request_id, 500, "NO_AVAILABLE_URL");
            http_incoming_request_id = NULL_KEY;
            state ready;
        }

        //llOwnerSay("unprocessed rot is "+(string)rot);
        rez_pos = rez_pos * llGetRootRotation();
        rez_rot = rez_rot * llGetRootRotation();

       // llMessageLinked(LINK_SET,SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_STARTED, "", NULL_KEY);

        llSetTimerEvent(0);
       // llOwnerSay("about to attempt rez for "+rez_object_list);
        llRezObject(rez_object, llGetRootPosition() + ( rez_pos * llGetRootRotation() ), ZERO_VECTOR, rez_rot, rez_object_http_in_password);

        // Timeout after a while if the object doesn't get rezzed
        llSetTimerEvent(30.0);
    }

    timer()
    {
        llSetTimerEvent(0.0);
        llHTTPResponse(http_incoming_request_id, 200,"");
        http_incoming_request_id = NULL_KEY;

        state ready;
    }

    object_rez(key id)
    {
        string responsebody = (string)id+"\n"+(string)llGetKey()+"\n"+rez_object_prim_password+"\n"+(string)rez_object_http_in_password+"\n"+rez_object_layout_entry_id;
        llHTTPResponse(http_incoming_request_id, 200,responsebody);
        http_incoming_request_id = NULL_KEY;
        state ready;
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // What was the message?
            if (str == "do:reset") llResetScript();
        }
    }

    changed(integer change) {

        if (change & CHANGED_REGION_START) {
            llResetScript();
        }

    }
    
    on_rez(integer start_param) {
        llResetScript();
    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_shared_media_setup.lsl


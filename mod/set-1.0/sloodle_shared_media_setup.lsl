/*********************************************
*  Copyrght (c) 2009 various contributors (see below)
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  http_in_config_requester
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL) fire@b3dMultiTech.com  
*
*  Edmund Edgar (Edmund Earp in SL) ed@socialminds
*
*  This script will get an httpin url, open a shared media page allowing it to be used
*/

integer SLOODLE_CHANNEL_OBJECT_DIALOG                   = -3857343;//configuration channel
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL = -1639270089; //Object creator telling itself it wants to rez an object at a position (specified as key)

string SLOODLE_EOF = "sloodleeof";
string inventorystr = "";

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
    numitems = llGetInventoryNumber(INVENTORY_ALL);
    string itemname = "";
    integer numavailable = 0;
    
    // Go through each item
    integer i = 0;

    for (i = 0; i < numitems; i++) {
        // Get the name of this item
        itemname = llGetInventoryName(INVENTORY_OBJECT, i);
        // Make sure it's copyable, not a script, and not on the ignore list
        if((llGetInventoryPermMask(itemname, MASK_OWNER) & PERM_COPY) && llGetInventoryType(itemname) != INVENTORY_SCRIPT ) {
            if (numavailable > 0) inventorystr += "|";
            inventorystr += llEscapeURL(itemname);
            numavailable++;
        }
    }
    
}
string myUrl;

// This will be set according to the object type in default state_entry 
vector rez_offset = ZERO_VECTOR; 

rotation default_rez_rot = ZERO_ROTATION; // The default rotation to rez new objects at

vector rez_pos = <0.0,0.0,0.0>; // This is used to store the actual rez position for a rez request
rotation rez_rot = ZERO_ROTATION; // This is used to store the actual rez rotation for a rez request
string rez_object = ""; // Name of the object we will rez
string rez_object_list = "";

key http_incoming_request_id;

default {
    
     state_entry() {    
        llSleep(1.0);
        llRequestURL();
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // What was the message?
            if (str == "do:reset") llResetScript();
        }  
    }       

    http_request(key id, string method, string body){
        
          if ((method == URL_REQUEST_GRANTED)){
        
                myUrl = body;
                
                string paramstr;
                paramstr = "&sloodleobjuuid=" + (string)llGetKey() + "&sloodleobjname=" + llEscapeURL(llGetObjectName()) + "&sloodleuuid=" + (string)llGetOwner() + "&sloodleavname=" + llEscapeURL(llKey2Name(llGetOwner()));
                           
                //llOwnerSay("got url URL_REQUEST_GRANTED"+"http://api.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/index.php?httpinurl="+llEscapeURL(myUrl) + paramstr);
                llClearPrimMedia(4);
                llSetPrimMediaParams( 4, [ PRIM_MEDIA_CURRENT_URL, "http://api.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/index.php?httpinurl="+llEscapeURL(myUrl) + paramstr, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_GROUP ] );
                state ready;
                
          }
     }//http
           

    on_rez(integer start_param) {
        llResetScript();
    }             
          
    changed(integer change) {

        if (change & CHANGED_REGION_START) {
            llResetScript();
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
                    state rezz_and_reply;
                    
                } else if (requestType == "REQUEST_INVENTORY_LIST") {
                    llOwnerSay("got REQUEST_INVENTORY_LIST request");                    
                        
                    update_inventory();
                    //numPages = numItems/
                    string resp="OK||||||||||"+"\n"+inventorystr;
                    llHTTPResponse(id, 200, resp);                                     
                    
                } else { // I don't know how to handle this - throw it to someone else...
                llOwnerSay("misc config message received");
                // Currently used for configuration of the rezzer
                    llHTTPResponse(id, 200, "OK");                       
               // llOwnerSay(body);                
                //integer i = 0;
                //for (i=0; i<llGetListLength(lines); i++) {
                   // llOwnerSay( llList2String(lines, i) );
                  //  sloodle_tell_other_scripts(llList2String(lines, i));                       
                //}
                    sloodle_tell_other_scripts(body);
                    // This is the end of the configuration data
                    llSleep(0.2);
                    sloodle_tell_other_scripts(SLOODLE_EOF);               
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
        
        //llOwnerSay("unprocessed rot is "+(string)rot);
        rez_pos = rez_pos * llGetRootRotation();
        rez_rot = rez_rot * llGetRootRotation(); 

       // llMessageLinked(LINK_SET,SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_STARTED, "", NULL_KEY);
            
        llSetTimerEvent(0);    
        
        llRezObject(rez_object, llGetRootPosition() + ( rez_pos * llGetRootRotation() ), ZERO_VECTOR, rez_rot, 0);          
        
        // Timeout after a while if the object doesn't get rezzed
        llSetTimerEvent(10.0);
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
        llHTTPResponse(http_incoming_request_id, 200,(string)id);
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
}



//
// The line above should be left blank to avoid script errors in OpenSim.

/*********************************************
*  Copyrght (c) 2009 - 2010 various contributors (see below)
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  httpIn_forwarder.lsl
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL) fire@b3dMultiTech.com  
*
*  Edmund Edgar (Edmund Earp in SL) ed@socialminds
*
*  This script will get an httpin url, and shout it out to the rezzer.  It will then wait to receive its config via httpin, and send it as a linked message to all other scripts
*/

integer SLOODLE_CHANNEL_OBJECT_DIALOG                   = -3857343;//configuration channel
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL = -1639270089; //Object creator telling itself it wants to rez an object at a position (specified as key)

string SLOODLE_EOF = "sloodleeof";


sloodle_handle_command(string str) {
         if (str=="do:requestconfig")llResetScript();         

}

sloodle_tell_other_scripts(string msg)
{
   
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_OBJECT_DIALOG, msg, NULL_KEY);   
}

string myUrl;
default{
    state_entry() {    
        llSleep(1.0);
        llRequestURL();
    }

    on_rez(integer start_param) {
        llResetScript();
    }          
        
    http_request(key id, string method, string body){
          if ((method == URL_REQUEST_GRANTED)){
                myUrl=body;
                //shout it out to the rezzer our httpinUrl
                llRegionSay(SLOODLE_CHANNEL_OBJECT_CREATOR_REQUEST_CONFIGURATION_VIA_HTTP_IN_URL,myUrl);
               // llOwnerSay("got url "+myUrl);
          }//endif
          else 
          if (method == "POST"){                            
               //this is where we receive data from from our server
                llHTTPResponse(id, 200, "OK");                       
                list lines;
                lines = llParseStringKeepNulls( body, ["\n"], [] );
                integer i = 0;
                for (i=0; i<llGetListLength(lines); i++) {
                   // llOwnerSay( llList2String(lines, i) );
                    sloodle_tell_other_scripts(llList2String(lines, i));                       
                }
                // This is the end of the configuration data
                llSleep(0.2);
                sloodle_tell_other_scripts(SLOODLE_EOF);               
          }//endif
     }//http
     changed(integer change) {
         if (change ==CHANGED_INVENTORY){         
             llResetScript();
         }
     }
}


// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/sloodle_httpin_config_requester.lsl 

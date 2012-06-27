//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*  Part of the Sloodle project (www.sloodle.org)
*
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
*  -------------------------------------------
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  All scripts must maintain this copyrite information, including the contributer information listed
*
*  Contributors:
*  Paul Preibisch
*
*  DESCRIPTION
* Contributors:
*  Edmund Edgar
*  Paul Preibisch
*/


integer FACE = 4;
integer counter=0;

integer SLOODLE_CHANNEL_SET_SET_BROWSER_URL_OWNER = -1639270121; // set the open browser button to url, accessible to owner
integer SLOODLE_CHANNEL_SET_SET_BROWSER_URL_GROUP = -1639270122; // set the open browser button to url, accessible to group
integer SLOODLE_CHANNEL_SET_SET_BROWSER_URL_ANYONE = -1639270124; // set the open browser button to url, accessible to anyone

integer active_num;
string url;
string nourlmessage; // If we can't provide a URL, use this message instead, which should be passed to the translation script.

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;

// Translation output methods
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";  // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;

// Send a translation request link message
// NB This has been changed to LINK_SET from the normal LINK_THIS
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

open_in_browser(key toucher) 
{   
    if (nourlmessage != "") {
        if (toucher == llGetOwner()) {
            sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], nourlmessage, [llKey2Name(toucher)], NULL_KEY, "");           
        } else {
            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], nourlmessage, [llKey2Name(toucher)], NULL_KEY, "");                           
        }
        return; 
    }

    llTriggerSound("click", 1.0);
    //sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], nourlmessage, [llKey2Name(toucher)], NULL_KEY, ""); 
    if (toucher == llGetOwner()) {
        sloodle_translation_request(SLOODLE_TRANSLATE_OWNER_SAY, [0], "openrezzerurl", [url], NULL_KEY, "");           
    } else {
        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "openrezzerurl", [url], NULL_KEY, "");                           
    }  
    /*  
    if (toucher == llGetOwner()) {
        llOwnerSay("Open the rezzer in your browser"+"\n"+url); 
    } else {
        llInstantMessage(toucher,"Open the rezzer screen in your browser\n"+url);            
    }
    */
    
}

default {
    
    on_rez(integer start_param) {
        llResetScript();
    }
    
    link_message( integer sender_num, integer num, string str, key id ) {
        
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            
            if (str=="do:reconfigure"||str=="do:reset"){
                llResetScript();
            }
                
        } else if ( ( num == SLOODLE_CHANNEL_SET_SET_BROWSER_URL_OWNER ) || ( num == SLOODLE_CHANNEL_SET_SET_BROWSER_URL_GROUP ) || ( num == SLOODLE_CHANNEL_SET_SET_BROWSER_URL_ANYONE) ) {
                
            active_num = num;
        
            if (str == "") {
                url = "";
                nourlmessage = "";
                return;
            }
        
            // if we can't provide a URL, we can set a message to say what to say instead.
            //nourlmessage|usedescriptioninstead
            if (llGetSubString(str, 0, 12) == "nourlmessage|") {
                url = "";
                nourlmessage = llGetSubString(str,13,-1);
                return;
            }
                
            url = str;
            nourlmessage = "";
            
        }
    }
    
    touch_start(integer d){
                           
        if ( (url == "") && (nourlmessage == "") ) {
            return;
        }

        integer j;            
        for (j=0;j<d;j++){
            
            key toucher = llDetectedKey(j);
            if (active_num == SLOODLE_CHANNEL_SET_SET_BROWSER_URL_ANYONE) {
                open_in_browser(toucher);
            } else if ( toucher == llGetOwner() ) {
                open_in_browser(toucher);                    
            } else if ( (active_num == SLOODLE_CHANNEL_SET_SET_BROWSER_URL_GROUP) && llSameGroup(toucher) ) {
                open_in_browser(toucher);                                        
            } else {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(toucher)], NULL_KEY, "");                    
            }
                
        }
    }//TOUCH 
        
}//default
        

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_open_in_browser.lslp 

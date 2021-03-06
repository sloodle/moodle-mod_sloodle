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
*  Edmund Edgar
*
*  DESCRIPTION
*  llMessageLinked(LINK_SET,SLOODLE_TIMER_RESTART, (string)TIME_LIMIT+"|"+"SND_BUZZER|QUESTION TIME LIMIT REACHED", "");
*/
integer TIME_LIMIT=10;//default, but can be set in config
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script. 
string sloodleserverroot = "";
integer sloodlecontrollerid = 0;
string sloodlepwd = "";
string END_SOUND;
integer sloodlemoduleid = 0;
string TIMES_UP_MESSAGE;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
integer isconfigured = FALSE; // Do we have all the configuration data we need?
string SLOODLE_EOF = "sloodleeof";
integer eof = FALSE; // Have we reached the end of the configuration data?
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
integer SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE= -1639277008;
integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";          // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_WHISPER = "whisper";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.
string SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM= "hovertext_linked_prim"; // 3 output parameters: colour <r,g,b>,  alpha value, link number
integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
vector RED =<1.00000, 0.00000, 0.00000>;
vector ORANGE=<1.00000, 0.43763, 0.02414>;
vector YELLOW=<1.00000, 1.00000, 0.00000>;
vector GREEN=<0.00000, 1.00000, 0.00000>;
vector BLUE=<0.00000, 0.00000, 1.00000>;
vector BABYBLUE=<0.00000, 1.00000, 1.00000>; 
vector PINK=<1.00000, 0.00000, 1.00000>;
vector PURPLE=<0.57338, 0.25486, 1.00000>;
vector BLACK= <0.00000, 0.00000, 0.00000>;
vector WHITE= <1.00000, 1.00000, 1.00000>;
vector AVCLASSBLUE= <0.06274,0.247058,0.35294>;
vector AVCLASSLIGHTBLUG=<0.8549,0.9372,0.9686>;//#daeff7
integer SLOODLE_TIMER_START= -1639277011; //shoudl be used to starts the timer from its current position
integer SLOODLE_TIMER_RESTART= -1639277012;//should be used to set the counter to 0 and begin counting down again
integer SLOODLE_TIMER_STOP= -1639277013;//should stop the timer at its current position
integer SLOODLE_TIMER_STOP_AND_RESET= -1639277014;//should stop the timer at its current position and reset count to 0
integer SLOODLE_TIMER_RESET= -1639277015;//shoudl reset the count back to zero but not restart the timer
integer SLOODLE_TIMER_TIMES_UP= -1639277016;//used to transmit the timer reached its time limit

integer COUNT=0;
sloodle_error_code(string method, key avuuid,integer statuscode, string msg){
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|"+(string)statuscode+"|"+(string)msg, NULL_KEY);
}   
sloodle_debug(string msg){
    llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
}  
// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}    
integer get_prim(string name){
    integer num_links=llGetNumberOfPrims();
    integer i;
    integer prim=-1;
    for (i=0;i<=num_links;i++){
        if (llGetLinkName(i)==name){
            prim=i;
        }else{
        }
    }
    return prim;
}    
 debug (string message ){
     list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
     if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 
default {
    on_rez(integer start_param) {
        llResetScript();
    }
   
    state_entry() {
        COUNT=0;
    }

    link_message(integer sender_num, integer chan, string str, key id) {
            
            list data=llParseString2List(str, ["|"], []);
            
            if (chan==SLOODLE_TIMER_START){//starts the timer from its current position
                llSetTimerEvent(1);
                TIME_LIMIT=(integer)llList2Integer(data,0);
                END_SOUND=llList2String(data,1);
                TIMES_UP_MESSAGE=llList2String(data,2);
            }else
            if (chan==SLOODLE_TIMER_RESTART){//used to set the counter to 0 and begin counting down again
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [RED, 1.0,get_prim("timer_prim")], "option", [" "], "", "hex_quizzer");
                COUNT=0;
                TIME_LIMIT=(integer)llList2Integer(data,0);
                END_SOUND=llList2String(data,1);
                TIMES_UP_MESSAGE=llList2String(data,2);
                llSetTimerEvent(1);
            }else
            if (chan==SLOODLE_TIMER_STOP){//stop the timer at its current position
                                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [RED, 1.0,get_prim("timer_prim")], "timer_stopped", [" "], "", "hex_quizzer");
                llSetTimerEvent(0);
            }else
            if (chan==SLOODLE_TIMER_STOP_AND_RESET){// stop the timer at its current position and reset count to 0
                llSetTimerEvent(0);
                COUNT=0;
            }else
            if (chan==SLOODLE_TIMER_RESET){// reset the count back to zero but not restart the timer
                COUNT=0;
                 llSetTimerEvent(0);
            }
    
    }
    timer() {
        COUNT++;
        vector color;
        if ((TIME_LIMIT - COUNT)<=0){
            llSetTimerEvent(0.0);
            
            if (END_SOUND!=""){
                llTriggerSound(END_SOUND,1);
                END_SOUND="";
            }
            llMessageLinked(LINK_SET, SLOODLE_TIMER_TIMES_UP, TIMES_UP_MESSAGE, NULL_KEY);
            return;
        }
        string timer_text="(" + (string)(TIME_LIMIT - COUNT) + ")";
     
        if ((TIME_LIMIT - COUNT)>10){
            color=GREEN;
            llTriggerSound("SND_TICK",0.2);
        }
        else if ((TIME_LIMIT - COUNT)<=10&&(TIME_LIMIT - COUNT)>5){
            color=YELLOW;
            llTriggerSound("SND_TICK",0.2);
        }
        else {
            color=RED;
            llTriggerSound("SND_BEEPBEEP",0.2);
        };
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [color, 1.0,get_prim("timer_prim")], "option", [timer_text], "", "hex_quizzer");
           
    }
}

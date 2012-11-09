//
// The line above should be left blank to avoid script errors in OpenSim.

// LSL script generated: mod.set-1.0.rezzer_reset_btn.lslp Tue Nov 15 15:49:28 Tokyo Standard Time 2011
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
*  Rezzer.lslp
*  This script is responsible for:
*  *** initiating the loading of a quiz
*  *** getting the first question and loading the options as texture maps on the child prims (pie_slices)
*  *** initiating a countdown in the timer.lslp script
*  *** starting a sensor, and using hovertext to display which pie_slice a user is standing over
*  *** determining the value of each option and telling each pie_slice to open or close when the count down timer reaches zero 
*  *** determining which pie_slice a user is standing over at the end of the countdown, and submitting their answers to the notify_server.lslp script 
*  *** rezzing orbs on each of its edges which are clickable by avatars who answered correctly 
*  *** receive linked messages from the orbs which indicate touch events from avatars who have answered the question correctly, and rez 
*      rezzing child hexagons along the touched edges 
*  *** Receive GET QUESTION command from a child hex when its center orb has been touched by an avatar
*  *** requesting questions from question_handler.lslp and passing retrieved question along to the requesting child hexagon
*      
*
*/
float edge_length;
float tip_to_edge;
list QUESTIONS_ASKED;
float edge_length_half;
string CONFIG;

list rezzed_hexes;
list opids;
integer PIN=7961;
integer doRepeat;
integer doRandomize;
integer doPlaySound;
integer quiz_id;
integer ALREADY_REZZED=FALSE;
string quiz_name;
integer question_id;
integer NO_REZ_ZONE;
list ORBS_TOUCHED;
integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
integer SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE= -1639271118; //user has tried to use the chair but doesnt have permission to do so.
integer SLOODLE_CHANNEL_QUIZ_LOAD_QUIZ= -1639277003;//user touched object
integer SLOODLE_CHANNEL_SET_CLEANUP_AND_DEREZ = -1639270131; // linked message to tell the object to derez if it has some object-specific cleanup tasks.
list question_ids;
integer num_questions;
list DETECTED_AVATARS;
list DETECTED_AVATARS_POSITION;
list DETECTED_AVATARS_OP_IDS;
list DETECTED_AVATARS_SCORE_CHANGE;
integer current_question;
string sloodleserverroot = "";
integer sloodlecontrollerid = 0;
string sloodlepwd = "";
integer sloodlemoduleid = 0;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
integer isconfigured = FALSE; // Do we have all the configuration data we need?
integer eof = FALSE; // Have we reached the end of the configuration data?
string SLOODLE_EOF = "sloodleeof";
string sloodle_quiz_url = "/mod/sloodle/mod/quiz-1.0/linker.php";
list  sides_rezzed;
string QUIZ_DATA;
integer TIME_LIMIT;
list GRAND_CHILDREN;
integer SLOODLE_REMOTE_LOAD_SCRIPT=1639277018;
string HEX_CONFIG_SEPARATOR="*^*^*^";
integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script. 
integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.
integer SLOODLE_SET_TEXTURE= -1639277010; 
integer SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE= -1639277008;
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object

integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";          // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_WHISPER = "whisper";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION = -1639271112; //used when this script wants to ask a question and have the results sent to the child hex
integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text
integer SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ = -1639271110;
integer SLOODLE_CHANNEL_QUIZ_NOTIFY_SERVER_OF_RESPONSE= -1639277004;
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER = -1639271116; //mod quiz script is in state CHECK_QUIZ
string SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM= "hovertext_linked_prim"; // 3 output parameters: colour <r,g,b>,  alpha value, link number
string HEXAGON_PLATFORM="Hexagon Quizzer";
integer TIMES_UP=FALSE;
integer num_options=0;
list CORRECT_AVATARS;
list options;//store pie slice correlation. Therefore option[0]=pie_slice# 
integer quiz_loaded=FALSE;
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
list MY_SLICES;
integer already_received_question=FALSE;
integer my_start_param;
list pie_slice_hover_text;
string qdialogtext;
list qdialogoptions;
list option_points;
debug (string message ){
     list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
     if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 
integer sloodle_check_access_use(key id){
    // Check the access mode
    if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_GROUP) {
        return llSameGroup(id);
    } else if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC) {
        return TRUE;
    }
    // Assume it's owner mode
    return (id == llGetOwner());
}


//returns the pie_slice the avatar is standing near
string get_detected_pie_slice(vector avatar){
    //returns name of pie_slice
    integer i;
    float closest_orb_distance=100.0;
    string  name_of_closest_orb="";
    integer closest_orb_link_number;
    integer root_orb= get_prim("Hexagon Quizzer");
    for (i=1;i<=6;i++){
        integer orb_link_number = get_prim("orb"+(string)i);
        list orb_data=llGetLinkPrimitiveParams(orb_link_number, [PRIM_POSITION]);
        
        vector orb_pos = llList2Vector(orb_data, 0);
        float detected_distance_from_avatar_to_orb = llVecDist(orb_pos, avatar);
        if (detected_distance_from_avatar_to_orb<closest_orb_distance){
            closest_orb_distance = detected_distance_from_avatar_to_orb;
            name_of_closest_orb="orb"+(string)i;
        }
    }
    
    return name_of_closest_orb;
}

/*
*  This function will determine how much a particular pie_slice is worth. 
*
*
*/
integer question_prim;
integer num_links;
set_prim_text(integer prim,string text,vector color){
    llSetLinkPrimitiveParamsFast(prim, [PRIM_TEXT,text,color,1] );
}
/*
Search through all linked prims, and returns the prims link number which matches the name
*/
integer get_prim(string name){
    num_links=llGetNumberOfPrims();
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
string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
}
// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}
        
   // Configure by receiving a linked message from another script in the object
   // Returns TRUE if the object has all the data it needs
   integer sloodle_handle_command(string str){
            list bits = llParseString2List(str,["|"],[]);
            integer numbits = llGetListLength(bits);
            string name = llList2String(bits,0);
            string value1 = "";
            string value2 = "";
            if (numbits > 1) value1 = llList2String(bits,1);
            if (numbits > 2) value2 = llList2String(bits,2);
            if (name == "set:sloodleserverroot") sloodleserverroot = value1;
            else if (name == "set:sloodlepwd") {
                // The password may be a single prim password, or a UUID and a password
                if (value2 != "") {
                   sloodlepwd = value1 + "|" + value2;
                }
                else {
                    sloodlepwd = value1;
                }
            }
            else if (name == "set:questiontimelimit"){
                 TIME_LIMIT= (integer)value1;
                   debug("\n\n\n\n\n we got time limit is: "+(string)TIME_LIMIT);
            }
            else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
            else if (name == "set:sloodlemoduleid") sloodlemoduleid = (integer)value1;
            else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
            else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
            else if (name == "set:sloodlerepeat") doRepeat = (integer)value1;
            else if (name == "set:sloodlerandomize") doRandomize = (integer)value1;
            else if (name == "set:sloodleplaysound") doPlaySound = (integer)value1;
            else if (name == SLOODLE_EOF) eof = TRUE;
            return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0 && sloodlemoduleid > 0);
       }

default {
    on_rez(integer start_param){
        llResetScript();
    }
    state_entry() {
        integer n=llGetNumberOfPrims();
        integer j=0;
        for (j=0;j<n;j++){
            llSetLinkPrimitiveParamsFast( j,[PRIM_TEXT," ",GREEN,1]);
        }
        llSetScriptState( "_platform.lslp", FALSE);
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==SLOODLE_CHANNEL_OBJECT_DIALOG){
            CONFIG=str;
            list lines = llParseString2List(CONFIG, ["\n"], []);
                    integer numlines = llGetListLength(lines);
                    integer i = 0;
                    for (i=0; i < numlines; i++) {
                        isconfigured = sloodle_handle_command(llList2String(lines, i));
                    }
                    // If we've got all our data AND reached the end of the configuration data (eof), then move on
                    if (eof == TRUE) {
                        if (isconfigured == TRUE) {
                               sloodle_translation_request ( SLOODLE_TRANSLATE_SAY , [0], "script_configurationreceived" , [ llGetScriptName()], NULL_KEY , "hex_quizzer");
                            state ready;
                        }
                    }
        }else
        if (num == SLOODLE_CHANNEL_SET_CLEANUP_AND_DEREZ) {
            llDie(); // You should always do this once you're finished.
        }
    }
}
state ready{
        on_rez(integer start_param){
            llResetScript();
        }
        state_entry() {
          llTriggerSound("SND_STARTING_UP", 1);
           debug("in ready state - touch to load quiz");   
           integer status_prim=get_prim("status_prim");
           debug("statusprim: "+(string)status_prim);
           sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [ORANGE, 1.0,status_prim], "click_to_load", [], "", "hex_quizzer");
        }
        touch_start(integer num_detected) {
            key user_key=llDetectedKey(0);
            if (quiz_loaded==FALSE){
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [ORANGE, 1.0,get_prim("status_prim")], "loadingquiz", [], "", "hex_quizzer");

                if (!sloodle_check_access_use(user_key)) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(user_key)], NULL_KEY, "");
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE, "", user_key);
                    return;
                }  
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "starting", [llKey2Name(user_key)], NULL_KEY, "quiz");                                                     
                /*
                * Tell load_quiz.lslp to load the quiz, it will do so, then pass us a message SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ with all the quiz data
                * this data will be locked for this hex
                */
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_LOAD_QUIZ, "", user_key);
            }      
        
        }
      
        link_message(integer link_set, integer channel, string str, key id) {
          list data= llParseString2List(str, ["|"], []);
        if (channel == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Split the message into lines
                    CONFIG = str;
        }
        if (channel==SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ){
              QUIZ_DATA = str;
              data = llParseString2List(str, ["|"], []);
              quiz_id=llList2Integer(data,0);
              quiz_name=llList2String(data,1);
              num_questions=llList2Integer(data,2);
              question_ids=llParseString2List(llList2String(data,3), [","], []);
              debug("------quiz loaded: "+(string)quiz_id+" quiz name: "+quiz_name+" num questions: "+(string)num_questions);
              state quiz_loaded;
        }else
        if (channel == SLOODLE_CHANNEL_SET_CLEANUP_AND_DEREZ) {
            llDie(); // You should always do this once you're finished.
        }
    }
}
state quiz_loaded{
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        debug("********************************************************************quiz loaded");
          sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [ORANGE, 1.0,get_prim("status_prim")], "quizloaded", [], "", "hex_quizzer");
          
          llRezObject(HEXAGON_PLATFORM, llGetPos()+<0,0,2>, ZERO_VECTOR,  llGetRot(), 0);
          ALREADY_REZZED=TRUE;
    }
    touch_start(integer num_detected) {
         if (llGetListLength(QUESTIONS_ASKED)>=num_questions){
             //quiz finished
              if (doRepeat==TRUE){
                        current_question=0;
                        QUESTIONS_ASKED=[];
            }else{
                 sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "no_more_questions", [llDetectedName(0)], llDetectedKey(0), "hex_quizzer");
                return;
            }
         }
         //if (!ALREADY_REZZED){
             llRezAtRoot(HEXAGON_PLATFORM, llGetPos()+<0,0,2>, ZERO_VECTOR,  llGetRot(), 0);
             ALREADY_REZZED=TRUE;
     //    }
    }
    
    object_rez(key platform) {
        //a new hex was rezzed, listen to the new hex platform
            llListen(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "", platform, "");
            rezzed_hexes+=platform;
            llGiveInventory(platform, HEXAGON_PLATFORM);
            debug("giving platform script");
            //since llRemoteLoadScriptPin makes a script sleep for 3 seconds, we need to offload the remote loading of the scripts to a seperate loader script
            llRemoteLoadScriptPin(platform, "sloodle_translation_hex_quizzer_en",PIN, TRUE, 0);
            llRemoteLoadScriptPin(platform, "_platform.lslp",PIN, TRUE, 0);
    }
    link_message(integer sender_num, integer num, string str, key id) {
         if (num == SLOODLE_CHANNEL_SET_CLEANUP_AND_DEREZ) {
             integer k=0;
             integer len = llGetListLength(rezzed_hexes);
             
             for(k=0;k<len;k++){
                 key hex=llList2Key(rezzed_hexes,k);
                 llRegionSayTo(hex,SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "die"+HEX_CONFIG_SEPARATOR+CONFIG);
                 
             }
             k=0;
             len = llGetListLength(GRAND_CHILDREN);
             for(k=0;k<len;k++){
                 key hex=llList2Key(GRAND_CHILDREN,k);
                 llRegionSayTo(hex,SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "die"+HEX_CONFIG_SEPARATOR+CONFIG);
             }
                 
             llSleep(2);
            llDie(); // You should always do this once you're finished.
        }
    }
    listen(integer channel, string name, key id, string message) {
        list data = llParseString2List(message, ["|"], []);
        string command = llList2String(data, 0);
        debug("************************** command is: "+command);
        if (command=="rezzed grandchild"){
               debug("a grandchild.. ");
               key grandchild=llList2Key(data,1);
            llListen(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "",grandchild, "");
            if (llListFindList(GRAND_CHILDREN,[grandchild])==-1){
                GRAND_CHILDREN+=grandchild;
            }
            debug("\n\n\n\nYay! a grandchild! listening to "+llList2CSV(GRAND_CHILDREN));

        }
        if (channel==SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST){
            if (command=="GET CONFIG"){
                   debug("sending config data");
                   llRegionSayTo(id,SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "receive config"+HEX_CONFIG_SEPARATOR+CONFIG);
                
            }else
            if (command=="LOAD QUIZ"){
                key user_key = llList2Key(data,1);
                debug("received load quiz - current question is: "+(string)current_question+ " num questions is : "+(string)num_questions);
                if (current_question>=num_questions){
                	  
                    if (doRepeat==TRUE){
                        current_question=0;
                        QUESTIONS_ASKED=[];
                    }else{
                        //TODO finish quiz for all avatars
                        sloodle_translation_request (SLOODLE_TRANSLATE_DIALOG, [1 , "Ok"], "no_more_questions" , ["Ok"], user_key , "hex_quizzer");
                        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "no_more_questions", [], user_key, "hex_quizzer");
                        llRegionSayTo(id,SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "die no more questions");
                        return;
                    }
                    
                }
                integer question_id = llList2Integer(question_ids,current_question);
                QUESTIONS_ASKED+=question_id;
                current_question++;
                debug("sending quiz data");
                debug("sending: "+"receive quiz data"+HEX_CONFIG_SEPARATOR+QUIZ_DATA+"|"+(string)question_id+"|"+(string)current_question);
                llRegionSayTo(id,SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "receive quiz data"+HEX_CONFIG_SEPARATOR+QUIZ_DATA+"|"+(string)question_id+"|"+(string)current_question);
                
            }
         }
            
    }
}

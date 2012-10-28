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
*  rezzer_platform.lslp
*  This script is responsible for:

*  *** requesting a question from the master hexagn and loading the options as texture maps on the child prims (pie_slices)
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
string HEX_CONFIG_SEPARATOR="*^*^*^";
float edge_length;
key ROOT_HEX;
list QUESTIONS_ASKED;
integer QUESTION_TIMER_ACTIVE=FALSE;
integer TIME_LIMIT;
integer doRepeat;
integer doRandomize;
integer master_listener;
string qstring;
integer doPlaySound;
integer NO_REZ_ZONE;
list ORBS_TOUCHED;
list last_detection;
integer pie_slice_num;
string QUIZ_DATA_str;
key MASTERS_KEY=NULL_KEY;
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
float edge_length_half;
float tip_to_edge;
list rezzed_hexes;
list opids;
integer PIN=7961;
integer quiz_id;
string quiz_name;
string DELIMITER="*%*%*";
integer question_id;
integer current_question;
list question_ids;
integer num_questions;
list  sides_rezzed;
string sloodlehttpvars;
string  SEPARATOR="****";
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG = -1639271126; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE= -1639277008;
integer SLOODLE_CHANNEL_ANIM= -1639277007;
        integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.
integer SLOODLE_SET_TEXTURE= -1639277010; 
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

integer TIMES_UP=TRUE;
integer num_options=0;
list CORRECT_AVATARS;
list DETECTED_AVATARS;
list DETECTED_AVATARS_POSITION;
list DETECTED_AVATARS_OP_IDS;
list DETECTED_AVATARS_SCORE_CHANGE;
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
list current_avatars_over_pie_slices;
string qdialogtext;
list qdialogoptions;
list option_points;
debug (string message ){
     list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
     if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 
string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
}

//rezzes a hexagon at the indicated orb#
rez_hexagon(integer orb){
    if (llGetListLength(QUESTIONS_ASKED)>=num_questions){
        //quiz finished
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "no_more_questions", [], NULL_KEY, "hex_quizzer");
        return;
     }
     integer my_oposite_section;
     vector my_coord= llGetPos();
     if (orb==0){
         return;
     }
     float adjustment_x = 0.0402;
     float adjustment_y = -0.0365;
     vector child_coord=my_coord;
     integer DIVISER=1;
     if (orb==1){//yellow
        child_coord.x=my_coord.x + edge_length + edge_length/2;
        child_coord.y=my_coord.y -tip_to_edge;  
        my_oposite_section=4;                              
     }else
     if (orb==2){//pink
        child_coord.x=my_coord.x;
        child_coord.y=my_coord.y-tip_to_edge * 2;  
        my_oposite_section=5;
     }else
     if (orb==3){
        child_coord.x=my_coord.x - edge_length- edge_length/2;
        child_coord.y=my_coord.y - tip_to_edge; 
        my_oposite_section=6;
     }else
     if (orb==4){
        child_coord.y=my_coord.y+tip_to_edge;   
        child_coord.x=my_coord.x-edge_length-edge_length/2;
        my_oposite_section=1;
     }else 
     if (orb==5){
        child_coord.x=my_coord.x;
        child_coord.y=my_coord.y+ tip_to_edge * 2; 
        my_oposite_section=2;
     }else
     if (orb==6){
        child_coord.x=my_coord.x+ edge_length+edge_length/2;
        child_coord.y=my_coord.y+tip_to_edge; 
        my_oposite_section=3;
     }
    // child_coord.x=child_coord.x+ adjustment_x;
    // child_coord.y=child_coord.y+ adjustment_y;
    //rez a new hexagon, and pass my_oppsosite_section as the start_parameter so that the new hexagon wont rez on that the my_oposite_section edge
    llRezAtRoot(llGetObjectName(), child_coord, ZERO_VECTOR,  llGetRot(), my_oposite_section);
}
set_all_pie_slice_hover_text(string msg){
    current_avatars_over_pie_slices=[];
    current_avatars_over_pie_slices+=" ";
    integer pie_slice_num;
     for (pie_slice_num=1;pie_slice_num<=6;pie_slice_num++){
         sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [ORANGE, 1.0,get_prim("option"+(string)pie_slice_num)], "option", [msg], "", "hex_quizzer");
         current_avatars_over_pie_slices+=msg;
     }
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

display_questions(string str,key id){

               
                list data= llParseString2List(str, ["|"], []);
                string qdialogtext = llList2String(data,0);
                debug("displaying questions "+qdialogtext);
                qdialogtext = strReplace(llList2String(data,0), ",", DELIMITER);
                  
                key hex = llList2Key(data,1);
                list qdialogoptions= llParseString2List(llList2String(data,2), [","], []);
                option_points= llParseString2List(llList2String(data,3), [","], []);
                debug("---------------received question! str: \nqdialogtext: "+qdialogtext+"\nhex: "+(string)hex+"\nqdialogoptions: "+llList2CSV(qdialogoptions)+"\noptionpoints: "+llList2CSV(option_points));
              //  debug("displaying question text: "+qdialogtext);
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [ORANGE, 1.0,get_prim("question_prim")], "option", [qdialogtext], "", "hex_quizzer");
                key user_key=id;
                integer j=0;
                //set the hover text of the pie_slices to the questions options
                num_options=llGetListLength(qdialogoptions); 
                options=[];
                set_texture_pie_slices("blank_white");
                for (j=0;j<num_options;j++){
                     string pie_slice=llStringTrim(llList2String(MY_SLICES,j),STRING_TRIM);
                     string option = llList2String(qdialogoptions,j);
                     options+=pie_slice;//opid has already been stored
                    //SET PIE_SLICE TO PARTICULAR OPTION
                     set_texture_pie_slice((string)option,(integer)pie_slice);
                }
              //  debug("\n\n\n\n\n\n------------------------------------------------ starting timer sending timelimit: "+(string)TIME_LIMIT);
                llMessageLinked(LINK_SET, SLOODLE_TIMER_RESTART,(string)TIME_LIMIT, "");
               /* for (j=1;j<=6;j++){
                    integer value = pie_slice_value(j);
                    integer prim_link=get_prim("pie_slice"+(string)j);
                    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [YELLOW, 1.0,prim_link], "option", [value], "", "hex_quizzer");
                    debug("value for "+"pie_slice"+(string)j+" is: "+(string)value);
                }*/
                
}

integer pie_slice_option_index(integer pie_slice){
    integer option_index = llListFindList(options, [pie_slice]);
    integer index;
    if (option_index==-1){//here the user is standing on a pie_slice that did not even have a number printed on it, so give them a 0 for incorrect 
        index=-1;
    }else{//ok, good, the pie_slice they are standing on actually has a grade assigned to it
        //find how many points the pie_slice is worth  
        index = llList2Integer(opids,option_index);           
    }
    return index;
}
/*
*  This function will determine how much a particular pie_slice is worth. 
*
*
*/
integer pie_slice_value(integer pie_slice){
    /*
    * ex. check_correct(pie_slice6)
    * here a the program is searching to see if pie_slice 6 is in the options list.
    * If it is, find out which option it is. the index of this list is the actual option id.
    * We can use the option id (option index) to find out if it is worth any points, by examining the options_points list
    */    
    integer option_index = llListFindList(options, [pie_slice]);
    integer grade;
    if (option_index==-1){//here the user is standing on a pie_slice that did not even have a number printed on it, so give them a 0 for incorrect 
        grade=-1;
    }else{//ok, good, the pie_slice they are standing on actually has a grade assigned to it
        //find how many points the pie_slice is worth  
        grade = llList2Integer(option_points,option_index);           
    }
    return grade;
}
set_texture_pie_slices(string texture){
            //clear the rest of the prims
            integer j;
            for (j=1;j<=6;j++){
                integer face=4;
                if (j==1||j==2||j==3){
                    face = 1;
                }
                llMessageLinked(LINK_SET, SLOODLE_SET_TEXTURE, "pie_slice"+(string)j+"|"+(string)face+"|"+texture,NULL_KEY);
            }

} 
set_texture_pie_slice(string texture,integer pie_slice){
            //clear the rest of the prims
            integer face=4;
            if (pie_slice==1||pie_slice==2||pie_slice==3){
                face = 1;
            }
            
         //   debug("sending message on "+(string)SLOODLE_SET_TEXTURE+" "+ "pie_slice"+llStringTrim((string)pie_slice,STRING_TRIM)+"|"+(string)face+"|"+llStringTrim(texture,STRING_TRIM));
            llMessageLinked(LINK_SET, SLOODLE_SET_TEXTURE, "pie_slice"+llStringTrim((string)pie_slice,STRING_TRIM)+"|"+(string)face+"|"+llStringTrim(texture,STRING_TRIM),NULL_KEY);
            

}
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
        }
    }
    return prim;
}

// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}
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
            else if (name == "set:questiontimelimit") TIME_LIMIT= (integer)value1;
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
init(){
    //get the dimensions of a pie_slice so we can determin the length of the sides of a pieslice.  In this case, we will choose pie_slice6 (they all have same dimensions)
        integer pie_slice6 = get_prim("pie_slice6");
        list pie_slice_data = llGetLinkPrimitiveParams(pie_slice6, [PRIM_SIZE] );
        vector pie_slice_size=llList2Vector(pie_slice_data, 0);
        tip_to_edge = pie_slice_size.z;//since we are looking for the length starting from the tip of the pie_slice to the middle of the edge, we need to choose the z dimension for this particular pie slice
        edge_length= pie_slice_size.y;//since we are looking for  the length of an edge we need to choose the y dimension for this particular pie slice
        question_prim= get_prim("question_prim");
        MY_SLICES=[1,2,3,4,5,6];
        MY_SLICES=llListRandomize(MY_SLICES, 1);//randomize list of pie slices so we can dont display the question options over the same pie_slices each time
        string name=llGetObjectName();
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "orb hide|0,1,2,3,4,5,6|10", NULL_KEY);
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [YELLOW, 1.0,question_prim], "initquiz", [], "", "hex_quizzer");
        set_texture_pie_slices("blank_white");
        integer num_prims = llGetNumberOfPrims();
        integer i=0;
        //clear text
        for (i=0;i<num_prims;i++){
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [GREEN, 1.0,i], "clear", [" "], "", "hex_quizzer");
        }
       
            
}

default {
    on_rez(integer start_param){
      llResetScript();
    }
    state_entry() {
        llTriggerSound("SND_SITAR_1", 1);
        init();
      //  debug("default state");
        llTriggerSound("SND_STARTING_UP", 1);
        master_listener=llListen(SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "", "", "");
       
          debug("asking for config");
        llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "GET CONFIG");
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [YELLOW, 1.0,get_prim("question_prim")], "requesting_config", [], "", "hex_quizzer");
        
        llMessageLinked(LINK_SET,SLOODLE_TIMER_RESTART, (string)5+"||requesting config", "");
        
    }
    touch_start(integer num_detected) {
        debug("asking for config");
        llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "GET CONFIG");
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [YELLOW, 1.0,get_prim("question_prim")], "requesting_config", [], "", "hex_quizzer");
        llMessageLinked(LINK_SET,SLOODLE_TIMER_RESTART, (string)5+"||requesting config", "");
    }
    link_message(integer sender_num, integer channel, string str, key id) {
                if (channel==SLOODLE_TIMER_TIMES_UP){
                    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [RED, 1.0,get_prim("question_prim")], "failedtoloadconfig", [], "", "hex_quizzer");
                    llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "GET CONFIG");
                     llMessageLinked(LINK_SET,SLOODLE_TIMER_RESTART, (string)5+"||requesting config", "");
                }
        }
     listen(integer channel, string name, key id, string message) {
       //  debug("heard something: "+message);
        if (channel==SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE){
            list data=llParseString2List(message, [HEX_CONFIG_SEPARATOR], []);
            string command = llList2String(data,0);
            if (MASTERS_KEY==NULL_KEY){
                MASTERS_KEY= id;
                //we now have the master's key, so stop listening to all other keys on the SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE channel
                //and only listen to the master on this channel from now on.
                llListenRemove(master_listener);
                master_listener=llListen(SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "", MASTERS_KEY, "");
            }
            if (command=="receive config"){
               // llTriggerSound("SND_FAX", 1);
                llMessageLinked(LINK_SET, SLOODLE_TIMER_RESET, "", NULL_KEY);
                
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [YELLOW, 1.0,get_prim("question_prim")], "receivingconfig", [], "", "hex_quizzer");
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [RED, 1.0,get_prim("timer_prim")], "option", [" "], "", "hex_quizzer");
                //debug("received config: "+message);
                string config = llList2String(data,1);
                // Split the message into lines
                list lines = llParseString2List(message, ["\n"], []);
                integer numlines = llGetListLength(lines);
                integer i = 0;
                for (i=0; i < numlines; i++) {
                    isconfigured = sloodle_handle_command(llList2String(lines, i));
                }
                // If we've got all our data AND reached the end of the configuration data (eof), then move on
                if (eof == TRUE) {
                    if (isconfigured == TRUE) {
                        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");
                        state ready;
                     } else {
                         // Go all configuration but, it's not complete... request reconfiguration
                        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [llGetScriptName()], NULL_KEY, "");
                        eof = FALSE;
                        }
                    }
                } 
            }
        }
    } 
    state ready{
        on_rez(integer start_param){
            llResetScript();
            }
            state_entry() {
                debug("ready state");
                sloodlehttpvars = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
                sloodlehttpvars += "&sloodlepwd=" + sloodlepwd;
                sloodlehttpvars += "&sloodlemoduleid=" + (string)sloodlemoduleid;
                sloodlehttpvars += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [YELLOW, 1.0,get_prim("question_prim")], "loadingquiz", [], "", "hex_quizzer");
                llMessageLinked(LINK_SET,SLOODLE_TIMER_RESTART, (string)5+"|", "");
                llListen(SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "", MASTERS_KEY, "");                
                llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "LOAD QUIZ");
               // debug("sending to"+(string)MASTERS_KEY+" : LOAD QUIZ");
            }
            touch_start(integer num_detected) {
                llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "LOAD QUIZ");
                
            }
            link_message(integer sender_num, integer channel, string str, key id) {
                if (channel==SLOODLE_TIMER_TIMES_UP){
                    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [RED, 1.0,get_prim("question_prim")], "failedtoloadquiz", [], "", "hex_quizzer");
                       llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "LOAD QUIZ");
                       llMessageLinked(LINK_SET,SLOODLE_TIMER_RESTART, (string)5+"|", "");
                       
                }
            }
            listen(integer channel, string name, key id, string message) {
            if (channel==SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE){
               // debug("got quiz data from server: "+message);
                list data=llParseString2List(message, [HEX_CONFIG_SEPARATOR], []);
                string command = llList2String(data,0);
              //  debug("Command: "+command);
                if (command=="receive quiz data"){
                 //   llTriggerSound("SND_FAX_2", 1);
                 //   llTriggerSound("SND_FAX", 1);
                    llMessageLinked(LINK_SET, SLOODLE_TIMER_RESET, "", NULL_KEY);
                    QUIZ_DATA_str= llList2String(data,1);
                    list quiz_data =llParseString2List(QUIZ_DATA_str, ["|"], []);
                    quiz_id=llList2Integer(quiz_data,0);
                    
                      quiz_name=llList2String(quiz_data,1);
                      num_questions=llList2Integer(quiz_data,2);
                      question_ids=llParseString2List(llList2String(quiz_data,3), [","], []);
                      question_id =llList2Integer(quiz_data,4); 
                      current_question=llList2Integer(quiz_data,5);
                     // debug("quiz_name: "+(string)quiz_name);
                    //  debug("num_questions: "+(string)num_questions);
                     // debug("question_id: "+(string)question_id);
                     // debug("current_question: "+(string)current_question);
                    //  debug("question_ids: "+(string)llList2String(quiz_data,3));

                    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [GREEN, 1.0,get_prim("question_prim")], "quizloaded", [], "", "hex_quizzer");
                    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [RED, 1.0,get_prim("timer_prim")], "option", [" "], "", "hex_quizzer");
                    qstring=(string)question_id+"|";
                    qstring+=(string)current_question+"|";
                    qstring+=(string)num_questions+"|";
                    qstring+=(string)current_question+"|";
                    qstring+=(string)llGetKey()+"|";
                    qstring+=sloodleserverroot+sloodle_quiz_url+"|";
                    qstring+=sloodlehttpvars;
                    quiz_loaded=TRUE;
                    state quizzing;
                    
                }  
                
                
                
            }
         } 
    }//state
    
    state quizzing{
        on_rez(integer start_param){
            llResetScript();
        }
        state_entry() {
        	set_all_pie_slice_hover_text(" ");
        	llSensorRepeat("", "", AGENT, edge_length, TWO_PI, 1);
        	llListen(1, "", llGetOwner(), "");
            debug("quizzing state");
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [GREEN, 1.0,get_prim("question_prim")], "ready_click_colored_orb", [], "", "hex_quizzer");
            sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [RED, 1.0,get_prim("timer_prim")], "option", [" "], "", "hex_quizzer");
            
        }
        listen(integer channel, string name, key id, string message) {
        	TIME_LIMIT=(integer)message;
        	llSay(0,"new time limit is: "+(string)TIME_LIMIT);
        }
        touch_start(integer num_detected) {
            if (TIMES_UP){//re-ask question
                //set TIMES_UP to false to prevent the re-asking of the question when timer is already counting down
                TIMES_UP=FALSE;
                //clear all hover text over pie slices to                 
                set_all_pie_slice_hover_text(" ");
                //request a question for first toucher 
                llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG,qstring,llDetectedKey(0));
                //set hovertext over central orb to load question
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [YELLOW, 1.0,get_prim("question_prim")], "loadingquestion", [" "], "", "hex_quizzer");
                
            }
        }
                
    
    link_message(integer link_set, integer channel, string str, key id) {
        list data= llParseString2List(str, ["|"], []);
        if (channel ==SLOODLE_CHANNEL_USER_TOUCH){
             //this script receives touch events from orbs sitting on the edge of the pie_slise         
            string type = llList2String(data,0);
            if (type!="orb"){
                 return;
            }
               // a user touched an edge selector, so rez an edge                 
            integer orb=llList2Integer(data, 1);                
            //check if toucher is permitted to rez an orb
            debug("received user touch: "+(string)id);
            debug("sending dialog message to user: "+(string)id);
            if (llListFindList(CORRECT_AVATARS, llKey2Name(id))!=-1){
                if (llListFindList(ORBS_TOUCHED,[orb])==-1){
                    rez_hexagon(orb);
                    ORBS_TOUCHED+=orb;
                }
                else{
                    sloodle_translation_request (SLOODLE_TRANSLATE_DIALOG, [1 , "Ok"], "rez_hex_denied_already_rezzed" , ["Ok"], id , "hex_quizzer");
                }
                
                //after a user presses an edge selector, hide the selector
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "orb hide|"+(string)orb, NULL_KEY);
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "rez_hex_granted", [llKey2Name(id)], id, "hex_quizzer");
                
            }else{
                
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "rez_hex_denied", [llKey2Name(id)], id, "hex_quizzer");
                sloodle_translation_request (SLOODLE_TRANSLATE_DIALOG, [1 , "Ok"], "rez_hex_denied" , ["Ok"], id , "hex_quizzer");
            }
        }else 
        if (channel==SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR){
            //user has either clicked the central orb, and this message has returned from other scripts, or this is the first time the question has been
            //asked and we need to populate pie_slices with options
            key hex = llList2Key(data,1);
          //  debug("SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR");
            opids=llParseString2List(llList2String(data,6),[","],[]);
            if (hex==llGetKey()){
                //get the question id
                question_id =llList2Integer(data,5);
                if (llListFindList(QUESTIONS_ASKED, [question_id])==-1){
                    QUESTIONS_ASKED+=question_id;
                }//if 
                llMessageLinked(LINK_SET,SLOODLE_TIMER_RESTART, (string)TIME_LIMIT+"|"+"SND_BUZZER|QUESTION TIME LIMIT REACHED", "");
                QUESTION_TIMER_ACTIVE=TRUE; 
                quiz_loaded=TRUE;
                display_questions(str,id);
                
                
            }//if
        }else
        if (channel==SLOODLE_TIMER_TIMES_UP){
            integer p;
            QUESTION_TIMER_ACTIVE=FALSE;
             for (p=1;p<=6;p++){
                   llSetLinkAlpha(get_prim("pie_slice"+(string)p), .5, ALL_SIDES );
            }
            //gets triggered when after a countdown and time is up
            //if (str=="QUESTION TIME LIMIT REACHED"){
                debug("times up! QUESTION TIME LIMIT REACHED");
                
                debug("times up! "+str);
            	debug("DETECTED_AVATARS "+llList2CSV(DETECTED_AVATARS));
            	debug("DETECTED_AVATARS_SCORE_CHANGE "+llList2CSV(DETECTED_AVATARS_SCORE_CHANGE));
            	debug("CORRECT_AVATARS "+llList2CSV(CORRECT_AVATARS));
            
                llTriggerSound("SND_BUZZER", 1);
                //set times up to true so that a user can re-touch the central orb to re-ask the question 
                    TIMES_UP=TRUE;
                 //clear pie slice hover text
                    set_all_pie_slice_hover_text(" ");
                //process all the avatars that were detected while the timer was counting down
                    integer avatar; //avatar index
                    integer pie_slice_num;
                    integer num_avatars_detected=llGetListLength(DETECTED_AVATARS);
                    for (avatar=0;avatar<num_avatars_detected;avatar++){
                        key  avatar_key=llList2Key(DETECTED_AVATARS,avatar);
                        vector  avatar_pos=llList2Vector(DETECTED_AVATARS_POSITION,avatar);
                        //determine the pie_slice that the avatar was over based on their last recorded position
                            string pie_slice = get_detected_pie_slice(avatar_pos);
                        //determine the number of the pie_slice
                            pie_slice_num=(integer)llGetSubString(pie_slice, -1, -1);
                        //retrieve the opid associated with the pie_slice
                            integer opid = pie_slice_option_index(pie_slice_num);
                        //retrieve the scorechange associated with that pie_slice
                            integer score_change = pie_slice_value(pie_slice_num);
                        //Now award the users
                        if (score_change>0){
                            debug("-----correct avatar is: "+llKey2Name(avatar_key));
                            llTriggerSound("SND_WINNER", 1);
                            //avatar is correct
                                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "correct_select_orb", [llKey2Name(avatar_key)], avatar_key, "hex_quizzer");
                            //add avatar name to CORRECT_AVATARS list 
                                if (llListFindList(CORRECT_AVATARS,[llKey2Name(avatar_key)])==-1){
                                    CORRECT_AVATARS+=llKey2Name(avatar_key);
                                }//if (llListFindList(CORRECT_AVATARS,[llKey2Name(avatar_key)])!=-1)
                        }// if (score_change>0)
                        else{
                            debug("-----incorrect avatar is: "+llKey2Name(avatar_key));
                            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "incorrect_can_not_select_orb", [llKey2Name(avatar_key)], avatar_key, "hex_quizzer");
                            llPushObject(avatar_key,<0,0,100>, <0,0,-100>, TRUE);
                        }//else
                        //submit answers to the server
                            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_NOTIFY_SERVER_OF_RESPONSE,"multichoice|"+(string)question_id+"|"+(string)opid+"|"+(string)score_change, avatar_key);
                        //report to other scripts of the scorechanges
                            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR, (string)score_change+"|"+(string)llGetKey(), avatar_key);
                        //issue the command to show all of the orbs so users can click on them to rez other hexagons
                            list orbs_to_show=[];
                            integer k;
                            for (k=1;k<=6;k++){
                                if (k!=NO_REZ_ZONE){
                                    orbs_to_show+=k;    
                                }
                                
                            }    
                            
                            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "orb show|1,2,3,4,5,6|10", NULL_KEY);
                        
                            
                    }//for (avatar=0;avatar<num_avatars_detected;avatar++)
                    //print the names of the avatars who were correct overtop the orbs so users know who is allowed to click the orbs
                            integer j;
                    string correct_avatars_str= "Avatars allowed to click:\n"+strReplace(llList2CSV(CORRECT_AVATARS),",","\n");
                            debug("\n\n\n\n\ncorrect_avatars_str:"+correct_avatars_str);
                            
                            for(j=1;j<=6;j++){
                                //debug("sending message to: "+(string)get_prim("orb"+(string)j));
                                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [GREEN, 1.0,get_prim("orb"+(string)j)], "option", [correct_avatars_str], "", "hex_quizzer");
                            }//for (j=1;j<=6;j++)
            //open/close the pie_slices
            list grades=[];//retrieve the grade for each pie_slice
            for (pie_slice_num=1;pie_slice_num<=6;pie_slice_num++){
                    //sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [color, 1.0,get_prim("option"+(string)pie_slice_num)], "option", [avatar_names], "", "hex_quizzer");
                    integer grade = pie_slice_value(pie_slice_num);
                    grades+=grade;
            }//for  (pie_slice_num=1;pie_slice_num<=6;pie_slice_num++)
            //send the list of grades to the pie_slices so that they open or close.  If grade is 0 for that option, pie_slice will open
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "pie_slice|"+llList2CSV(grades), NULL_KEY);
           // debug("sending grades to pie_slices: "+llList2CSV(grades));         
            
        //    }//if (str=="QUESTION TIME LIMIT REACHED")
        }//if (channel==SLOODLE_TIMER_TIMES_UP)
    }
    sensor(integer num_avatars_detected) {
            //since this is a new sensor event, erase all recorded avatar sensed data - as the avatars may have moved to a new 
            //position before timer is up.
            if (QUESTION_TIMER_ACTIVE==TRUE){
              DETECTED_AVATARS=[];
              DETECTED_AVATARS_OP_IDS=[];
              DETECTED_AVATARS_SCORE_CHANGE=[];
              DETECTED_AVATARS_POSITION=[];
            }
            
            //go through each detected avatar and add their names to the prims they are standing in
            set_all_pie_slice_hover_text(" ");
            integer avatar;
            integer pie_slice_num;
            //Here, we will just go through all of the detected avatars and their current positions, and store the values
            //for the pie_slices they are currently hovering over (along with the associated opids).  When time is up, we will
            //examine these last known values as the players final answer.
            
             for (pie_slice_num=1;pie_slice_num<=6;pie_slice_num++){
                   llSetLinkAlpha(get_prim("pie_slice"+(string)pie_slice_num), .5, ALL_SIDES );
            }
            //reset pie_slice sounds
            
            for (avatar=0;avatar<num_avatars_detected;avatar++){
                //get detected avatar information
                    string avatar_name=llDetectedName(avatar);
                    vector avatar_pos=llDetectedPos(avatar);
                    key avatar_key = llDetectedKey(avatar);
                //get pie_slice information for the pie_slice the avatar is detected over
                    string pie_slice = get_detected_pie_slice(avatar_pos);
                    pie_slice_num=(integer)llGetSubString(pie_slice, -1, -1);
                   //play sound for avatar hoverign over a pie_slice
                   
                //change pie_slice to almost opaque for hovering avatar
                    llSetLinkAlpha(get_prim("pie_slice"+(string)pie_slice_num), .9, ALL_SIDES );
                //set text for pie_slice        
                    string pie_slice_text =llList2String(current_avatars_over_pie_slices,pie_slice_num);
                    current_avatars_over_pie_slices= llListReplaceList(current_avatars_over_pie_slices, [pie_slice_text+DELIMITER+avatar_name], pie_slice_num, pie_slice_num);
                    debug("current_avatars_over_pie_slices: "+llList2CSV(current_avatars_over_pie_slices)+ "("+(string)pie_slice_num+")");
                //DETECT WHO IS CORRECT AND INCORRECT
                    integer score_change = pie_slice_value(pie_slice_num);
                    integer opid = pie_slice_option_index(pie_slice_num);
                 //store detected avatars so we can submit scores later
                     if (QUESTION_TIMER_ACTIVE==TRUE){
	                    DETECTED_AVATARS_POSITION+=avatar_pos;
	                    DETECTED_AVATARS+=avatar_key;
	                    DETECTED_AVATARS_OP_IDS+=opid;
	                    DETECTED_AVATARS_SCORE_CHANGE+=score_change;
                     }
            }
            
            for (pie_slice_num=1;pie_slice_num<=6;pie_slice_num++){
               //get all the avatar names that are over a pie slice
                       string avatar_names=llList2String(current_avatars_over_pie_slices,pie_slice_num);
               //get all the avatar names that over a pie slice the last time this sensor ran
                       string last_avatar_names=llList2String(last_detection,pie_slice_num);
               //convert both results to a list
                       list data = llParseString2List(avatar_names, [DELIMITER], []);
                       list last_data = llParseString2List(last_avatar_names, [DELIMITER], []);
               //compare the length of both lists, if the lenght of the new data is greater than last data for this pie slice,
               //that means a new avatar has entered this pie slice so play a sound
	               if (llGetListLength(data)>llGetListLength(last_data)){
	                       llTriggerSound("SND_PIE_"+(string)pie_slice_num, 1);
	               }
               //print names on pie slice hover text
                    sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM, [YELLOW, 1.0,get_prim("option"+(string)pie_slice_num)], "option", [avatar_names], "", "hex_quizzer");
                        
            }
            //save the sensor event data
            last_detection = current_avatars_over_pie_slices;
                
          
    }
    
     object_rez(key platform) {
        //a new hex was rezzed, listen to the new hex platform
              llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "rezzed grandchild"+"|"+platform);
            rezzed_hexes+=platform;
            llGiveInventory(platform, llGetObjectName());
            debug("giving platform script");
            //since llRemoteLoadScriptPin makes a script sleep for 3 seconds, we need to offload the remote loading of the scripts to a seperate loader script
            llRemoteLoadScriptPin(platform, "sloodle_translation_hex_quizzer_en",PIN, TRUE, 0);
            llRemoteLoadScriptPin(platform, "_platform.lslp",PIN, TRUE, 0);
            //tell mother hex we rezzed a grandchild!  Mother will be happy!  we need to do this so that the mother hex will listen to her grandchildren when they are requesting questions
            

    } 

    
   
}

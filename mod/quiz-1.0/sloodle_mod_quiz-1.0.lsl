// LSL script generated: mod.quiz-1.0.sloodle_mod_quiz-1.0.lslp Mon Aug 29 13:44:56 Tokyo Standard Time 2011
/* Sloodle quiz chair

	Copyright (c) 2006-9 Sloodle (various contributors)
    Released under the GNU GPL
    

	This files lists all the status codes we use for sloodle.
	They have been written in LSL format so that you can plunk them into your source
	code if needed. 

	Contributors:
    Edmund Edgar
    Paul Preibisch
    
   
	
*/
      
        key null_key = NULL_KEY;
        integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST = -1828374651;
        integer doRepeat = 0;
        integer doDialog = 1;
        integer doPlaySound = 1;
        integer doRandomize = 1;
        
        string sloodleserverroot = "";
        integer sloodlecontrollerid = 0;
        string sloodlepwd = "";
        integer sloodlemoduleid = 0;
        integer sloodleobjectaccessleveluse = 0;
        integer sloodleserveraccesslevel = 0;
        
        integer isconfigured = FALSE;
        integer eof = FALSE;
        integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
       
 
        integer SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR = -1639271102;
        integer SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR = -1639271103;
        integer SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR = -1639271104;
        integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105;
        integer SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION = -1639271111;
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION = -1639271112;
        integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113;
		integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_DEFAULT = -1639271114;
		integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_READY = -1639271115;
		integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_CHECK_QUIZ = -1639271116;
		integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING = -1639271117;
		integer SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE = -1639271118;
        integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
        integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
        string SLOODLE_EOF = "sloodleeof";
        
        string sloodle_quiz_url = "/mod/sloodle/mod/quiz-1.0/linker.php";
                        
        key httpquizquery = null_key;
        
        float request_timeout = 20.0;
        
        // ID and name of the current quiz
        integer quizid = -1;
        string quizname = "";
        // This stores the list of question ID's (global ID's)
        list question_ids = [];
        integer num_questions = 0;
        // Identifies the active question number (index into question_ids list)
        // (Next question will always be this value +1)
        integer active_question = -1;

        // Avatar currently using this cahir
        key sitter = null_key;
        // The position where we started. The Chair will use this to get the lowest vertical position it used.
        vector startingposition;
        
        // Stores the number of questions the user got correct on a given attempt
        integer num_correct = 0;
        
        ///// TRANSLATION /////
        
        // Link message channels
        integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
        string SLOODLE_TRANSLATE_SAY = "say";
        string SLOODLE_TRANSLATE_IM = "instantmessage";
        
        
        ///// FUNCTIONS /////
        /******************************************************************************************************************************
        * sloodle_error_code - 
        * Author: Paul Preibisch
        * Description - This function sends a linked message on the SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST channel
        * The error_messages script hears this, translates the status code and sends an instant message to the avuuid
        * Params: method - SLOODLE_TRANSLATE_SAY, SLOODLE_TRANSLATE_IM etc
        * Params:  avuuid - this is the avatar UUID to that an instant message with the translated error code will be sent to
        * Params: status code - the status code of the error as on our wiki: http://slisweb.sjsu.edu/sl/index.php/Sloodle_status_codes
        * Params: a message from the server to use if there is none listed in the linker script.        
        *******************************************************************************************************************************/
        sloodle_error_code(string method,key avuuid,integer statuscode,string msg){
    llMessageLinked(LINK_SET,SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST,((((((method + "|") + ((string)avuuid)) + "|") + ((string)statuscode)) + "|") + ((string)msg)),NULL_KEY);
}sloodle_debug(string msg){
    llMessageLinked(LINK_THIS,DEBUG_CHANNEL,msg,null_key);
}
		/******************************************************************************************************************************
        * clearUserQuizData- 
        * Description - resets the quiz chair data.  Used if a user jumps off a quiz chair.  Resets data for next user
        *******************************************************************************************************************************/
		clearUserQuizData(){
    (quizname = "");
    (question_ids = []);
    (num_questions = 0);
    (active_question = (-1));
    if (doRandomize) (question_ids = llListRandomize(question_ids,1));
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
    else  if ((name == "set:sloodleobjectaccessleveluse")) (sloodleobjectaccessleveluse = ((integer)value1));
    else  if ((name == "set:sloodleserveraccesslevel")) (sloodleserveraccesslevel = ((integer)value1));
    else  if ((name == "set:sloodlerepeat")) (doRepeat = ((integer)value1));
    else  if ((name == "set:sloodlerandomize")) (doRandomize = ((integer)value1));
    else  if ((name == "set:sloodledialog")) (doDialog = ((integer)value1));
    else  if ((name == "set:sloodleplaysound")) (doPlaySound = ((integer)value1));
    else  if ((name == SLOODLE_EOF)) (eof = TRUE);
    return ((((sloodleserverroot != "") && (sloodlepwd != "")) && (sloodlecontrollerid > 0)) && (sloodlemoduleid > 0));
}
        
        // Checks if the given agent is permitted to user this object
        // Returns TRUE if so, or FALSE if not
        integer sloodle_check_access_use(key id){
    if ((sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_GROUP)) {
        return llSameGroup(id);
    }
    else  if ((sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC)) {
        return TRUE;
    }
    return (id == llGetOwner());
}

        
        // Report completion to the user
        finish_quiz(){
    sloodle_translation_request(SLOODLE_TRANSLATE_IM,[0],"complete",[llKey2Name(sitter),((((string)num_correct) + "/") + ((string)num_questions))],sitter,"quiz");
    string body = ("sloodlecontrollerid=" + ((string)sloodlecontrollerid));
    (body += ("&sloodlepwd=" + sloodlepwd));
    (body += ("&sloodlemoduleid=" + ((string)sloodlemoduleid)));
    (body += ("&sloodleuuid=" + ((string)sitter)));
    (body += ("&sloodleavname=" + llEscapeURL(llKey2Name(sitter))));
    (body += ("&sloodleserveraccesslevel=" + ((string)sloodleserveraccesslevel)));
    (body += "&finishattempt=1");
    llHTTPRequest((sloodleserverroot + sloodle_quiz_url),[HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],body);
    llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR,((((string)num_correct) + "/") + ((string)num_questions)),sitter);
}
        
        // Reinitialise (e.g. after one person has finished an attempt)
        reinitialise(){
    sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"resetting",[],null_key,"");
    llMessageLinked(LINK_THIS,SLOODLE_CHANNEL_OBJECT_DIALOG,"do:requestconfig",null_key);
    llResetScript();
}
        
        // Send a translation request link message
        
        sloodle_translation_request(string output_method,list output_params,string string_name,list string_params,key keyval,string batch){
    llMessageLinked(LINK_THIS,SLOODLE_CHANNEL_TRANSLATION_REQUEST,((((((((output_method + "|") + llList2CSV(output_params)) + "|") + string_name) + "|") + llList2CSV(string_params)) + "|") + batch),keyval);
}
        
        ///// ----------- /////
        
        
        ///// STATES /////
        
        // Waiting on initialisation
        default {

            state_entry() {
        llSetText("",<0.0,0.0,0.0>,0.0);
        (isconfigured = FALSE);
        (eof = FALSE);
        (sloodleserverroot = "");
        (sloodlepwd = "");
        (sloodlecontrollerid = 0);
        (sloodlemoduleid = 0);
        (sloodleobjectaccessleveluse = 0);
        (sloodleserveraccesslevel = 0);
        (doRepeat = 1);
        (doDialog = 1);
        (doPlaySound = 1);
        (doRandomize = 1);
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_DEFAULT,llGetScriptName(),NULL_KEY);
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
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"configurationreceived",[],null_key,"");
                    state ready;
                }
                else  {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"configdatamissing",[],null_key,"");
                    llMessageLinked(LINK_THIS,SLOODLE_CHANNEL_OBJECT_DIALOG,"do:reconfigure",null_key);
                    (eof = FALSE);
                }
            }
        }
    }

            
            touch_start(integer num_detected) {
        if ((llDetectedKey(0) == llGetOwner())) {
            llMessageLinked(LINK_THIS,SLOODLE_CHANNEL_OBJECT_DIALOG,"do:requestconfig",null_key);
        }
    }
}
        
        
        // Ready state - waiting for a user to climb aboard!
        state ready {

            state_entry() {
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_READY,llGetScriptName(),NULL_KEY);
    }

            
            // Wait for the script that handles the sitting to tell us that somebody has sat on us.
            // Normally a sit will immediately produce a link message
            // But variations on the script may do things differently, 
            // eg. the awards script doesn't want to start the quiz until it's got a Game ID
            link_message(integer sender_num,integer num,string str,key id) {
        if ((num == SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR)) {
            (sitter = id);
            if ((!sloodle_check_access_use(sitter))) {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"nopermission:use",[llKey2Name(sitter)],null_key,"");
                llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE,"",sitter);
                (sitter = null_key);
                return;
            }
            (startingposition = llGetPos());
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"starting",[llKey2Name(sitter)],null_key,"quiz");
            state check_quiz;
        }
    }


            on_rez(integer par) {
        llResetScript();
    }
}
        
        
        // Fetching the general quiz data from the server
        state check_quiz {

            state_entry() {
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_CHECK_QUIZ,"",NULL_KEY);
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"fetchingquiz",[],null_key,"quiz");
        clearUserQuizData();
        string body = ("sloodlecontrollerid=" + ((string)sloodlecontrollerid));
        (body += ("&sloodlepwd=" + sloodlepwd));
        (body += ("&sloodlemoduleid=" + ((string)sloodlemoduleid)));
        (body += ("&sloodleuuid=" + ((string)sitter)));
        (body += ("&sloodleavname=" + llEscapeURL(llKey2Name(sitter))));
        (body += ("&sloodleserveraccesslevel=" + ((string)sloodleserveraccesslevel)));
        (httpquizquery = llHTTPRequest((sloodleserverroot + sloodle_quiz_url),[HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],body));
        llSetTimerEvent(0.0);
        llSetTimerEvent(((float)request_timeout));
    }

            
            state_exit() {
        llSetTimerEvent(0.0);
    }

            
            timer() {
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"httptimeout",[],null_key,"");
        state ready;
    }

            
            http_response(key id,integer status,list meta,string body) {
        if ((id != httpquizquery)) return;
        (httpquizquery = null_key);
        if ((status != 200)) {
            sloodle_error_code(SLOODLE_TRANSLATE_SAY,NULL_KEY,status,"");
            state default;
        }
        list lines = llParseString2List(body,["\n"],[]);
        integer numlines = llGetListLength(lines);
        (body = "");
        list statusfields = llParseStringKeepNulls(llList2String(lines,0),["|"],[]);
        integer statuscode = ((integer)llStringTrim(llList2String(statusfields,0),STRING_TRIM));
        if ((statuscode == (-10301))) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"noattemptsleft",[llKey2Name(sitter)],null_key,"");
            state ready;
            return;
        }
        else  if ((statuscode == (-10302))) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"noquestions",[],null_key,"");
            state ready;
            return;
        }
        else  if ((statuscode <= 0)) {
            string msg;
            if ((numlines > 1)) {
                (msg = llList2String(lines,1));
            }
            sloodle_debug(msg);
            sloodle_error_code(SLOODLE_TRANSLATE_IM,sitter,statuscode,msg);
            state ready;
            return;
        }
        (statusfields = []);
        integer i;
        for ((i = 1); (i < numlines); (i++)) {
            string thislinestr = llList2String(lines,i);
            list thisline = llParseString2List(thislinestr,["|"],[]);
            string rowtype = llList2String(thisline,0);
            if ((rowtype == "quiz")) {
                (quizid = ((integer)llList2String(thisline,4)));
                (quizname = llList2String(thisline,2));
            }
            else  if ((rowtype == "quizpages")) {
                list question_ids_str = llCSV2List(llList2String(thisline,3));
                (num_questions = llGetListLength(question_ids_str));
                integer qiter = 0;
                (question_ids = []);
                for ((qiter = 0); (qiter < num_questions); (qiter++)) {
                    (question_ids += [((integer)llList2String(question_ids_str,qiter))]);
                }
                if (doRandomize) (question_ids = llListRandomize(question_ids,1));
                (active_question = 0);
            }
        }
        if (((quizname == "") || (num_questions == 0))) {
            sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"noquestions",[],null_key,"quiz");
            state default;
            return;
        }
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[0],"ready",[quizname],null_key,"quiz");
        state quizzing;
    }

            
            on_rez(integer par) {
        llResetScript();
    }

            
            changed(integer change) {
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION,((string)startingposition),sitter);
        reinitialise();
    }
}
        
        
        // Running the quiz
        state quizzing {

            on_rez(integer param) {
        llResetScript();
    }

            
            state_entry() {
        llSetText("",<0.0,0.0,0.0>,0.0);
        (num_correct = 0);
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING,"",NULL_KEY);
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION,((string)startingposition),sitter);
        if ((num_questions == 0)) {
            sloodle_debug("No questions - cannot run quiz.");
            state default;
            return;
        }
        (active_question = 0);
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR,(((string)quizid) + quizname),sitter);
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION,((string)llList2Integer(question_ids,active_question)),sitter);
        llSetTimerEvent(10.0);
    }

            
            link_message(integer sender_num,integer num,string str,key id) {
        if ((num == SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR)) {
            float scorechange = ((integer)str);
            if ((sitter != id)) {
                return;
            }
            (active_question++);
            if ((scorechange > 0)) (num_correct++);
            if ((active_question >= num_questions)) {
                finish_quiz();
                if (doRepeat) state quizzing;
                return;
            }
            llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION,((string)llList2Integer(question_ids,active_question)),sitter);
        }
        else  if ((num == SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR)) {
            llSetTimerEvent(0.0);
        }
        else  if ((num == SLOODLE_CHANNEL_OBJECT_DIALOG)) {
            if ((str == "do:reset")) {
                llResetScript();
            }
            return;
        }
    }

            
            state_exit() {
        llSetTimerEvent(0.0);
    }

            
            timer() {
        llSetTimerEvent(0.0);
        if ((active_question > (-1))) {
            llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION,((string)llList2Integer(question_ids,active_question)),sitter);
            llSetTimerEvent(10.0);
        }
    }

            
            touch_start(integer num) {
        if (((active_question + 1) < num_questions)) {
            if ((llDetectedKey(0) == sitter)) {
                llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION,((string)llList2Integer(question_ids,active_question)),sitter);
            }
        }
    }

            
            changed(integer change) {
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION,((string)startingposition),sitter);
        clearUserQuizData();
        state ready;
    }
}

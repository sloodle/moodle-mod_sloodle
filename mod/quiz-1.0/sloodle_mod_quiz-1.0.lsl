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
      
        integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
        integer doRepeat = 0; // whether we should run through the questions again when we're done
        integer doDialog = 1; // whether we should ask the questions using dialog rather than chat
        integer doPlaySound = 1; // whether we should play sound
        integer doRandomize = 1; // whether we should ask the questions in random order
        string sloodleserverroot = "";
        integer sloodlecontrollerid = 0;
        string sloodlepwd = "";
        integer sloodlemoduleid = 0;
        integer sloodleobjectaccessleveluse = 0; // Who can use this object?
        integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
        integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
        integer isconfigured = FALSE; // Do we have all the configuration data we need?
        integer eof = FALSE; // Have we reached the end of the configuration data?
        integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
        integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script. 
        integer SLOODLE_CHANNEL_AVATAR_IGNORE = -1639279999;
        integer SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR = -1639271102; //Tells us to start a quiz for the avatar, if possible.; Ordinary quiz chair will have a second script that detects and avatar sitting      on it and sends it. Awards-integrated version waits for a game ID to be set before doing this.
        integer SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR = -1639271103; //Sent by main quiz script to tell UI scripts that quiz has started for avatar with key
        integer SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR = -1639271104; //Sent by main quiz script to tell UI scripts that quiz has finished for avatar with key, with x/y correct in string
        integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text
        integer SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR = -1639271106;  //Sent by main quiz script to tell UI scripts that question has been answered by avatar with key. String contains selected option ID + "|" + option text + "|"
        integer SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION = -1639271107; 
        integer SLOODLE_CHANNEL_QUIZ_LOADED_QUESTION = -1639271108;
        integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
        integer SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ = -1639271110;
        integer SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION = -1639271111;            
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT = -1639271125; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA CHAT.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG = -1639271126; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.
        integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_DEFAULT = -1639271114; //mod quiz script is in state DEFAULT
        integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_READY = -1639271115; //mod quiz script is in state READY
        integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER = -1639271116; //mod quiz script is in state CHECK_QUIZ
        integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING = -1639271117; //mod quiz script is in state quizzing
        integer SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE= -1639271118; //user has tried to use the chair but doesnt have permission to do so.
        integer SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR = -1639271119; //Tells us to STOP a quiz for the avatar
        integer SLOODLE_CHANNEL_QUIZ_SUCCESS_NOTHING_MORE_TO_DO_WITH_AVATAR= -1639271122;
        integer SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR= -1639271123;
        integer SLOODLE_CHANNEL_QUIZ_ERROR_INVALID_QUESION = -1639271121;  //
        integer SLOODLE_CHANNEL_QUIZ_ERROR_ATTEMPTS_LEFT= -1639271123;  //
        integer SLOODLE_CHANNEL_QUIZ_ERROR_NO_QUESTIONS= -1639271124;  //          
        ///// TRANSLATION /////
        // Link message channels
        integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
        // Translation output methods
        string SLOODLE_TRANSLATE_WHISPER = "whisper";               // 1 output parameter: chat channel number
        string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
        string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
        string SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
        string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
        string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.
        integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
        integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
        integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
        string SLOODLE_OBJECT_TYPE = "quiz-1.0";
        string SLOODLE_EOF = "sloodleeof";
        string sloodle_quiz_url = "/mod/sloodle/mod/quiz-1.0/linker.php";
        key httpquizquery = NULL_KEY;
        float request_timeout = 20.0;
        string sloodlehttpvars;
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
        key sitter = NULL_KEY;
        // The position where we started. The Chair will use this to get the lowest vertical position it used.
        vector startingposition;
        
        // Stores the number of questions the user got correct on a given attempt
        integer num_correct = 0;
        
        
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
        sloodle_error_code(string method, key avuuid,integer statuscode, string msg){
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|"+(string)statuscode+"|"+(string)msg, NULL_KEY);
        }   sloodle_debug(string msg)
        {
            llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
        }        
        /******************************************************************************************************************************
        * clearUserQuizData- 
        * Description - resets the quiz chair data.  Used if a user jumps off a quiz chair.  Resets data for next user
        *******************************************************************************************************************************/
           clearUserQuizData(){
           quizname = "";
           question_ids = [];
           num_questions = 0;
           num_correct=0;
           active_question = -1;
           sitter=NULL_KEY;
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
            else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
            else if (name == "set:sloodlemoduleid") sloodlemoduleid = (integer)value1;
            else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
            else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
            else if (name == "set:sloodlerepeat") doRepeat = (integer)value1;
            else if (name == "set:sloodlerandomize") doRandomize = (integer)value1;
            else if (name == "set:sloodledialog") doDialog = (integer)value1;
            else if (name == "set:sloodleplaysound") doPlaySound = (integer)value1;
            else if (name == SLOODLE_EOF) eof = TRUE;
            
            return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0 && sloodlemoduleid > 0);
        }
        
        // Checks if the given agent is permitted to user this object
        // Returns TRUE if so, or FALSE if not
        integer sloodle_check_access_use(key id)
        {
            // Check the access mode
            if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_GROUP) {
                return llSameGroup(id);
            } else if (sloodleobjectaccessleveluse == SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC) {
                return TRUE;
            }
            
            // Assume it's owner mode
            return (id == llGetOwner());
        }

        
        // Report completion to the user
        finish_quiz() 
        {
            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "complete", [llKey2Name(sitter), (string)num_correct + "/" + (string)num_questions], sitter, "quiz");
            //move_to_start(); // Taking this out here leaves the quiz chair at its final position until the user stands up.
            
            // Notify the server that the attempt was finished
            string body = sloodlehttpvars;
            body += "&finishattempt=1";
            llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
            
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR, (string)num_correct + "/" + (string)num_questions, sitter);
            
        }
        // Send a translation request link message
        sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
        }
        ///// ----------- /////
        ///// STATES /////
        default
        {
            state_entry()
            {
                 
                // Starting again with a new configuration
                llSetText("", <0.0,0.0,0.0>, 0.0);
                isconfigured = FALSE;
                eof = FALSE;
                // Reset our configuration data
                sloodleserverroot = "";
                sloodlepwd = "";
                sloodlecontrollerid = 0;
                sloodlemoduleid = 0;
                sloodleobjectaccessleveluse = 0;
                sloodleserveraccesslevel = 0;
                doRepeat = 1;
                doDialog = 1;
                doPlaySound = 1;
                doRandomize = 1;
                //tell other scripts we are in the default state.
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_DEFAULT,llGetScriptName(), NULL_KEY);
            }
            
            link_message( integer sender_num, integer num, string str, key id)
            {
                // Check the channel for configuration messages
                if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Split the message into lines
                    list lines = llParseString2List(str, ["\n"], []);
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
                            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], NULL_KEY, "");
                            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);
                            eof = FALSE;
                        }
                    }
                }
            }
            
            touch_start(integer num_detected)
            {
                //let the administrator request re-configuration if we get stuck in this state
                // Attempt to request a reconfiguration
                if (llDetectedKey(0) == llGetOwner()) {
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
                }
            }
        }
        
        
        // Ready state - waiting for a user to climb aboard!
        state ready
        {
            state_entry()
            {
                // Clear existing data
                clearUserQuizData();
                //tell other scripts we are in the ready state                 
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_READY, "", NULL_KEY);
                // This is now handled by a separate poseball
                // llSitTarget(<0,0,.5>, ZERO_ROTATION);
            }
            
            // Wait for the script that handles the sitting to tell us that somebody has sat on us.
            // Normally a sit will immediately produce a link message
            // But variations on the script may do things differently, 
            // eg. the awards script doesn't want to start the quiz until it's got a Game ID
            link_message(integer sender_num, integer num, string str, key id)
            {
                if (num == SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR) {
                    
                    sitter = id;
                    // Make sure the given avatar is allowed to use this object
                    if (!sloodle_check_access_use(sitter)) {
                        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(sitter)], NULL_KEY, "");
                        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE, "", sitter);
                        sitter = NULL_KEY;
                        return;
                    }                
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "starting", [llKey2Name(sitter)], NULL_KEY, "quiz");                                                     
                    state load_quiz_for_user;
                }                
                
            }

            on_rez(integer par)
            {
                llResetScript();
            }            
                                                
            state_exit()
            {
                llSetTimerEvent(0.0);
            }
        }
        
        
        // Fetching the general quiz data from the server
        state load_quiz_for_user
        {
            state_entry()
            {
                 llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER, "", sitter);
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "fetchingquiz", [], NULL_KEY, "quiz");
                // Request the quiz data from Moodle
                sloodlehttpvars = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
                sloodlehttpvars += "&sloodlepwd=" + sloodlepwd;
                sloodlehttpvars += "&sloodlemoduleid=" + (string)sloodlemoduleid;
                sloodlehttpvars += "&sloodleuuid=" + (string)sitter;
                sloodlehttpvars += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
                sloodlehttpvars += "&sloodleavname=" + llEscapeURL(llKey2Name(sitter));
                httpquizquery = llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], sloodlehttpvars);
                llSetTimerEvent(0.0);
                llSetTimerEvent((float)request_timeout);
            }
            
            state_exit()
            {
                llSetTimerEvent(0.0);
            }
            
            timer()
            {
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
                state ready;
            }
            link_message(integer sender_num, integer num, string str, key id) {
                if (num == SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR){
                   state ready;
                }
            }
            http_response(key id, integer status, list meta, string body)
            {
                
                // Is this the response we are expecting?
                if (id != httpquizquery) return;
                httpquizquery = NULL_KEY;
                                    
                llSetTimerEvent(0.0);
                        
                // Make sure the response was OK
                if (status != 200) {
                        sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status, ""); //send message to error_message.lsl
                        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter);//todo add to dia
                    state ready;//todo add to dia
                }
                
                // Split the response into several lines
                list lines = llParseString2List(body, ["\n"], []);
                integer numlines = llGetListLength(lines);
                body = "";
                list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
                integer statuscode = (integer)llStringTrim(llList2String(statusfields, 0), STRING_TRIM);
                
                // Was it an error code?
                if (statuscode == -10301) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noattemptsleft", [llKey2Name(sitter)], NULL_KEY, "");
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter);//todo add to dia
                    state ready;
                    return;
                    
                } else if (statuscode == -10302) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noquestions", [], NULL_KEY, "");
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter);
                    state ready;
                    return;
                    
                } else if (statuscode <= 0) {
                    //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
                    string msg;
                    if (numlines > 1) {
                        msg = llList2String(lines, 1);
                    }
                    sloodle_debug(msg);
                      //Sloodle 2.0 Change - output custom errorcode to other scripts
                     sloodle_error_code(SLOODLE_TRANSLATE_IM, sitter,statuscode, msg); //send message to error_message.lsl                 
                    // Check if an error message was reported
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter);//add to dia
                    state ready;
                    return;
                }
                
                // We shouldn't need the status line anymore... get rid of it
                statusfields = [];
        
                // Go through each line of the response
                integer i;
                for (i = 1; i < numlines; i++) {
        
                    // Extract and parse the current line
                    string thislinestr = llList2String(lines, i);
                    list thisline = llParseString2List(thislinestr,["|"],[]);
                    string rowtype = llList2String( thisline, 0 ); 
        
                    // Check what type of line this is
                    if ( rowtype == "quiz" ) {
                        
                        // Get the quiz ID and name
                        quizid = (integer)llList2String(thisline, 4);
                        quizname = llList2String(thisline, 2);
                        
                    } else if ( rowtype == "quizpages" ) {
                        
                        // Extract the list of questions ID's
                        list question_ids_str = llCSV2List(llList2String(thisline, 3));
                        num_questions = llGetListLength(question_ids_str);
                        integer qiter = 0;
                        question_ids = [];
                        // Store all our question IDs
                        for (qiter = 0; qiter < num_questions; qiter++) {
                            question_ids += [(integer)llList2String(question_ids_str, qiter)];
                        }
                        
                        // Are we to randomize the order of the questions?
                        if (doRandomize) question_ids = llListRandomize(question_ids, 1);
                        active_question = 0;
                    }
                }
                
                // Make sure we have all the data we need
                if (quizname == "" || num_questions == 0) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noquestions", [], NULL_KEY, "quiz");
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter);//add to dia
                    state ready;//todo add to dia
                    return;
                }
                
                // Report the status to the user
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "ready", [quizname], NULL_KEY, "quiz");
                state quizzing;
            }
            
            on_rez(integer par)
            {
                llResetScript();
            }
            
            
        }
        
        
        // Running the quiz
        state quizzing
        {
            on_rez(integer param)
            {
                llResetScript();
            }
            
            state_entry()
            {
                llSetText("", <0.0,0.0,0.0>, 0.0);
                num_correct = 0;
                //tell other scripts we are quizzing
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING, "", sitter);
                // Make sure we have some questions
                if (num_questions == 0) {
                    sloodle_debug("No questions - cannot run quiz.");
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter);//add to dia
                    state ready;//todo add to dia
                    return;
                }
                
                // Start from the beginning
                active_question = 0;
                llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR, (string)quizid+"|"+quizname, sitter );
                if (doDialog==1){ //1 = true
                    llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG, llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,sitter );//todo add to dia
                }else                 
                if (doDialog==0){ //0= false
                    llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT, llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,sitter );//todo add to dia
                }                
                llSetTimerEvent( 10.0 ); // The other script should let us know that it's heard us and asked the question. If it doesn't, we'll keep on retrying until it hears us, if it ever does.
            }
            
            link_message(integer sender_num, integer num, string str, key id)
            {
                if (num == SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR){
                   state ready;
                }
                else
                if (num == SLOODLE_CHANNEL_QUIZ_ERROR_INVALID_QUESION) {//TODO add to dia
                    //send message it is done with avatar
                    llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter );//TODO add to dia
                    //go to state READY
                    state ready;//todo add to dia
                    
                }else
                if (num == SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR) {
                    
                    float scorechange = (integer)str;
                    
                    if (sitter != id) {
                        return;
                    }
                    
                 // Advance to the next question
                    active_question++; 
                    
                    if(scorechange>0) num_correct++; // SAL added this

                    // Are we are at the end of the quiz?
                    if (active_question >= num_questions) {
                        // Yes - finish off
                        finish_quiz();
                        // Do we want to repeat the quiz?
                        if (!doRepeat) {
                            llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_SUCCESS_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter );//TODO add to dia
                        }
                        
                        state quizzing;
                        return;
                    }
                    if (doDialog==1){ //1 = true
                        llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG, llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,sitter );//todo add to dia
                    }else                 
                    if (doDialog==0){ //0= false
                        llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT, llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,sitter );//todo add to dia
                    }                                                             
                    
                    
                } else if (num == SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR) {
                    
                    // Cancel the timer that we used to make sure the question script heard us and asked its question.
                    // At this point the question script should ask the question then wait for a response.
                    // If it doesn't get one, nothing will happen until the sitter touches us, and we'll ask the question script to fetch and ask the question again.
                    llSetTimerEvent(0.0);
                    
                } else if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Is it a reset command?
                    if (str == "do:reset") {
                        llResetScript();
                    }
                    return;
                }                        
                
                // TODO: What happens if loading the question fails?
            }
            
            state_exit()
            {
                llSetTimerEvent(0.0);
            }
            
            timer()
            {       
                llSetTimerEvent( 0.0 );         
                if (active_question > -1) {
                   if (doDialog==1){ //1 = true
                    llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG, llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,sitter );//todo add to dia
                   }else                 
                   if (doDialog==0){ //0= false
                       llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT, llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,sitter );//todo add to dia
                   } 
                   llSetTimerEvent( 10.0 ); // The other script should let us know that it's heard us and answered the question. If it doesn't, we'll keep on retrying until it hears us, if it ever does.
                }
            }
            
            touch_start(integer num)
            {
                if ((active_question + 1) < num_questions) {
                    if (llDetectedKey(0) == sitter) {
                        if (doDialog==1){ //1 = true
                        llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG, llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,sitter );//todo add to dia
                        }else                 
                        if (doDialog==0){ //0= false
                            llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT, llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,sitter );//todo add to dia
                        } 
                     }
                }
            }    
                             
        }
                                        

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/quiz-1.0/sloodle_mod_quiz-1.0.lsl


//
// The line above should be left blank to avoid script errors in OpenSim.

       // Sloodle quiz chair
        // Allows SL users to take Moodle quizzes in-world
        // Part of the Sloodle project (www.sloodle.org)
        //
        // Copyright (c) 2006-9 Sloodle (various contributors)
        // Released under the GNU GPL
        //
        // Contributors:
        //  Edmund Edgar
        //  Paul Preibisch
        //  Peter R. Bloomfield

        // Once configured in the usual way, this script waits for a request to ask a question in the form of a linked message with num SLOODLE_CHANNEL_QUIZ_ASK_QUESTION.
        // When the student answers the question, it sends out a linked message with num SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR.
        // Note that it doesn't handle timeouts in case the user doesn't respond - all that should be done by the calling script.
        
        integer SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR = -1639271119; //Tells us to STOP a quiz for the avatar
        integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
        integer doRepeat = 0; // whether we should run through the questions again when we're done
        integer doDialog = 1; // whether we should ask the questions using dialog rather than chat
        integer menu_channel;
        string sloodlehttpvars;
        integer answerDialogListenHandler;
        integer answerChatListenHandler;
        integer answerChatListenHandlerNonPublic;
        
        integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text
        integer SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR = -1639271106;  //Sent by main quiz script to tell UI scripts that question has been answered by avatar with key. String contains selected option ID + "|" + option text + "|"
        integer SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION = -1639271107; 
        integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.
        integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING = -1639271117; //mod quiz script is in state quizzing
        integer SLOODLE_CHANNEL_QUIZ_ERROR_INVALID_QUESION = -1639271121;  //
        integer SLOODLE_CHANNEL_QUIZ_ERROR_NO_ATTEMPTS_LEFT= -1639271123;  //
        integer SLOODLE_CHANNEL_QUIZ_ERROR_NO_QUESTIONS= -1639271124;  //          
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT = -1639271125; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA CHAT.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG = -1639271126; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
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
        string sloodle_full_quiz_url;
        key httpfetchquestionquery = NULL_KEY;
        key feedbackreq = NULL_KEY;
        float request_timeout = 20.0;
        integer question_id = -1;
        // Text and type of the current and next question
        string qtext = "";
        string qtype = "";
        // Lists of option information for the current question
        list opids = []; // IDs
        list optext = []; // Texts
        list opgrade = []; // Grades
        list opfeedback = []; // Feedback if this option is selected
        // Avatar currently using this cahir
        key sitter = NULL_KEY; 

                    
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
        sloodle_error_code(string method, key avuuid,integer statuscode){
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|"+(string)statuscode, NULL_KEY);
        }        sloodle_debug(string msg)
        {
            llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
        }        
        integer random_integer( integer min, integer max )
        {
          return min + (integer)( llFrand( max - min + 1 ) );
        }
        // Query the server for the identified question (request by global question ID)
        key request_question( integer qid )
        {
            
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION, (string)qid, sitter);            
            
            // Request the identified question from Moodle
            
            string body = sloodlehttpvars+"&ltq=" + (string)qid;
            key newhttp = llHTTPRequest(sloodle_full_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
            
            llSetTimerEvent(0.0);
            llSetTimerEvent(request_timeout);
            
            return newhttp;
        }
        
        // Query the server for the feedback for a particular choice.
        // This is only called if the server has told us that the feedback is too long to go in the regular request
        // It does this by substituting the feedback [[[LONG]]]
        key request_feedback( integer qid, string fid ) {
            // Request the identified question from Moodle
            string body = sloodlehttpvars;
            body += "&ltq=" + (string)qid;
            body += "&fid=" + (string)fid;                                    
            
            key reqid = llHTTPRequest(sloodle_full_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
            llSleep(3.0); // Hopefully the message will come back before the next question is asked. But if it comes back out of order, we won't insist.
            
            return reqid;
            
        }
        
        // Notify the server of a response
        notify_server(string qtype, integer questioncode, string responsecode, float scorechange)
        {
            string body =sloodlehttpvars;
            body += "&resp" + (string)questioncode + "_=" + responsecode;
            body += "&resp" + (string)questioncode + "_submit=1";
            body += "&questionids=" + (string)questioncode;
            body += "&action=notify";
            body += "&scorechange="+(string)scorechange;
            
            llHTTPRequest(sloodle_full_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        }
        
        
        // Ask the current question
        ask_question() 
        {     
                                  
            // Are we using dialogs?
            if (doDialog == 1) {
                
                // We want to create a dialog with the option texts embedded into the main text,
                //  and numbers on the buttons
                integer qi;
                list qdialogoptions = [];
                
                string qdialogtext = qtext + "\n";
                // Go through each option
                integer num_options = llGetListLength(optext);
                
                if ((qtype == "numerical")|| (qtype == "shortanswer")) {
                   // Ask the question via IM
                   llInstantMessage(sitter, qtext);
                } else {
                    for (qi = 1; qi <= num_options; qi++) {
                        // Append this option to the main dialog (remebering buttons are 1-based, but lists 0-based)
                        qdialogtext += (string)qi + ": " + llList2String(optext,qi-1) + "\n";
                        // Add a button for this option
                        qdialogoptions = qdialogoptions + [(string)qi];
                    }
                    // Present the dialog to the user
                    answerDialogListenHandler = llListen(menu_channel, "", sitter, "");
                    llDialog(sitter, qdialogtext, qdialogoptions, menu_channel);
                }
            } else {
                
                // Ask the question via IM
                llListenRemove(answerChatListenHandler); // cancel any existing listens before creating a new one
                answerChatListenHandler = llListen(0, "", sitter, "");                
                
                // Listen on channel 111 to allow people to give answers without everyone else hearing them.                
                llListenRemove(answerChatListenHandlerNonPublic); // cancel any existing listens before creating a new one
                answerChatListenHandlerNonPublic = llListen(111, "", sitter, "");                
                                
                llInstantMessage(sitter, qtext);
                // Offer the options via IM
                integer x = 0;
                integer num_options = llGetListLength(optext);
                for (x = 0; x < num_options; x++) {
                    llInstantMessage(sitter, (string)(x + 1) + ". " + llList2String(optext, x));
                }        
            }
            
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR, (string)question_id+"|"+qtext, sitter);
            
        }
        // Send a translation request link message
        sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
        }
        ///// ----------- /////
        ///// STATES /////
        default{
            on_rez(integer param)
            {
                llResetScript();
            }
            
            link_message(integer sender_num, integer num, string str, key id){
                if (num ==SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR){
                    llListenRemove(answerDialogListenHandler);
                    llListenRemove(answerChatListenHandler);
                    llListenRemove(answerChatListenHandlerNonPublic);            
                }                
                else
                if (num == SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING){
                    sitter=id;
                
                    llListenRemove(answerDialogListenHandler); // Cancel any existing listens
                    menu_channel = random_integer(-90000,-900000);                                    
                }
                else
                if (num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG||num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT) {//todo add to dia
                    list data = llParseString2List(str, ["|"], []);
                    question_id = llList2Integer(data, 0);
                    sloodle_full_quiz_url = llList2String(data, 1);//todo add to dia
                    integer offset = llStringLength(llList2String(data,0)+"|"+sloodle_full_quiz_url+"|");
                    sloodlehttpvars = llGetSubString(str, offset, -1);//-1 is the end of the list
                    sitter = id;
                    if (num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG) {//todo add to dia
                        doDialog=TRUE; //todo add to dia
                    }else{
                        doDialog=FALSE;//todo add to dia
                    }
                    httpfetchquestionquery = request_question((integer)str);                    
                } 
            }
            state_exit()
            {
                llSetTimerEvent(0.0);
            }
            
            listen(integer channel, string name, key id, string message)
            {
                // If using dialogs, then only listen to the dialog channel
                
                if (doDialog && ((qtype == "multichoice") || (qtype == "truefalse"))) {
                    if (channel != menu_channel) {
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "usedialogs", [llKey2Name(sitter)], sitter, "quiz");
                        return;
                    }
                } else {
                    if (channel != 0) return;
                }
            
                string opid; // used when the feedback is too long, and we have to fetch it off the server
                // Only listen to the sitter
                if (id == sitter) {
                    // Handle the answer...
                    float scorechange = 0;
                    string feedback = "";
                    string answeroptext = "";
                    
                    // Check the type of question this was
                    if ((qtype == "multichoice") || (qtype == "truefalse")) {
                        // Multiple choice - the response should be a number from the dialog box (1-based)
                        integer answer_num = (integer)message;
                        // Make sure it's valid
                        if ((answer_num > 0) && (answer_num <= llGetListLength(opids))) {
                            // Correct to 0-based
                            answer_num -= 1;
                            
                            feedback = llList2String(opfeedback, answer_num);
                            scorechange = llList2Float(opgrade, answer_num);
                            opid = llList2String(opids, answer_num);
                            answeroptext = llList2String(optext, answer_num);

                            // Notify the server of the response
                            notify_server(qtype, question_id, llList2String(opids, answer_num),scorechange);
                        } else {
                            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "invalidchoice", [llKey2Name(sitter)], NULL_KEY, "quiz");
                            ask_question();
                        }        
                     } else if (qtype == "shortanswer") {
                               // Notify the server of the response 
                               integer x = 0;
                               integer num_options = llGetListLength(optext);
                               for (x = 0; x < num_options; x++) {
                                   if (llToLower(message) == llToLower(llList2String(optext, x))) {
                                      feedback = llList2String(opfeedback, x);
                                      scorechange = llList2Float(opgrade, x);
                                      opid = llList2String(opids, x);
                                      answeroptext = llList2String(optext, x);
                                   }
                               notify_server(qtype, question_id, message, scorechange);
                               }        
                    } else if (qtype == "numerical") {
                               // Notify the server of the response
                               float number = (float)message;
                               integer x = 0;
                               integer num_options = llGetListLength(optext);
                               for (x = 0; x < num_options; x++) {
                                   if (number == (float)llList2String(optext, x)) {
                                      feedback = llList2String(opfeedback, x);
                                      scorechange = llList2Float(opgrade, x);
                                      opid = llList2String(opids, x);
                                      answeroptext = llList2String(optext, x);                                      
                                   }
                                   notify_server(qtype, question_id, message, scorechange);
                               }        
                    } 
                    
                    
                     else {
                        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "invalidtype", [qtype], NULL_KEY, "quiz");
                    }                
                    
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR, opid+"|"+answeroptext, sitter);    
                    
                    if (feedback == "[[LONG]]") // special long feedback placeholder for when there is too much feedback to give to the script
                        feedbackreq = request_feedback( question_id, opid );
                    else if (feedback != "") llInstantMessage(sitter, feedback); // Text feedback
                    else if (scorechange > 0.0) {                                                    
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "correct", [llKey2Name(sitter)], sitter, "quiz");
                        //num_correct += 1; SAL commented out this
                    } else {
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "incorrect",  [llKey2Name(sitter)], sitter, "quiz");
                    }
                    llSleep(1.);  //wait to finish the sloodle_translation_request before next question.
                    
                    // Clear out our current data (a feeble attempt to save memory!)
                    qtext = "";
                    qtype = "";
                    opids = [];
                    optext = [];
                    opgrade = [];
                    opfeedback = [];              
                    
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR, (string)scorechange, sitter);                                                                              
    
                }
            }
            
            timer()
            {
                // There has been a timeout of the HTTP request
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], NULL_KEY, "");
                llSetTimerEvent(0.0);
                
                if (question_id > -1) {
                    httpfetchquestionquery = request_question(question_id);
                }
            }            
        
            http_response(key request_id, integer status, list metadata, string body)
            {
                
                // This response will always contain question data.
                // If the current question is being loaded, then ask it right away, and load the next.
                // If the next question is being loaded, then just store it.
                // It will be made current and asked whenever the current one gets answered.
                // If the user ever gets ahead of our loading, then they will be waiting on the 'current' question.
                // As soon as that is loaded, it will get asked.
            
                // Is this the response we are expecting?
                if (request_id == httpfetchquestionquery) {                
                    httpfetchquestionquery = NULL_KEY;
                    llSetTimerEvent(0.0);
                } else if (request_id != feedbackreq) {
                    return;
                }
                
                // Make sure the response was OK
                if (status != 200) {
                    sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
                    if (request_id!=feedbackreq){
                        request_question( question_id );//TODO update DIA
                    } 
                    
                }
                
                // Split the response into several lines
                list lines = llParseStringKeepNulls(body, ["\n"], []);
                integer numlines = llGetListLength(lines);
                body = "";
                list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
                integer statuscode = llList2Integer(statusfields, 0);
                
                // Was it an error code?
                if (statuscode == -10301) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noattemptsleft", [llKey2Name(sitter)], NULL_KEY, "");
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_ERROR_NO_ATTEMPTS_LEFT, (string)question_id, sitter);//todo add to dia
                    return;
                    
                } else if (statuscode == -10302) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noquestions", [], NULL_KEY, "");
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_ERROR_NO_QUESTIONS, (string)question_id, sitter);//todo add to dia
                    
                    return;
                    
                } else if (statuscode <= 0) {
                    //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
                     sloodle_error_code(SLOODLE_TRANSLATE_IM, sitter,statuscode); //send message to error_message.lsl
                    // Check if an error message was reported
                    if (numlines > 1) sloodle_debug(llList2String(lines, 1));
                    return;
                }
                
                if (request_id == feedbackreq) {
                    llInstantMessage( sitter, llList2String(lines, 1) );
                    return;
                }
                
                // Save a tiny bit of memory!
                statusfields = [];
        
                // Go through each line of the response
               
                integer i = 0;
                for (i = 1; i < numlines; i++) {
        
                    // Extract and parse the current line
                    list thisline = llParseStringKeepNulls(llList2String(lines, i),["|"],[]);
                    string rowtype = llList2String( thisline, 0 );
        
                    // Check what type of line this is
                    if ( rowtype == "question" ) {
                        
                        // Grab the question information and reset the options

                            qtext = llList2String(thisline, 4);
                            qtype = llList2String(thisline, 7);
                            
                            opids = [];
                            optext = [];
                            opgrade = [];
                            opfeedback = [];
                            
                            // Make sure it's a valid question type
                            if ((qtype != "multichoice") && (qtype != "truefalse") && (qtype != "numerical") && (qtype != "shortanswer")) {
                                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "invalidtype", [qtype], NULL_KEY, "quiz");
                                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], NULL_KEY, "");
                                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_ERROR_INVALID_QUESION, (string)question_id, sitter);//todo add to dia
                                
                                return;
                            }
                        
                    } else if ( rowtype == "questionoption" ) {                        
                        // Add this option to the appropriate place
                        opids += [(integer)llList2String(thisline, 2)];
                        optext += [llList2String(thisline, 4)];
                        opgrade += [(float)llList2String(thisline, 5)];
                        opfeedback += [llList2String(thisline, 6)];
                    }
                }
                
                // Automatically ask this question
                ask_question();
            }
            
        }
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/quiz-1.0/objects/default/assets/sloodle_quiz_question_handler.lslp

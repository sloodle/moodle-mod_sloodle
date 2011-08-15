       // Sloodle quiz chair
        // Allows SL users to take Moodle quizzes in-world
        // Part of the Sloodle project (www.sloodle.org)
        //
        // Copyright (c) 2006-9 Sloodle (various contributors)
        // Released under the GNU GPL
        //
        // Contributors:
        //  Edmund Edgar
        //  Peter R. Bloomfield

        // Once configured in the usual way, this script waits for a request to ask a question in the form of a linked message with num SLOODLE_CHANNEL_QUIZ_ASK_QUESTION.
        // When the student answers the question, it sends out a linked message with num SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR.
        // Note that it doesn't handle timeouts in case the user doesn't respond - all that should be done by the calling script.
        
        // Memory-saving hacks!
        key null_key = NULL_KEY;

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
        
        integer SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR = -1639271102; //Tells us to start a quiz for the avatar, if possible.; Ordinary quiz chair will have a second script that detects and avatar sitting on it and sends it. Awards-integrated version waits for a game ID to be set before doing this.
        integer SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR = -1639271103; //Sent by main quiz script to tell UI scripts that quiz has started for avatar with key
        integer SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR = -1639271104; //Sent by main quiz script to tell UI scripts that quiz has finished for avatar with key, with x/y correct in string
        integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text
        integer SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR = -1639271106;  //Sent by main quiz script to tell UI scripts that question has been answered by avatar with key. String contains selected option ID + "|" + option text + "|"
        integer SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION = -1639271107; 
        integer SLOODLE_CHANNEL_QUIZ_LOADED_QUESTION = -1639271108;
        integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
        integer SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ = -1639271110;
        integer SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION = -1639271111;            
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION = -1639271112; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key.
        integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.


        integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
        integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
        integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
        
        string SLOODLE_OBJECT_TYPE = "quiz-1.0";
        string SLOODLE_EOF = "sloodleeof";
        
        string sloodle_quiz_url = "/mod/sloodle/mod/quiz-1.0/linker.php";
                        
        key httpquizquery = null_key;
        key feedbackreq = null_key;
        
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
        key sitter = null_key; 

                    
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
            llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, null_key);
        }        

        // Configure by receiving a linked message from another script in the object
        // Returns TRUE if the object has all the data it needs
        integer sloodle_handle_command(string str) 
        {
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
                if (value2 != "") sloodlepwd = value1 + "|" + value2;
                else sloodlepwd = value1;
                
            } else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
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
        
        // Query the server for the identified question (request by global question ID)
        key request_question( integer qid )
        {
            
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION, (string)qid, sitter);            
            
            // Request the identified question from Moodle
            string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
            body += "&sloodlepwd=" + sloodlepwd;
            body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
            body += "&sloodleuuid=" + (string)sitter;
            body += "&sloodleavname=" + llEscapeURL(llKey2Name(sitter));
            body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
            body += "&ltq=" + (string)qid;
            
            key newhttp = llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
            
            llSetTimerEvent(0.0);
            llSetTimerEvent(request_timeout);
            
            return newhttp;
        }
        
        // Query the server for the feedback for a particular choice.
        // This is only called if the server has told us that the feedback is too long to go in the regular request
        // It does this by substituting the feedback [[[LONG]]]
        key request_feedback( integer qid, string fid ) {
            // Request the identified question from Moodle
            string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
            body += "&sloodlepwd=" + sloodlepwd;
            body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
            body += "&sloodleuuid=" + (string)sitter;
            body += "&sloodleavname=" + llEscapeURL(llKey2Name(sitter));
            body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
            body += "&ltq=" + (string)qid;
            body += "&fid=" + (string)fid;                                    
            
            key reqid = llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
            llSleep(3.0); // Hopefully the message will come back before the next question is asked. But if it comes back out of order, we won't insist.
            
            return reqid;
            
        }
        
        // Notify the server of a response
        notify_server(string qtype, integer questioncode, string responsecode, float scorechange)
        {
            string body = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
            body += "&sloodlepwd=" + sloodlepwd;
            body += "&sloodlemoduleid=" + (string)sloodlemoduleid;
            body += "&sloodleuuid=" + (string)sitter;
            body += "&sloodleavname=" + llEscapeURL(llKey2Name(sitter));
            body += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
            body += "&resp" + (string)questioncode + "_=" + responsecode;
            body += "&resp" + (string)questioncode + "_submit=1";
            body += "&questionids=" + (string)questioncode;
            body += "&action=notify";
            body += "&scorechange="+(string)scorechange;
            
            llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        }
        
        
        // Ask the current question
        ask_question() 
        {     
                 
            llListen(SLOODLE_CHANNEL_AVATAR_DIALOG, "", sitter, "");
            llListen(0, "", sitter, "");
                 
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
            llDialog(sitter, qdialogtext, qdialogoptions, SLOODLE_CHANNEL_AVATAR_DIALOG);
            }
            } else {
                
                // Ask the question via IM
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
        

        
        // Move the Quiz Chair back to the starting position

        
        
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
        
        // Send a translation request link message
        
        sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
        {
            
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
        }
        
        ///// ----------- /////
        
        
        ///// STATES /////
        
        // Waiting on initialisation
        default
        {
            
            on_rez(integer par)
            {
                llResetScript();
            }
                        
            state_entry()
            {
                // Starting again with a new configuration
                llSetText("", <0.0,0.0,0.0>, 0.0);
                isconfigured = FALSE;
                eof = FALSE;
                // Reset our data
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
            }
            
            link_message( integer sender_num, integer num, string str, key id)
            {
                // Check the channel
                if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Split the message into lines
                    list lines = llParseString2List(str, ["\n"], []);
                    integer numlines = llGetListLength(lines);
                    integer i = 0;
                    for (; i < numlines; i++) {
                        isconfigured = sloodle_handle_command(llList2String(lines, i));
                    }
                    
                    // If we've got all our data AND reached the end of the configuration data, then move on
                    if (eof == TRUE) {
                        if (isconfigured == TRUE) {
                            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], null_key, "");
                            state ready;
                        } else {
                            // Go all configuration but, it's not complete... request reconfiguration
                            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], null_key, "");
                            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", null_key);
                            eof = FALSE;
                        }
                    }
                }
            }
            
        }
        
        
        // Ready state - waiting for a request to ask a question
        state ready
        {
            on_rez(integer param)
            {
                llResetScript();
            }
            
            link_message(integer sender_num, integer num, string str, key id)
            {
                if (num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION) {
                    question_id = (integer)str;
                    sitter = id;
                    httpquizquery = request_question((integer)str);                    
                } else if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Is it a reset command?
                    if (str == "do:reset") {
                        llResetScript();
                    } else if (str == "do:reconfigure"  || str == "do:requestconfig") {
                        state default; // The main script is about to receive new configuration data... get ready to receive it too
                    }
                    return;
                }
            }
                        
            state_entry()
            {

            }
            
            state_exit()
            {
                llSetTimerEvent(0.0);
            }
            
            listen(integer channel, string name, key id, string message)
            {
                // If using dialogs, then only listen to the dialog channel
                if (doDialog && ((qtype == "multichoice") || (qtype == "truefalse"))) {
                    if (channel != SLOODLE_CHANNEL_AVATAR_DIALOG) {
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
                            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "invalidchoice", [llKey2Name(sitter)], null_key, "quiz");
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
                        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "invalidtype", [qtype], null_key, "quiz");
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
                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "httptimeout", [], null_key, "");
                llSetTimerEvent(0.0);
                
                if (question_id > -1) {
                    httpquizquery = request_question(question_id);
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
                if (request_id == httpquizquery) {                
                    httpquizquery = null_key;
                    llSetTimerEvent(0.0);
                } else if (request_id != feedbackreq) {
                    return;
                }
                
                // Make sure the response was OK
                if (status != 200) {
                    sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status); //send message to error_message.lsl
                    state default;
                }
                
                // Split the response into several lines
                list lines = llParseStringKeepNulls(body, ["\n"], []);
                integer numlines = llGetListLength(lines);
                body = "";
                list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
                integer statuscode = llList2Integer(statusfields, 0);
                
                // Was it an error code?
                if (statuscode == -331) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(sitter)], null_key, "");
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], null_key, "");
                    state default;
                    return;
                    
                } else if (statuscode == -10301) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noattemptsleft", [llKey2Name(sitter)], null_key, "");
                    return;
                    
                } else if (statuscode == -10302) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noquestions", [], null_key, "");
                    return;
                    
                } else if (statuscode <= 0) {
                    //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], null_key, "");
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
                list thisline = [];
                string rowtype = "";
                integer i = 0;
                for (i = 1; i < numlines; i++) {
        
                    // Extract and parse the current line
                    list thisline = llParseString2List(llList2String(lines, i),["|"],[]);
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
                                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "invalidtype", [qtype], null_key, "quiz");
                                sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "resetting", [], null_key, "");
                                state default;
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


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/quiz-1.0/sloodle_quiz_question_handler.lsl


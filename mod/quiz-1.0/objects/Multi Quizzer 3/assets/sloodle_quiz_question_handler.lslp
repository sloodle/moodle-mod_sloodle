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
      	integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_TEXT_BOX=-1639277000;
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
        string SLOODLE_TRANSLATE_TEXTBOX="textbox";//asks via a text box
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
        }       
        sloodle_debug(string msg){
            llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
        }  
         debug (string message ){
              list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
              if ( llList2Integer (params ,0)==PRIM_MATERIAL_FLESH ){
                   llOwnerSay(llGetScriptName ()+": " +message );
             }
        } 
        key  request_question(key user_key,integer question){
           
                string body=sloodlehttpvars;
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "Asking a questions",  [llKey2Name(user_key)], user_key, "quizzer");
            	// Request the quiz data from Moodle
                body += "&sloodlerequestdesc="+"REQUESTING_QUESTION";
                body += "&sloodleuuid=" + (string)user_key;
                body += "&sloodleavname=" + llEscapeURL(llKey2Name(user_key));
                body += "&ltq="+(string)question;
                body +="&request_timestamp="+(string)llGetUnixTime(); 
                key newhttp = llHTTPRequest(sloodle_full_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
                debug("request_question: "+sloodle_full_quiz_url+"/?"+body);
                return newhttp;
        }     
        integer random_integer( integer min, integer max ) {
          return min + (integer)( llFrand( max - min + 1 ) );
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
        notify_server(key user_key,string qtype, integer questioncode, string responsecode, float scorechange) {
            string body =sloodlehttpvars;
            body += "&sloodlerequestdesc="+"NOTIFY_SERVER";
            body += "&sloodleuuid=" + (string)user_key;
            body += "&sloodleavname=" + llEscapeURL(llKey2Name(user_key));
            body += "&request_timestamp="+(string)llGetUnixTime(); 
            body += "&resp" + (string)questioncode + "_=" + responsecode;
            body += "&resp" + (string)questioncode + "_submit=1";
            body += "&questionids=" + (string)questioncode;
            body += "&action=notify";
            body += "&scorechange="+(string)scorechange;
            
            llHTTPRequest(sloodle_full_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        }
        
        
        // Ask the current question
        ask_question(key user_key,integer menu_channel) {     
                                  
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
                    answerDialogListenHandler = llListen(menu_channel, "", user_key, "");
                    llDialog(user_key, qdialogtext, qdialogoptions, menu_channel);
                }
            } else {
                
                // Ask the question via IM
                llListenRemove(answerChatListenHandler); // cancel any existing listens before creating a new one
                answerChatListenHandler = llListen(0, "", user_key, "");                
                
                // Listen on channel 111 to allow people to give answers without everyone else hearing them.                
                llListenRemove(answerChatListenHandlerNonPublic); // cancel any existing listens before creating a new one
                answerChatListenHandlerNonPublic = llListen(111, "", user_key, "");                
                               
                
                // Offer the options via IM
                integer x = 0;
                integer num_options = llGetListLength(optext);
                string option_text="";
                for (x = 0; x < num_options; x++) {
                    option_text += (string)(x + 1) + ". " + llList2String(optext, x);
                }       
                llTextBox(user_key,qtext+"\n"+option_text,menu_channel);    
            }
            
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR, (string)question_id+"|"+qtext, user_key);
            
        }
        // Send a translation request link message
        sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
        }
        ///// ----------- /////
        ///// STATES /////
        default{
            on_rez(integer param){
                llResetScript();
            }
            
            link_message(integer sender_num, integer num, string str, key user_key){
                if (num ==SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR){
                    llListenRemove(answerDialogListenHandler);
                    llListenRemove(answerChatListenHandler);
                    llListenRemove(answerChatListenHandlerNonPublic);            
                }                
                else
                if (num == SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING){
                   
                
                    llListenRemove(answerDialogListenHandler); // Cancel any existing listens
                    menu_channel = random_integer(-90000,-900000);                                    
                }
                else
                if (num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG||num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_TEXT_BOX) {//todo add to dia
                    //llList2String(question_ids, active_question)+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars
                    list data = llParseString2List(str, ["|"], []);
                    question_id = llList2Integer(data, 0);
                    sloodle_full_quiz_url = llList2String(data, 1);//todo add to dia
                    integer offset = llStringLength(llList2String(data,0)+"|"+sloodle_full_quiz_url+"|");
                    sloodlehttpvars = llGetSubString(str, offset, -1);//-1 is the end of the list
                    
                    if (num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG) {//todo add to dia
                        doDialog=TRUE; //todo add to dia
                    }else{
                        doDialog=FALSE;//todo add to dia
                    }
                    httpfetchquestionquery = request_question(user_key,question_id);                    
                } 
            }
            
            listen(integer channel, string name, key user_key, string user_response){
                // If using dialogs, then only listen to the dialog channel
                if (DEBUG==TRUE){
	                if (channel==-9){
	                	user_key=(key)user_response;
	                	integer debug_activeq=get_active_question(user_key);
	                	request_question(user_key,debug_activeq);
	                	debug("debug mode: asking question "+(string)debug_activeq+ " for user: "+llKey2Name(user_key));
	                 return;
	                }
                }
                
                
               
                if (doDialog && ((qtype == "multichoice") || (qtype == "truefalse"))) {
                    if (llListFindList(users_menu_channels, [channel])==-1) {
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "usedialogs", [llKey2Name(user_key)], user_key, "quizzer");
                        return;
                    }
                } 
                string opid; // used when the feedback is too long, and we have to fetch it off the server
                // Only listen to the sitter
                if (llListFindList(users, [user_key])!=-1) {
                	/* Determine the user_id so we can access the current question the user is on, as wel as access other info about this user
                	*  which is stored in this script
                	*/
                	integer user_id=llListFindList(users, [user_key]);
                	
                    // Handle the answer...
                    float scorechange = 0;
                    string feedback = "";
                    string answeroptext = "";
                    list opids = llParseString2List(llList2String(users_current_question_opids,user_id), ["|"], []);
                    list optext = llParseString2List(llList2String(users_current_question_optext,user_id), ["|"], []);
                    list opgrade = llParseString2List(llList2String(users_current_question_opgrade,user_id), ["|"], []);
                    list opfeedback = llParseString2List(llList2String(users_current_question_opfeedback,user_id), ["|"], []);
                    //determine which question this user is on
                    integer active_question_index = llList2Integer(users_active_question_index,user_id);
                    //get this users question list
                    list question_list = llParseString2List(llList2String(users_questions, user_id), ["|"], []);
                    //get the MOODLE question_id 
                    integer question_id = llList2Integer(question_list, active_question_index);
                    debug("users_current_question_opids: "+llList2CSV(users_current_question_opids));
                    debug("opids: "+llList2CSV(opids));
                    
                    // Check the type of question this was
                    if ((qtype == "multichoice") || (qtype == "truefalse")) {
                        // Multiple choice - the response should be a number from the dialog box (1-based)
                        integer answer_num = (integer)user_response;
                        // Make sure it's valid
                        if ((answer_num > 0) && (answer_num <= llGetListLength(opids))) {
                            // Correct to 0-based
                            answer_num -= 1;
                            feedback = llList2String(opfeedback, answer_num);
                            scorechange = llList2Float(opgrade, answer_num);
                            opid = llList2String(opids, answer_num);
                            answeroptext = llList2String(optext, answer_num);

                            // Notify the server of the response
                            notify_server(user_key,qtype, question_id, llList2String(opids, answer_num),scorechange);
                        } else {
                           
                          sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "invalidchoice",  [llKey2Name(user_key)],user_key, "quizzer");
                           // ask_question();
                        }        
                     } else if (qtype == "shortanswer") {
                               // Notify the server of the response 
                               integer x = 0;
                               integer num_options = llGetListLength(optext);
                               for (x = 0; x < num_options; x++) {
                                   if (llToLower(user_response) == llToLower(llList2String(optext, x))) {
                                      feedback = llList2String(opfeedback, x);
                                      scorechange = llList2Float(opgrade, x);
                                      opid = llList2String(opids, x);
                                      answeroptext = llList2String(optext, x);
                                   }
                               notify_server(user_key,qtype, question_id, user_response, scorechange);
                               }        
                    } else if (qtype == "numerical") {
                               // Notify the server of the response
                               float number = (float)user_response;
                               integer x = 0;
                               integer num_options = llGetListLength(optext);
                               for (x = 0; x < num_options; x++) {
                                   if (number == (float)llList2String(optext, x)) {
                                      feedback = llList2String(opfeedback, x);
                                      scorechange = llList2Float(opgrade, x);
                                      opid = llList2String(opids, x);
                                      answeroptext = llList2String(optext, x);                                      
                                   }
                                   notify_server(user_key,qtype, question_id, user_response, scorechange);
                               }        
                    } 
                    
                    
                     else {
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM , [0], "invalidtype" , [], user_key, "quizzer" );
                    }                
                    
                    //llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR, opid+"|"+answeroptext, sitter);    
                    
                    if (feedback == "[[LONG]]") // special long feedback placeholder for when there is too much feedback to give to the script
                        user_feedback_requests+= request_feedback( question_id, opid,user_key );
                    else if (feedback != "") llInstantMessage(user_key, feedback); // Text feedback
                    else if (scorechange > 0.0) {                                                    
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "correct", [llKey2Name(user_key)], user_key, "quizzer");
                        num_correct = llList2Integer(users_num_correct,user_id);
                        //save the number of questions correct for this user
                        users_num_correct=llListReplaceList(users_num_correct, [num_correct+1], user_id, user_id);
                    } else {
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "incorrect",  [llKey2Name(user_key)], user_key, "quizzer");
                    }
                    //before asking the next question, check if the quiz is complete
                    if (active_question_index==num_questions-1){
                    	finish_quiz(user_key);
                    	//if it is complete, should we repeat the quiz?
                    	if (doRepeat!=1){
                    		return;
                    	}
                    }else{
                    	//we are not at the end of the quiz, so should we advance to the next question?
                    	  if (correctToContinue!=1){
                    	  	//last question doesn't have to be answered correctly before advancing to the next question so increase their active question index
                    	  	users_active_question_index= llListReplaceList(users_active_question_index, [active_question_index+1], user_id, user_id);
                    	  }
                    	  //now ask the question
                    	//   llSleep(1.);  //wait to finish the sloodle_translation_request before next question.
                    	   // Clear out our current data (a feeble attempt to save memory!)
		                   qtext = "";
		                   qtype = "";
		                   opids = [];
		                   optext = [];
		                   opgrade = [];
		                   opfeedback = [];   
		                   if (askquestionscontinuously==1){
		                   		request_question(user_key,get_active_question(user_key));
		                   }else{
		                   		if (active_question_index+1!=num_questions){
		                   				sloodle_translation_request(SLOODLE_TRANSLATE_IM , [0], "clicktogetnextquestion" , [llKey2Name(user_key)], user_key, "quizzer" );
		                   		}
		                   }
                    	   
                    }
                   
                  
                    
                //    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR, (string)scorechange, user_key);                                                                              
    
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
        
            http_response(key request_id, integer status, list metadata, string body) {
            
                    // Questions are comming into our http_response from SLOODLE.  Split this data into several lines
                        list lines = llParseStringKeepNulls(body, ["\n"], []);
                        integer numlines = llGetListLength(lines);
                        body = "";
                        list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
                        integer statuscode = llList2Integer(statusfields, 0);
                        //1|QUIZ||REQUESTING_QUESTION|||2102f5ab-6854-4ec3-aec5-6cd6233c31c6
                        string  request_descriptor =llList2String(statusfields, 3); 
                        key user_key = llList2Key(statusfields,6);
                        //the user who initiated this request
                        integer user_id = llListFindList(users, [user_key]);
                        integer active_question_index = llList2Integer(users_active_question_index,user_id);
                         	debug("*********************request_descriptor: "+request_descriptor);
                          if (request_descriptor=="REQUESTING_QUESTION"){
                         		request_descriptor="";
		                        if (statuscode == -10301) {
		                            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "noattemptsleft",  [llKey2Name(user_key)],user_key, "quizzer");
		                       //     llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_ERROR_NO_ATTEMPTS_LEFT, (string)question_id, user_key);//todo add to dia
		                            return;
		                            
		                        } else if (statuscode == -10302) {
		                           sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "noquestions",  [llKey2Name(user_key)],user_key, "quizzer");
		                      //      llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_ERROR_NO_QUESTIONS, (string)question_id, user_key);//todo add to dia
		                           return;
		                            
		                        } else if (statuscode <= 0) {
		                            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
		                            // sloodle_error_code(SLOODLE_TRANSLATE_IM, sitter,statuscode); //send message to error_message.lsl
		                            // Check if an error message was reported
		                            if (numlines > 1) sloodle_debug("quiz data error: "+llList2String(lines, 1));
		                            return;
		                        }
                            integer feedback_request_index = llListFindList(user_feedback_requests, [request_id]);
                            if (feedback_request_index!=-1) {
                                   llInstantMessage( user_key, llList2String(lines, 1) );
                                   user_feedback_requests=llDeleteSubList(user_feedback_requests, feedback_request_index, feedback_request_index);
                                return;
                               }
                        
                        // Save a tiny bit of memory!
                        statusfields = [];
                
                        // Go through each line of the response
                        integer i = 0;
                        
                      
                        	string opids_string="";
	                        string optext_string="";
	                        string opgrade_string="";
	                        string opfeedback_string="";
	                        list opids = []; // IDs
	                        list optext = []; // Texts
	                        list opgrade = []; // Grades
	                        list opfeedback = []; // Feedback if this option is selected
	                        //clear users current question option data
	                        users_current_question_opids=llListReplaceList(users_current_question_opids, [""], user_id, user_id);
	                        users_current_question_optext=llListReplaceList(users_current_question_optext, [""], user_id, user_id); 
	                        users_current_question_opgrade=llListReplaceList(users_current_question_opgrade, [""], user_id, user_id); 
	                        users_current_question_opfeedback=llListReplaceList(users_current_question_opfeedback, [""], user_id, user_id); 
	                        for (i = 1; i < numlines; i++) {
	                
	                            // Extract and parse the current line
	                            list thisline = llParseStringKeepNulls(llList2String(lines, i),["|"],[]);
	                            string rowtype = llList2String( thisline, 0 );
	                			debug ("rowtype: "+rowtype);
	                            // Check what type of line this is
	                            if ( rowtype == "question" ) {
	                                
	                                // Grab the question information and reset the options
	        
	                                    qtext = llList2String(thisline, 4);
	                                    qtype = llList2String(thisline, 7);
	                                    // Make sure it's a valid question type
	                                    if ((qtype != "multichoice") && (qtype != "truefalse") && (qtype != "numerical") && (qtype != "shortanswer")) {
	                                      sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "invalidtype",  [llKey2Name(user_key)],user_key, "quizzer");
	                                  //    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_ERROR_INVALID_QUESION, (string)question_id, user_key);//todo add to dia
	                                      return;
	                                    }
	                                
	                            } else if ( rowtype == "questionoption" ) {                        
	                                // Add this option to the appropriate place
	                                opids_string += llList2String(thisline, 2)+"|";
	                                optext_string += llList2String(thisline, 4)+"|";
	                                opgrade_string += llList2String(thisline, 5)+"|";
	                                opfeedback_string += llList2String(thisline, 6)+"|";
	                                
	                                opids += [(integer)llList2String(thisline, 2)];
	                                optext += [llList2String(thisline, 4)];
	                                opgrade += [(float)llList2String(thisline, 5)];
	                                opfeedback += [llList2String(thisline, 6)];
	                            }
	                        }
	                        opids_string=llGetSubString(opids_string, 0, -2);
	                        optext_string=llGetSubString(optext_string, 0, -2);
	                        opgrade_string=llGetSubString(opgrade_string, 0, -2);
	                        opfeedback_string=llGetSubString(opfeedback_string, 0, -2);
	                        debug("opids_string: "+opids_string);
	                        debug("optext_string: "+optext_string);
	                        debug("opgrad_string: "+opgrade_string);
	                        debug("opfeedback_string: "+opfeedback_string);
	                        
	                        users_current_question_opids=llListReplaceList(users_current_question_opids, [opids_string], user_id, user_id);
	                        users_current_question_optext=llListReplaceList(users_current_question_optext, [optext_string], user_id, user_id); 
	                        users_current_question_opgrade=llListReplaceList(users_current_question_opgrade, [opgrade_string], user_id, user_id); 
	                        users_current_question_opfeedback=llListReplaceList(users_current_question_opfeedback, [opfeedback_string], user_id, user_id); 
	                        integer menu_channel = llList2Integer(users_menu_channels, user_id);               
	                        // Are we using dialogs?
	                        if (doDialog == 1) {
	                            // We want to create a dialog with the option texts embedded into the main text,
	                            //  and numbers on the buttons
	                            integer qi=1;
	                            list qdialogoptions = [];
	                            string qdialogtext = "Question "+(string)(active_question_index+1)+" of "+(string)num_questions+"\n"+ qtext + "\n";
	                            // Go through each option
	                            integer num_options = llGetListLength(optext);
	                            
	                            if ((qtype == "numerical")|| (qtype == "shortanswer")) {
	                               // Ask the question via IM
	                                llTextBox(user_key,qtext,llList2Integer(users_menu_channels,user_id));   
	                                return;
	                            } 
	                            else {
	                                for (qi = 1; qi <= num_options; qi++) {
	                                    // Append this option to the main dialog (remebering buttons are 1-based, but lists 0-based)
	                                    qdialogtext += (string)qi + ": " + llList2String(optext,qi-1) + "\n";
	                                    // Add a button for this option
	                                    qdialogoptions = qdialogoptions + [(string)qi];
	                                }
	                                // Present the dialog to the user
	                               
	                                llDialog(user_key, qdialogtext, qdialogoptions, llList2Integer(users_menu_channels,user_id));
	                                debug("qi="+(string)(qi)+" qdialogtext: "+qdialogtext);
	                                return;
	                            }
	                        } else {
	                          // Offer the options via IM
	                            integer x = 0;
	                            integer num_options = llGetListLength(optext);
	                            string option_string;
	                            for (x = 0; x < num_options; x++) {
	                                option_string+= (string)(x + 1) + ". " + llList2String(optext, x);
	                            }     
	                              llTextBox(user_key,qtext+"\n"+option_string,llList2Integer(users_menu_channels,user_id));   
	                              return;
	                        }         
                        }     
                }
            
        }
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/quiz-1.0/objects/default/assets/sloodle_quiz_question_handler.lslp

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

        // Once configured in the usual way, this script waits for a request to ask a question in the form of a linked message with num SLOODLE_CHANNEL_QUIZ_ASK_QUESTION.
        // When the student answers the question, it sends out a linked message with num SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR.
        // Note that it doesn't handle timeouts in case the user doesn't respond - all that should be done by the calling script.
        
        integer SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR = -1639271119; //Tells us to STOP a quiz for the avatar
        integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
        integer doRepeat = 0; // whether we should run through the questions again when we're done
        integer doDialog = 1; // whether we should ask the questions using dialog rather than chat
        string  sloodlehttpvars;
        integer answerDialogListenHandler;
        integer answerChatListenHandler;
        integer answerChatListenHandlerNonPublic;
        string  SEPARATOR="****";
        integer num_questions;
        integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text
        integer SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR = -1639271106;  //Sent by main quiz script to tell UI scripts that question has been answered by avatar with key. String contains selected option ID + "|" + option text + "|"
        integer SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION = -1639271107; 
        integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.
        integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING = -1639271117; //mod quiz script is in state quizzing
        integer SLOODLE_CHANNEL_QUIZ_ERROR_INVALID_QUESION = -1639271121;  //
        integer SLOODLE_CHANNEL_QUIZ_ERROR_NO_ATTEMPTS_LEFT= -1639271123;  //
        integer SLOODLE_CHANNEL_QUIZ_ERROR_NO_QUESTIONS= -1639271124;  //          
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT = -1639271125; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA CHAT.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG;// Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_TEXT_BOX=-1639277000;
        integer SLOODLE_CHANNEL_QUIZ_NOTIFY_SERVER_OF_RESPONSE= -1639277004;
        integer SLOODLE_CHANNEL_QUIZ_FEED_BACK_REQUEST= -1639277005;
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG0 = -170000; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG1 = -1700001; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG2 = -1700002; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG3= -1700003; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG4 = -1700004; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG5 = -1700005; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG6 = -1700006; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        list server_requests;          
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
        
        float request_timeout = 20.0;
        
        // Text and type of the current and next question
        string qtext = "";
        string qtype = "";
        // Lists of option information for the current question
        list opids = []; // IDs
        list optext = []; // Texts
        list opgrade = []; // Grades
        list opfeedback = []; // Feedback if this option is selected
        list users_menu_channels;
        list users;  
        list user_question_options; 
        list users_question_id;
        list users_listen_handler;
        list users_current_question_index;
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
           
        integer random_integer( integer min, integer max ) {
          return min + (integer)( llFrand( max - min + 1 ) );
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
            state_entry() {
                string script_name = llGetScriptName();
                integer myNum = (integer)llGetSubString(script_name, -1,-1);
                if (myNum ==0){
                    SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG0;
                }else
                if (myNum ==1){
                    SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG1;
                }else
                if (myNum ==2){
                    SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG2;
                }else
                if (myNum ==3){
                    SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG3;
                }else
                if (myNum ==4){
                    SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG4;
                }else
                if (myNum ==5){
                    SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG5;
                }else
                if (myNum ==6){
                    SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG6;
                }
                llSay(0,"My num is : "+(string)myNum+" my channel is : "+(string)SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG);
                
                
            }
            link_message(integer sender_num, integer num, string str, key user_key){
                    if (num!=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG&&num!=SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR){
                    
                        return;
                    }
                //  llList2String(question_ids, current_question_index)+"|"+(string)users_question_index+"|"+(string)num_questions+"|"+(string)menu_channel+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,user_key );//todo add to dia    
                if (num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG||num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_TEXT_BOX) {//todo add to dia
                    integer menu_channel;                   
                    list data = llParseString2List(str, ["|"], []);
                    /*  llList2String(question_ids, current_question_index)
                      +"|"+(string)users_question_index
                      +"|"+(string)num_questions
                      +"|"+(string)menu_channel
                      +"|"+sloodleserverroot+sloodle_quiz_url
                      +"|"+sloodlehttpvars,user_key );//todo add to dia
              */
                    //question_id - data,0
                    //users_question_index - data,1
                    //num_questions - data 2 
                    //menu_channel - data 3
                    //sloodle_full_quiz_url - data 4
                    //sloodlehttpvars data 5 
                    integer question_id = llList2Integer(data, 0);
                    integer users_question_index = llList2Integer(data, 1);
                    num_questions = llList2Integer(data, 2);
                    menu_channel = llList2Integer(data, 3);
                    sloodle_full_quiz_url = llList2String(data, 4);
                    integer offset = llStringLength((string)question_id+"|"+(string)users_question_index+"|"+(string)num_questions);
                    offset+=llStringLength("|"+(string)menu_channel+"|"+(string)sloodle_full_quiz_url)+1;
                    sloodlehttpvars = llGetSubString(str, offset, -1);//-1 is the end of the list
                    //****0****10****-8610976****http://englishvillage.avatarclassroom.com/mod/sloodle/mod/quiz-1.0/linker.php****sloodlecontrollerid=2&sloodlepwd=0fcf04ac-4504-6209-050e-6267014c38b8|922621267&sloodlemoduleid=8&sloodleserveraccesslevel=0
                    string db_str ="*********************************************\n";
                    db_str+="* str = "+str+"\n";
                    db_str+="* \n";
                    db_str+="* question_id = "+(string)question_id+"\n";
                    db_str+="* users_question_idex = "+(string)users_question_index+"\n";
                    db_str+="* num_questions = "+(string)num_questions+"\n";
                    db_str+="* menu_channel = "+(string)menu_channel+"\n";
                    db_str+="* sloodle_full_quiz_url = "+(string)sloodle_full_quiz_url+"\n";
                    db_str+="* sloodlehttpvars = "+(string)sloodlehttpvars+"\n";
                    db_str +="*********************************************\n";
                    debug(db_str);
                    integer user_id = llListFindList(users, [user_key]);
                    integer listen_handler= llListen(menu_channel, "", user_key, "");
                    debug("listening to user: "+llKey2Name(user_key));
                    if (user_id==-1){
                            //if we have never seen this user before, add them to the system
                            users+=user_key;
                            //store this unique channel for this user
                            users_menu_channels+=menu_channel;
                            users_question_id+=question_id;
                            users_listen_handler +=listen_handler;
                            users_current_question_index+=users_question_index;
                            
                    }else{
                        users_question_id=llListReplaceList(users_question_id, [question_id], user_id, user_id);
                        users_menu_channels=llListReplaceList(users_menu_channels, [menu_channel], user_id, user_id);
                        users_listen_handler =llListReplaceList(users_listen_handler , [listen_handler], user_id, user_id);
                        users_current_question_index =llListReplaceList(users_current_question_index , [users_question_index], user_id, user_id);
                    }
                    if (num == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG) {//todo add to dia
                        doDialog=TRUE; 
                    }else{
                        doDialog=FALSE;
                    }
                    string body=sloodlehttpvars;
                    sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "Asking a questions",  [llKey2Name(user_key)], user_key, "quizzer");
                    // Request the quiz data from Moodle
                    body += "&sloodlerequestdesc="+"REQUESTING_QUESTION";
                    body += "&sloodleuuid=" + (string)user_key;
                    body += "&sloodleavname=" + llEscapeURL(llKey2Name(user_key));
                    body += "&ltq="+(string)question_id;
                    body +="&request_timestamp="+(string)llGetUnixTime(); 
                    debug("request_question: "+sloodle_full_quiz_url+"/?"+body);
                    server_requests+=  llHTTPRequest(sloodle_full_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);   
              } 
            }
            
                   
        
            http_response(key request_id, integer status, list metadata, string body) {
                  integer placeinlist=llListFindList(server_requests, [request_id]);        
                    if (placeinlist!=-1){
                        server_requests= llDeleteSubList(server_requests, placeinlist, placeinlist);
                     }else {
                         return;
                     }
                     
                    // Questions are comming into our http_response from SLOODLE.  Split this data into several lines
                        list lines = llParseStringKeepNulls(body, ["\n"], []);
                        integer numlines = llGetListLength(lines);
                        body = "";
                        list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
                        integer statuscode = llList2Integer(statusfields, 0);
                        //1|QUIZ||REQUESTING_QUESTION|||2102f5ab-6854-4ec3-aec5-6cd6233c31c6
                        string  request_descriptor =llList2String(statusfields, 3); 
                        
                        key user_key = llList2Key(statusfields,6);
                        
                        integer user_id =llListFindList(users,[user_key]);
                     
                        //the user who initiated this request
                            debug("*********************request_descriptor: "+request_descriptor);
                          if (request_descriptor=="REQUESTING_QUESTION"){
                                  llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR, "", user_key);
                                 request_descriptor="";
                                if (statuscode == -10301) {
                                    sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "noattemptsleft",  [llKey2Name(user_key)],user_key, "quizzer");
                                    return;
                                    
                                } else if (statuscode == -10302) {
                                   sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "noquestions",  [llKey2Name(user_key)],user_key, "quizzer");
                                   return;
                                    
                                } else if (statuscode <= 0) {
                                    //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], NULL_KEY, "");
                                    // sloodle_error_code(SLOODLE_TRANSLATE_IM, sitter,statuscode); //send message to error_message.lsl
                                    // Check if an error message was reported
                                    if (numlines > 1) sloodle_debug("quiz data error: "+llList2String(lines, 1));
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
                            //remove the last trailing "|"
                            opids_string=llGetSubString(opids_string, 0, -2);
                            optext_string=llGetSubString(optext_string, 0, -2);
                            opgrade_string=llGetSubString(opgrade_string, 0, -2);
                            opfeedback_string=llGetSubString(opfeedback_string, 0, -2);
                            if (user_id!=-1){
                                    //save question options for this user from this question
                                    user_question_options=llListReplaceList(user_question_options,[opids_string+SEPARATOR+optext_string+SEPARATOR+opgrade_string+SEPARATOR+opfeedback_string],user_id,user_id);
                                }            
                            // Are we using dialogs?
                            integer users_question_index=llList2Integer(users_current_question_index,user_id);
                            if (doDialog == 1) {
                                // We want to create a dialog with the option texts embedded into the main text,
                                //  and numbers on the buttons
                                integer qi=1;
                                list qdialogoptions = [];
                                string qdialogtext = "Question ("+(string)(users_question_index+1)+") of ("+(string)num_questions+")\n"+qtext + "\n";
                                // Go through each option
                                integer num_options = llGetListLength(optext);
                                
                                if ((qtype == "numerical")|| (qtype == "shortanswer")) {
                                   // Ask the question via IM
                                    llTextBox(user_key,qdialogtext,llList2Integer(users_menu_channels,user_id));   
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
                                string qdialogtext = "Question ("+(string)(users_question_index+1)+") of ("+(string)num_questions+")\n"+qtext + "\n";
                                string option_string;
                                for (x = 0; x < num_options; x++) {
                                    option_string+= (string)(x + 1) + ". " + llList2String(optext, x);
                                }     
                                  llTextBox(user_key,qdialogtext+"\n"+option_string,llList2Integer(users_menu_channels,user_id));   
                                  return;
                            }         
                        }     
                }
              listen(integer channel, string name, key user_key, string user_response){
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
                    integer listenHandler = llList2Integer(users_listen_handler, user_id);
                    llListenRemove(listenHandler);
                    debug("removing Listen Handler");
                
                    integer question_id = llList2Integer(users_question_id,user_id);
                    // Handle the answer...
                    float scorechange = 0;
                    string feedback = "";
                    string answeroptext = "";
                    list opInfo = llParseString2List(llList2String(user_question_options,user_id), [SEPARATOR], []);
                    list opids = llParseString2List(llList2String(opInfo,0), ["|"], []);
                    list optext = llParseString2List(llList2String(opInfo,1), ["|"], []);
                    list opgrade = llParseString2List(llList2String(opInfo,2), ["|"], []);
                    list opfeedback = llParseString2List(llList2String(opInfo,3), ["|"], []);
                    
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
                            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_NOTIFY_SERVER_OF_RESPONSE,(string)qtype+"|"+(string)question_id+"|"+ llList2String(opids, answer_num)+"|"+(string)scorechange, user_key);
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
                              llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_NOTIFY_SERVER_OF_RESPONSE,(string)qtype+"|"+(string)question_id+"|"+ user_response +"|"+(string)scorechange, user_key);
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
                                   
                                  llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_NOTIFY_SERVER_OF_RESPONSE,(string)qtype+"|"+(string)question_id+"|"+ user_response +"|"+(string)scorechange, user_key);
                               }        
                    }else {
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM , [0], "invalidtype" , [], user_key, "quizzer" );
                    }                
                   //handle feedback
                   
                    if (feedback == "[[LONG]]") { // special long feedback placeholder for when there is too much feedback to give to the script
                        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FEED_BACK_REQUEST, (string)question_id+"|"+(string)opid,user_key);
                    }
                    else if (feedback != ""){
                         llInstantMessage(user_key, feedback); // Text feedback
                    }
                     llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR, (string)scorechange, user_key);
                   
                    
            } 
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/quiz-1.0/objects/multi_user_quiz/assets/sloodle_quiz_question_handler.lslp

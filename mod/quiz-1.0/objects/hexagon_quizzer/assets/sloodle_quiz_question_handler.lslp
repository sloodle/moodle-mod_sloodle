//
/* The line above should be left blank to avoid script errors in OpenSim.

  Sloodle_quiz_question_handler
        
  Part of the Sloodle project (www.sloodle.org)
  
  Copyright (c) 2006-9 Sloodle (various contributors)
  
  Released under the GNU GPL
  
  Contributors:
      Edmund Edgar
      Paul Preibisch

  This script requests questions from the server for a particular user.  If that user has enough attempts left, it will
  load the questions into either a dialog box, or a textbox, along with that questions options.
  
  When the user responds, it reports the scorechange back to the linked message stream.
         
*/

        
        integer SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR = -1639271119; //Tells us to STOP a quiz for the avatar
        integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
        integer doRepeat = 0; // whether we should run through the questions again when we're done
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
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG=-1639271126;// Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_TEXT_BOX=-1639277000;
        integer SLOODLE_CHANNEL_QUIZ_NOTIFY_SERVER_OF_RESPONSE= -1639277004;
        integer SLOODLE_CHANNEL_QUIZ_FEED_BACK_REQUEST= -1639277005;
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

            }
            link_message(integer sender_num, integer channel, string str, key user_key){
                
                   if (channel!=SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG&&channel!=SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR){
                  //  debug("returning");
                       return;
                   }
                //  this is what was sent: llList2String(question_ids, current_question_index)+"|"+(string)users_question_index+"|"+(string)num_questions+"|"+(string)menu_channel+"|"+sloodleserverroot+sloodle_quiz_url+"|"+sloodlehttpvars,user_key );//todo add to dia    
                if (channel == SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG) {
                    integer menu_channel;                   
                    list data = llParseString2List(str, ["|"], []);
                    
                    /*  llList2String(question_ids, current_question_index)
                      +"|"+(string)users_question_index
                      +"|"+(string)num_questions
                      +"|"+(string)menu_channel
                      +"|"+sloodleserverroot+sloodle_quiz_url
                      +"|"+sloodlehttpvars,user_key );//todo add to dia
              */
                   
                    integer question_id = llList2Integer(data, 0);
                    integer users_question_index = llList2Integer(data, 1);
                    num_questions = llList2Integer(data, 2);
                    menu_channel = llList2Integer(data, 3);
                    key hex=llList2Key(data,4);
                    sloodle_full_quiz_url = llList2String(data, 5);
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
                    if (user_id==-1){
                            //if we have never seen this user before, add them to the system
                            users+=user_key;
                            //store this unique channel for this user
                            users_question_id+=question_id;
                         	users_hex +=hex;
                            users_current_question_index+=users_question_index;
                            
                    }else{
                        users_question_id=llListReplaceList(users_question_id, [question_id], user_id, user_id);
                        users_menu_channels=llListReplaceList(users_menu_channels, [menu_channel], user_id, user_id);
                  		users_hex +=llListReplaceList(users_hex, [hex], user_id, user_id);
                        users_current_question_index =llListReplaceList(users_current_question_index , [users_question_index], user_id, user_id);
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
                    if (placeinlist==-1){
                        return;
                    }
                    server_requests= llDeleteSubList(server_requests, placeinlist, placeinlist);
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
                    if (request_descriptor=="REQUESTING_QUESTION"){
                        request_descriptor="";
                        if (statuscode == -10301) {
                            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noattemptsleft",  [llKey2Name(user_key)],user_key, "hex_quizzer");
                            return;
                        } else 
                        if (statuscode == -10302) {
                            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "noquestions",  [llKey2Name(user_key)],user_key, "hex_quizzer");
                            return;
                        } else 
                        if (statuscode <= 0) {
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
                                              sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "invalidtype",  [llKey2Name(user_key)],user_key, "hex_quizzer");
                                      //    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_ERROR_INVALID_QUESION, (string)question_id, user_key);//todo add to dia
                                              return;
                                        }
                                } else 
                                if ( rowtype == "questionoption" ) {                        
                                    // Add this option to the appropriate place
                                    opids_string += llList2String(thisline, 2)+"|";
                                    optext_string += llList2String(thisline, 4)+"|";
                                    opgrade_string += llList2String(thisline, 5)+",";
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
                            integer users_question_index=llList2Integer(users_current_question_index,user_id);
                            key hex = llList2Key(users_hex,user_id);
                            // We want to create a dialog with the option texts embedded into the main text,
                            //  and numbers on the buttons
                            integer qi=1;
                            list qdialogoptions = [];
                            string qdialogtext = "Question ("+(string)(users_question_index+1)+") of ("+(string)num_questions+")\n"+qtext + "\n";
                            // Go through each option
                            integer num_options = llGetListLength(optext);
                            string qdialogoptions_string="";
                            for (qi = 1; qi <= num_options; qi++) {
                                // Append this option to the main dialog (remebering buttons are 1-based, but lists 0-based)
                                qdialogtext += (string)qi + ": " + llList2String(optext,qi-1) + "\n";
                                // Add a button for this option
                                qdialogoptions = qdialogoptions + [(string)qi];
                                
                            }
                            qdialogoptions_string = llList2CSV(qdialogoptions);
                            string question_data = qdialogtext+"|";//question text
                            question_data +(string)hex+"|";
                            question_data += qdialogoptions_string+"|";//options ie: a,b,c 
                            question_data += opgrade_string+"|";//grade for each option ie: -1.0,1,-1 (1=correct)
                            question_data += opfeedback_string;//any feedback
                            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR, question_data, user_key);//send back to rezzer so that pie_slices can show hovertext for each option
                            debug("question_data: "+question_data);
                         }
              }
              listen(integer channel, string name, key user_key, string user_response){
             
                    if (llListFindList(users_menu_channels, [channel])==-1) {
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "usedialogs", [llKey2Name(user_key)], user_key, "quizzer");
                        return;
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
// SLOODLE LSL Script Git Location: mod/quiz-1.0/objects/hex_quizzer/assets/sloodle_quiz_question_handler.lslp

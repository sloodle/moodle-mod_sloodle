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
        integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
        integer doRepeat = 0; // whether we should run through the questions again when we're done
        integer doDialog = 1; // whether we should ask the questions using dialog rather than chat
        integer correctToContinue=0; //must get question correct before next question is asked
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
        list users;
        key toucher;
        integer SLOODLE_CHANNEL_QUIZ_ERROR_NO_ATTEMPTS_LEFT= -1639271123;  //
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
        string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";          // 2 output parameters: colour <r,g,b>, and alpha value
        
        integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
        integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
        string SLOODLE_OBJECT_TYPE = "quiz-1.0";
        string SLOODLE_EOF = "sloodleeof";
        string sloodle_quiz_url = "/mod/sloodle/mod/quiz-1.0/linker.php";
        key httpquizquery = null_key;
        float request_timeout = 20.0;
        integer STRIDE_LENGTH_IS_ONE=1;
        string sloodlehttpvars;
        // ID and name of the current quiz
        integer quiz_id = -1;
        string quiz_name = "";
        // This stores the list of question ID's (global ID's)
        list question_ids = [];
        integer num_questions = 0;
                // Stores the number of questions the user got correct on a given attempt
        integer num_correct = 0;
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
         // Text and type of the current and next question
        string qtext = "";
        string qtype = "";
        // Lists of option information for the current question
        list users_current_question_opids = []; // IDs
        list users_current_question_optext = []; // Texts
        list users_current_question_opgrade = []; // Grades
        list users_current_question_opfeedback = []; // Feedback if this option is selected
        list users_score_change;    
        list users_questions;
        list users_menu_channels;
        list users_active_question_index;
        list users_num_correct;
         list user_feedback_requests;
        
        ///// FUNCTIONS /////
        debug (string message ){
              list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
              if ( llList2Integer (params ,0)==PRIM_MATERIAL_FLESH ){
                   llOwnerSay(llGetScriptName ()+": " +message );
             }
        }
         integer random_integer( integer min, integer max ){
          return min + (integer)( llFrand( max - min + 1 ) );
        }
              
        initialize_variables(){
        // Starting again with a new configuration
                
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [YELLOW, 1.0], "initializing", [], llGetOwner(), "quizzer");
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
        }
        // Notify the server of a response
        notify_server(string qtype, integer questioncode, string responsecode, float scorechange){
            string body =sloodlehttpvars;
            body += "&resp" + (string)questioncode + "_=" + responsecode;
            body += "&resp" + (string)questioncode + "_submit=1";
            body += "&questionids=" + (string)questioncode;
            body += "&action=notify";
            body += "&scorechange="+(string)scorechange;
            llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
        }
         // Query the server for the feedback for a particular choice.
        // This is only called if the server has told us that the feedback is too long to go in the regular request
        // It does this by substituting the feedback [[[LONG]]]
        key request_feedback( integer qid, string fid,key user_key ) {
            // Request the identified question from Moodle
            sloodlehttpvars = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
            sloodlehttpvars += "&sloodlepwd=" + sloodlepwd;
            sloodlehttpvars += "&sloodlemoduleid=" + (string)sloodlemoduleid;
            sloodlehttpvars += "&sloodleuuid=" + (string)user_key;
            sloodlehttpvars += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
            sloodlehttpvars += "&sloodleavname=" + llEscapeURL(llKey2Name(user_key));
            sloodlehttpvars += "&ltq=" + (string)qid;
            sloodlehttpvars += "&fid=" + (string)fid;  
            key reqid = llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], sloodlehttpvars);
            llSleep(3.0); // Hopefully the message will come back before the next question is asked. But if it comes back out of order, we won't insist.
            
            return reqid;
            
        }
        /*
        *  get_active_question
        *
        *  Contributor:
        *  Paul Preibisch (Fire Centaur)
        *
        *  get_active_question will return the question_id of the current question for the user_key input
        *  each users user_key is stored in the "users" list
        *  each users active question index is stored in the "users_active_question_index" list
        *  each users questions are stored as a string separated by "|" in "users_questions" list
        *  The index of each of these lists pertain to one user.  A user is added to the system when they first touch the prim
        *  in the quiz_loaded state, and we need to get a question for them to answer.  This script will check if their key exists in the 
        *  users list, and if not add them.  To understand how the data for the first user's data is stored, review the following
        *
        *  users[0] = 2102f5ab-6854-4ec3-aec5-6cd6233c31c6
        *  users_active_question_index[0] = 5
        *  users_questions_list[0]  = 9|2|7|4|3|8|5|6|1 
        *
        *  Here you can see we are using a common index in each of these lists to refer to one user in the system.  In this case
        *  we are refering to the first user who is in the system, at index 0. We refer to this index as "user_id".  This users active question index is 5
        *  that means they are on the sixth question, which in the users_question_list has the question id "8" 
        */  
        
        integer get_active_question(key user_key){
            integer user_id=llListFindList(users, [user_key]);
            if (user_id==-1){
                string new_user_questions="";
                integer q;
                //randomize the questions for the new user if required
                if (doRandomize==1){
                    question_ids=llListRandomize(question_ids, STRIDE_LENGTH_IS_ONE);
                }
                //now create a question list for this user
            
                for (q=0;q<num_questions;q++){
                    new_user_questions+=llList2String(question_ids, q)+"|";
                }
                //store new question list into an array for this user
                users_questions+=new_user_questions;
                //set the new users active question to the first question in the list
                users_active_question_index+=0;
                //add the new user to the system
                users+=user_key;
                users_num_correct+=0;
                //create a random unique menu channel for this user
                integer menu_channel;
                //make sure this menu_channel is not currently being used.
                while  (llListFindList(users_menu_channels, [menu_channel])!=-1){
                    menu_channel = random_integer(-900000,-9000000); 
                }
                //store this unique channel for this user
                users_menu_channels+=menu_channel;   
                //list for the user on a special channel
                llListen(menu_channel, "", user_key, "");  
                debug("New user added to the system: "+llList2CSV(users));
                integer active_question =  llList2Integer(question_ids, 0);
                debug("Active Question Index is: "+(string)active_question);
                return active_question;
            }else{
                /*
                  Each user has its question list stored as a string in the users_questions list;
                  As an example, that string might look like: 9|2|7|4|3|6|5|8|1
                  
                  We can retreive this list like this: llList2String(users_questions, user_id)
                  then parse it into a list using llParseString2List, and then retreive the active question by
                  examining users_active_question_index at the index user_id
                */
                list question_list = llParseString2List(llList2String(users_questions, user_id), ["|"], []);
                integer active_question_index = llList2Integer(users_active_question_index,user_id);
                integer active_question = llList2Integer(question_list, active_question_index);
                //Update the active question index once the user has given a response
                debug("Active Question for "+ llKey2Name(user_key)+ " is: "+(string)active_question);
                return active_question ;
            }
        }
        load_quiz(key user_key){
            // llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER, "", userKey);
                
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "fetchingquiz",  [llKey2Name(user_key)], user_key, "quizzer");
                // Request the quiz data from Moodle
                sloodlehttpvars = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
                sloodlehttpvars += "&sloodlepwd=" + sloodlepwd;
                sloodlehttpvars += "&sloodlemoduleid=" + (string)sloodlemoduleid;
                sloodlehttpvars += "&sloodleuuid=" + (string)user_key;
                sloodlehttpvars += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
                sloodlehttpvars += "&sloodleavname=" + llEscapeURL(llKey2Name(user_key));
                httpquizquery = llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], sloodlehttpvars);
                debug("loading quiz: "+sloodleserverroot + sloodle_quiz_url+"/?"+sloodlehttpvars);
        }
        
         request_question(key user_key,integer question){
            // llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER, "", userKey);
                
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "Asking a questions",  [llKey2Name(user_key)], user_key, "quizzer");
            
                // Request the quiz data from Moodle
                sloodlehttpvars = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
                sloodlehttpvars += "&sloodlepwd=" + sloodlepwd;
                sloodlehttpvars += "&sloodlemoduleid=" + (string)sloodlemoduleid;
                sloodlehttpvars += "&sloodleuuid=" + (string)user_key;
                sloodlehttpvars += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
                sloodlehttpvars += "&sloodleavname=" + llEscapeURL(llKey2Name(user_key));
                sloodlehttpvars += "&ltq="+(string)question;
                httpquizquery = llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], sloodlehttpvars);
                debug("request_question: "+sloodleserverroot + sloodle_quiz_url+"/?"+sloodlehttpvars);
        }
        
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
        }   
        sloodle_debug(string msg){
            llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, null_key);
        }        
        /******************************************************************************************************************************
        * clearUserQuizData- 
        * Description - resets the quiz chair data.  Used if a user jumps off a quiz chair.  Resets data for next user
        *******************************************************************************************************************************/
           clearUserQuizData(){
           quiz_name = "";
           question_ids = [];
           num_questions = 0;
           num_correct=0;
        
           
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
            else if (name == "set:correctToContinue") correctToContinue = (integer)value1;
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
        finish_quiz(key user_key) {
            integer user_id = llListFindList(users, [user_key]);
            integer num_correct = llList2Integer(users_num_correct,user_id);
            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "complete", [llKey2Name(user_key), (string)num_correct + "/" + (string)num_questions], user_key, "quizzer");
            //move_to_start(); // Taking this out here leaves the quiz chair at its final position until the user stands up.
            
            // Notify the server that the attempt was finished
            string body = sloodlehttpvars;
            body += "&finishattempt=1";
            llHTTPRequest(sloodleserverroot + sloodle_quiz_url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], body);
            users_num_correct=llListReplaceList(users_num_correct, [0], user_id, user_id);
            users_active_question_index=llListReplaceList(users_active_question_index, [0], user_id, user_id);
         //   llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR, (string)num_correct + "/" + (string)num_questions, user_key);
            
        }
        // Send a translation request link message
        sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
        }
        ///// ----------- /////
        ///// STATES /////
        default{
            /* 
                In this state we are just going to sit and wait for our initialization variables to come through 
                as linked message on the SLOODLE_CHANNEL_OBJECT_DIALOG channel
                When these are received we will store them in this scripts globabl variables using the sloodle_handle_command function
                If we get touched in the meantime, we will send a "do:requestconfig" to request for the variables again
            */
            state_entry(){
                initialize_variables();
                /*
                    It's good to tell other scripts we are in the default state so they have an idea of whats going on
                    and react (hook) to this event if they have been programmed to do so.
                */
              //  llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_DEFAULT,llGetScriptName(), NULL_KEY);
            }
            
            link_message( integer sender_num, integer num, string str, key id){
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
                            
                             sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "configurationreceived",  [llKey2Name(llGetOwner())], llGetOwner(), "");
            
                            state load;
                        } else {
                            // Go all configuration but, it's not complete... request reconfiguration
                            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "configdatamissing",  [llKey2Name(llGetOwner())], llGetOwner(), "");
                            
                            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", id);
                            eof = FALSE;
                        }
                    }
                }
            }
            
            touch_start(integer num_detected){
                //let the administrator request re-configuration if we get stuck in this state
                // Attempt to request a reconfiguration
                toucher = llDetectedKey(0);
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", toucher);
              
            }
        }
        
        
        state load {
            /*
                We have now received all basic configuration and are ready to retrieve the questions from our quiz.
                We need a user to initiate this stage through touch.
                Once touched, we will contact the server, and retreive the following important data
                ** quiz_id
                ** quiz_name
                ** question_ids
                After this data is collected from the server response we will move into the quiz_loaded state.
            */
            state_entry(){
            	sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [RED, 1.0], "clickmetoloadthequiz", [], llGetOwner(), "quizzer");
                
                llSetText("Click me to load the quiz", RED, 1);     
               
            }
            
           touch_start(integer num_detected) {
                     //take the first touch, extract the user-uuid, and request from the server, the question_id's and quiz name
                  toucher = llDetectedKey(0);
                  load_quiz(toucher);
                  sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [YELLOW, 1.0], "loadingquiz", [], llGetOwner(), "quizzer");
            
            }

            on_rez(integer par){
                //if the quiz is just dropped from inventory, we need to start from the first state, so reset the script
                llResetScript();
            }            
           
           
            http_response(key id, integer status, list meta, string quiz_data){
                /*
                    This response is a result of us calling load_quiz in the touch start event.  In load_quiz, we asked the server
                    for the quiz_name, and question_ids.  Now let's parse the data that was returned
                */
                
                debug("quiz data: "+quiz_data);
                // Is this the response we are expecting?
                if (id != httpquizquery) return;
                httpquizquery = null_key;
                //stop the timer which was set before the server was asked for data
                llSetTimerEvent(0.0);
                // Make sure the response was OK
                if (status != 200) {
                        sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,status, ""); //send message to error_message.lsl
                      //  llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", user_key);//todo add to dia
                        state load;
                }
                
                // Split the response into several lines
                list lines = llParseString2List(quiz_data, ["\n"], []);
                integer numlines = llGetListLength(lines);
                quiz_data = "";
                list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
                integer statuscode = (integer)llStringTrim(llList2String(statusfields, 0), STRING_TRIM);
                key user_key = llList2Key(statusfields,6);
                // Was it an error code?
                if (statuscode == -10301) { 
                    sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "noattemptsleft",  [llKey2Name(user_key)],user_key, "");
                  //  llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", user_key);//todo add to dia
                    return;
                    
                } else if (statuscode == -10302) {
                     sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "noquestions",  [llKey2Name(user_key)],user_key, "quizzer");
                  //  llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", user_key);
                    return;
                    
                } else if (statuscode <= 0) {
                    //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "servererror", [statuscode], null_key, "");
                    string msg;
                    if (numlines > 1) {
                        msg = llList2String(lines, 1);
                    }
                    sloodle_debug("quiz_data error: "+msg);
                      //Sloodle 2.0 Change - output custom errorcode to other scripts
                     sloodle_error_code(SLOODLE_TRANSLATE_IM, user_key,statuscode, msg); //send message to error_message.lsl                 
                 
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
                        quiz_id = (integer)llList2String(thisline, 4);
                        quiz_name = llList2String(thisline, 2);
                       
                        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [BLUE, 1.0], "quizname", [quiz_name], llGetOwner(), "quizzer");
            
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
                       
                    }
                }
                
                // Make sure we have all the data we need
                if (quiz_name == "" || num_questions == 0) {
                   
                     sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "noquestions",  [llKey2Name(user_key)],user_key, "quizzer");
                 //   llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", user_key);//add to dia
                
                    return;
                }
                
                // Report the status to the user
                
                sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "ready",  [llKey2Name(user_key)],user_key, "quizzer");
        //        llMessageLinked(LINK_SET,  SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_READY, "", "");
              state quiz_ready;
            }
            
          
            
            
        }

        state quiz_ready {
            on_rez(integer param){
                llResetScript();
            }
            
            state_entry(){
                sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT, [GREEN, 1.0], "quizisready", [quiz_name,num_questions], llGetOwner(), "quizzer");
            
                num_correct = 0;
            
                // Make sure we have some questions
                if (num_questions == 0) {
                    sloodle_debug("No questions - cannot run quiz.");
                  //  llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", sitter);//add to dia
                    state load;//todo add to dia
                    return;
                }
                request_question(toucher,get_active_question(toucher)); 
              
            }
            touch_start(integer num_touches) {
                integer j=0;
                key user_key=NULL_KEY;
                for (j=0;j<num_touches;j++){
                    user_key=llDetectedKey(j);
                    request_question(user_key,get_active_question(user_key));
                }
                
                
            }
            http_response(key request_id, integer status, list metadata, string body) {
            
                    // Questions are comming into our http_response from SLOODLE.  Split this data into several lines
                        list lines = llParseStringKeepNulls(body, ["\n"], []);
                        integer numlines = llGetListLength(lines);
                        body = "";
                        list statusfields = llParseStringKeepNulls(llList2String(lines,0), ["|"], []);
                        integer statuscode = llList2Integer(statusfields, 0);
                        key user_key = llList2Key(statusfields,6);
                        //the user who initiated this request
                        integer user_id = llListFindList(users, [user_key]);
                        integer active_question_index = llList2Integer(users_active_question_index,user_id);
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
                            integer qi;
                            list qdialogoptions = [];
                            string qdialogtext = "Question "+(string)(active_question_index+1)+" of "+(string)num_questions+"\n"+ qtext + "\n";
                            // Go through each option
                            integer num_options = llGetListLength(optext);
                            
                            if ((qtype == "numerical")|| (qtype == "shortanswer")) {
                               // Ask the question via IM
                                llTextBox(user_key,qtext,llList2Integer(users_menu_channels,user_id));   
                            } else {
                                for (qi = 1; qi <= num_options; qi++) {
                                    // Append this option to the main dialog (remebering buttons are 1-based, but lists 0-based)
                                    qdialogtext += (string)qi + ": " + llList2String(optext,qi-1) + "\n";
                                    // Add a button for this option
                                    qdialogoptions = qdialogoptions + [(string)qi];
                                }
                                // Present the dialog to the user
                               
                                llDialog(user_key, qdialogtext, qdialogoptions, llList2Integer(users_menu_channels,user_id));
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
                        }
                        
                     
                }
            listen(integer channel, string name, key user_key, string user_response){
                // If using dialogs, then only listen to the dialog channel
               
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
                            notify_server(qtype, question_id, llList2String(opids, answer_num),scorechange);
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
                               notify_server(qtype, question_id, user_response, scorechange);
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
                                   notify_server(qtype, question_id, user_response, scorechange);
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
                    	   llSleep(1.);  //wait to finish the sloodle_translation_request before next question.
                    	   // Clear out our current data (a feeble attempt to save memory!)
		                   qtext = "";
		                   qtype = "";
		                   opids = [];
		                   optext = [];
		                   opgrade = [];
		                   opfeedback = [];   
                    	   request_question(user_key,get_active_question(user_key));
                    }
                   
                  
                    
                //    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR, (string)scorechange, user_key);                                                                              
    
                }
            }
            }
            
         
          
                             
      
                                        

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/quiz-1.0/sloodle_mod_quiz-1.0.lsl

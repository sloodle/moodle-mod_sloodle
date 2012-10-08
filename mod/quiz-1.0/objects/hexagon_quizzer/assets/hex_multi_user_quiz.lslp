//
// The line above should be left blank to avoid script errors in OpenSim.

/*  hex_multi_user_quiz

    Copyright (c) 2006-9 Sloodle (various contributors)
    Released under the GNU GPL
    

    This file is the main brain of the multi user quiz.  It keeps track of which users are taking the quiz, and what stage 
    that user is at. It will keep track of which question the current user is on. When the last question is answered, it will
    dispatch request_finish_quiz_from_lsl_pipeline, which calls the finish_quiz script.  It also dispatches all request_question_from_lsl_pipepline
    which requests questions from the question_handler script

    Contributors:
    Edmund Edgar
    Paul Preibisch
    
   
     
*/
      
        integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
        integer doRepeat = 0; // whether we should run through the questions again when we're done
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
        string  SEPARATOR="****";
        integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
        integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script. 
        integer SLOODLE_CHANNEL_AVATAR_IGNORE = -1639279999;
        integer SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR = -1639271102; //Tells us to start a quiz for the avatar, if possible.; Ordinary quiz chair will have a second script that detects and avatar sitting      on it and sends it. Awards-integrated version waits for a game ID to be set before doing this.
        integer SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR = -1639271103; //Sent by main quiz script to tell UI scripts that quiz has started for avatar with key
        integer SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR = -1639271104; //Sent by main quiz script to tell UI scripts that quiz has finished for avatar with key, with x/y correct in string
        integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text
        integer SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR = -1639271106;  //Sent by main quiz script to tell UI scripts that question has been answered by avatar with key. String contains selected option ID + "|" + option text + "|"
        integer SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION = -1639271107; 
        integer SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM= -1639277009; // 3 output parameters: colour <r,g,b>,  alpha value, link number
        integer SLOODLE_CHANNEL_QUIZ_LOADED_QUESTION = -1639271108;
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION = -1639271112; //used when this script wants to ask a question and have the results sent to the child hex
        integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
        integer SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ = -1639271110;
        integer SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION = -1639271111;            
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT = -1639271125; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA CHAT.
        integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_TEXT_BOX=-1639277001;//asks via a text box
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
        integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object       
        integer SLOODLE_CHANNEL_QUIZ_LOAD_QUIZ= -1639277003;//user touched object
        
        ///// COLORS ////
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
        ///// TRANSLATION /////
        // Link message channels
        integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
        // Translation output methods
        string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";          // 2 output parameters: colour <r,g,b>, and alpha value
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
        integer quiz_id = -1;
        string quiz_name = "";
        // This stores the list of question ID's (global ID's)
        list question_ids = [];
        integer num_questions = 0;
        // The position where we started. The Chair will use this to get the lowest vertical position it used.
        vector startingposition;
        
        // Stores the number of questions the user got correct on a given attempt
        list users;
        list users_current_question_opids = []; // IDs
        list users_current_question_optext = []; // Texts
        list users_current_question_opgrade = []; // Grades
        list users_current_question_opfeedback = []; // Feedback if this option is selected
        list users_score_change;    
        list users_questions;
        list users_menu_channels;
        list users_question_id_index;
        list users_num_correct;
        list user_feedback_requests;
        integer STRIDE_LENGTH_IS_ONE=1;
        key first_user = NULL_KEY;
        integer first_user_active_question;
        integer askquestionscontinuously=1;   
        integer correctToContinue=0; //must get question correct before next question is asked
        ///// FUNCTIONS /////
        debug (string message ){
                 list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
                 if ( llList2Integer (params ,0)!=PRIM_MATERIAL_FLESH ){
                     return;
                 }
                llOwnerSay(llGetScriptName ()+": " +message );
        }
   
   
        integer get_prim(string name){
            integer num_links=llGetNumberOfPrims();
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
        
        integer random_integer( integer min, integer max ){
          return min + (integer)( llFrand( max - min + 1 ) );
        }
        integer add_user(key user_key){
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING, "", user_key);
                integer q;
                //randomize the questions for the new user if required
                list temp=question_ids;
                if (doRandomize==1){
                    temp=llListRandomize(question_ids, STRIDE_LENGTH_IS_ONE);
                }
                //now create a question list for this user
                string new_user_question_string="";
                for (q=0;q<num_questions;q++){
                    new_user_question_string+=llList2String(temp, q)+"|";
                }
                new_user_question_string=llGetSubString(new_user_question_string, 0, -2);
                //create a random unique menu channel for this user
                integer menu_channel = random_integer(-900000,-9000000);
                //make sure this menu_channel is not currently being used.
                 
                while  (llListFindList(users_menu_channels, [menu_channel])!=-1){
                    menu_channel = random_integer(-900000,-9000000); 
                }
                ///// add user data ////
                //add the new user to the system
                users+=user_key;
                //store new question list into an array for this user
                users_questions+=new_user_question_string;
                //set the new users active question to the first question in the list
                users_question_id_index+=0;
                users_num_correct+=0;
                //store this unique channel for this user
                users_menu_channels+=menu_channel;   
                //list for the user on a special channel
                debug("-----------------------------New user added to the system: "+llList2CSV(users));
                return llGetListLength(users)-1;
        }
        //get active question will add a user to the users list if they have not been added yet, and it will also return a users
        //active question id
        integer get_current_question_id(key user_key){
                /*
                  Each user has its question list stored as a string in the users_questions list;
                  As an example, that string might look like: 9|2|7|4|3|6|5|8|1
                  
                  We can retreive this list like this: llList2String(users_questions, user_id)
                  then parse it into a list using llParseString2List, and then retreive the active question by
                  examining users_question_id_index at the index user_id
                */
                integer user_id=llListFindList(users,[user_key]);
                string user_question_str=llList2String(users_questions, user_id);
                list question_list = llParseString2List(user_question_str, ["|"], []);
                integer question_id_index = llList2Integer(users_question_id_index,user_id);
                if (question_id_index==0){
                  llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR, (string)quiz_id+"|"+quiz_name, user_key );
                }
                integer question_id = llList2Integer(question_list, question_id_index);
                //Update the active question index once the user has given a response
                debug("question_id for "+ llKey2Name(user_key)+ " at index: "+(string)question_id_index+" from: "+user_question_str+" is: "+(string)question_id);
                return question_id ;            
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
            llMessageLinked(LINK_THIS, DEBUG_CHANNEL, msg, NULL_KEY);
        }  
        //requests from the question handler scripts a question
        request_question_from_lsl_pipepline(key user_key, integer users_question_index,integer num_questions){
            integer user_id = llListFindList(users, [user_key]);
            integer menu_channel =  llList2Integer(users_menu_channels, user_id);
            string users_questions_str=llList2String(users_questions, user_id);
            integer current_question_id= get_current_question_id(user_key); 
            integer question_id_index = llList2Integer(users_question_id_index,user_id);
            //debug("///////// question ids cvs /////////"+llList2CSV(question_ids));
            debug("////////// users question cvs ///////"+(string)users_questions_str);
            debug("////////// question_id_index  ///////"+(string)question_id_index);
            debug("//////// resulting question id /////////"+(string)get_current_question_id(user_key));
            debug("/////////// full sloodle root ///////////"+(string)sloodleserverroot+sloodle_quiz_url);
            
            SEPARATOR="|";
          
            llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG,(string)current_question_id+SEPARATOR+(string)users_question_index+SEPARATOR+(string)num_questions+SEPARATOR+(string)menu_channel+SEPARATOR+sloodleserverroot+sloodle_quiz_url+SEPARATOR+sloodlehttpvars,user_key );//todo add to dia
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
            else if (name == "set:sloodleplaysound") doPlaySound = (integer)value1;
            else if (name == "set:sloodleaskquestionscontinuously") askquestionscontinuously= (integer)value1;
            else if (name == "set:correctToContinue") correctToContinue = (integer)value1;
            else if (name == SLOODLE_EOF) eof = TRUE;
            
            return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0 && sloodlemoduleid > 0);
        }
        
        // Checks if the given agent is permitted to user this object
        // Returns TRUE if so, or FALSE if not
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
        // Report completion to the user
        request_finish_quiz_from_lsl_pipeline(key user_key) {
            integer user_id = llListFindList(users, [user_key]);
            integer num_correct = llList2Integer(users_num_correct,user_id);
            sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "complete", [llKey2Name(user_key), (string)num_correct + "/" + (string)num_questions], user_key, "quiz");
            users_question_id_index=llListReplaceList(users_question_id_index, [0], user_id, user_id);   
            user_feedback_requests=llListReplaceList(user_feedback_requests, [""], user_id, user_id);
            users_num_correct=llListReplaceList(users_num_correct, [0], user_id, user_id);
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR, (string)num_correct + "/" + (string)num_questions, user_key);
        }
        // Send a translation request link message
        sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
        }
        ///// ----------- /////
        ///// STATES /////
        default{
            state_entry(){
            	
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
                doPlaySound = 1;
                doRandomize = 1;
                //tell other scripts we are in the default state.
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_DEFAULT,llGetScriptName(), NULL_KEY);
            }
            
            link_message( integer sender_num, integer num, string str, key user_key){
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
                            state load;
                        } else {
                            // Go all configuration but, it's not complete... request reconfiguration
                            sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [llGetScriptName()], NULL_KEY, "");
                            llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);
                            eof = FALSE;
                        }
                    }
                }else 
                if (num==SLOODLE_CHANNEL_USER_TOUCH){
                    if (user_key==llGetOwner()){
                          llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", NULL_KEY);
                    }
                }
            }
        }
        
        
        // Ready state - waiting for a user to climb aboard!
        state load{
            on_rez(integer par){
                llResetScript();
            }       
            state_entry(){
            	
           
                //tell other scripts we are loading the quiz;
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ, "", NULL_KEY);
               sloodlehttpvars = "sloodlecontrollerid=" + (string)sloodlecontrollerid;
                sloodlehttpvars += "&sloodlepwd=" + sloodlepwd;
                sloodlehttpvars += "&sloodlemoduleid=" + (string)sloodlemoduleid;
                sloodlehttpvars += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;
               
            }
            
            link_message(integer sender_num, integer num, string str, key user_key){
                if (num == SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER) {
                   // Make sure the given avatar is allowed to use this object
                    if (!sloodle_check_access_use(user_key)) {
                        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(user_key)], NULL_KEY, "");
                        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE, "", user_key);
                        return;
                    }  
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "starting", [llKey2Name(user_key)], NULL_KEY, "quiz");                                                     
                   //load the quiz
                    first_user=user_key;
                    /*
                    * Tell load_quiz.lslp to load the quiz, it will do so, then pass us a message SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ with all the quiz data
                    * this data will be locked for this hex
                    */
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_LOAD_QUIZ, "", user_key);
                }else 
                //   llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ, (string)quiz_id+"|"+quiz_name+"|"+(string)num_questions+"|"+question_ids_str, user_key);
                if (num == SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ){
                    list data = llParseString2List(str, ["|"], []);
                    quiz_id=llList2Integer(data,0);
                    quiz_name =llList2String(data,1);
                    num_questions= llList2Integer(data,2);
                    question_ids=llParseString2List(llList2String(data,3), [","], []);
                    first_user_active_question= get_current_question_id(user_key);
                    debug(" FIRST USER: "+(string)first_user);
                    first_user=user_key;//record the first user, because in the next state we must initate asking the first question
                    integer prim = get_prim("quiz_name");
                    if (prim!=-1){
                    	sloodle_translation_request("SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM", [GREEN, 1.0,prim], "quiz_name", [quiz_name], "", "hex_quizzer");
                    }
                    
                    
                    state quiz_ready;     
                }    
            }
         }
        // Running the quiz
        state quiz_ready{
            on_rez(integer param){
                llResetScript();
            }
            
            state_entry(){
                
                
                // Make sure we have some questions
                if (num_questions == 0) {
                    sloodle_debug("No questions - cannot run quiz.");
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR, "", first_user);//add to dia
                    state load;//todo add to dia
                    return;
                }
                //ask first users question
                integer user_id=llListFindList(users, [first_user]);
                if (user_id==-1){
                    user_id=add_user(first_user);
                    
                }
                integer user_question_index = llList2Integer(users_question_id_index,user_id);
                
                request_question_from_lsl_pipepline(first_user,user_question_index,num_questions);
                /*
                * request_question will now send a linked message to the question handler script  
                * that looks like: llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG,(string)current_question_id+SEPARATOR+(string)users_question_index+SEPARATOR+(string)num_questions+SEPARATOR+(string)menu_channel+SEPARATOR+sloodleserverroot+sloodle_quiz_url+SEPARATOR+sloodlehttpvars,user_key );
                * the question handler will do an http request, and then send us a linked message back:
                * llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR, qdialogtext+"|"+qdialogoptions_string, user_key);//send back to rezzer so that pie_slices can show hovertext for each option
                * That message will be received by the rezzer script, which will then take the info and
                * populate our hex with the question. 
                */ 
                
                
            }
            
            link_message(integer sender_num, integer num, string str, key user_key){
                //a new user is starting the quiz
                 if (num==SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR){
            		quiz_loaded=TRUE;
                 }else
                 if (num == SLOODLE_CHANNEL_USER_TOUCH||num==SLOODLE_CHANNEL_QUIZ_ASK_QUESTION) {
                 			list data = llParseString2List(str, ["|"], []);
                 			string type = llList2String(data,0);
                 	
                 	
		                   // Make sure the given avatar is allowed to use this object
		                    if (!sloodle_check_access_use(user_key)) {
		                        sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "nopermission:use", [llKey2Name(user_key)], NULL_KEY, "");
		                        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE, "", user_key);
		                        return;
		                    }                
		                    //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "starting", [llKey2Name(user_key)], NULL_KEY, "hex_quizzer");                                                     
		                    integer user_id=llListFindList(users, [user_key]);
		                    if (user_id==-1){
		                        user_id=add_user(user_key);
		                    }
		                    
		                    integer orb= llList2Integer(data,1);
                 			//if this is the center orb, load the quiz for this hex
                 			if (orb==0&&quiz_loaded==FALSE){
		                    	integer user_question_index = llList2Integer(users_question_id_index,user_id);
		                    	//rezzer script will handle the retreived question
		                    	request_question_from_lsl_pipepline(user_key,user_question_index,num_questions);
                 			}
		           }
                }      
                else
                if (num == SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR) {
                    integer user_id=llListFindList(users, [user_key]);
                    integer question_id_index = llList2Integer(users_question_id_index,user_id);
                    float scorechange = (integer)str;
                    if(scorechange>0) {
                           sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "correct", [llKey2Name(user_key)], user_key, "quizzer");
                           integer num_correct = llList2Integer(users_num_correct,user_id);
                        //save the number of questions correct for this user
                        users_num_correct=llListReplaceList(users_num_correct, [num_correct+1], user_id, user_id);
                         // Advance to the next question
                          if (question_id_index < num_questions-1) {
                              users_question_id_index= llListReplaceList(users_question_id_index, [question_id_index+1], user_id, user_id);
                          }
                    }else{
                         sloodle_translation_request(SLOODLE_TRANSLATE_IM, [0], "incorrect",  [llKey2Name(user_key)], user_key, "quizzer");
                         //must a user get an answer correctly to continue? (0=no, 1=yes)
                        if (correctToContinue==0){
                            // Advance to the next question
                            if (question_id_index < num_questions-1) {
                                users_question_id_index= llListReplaceList(users_question_id_index, [question_id_index+1], user_id, user_id);
                            }
                        }
                    }

                    // Are we are at the end of the quiz?
                    if (question_id_index >= num_questions-1) {
                        // Yes - finish off
                        debug("******************************user has finished the quiz");
                        request_finish_quiz_from_lsl_pipeline(user_key);
                        // Do we want to repeat the quiz?
                        if (!doRepeat) {
                            llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_SUCCESS_NOTHING_MORE_TO_DO_WITH_AVATAR, "", user_key );//TODO add to dia
                        }
                        return;
                    }
                    if (askquestionscontinuously==1){
                        integer user_question_index = llList2Integer(users_question_id_index,user_id);
                        request_question_from_lsl_pipepline(user_key,user_question_index,num_questions);
                    }else
                    if (question_id_index+1<=num_questions-1){
                        sloodle_translation_request(SLOODLE_TRANSLATE_IM , [0], "clicktogetnextquestion" , [llKey2Name(user_key)], user_key, "quizzer" );
                       }
                } else 
                if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Is it a reset command?
                    if (str == "do:reset") {
                        llResetScript();
                    }
                    return;
                }                        
                
                // TODO: What happens if loading the question fails?
            }
            
           
           }
                                        

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/quiz-1.0/objects/hexagon_quizzer/assets/hex_multi_user_quiz.lslp


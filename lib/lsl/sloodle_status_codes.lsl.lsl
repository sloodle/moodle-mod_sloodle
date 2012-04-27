/* Sloodle Status Codes

	Copyright (c) 2006-9 Sloodle (various contributors)
    Released under the GNU GPL
    

	This files lists all the status codes we use for sloodle.
	They have been written in LSL format so that you can plunk them into your source
	code if needed. 

	Contributors:
    Edmund Edgar
    Paul Preibisch
    
    http://lslplus.sourceforge.net/
	
*/

integer SLOODLE_CHANNEL_HTTP_RESPONSE = -1639260101  // Tells the sloodle_rezzer_object script to send the contents as an http response, to the key specified as key

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
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION = -1639271112; // This is depricated. Now using SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG            
integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_DEFAULT = -1639271114; //mod quiz script is in state DEFAULT
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_READY = -1639271115; //mod quiz script is in state READY
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER = -1639271116; //mod quiz script is in state CHECK_QUIZ
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING = -1639271117; //mod quiz script is in state quizzing
integer SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE= -1639271118; //user has tried to use the chair but doesnt have permission to do so.
integer SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR = -1639271119; //Tells us to STOP a quiz for the avatar
integer SLOODLE_CHANNEL_QUIZ_UNSEAT_AVATAR = -1639271120;  //sends a message to unseat an avatar
integer SLOODLE_CHANNEL_QUIZ_ERROR_INVALID_QUESION = -1639271121;  //
integer SLOODLE_CHANNEL_QUIZ_SUCCESS_NOTHING_MORE_TO_DO_WITH_AVATAR= -1639271122;
integer SLOODLE_CHANNEL_QUIZ_ERROR_ATTEMPTS_LEFT= -1639271123;  //
integer SLOODLE_CHANNEL_QUIZ_ERROR_NO_QUESTIONS= -1639271124;  //
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_CHAT = -1639271125; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA CHAT.
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG = -1639271126; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_SHARED_MEDIA = -1639271127; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA SHARED MEDIA.
integer SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_SET_ADMIN_URL_CHANNEL= -1639271128; // This is the channel that the scoreboard shouts out its admin URL
integer SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_CHANGE_ADMIN_URL_CHANNEL= -1639271129; // This is the channel that the scoreboard shouts out its admin URL WHEN It has changed due to a region event (lost its url etc)
integer SLOODLE_SCOREBOARD_CONNECT_HUD= -1639271130; // channel which gets sent a linked message by the connect a hud button when it is touched.
integer SLOODLE_SCOREBOARD_CONNECT_HUD_REGION_SAY= -1639271131; // broadcast to the region by the scoreboard when a user presses the connect scoreboard button
integer SLOODLE_OBJECT_INTERACTION= -1639271132; //channel interaction objects speak on
integer SLOODLE_OBJECT_REGISTER_INTERACTION= -1639271133; //channel objects send interactions to the mod_interaction-1.0 script on to be forwarded to server
integer SLOODLE_OBJECT_INTERACTION_SHOUT_COMMAND= -1639271134; //channel interaction object will shout commands to its consituent parts
integer SLOODLE_OBJECT_BLINK= -1639271135; //linked message channel to tell a prim to blink
integer SLOODLE_OBJECT_GIVE_POINTS= -1639271136; //linked message channel to tell an object to give points
integer SLOODLE_LOAD_CURRENT_URL= -1639271137; //send message to shared media to open url that it is currently displaying in a browser.
integer SLOODLE_CHANNEL_DISTRIBUTOR_REQUEST_GIVE_OBJECT = -1639271151; // start the process to give the specified object to the specified avatar, if they are allowed it.
integer SLOODLE_CHANNEL_DISTRIBUTOR_DO_GIVE_OBJECT = 1639271152; // actually do give the specified object to the specified avatar
// Please leave the following line intact to show where the script lives in Subversion:
=======
integer SLOODLE_CHANNEL_SCOREBOARD_UPDATE_COMPLETE = 1639271140;
integer SLOODLE_CHANNEL_SCOREBOARD_SCORES_CONFIG = -1639272000;
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_SET_CELL_INFO=-1639272001; 
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_REMAP_INDICIES=-1639272002;
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_RESET_INDICIES=-1639272003;
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_SET_THICKNESS=-1639272004;
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_SET_COLOR=-1639272005;
integer SLOODLE_CHANNEL_SCOREBOARD_SCORES = 1639272100;

integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_CONFIG = -1639273000;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_SET_CELL_INFO = -1639273001;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_REMAP_INDICIES = -1639273002;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_RESET_INDICIES = -1639273003;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_SET_THICKNESS = -1639273004;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_SET_COLOR = -1639273005;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM = 1639273100;

integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_CONFIG = -1639274000;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_SET_CELL_INFO  = -1639274001;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_REMAP_INDICIES  = -1639274002;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_RESET_INDICIES = -1639274003;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_SET_THICKNESS  = -1639274004;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_SET_COLOR = -1639274005;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY = 1639274100;

integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_CONFIG = -1639275000;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_SET_CELL_INFO = -1639275001;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_REMAP_INDICIES = -1639275002;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_RESET_INDICIES = -1639275003;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_SET_THICKNESS = -1639275004;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_SET_COLOR = -1639275005;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE= 1639275100;
integer SLOODLE_CHANNEL_ZZTEXT_TEXTURE_CONFIG= -1639276000;

integer SLOODLE_CHANNEL_OPEN_IN_BROWSER = -1639277000;

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: lib/lsl/sloodle_status_codes.lsl.lsl 

//
// The line above should be left blank to avoid script errors in OpenSim.

// Sloodle quiz chair UI
// Controls the movement of the quiz chair, based on linked messages from the main script.
// It should be possible to radically alter the object, eg. change it into an aeroplane etc - by altering this script.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-9 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Edmund Edgar
//  Paul Preibisch
//  Peter R. Bloomfield
//

integer SLOODLE_CHANNEL_OBJECT_DIALOG= -3857343;

integer SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR = -1639271102; //Tells us to start a quiz for the avatar, if possible.; Ordinary quiz chair will have a second script that detects and avatar sitting on it and sends it. Awards-integrated version waits for a game ID to be set before doing this.
integer SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR = -1639271103; //Sent by main quiz script to tell UI scripts that quiz has started for avatar with key
integer SLOODLE_CHANNEL_1QUIZ_COMPLETED_FOR_AVATAR = -1639271104; //Sent by main quiz script to tell UI scripts that quiz has finished for avatar with key, with x/y correct in string
integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text
integer SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR = -1639271106;  //Sent by main quiz script to tell UI scripts that question has been answered by avatar with key. String contains selected option ID + "|" + option text + "|"
integer SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION = -1639271107;
integer SLOODLE_CHANNEL_QUIZ_LOADED_QUESTION = -1639271108;
integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
integer SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ = -1639271110;
integer SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION = -1639271111;           
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION = -1639271112; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key.
integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_DEFAULT = -1639271114; //mod quiz script is in state DEFAULT
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING = -1639271117; //mod quiz script is in state quizzing
integer SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR = -1639271119; //Tells us to STOP a quiz for the avatar
integer SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE= -1639271118; //user has tried to use the chair but doesnt have permission to do so.
integer SLOODLE_CHANNEL_QUIZ_SUCCESS_NOTHING_MORE_TO_DO_WITH_AVATAR= -1639271122;
integer SLOODLE_CHANNEL_QUIZ_FAILURE_NOTHING_MORE_TO_DO_WITH_AVATAR= -1639271123; 
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
vector startingposition=<0,0,0>;
integer doPlaySound = 0;
integer doRepeat = 0; // whether we should run through the questions again when we're done
key sitter;
list users;


// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str){
    list bits = llParseString2List(str,["|" ],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);               
    if (name == "set:sloodleplaysound") doPlaySound = (integer)llList2String (bits,1);
    return 1;
}



// Play a sound as audio feedback
play_sound( float multiplier){
    // Do nothing if sound is disabled
    if (doPlaySound == 0) {
        return ;
    }
    string sound_file;
    float volume;
       
    // Determine what our sound file and volume should be
    if (multiplier > 0) {
        sound_file = "Correct" ;
    } else {
        sound_file = "Incorrect" ;
        multiplier = multiplier * -1;
    }

    // Cap our volume
    if (multiplier > 1) {
        volume = 1.0;
    } else {
        volume = ( float )multiplier;
    }   
           
    // Make sure the sound file exists, and then play it
    if ( llGetInventoryType(sound_file) == INVENTORY_SOUND ) {
        llTriggerSound (sound_file,multiplier);
       
    }
}

default{
    on_rez( integer start_param) {
        llResetScript();
    }
    state_entry() {
     
   
    }
    link_message( integer sender_num, integer num, string str, key id){
       
       
      
       	if (num == SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR) {
       
            play_sound( ( float)str );  
        } else 
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List (str, ["\n" ], []);
            integer numlines = llGetListLength (lines);
            integer i = 0;
            for (i=0; i < numlines; i++) {
                sloodle_handle_command(llList2String (lines, i));
            }
        }
    }
    touch_start(integer number_of_times_clicked) {
    	integer i=0;
    	key user_key;
    	for (i=0;i<number_of_times_clicked;i++){
    		llMessageLinked(LINK_SET, SLOODLE_CHANNEL_USER_TOUCH,"", user_key);
    	}
    }    
}


// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/quiz-1.0/objects/default/assets/sloodle_quiz_ui.lslp

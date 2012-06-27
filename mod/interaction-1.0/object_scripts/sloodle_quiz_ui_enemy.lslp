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
vector AVCLASSBLUE= <0.06274,0.247058,0.35294>;
vector AVCLASSLIGHTBLUG=<0.8549,0.9372,0.9686>;//#daeff7
integer SLOODLE_ROUTER=-1639271139;
integer SLOODLE_PLAYERSERVER=-1639271140;
key MYENEMY;
string MYSTATUS;
integer SLOODLE_CHANNEL_OBJECT_DIALOG= -3857343;
integer SLOODLE_CHANNEL_QUIZ_SUCCESS_NOTHING_MORE_TO_DO_WITH_AVATAR= -1639271122;
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
integer SLOODLE_CHANNEL_QUIZ_UNSEAT_AVATAR = -1639271120;  
integer SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR = -1639271104; //Sent by main quiz script to tell UI scripts that quiz has finished for avatar with key, with x/y correct in string
vector startingposition=<0,0,0>;
integer doPlaySound = 0;
key sitter; 
integer counter=0; 

debug(integer channel, string message){
    string c;
        if (channel==SLOODLE_ROUTER){
        c="SLOODLE_ROUTER";
        llSay(0,"Message came in on: "+c+" : "+message);
        }else
        if (channel==SLOODLE_PLAYERSERVER){
        c="SLOODLE_PLAYERSERVER";
        llSay(0,"Message came in on: "+c+" : "+message);
        }else{
        llSay(0,message);
        }
}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);                
    if (name == "set:sloodleplaysound") doPlaySound = (integer)llList2String(bits,1);
    return 1;
}

// Move the chair up or down as visual feedback
move_vertical(float multiplier)
{
    vector position = llGetPos();
    position.z += 0.5 * multiplier;
    llSetPos(position);
}

// Play a sound as audio feedback
play_sound(float multiplier)
{
    // Do nothing if sound is disabled
    if (doPlaySound == 0) {
        return;
    }
    string sound_file;
    float volume;
        
    // Determine what our sound file and volume should be
    if (multiplier > 0) {
        sound_file = "Correct";
    } else {
        sound_file = "Incorrect";
        multiplier = multiplier * -1;
    }

    // Cap our volume
    if (multiplier > 1) {
        volume = 1.0;
    } else {
        volume = (float)multiplier;
    }    
            
    // Make sure the sound file exists, and then play it
    if (llGetInventoryType(sound_file) == INVENTORY_SOUND) {
        llTriggerSound(sound_file,multiplier);
        
    }
}
key MYGUEST;
integer TIMELIMIT=60;
default
{
    on_rez(integer start_param) {
        llResetScript();
        MYSTATUS="AVAILABLE";
        llSetText(MYSTATUS, GREEN, 1);
    }
    state_entry() {
      llListen(SLOODLE_PLAYERSERVER, "", "", "");
        MYSTATUS="AVAILABLE";
        llSetText(MYSTATUS, GREEN, 1);
        MYGUEST=NULL_KEY;
    }
    listen(integer channel, string name, key id, string message) {
      list data;
      debug(channel,message);
      if (channel==SLOODLE_PLAYERSERVER){
          data= llParseString2List(message, ["|"], []);
      }
      string cmd = llList2String(data,0);
     if (cmd=="ARE YOU AVAILABLE?"){
             llRegionSayTo(id,SLOODLE_ROUTER,MYSTATUS);
     }else
     if (cmd=="STOP GAME"){
         MYSTATUS="AVAILABLE";
         counter=0;
         llSetTimerEvent(0);
        llSetText(MYSTATUS, GREEN, 1);
        MYGUEST=NULL_KEY;    
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR, "", NULL_KEY);
     }
     if (cmd=="ASK QUESTION"){
         llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION , "", NULL_KEY);
         MYENEMY=llList2Key(data,1);
         debug(0,"I WAS TOLD TO ASK A QUESTION: "+message); 
     } 
     if (cmd=="GUEST TRANSFER"){
        llSetTimerEvent(1);
        MYSTATUS="BUSY";
        MYGUEST = llList2Key(data,1);
        llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR, "", MYGUEST);
        llSleep(3);
        llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION , "", NULL_KEY);
        MYENEMY=NULL_KEY;
     } 
    }
    link_message(integer sender_num, integer num, string str, key id)
    { 
        if (num==SLOODLE_CHANNEL_QUIZ_UNSEAT_AVATAR||num==SLOODLE_CHANNEL_QUIZ_SUCCESS_NOTHING_MORE_TO_DO_WITH_AVATAR){
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR, "", NULL_KEY);
                MYSTATUS="AVAILABLE";
                MYGUEST=NULL_KEY;
                llSetText(MYSTATUS, GREEN, 1);
                counter=0;
                llSetTimerEvent(0);
                
        }else
        if (num == SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR){
                llRegionSay(SLOODLE_ROUTER,"QUIZ FINISHED|"+(string)MYGUEST);
                MYSTATUS="AVAILABLE";
                counter=0;
                MYGUEST=NULL_KEY;
                llSetText(MYSTATUS, GREEN, 1);
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR, "", NULL_KEY);
                llSetTimerEvent(0);
        }else
        if (num == SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION) {
        
        } else if (num == SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR) {
        	if (MYENEMY!=NULL_KEY){
            	llRegionSayTo(MYENEMY,SLOODLE_PLAYERSERVER,"EXPLODE|"+(string)MYGUEST);
        	}
        }else if (num == SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING){
            
        }else if (num==SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE){
            if (id!=NULL_KEY){
                MYSTATUS="AVAILABLE";
                MYGUEST=NULL_KEY;
                llSetTimerEvent(0);
                counter=0;
                llSetText(MYSTATUS, GREEN, 1);
            }
        } 
        else if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (i=0; i < numlines; i++) {
                sloodle_handle_command(llList2String(lines, i));
            }
        }
    }
    timer() {
        counter++;
        llSetText(MYSTATUS+"\n"+llKey2Name(MYGUEST)+"\nGAME TIME LEFT: "+(string)(TIMELIMIT-counter), RED, 1);
        if ((TIMELIMIT-counter)<0) {
            counter=0;
            llSetTimerEvent(0);
            MYSTATUS="AVAILABLE";
            MYGUEST=NULL_KEY;
            llSetText(MYSTATUS, GREEN, 1);
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR, "", NULL_KEY);
        }
    }
    
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/interaction-1.0/object_scripts/sloodle_quiz_ui_enemy.lslp 

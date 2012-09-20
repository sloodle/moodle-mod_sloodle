
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG = -1639271126; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
list question_scripts = [0,0,0,0,0,0];
integer len;
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG0 = -1700000000; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG1 = -1700000001; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG2 = -1700000002; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG3= -1700000003; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG4 = -1700000004; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG5 = -1700000004; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG6 = -1700000004; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.


default {
    state_entry() {
        llOwnerSay("Hello Scripter");
    }
    touch_start(integer num_detected) {
    	llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG, "", "");
    
    }
}

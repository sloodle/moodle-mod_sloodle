// LSL script generated: mod.quiz-1.0.sloodle_quiz_ui.lslp Tue Nov 15 15:49:28 Tokyo Standard Time 2011
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

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;

integer SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR = -1639271102;
integer SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION = -1639271111;
integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113;
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING = -1639271117;
integer SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR = -1639271119;
integer SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE = -1639271118;
integer SLOODLE_CHANNEL_QUIZ_UNSEAT_AVATAR = -1639271120;
vector startingposition = <0,0,0>;
integer doPlaySound = 0;
key sitter;
move_to_start(vector startingposition){
    vector position = llGetPos();
    if ((startingposition == <0,0,0>)) {
        (startingposition = position);
    }
    (position.z = startingposition.z);
    llSetPos(position);
}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str){
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);
    if ((name == "set:sloodleplaysound")) (doPlaySound = ((integer)llList2String(bits,1)));
    return 1;
}

// Move the chair up or down as visual feedback
move_vertical(float multiplier){
    vector position = llGetPos();
    (position.z += (0.5 * multiplier));
    llSetPos(position);
}

// Play a sound as audio feedback
play_sound(float multiplier){
    if ((doPlaySound == 0)) {
        return;
    }
    string sound_file;
    float volume;
    if ((multiplier > 0)) {
        (sound_file = "Correct");
    }
    else  {
        (sound_file = "Incorrect");
        (multiplier = (multiplier * (-1)));
    }
    if ((multiplier > 1)) {
        (volume = 1.0);
    }
    else  {
        (volume = ((float)multiplier));
    }
    if ((llGetInventoryType(sound_file) == INVENTORY_SOUND)) {
        llTriggerSound(sound_file,multiplier);
    }
}

default {

	on_rez(integer start_param) {
        llResetScript();
    }

	state_entry() {
        (startingposition = llGetPos());
    }

    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == SLOODLE_CHANNEL_QUIZ_UNSEAT_AVATAR)) {
            llUnSit(id);
        }
        else  if ((num == SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION)) {
            move_to_start(startingposition);
        }
        else  if ((num == SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR)) {
            move_vertical(((float)str));
            play_sound(((float)str));
        }
        else  if ((num == SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_QUIZZING)) {
            move_to_start(startingposition);
        }
        else  if ((num == SLOODLE_CHANNEL_QUIZ_NO_PERMISSION_USE)) {
            if ((id != NULL_KEY)) {
                llUnSit(id);
            }
        }
        else  if ((num == SLOODLE_CHANNEL_OBJECT_DIALOG)) {
            list lines = llParseString2List(str,["\n"],[]);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for ((i = 0); (i < numlines); (i++)) {
                sloodle_handle_command(llList2String(lines,i));
            }
        }
    }

    changed(integer change) {
        if ((change & CHANGED_LINK)) {
            (sitter = llAvatarOnSitTarget());
            if ((sitter != NULL_KEY)) {
                llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR,"",sitter);
                move_to_start(startingposition);
            }
            else  {
                llMessageLinked(LINK_SET,SLOODLE_CHANNEL_QUIZ_STOP_FOR_AVATAR,"",sitter);
                move_to_start(startingposition);
            }
        }
    }
}

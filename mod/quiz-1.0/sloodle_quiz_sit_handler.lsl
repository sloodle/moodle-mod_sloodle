// Sloodle quiz chair sit handler
// Detects the avatar sitting on it, and sends the main script a message to tell it to give them a quiz.
// This is done in a seperate script so that it can be easily switched out for scripts that want to do something else before the quiz starts.
// Specifically, the awards script wants to make sure it has a Game ID before starting the quiz.
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2006-10 Sloodle (various contributors)
// Released under the GNU GPL
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield
//

integer SLOODLE_CHANNEL_QUIZ_FETCH_FEEDBACK = -1639271101;
integer SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR = -1639271102;
integer SLOODLE_CHANNEL_QUIZ_STARTED_FOR_AVATAR = -1639271103;
integer SLOODLE_CHANNEL_QUIZ_COMPLETED_FOR_AVATAR = -1639271104;
integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105;
integer SLOODLE_CHANNEL_QUESTION_ANSWERED_AVATAR = -1639271106;
integer SLOODLE_CHANNEL_QUIZ_LOADING_QUESTION = -1639271107;
integer SLOODLE_CHANNEL_QUIZ_LOADED_QUESTION = -1639271108;
integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
integer SLOODLE_CHANNEL_QUIZ_LOADED_QUIZ = -1639271110;
integer SLOODLE_CHANNEL_QUIZ_GO_TO_STARTING_POSITION = -1639271111;
        
key sitter;

default
{
        
    changed(integer change)
    {
        // Something changed - was it a link?
        if (change & CHANGED_LINK) {
            llSleep(0.5); // Allegedly llUnSit works better with this delay
                    
            // Has an avatar sat down?
            if (llAvatarOnSitTarget() != NULL_KEY) {
                        
                // Store the new sitter
                sitter = llAvatarOnSitTarget();

                llMessageLinked( LINK_SET, SLOODLE_CHANNEL_QUIZ_START_FOR_AVATAR, "START QUIZ", sitter ); // the string paramter is just for debugging

            }
        }
    }
    
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/quiz-1.0/sloodle_quiz_sit_handler.lsl 

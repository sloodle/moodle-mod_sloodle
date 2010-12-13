integer SLOODLE_CHANNEL_QUIZ_MULTIPLE_MY_NUMBER = -1639270062;
integer SLOODLE_CHANNEL_QUIZ_MULTIPLE_QUESTION = -1639270063;
integer SLOODLE_CHANNEL_QUIZ_MULTIPLE_CORRECT = -1639270064;
integer SLOODLE_CHANNEL_QUIZ_MULTIPLE_INCORRECT = -1639270065;
integer SLOODLE_CHANNEL_QUIZ_MULTIPLE_CHOICE_SELECTED = -1639270066;

string g_choice_number = "";
string g_value = "";
key g_sitter = NULL_KEY;

refresh_text()
{
    string text = "";
    if ( (g_choice_number != "") && (g_value != "") ) {
        text = "("+g_choice_number+") "+g_value;        
    }
    llSetText( text, <0,0,1.0>, 1.0 );
}

refresh_appearance()
{
    refresh_text();
    if (g_value == "") {
        llSetScale(<0.01,0.01,0.01>);
    } else {
        llSetScale(<0.5,0.5,0.5>);
    }
}

remove_choice()
{
    g_value = "";
}

integer handle_success(string feedback)
{
    llSleep(3);
    if (g_sitter != NULL_KEY) {
        llPlaySound("ed124764-705d-d497-167a-182cd9fa2e6c",1);
        llSay(0,feedback);
        //victory_roll();
        vector origpos = llGetPos();
        vector newpos = origpos;
        newpos.z = origpos.z + 2;
        llSetPos(newpos);
        llSleep(5);
        llUnSit(g_sitter);
        llSetPos(origpos);
    }
    return 1;
}

integer handle_failure(string feedback)
{
    if (g_sitter != NULL_KEY) {
        llSay(0,feedback);
        llPlaySound("85cda060-b393-48e6-81c8-2cfdfb275351",1);
        llUnSit(g_sitter);
    }
    return 1;
}

default
{
    state_entry()
    {
        refresh_appearance();
        llSitTarget(<0.0, 0.0, 0.8>, ZERO_ROTATION);
        llSetSitText("Choose");
    }
    changed(integer change) {
        
        if (change & CHANGED_LINK) { 
        
            if (g_sitter != llAvatarOnSitTarget()) {                
                g_sitter = llAvatarOnSitTarget();
            
                if (g_sitter != NULL_KEY) {            
                    llMessageLinked(LINK_ALL_OTHERS,SLOODLE_CHANNEL_QUIZ_MULTIPLE_CHOICE_SELECTED, g_choice_number, g_sitter);
                }
            }
        }
        
    }
    link_message(integer source, integer num, string str, key id) {    
        if (num == SLOODLE_CHANNEL_QUIZ_MULTIPLE_MY_NUMBER) {
            g_choice_number = str;
            refresh_appearance();                     
        } else if (num == SLOODLE_CHANNEL_QUIZ_MULTIPLE_QUESTION) { 
            g_value = str;
            refresh_appearance();
        } else if (num == SLOODLE_CHANNEL_QUIZ_MULTIPLE_CORRECT) {
            handle_success(str);
            remove_choice();
            refresh_appearance();
        } else if (num == SLOODLE_CHANNEL_QUIZ_MULTIPLE_INCORRECT) {
            handle_failure(str);
            remove_choice();
            refresh_appearance();
        }
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/quiz_pile_on-1.0/sloodle_quiz_pile_on_choice.lsl 

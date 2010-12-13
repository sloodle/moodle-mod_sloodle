// LSL script generated: QUIZ CHAIR.lsl.quiz-1.0.lsl-communicates-with-scoreboard.award_sloodle_setup_notecard.lslp Thu Apr 15 13:22:35 Pacific Daylight Time 2010
// Sloodle configuration notecard reader
// This script has been modified so that it also reads a notecard called sloodle_award_config
// It then reads a configuration notecard and transmits the data via link messages to other scripts
// If the notecard changes, then it automatically resets.
//
// Part of the Sloodle project (www.sloodle.org)
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL v3
//
// Contributors:
//  Edmund Edgar
//  Peter R. Bloomfield
// Paul Preibisch
//



integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857353;
string SLOODLE_CONFIG_NOTECARD = "sloodle_config";
string SLOODLE_AWARD_CONFIG_NOTECARD = "sloodle_award_config";
string SLOODLE_EOF = "sloodleeof";

key sloodle_notecard_key = NULL_KEY;
integer sloodle_notecard_line = 0;

string COMMENT_PREFIX = "//";

key latestnotecard = NULL_KEY;



///// TRANSLATION /////

// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";

// Send a translation request link message
sloodle_translation_request(string output_method,list output_params,string string_name,list string_params,key keyval,string batch){
    llMessageLinked(LINK_THIS,SLOODLE_CHANNEL_TRANSLATION_REQUEST,((((((((output_method + "|") + llList2CSV(output_params)) + "|") + string_name) + "|") + llList2CSV(string_params)) + "|") + batch),keyval);
}

///// ----------- /////


///// FUNCTIONS /////


sloodle_tell_other_scripts(string source,string msg){
    sloodle_debug(("notecard sending message to other scripts: " + msg));
    llMessageLinked(LINK_SET,SLOODLE_CHANNEL_OBJECT_DIALOG,((("SOURCE:" + source) + "|") + msg),NULL_KEY);
}

sloodle_debug(string msg){
}

sloodle_handle_command(string str){
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);
    string value = "";
    if ((numbits >= 2)) llList2String(bits,1);
    if ((name == "do:reset")) {
        sloodle_debug("Resetting configuration notecard reader");
        llResetScript();
    }
    else  if ((name == "do:requestconfig")) {
        llResetScript();
        sloodle_start_reading_notecard();
    }
}

sloodle_start_reading_notecard(){
    if ((llGetInventoryType(SLOODLE_CONFIG_NOTECARD) == INVENTORY_NOTECARD)) {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT,[<0.0,1.0,0.0>,1.0],"readingconfignotecard",[],NULL_KEY,"");
        sloodle_debug("starting reading notecard");
        (sloodle_notecard_line = 0);
        (sloodle_notecard_key = llGetNotecardLine("sloodle_config",0));
        (latestnotecard = llGetInventoryKey(SLOODLE_CONFIG_NOTECARD));
    }
    else  {
        sloodle_debug((("No notecard called " + SLOODLE_CONFIG_NOTECARD) + " found - skipping notecard configuration"));
        (latestnotecard = NULL_KEY);
    }
}

sloodle_start_reading_award_notecard(){
    if ((llGetInventoryType(SLOODLE_AWARD_CONFIG_NOTECARD) == INVENTORY_NOTECARD)) {
        sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT,[<0.0,1.0,0.0>,1.0],"readingawardconfignotecard",[],NULL_KEY,"award");
        sloodle_debug("starting reading award notecard");
        (sloodle_notecard_line = 0);
        (sloodle_notecard_key = llGetNotecardLine("sloodle_award_config",0));
        (latestnotecard = llGetInventoryKey(SLOODLE_AWARD_CONFIG_NOTECARD));
    }
    else  {
        sloodle_debug((("No notecard called " + SLOODLE_AWARD_CONFIG_NOTECARD) + " found - skipping notecard configuration"));
        (latestnotecard = NULL_KEY);
    }
}
default {

    on_rez(integer start_param) {
        llResetScript();
    }

    
    state_entry() {
        llSleep(0.2);
        sloodle_start_reading_notecard();
    }

    
    dataserver(key requested,string data) {
        if ((requested == sloodle_notecard_key)) {
            (sloodle_notecard_key = NULL_KEY);
            if ((data != EOF)) {
                string trimmeddata = llStringTrim(data,STRING_TRIM_HEAD);
                if ((llSubStringIndex(trimmeddata,COMMENT_PREFIX) != 0)) sloodle_tell_other_scripts("sloodle_config",data);
                (sloodle_notecard_line++);
                (sloodle_notecard_key = llGetNotecardLine("sloodle_config",sloodle_notecard_line));
            }
            else  {
                llSleep(0.2);
                state readAwardsConfig;
            }
        }
    }

    
    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == DEBUG_CHANNEL)) return;
        if ((num == SLOODLE_CHANNEL_OBJECT_DIALOG)) {
            sloodle_handle_command(str);
        }
    }

    
    changed(integer change) {
        if (((change & CHANGED_INVENTORY) && (llGetInventoryType(SLOODLE_CONFIG_NOTECARD) == INVENTORY_NOTECARD))) {
            if ((llGetInventoryKey(SLOODLE_CONFIG_NOTECARD) != latestnotecard)) llResetScript();
        }
    }
}

state readAwardsConfig {

state_entry() {
        llSleep(0.2);
        (sloodle_notecard_line = 0);
        sloodle_start_reading_award_notecard();
    }

    
    dataserver(key requested,string data) {
        if ((requested == sloodle_notecard_key)) {
            (sloodle_notecard_key = NULL_KEY);
            if ((data != EOF)) {
                string trimmeddata = llStringTrim(data,STRING_TRIM_HEAD);
                if ((llSubStringIndex(trimmeddata,COMMENT_PREFIX) != 0)) sloodle_tell_other_scripts("sloodle_award_config",data);
                (sloodle_notecard_line++);
                (sloodle_notecard_key = llGetNotecardLine("sloodle_award_config",sloodle_notecard_line));
            }
            else  {
                llSleep(0.2);
                sloodle_tell_other_scripts("sloodle_config",SLOODLE_EOF);
                llSetText("",<0.0,0.0,0.0>,0.0);
            }
        }
    }

    
    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == DEBUG_CHANNEL)) return;
        if ((num == SLOODLE_CHANNEL_OBJECT_DIALOG)) {
            sloodle_handle_command(str);
        }
    }

    
    changed(integer change) {
        if (((change & CHANGED_INVENTORY) && (llGetInventoryType(SLOODLE_AWARD_CONFIG_NOTECARD) == INVENTORY_NOTECARD))) {
            if ((llGetInventoryKey(SLOODLE_AWARD_CONFIG_NOTECARD) != latestnotecard)) llResetScript();
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/quiz-1.0/lsl-communicates-with-scoreboard/award_sloodle_setup_notecard.lsl 

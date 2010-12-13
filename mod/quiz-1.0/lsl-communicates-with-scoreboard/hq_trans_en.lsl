// LSL script generated: QUIZ CHAIR.lsl.quiz-1.0.lsl-communicates-with-scoreboard.hq_trans_en.lslp Thu Apr 15 13:22:35 Pacific Daylight Time 2010
// Standard translation script for Sloodle.
// Contains the common, re-usable words and phrases.
//
// The "locstrings" list is pairs of strings.
// The first of each pair is the name, and second is the translation.
//
// This script is part of the Sloodle project.
// Copyright (c) 2008 Sloodle (various contributors)
// Released under the GNU GPL v3
//
// Contributors:
//  Peter R. Bloomfield
//  Paul Preibisch - aka Fire Centaur
//

// Note: where a translation string contains {{x}} (where x is a number),
//  it means that a parameter can be inserted. Please make sure to include these
//  parameters in the appropriate location in your translation.
// It may be sensible to add comments after your string to indicate what its parameters mean.
// NOTE: parameter numbering starts at 0 (unlike previous versions, which started at 1).

// Translations can be requested by sending a link message on the SLOODLE_CHANNEL_TRANSLATION_REQUEST channel.
// It is advisable simply to use the "sloodle_translation_request" function provided in this script.


///// TRANSLATION /////

// Localization batch - indicates the purpose of this file
string mybatch = "hq";


// List of string names and translation pairs.
// The name is the first of each pair, and should not be translated.
// The second of each pair is the translation.
// Additional comments are sometimes given afterward to aid translations.
list locstrings = ["apiconfigurationreceived","Received API Configuration"];

///// ----------- /////


// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;
integer SETTEXT_CHANNEL = -776644;
// Translation output methods
string SLOODLE_TRANSLATE_LINK = "link";
string SLOODLE_TRANSLATE_HOVER_TEXT_BASIC = "hovertextbasic";
string SLOODLE_TRANSLATE_SAY = "say";
string SLOODLE_TRANSLATE_WHISPER = "whisper";
string SLOODLE_TRANSLATE_SHOUT = "shout";
string SLOODLE_TRANSLATE_REGION_SAY = "regionsay";
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";
string SLOODLE_TRANSLATE_DIALOG = "dialog";
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";
string SLOODLE_TRANSLATE_LOAD_URL_PARALLEL = "loadurlpar";
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";
string SLOODLE_TRANSLATE_IM = "instantmessage";


// Used for sending parallel URL loading messages
integer SLOODLE_CHANNEL_OBJECT_LOAD_URL = -1639270041;

// Send a translation response link message
sloodle_translation_response(integer target,string name,string translation){
    llMessageLinked(target,SLOODLE_CHANNEL_TRANSLATION_RESPONSE,((((name + "|") + translation) + "|") + mybatch),NULL_KEY);
}

// Get the translation of a particular string
string sloodle_get_string(string name){
    integer numstrings = llGetListLength(locstrings);
    integer pos = llListFindList(locstrings,[name]);
    if (((pos % 2) == 0)) {
        if (((pos + 1) < numstrings)) return llList2String(locstrings,(pos + 1));
        (pos = (-1));
    }
    if ((pos < 0)) return (("[[" + name) + "]]");
    (pos += 1);
    for (; (pos < numstrings); (pos += 2)) {
        if ((llList2String(locstrings,pos) == name)) {
            if (((pos + 1) < numstrings)) return llList2String(locstrings,(pos + 1));
            (pos = numstrings);
        }
    }
    return (("[[" + name) + "]]");
}

// Send a debug link message
sloodle_debug(string msg){
    llMessageLinked(LINK_THIS,DEBUG_CHANNEL,msg,NULL_KEY);
}


// Get a formatted translation of a string
string sloodle_get_string_f(string name,list params){
    string str = sloodle_get_string(name);
    integer numparams = llGetListLength(params);
    integer curparamnum = 0;
    string curparamtok = "{{x}}";
    integer curparamtoklength = 0;
    string curparamstr = "";
    integer tokpos = (-1);
    for (; (curparamnum < numparams); (curparamnum++)) {
        (curparamtok = (("{{" + ((string)curparamnum)) + "}}"));
        (curparamtoklength = llStringLength(curparamtok));
        (curparamstr = llList2String(params,curparamnum));
        if (((llSubStringIndex(curparamstr,"{{") < 0) && (llSubStringIndex(curparamstr,"}}") < 0))) {
            while (((tokpos = llSubStringIndex(str,curparamtok)) >= 0)) {
                (str = llDeleteSubString(str,tokpos,((tokpos + curparamtoklength) - 1)));
                (str = llInsertString(str,tokpos,curparamstr));
            }
        }
    }
    return str;
}


///// STATES /////

default {

    state_entry() {
    }

    
    link_message(integer sender_num,integer num,string str,key id) {
        if ((num == SLOODLE_CHANNEL_TRANSLATION_REQUEST)) {
            list fields = llParseStringKeepNulls(str,["|"],[]);
            integer numfields = llGetListLength(fields);
            string batch = "";
            if ((numfields > 4)) (batch = llList2String(fields,4));
            if ((batch != mybatch)) return;
            if ((numfields < 3)) {
                sloodle_debug("ERROR: Insufficient fields for translation of string.");
                return;
            }
            string output_method = llList2String(fields,0);
            list output_params = llCSV2List(llList2String(fields,1));
            integer num_output_params = llGetListLength(output_params);
            string string_name = llList2String(fields,2);
            list string_params = [];
            if ((numfields > 3)) {
                string string_param_text = llList2String(fields,3);
                if ((string_param_text != "")) (string_params = llCSV2List(string_param_text));
            }
            string trans = "";
            if ((string_name != "")) {
                if ((llGetListLength(string_params) == 0)) {
                    (trans = sloodle_get_string(string_name));
                }
                else  {
                    (trans = sloodle_get_string_f(string_name,string_params));
                }
            }
            if ((output_method == SLOODLE_TRANSLATE_LINK)) {
                sloodle_translation_response(sender_num,string_name,trans);
            }
            else  if ((output_method == SLOODLE_TRANSLATE_SAY)) {
                if ((num_output_params > 0)) llSay(llList2Integer(output_params,0),trans);
                else  sloodle_debug((("ERROR: Insufficient output parameters to say string \"" + string_name) + "\"."));
            }
            else  if ((output_method == SLOODLE_TRANSLATE_WHISPER)) {
                if ((num_output_params > 0)) llWhisper(llList2Integer(output_params,0),trans);
                else  sloodle_debug((("ERROR: Insufficient output parameters to whisper string \"" + string_name) + "\"."));
            }
            else  if ((output_method == SLOODLE_TRANSLATE_SHOUT)) {
                if ((num_output_params > 0)) llShout(llList2Integer(output_params,0),trans);
                else  sloodle_debug((("ERROR: Insufficient output parameters to shout string \"" + string_name) + "\"."));
            }
            else  if ((output_method == SLOODLE_TRANSLATE_REGION_SAY)) {
                if ((num_output_params > 0)) llRegionSay(llList2Integer(output_params,0),trans);
                else  sloodle_debug((("ERROR: Insufficient output parameters to region-say string \"" + string_name) + "\"."));
            }
            else  if ((output_method == SLOODLE_TRANSLATE_OWNER_SAY)) {
                llOwnerSay(trans);
            }
            else  if ((output_method == SLOODLE_TRANSLATE_DIALOG)) {
                if ((id == NULL_KEY)) {
                    sloodle_debug((("ERROR: Non-null key value required to show dialog with string \"" + string_name) + "\"."));
                    return;
                }
                if ((num_output_params >= 2)) {
                    integer channel = llList2Integer(output_params,0);
                    list buttons = llList2List(output_params,1,12);
                    llDialog(id,trans,buttons,channel);
                }
                else  sloodle_debug((("ERROR: Insufficient output parameters to show dialog with string \"" + string_name) + "\"."));
            }
            else  if ((output_method == SLOODLE_TRANSLATE_LOAD_URL)) {
                if ((id == NULL_KEY)) {
                    sloodle_debug((("ERROR: Non-null key value required to load URL with string \"" + string_name) + "\"."));
                    return;
                }
                if ((num_output_params >= 1)) llLoadURL(id,trans,llList2String(output_params,0));
                else  sloodle_debug((("ERROR: Insufficient output parameters to load URL with string \"" + string_name) + "\"."));
            }
            else  if ((output_method == SLOODLE_TRANSLATE_LOAD_URL_PARALLEL)) {
                if ((id == NULL_KEY)) {
                    sloodle_debug((("ERROR: Non-null key value required to load URL with string \"" + string_name) + "\"."));
                    return;
                }
                if ((num_output_params >= 1)) llMessageLinked(LINK_THIS,SLOODLE_CHANNEL_OBJECT_LOAD_URL,llList2String(output_params,0),id);
                else  sloodle_debug((("ERROR: Insufficient output parameters to load URL with string \"" + string_name) + "\"."));
            }
            else  if ((output_method == SLOODLE_TRANSLATE_HOVER_TEXT)) {
                if ((num_output_params >= 2)) llSetText(trans,((vector)llList2String(output_params,0)),((float)llList2String(output_params,1)));
                else  sloodle_debug((("ERROR: Insufficient output parameters to show hover text with string \"" + string_name) + "\"."));
            }
            else  if ((output_method == SLOODLE_TRANSLATE_IM)) {
                if ((id == NULL_KEY)) {
                    sloodle_debug((("ERROR: Non-null key value required to send IM with string \"" + string_name) + "\"."));
                    return;
                }
                llInstantMessage(id,trans);
            }
            else  if ((output_method == SLOODLE_TRANSLATE_HOVER_TEXT_BASIC)) {
                llMessageLinked(LINK_SET,SETTEXT_CHANNEL,((((("DISPLAY::top display|STRING::Sloodle Award System Error: " + trans) + "|COLOR::") + llList2String(output_params,0)) + "|ALPHA::") + llList2String(output_params,1)),NULL_KEY);
            }
            else  {
                sloodle_debug((("ERROR: unrecognised output method \"" + output_method) + "\"."));
            }
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/quiz-1.0/lsl-communicates-with-scoreboard/hq_trans_en.lsl 

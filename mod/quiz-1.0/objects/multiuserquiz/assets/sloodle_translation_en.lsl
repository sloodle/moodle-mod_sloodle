// LSL script generated: mod.quiz-1.0.objects.quizzer.assets.sloodle_translation_en.lslp Mon Sep 10 11:31:42 Tokyo Standard Time 2012
// Standard translation script for Sloodle.
// Contains the common, re-usable words and phrases.
//
// The "locstrings" list is pairs of strings.
// The first of each pair is the name, and second is the translation.
//
// This script is part of the Sloodle project.
// Copyright (c) 2008-9 Sloodle (various contributors)
// Released under the GNU GPL v3
//
// Contributors:
//  Peter R. Bloomfield
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
string mybatch = "";


// List of string names and translation pairs.
// The name is the first of each pair, and should not be translated.
// The second of each pair is the translation.
// Additional comments are sometimes given afterward to aid translations.
list locstrings = ["yes","Yes","no","No","on","On","off","Off","enabled","Enabled","disabled","Disabled","webconfigmenu","Sloodle Web-Configuration Menu\n\n{{0}} = Access web-configuration page\n{{1}} = Download configuration","configlink","Use this link to configure the object.","chatserveraddress","Please chat the address of your Moodle site, without a trailing slash. For example: http://www.yoursite.blah/moodle","waitingforserveraddress","Waiting for Moodle site address.\nPlease chat it on channel 0 or 1.","checkingserverat","Checking Moodle site at:\n{{0}}","sendingconfig","Sending configuration data...","touchforwebconfig","Touch me to start web-configuration","userauthurl","Please login to Moodle with this URL to authorize the object for your own use.","readynotconnected","Ready\n[Not connected]","shutdown","Shutdown","connected","Connected successfully","readyconnectedto","Ready\n[Connected to: {{0}}]","readyconnectedto:sitecourse","Ready\n[Site: {{0}}]\n[Course: {{1}}]","connectionfailed","Connection failed","httperror","ERROR: HTTP request failed","httperror:code","ERROR: HTTP request failed with code {{0}}","httpempty","ERROR: HTTP response empty","httptimeout","ERROR: HTTP request timed out.","servererror","ERROR: server responded with status code {{0}}","notypeid","ERROR: failed to identify object type ID","gottype","Identified object type as {{0}}","failedcheckcompatibility","ERROR: failed to check compatibility with site","badresponseformat","ERROR: response from server was badly formatted","objectauthfailed:code","ERROR: object authorisation failed with code {{0}}","objectconfigfailed:code","ERROR: object configuration failed with code {{0}}","initobjectauth","Initiating object authorisation...","autoreg:newaccount","A new Moodle account has been automatically generated for you.\nWebsite: {{0}} \nUsername: {{1}}\nPassword: {{2}}","configurationreceived","Configuration received","configdatamissing","ERROR: some required data was missing from the configuration","readingconfignotecard","Reading configuration notecard...","checkingcourse","Checking course...","errortouchtoreset","ERROR\nTouch me to reset","notconfiguredyet","Sorry {{0}}. I am not configured yet.","resetting","Resetting...","noconfigavailable","There is no configuration available to download. Please visit the configuration web-page first.","checkingauth","Checking authorisation...","sloodlenotinstalled","ERROR: Sloodle is not installed on specified site.","sloodleversioninstalled","Sloodle version installed on server: {{0}}","sloodleversionrequired","ERROR: you require at least Sloodle version {{0}}","nopermission:use","Sorry {{0}}. You do not have permission to use this object.","nopermission:ctrl","Sorry {{0}}. You do not have permission to control this object.","nopermission:authobjects","Sorry {{0}}. You do not have permission to authorise objects on this course.","layout:failedretrying","Failed to store layout position. Retrying...","layout:failedaborting","Failed to store layout position. Aborting.","layout:toofar","Failed to store layout position - too far from rezzer.","layout:storedobject","Object stored in layout.","sloodleerror","SLOODLE error ({{0}}): please lookup SLOODLE wiki for error information","sloodleerror:desc","SLOODLE error ({{0}}): {{1}}"];

///// ----------- /////


// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

// Translation output methods
string SLOODLE_TRANSLATE_LINK = "link";
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
    for ((pos += 1); (pos < numstrings); (pos += 2)) {
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
    integer curparamnum;
    string curparamtok = "{{x}}";
    integer curparamtoklength = 0;
    string curparamstr = "";
    integer tokpos = (-1);
    for ((curparamnum = 0); (curparamnum < numparams); (curparamnum++)) {
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
            else  {
                sloodle_debug((("ERROR: unrecognised output method \"" + output_method) + "\"."));
            }
        }
    }
}

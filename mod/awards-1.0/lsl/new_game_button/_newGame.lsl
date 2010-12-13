/**********************************************************************************************
*  _newGame.lsl
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  Contributors:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com
*
*  **********************************************************************************************/
//gets a vector from a string
vector     RED            = <0.77278,0.04391,0.00000>;//RED
vector     ORANGE = <0.87130,0.41303,0.00000>;//orange
vector     YELLOW         = <0.82192,0.86066,0.00000>;//YELLOW
vector     GREEN         = <0.12616,0.77712,0.00000>;//GREEN
vector     BLUE        = <0.00000,0.05804,0.98688>;//BLUE
vector     PINK         = <0.83635,0.00000,0.88019>;//INDIGO
vector     PURPLE = <0.39257,0.00000,0.71612>;//PURPLE
vector     WHITE        = <1.000,1.000,1.000>;//WHITE
vector     BLACK        = <0.000,0.000,0.000>;//BLACKvector     ORANGE = <0.87130, 0.41303, 0.00000>;//orange
integer myQuizId;
string myQuizName;
                integer PLUGIN_RESPONSE_CHANNEL=998822; //channel the api responds on
integer counter=0;
integer TIME_LIMIT=5;
vector getVector(string vStr){
        vStr=llGetSubString(vStr, 1, llStringLength(vStr)-2);
        list vStrList= llParseString2List(vStr, [","], ["<",">"]);
        vector output= <llList2Float(vStrList,0),llList2Float(vStrList,1),llList2Float(vStrList,2)>;
        return output;
}//end getVector
rotation getRot(string vStr){
        vStr=llGetSubString(vStr, 1, llStringLength(vStr)-2);
        list vStrList= llParseString2List(vStr, [","], ["<",">"]);
        rotation output= <llList2Float(vStrList,0),llList2Float(vStrList,1),llList2Float(vStrList,2),llList2Float(vStrList,3)>;
        return output;
}//end getRot
integer PLUGIN_CHANNEL                                                    =998821;//sloodle_api requests
integer SLOODLE_CHANNEL_OBJECT_DIALOG                   = -3857343;//configuration channel
/***********************************************
*  isFacilitator()
*  |-->is this person's name in the access notecard
***********************************************/
integer isFacilitator(string avName){
    if (llListFindList(facilitators, [llStringTrim(llToLower(avName),STRING_TRIM)])==-1) return FALSE; else return TRUE;
}

/***********************************************************************************************
*  s()  k() i() and v() are used so that sending messages is more readable by humans.  
* Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added with a tag: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  All these functions do is strip off the text before the ":" char and return a string
***********************************************************************************************/
string s (string ss){
    return llList2String(llParseString2List(ss, [":"], []),1);
}//end function
key k (string kk){
    return llList2Key(llParseString2List(kk, [":"], []),1);
}//end function
integer i (string ii){
    return llList2Integer(llParseString2List(ii, [":"], []),1);
}//end function
vector v (string vv){
    integer p = llSubStringIndex(vv, ":");
    string vString = llGetSubString(vv, p+1, llStringLength(vv));
    return getVector(vString);
}//end function
rotation r (string rr){
    integer p = llSubStringIndex(rr, ":");
    string rString = llGetSubString(rr, p+1, llStringLength(rr));
    return getRot(rString);
}//end function
integer UI_CHANNEL                                                            =89997;//UI Channel - main channel
string SLOODLE_EOF = "sloodleeof";
string sloodleserverroot;
integer sloodlecontrollerid;
string sloodlecoursename_short;
string sloodlecoursename_full;
integer sloodleid;
string scoreboardname;
integer currentAwardId;
string currentAwardName;
list facilitators;
integer sloodle_handle_command(string str) {         
        list bits = llParseString2List(str,["|"],[]);
        integer numbits = llGetListLength(bits);
        string name = llList2String(bits,0);
        string value1 = "";
        string value2 = "";
        if (numbits > 1) value1 = llList2String(bits,1);
        if (numbits > 2) value2 = llList2String(bits,2);
        if (name == "facilitator")facilitators+=llStringTrim(llToLower(value1),STRING_TRIM);else
if (name =="set:sloodleid") {
                sloodleid= (integer)value1; 
                currentAwardId=sloodleid;
                currentAwardName=value2;
               
            }else
        if (name == SLOODLE_EOF) return TRUE;
         return FALSE;
    }
default {
     on_rez(integer start_param) {
        llResetScript();       
    }
    state_entry() {
              llSetText("", RED, 1.0);
        llSetTexture("btn_newgame", 4);
              llSetObjectName("btn:New Game");
        facilitators+=llStringTrim(llToLower(llKey2Name(llGetOwner())),STRING_TRIM);
    }
    link_message(integer sender_num, integer channel, string str, key id) {
        if (channel==SLOODLE_CHANNEL_OBJECT_DIALOG){
                sloodle_handle_command(str);
            }//endif SLOODLE_CHANNEL_OBJECT_DIALOG
            else
            if (channel==(PLUGIN_RESPONSE_CHANNEL)) {
                  list dataLines = llParseString2List(str, ["\n"], []);  
                string responseLine = s(llList2String(dataLines, 1));
                list statusLine =llParseStringKeepNulls(llList2String(dataLines,0),["|"],[]);
                integer status =llList2Integer(statusLine,0);
                
                //this was called from the responsehandler1, or from the newgame button
                if (responseLine=="quiz|newQuizGame"){
                 
                     myQuizName = s(llList2String(dataLines,3));
                     myQuizId = i(llList2String(dataLines,4));
                }
            }
                    
        if (channel==UI_CHANNEL){
                list cmdList = llParseString2List(str, ["|"], []);        
                string cmd = s(llList2String(cmdList,0));
                //if (cmd!="confirm"&&cmd!="BUTTON PRESS")return;
                //llMessageLinked(LINK_SET,UI_CHANNEL,"COMMAND:GOT QUIZ ID|QUIZID:"+(string)myQuizId+"|QUIZNAME:"+myQuizName,NULL_KEY);
             if (cmd=="GAMEID"){
                
                myQuizName = s(llList2String(cmdList,2));
                myQuizId = i(llList2String(cmdList,3));
                
            }else
                        if (cmd=="GOT QUIZ ID"){
                            myQuizId = i(llList2String(cmdList,1));
                            myQuizName = s(llList2String(cmdList,2));
                        }else        
                
                if (cmd=="BUTTON PRESS"&&s(llList2String(cmdList,1))=="New Game"){
                        if (isFacilitator(llKey2Name(k(llList2String(cmdList,2))))==FALSE) {
                            llSay(0,"Sorry, "+llKey2Name(k(llList2String(cmdList,2)))+ " but you are not a facilitator, facilitators are: "+llList2CSV(facilitators));
                            return;
                        }
                        llTriggerSound("click", 1.0);//
                    llSetTexture("btn_cancel", 4);
                    llSetTimerEvent(30);
                    llSetObjectName("btn:Cancel");                      
                        llSetTimerEvent(1);
                }else 
                if (cmd=="BUTTON PRESS"&&s(llList2String(cmdList,1))=="Cancel"){                    
                        if (isFacilitator(llKey2Name(k(llList2String(cmdList,2))))==FALSE) {
                            llSay(0,"Sorry, "+llKey2Name(k(llList2String(cmdList,2)))+ " but you are not a facilitator "+str);
                            return;
                        }
                        llSetColor(WHITE, ALL_SIDES);
                        llTriggerSound("snd_canceled", 1.0);                          
                        llSetTexture("btn_newgame", 4);
                        llSetText("", RED, 1.0);
                        llSetTimerEvent(0);
                        llSetObjectName("btn:New Game");
                        counter=0;     

                }//confirm button
             
        }//channel
  }//link
  timer() {
      counter++;
      
      
      vector color;
      if (llGetColor(4)==YELLOW) color = RED; else color= YELLOW;
      llSetText("("+(string)(TIME_LIMIT-counter)+")",color, 1.0);
      llSetColor(color, ALL_SIDES); 
      if (counter>=TIME_LIMIT){
          llSetTimerEvent(0.0);
             llTriggerSound("confirmed", 1.0);
          llSetTexture("btn_newgame", 4);
           llSetObjectName("btn:New Game");
           llSetText("",RED, 1.0);
           llSetColor(WHITE, ALL_SIDES);
          counter=0;
             string authenticatedUser= "&sloodleuuid="+(string)llGetOwner()+"&sloodleavname="+llEscapeURL(llKey2Name(llGetOwner()));       
            llMessageLinked(LINK_SET, UI_CHANNEL, "CMD:NEWGAME", NULL_KEY);
                
      }else
      if (TIME_LIMIT-counter<5)llTriggerSound("beepbeep", 1.0); else
          llTriggerSound("TICK", 1.0);
  }
  changed(integer change) { // something changed
        if (change== CHANGED_INVENTORY) { // and it was a link change
               llSetTexture("btn_newgame", 4); 
               llSetObjectName("btn:New Game");
             llResetScript();
        }//endif
        }
}//default
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/lsl/new_game_button/_newGame.lsl 
        
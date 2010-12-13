/*********************************************
*  Copyright (c) 2009 Paul Preibisch
*  GPL 3.0 for the Sloodle Project
*
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
*  http://twitter.com/fire 
* 
*  setText will accept linked messages for incoming text. It will set the text for 3 seconds, then set to blank.
*  Put this in a linked prim, and send messags to it using:
*
*  llMessageLinked(LINK_SET, SETTEXT_CHANNEL, "TEXT::Clearing stored coordinate|COLOR::(string)RED|BLINK::(string)TRUE+"|BLINK_TIMER::5", NULL_KEY);
*/
integer SETTEXT_CHANNEL= 981000; //channel used for hover text
vector getVector(string vStr){
        vStr=llGetSubString(vStr, 1, llStringLength(vStr)-2);
        list vStrList= llParseString2List(vStr, [","], ["<",">"]);
        vector output= <llList2Float(vStrList,0),llList2Float(vStrList,1),llList2Float(vStrList,2)>;
        return output;
}//end getVector
vector  RED            = <0.77278,0.04391,0.00000>;//RED
vector  ORANGE = <0.87130,0.41303,0.00000>;//orange
vector  YELLOW         = <0.82192,0.86066,0.00000>;//YELLOW
vector  GREEN         = <0.12616,0.77712,0.00000>;//GREEN
vector  BLUE        = <0.00000,0.05804,0.98688>;//BLUE
vector  PINK         = <0.83635,0.00000,0.88019>;//INDIGO
vector  PURPLE = <0.39257,0.00000,0.71612>;//PURPLE
vector  WHITE        = <1.000,1.000,1.000>;//WHITE
vector  BLACK        = <0.000,0.000,0.000>;//BLACK
/***********************************************************************************************
*  s()  k() i() and v() are used so that sending messages is more readable by humans.  
* Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added with a tag: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  All these functions do is strip off the text before the ":" char and return a string
***********************************************************************************************/
string s (string ss){
    return llList2String(llParseString2List(ss, ["::"], []),1);
}//end function
key k (string kk){ 
    return llList2Key(llParseString2List(kk, ["::"], []),1);
}//end function
integer i (string ii){
    return llList2Integer(llParseString2List(ii, ["::"], []),1);
}//end function
vector v (string vv){
    integer p = llSubStringIndex(vv, "::");
    string vString = llGetSubString(vv, p+1, llStringLength(vv));
    return getVector(vString);
}//end function
integer blinkTimer =3;

integer debugCheck(){
    if (llList2Integer(llGetPrimitiveParams([PRIM_MATERIAL]),0)==PRIM_MATERIAL_FLESH){
        return TRUE;
    }
        else return FALSE;
    
}
debug(string str){
    if (llList2Integer(llGetPrimitiveParams([PRIM_MATERIAL]),0)==PRIM_MATERIAL_FLESH){
        llOwnerSay(str);
    }
}
default {
    state_entry() {
       
    }
    link_message(integer sender_num, integer channel, string str, key id) {
        if (channel==SETTEXT_CHANNEL){
debug(str);
//TEXT:Welcome Area - Using SLOODLE|COLOR:<0.83635, 0.00000, 0.88019>|BLINK:0|TIMER:0
            list cmdList = llParseString2List(str, ["|"], []);       
            integer blink = i(llList2String(cmdList,2));
              blinkTimer = i(llList2String(cmdList,3));
               string text = s(llList2String(cmdList,0));
               vector color = PINK;//v(llList2String(cmdList,1));
               debug(text); 
            llSetText(text, color, 1.0);
            if (blink==TRUE){
                llSetTimerEvent(blinkTimer);
            }
        }
    }
    timer() {
        llSetTimerEvent(0);
        llSetText("", <0,0,0>, 1.0);
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/enrolbooth-1.0/_setText.lsl 

 /*********************************************
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
*
* _click_handler.lsl 
* 
* PURPOSE
*  This script is part of the SLOODLE HQ.
*  click_handler detects button clicks and sends a linked message on the UI_CHANNEL indicating which button was pressed
*  
/**********************************************************************************************/
key owner;
// *************************************************** HOVER TEXT VARIABLES
integer PLUGIN_RESPONSE_CHANNEL                                =998822; //sloodle_api.lsl responses
integer PLUGIN_CHANNEL                                                    =998821;//sloodle_api requests
integer SETTEXT_CHANNEL                                                =-776644;//hover text channel
integer SOUND_CHANNEL                                                     = -34000;//sound requests
integer DISPLAY_PAGE_NUMBER_STRING                            = 304000;//page number xy_text
integer XY_TITLE_CHANNEL                                                  = 600100;//title xy_text
integer XY_TEXT_CHANNEL                                                = 100100;//display xy_channel
integer XY_DETAILS_CHANNEL                                          = 700100;//instructional xy_text
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST     = -1928374651;//translation channel
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE     = -1928374652;//translation channel
integer UI_CHANNEL                                                            =89997;//UI Channel - main channel
integer PRIM_PROPERTIES_CHANNEL                                =-870870;//setting highlights
integer SLOODLE_CHANNEL_OBJECT_DIALOG                     = -3857343;//configuration channel
integer SET_COLOR_INDIVIDUAL                                        = 8888999;//row text color channel
integer ROW_CHANNEL;                                                                    
integer AWARD_DATA_CHANNEL                                        =890;
integer ANIM_CHANNEL                                                        =-77664251;//animation trigger channel
/***********************************************
*  clearHighlights -- makes sure all highlight rows are set to 0 alpha
***********************************************/
clearHighlights(){
    integer c;
    for (c=0;c<9;c++){
        llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)(c)+"|POWER:OFF|COLOR:GREEN",NULL_KEY);
    } 
}

debugMessage(string s){
 llOwnerSay((string)llGetFreeMemory()+"********************** "+s);
   s="";
}
/***********************************************
*  clear()
*  |-->clears the xy display
***********************************************/ 
clear(){
        string blanks="";
        integer counter;
        for (counter=0;counter<300;counter++){
            blanks+=" ";    
        }
        llMessageLinked(LINK_SET, DISPLAY_PAGE_NUMBER_STRING, "          ", "0");
        llMessageLinked(LINK_SET, XY_TITLE_CHANNEL, "                              ", "0");
        llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, "                              ", "0");        
        llMessageLinked(LINK_SET, XY_TEXT_CHANNEL, blanks, "0");
        blanks="";
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
    return llList2Vector(llParseString2List(vv, [":"], []),1);
}//end function

/* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
*
*  default state
*  In this state we wait until the sloodle_api script in this object inits
*
* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& */
 default{     
 on_rez(integer par)
            {
                llResetScript();
            }
     state_entry() {
         owner=llGetOwner();
          state ready;
     }
    link_message(integer sender_num, integer channel, string str, key id) {
        if (channel==UI_CHANNEL){
            list dataBits = llParseString2List(str,["|"],[]);
            string command=s(llList2String(dataBits,0));
            if (command=="ENGAGE CLICK HANDLER") {
                state ready;
            }
        }//endif channel=PLUGIN_RESPONSE_CHANNEL
    }//end linked_message event
}//end default state

/* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
*
*  ready state
*  When we get to this state, the sloodle_api is ready and we can begin detecting clicks
*
* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& */
state ready{
    on_rez(integer par)
            {
                llResetScript();
            }
    touch_start(integer num_detected) {
      
            //buttonName:name
            list buttonData = llParseString2List(llGetLinkName(llDetectedLinkNumber(0)),[","],[]);
            string buttonName=s(llList2String(buttonData,0));
            llMessageLinked(LINK_SET, UI_CHANNEL, "CMD:BUTTON PRESS|BUTTON:"+buttonName+"|AVUUID:"+(string)llDetectedKey(0),NULL_KEY);
      
    }//end touch event
    /***********************************************
    *  changed event
    *  |-->Every time the inventory changes, reset the script
    *        
    ***********************************************/
    changed(integer change) {
     if (change ==CHANGED_INVENTORY){         
         llResetScript();
     }//endif
    }//end changed event  
}//end ready state
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/lsl/root_prim_board/_click_handler.lsl

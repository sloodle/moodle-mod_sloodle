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
* sloodle_mod_hq-1.0.lsl 
* 
* PURPOSE
*  This script is part of the SLOODLE HQ.
* This script initializes the Sloodle Awards
*  
* beep sound from http://www.freesound.org/samplesViewSingle.php?id=12906
* Creative Commons Sampling Plus 1.0 License. see http://creativecommons.org/licenses/sampling+/1.0/
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
string myUrl;
integer currentAwardId;
string previousUrl;
integer previousAwardId;
// *************************************************** HOVER TEXT COLORS
vector     RED            = <0.77278, 0.04391, 0.00000>;//RED
vector     YELLOW         = <0.82192, 0.86066, 0.00000>;//YELLOW
vector     GREEN         = <0.12616, 0.77712, 0.00000>;//GREEN
vector     PINK         = <0.83635, 0.00000, 0.88019>;//INDIGO
vector     WHITE        = <1.000, 1.000, 1.000>;//WHITE

/***********************************************
*  clearHighlights -- makes sure all highlight rows are set to 0 alpha
***********************************************/
clearHighlights(){
    integer c;
    for (c=0;c<9;c++){
        llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)(c)+"|POWER:OFF|COLOR:GREEN",NULL_KEY);
    } 
}
integer DEBUG=FALSE;
debug(string s){
 if (DEBUG==TRUE) llOwnerSay((string)llGetFreeMemory()+" "+llGetScriptName()+" "+ s);
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
*  In this state we wait until the rest of the scripts in this object init
*
* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& */
 default{
     
     state_entry() {
         //clear highlighted rows
         clearHighlights();
         //clear scoreboard;
         clear();      
         //set owner
         owner = llGetOwner();
     }
    link_message(integer sender_num, integer channel, string str, key id) {
        list dataLines=llParseString2List(str, ["\n"],[]);
        list cmdLine = llParseString2List(str, ["|"],[]);
        string cmd=s(llList2String(cmdLine,0));
        if (channel==PLUGIN_RESPONSE_CHANNEL){
            if (cmd=="API READY") state chooseAward;
        }//endif channel=PLUGIN_RESPONSE_CHANNEL
    }//end linked_message event
}//end default state

/* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
*
*  chooseAward state
*  When we get to this state, all other scripts should have completed their initializations and are ready to accept commands from this script
*  Additionally this script has initialized it's scripts
*
* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& */
state chooseAward{
    /***********************************************
    *  on_rez event
    *  |--> Reset Script to ensure proper defaults on rez
    ***********************************************/
    on_rez(integer start_param) {
        llResetScript();     
    }
    state_entry() {
        //send button press to btn_handler        
        llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:BUTTON PRESS|BUTTON:Config Tab|UUID:"+(string)llGetOwner(),NULL_KEY);
        llMessageLinked(LINK_SET,SETTEXT_CHANNEL, "Opening Config Tab",NULL_KEY);
        clear();
    }  
     link_message(integer sender_num, integer channel, string str, key id) {
             if (channel==UI_CHANNEL){
                 list dataBits = llParseString2List(str,["|"],[]);
                 string command = s(llList2String(dataBits,0));
                 /*********************************
                 * Capture AWARD SELECTED
                 *********************************/  
                 //DISPLAY MENU message comes from scoreboard_row.lsl which is located in each XY prim when it is clicked on             
                 if (command=="AWARD SELECTED"){   
                             currentAwardId = i(llList2String(dataBits,1));
                                                       
                 }//endif
                 else
                 if (command=="REGISTERED SCOREBOARD"){   
                         state ready;
                 }//endif
        }//endif
    }//end link_message
    
    /***********************************************
    *  changed event
    *  |-->Every time the inventory changes, reset the script
    *        
    ***********************************************/
    changed(integer change) {
         if (change ==CHANGED_INVENTORY){         
             llResetScript();
         }//endif
     }//end ready state
}//end chooseAward state

state ready{
    state_entry() {
        //send message to _click_handler.lsl and order it to start listening for clicks
        llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:ENGAGE CLICK HANDLER",NULL_KEY);
        //send message to _btn_handler.lsl to emulate a button press on the students tab
        llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:BUTTON PRESS|BUTTON:Students Tab|AVUUID:"+(string)llGetOwner(),NULL_KEY);
    }//end state_entry
    link_message(integer sender_num, integer channel, string str, key id) {
        if (channel==UI_CHANNEL){
            list dataBits = llParseString2List(str,["|"],[]);
            string command = s(llList2String(dataBits,0));
            if(command=="RESET"){
                llInstantMessage(owner,"Releasing http-in url...");
                llReleaseURL(myUrl);
                  llResetScript();
              }//endif command=="RESET"      
            }//UI_CHANNEL  
    }//linked message
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
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/lsl/root_prim_board/sloodle_mod_hq-1.0.lsl 
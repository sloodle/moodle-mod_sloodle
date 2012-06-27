//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*********************************************************************************************
*  sloodle_hover_text_displayer.lsl
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*
*  This script is part of the SLOODLE Project see http://sloodle.org
*  This script can be dropped into a linked prim, and messages can be sent to it on channel SETTEXT_CHANNEL=-776644 to set the text above 
*  This way you can better position where setText get's printed
*  You should name the linked prim a unique name, then send this command to it via a linked message
*  example:  DISPLAY:top display|STRING:some string|COLOR:"+<0,0.5,0>
*  example:  llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY:top display|STRING:"+text+"|COLOR:"+(string)GREEN,NULL_KEY);
*
*  Copywrite 2009
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
**********************************************************************************************
*/

integer SETTEXT_CHANNEL=-776644;
list     commandList; //used for linked_message strings
/***********************************************
*  extractResponse()
*  Is used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  By adding a context to the messages, the programmer can understand whats going on when debugging
*  All this function does is strip off the text before the ":" char 
***********************************************/
string extractResponse(string cmd){     
     return llList2String(llParseString2List(cmd, ["::"],[]),1);
}
default {
    /***********************************************
    *  on_rez event
    *  |--> Reset Script to ensure proper defaults on rez
    ***********************************************/
    on_rez(integer start_param) {
        llResetScript();
    }
    /***********************************************
    *  state_entry
    *  |-->
    ***********************************************/    
    state_entry() {
        llSetText("",<0,0,0>,1.0);        
    }

    
    /***********************************************
    *  changed event
    *  |-->Every time the inventory changes, reset the script
    *        
    ***********************************************/
    changed(integer change) {
     if (change ==CHANGED_INVENTORY){   
          llSetText("                                                               ",<0,0,0>,1.0);       
         llResetScript();
     }
    }
    
    link_message(integer sender_num, integer channel, string str, key id) {
    
        if     (channel==SETTEXT_CHANNEL){
            //llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY:top display|STRING:"+text+"|COLOR:"+(string)GREEN,NULL_KEY);
            commandList=llParseString2List(str, ["|"],[]);
            if (extractResponse(llList2String(commandList,0))==llGetLinkName(llGetLinkNumber())){
                string text = extractResponse(llList2String(commandList,1));
                vector color = (vector)extractResponse(llList2String(commandList,2));
                float alpha = (float)extractResponse(llList2String(commandList,3));
                llSetText(text, color, alpha);
            }
        }
    }

}


// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: assets/sloodle_hover_text_displayer.lslp 

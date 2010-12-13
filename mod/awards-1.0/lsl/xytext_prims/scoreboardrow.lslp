/**********************************************************************************************
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*  scoreboardRow.lsl
*  
* This script is responsible for  highlighting the text on the xy_prims if any xy_prim in the same row has been clicked
* please note that each xy_prim should have the following name:
*
* cell:0,row:0,display:scoreboard,channel:100100,charPos:0
*
* row should be set to the current row (from 0 to 9) and char pos should increment by 10.
* also note that the channel should be set to 100100 for display of output.  For other xy_prims in the system, this channel
* will differ
*
*  
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  Contributors:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com
*
*  This script sends messages to the GUI channel when users click on a scoreboard prim
*  This is done so the gui script knows which user displayed on the XY prim was clicked on
*  This script will also send a linked message to all other prims in this row
*  so that the color of the text will temporarily change so the owner can see an instant feedback that the prim was clicked on
**********************************************************************************************/
integer DELETE_CHANNEL=-45423;
integer GUI_CHANNEL=89997;
integer COMMAND=0;
integer DATA0=1;
integer DATA1=2;
list commandList;
string command;
list MyParticleSettings;
vector color;
integer rowId;
integer myRow;
integer myCell;
integer myType;
integer SET_ROW_COLOR= 8888999;
vector BLACK=<0,0,0>;
vector ORANGE=<0.91574, 0.68922, 0.00000>;
/***********************************************
*  s()  used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  All this function does is strip off the text before the ":" char and return a string
***********************************************/
string s (string ss){
    return llList2String(llParseString2List(ss, [":"], []),1);
}
/***********************************************
*  k()  used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  All this function does is strip off the text before the ":" char and return a key
***********************************************/
key k (string kk){
    return llList2Key(llParseString2List(kk, [":"], []),1);
}
/***********************************************
*  i()  used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  All this function does is strip off the text before the ":" char and return an integer
***********************************************/

integer i (string ii){
    return llList2Integer(llParseString2List(ii, [":"], []),1);
}
/***********************************************
*  v()  used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  All this function does is strip off the text before the ":" char and return an integer
***********************************************/
vector v (string vv){
    return llList2Vector(llParseString2List(vv, [":"], []),1);
}

default {
    
    state_entry() {
       
       list dataList = llParseString2List(llGetObjectName(),[","],[]);
       //cell:0,row:0,display:scoreboard
       myCell =i(llList2String(dataList,0));
       myRow = i(llList2String(dataList,1));       
       myType =i(llList2String(dataList,2));
       llSetLinkPrimitiveParams(llGetLinkNumber(), [ PRIM_FULLBRIGHT, ALL_SIDES, TRUE]);
    }
    touch_start(integer num_detected) {
        llMessageLinked(LINK_SET,GUI_CHANNEL, "COMMAND:DISPLAY MENU|ROW:"+ (string)myRow+"|AVUUID:"+(string)llDetectedKey(0),NULL_KEY);
        //COMMAND:DISPLAY MENU|ID:row#|AVUUID:detectedKey               
        //send linked message so that all xy prims in this row highlight
        llMessageLinked(LINK_SET, SET_ROW_COLOR, "COMMAND:SET COLOR|ROW:"+(string)myRow+"|COLOR:"+(string)ORANGE, NULL_KEY);
          
    }    
    link_message(integer sender_num, integer channel, string str, key id) {     
        if (channel==SET_ROW_COLOR){            
            //set the color of this row
            //COMMAND:SET_COLOR|ROWID:row#|COLOR:color
            //llMessageLinked(LINK_SET, SET_ROW_COLOR, "COMMAND:SET_COLOR|ROWID:row#|COLOR:color", NULL_KEY);
            commandList=llParseString2List(str, ["|"],[]);
            command=s(llList2String(commandList,0));
            rowId=i(llList2String(commandList,1));
            color=v(llList2String(commandList,2));
            if (command=="SET COLOR"){    
                llSetTimerEvent(2.0);                  
                if (rowId == myRow){
                    llSetColor(ORANGE, ALL_SIDES);
                }
            }
        }
    }
    timer() {
        llSetColor(BLACK, ALL_SIDES);         
         llSetTimerEvent(0.0);
    }
}

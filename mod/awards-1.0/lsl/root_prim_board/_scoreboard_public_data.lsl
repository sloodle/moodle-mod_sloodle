 /*********************************************
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*  _scoreboard_public_data.lsl
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
*
* init.lsl 
* 
* PURPOSE
*  This script is part of the SLOODLE HQ.
* This script initializes the Sloodle Awards
*  
* beep sound from http://www.freesound.org/samplesViewSingle.php?id=12906
* Creative Commons Sampling Plus 1.0 License. see http://creativecommons.org/licenses/sampling+/1.0/
/**********************************************************************************************/
//scoreboard_public_data
    integer gameid;
    integer scoreboardchannel=-1;
    integer PLUGIN_CHANNEL=998821; //channel api commands come from  
    integer UI_CHANNEL                                                            =89997;//UI Channel - main channel
    integer PLUGIN_RESPONSE_CHANNEL=998822; //channel the api responds on
    integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
    integer XY_TEXT_CHANNEL                                                = 100100;//display xy_channel
    integer XY_GAMEID_CHANNEL                                          = 1700100;//instructional xy_text
    string  sloodleserverroot = ""; 
    string  sloodlepwd = ""; //password of the controller who's activites we wish access to
    integer sloodlecontrollerid = 0;//id of the controller
    integer sloodlemoduleid = 0;//course module id 
    integer sloodleid;//module id
    integer sloodleobjectaccessleveluse = 0; // Who can use this object?
    integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
    integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
    string sloodleCourseName;
    integer coursemoduleid;
    string sloodlecoursename_short;
    integer XY_QUIZ_CHANNEL=-1800100;
    string sloodlecoursename_full;
    integer myQuizId;
    string myQuizName;
    string  SLOODLE_EOF = "sloodleeof";//end of file, should be the end of a sloodle_config file
    integer eof= FALSE;
    list groups;
    string scoreboardname;
    integer isconfigured;
    list dataLines;
    integer debugCheck(){
        if (llList2Integer(llGetPrimitiveParams([PRIM_MATERIAL]),0)==4){
            return TRUE;
        }
            else return FALSE;
        
    }
     debug(string str){
            if (llList2Integer(llGetPrimitiveParams([PRIM_MATERIAL]),0)==PRIM_MATERIAL_FLESH){
                llOwnerSay(llGetScriptName()+" " +str);
           }
        }
    //gets a vector from a string
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
    center(string str){
                     integer len = llStringLength(str);
                    string spaces="                    ";
                    integer numSpacesForMargin= (20-len)/2;
                    string margin = llGetSubString(spaces, 0, numSpacesForMargin);
                    string stringToPrint = margin+str+margin;
                    llMessageLinked(LINK_SET, XY_GAMEID_CHANNEL, stringToPrint, NULL_KEY);  
    }
    left(string str){
                    llMessageLinked(LINK_SET, XY_GAMEID_CHANNEL, str, NULL_KEY);  
    }
          // Configure by receiving a linked message from another script in the object
            // Returns TRUE if the object has all the data it needs
            integer sloodle_handle_command(string str) {
                    if (str=="do:requestconfig")llResetScript();
                list bits = llParseString2List(str,["|"],[]);
               string name=  llList2String(bits,0);
               string value1 = llList2String(bits,1);
                if (name == "set:scoreboardchannel") scoreboardchannel= (integer)value1;
                return (scoreboardchannel<-100);            
            }
    
    default {
        on_rez(integer start_param) {
        llResetScript();       
    }
        link_message(integer sender_num, integer channel, string str, key id) {        
              if (channel==UI_CHANNEL){
                     list cmdList = llParseString2List(str,["|"],[]);
                     string cmd= s(llList2String(cmdList,0));
                    //check to see if any commands are currently being processed
                        if (cmd=="GAMEID"){
                            gameid=i(llList2String(cmdList,1));
                            myQuizId = i(llList2String(cmdList,2));
                            myQuizName = s(llList2String(cmdList,3));
                            left("Game: "+(string)gameid);
                        }
                        else
                        //llMessageLinked(LINK_SET,UI_CHANNEL,"COMMAND:GOT QUIZ ID|QUIZID:"+(string)myQuizId+"|QUIZNAME:"+myQuizName,NULL_KEY);
                        if (cmd=="GOT QUIZ ID"){
                            myQuizId = i(llList2String(cmdList,1));
                            myQuizName = s(llList2String(cmdList,2));
                        }        
                }else
                 if (channel == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                 
                // Split the message into lines
                    dataLines=[];
                //parse each line into the list
                    dataLines = llParseString2List(str, ["\n"], []);                       
                    isconfigured=FALSE;
                //get number of lines received
                    integer numLines =  llGetListLength(dataLines);
                    integer i;
                    for (i=0; i<numLines; i++) {
                        if (sloodle_handle_command(llList2String(dataLines,i))==TRUE) state ready;
                    }//endfor
            }//endif
        }//linked
    }
    
    state ready{
    on_rez(integer start_param) {
        llResetScript();       
    }
    state_entry() {
        debug("(((((((((((((((((((((( listening to: "+(string)scoreboardchannel);
        llListen(scoreboardchannel, "", "", "");
      
    }
    listen(integer channel, string name, key id, string str) {
        if (channel==scoreboardchannel){
                  list cmdList = llParseString2List(str,["|"],[]);
                string cmd= s(llList2String(cmdList,0));
                //request comes from a chair
                if (cmd=="REQUEST GAME ID"){
                    //tell chairs
                    debug("CMD:SCOREBOARD SENDING GAME ID|ID:"+(string)gameid+"|UUID:"+s(llList2String(cmdList,1))+"|groups:"+llList2CSV(groups)+"|myQuizName:"+myQuizName+"|QUIZID:"+(string)myQuizId);
                    llRegionSay(scoreboardchannel, "CMD:SCOREBOARD SENDING GAME ID|ID:"+(string)gameid+"|UUID:"+s(llList2String(cmdList,1))+"|groups:"+llList2CSV(groups)+"|myQuizName:"+myQuizName+"|QUIZID:"+(string)myQuizId);
                
                }
        }
    }
     link_message(integer sender_num, integer channel, string str, key id) {        
             if (channel==SLOODLE_CHANNEL_OBJECT_DIALOG){
                sloodle_handle_command(str);
            }//endif SLOODLE_CHANNEL_OBJECT_DIALOG
            
             list dataLines = llParseString2List(str, ["\n"], []);  
            string responseLine = s(llList2String(dataLines, 1));
            list statusLine =llParseStringKeepNulls(llList2String(dataLines,0),["|"],[]);
            integer status =llList2Integer(statusLine,0);
            
            if (channel==UI_CHANNEL){
                list cmdList = llParseString2List(str, ["|"], []);        
                string cmd = s(llList2String(cmdList,0));
                    //llMessageLinked(LINK_SET,UI_CHANNEL,"COMMAND:GOT QUIZ ID|QUIZID:"+(string)myQuizId+"|QUIZNAME:"+myQuizName,NULL_KEY);
                        if (cmd=="GOT QUIZ ID"){
                            myQuizName = s(llList2String(cmdList,2));
                            myQuizId = i(llList2String(cmdList,1));
                        }  
            }//ui
            if (channel==(PLUGIN_RESPONSE_CHANNEL)) {
                //this was called from the responsehandler1, or from the newgame button
                if (responseLine=="quiz|newQuizGame"){
                     gameid= i(llList2String(dataLines, 2));
                     myQuizName = s(llList2String(dataLines,3));
                     myQuizId = i(llList2String(dataLines,4));
                     llMessageLinked(LINK_SET, XY_QUIZ_CHANNEL, myQuizName, "0");
                     left("Game: "+(string)gameid);
                      llMessageLinked(LINK_SET, UI_CHANNEL, "CMD:GAMEID|ID:"+(string)gameid+"|qname:"+myQuizName+"|id:"+(string)myQuizId, NULL_KEY);
                      
                      llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:BUTTON PRESS|BUTTON:Students Tab|UUID:"+(string)llGetOwner(),NULL_KEY);
                      //tell chairs that there is a new game                  
                      llRegionSay(scoreboardchannel, "CMD:NEW GAME|ID:"+(string)gameid+"|GROUPS:"+llList2CSV(groups)+"|MyQuizName:"+myQuizName+"|QUIZID:"+(string)myQuizId);
                 }
            }//pluginre
           //new|game is a response that happens after newgame button is pressed
                        if (responseLine=="awards|getTeamPlayerScores"){
                            groups=[];
                               string data = llList2String(dataLines,4);
                            integer totalGroups= i(llList2String(dataLines,3));
                            list grpsData = llParseString2List(data, ["|"], []);
                            integer len = llGetListLength(grpsData);
                             integer counter;
                             debug("--------------------------------------------------"+str);    
                             debug("--------------------------------------------------"+llList2CSV(grpsData));      
                            for (counter=0;counter<len;counter++){
                                list grpData =llParseString2List(llList2String(grpsData,counter), [","], []); //parse the message into a list
                                string grpName =s(llList2String(grpData,0));
                                groups+=grpName;
                                integer grpPoints = i(llList2String(grpData,1));                            
                            }//for
                            debug("--------------------------------------------------"+llList2CSV(groups));
                                
                        }
                
                 
        }//linked
    }//state

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/lsl/root_prim_board/_scoreboard_public_data.lsl 
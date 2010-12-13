/*********************************************
*  Copyrght (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
* _httpin_handler.lsl
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
*
*  
* 
*/ 
integer ROW_CHANNEL;
string stringToPrint;
list lines;
integer numStudents;
integer totalPages;
integer index;
integer DISPLAY_DATA                                                        =-774477; //every time the display is updated, data goes on this channel
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
integer SLOODLE_CHANNEL_OBJECT_DIALOG                   = -3857343;//configuration channel
integer SET_COLOR_INDIVIDUAL                                       = 8888999;//row text color channel                                                                    
integer AWARD_DATA_CHANNEL                                        =890;
integer WEB_UPDATE_CHANNEL                                        =-64000; // data we receive from an http request from httpIn handler
integer ANIM_CHANNEL                                                      =-77664251;//animation trigger channel
integer PAGE_SIZE=10; //can display only 10 users at once.
integer SET_ROW_COLOR= 8888999;
integer PLAYERNAME=0; //constant which defines a list postion our specific data is in to make code more readable
integer PLAYERPOINTS=1; //constant which defines a list postion our specific data is in to make code more readable
integer SLOTCHANNEL=2; //constant which defines a list postion our specific data is in to make code more readable
integer AVUUID=3; //constant which defines a list postion our specific data is in to make code more readable
integer MAX_XY_LETTER_SPACE=30;
list rows;
integer counter;
string senderUuid;
string statusLine;
string connected;
vector ORANGE=<1.08262, 0.66319, 0.00000>;
vector BLACK=<0.00000, 0.00000, 0.00000>;
list awardGroups;
list courseGroups;
integer currentAwardId;
string current_grp_membership_group;//to keep track of which group we selected in group membership displaymode
integer current_grp_mbr_index; //keep track of which of group members we are viewing
list dataLines;
integer numGroups;
key owner;
string currentView;
list rows_teamScores;
list rows_getAwardGrps;
list rows_getAwardMbrs;
list rows_selectTeams;
list rows_selectAward;
list rows_getClassList;
integer previousAwardId;
integer selectedAwardId=0;
string currentGroup;
string sortMode="balance";
list pointMods=["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000"]; //this is a list of values an owner can modify a users points to //["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000",
list modifyPointList; //this is a temp list that is used to store point modifications in.  When Save is pressed on a menu, these points are applied to the users point bank
integer modPoints;
string myUrl;
string displayData;
string authenticatedUser;
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
integer DEBUG=FALSE;
debug(string s){
 if (DEBUG==TRUE) llOwnerSay((string)llGetFreeMemory()+" "+llGetScriptName()+"*** "+ s);
   s="";
}

/***********************************************
*  clearHighlights -- makes sure all highlight rows are set to 0 alpha
***********************************************/
clearHighlights(){
    integer c;
    for (c=0;c<9;c++){
        llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)(c)+"|POWER:OFF|COLOR:GREEN",NULL_KEY);
    } 
}

/****************************************************************************************************
* center(string str) displays text on the title bar 
****************************************************************************************************/
center(string str){
    integer len = llStringLength(str);
    string spaces="                    ";
    integer numSpacesForMargin= (20-len)/2;
    string margin = llGetSubString(spaces, 0, numSpacesForMargin);
    string stringToPrint = margin+str+margin;    
    llMessageLinked(LINK_SET, XY_TITLE_CHANNEL,stringToPrint,NULL_KEY);
}

/***********************************************
*  random_integer()
*  |-->Produces a random integer
***********************************************/ 
integer random_integer( integer min, integer max )
{
  return min + (integer)( llFrand( max - min + 1 ) );
}
default{
    on_rez(integer start_param) {
        llSetObjectDesc("");
    } 
    state_entry() {
         owner=llGetOwner();          
         authenticatedUser= "&sloodleuuid="+(string)owner+"&sloodleavname="+llEscapeURL(llKey2Name(owner));
    }
    
    link_message(integer sender_num, integer channel, string str, key id) {      

            if (channel==DISPLAY_DATA){
                displayData=str;
            }
            else
            /*********************************
            * Handle the UI_CHANNEL 
            *********************************/
             if (channel==UI_CHANNEL){
                 list dataBits = llParseString2List(str,["|"],[]);
                 string command = s(llList2String(dataBits,0));
                 /*********************************
                 * Capture current award                 
                 *********************************/                 
                 if(command=="AWARD SELECTED"){
                     debug("******************* award selected");
                            currentAwardId=i(llList2String(dataBits,1));
                            //remove old httpin
                            string oldUrl= llGetObjectDesc();
                            if (oldUrl!=""){
                                    llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->deregisterScoreboard"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&url="+oldUrl+"&name="+llEscapeURL(llGetObjectName()),NULL_KEY);                          
                            }else{
                          
                                 llRequestURL();
                            }                            
                 }//endif AWARD SELECTED
                 else
                 /*********************************
                 * Capture current button                 
                 *********************************/                 
                 if (command=="SET CURRENT BUTTON"){ 
                     currentView= s(llList2String(dataBits,2));
                 }//endif
                 else  
                /*********************************
                 * Capture UPDATE ARROWS                 
                 *********************************/                            
                 if (command=="UPDATE ARROWS"){
                     currentView=s(llList2String(dataBits,1));
                 }//endif
             }//UI_CHANNEL
                else
          /*********************************
            * Handle the PLUGIN_RESPONSE_CHANNEL 
            *********************************/
            if (channel==PLUGIN_RESPONSE_CHANNEL){                          
                list dataLines = llParseString2List(str, ["\n"], []); //parse the message into a list            
                string response = s(llList2String(dataLines,1));       
               /*********************************
               * Handle the user|getClassList  response 
               *********************************/                      
               if (response=="awards|registerScoreboard"){
                /* A typical getClassList response looks like:
                1|OK|||||2102f5ab-6854-4ec3-aec5-6cd6233c31c6
                RESPONSE:awards|registerScoreboard
                */
                    string url = llList2String(dataLines,2);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"COMMAND:REGISTERED SCOREBOARD|"+url, NULL_KEY);                    
                }//awards|registerScoreboard
                else
                if (response=="awards|deregisterScoreboard"){
                /* A typical getClassList response looks like:
                1|OK|||||2102f5ab-6854-4ec3-aec5-6cd6233c31c6
                RESPONSE:awards|registerScoreboard
                */
                //award is deregistered, register new one
                llRequestURL();
                }//awards|registerScoreboard
            }//end PLUGIN_RESPONSE_CHANNEL
    }
     http_request(key id, string method, string body){
          if ((method == URL_REQUEST_GRANTED)){
                myUrl=body;
                //save this new url in object description to survive script reboots
                llSetObjectDesc(myUrl); 
                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->registerScoreboard"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&url="+myUrl+"&type=scoreboard&name="+llEscapeURL(llGetObjectName()),NULL_KEY);
          }//endif
          else 
          if (method == "POST"){
               list bodyData= llParseString2List(body, ["\n"],[]);
               string cmd= s(llList2String(bodyData,0));
               if (cmd=="GET DISPLAY DATA"){
                   string responseText =displayData;
                   llHTTPResponse(id, 200, responseText);
                   //llMessageLinked(LINK_SET,WEB_UPDATE_CHANNEL,body,NULL_KEY);
               }else
               if (cmd=="UPDATE DISPLAY"){
                   llMessageLinked(LINK_SET,SOUND_CHANNEL, "COMMAND:PLAYSOUND|SOUND:sound bleepy computer|SCRIPT_NAME:soundPlayer 3|VOLUME:0.8",NULL_KEY);
                   llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:UPDATE DISPLAY", NULL_KEY);
                       string responseText ="UPDATED";
                   llHTTPResponse(id, 200, responseText);
                   //llMessageLinked(LINK_SET,WEB_UPDATE_CHANNEL,body,NULL_KEY);
               }
          }//endif
          else {
              //llSay(0,"got something "+ body+" method: "+method+" id:"+(string)id);
          }//else
     }//http
     /***********************************************
    *  changed event
    *  |-->Every time the inventory changes, reset the script
    *        
    ***********************************************/
    changed(integer change) {
         if (change ==CHANGED_INVENTORY){         
             llResetScript();
         }
     }
}//default state

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/lsl/root_prim_board/_httpIn_handler.lsl

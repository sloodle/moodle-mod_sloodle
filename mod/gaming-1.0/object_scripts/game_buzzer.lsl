//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*  Part of the Sloodle project (www.sloodle.org)
*
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
*  -------------------------------------------
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  All scripts must maintain this copyrite information, including the contributer information listed
*
*  Developer:
*   Paul Preibisch
*
*******************************
*  Description                *
*******************************
*  
*  This buzzer script is free for use, and was designed for educators using virtual worlds
*  It has now become part of the SLOODLE project, and the AVATARCLASSROOM and licensed under GPL 3.0
*  Basically, that means, you are free to use the script, commercially etc, but if you include
*  it in your objects, you must make the source viewable to the person you are distributuing it to -
*  ie: it can not be closed source - GPL 3.0 means - you must make it open!
*
*  This is so that others can modify it and contribute back to the community.
*  The SLOODLE github can be found here: https://github.com/sloodle

*  Enjoy!
*  
*  This buzzer can be used for games which require contestants to "hit a buzzer" before 
*  they can answer a question.  To turn the buzzer ON, click on the green ON cylindar at the 
*  base of the buzzer.  A large mechanical arm with a big green click me button will appear.
*  Up to three contestants can hit the green cylindar by touching it.  When they do
*  their names will be listed in order below, in 3 mechanical drawers which pop down
*
*******************************
*  The Red Off Button         *
*******************************
*  
*  The large Red Cylindar that says "Off" is used to deactivate clicking - so no user will be able 
*  to click the buzzer.  Click the "Off" button in between questions.  When you have asked your question
*  you can click the green "On" button, so contestants can click it indicating that they want to answer the question
*
*
********************************
*  The Green On Button         *
********************************
*
* Once you have asked your question, the teacher presses the green "on" button which
* will automatically display a mechanical arm with a large green button attached that says
* "Click Me"  when a user clicks the green "Click Me" button, their name will be displayed
* in a large rectangular drawer below the timer.  Up to three students can click the green button
*  
*******************************
*  Using the Count Down Timer *
*******************************
* 
*  This buzzer also comes with a count down timer.
*  The teacher can press the green "start" button to start the count down, and the red "stop" button
*  to stop the countdown.  This is useful in cases where the teacher wants to give the contestant a time limit in answering
*  a question.  When the countdown reaches 5 seconds, there will be an audible beeping sound
*  and a big buzzer sound at when the buzzer reaches zero. 
*
*
**********************
*  Setting the Timer *
**********************
*
*  The teacher can set the timer by pressing the orange "Set Timer" button at the base of the buzzer, then
*  using the iphone like keypad to enter a new time.  Press "Set Timer" once more when finished. Each time the user
*  presses a keypad, a new digit will be displayed on the surface of the timer, so it is 
*  easy to see the digits that are being typed in.  Note, if you make a mistake, there is a backspace key on the keypad
*  which you can press to erase the last digit.  The number sign icon does nothing.
*
*******************
*  HIDE BUTTON    *
*******************
*
*  Lastly, there is a large yellow cylindar that says "Hide" - use this to hide the large mechanical arm
*  in cases where a game is finished, or you simply want to use this buzzer as a count down timer.
*  When teacher is ready, they click the ball, it turns green indicating it is ready to be clicked, count down timer displays
*
*******************
*  Sound Licenses.*
*******************
* All sounds were sourced from the http://freesound.org website
* please view their licences below
*
* Kodak Printer sound: http://www.freesound.org/samplesViewSingle.php?id=48667
* http://creativecommons.org/licenses/sampling+/1.0/
* nice.wav visit: http://www.freesound.org/samplesViewSingle.php?id=51488
* beepbeep.wav beep: http://www.freesound.org/samplesViewSingle.php?id=32683
*/


key     gSetupQueryId; //used for reading settings notecards
list    gInventoryList;//used for reading settings notecards
string     gSetupNotecardName="config";//used for reading settings notecards
integer gSetupNotecardLine;//used for reading settings notecards
integer SETTEXT_CHANNEL= -8882;
integer SET_COLOR_CHANNEL=-889;
integer SOUND_CHANNEL                                                     = -34000;//sound requests
integer TIME_S = 0;
integer TIME_M=1;
integer TIME_H=0;
integer keyPressCount;
integer MAX_TIME;
string editNum="";
integer SETTIMER=FALSE;
string SHOWARM="HIDE";
string editM;
string editS;
string editH;
string SLOODLE_EOF = "sloodleeof";
integer eof= FALSE;
list winners;
list winnerKeys;
list sitters;
list booths;
string myName;
integer buzzerButton;//to identify which link is the buzzerButton
key myKey;
list facilitators;//list of people who can control the buzzer
integer PLUGIN_RESPONSE_CHANNEL                                =998822; //sloodle_api.lsl responses
integer PLUGIN_CHANNEL                                                    =998821;//sloodle_api requests
integer UI_CHANNEL                                                            =89997;//UI Channel - main channel
integer ROW_CHANNEL;
// *************************************************** HOVER TEXT COLORS
vector     RED            = <0.77278, 0.04391, 0.00000>;//RED
vector     YELLOW         = <0.82192, 0.86066, 0.00000>;//YELLOW
vector     GREEN         = <0.12616, 0.77712, 0.00000>;//GREEN
vector     PINK         = <0.83635, 0.00000, 0.88019>;//INDIGO
vector     WHITE        = <1.000, 1.000, 1.000>;//WHITE
integer MENU_CHANNEL;
integer XY_1= -999821;
integer XY_2= -999822;
integer XY_3= -999823;
integer XY_TIMER= -999824;
integer XY_AWARD_NAME= -999825;
integer counter;
list modButs = ["+10","+30","-10","-30","+60","-60","+300","-300"];
list pointMods=["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000","~~ SAVE ~~"]; //this is a list of values an owner can modify a users points to //["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000",
list modifyPointList; //this is a temp list that is used to store point modifications in.  When Save is pressed on a menu, these points are applied to the users point bank
integer modPoints;
integer currentAwardId;
string currentAwardName;
list primNames;

//deletes an item from a list
list ListItemDelete(list mylist,string element_old) {
    integer placeinlist = llListFindList(mylist, [element_old]);
    if (placeinlist != -1){
        return llDeleteSubList(mylist, placeinlist, placeinlist);
    }
    return mylist;
}//listitemdelete

//clear the timer screen
clear(){
        llMessageLinked(LINK_SET, XY_1,"                              ", NULL_KEY);
        llMessageLinked(LINK_SET, XY_2,"                              ", NULL_KEY);
        llMessageLinked(LINK_SET, XY_3,"                              ", NULL_KEY);
}

//center the xy text s, which is of length len, and listens to channel 
center(string s,integer len,integer channel){
            
            integer marginLen= (integer)(len-llStringLength((string)s))/2;
            integer j;
            string spaces="";
            for (j=0;j<len*10+1;++j){
                spaces+=" ";    
            }
            string margin = llGetSubString(spaces, 0, marginLen);
            string text = margin + (string)(s)+margin;
            llMessageLinked(LINK_SET, channel,text , NULL_KEY);
}

//returns the link number of the prim named pName
integer getLink(string pName){
    return (llListFindList(primNames,[pName]));
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
preloadSounds(){
    key buzzer = "SND_BUZZER";
    llPreloadSound(buzzer);    
    key tick = "SND_TICK";
    llPreloadSound(tick);    
    key beepbeep = "SND_BEEPBEEP";
    llPreloadSound(beepbeep);    
    key onetype = "SND_TYPE";
    llPreloadSound(onetype );    
    key ipress = "SND_IPRESS";
    llPreloadSound(ipress );    
    key pd = "SND_POWER_DOWN";
    llPreloadSound(pd );    
    key iopen = "cf218344-0251-6bfd-acba-fdd5534861b1";
    llPreloadSound(iopen );
}

/***********************************************
*  isFacilitator()
*  |-->is this person's name in the access notecard
***********************************************/
integer isFacilitator(string avName){
    if (llListFindList(facilitators, [llToLower(avName)])==-1) return FALSE; else return TRUE;
}
/***********************************************
*  getMaxTime(integer seconds,integer minutes,integer hours)
*  |-->gets thenumber of seconds
***********************************************/
integer getSeconds(string seconds,string minutes,string hours){
    
    
    integer timeLeft = i(seconds)+60*i(minutes)+3600*i(hours);
    return timeLeft;
}
/***********************************************
*  getMaxTime(integer seconds,integer minutes,integer hours)
*  |-->gets thenumber of seconds and returns a formated list 00:00:00
***********************************************/
string  getTime(integer seconds){
    
    integer hours = (integer)(seconds/3600);
    
    integer minutes = (integer)((seconds/60)- (hours*60));
    
    integer s = (integer)(seconds%60);

    if (s ==60) { 
        minutes+=1;
        s = 0;
    }
    if (minutes==60){
        hours+=1;
        minutes=0;
    }
    string sString;
    string mString;
    string hString;
    if (llStringLength((string)s)==1) {
        sString= "0"+(string)s;
    }else sString = (string)s;
    if (llStringLength((string)minutes)==1) {
        mString= "0"+(string)minutes;
    }else mString = (string)minutes;
    if (llStringLength((string)hours)==1) {
        hString= "0"+(string)hours;
    }else hString = (string)hours;
    
    return hString+":"+mString+":"+sString;
}



/***********************************************
*  random_integer()
*  |-->Produces a random integer
***********************************************/ 
integer random_integer( integer min, integer max )
{
  return min + (integer)( llFrand( max - min + 1 ) );
}
string setTime;
integer isconfigured=FALSE;
integer newChannel;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script.
string time="00:00:00";
integer sloodle_handle_command(string str) 
        {
    
            list bits = llParseString2List(str,["|"],[]);
            integer numbits = llGetListLength(bits);
            string name = llList2String(bits,0);
            string value1 = "";
            string value2 = "";
            
            if (numbits > 1) value1 = llList2String(bits,1);
            if (numbits > 2) value2 = llList2String(bits,2);
            
            if (name == "set:facilitator"){
                 facilitators+=llToLower(value1);
            }else
            if (name == "set:time"){
                 time= (string)value1;
                 center(time,10,XY_TIMER);
            }
            else if (name == SLOODLE_EOF){
                 eof = TRUE;
                return (time != "00:00:00");
            }
return FALSE;
        }

default {

    state_entry() {
        facilitators+=llToLower(llKey2Name(llGetOwner()));
        llTriggerSound("SND_STARTING_UP",1.0);//starting up
        MAX_TIME = TIME_S + TIME_M*60+TIME_H*3600;
        //get number of linked prims
        integer numPrims = llGetNumberOfPrims();
        //find out which one is buzzer prim
        integer j;
        for (j=0;j<=numPrims;j++){
            primNames +=llGetLinkName(j);          
        }//endfor
        llMessageLinked(LINK_SET, 1, "p0",NULL_KEY);
        myName = llGetObjectName();
        myKey = llGetKey();
        MENU_CHANNEL = random_integer(2000,3000);
        ROW_CHANNEL=random_integer(2483000,3483000);
       state ready;
             
    }//end state_entry
      
     on_rez(integer start_param) {
        llResetScript();
    }
    link_message( integer sender_num, integer num, string str, key id)
            {
                // Check the channel
                if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Split the message into lines
                    list lines = llParseString2List(str, ["\n"], []);
                    integer numlines = llGetListLength(lines);
                    integer i = 0;
                    for (i=0; i < numlines; i++) {
                        isconfigured = sloodle_handle_command(llList2String(lines, i));
                    }if (isconfigured){
                        state ready;
                    
                    }
                }
    }
      changed(integer change) { // something changed
        if (change ==CHANGED_INVENTORY){         
             llResetScript();
        }//endif
    }
}//end default

      
//waiting for teacher to touch it
state ready{
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        llTriggerSound("SND_LOADING_COMPLETE", 1.0);//loading complete
        llOwnerSay("Ready! Click the green cylindar to engage the buzzer!\nPress the red cylindar to disengage the buzzer, and the yellow cylindar to hide it!");
        integer j=0;
        integer len = llGetListLength(booths);
        /****************************************
        *  INITIALIZE
        *****************************************/
            llSetTimerEvent(0);
            //move arm to waiting position
            llMessageLinked(LINK_SET, 1, "p1",NULL_KEY);
            winners=[];
            winnerKeys=[];
            modifyPointList=[0,0,0];            
        /****************************************
        *  PLAY SOUNDS
        *****************************************/
           llTriggerSound("SND_FAST_KODAK", 1.0);

        /****************************************
        *  INIT DISPLAY
        *****************************************/
            //center text
            
            
            //set hover text
            llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY::top display|STRING::Ready:|COLOR::"+(string)RED+"|ALPHA::1.0",NULL_KEY);
            //clear text
            clear();
            //set red
            llMessageLinked(LINK_SET,SET_COLOR_CHANNEL,"COMMAND:SET COLOR|PRIM:buzzer_button|COLOR:RED",NULL_KEY);
    }//end state_entry


    
    
    touch_start(integer num_detected) {

        //each prim that has a blink.lsl script in it, will set its glow to .90 for 1 second when this message is received
            
        integer j;
        for (j=0;j<num_detected;j++){
            string butName = llGetLinkName(llDetectedLinkNumber(j));
        if (isFacilitator(llDetectedName(j))){
            
                llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:BLINK|PRIM:"+butName, NULL_KEY);
                if (butName=="hide_arm_button"){
                    llMessageLinked(LINK_SET, 1, "p0",NULL_KEY);
                   llTriggerSound("SND_FAST_KODAK", 1.0);//fastkodak
                    return;
                    
                }//endif
                else
               if (butName=="dock_arm"){    
              //     if (SHOWARM=="SHOW"){
                    llSetLinkPrimitiveParams(getLink("buzzer_button"), [PRIM_COLOR, ALL_SIDES, RED, 1.0,
                    PRIM_TEXTURE, 0, "blank",<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]);
                    llTriggerSound("SND_POWER_DOWN", 1.0);//power down
                     llMessageLinked(LINK_SET, 1, "p1",NULL_KEY);
                     SHOWARM="HIDE";
                     return;
              //     }//SHOWARM
                  
              }//endifndif
              else 
              if (butName=="show_arm"){
                    SHOWARM="SHOW";
                    llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:BLINK|PRIM:timer", NULL_KEY);
                    llTriggerSound("SND_POWER_UP", 1.0);
                    llSetLinkPrimitiveParams(getLink("buzzer_button"), [PRIM_COLOR, ALL_SIDES, GREEN, 1.0,
                    PRIM_TEXTURE, 0, "click",<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]);
                    llMessageLinked(LINK_SET, 1, "p2",NULL_KEY); 
                     llTriggerSound("SND_FAST_KODAK", 1.0);//fastkodak


                    winners=[];
                    return;
             }//endif
            else 
            if (butName=="hide_arm_button"){    
                SHOWARM="HIDE";
                            
            }//endif
            else         
            if (butName=="stopwatch_button"){        
                 llTriggerSound("SND_SPACE_CODE", 1.0);//SPACCODE buzzer button press    
                  llSetTimerEvent(0);
                  
                  SETTIMER=FALSE;
                  return;
            }//endif
            else
            if (butName=="resetwatch_button"){        
                   llTriggerSound("SND_SPACE_CODE", 1.0);//SPACCODE buzzer button press 
                  llSetTimerEvent(0);
                  counter=0;
                      MAX_TIME= TIME_S + TIME_M*60+TIME_H*3600;  
                      SETTIMER=FALSE;
                      integer timeLeft = MAX_TIME-counter;
                    string printTime = getTime(timeLeft);
                    center(printTime,10,XY_TIMER);
                    return;
            }//endif
            else 
            if (butName=="startwatch_button"){
             if (SETTIMER==TRUE){                       
                  TIME_S = (integer)llGetSubString(editNum, 6,7);
                  TIME_M =(integer)llGetSubString(editNum, 3,4);
                  TIME_H = (integer)llGetSubString(editNum, 0,1);                
                  SETTIMER==FALSE;
                  
              }
              MAX_TIME= TIME_S + TIME_M*60+TIME_H*3600;  
                 llTriggerSound("SND_SPACE_CODE", 1.0);//SPACCODE buzzer button press 
               
                
                llSetTimerEvent(1); 
                return;                   
            }//endif
           else
           if (butName=="set_timer"){
                llTriggerSound("SND_INTERFACE_PRESS", 1.0);//interface press        
                llSetTimerEvent(0);
                keyPressCount=0;
                
                if (SETTIMER==TRUE){
                    //Sound source: http://www.freesound.org/samplesViewSingle.php?id=2329
//license: http://creativecommons.org/licenses/sampling+/1.0/

                llTriggerSound("SND_CONFIRMED", 1.0);//confirmed


                    TIME_S = (integer)llGetSubString(editNum, 6,7);
                      TIME_M =(integer)llGetSubString(editNum, 3,4);
                      TIME_H = (integer)llGetSubString(editNum, 0,1);                
                    MAX_TIME= TIME_S + TIME_M*60+TIME_H*3600;  
                   
                    SETTIMER=FALSE; 
                    integer timeLeft = MAX_TIME-counter;
                    string printTime = getTime(timeLeft);
                    center(printTime,10,XY_TIMER);
                }else {
                    editNum="00:00:00";
                    SETTIMER=TRUE;
                }
                return;
            }//endif          
         else
         if (butName=="backspace"){
               if (SETTIMER==TRUE){
                      if (llStringLength(editNum)==1) editNum="";
                    else editNum= llGetSubString(editNum,0,llStringLength(editNum)-2);
                   llTriggerSound("SND_TYPE", 1.0);//one type
                    center(editNum,10,XY_TIMER);
              }//SETTIMER
              return;
        }//backspace
        else 
        if (llListFindList(["b1","b2","b3","b4","b5","b6","b7","b8","b9","b0"],[butName])!=-1){
            if (SETTIMER==TRUE){
                    counter=0;
                    keyPressCount++;
                    string printTime ="";
                    string num = llGetSubString(butName,1,1);
                    if (keyPressCount==1) editNum =llGetSubString(editNum, 0, 6)+num; else
                    if (keyPressCount==2) editNum =llGetSubString(editNum, 0, 5) +llGetSubString(editNum, 7, 7) + num; else
                    if (keyPressCount==3) editNum =llGetSubString(editNum, 0, 3) +llGetSubString(editNum, 6, 6) +":" +llGetSubString(editNum, 7, 7) + num; else
                    if (keyPressCount==4) editNum =llGetSubString(editNum, 0, 2) +llGetSubString(editNum, 4, 4) +llGetSubString(editNum, 6, 6) + ":" +llGetSubString(editNum, 7, 7) + num; else
                    if (keyPressCount==5) editNum ="0"+llGetSubString(editNum, 3, 3) +":"+llGetSubString(editNum, 4, 4) +llGetSubString(editNum, 6, 6) + ":" +llGetSubString(editNum, 7, 7) + num; else
                    if (keyPressCount==6) editNum =llGetSubString(editNum, 1, 1) +llGetSubString(editNum, 3, 3)+":" +llGetSubString(editNum, 4, 4)  +llGetSubString(editNum, 6, 6) + ":" +llGetSubString(editNum, 7, 7) + num;
                    setTime = editNum;
                    center(editNum,10,XY_TIMER);
                    llTriggerSound("SND_TYPE", 1.0);//one type
            }//SETTIMER==TRUE
            return;
        }//end if llListFind
               
        }//end if facilitator
         else 
         if  (butName!="buzzer_button") llSay(0,"Sorry, you need to be a facilitator to use this function.  Facilitators are: "+(string)llList2CSV(facilitators));
       
        
        /********************************************************
        *  Player clicks
        *********************************************************/
        if (butName=="buzzer_button"){
   //         llSay(0,(string)llList2CSV(sitters)+"**********"+(string)llDetectedKey(0));
          //  if (llListFindList(sitters, [llDetectedKey(0)])!=-1){
                    //llMessageLinked(LINK_SET,SOUND_CHANNEL, "COMMAND:PLAYSOUND|SOUND:beep|SCRIPT_NAME:soundPlayer 1|VOLUME:1.0",NULL_KEY);                          
                    integer printChannel;
                    string userName=llDetectedName(j);
                    key userKey = llDetectedKey(j);                
                       if (SHOWARM=="SHOW"){
                   //       if (llListFindList(sitters, [llDetectedKey(0)])!=-1){
                                  llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:BLINK|PRIM:"+butName, NULL_KEY);
                              //only 3 people are allowed to click
                             if (llListFindList(winners, [userName])==-1){
                                 //if hasnt been added, add to winners
                                 winners+=userName;
                                 winnerKeys+=userKey;
                                 //get number of winners
                                 integer numWinners = llGetListLength(winners);
                                 string anim="p3";
                                 if (numWinners<4){
                                     //play buzzer sound if one of the first 3 to click
                                     llTriggerSound("SND_GAME_BUZZER_HIT", 1.0);//game_show_buzzer_hit
                                     if (numWinners ==1){
                                         printChannel=XY_1;
                                         anim = "p3";
                                     }else
                                     if (numWinners ==2){
                                         printChannel=XY_2;
                                         anim ="p4";
                                     }else
                                     if (numWinners ==3){
                                         printChannel=XY_3;
                                         anim ="p5";
                                     }
                             //only print username on scoreboard if one of the first 3 to click    
                             llMessageLinked(LINK_SET, printChannel,userName, NULL_KEY);
                             //play animation
                             llMessageLinked(LINK_SET, 1, anim,NULL_KEY);
                             return;
                          }//endif numWinners < 4
                         }//findlist winners             
                  //   }//findlist sitters
                   } //showarm           
             //  }//findlist sitters 
        }//end if buttname
                            }
    }//end touch
    timer() {
        //gets thenumber of seconds and returns a formated list 00:00:00
        
        integer timeLeft = MAX_TIME-counter;
        string printTime = getTime(timeLeft);
        center(printTime,10,XY_TIMER);
        ++counter;
          if (timeLeft<5){
          llTriggerSound("SND_BEEPBEEP", 1.0);//beep beepbeep beep
        }else
        llTriggerSound("SND_TICK", 1.0);//tick
        if (counter>MAX_TIME){                
            llSetTimerEvent(0.0);
            llMessageLinked(LINK_SET, 1, "bp0",NULL_KEY);         
            counter=0;
            center("00:00:00",10,XY_TIMER);
           llTriggerSound("SND_BUZZER", 1.0);//buzzer
}        
        }//end timer    
          changed(integer change) { // something changed
        if (change ==CHANGED_INVENTORY){         
             llResetScript();
        }//endif
    }
}//end state



// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/gaming-1.0/object_scripts/game_buzzer.lsl 

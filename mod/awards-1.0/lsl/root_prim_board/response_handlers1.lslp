/*********************************************
*  Copyrght (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
* response_handlers1.lsl
* 
* This script is responsible for handling and reacting to contact received as output from SLOODLE on the 
* PLUGIN_RESPONSE_CHANNEL once a request has been received from the sloodle_api_new.lsl script.
*
* It also responds to messages sent on the UI_CHANNEL from other scripts in the system. These messages are:
* 
* AWARD SELECTED (Gets triggered during setup when user selects the award to display)
* SET CURRENT BUTTON (Gets triggered when a user clicks a button)
* UPDATE ARROWS (this is when the next/previous button is pressed so we know which page we are on)
* SET CURRENT GROUP (used when users are manipulating groups)
* GET CLASS LIST (A message sent when the class list is requested)
* UPDATE VIEW CLASS LIST 
* DISPLAY MENU  (This gets triggered when someone clicks on an XY_prim in a row of the scoreboard)
* 
* 
* 
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
*
*/ 
integer ROW_CHANNEL;
string stringToPrint;
list lines;
integer numStudents;
integer totalPages;
list userDetails;
integer index;
integer index_teamScores;
integer index_getClassList;
integer index_selectTeams;
integer DISPLAY_DATA                                                        =-774477; //every time the display is updated, data goes on this channel
integer WEB_UPDATE_CHANNEL                                        =-64000; // data we receive from an http request from httpIn handler
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
integer ANIM_CHANNEL                                                      =-77664251;//animation trigger channel
integer PAGE_SIZE=10; //can display only 10 users at once.
integer SET_ROW_COLOR= 8888999;
integer PLAYERNAME=0; //constant which defines a list postion our specific data is in to make code more readable
integer PLAYERPOINTS=1; //constant which defines a list postion our specific data is in to make code more readable
integer SLOTCHANNEL=2; //constant which defines a list postion our specific data is in to make code more readable
integer AVUUID=3; //constant which defines a list postion our specific data is in to make code more readable
integer MAX_XY_LETTER_SPACE=30;
list rows;
string authenticatedUser;
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
list rows_getAwardGrpMbrs;
list rows_selectTeams;
list rows_selectAward;
list rows_getClassList;
integer previousAwardId;
integer selectedAwardId=0;
integer currentIndex;
string currentGroup;
string sortMode="balance";
list pointMods=["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000"]; //this is a list of values an owner can modify a users points to //["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000",
list modifyPointList; //this is a temp list that is used to store point modifications in.  When Save is pressed on a menu, these points are applied to the users point bank
integer modPoints;
string myUrl;
string displayData;
list facilitators;
integer SCOREBOARD_CHANNEL;
// *************************************************** HOVER TEXT COLORS
vector     RED            = <0.77278, 0.04391, 0.00000>;//RED
vector     YELLOW         = <0.82192, 0.86066, 0.00000>;//YELLOW
vector     GREEN         = <0.12616, 0.77712, 0.00000>;//GREEN
vector     PINK         = <0.83635, 0.00000, 0.88019>;//INDIGO
vector     WHITE        = <1.000, 1.000, 1.000>;//WHITE
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
*  isFacilitator()
*  |-->is this person's name in the access notecard
***********************************************/
integer isFacilitator(string avName){
    if (llListFindList(facilitators, [llStringTrim(llToLower(avName),STRING_TRIM)])==-1) return FALSE; else return TRUE;
}

/***********************************************
*  clearHighlights -- makes sure all highlight rows are set to 0 alpha
***********************************************/
clearHighlights(){
    integer c;
    for (c=0;c<=9;c++){
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
integer random_integer( integer min, integer max ){
  return min + (integer)( llFrand( max - min + 1 ) );
}
/***********************************************
*  displayModMenu(string userName,integer userPoints, integer row_channel)
*  Is used to display a dialog menu so owner can modify the points awarded 
***********************************************/
displayModMenu(string name,string userPoints, string row_channel,string avKey){
                     integer points=i(userPoints);       
                     integer channel = i(row_channel);     
                     string userName   = s(name);       
                     integer rowNum =  channel-ROW_CHANNEL;
                     key av_key= k(avKey);
                     //llSay(0,"++++++++++++++ points"+(string)points+" channel "+(string)channel+" username: "+userName+" rowNum: "+(string)rowNum+ "avKey: "+(string)av_key);
                     modPoints = points + llList2Integer(modifyPointList,rowNum);
                     if (modPoints <0) modPoints=0;                                                         
                     llDialog(llGetOwner()," -~~~ Modify iPoints awarded: "+(string)userPoints+" ~~~-\n"+userName+"\nModify Points to: "+(string) modPoints, ["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000"] + ["~~ SAVE ~~"], channel);
}

string SLOODLE_EOF = "sloodleeof";
 integer sloodle_handle_command(string str) {
         
        list bits = llParseString2List(str,["|"],[]);
        integer numbits = llGetListLength(bits);
        string name = llList2String(bits,0);
        string value1 = "";
        string value2 = "";
        if (numbits > 1) value1 = llList2String(bits,1);
        if (name == "facilitator"){ 
                    facilitators+=llStringTrim(llToLower(value1),STRING_TRIM);
        }
        else if (name == "SCOREBOARD_CHANNEL") {
            SCOREBOARD_CHANNEL=(integer)value1;
            debug("*******************GOT SCOREBOARD CHANNEL: "+(string)SCOREBOARD_CHANNEL);
              llListen(SCOREBOARD_CHANNEL, "", "", "");
            debug("listening to: "+(string)SCOREBOARD_CHANNEL);
        }
        else if (name == SLOODLE_EOF) return TRUE;
        return FALSE;
    }
default{    
    state_entry() {
         owner=llGetOwner();
         //llMessageLinked(LINK_SET, UI_CHANNEL, "CMD:REGISTER VIEW|INDEX:0|TOTALITEMS:0|COMMAND:cmd{index}|CHAN:channel",NULL_KEY);
         //create a random ROW_CHANNEL index within a range of 5,000,000 numbers - to avoid conflicts with other scoreboards
          //this user channel will accept messages from the owner when the owner clicks on a scoreboard row        
          ROW_CHANNEL=random_integer(2483000,3483000);
          integer c=0;
         //listen to all userchannels so we can detect scoreboard row clicks          
         for (c=0;c<10;c++){
            llListen(ROW_CHANNEL+c, "", "", "");  
         }//endfor
         //initialize tempory storage for row calculations          
         modifyPointList=[0,0,0,0,0,0,0,0,0,0];      
         //add the owner to the facilitators list 
        facilitators+=llKey2Name(llToLower(llGetOwner()));
      
    }
    
    link_message(integer sender_num, integer channel, string str, key id) {      
debug(str);


             if (channel==SLOODLE_CHANNEL_OBJECT_DIALOG){
                sloodle_handle_command(str);
            }//endif SLOODLE_CHANNEL_OBJECT_DIALOG
            else
            
            /*********************************
            * Handle the UI_CHANNEL 
            *********************************/
             if (channel==UI_CHANNEL){
                 list dataBits = llParseString2List(str,["|"],[]);
                 string command = s(llList2String(dataBits,0));
                 /*********************************
                 * Capture current award - this messageg gets fired when a new award has been chosen               
                 *********************************/                 
                 if(command=="AWARD SELECTED"){
                     currentAwardId=i(llList2String(dataBits,1));
                     //connect display to newly selected award                     
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
                     currentIndex = i(llList2String(dataBits,2));

                 }//endif
                 else
                /*********************************
                 * Capture current group                 
                 *********************************/                            
                 if (command=="SET CURRENT GROUP"){
                     currentGroup=s(llList2String(dataBits,1));
                 }//endif
                 else
                /*********************************
                * Capture GET CLASS LIST 
                *********************************/               
                if (command=="GET CLASS LIST"){
                    if (currentView=="Top Scores"||currentView=="Sort by Name"){                      
                        index = i(llList2String(dataBits,1));
                        sortMode = s(llList2String(dataBits,2));           
                        key avuuid = k(llList2String(dataBits,3));           
                        authenticatedUser= "&sloodleuuid="+(string)avuuid+"&sloodleavname="+llEscapeURL(llKey2Name(avuuid));
                        llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->getClassList"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index+"&sortmode="+sortMode, NULL_KEY);
                     }//endif
                }else 
                    /*********************************
                   * Capture UPDATE VIEW CLASS LIST 
                   *********************************/               
                 if (command=="UPDATE VIEW CLASS LIST"||command=="UPDATE DISPLAY"){
                    if (currentView=="Top Scores"||currentView=="Sort by Name"){
                         //COMMAND:GETCLASSLIST|SORTMODE:"+sortMode    
                         authenticatedUser= "&sloodleuuid="+(string)owner+"&sloodleavname="+llEscapeURL(llKey2Name(owner));               
                          llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->getClassList"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index_getClassList+"&sortmode="+sortMode, NULL_KEY);
                     }//end if
                     else
                     if (currentView =="Team Top Scores"){
                         authenticatedUser= "&sloodleuuid="+(string)owner+"&sloodleavname="+llEscapeURL(llKey2Name(owner));               
                     llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getTeamScores"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index_teamScores+"&maxitems=9&sortmode=balance", NULL_KEY);
                     }
                     else
                     if (currentView =="Select Teams"){
                         owner=llGetOwner();
                         authenticatedUser= "&sloodleuuid="+(string)owner+"&sloodleavname="+llEscapeURL(llKey2Name(owner));               
                        llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getAwardGrps"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index_selectTeams+"&maxitems=9", NULL_KEY);                     
                     }
                 }//endif command = update view class list
                 else
                 /***********************************************************************************
                 * Capture DISPLAY MENU - scoreboard row clicks
                 ***********************************************************************************/                              
                 if (command=="DISPLAY MENU"){                     
                    //since the XY Display board can be used to display different lists besides the user list, we must first check which displayMode is current.                         
                    integer rowNum =i(llList2String(dataBits,1));                 
                    key av= k(llList2String(dataBits,2));
                    //make sure it was the owner who clicked on the row
                    if (isFacilitator(llKey2Name(av))){
                        authenticatedUser= "&sloodleuuid="+(string)av+"&sloodleavname="+llEscapeURL(llKey2Name(av));               
                    /*****************************************************************    
                     * Select Award  - this is the handler when user is selecting an awards activitiy                 
                     *****************************************************************/                        
                        if (currentView=="Select Award"){
                                     //save previous award
                                     previousAwardId = selectedAwardId;
                                     //clear all highlights
                                    clearHighlights();
                                    //list row structure
                                    //0[0awardId,1awardName] 
                                    //1[2awardId,3awardName]
                                    //2[4awardId,5awardName]
                                    //highlight chosen award
                                    llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)rowNum+"|POWER:ON|COLOR:GREEN",NULL_KEY);
                                    //get awardId                                    
                                    integer awardId = llList2Integer(rows_selectAward,rowNum*2);
                                    //get awardName
                                    string   awardName =llList2String(rows_selectAward,rowNum*2+1); 
                                    //send award choice 
                                    llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:AWARD SELECTED|AWARDID:"+(string)awardId+"|NAME:"+awardName, NULL_KEY);
                                    selectedAwardId = awardId;
                                    //detach current display from currentAward
                       }//currentView!="Select Award"
                       else
                    /*****************************************************************
                     * Group Membership editing members view and has clicked a row with a user on it                
                     *****************************************************************/           
                        if (currentView=="Group Membership Users"){
                            //[uuid][avname][balance][mbr]
                            list clickedUser = llList2List(rows_getAwardGrpMbrs,rowNum*4,rowNum*4+4);                                     
                            key useruuid= k(llList2String(clickedUser,0));
                            string userName = llEscapeURL(s(llList2String(clickedUser,1)));
                            string mbr = s(llList2String(clickedUser,3));
                            if (mbr=="yes"){
                                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->removeGrpMbr"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&grpname="+llEscapeURL(currentGroup)+"&avuuid="+(string)useruuid+"&avname="+userName, NULL_KEY);
                            }//endif
                            else{
                                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->addGrpMbr"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&grpname="+llEscapeURL(currentGroup)+"&avuuid="+(string)useruuid+"&avname="+userName, NULL_KEY);
                            }//endif                  
                        }//end currentView="Group Membership Users"
                        else
                    /*****************************************************************
                     * Group Membership view - selecting a group to edit members
                     *****************************************************************/           
                        if (currentView=="Group Membership"){
                            //display menu for the group
                            //in this mode, a list of course groups are displayed. The user clicks on one to see the membership of that group
                            string clickedGroup= llEscapeURL(llList2String(rows_getAwardGrps,rowNum));
                            //set current button
                               llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s3|DESCRIPTION:Group Membership Users",NULL_KEY);
                            //keep track of which group we are viewing
                            current_grp_membership_group = clickedGroup;
                            //set current clicked group
                            llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT GROUP|GRPNAME:"+current_grp_membership_group,NULL_KEY);                                     
                            //now request from the sloodle api to return all members starting at index 0, 
                            llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->getAwardGrpMbrs"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&grpname="+clickedGroup+"&index="+(string)index+"&sortmode=name", NULL_KEY);
                       }//end currentView=="Group Membership"
                       else
                    /*****************************************************************
                     * Select Teams - editing teams connected to the award activity                 
                     *****************************************************************/           
                       if (currentView=="Select Teams"){
                             //highlight row
                            string clickedGroup =llList2String(rows_selectTeams,rowNum);
                            //display a menu for select team
                            if (llListFindList(awardGroups, [clickedGroup])==-1){//add group
                                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->addAwardGrp"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&grpname="+llEscapeURL(clickedGroup), NULL_KEY);
                           }
                           else{ //remove group
                                   llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->removeAwardGrp"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&grpname="+llEscapeURL(clickedGroup), NULL_KEY);                     
                           }  //endif                                
                      }//end currentView
                     
                   }//av!=owner
                 }//end command==DISPLAY MENU
             }//end UI_CHANNEL
             else 
            /*****************************************************************
            * Handle the PLUGIN_RESPONSE_CHANNEL     
            *****************************************************************/           
            if (channel==PLUGIN_RESPONSE_CHANNEL){
                dataLines = llParseStringKeepNulls(str,["\n"],[]);           
                //get status code
                list statusLine =llParseStringKeepNulls(llList2String(dataLines,0),["|"],[]);
                integer status =llList2Integer(statusLine,0);
                string descripter = llList2String(statusLine,1);
                key authUserUuid = llList2Key(statusLine,6);
                string response = s(llList2String(dataLines,1));
                index = i(llList2String(dataLines,2));                 
                integer totalGroups= i(llList2String(dataLines,3));
                string data = llList2String(dataLines,4);
                
                authenticatedUser= "&sloodleuuid="+(string)authUserUuid+"&sloodleavname="+llEscapeURL(llKey2Name(authUserUuid));                             
                if (response=="awards|getAwards"){
                /*****************************************************************
                * Select an award - response
                * This is the response from requesting a list of award activities in the course                 
                *****************************************************************/           
                if (currentView=="Select Award"){                    
                integer totalAwards= i(llList2String(dataLines,3));
                //check status of returned response
                if (status==1){
                //initialize rows we store                                                     
                    rows_selectAward=[];
                    //clear all highlights
                    clearHighlights();                                
                    //update arrows & page number
                    llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:UPDATE ARROWS|VIEW:"+currentView+"|INDEX:"+(string)index+"|TOTALITEMS:"+(string)totalAwards, NULL_KEY);
                    //initialize the string we will print on xy_text channel
                    stringToPrint="";
                    //get all of the award activities returned
                    list award_activities = llList2List(dataLines,4,llGetListLength(dataLines));
                    integer len = llGetListLength(award_activities);
                    displayData="CURRENT VIEW:"+currentView+"\n"; 
                    for (counter=0;counter<len;counter++){
                            list awardData =llParseString2List(llList2String(award_activities,counter), ["|"], []); //parse the message into a list
                            //get awardId from awarddata
                            integer awardId =i(llList2String(awardData,0));
                            //highlight the currently selected award (if selected)
                            if (awardId==selectedAwardId){
                                //highlight row
                                llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)counter+"|POWER:ON|COLOR:GREEN",NULL_KEY);
                            }

                            //get award name
                            string awardName= s(llList2String(awardData,1));
                            displayData+="AWARDNAME:"+awardName;
                            if (counter!=len)displayData+="\n";
                            //add award to our rows
                            rows_selectAward+=[awardId,awardName];
                            //trim the length of the award name is to long for our display                                    
                             if (llStringLength(awardName)>25){
                                 awardName = llGetSubString(awardName, 0, 24);
                             }
                             //compute how much space is needed between names 
                             integer spaceLen=MAX_XY_LETTER_SPACE - (llStringLength((string)((counter+1)))+2+llStringLength(awardName));
                             //add room for the index, the bracket, and award name
                             string text=(string)(index+counter+1)+") "+awardName;
                              //here we add the number of spaces by grabbing a chunk of spaces from the string of spaces below below and appending it to text
                             text+=llGetSubString("                              ", 0, spaceLen-1) ;
                             //now add the stringToPrint to the end. This will effectively placed the correct number of spaces in between the name, and the points                                         
                             stringToPrint+=text;
                    }//for
                    //now send this text to the xy_prims
                    llMessageLinked(LINK_SET, XY_TEXT_CHANNEL,stringToPrint, NULL_KEY);
                    llMessageLinked(LINK_SET, DISPLAY_DATA, displayData,NULL_KEY);
                    stringToPrint="";
                }//status==1
               }//endif current view
            }//response!="awards|getAwards"
         
         else
           /*****************************************************************
             * Add a team to the award activity - response
             * This is the response from adding a team to the award activity                 
             *****************************************************************/           
             if (response=="awards|addAwardGrp"){
                list grps = llParseString2List(data,["|"],[]);
                integer counter=0;
                list mbrData;
                string grpName;
                if (currentView=="Select Teams"){
                            if (status==1){
                                //add successfull
                                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getAwardGrps"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index+"&maxitems=10", NULL_KEY);                                                                   
                               }//endif (status==1) add successfull
                               else 
                            if (status==-500100){
                                //add unsuccessfull
                                llInstantMessage(owner, "Sorry, tried to add the group to this award but had troubles inserting into the Moodle database");
                           }//endif (status==-500100) add unsuccessfull
                           else
                           if (status==-500200){
                                   //group doesnt exist in moodle
                                llInstantMessage(owner, "Sorry, that group doesn't exist in moodle");
                           }else
                           if (status==-500300){
                                   //group doesnt exist in moodle
                                llInstantMessage(owner, "Sorry, group has already been added!");
                                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getAwardGrps"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index+"&maxitems=10", NULL_KEY);
                           }
                        }//end currentView=="Select Teams"
                    }//response!="awards|addAwardGrp"
                    else
                   /*****************************************************************
                     * Remove a team t the award activity - response
                     * This is the response from removing a team to the award activity                 
                     *****************************************************************/           
               if (response=="awards|removeAwardGrp"){
                        list grps = llParseString2List(data,["|"],[]);
                        integer counter=0;
                        list mbrData;
                        string grpName;                                                                
                        //get status code                          
                        if (currentView=="Select Teams"){
                            if (status==1){
                                //remove  successfull
                                //refresh display`
                                
                                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getAwardGrps"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index+"&maxitems=10", NULL_KEY);                     
                            }else                              
                            if (status==-500200){
                                //group doesnt exist in moodle
                                llInstantMessage(owner, "Sorry, that group doesn't exist in moodle");
                            }else
                            if (status==-500400){
                                //group doesnt exist in moodle
                                llInstantMessage(owner, "Sorry, group doesnt exist for this award");
                                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getAwardGrps"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index+"&maxitems=10", NULL_KEY);
                            }else
                            if (status==-500500){
                                //group doesnt exist in moodle
                                llInstantMessage(owner, "Sorry, could not delete the group from the sloodle_awards_teams table");                                 
                            }else
                            if (status==-500600){
                                //group doesnt exist in moodle
                                llInstantMessage(owner, "Sorry,  group does not exist in the sloodle_awards_teams table");                                 
                            }   //status
                        }//currentView=="Select Teams"
                    }//response!="awards|removeAwardGrp"
                    else
                /*********************************
                * Get Team Scores response -
                * This is the response from requesting top scores 
                *********************************/
                if (response=="awards|getTeamScores"){
                    //clear hovertext
                    llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY::userUpdate display|STRING::                                   |COLOR::"+(string)PINK+"|ALPHA::1.0",NULL_KEY);
                    if (status==1){
                        list grpsData = llParseString2List(data, ["|"], []);
                        rows_teamScores=[];
                        //update arrows & page number
                        index_teamScores = index;
                        llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:UPDATE ARROWS|VIEW:"+currentView+"|INDEX:"+(string)index_teamScores+"|TOTALITEMS:"+(string)totalGroups,NULL_KEY);
                        stringToPrint="";
                        //set up display data for the web
                        displayData="CURRENT VIEW:"+currentView;                        
                        for (counter=0;counter<totalGroups;counter++){
                            list grpData =llParseString2List(llList2String(grpsData,counter), [","], []); //parse the message into a list
                            string grpName =s(llList2String(grpData,0));
                            integer grpPoints = i(llList2String(grpData,1));                            
                            displayData +="\n"+grpName+"|"+(string)grpPoints;
                            
                            
                            //To right align points, we must count how many characters are used by the text printed on one row, then compute how many spaces we need 
                            integer spaceLen=MAX_XY_LETTER_SPACE - (llStringLength    ((string)((counter+1)))+2+llStringLength(grpName)+llStringLength((string)grpPoints));
                            string text=(string)(index+counter+1)+") "+grpName;
                            //here we add the number of spaces by grabbing a chunk of spaces from the string of spaces below below and appending it to text
                            text+=llGetSubString("                              ", 0, spaceLen-1) + (string)grpPoints;
                            //now add the stringToPrint to the end. This will effectively placed the correct number of spaces in between the name, and the points
                            rows_teamScores+=[]+grpName;    
                            stringToPrint+=text;
                        }//for
                        //now send this text to the xy_prims
                        llMessageLinked(LINK_SET, XY_TEXT_CHANNEL,stringToPrint, NULL_KEY);
                         llMessageLinked(LINK_SET, DISPLAY_DATA, displayData,NULL_KEY);     
                        stringToPrint="";
                    }//status==1    
                    else
                    if (status==-500700){
                        stringToPrint="No teams have been added yet. Please select teams first.";
                           //now send this text to the xy_prims
                        llMessageLinked(LINK_SET, XY_TEXT_CHANNEL,stringToPrint, NULL_KEY);
                         llMessageLinked(LINK_SET, DISPLAY_DATA, displayData,NULL_KEY);     
                        stringToPrint="";
                    }                    
               }//response!="awards|getTeamScores"              
               else
               /*****************************************************************
                * Get Team members of a specific group response
                * This is the response from requesting a member list of a particular group in this award activity                 
                *****************************************************************/           
               if (response=="user|getAwardGrpMbrs"){
                    if (currentView=="Group Membership Users"){                              
                    integer totalUsers= i(llList2String(dataLines,3));
                     integer totalMembers= i(llList2String(dataLines,4));                          
                    string groupName =s(llList2String(dataLines,5));
                    index = i(llList2String(dataLines,6));                          
                    llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, groupName, "0");
                    current_grp_mbr_index= i(llList2String(dataLines,6)); 
                    counter=0;
                    integer len = llGetListLength(dataLines);
                    //change details row title
                    llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, groupName+ " members:", NULL_KEY);
                    stringToPrint="";
                    rows_getAwardGrpMbrs=[];
                    displayData="";
                    //*********************************
                    // Handle the display of the users 
                    //*********************************
                    
                    list userList = llList2List(dataLines,7,len-1);  
                    len = llGetListLength(userList);
                    displayData="CURRENTVIEW:"+currentView+"\n";
                    for (counter=0;counter<len;counter++){
                        data=llList2String(userList,counter);
                        if (data!="EOF"){
                            
                            userDetails = llParseString2List(data, ["|"], []); //parse the message into a list
                            key avuuid= k(llList2String(userDetails,0));
                            string avName=s(llList2String(userDetails,1));
                            
                             debug("--------------------------------");
                            if (llStringLength(avName)>20){
                                avName=llGetSubString(avName, 0, 20);
                            }//endif
                            integer balance = i(llList2String(userDetails,2));
                            string membershipStatus = s(llList2String(userDetails,3));                                                                           
                            integer spaceLen=MAX_XY_LETTER_SPACE - (llStringLength    ((string)((current_grp_mbr_index+counter+1)))+2+llStringLength(avName)+llStringLength((string)balance));
                            string text=(string)(current_grp_mbr_index+counter+1)+") "+avName;
                            //here we add the number of spaces by grabbing a chunk of spaces from the string of spaces below below and appending it to text
                            text+=llGetSubString("                              ", 0, spaceLen-1) + (string)balance;
                            //now add the stringToPrint to the end. This will effectively placed the correct number of spaces in between the name, and the points
                            if (membershipStatus=="yes"){                                        
                                llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)counter+"|POWER:ON|COLOR:GREEN",NULL_KEY);                                         
                            }//endif membershipStatus=="yes"
                            else {                                             
                                llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)counter+"|POWER:OFF|COLOR:GREEN",NULL_KEY);                                             
                            }//endif membershipStatus=="no"
                            //save displayed users in a list
                            rows_getAwardGrpMbrs+=[]+userDetails;
                            userDetails=[];  
                            //[uuid][avname][balance][mbr]
                            stringToPrint+=text;    
                            displayData+="AVUUID:"+(string)avuuid+"|AVNAME:"+avName+"|BALANCE:"+(string)balance+"|GROUP:"+currentGroup+"|MBR:"+membershipStatus;
                            if (counter!=len) displayData+="\n";
                        }//data==EOF        
                    }//for
                    //now send this text to the xy_prims
                    llMessageLinked(LINK_SET, XY_TEXT_CHANNEL,stringToPrint, NULL_KEY);
                     llMessageLinked(LINK_SET, DISPLAY_DATA, displayData,NULL_KEY);     
                    stringToPrint="";
                    //updated arrows and page numbers
                    llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:UPDATE ARROWS|VIEW:"+currentView+"|INDEX:"+(string)index+"|TOTALITEMS:"+(string)totalUsers, NULL_KEY);
                }//currentView==Group Members Users                                              
             }//response!="awards|getAwardGrpMbrs"
             else
          /*****************************************************************
           * Add a Group Memmber response
           * This is the response from adding a team member to a group in the award activity                 
           *****************************************************************/           
             if (response=="user|addGrpMbr"){
                 if (currentView=="Group Membership Users"){
                    if (status==1){                              
                        //now request from the sloodle api to return all members starting at index 0, 
                        llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->getAwardGrpMbrs"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&grpname="+currentGroup+"&index="+(string)currentIndex+"&sortmode=name", NULL_KEY);
                        //cmd is the command that will execute when prev/next is pressed for this view. The {index} place holder is where the current index will be inserted  
                    }//endif  (status==1)
                }//currentView=="Group Membership Users"                        
            }//  if (response=="user|addGrpMbr")
            else
          /*****************************************************************
           * Remove a Group Memmber response
           * This is the response from removing a team member from a group in the award activity                 
           *****************************************************************/           
            if (response=="user|removeGrpMbr"){
                if (currentView=="Group Membership Users"){
                    if (status==1){                        
                        //now request from the sloodle api to return all members starting at index 0, 
                        llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "user->getAwardGrpMbrs"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&grpname="+currentGroup+"&index="+(string)currentIndex+"&sortmode=name", NULL_KEY);
                    }//endif status==1
                }//currentView=="Group Membership Users"                        
            }//  if (response=="user|addGrpMbr")  
            else
            /*********************************
            * Get all groups in this course
            * This response is a list of groups in this course
            *********************************/    
            if (response=="awards|getAwardGrps"){
                list grps = llParseString2List(data,["|"],[]);
                integer counter=0;
                list mbrData;
                string grpName;
                rows_getAwardGrps=[];                     
                    if (currentView=="Group Membership"){
                      if (status==1){
                        for (counter=0;counter<totalGroups;counter++){
                            mbrData = llParseString2List(llList2String(grps,counter), [","], []);
                            grpName = s(llList2String(mbrData,0));                                                
                            //update arrows & page number
                            llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:UPDATE ARROWS|VIEW:"+currentView+"|INDEX:"+(string)index+"|TOTALITEMS:"+(string)totalGroups, NULL_KEY);
                            //is this group connected to this awards
                            connected= s(llList2String(mbrData, 2));
                            //To right align points, we must count how many characters are used by the text printed on one row, then compute how many spaces we need 
                            integer spaceLen=MAX_XY_LETTER_SPACE - (llStringLength    ((string)((counter+1)))+2+llStringLength(grpName));
                            string text=(string)(index+counter+1)+") "+grpName;
                            //here we add the number of spaces by grabbing a chunk of spaces from the string of spaces below below and appending it to text
                            text+=llGetSubString("                              ", 0, spaceLen-1);
                            //now add the stringToPrint to the end. This will effectively placed the correct number of spaces in between the name, and the points
                            if (connected=="yes"){
                                awardGroups+=grpName;
                            }else {                                             
                                courseGroups+=grpName;
                            }//endif connected
                            //save displayed group in list
                            rows_getAwardGrps+=grpName;    
                            stringToPrint+=text;    
                       }//for (counter=0;counter<totalGroups;counter++)
                     //now send this text to the xy_prims
                     llMessageLinked(LINK_SET, XY_TEXT_CHANNEL,stringToPrint, NULL_KEY);
                      llMessageLinked(LINK_SET, DISPLAY_DATA, displayData,NULL_KEY);     
                     stringToPrint="";
                     }//end if status == 1
                 }//endif currentView=="Group Membership"
                else                    
                if (currentView=="Select Teams"){
                     awardGroups=[];
                     rows_selectTeams=[];    
                    courseGroups=[];
                    index_selectTeams = index;
                    if (status==1){
                        displayData="CURRENTVIEW:"+currentView+"\n";
                        for (counter=0;counter<totalGroups;counter++){
                            mbrData = llParseString2List(llList2String(grps,counter), [","], []);
                            grpName = s(llList2String(mbrData,0));
                            //is this group connected to this awards
                            connected= s(llList2String(mbrData, 2));
                            
                            //To right align points, we must count how many characters are used by the text printed on one row, then compute how many spaces we need 
                            integer spaceLen=MAX_XY_LETTER_SPACE - (llStringLength    ((string)((counter+1)))+2+llStringLength(grpName));
                            string text=(string)(index+counter+1)+") "+grpName;
                            //here we add the number of spaces by grabbing a chunk of spaces from the string of spaces below below and appending it to text
                            text+=llGetSubString("                              ", 0, spaceLen-1);
                            //now add the stringToPrint to the end. This will effectively placed the correct number of spaces in between the name, and the points
                            if (connected=="yes"){                                        
                                llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)counter+"|POWER:ON|COLOR:GREEN",NULL_KEY);
                                awardGroups+=grpName;
                            }else {                                             
                                llMessageLinked(LINK_SET,PRIM_PROPERTIES_CHANNEL,"COMMAND:HIGHLIGHT|ROW:"+(string)counter+"|POWER:OFF|COLOR:GREEN",NULL_KEY);
                                courseGroups+=grpName;
                            }//end connected
                            //save displayed group in list
                            rows_selectTeams+=grpName;    
                            stringToPrint+=text;    
                            displayData+="GRPNAME:"+grpName+"|Connected:"+connected;
                            if (counter!=totalGroups) displayData+="\n";
                        }//for
                     //now send this text to the xy_prims
                    llMessageLinked(LINK_SET, XY_TEXT_CHANNEL,stringToPrint, NULL_KEY);
                     llMessageLinked(LINK_SET, DISPLAY_DATA, displayData,NULL_KEY);     
                    stringToPrint="";
                    //update arrows & page number
                    //update arrows & page number
                    llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:UPDATE ARROWS|VIEW:"+currentView+"|INDEX:"+(string)index+"|TOTALITEMS:"+(string)totalGroups, NULL_KEY);                                                 
                     }//status==1
                }//endif currentView=="Select Teams"
           }//response!="awards|getAwardGrps"    
          
         
        }//channel!=PLUGIN_RESPONSE_CHANNEL
    }//linked message event
     listen(integer channel, string name, key id, string str) {   
                     if (channel==SCOREBOARD_CHANNEL){
                list cmdList = llParseString2List(str, ["|"],[]);    
                string cmd = s(llList2String(cmdList,0));
                string avname= s(llList2String(cmdList,1));
                debug("got button press: "+str);
                if (cmd=="UPDATE"){
                if (llSubStringIndex(displayData, avname)!=-1){                    
                    //this means the name which was updated is currently being displayed
                    //emulate a button press
                    llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:BUTTON PRESS|BUTTON:Students Tab|AVUUID:"+(string)llGetOwner(),NULL_KEY);
                }//end displayData
                }//end command
            }
    }
}//default state

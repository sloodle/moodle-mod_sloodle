 /*********************************************
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*  btn_handler.lsl
* This script's job is to accept and process "BUTTON PRESS" commands that come in on the UI_CHANNEL when a UI button has been pressed
* Depending on the tab currently selected, this script will issue commands to process the request
*
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
* 
*
/**********************************************************************************************/
integer PAGE_SIZE=10; //amount of data rows to return
integer currentAwardId=-1;//current award id
string   currentAwardName;
string owner; //owner of the script
integer index=0;//the current row index we are viewing
// *************************************************** HOVER TEXT COLORS
vector     RED            = <0.77278, 0.04391, 0.00000>;//RED
vector     YELLOW         = <0.82192, 0.86066, 0.00000>;//YELLOW
vector     GREEN         = <0.12616, 0.77712, 0.00000>;//GREEN
vector     PINK         = <0.83635, 0.00000, 0.88019>;//INDIGO
vector     WHITE        = <1.000, 1.000, 1.000>;//WHITE
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
// *************************************************** TRANSLATION OUTPUT METHODS
string SLOODLE_TRANSLATE_HOVER_TEXT_BASIC = "hovertextbasic";
string  SLOODLE_TRANSLATE_LINK = "link";             // No output parameters - simply returns the translation on SLOODLE_TRANSLATION_RESPONSE link message channel
string  SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
string  SLOODLE_TRANSLATE_WHISPER = "whisper";       // 1 output parameter: chat channel number
string  SLOODLE_TRANSLATE_SHOUT = "shout";           // 1 output parameter: chat channel number
string  SLOODLE_TRANSLATE_REGION_SAY = "regionsay";  // 1 output parameter: chat channel number
string  SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
string  SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string  SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string  SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";  // 2 output parameters: colour <r,g,b>, and alpha value
string  SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.
integer ADMIN_CHANNEL =82;  //used for dialog messages during setup
string ownerKey;
// *************************************************** LISTS TO HOLD FIELD VALUES OF DATAROW RECORD SETS
// *************************************************** AUTHENTICATION CONSTANTS
integer MENU_CHANNEL;
string   response;   //string used for linked_message stings
integer counter;//used with for loops
string dialogMessage;//used with dialogs
string currentTab;//currently selected tab
string currentSubMenuButton="s0";//last menu button pressed
integer drawerRight=-1;
integer drawerLeft=-1;
string currentSubMenuButton_studentsTab;
string currentSubMenuButton_groupsTab;
string currentSubMenuButton_prizesTab;
string currentSubMenuButton_configTab;
string myUrl;
list facilitators;
string SLOODLE_EOF = "sloodleeof";
string authenticatedUser;
list viewData;
string currentView;
/***********************************************
*  isFacilitator()
*  |-->is this person's name in the access notecard
***********************************************/
integer isFacilitator(string avName){
    if (llListFindList(facilitators, [llStringTrim(llToLower(avName),STRING_TRIM)])==-1) return FALSE; else return TRUE;
}

/***************************************************
*  SLOODLE TRANSLATION
*  @see: http://slisweb.sjsu.edu/sl/index.php/Translating_Sloodle_objects_in_Second_Life#Sloodle_LSL_Translation_Code
****************************************************/
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
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

integer DEBUG=FALSE;
debug(string s){
 if (DEBUG==TRUE) llOwnerSay((string)llGetFreeMemory()+" "+llGetScriptName()+"*** "+ s);
   s="";
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
*  clear()
*  |-->clears the xy display
***********************************************/ 
clear(){
        string blanks="";
        for (counter=0;counter<300;counter++){
            blanks+=" ";    
        }
        llMessageLinked(LINK_SET, DISPLAY_PAGE_NUMBER_STRING, "          ", "0");
        llMessageLinked(LINK_SET, XY_TITLE_CHANNEL, "                              ", "0");
        llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, "                              ", "0");        
        llMessageLinked(LINK_SET, XY_TEXT_CHANNEL, blanks, "0");
        blanks="";
}
/***********************************************
*  random_integer()
*  |-->Produces a random integer
***********************************************/ 
integer random_integer( integer min, integer max )
{
  return min + (integer)( llFrand( max - min + 1 ) );
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
        else if (name == SLOODLE_EOF) return TRUE;
        
        return FALSE;
    }

integer getIndex(string view){
            //get the current index that this view is displaying
            integer found = llListFindList(viewData,[view]);      
            list currViewData = llList2List(viewData, found, found+4);
            index = llList2Integer(currViewData,1);
           return index;                
}
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
         owner=llGetOwner();
         //define the first link message we send to the anim scripts. s0 signifies position 0 in the animation set which was pre recorded.
         //when s0 is sent out as a linked message, all prims to be animated move to the position recorded for s0
         //and if s1 is sent, then they all move to frame 1 of the animation set etc.
         //s0 signifies that the right side drawers are is pulled out and displayed. 
         currentSubMenuButton_studentsTab="s0";
         currentSubMenuButton_groupsTab="s0";
         currentSubMenuButton_configTab="s0";
         //define commands that are executed when an NEXT PAGE or PREV PAGE button is pressed
          viewData=[];
          //format: [view name,current index, total items, command to execute, channel to send command out on]
          viewData+= ["Select Award",0,0,"awards->getAwards&index={index}&maxitems=9",PLUGIN_CHANNEL];            
          viewData+= ["Top Scores",0,0,"CMD:GET CLASS LIST|INDEX:{index}|SORTMODE:balance",UI_CHANNEL]; 
          viewData+= ["Sort by Name",0,0,"CMD:GET CLASS LIST|INDEX:{index}|SORTMODE:name",UI_CHANNEL];
          viewData+= ["Group Membership",0,0, "awards->getAwardGrps&index={index}&maxitems=9",PLUGIN_CHANNEL];
          viewData+= ["Group Membership Users",0,0, "user->getAwardGrpMbrs&index={index}&maxitems=9",PLUGIN_CHANNEL];
          viewData+= ["Team Top Scores",0,0, "awards->getTeamScores&index={index}&maxitems=9&sortmode=balance",PLUGIN_CHANNEL];
          viewData+= ["Select Teams",0,0,  "awards->getAwardGrps&index={index}&maxitems=9",PLUGIN_CHANNEL];
                   //add the owner to the facilitators list 
         facilitators+=llKey2Name(llGetOwner());
           
    }

link_message(integer sender_num, integer channel, string str, key id) {
    /*
    * general handling of a button is
    * set current button
    * set highlight button
    * set title
    * set instructional text
    * execute
    */
    if (channel==SLOODLE_CHANNEL_OBJECT_DIALOG){
        sloodle_handle_command(str);
    }//endif SLOODLE_CHANNEL_OBJECT_DIALOG
    else
    if (channel==UI_CHANNEL){
        
        list dataBits = llParseString2List(str,["|"],[]);
        string command = s(llList2String(dataBits,0));
        /*********************************
         * Capture current button and update the current view                
         *********************************/
         if (command=="SET CURRENT BUTTON"){              
                currentView= s(llList2String(dataBits,2));                 
           }//endif
        if(command=="SET CURRENT TAB"){
              currentTab=s(llList2String(dataBits,1));
          }//endif command=="SET CURRENT TAB"        
          else
              //update arrows is a command that is called each time a response handler prints data that 
                //has next or previous pages.  Update arrows maintains a list of the different views and 
                //the current index they are viewing, as well as total items in the list
                if (command=="UPDATE ARROWS"){
                    ////update arrows & page number
                    currentView = s(llList2String(dataBits,1));
                    index = i(llList2String(dataBits,2));
                    integer totalItems = i(llList2String(dataBits,3));
                    integer found = llListFindList(viewData,[currentView]);    
                     
                    if (found!=-1){
                        //take the update viewData information and insert it into our viewData list
                        viewData = llListReplaceList(viewData,[(integer)index,(integer)totalItems], found+1, found+2);
                        //llSay(0,"UPDATE ARROWS: "+currentView+" index: "+(string)index+" totalItems: "+(string)totalItems);
                        if (index+PAGE_SIZE<totalItems){
                     //hide the next arrow if we are on the last page
                              llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:DISPLAY NEXT ARROW", NULL_KEY);
                              debug("%%%%%%%%%%%%%%%%%%%%%%%% index+pagesize: "+(string)(index+PAGE_SIZE)+" totalItems = "+(string)totalItems+" displaying next arrow");
                     }else{
                         llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:HIDE NEXT ARROW", NULL_KEY);
                                                       debug("%%%%%%%%%%%%%%%%%%%%%%%% index+pagesize: "+(string)(index+PAGE_SIZE)+" totalItems = "+(string)totalItems+" hiding next arrow");
                     }
                    //*********************************
                     // Handle the display of the PREV arrow 
                     //*********************************                                  
                        if (index>=PAGE_SIZE){
                         //hide the next arrow if we are on the last page
                          llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:DISPLAY PREV ARROW", NULL_KEY);
                                                        debug("%%%%%%%%%%%%%%%%%%%%%%%% index: "+(string)(index)+" pagesize = "+(string)PAGE_SIZE+" displaying prev arrow");
                     }else{
                                                        debug("%%%%%%%%%%%%%%%%%%%%%%%% index: "+(string)(index)+" pagesize = "+(string)PAGE_SIZE+" hiding prev arrow");    
                         llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:HIDE PREV ARROW", NULL_KEY);
                     }                                    
                    }//endif found
                    else {
                        llOwnerSay("ERROR: A view handler has not been created for view: "+currentView+". Please add this in the "+llGetScriptName()+" script in the viewData list");
                    }
                }//command!="UPDATE ARROWS"
          else
          if(command=="RESET"){
              llResetScript();
          }//endif command=="RESET"        
          else
          //AWARD_SELECTED is passed on the UI_CHANNEL when a user selects an award on the xy_text display during the config stage
          if(command=="AWARD SELECTED"){
            currentAwardId=i(llList2String(dataBits,1));
            currentAwardName=s(llList2String(dataBits,2));
            myUrl = llList2String(dataBits,1);
          }//endif  AWARD SELECTED
          else          
        if (command=="BUTTON PRESS"){
      
            string button =s(llList2String(dataBits,1));
            key avuuid=k(llList2String(dataBits,2));            
            string avname = llKey2Name(avuuid);
            //                
            authenticatedUser = "&sloodleuuid="+(string)avuuid+"&sloodleavname="+llEscapeURL(llKey2Name(avuuid));
            /**************************************************
            *    Drawers
            **************************************************/
             debug("received: "+str+"avname is: "+avname+"\n"+llList2CSV(facilitators));
             
           
                
                if (button=="DrawerLeft"){
                    drawerLeft*=-1;
                    if (drawerLeft==1){
                        //highlight the current tab
                        llMessageLinked(LINK_SET, ANIM_CHANNEL, "p5", NULL_KEY);
                        //execute last button
                        // llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:BUTTON PRESS|BUTTON:"+currentButton,NULL_KEY);
                        //Got Sound from http://www.freesound.org/samplesViewSingle.php?id=12906
                        // Modified it using audacity
                        //Creative Commons Sampling Plus 1.0 License. see http://creativecommons.org/licenses/sampling+/1.0/
                        llTriggerSound("interface_open", 1.0);
                        return;
                       }//endif 
                    else {
                        llMessageLinked(LINK_SET, ANIM_CHANNEL, "p0", NULL_KEY);
                        llTriggerSound("interface_open", 1.0);
                        return;
                   }//endif handle==-1
                }//endif button=drawerLeft
                else
                if (button=="DrawerRight"){
                    drawerRight*=-1;
                    if (drawerRight==1){
                        //highlight the current tab
                        llMessageLinked(LINK_SET, ANIM_CHANNEL, "p1", NULL_KEY);
                        //execute last button
                       //Creative Commons Sampling Plus 1.0 License. see http://creativecommons.org/licenses/sampling+/1.0/
                       llTriggerSound("interface_open", 1.0);
                       return;
                   }//endif 
                   else {
                      llMessageLinked(LINK_SET, ANIM_CHANNEL, "p0", NULL_KEY);
                      llTriggerSound("interface_open", 1.0);
                      return;
                  }//endif handle==-1
              }//endif button=drawerRight   
              else
              /**************************************************
              *    Tabs - Students
              **************************************************/
              if (button=="Students Tab"){
                     clearHighlights();
                     //play sound                                          
                     //set sub menu
                     llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:SET CURRENT TAB|TAB:Students Tab",NULL_KEY);
                     //activate anim
                     llMessageLinked(LINK_SET, ANIM_CHANNEL, "p5", NULL_KEY);
                    //load button textures                                             
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s1|TEXTURE:btn_sortByName|DISPLAY:SHOW|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s2|TEXTURE:btn_resetPoints|DISPLAY:HIDE|POWER:OFF",NULL_KEY);                    
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s3|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s4|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s5|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s0|TEXTURE:btn_topScores|DISPLAY:SHOW|POWER:ON",NULL_KEY);
                    //highlight tab
                    llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:highlight tab|BUTTON:"+"Students Tab"+"|COLOR:"+(string)YELLOW,NULL_KEY);    
                     //execute last button pressed in that menu
                     llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:BUTTON PRESS|BUTTON:"+currentSubMenuButton_studentsTab+"|UUID:"+(string)avuuid,NULL_KEY);
              }//endif button==Students Tab
              else
              /**************************************************
              *    Tabs - Groups
              **************************************************/
              if (button=="Groups Tab"){
                     //clear display;
                      clear();
                    //play sound
                    llTriggerSound("interface_open", 1.0);                     
                    //set sub menu
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:SET CURRENT TAB|TAB:Groups Tab",NULL_KEY);
                    //activate anim
                    llMessageLinked(LINK_SET, ANIM_CHANNEL, "p6", NULL_KEY);
                    //Display Buttons                                                                  
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s1|TEXTURE:btn_selectTeams|DISPLAY:SHOW|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s2|TEXTURE:btn_groupMbr|DISPLAY:SHOW|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s3|TEXTURE:btn_createTeam|DISPLAY:HIDE|POWER:OFF",NULL_KEY);                
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s4|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s5|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);                    
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s0|TEXTURE:btn_topScores|DISPLAY:SHOW|POWER:ON",NULL_KEY);
                    //highlight tab
                    llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:highlight tab|BUTTON:"+"Groups Tab"+"|COLOR:"+(string)YELLOW,NULL_KEY);    
                    //execute last button pressed in that menu
                    llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:BUTTON PRESS|BUTTON:"+currentSubMenuButton_groupsTab+"|UUID:"+(string)avuuid,NULL_KEY);
               }//endif
              else 
               /**************************************************
              *    Tabs - Prizes
              **************************************************/
              if (button=="Prizes Tab"){
                     //clear display;
                      clear();
                    //play sound
                    llTriggerSound("interface_open", 1.0);                     
                    //set sub menu
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:SET CURRENT TAB|TAB:Prizes Tab",NULL_KEY);
                    //activate anim
                    llMessageLinked(LINK_SET, ANIM_CHANNEL, "p7", NULL_KEY);
                    //Display Buttons                                                                  
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s1|TEXTURE:btn_selectDistributer|DISPLAY:SHOW|POWER:ON",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s2|TEXTURE:btn_setPrizeAmounts|DISPLAY:SHOW|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s3|TEXTURE:btn_createTeam|DISPLAY:HIDE|POWER:OFF",NULL_KEY);                
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s4|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s5|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);                    
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s0|TEXTURE:btn_topScores|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    //highlight tab
                    llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:highlight tab|BUTTON:"+"Groups Tab"+"|COLOR:"+(string)YELLOW,NULL_KEY);    
                    //execute last button pressed in that menu
                    llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:BUTTON PRESS|BUTTON:"+currentSubMenuButton_prizesTab+"|UUID:"+(string)avuuid,NULL_KEY);
               }//endif
              /**************************************************
              *    Tabs - Config
              **************************************************/
            
                   if (button=="Config Tab"){
                    if (isFacilitator(avname)){                           
                      //play sound
                    llTriggerSound("interface_open",1.0);                     
                    //set current tab
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:SET CURRENT TAB|TAB:Config Tab",NULL_KEY);
                    //activate anim
                    llMessageLinked(LINK_SET, ANIM_CHANNEL, "p8", NULL_KEY);
                    //Display Buttons                                                                                      
                    if (currentAwardId!=-1)
                        llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s1|TEXTURE:btn_scavengerhunt|DISPLAY:SHOW|POWER:OFF",NULL_KEY); else
                        llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s1|TEXTURE:btn_scavengerhunt|DISPLAY:HIDE|POWER:OFF",NULL_KEY); 
                        
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s2|TEXTURE:|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s3|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s4|TEXTURE:blank|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s5|TEXTURE:btn_reset|DISPLAY:HIDE|POWER:OFF",NULL_KEY);
                    llMessageLinked(LINK_SET, UI_CHANNEL,"CMD:BTN DISPLAY|BUTTON:s0|TEXTURE:btn_selectAward|DISPLAY:SHOW|POWER:ON",NULL_KEY);                    
                    //highlight tab
                    llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:highlight tab|BUTTON:"+"Config Tab"+"|COLOR:"+(string)YELLOW,NULL_KEY);    
                    //execute last button pressed in that menu
                    llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:BUTTON PRESS|BUTTON:"+currentSubMenuButton_configTab+"|UUID:"+(string)avuuid,NULL_KEY);
                    debug(currentSubMenuButton_configTab);
                    }//isFacilitator
                    else llSay(0,"Sorry "+avname+" but you must be a facilitator listed in the config file inorder to access the Configuration Tab.");
              }//endif Config Tab
              else
              /**************************************************
              *    Buttons - Students
              **************************************************/
              if (currentTab=="Students Tab"){
                  if (button=="s0"){                           
                      llTriggerSound("beep", 1.0);
                    //clear highlights
                    clearHighlights();
                    //set current button
                    currentSubMenuButton_studentsTab = "s0";
                    currentView = "Top Scores";
                    llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s0|DESCRIPTION:"+currentView,NULL_KEY);
                     index = getIndex(currentView);
                    //highlight button
                    llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s0"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                         //Print and center a title                         
                    center("Top Scores");
                    //execute sloodle api function (sloodle_plugin_users.lsl will react to the sloodle_api http response)                                   
                    llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:GET CLASS LIST|INDEX:"+(string)(index)+"|SORTMODE:balance|AVUUID:"+(string)llGetOwner(),NULL_KEY);
                    llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, currentAwardName, NULL_KEY);
               }//endif button=="s0"
               else
               if (button=="s1"){
                    //make sure the students tab has been selected               
                   //clear highlights
                   clearHighlights();
                   //play sound
                   llTriggerSound("beep", 1.0);
                   //set current button
                   currentSubMenuButton_studentsTab = "s1";
                   currentView = "Sort by Name";
                   llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s1|DESCRIPTION:"+currentView,NULL_KEY);
                   index = getIndex(currentView);
                   //highlight button
                   llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s1"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                   //Print and center a title                         
                   center("Scoreboard");
                  //execute sloodle api function (sloodle_plugin_users.lsl will react to the sloodle_api http response)                                               
                  llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:GET CLASS LIST|INDEX:"+(string)(index)+"|SORTMODE:name|AVUUID:"+(string)llGetOwner(),NULL_KEY);
                  //set activity name
                  llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, currentAwardName, NULL_KEY);
               }//endif button == s1
             }//end currentTab=="Students Tab"
            else
            /**************************************************
            *    Buttons - Groups
            **************************************************/
            if (currentTab=="Groups Tab"){
                if (button=="s0"){
                    //play sound
                    llTriggerSound("beep", 1.0);
                  //clear highlights
                  clearHighlights();                       
                  //set current button
                  currentView ="Team Top Scores";
                  llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s0|DESCRIPTION:"+currentView,NULL_KEY);
                  index = getIndex(currentView);
                  currentSubMenuButton_groupsTab = "s0";
                  //highlight button
                  llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s0"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                  //Print and center a title                         
                  center("Team Top Scores");
                  //execute sloodle api function (sloodle_plugin_users.lsl will react to the sloodle_api http response)                                               
                  llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getTeamScores"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index+"&maxitems=9&sortmode=balance", NULL_KEY);
                  //instructional text - 
                  llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, currentAwardName, NULL_KEY);                                               
                }//endif button=="s0"
               else
                  if (button=="s1"){
                               if (isFacilitator(avname)){   
                  //play sound
                  llTriggerSound("beep", 1.0);
                  //set current button
                  currentView="Select Teams";
                  llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s1|DESCRIPTION:"+currentView,NULL_KEY);
                  index = getIndex(currentView);
                  currentSubMenuButton_groupsTab = "s1";
                  //highlight button
                  llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s1"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                  //Print and center a title                         
                  center("Select Teams");
                  //set instructional text
                  llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, "Click to select teams:", NULL_KEY);
                  //execute sloodle api function (sloodle_plugin_groups.lsl will react to the sloodle_api http response)        
                  llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getAwardGrps"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index+"&maxitems=9", NULL_KEY);
                               }
              }//endif button=="s1"    
              else
              if (button=="s2"){
                   if (isFacilitator(avname)){   
                    llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL,"Please select a group:", NULL_KEY);
                   //clear highlight
                 clearHighlights();
                 //play sound
                 llTriggerSound("beep", 1.0);
                  //set current button
                  currentView="Group Membership";
                  llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s2|DESCRIPTION:"+currentView,NULL_KEY);
                   index = getIndex(currentView);
                  currentSubMenuButton_groupsTab = "s2";
                 //highlight button
                 llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s2"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                 //Print and center a title                         
                 center("Group Membership");
                 //execute sloodle api function (sloodle_plugin_users.lsl will react to the sloodle_api http response)                                               
                 llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getAwardGrps"+authenticatedUser+"&sloodleid="+(string)currentAwardId+"&index="+(string)index+"&maxitems=9", NULL_KEY);
                   }                       
              }//endif button=="s2"
                  /*if (button=="s3"){
                  clear();
                  //play sound
                  
                  //set current button
                  llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s3|DESCRIPTION:Create Team",NULL_KEY);
                  currentSubMenuButton_groupsTab = "s3";
                  //highlight button
                  llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s3"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                  //Print and center a title                         
                  center("Create Team");
                  //set instructional text
                  llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, "Type new team on the chat line:", NULL_KEY);
                  //execute sloodle api function (sloodle_plugin_groups.lsl will react to the sloodle_api http response)                      
                  llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:GET USER INPUT", NULL_KEY);
              }//endif button=="s3"    
              else*/
           }//end currentTab=="Groups Tab"
           else
           /**************************************************
           *    Buttons - Prizes
           **************************************************/
           if (currentTab=="Prizes Tab"){
               if (button=="s0"){
                            if (isFacilitator(avname)){   
                //set instructional text
                llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, "Select a Prize Distributer:", NULL_KEY);                           
                //play sound
                llTriggerSound("beep", 1.0);
                //set current button
                currentView="Select Distributer";
                llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s0|DESCRIPTION:"+currentView,NULL_KEY);
                  index = getIndex(currentView);
                currentSubMenuButton_prizesTab = "s0";
                //highlight button
                llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s0"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                //Print and center a title                         
                center("Configuration");
                //execute sloodle api function (sloodle_plugin_users.lsl will react to the sloodle_api http response)                                               
                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "general->getSloodleObjects"+authenticatedUser+"&type=distributor&index=0&maxitems=9", NULL_KEY);
                            }                       
            }//endif button=="s0"       
           }//end currentTab=="Prize Tab"
           /**************************************************
           *    Buttons - Config
           **************************************************/
           if (currentTab=="Config Tab"){
               if (button=="s0"){
                            if (isFacilitator(avname)){   
                //set instructional text
                llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, "Select an Awards activity:", NULL_KEY);                           
                //play sound
                llTriggerSound("beep", 1.0);
                //set current button
                currentView="Select Award";
                llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s0|DESCRIPTION:"+currentView,NULL_KEY);
                  index = getIndex(currentView);
                currentSubMenuButton_configTab = "s0";
                //highlight button
                llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s0"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                //Print and center a title                         
                center("Configuration");
                //execute sloodle api function (sloodle_plugin_users.lsl will react to the sloodle_api http response)                                               
                llMessageLinked(LINK_SET, PLUGIN_CHANNEL, "awards->getAwards"+authenticatedUser+"&index="+(string)index+"&maxitems=9", NULL_KEY);
                            }                       
            }//endif button=="s0"
            else
               if (button=="s1"){//scavenger hunt
                            if (isFacilitator(avname)){   
                //set instructional text
                llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, "Rezzing a cup:", NULL_KEY);                           
                //play sound
                llTriggerSound("beep", 1.0);
                //set current button
                currentView="Rez Cup";
                llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s0|DESCRIPTION:"+currentView,NULL_KEY);
                  index = getIndex(currentView);
                currentSubMenuButton_configTab = "s1";
                //highlight button
                llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s1"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                //Print and center a title                         
                center("Scavenger Hunt!");
                string  stringToPrint = "A sloodle_config has been added to the Awards Cup.  Please add the following line to it:  set:sloodlemoduleid|"+(string)currentAwardId;
                llMessageLinked(LINK_SET, XY_TEXT_CHANNEL,stringToPrint, NULL_KEY);  
 llOwnerSay(stringToPrint);      
                llRezAtRoot("Sloodle Awards Cup",  <0,0,2>*llGetRot()+llGetPos(),<0,0,0>, llGetRot(), 1);
                            }if (isFacilitator(avname)){                          
            }//endif button=="s0"
            else
                  if (button=="s5"){
                               if (isFacilitator(avname)){   
                //set instructional text
                llMessageLinked(LINK_SET, XY_DETAILS_CHANNEL, "Resetting...", NULL_KEY);                           
                //play sound
                llTriggerSound("beep", 1.0);
                //set current button
                llMessageLinked(LINK_SET,UI_CHANNEL, "CMD:SET CURRENT BUTTON|BUTTON:s1|DESCRIPTION:Reset",NULL_KEY);
                currentSubMenuButton_configTab = "s1";
                //highlight button
                llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:highlight|BUTTON:"+"s1"+"|COLOR:"+(string)YELLOW,NULL_KEY);                                                                 
                //Print and center a title                         
                center("Resetting");
                //release url
                llReleaseURL(myUrl);
                //reset
                llMessageLinked(LINK_SET,UI_CHANNEL, "COMMAND:RESET",NULL_KEY);
                               }
            }//endif button=="s5"
           }//end currentTab=="Config Tab"
        
        if (button=="NEXT PAGE"||button=="PREV PAGE"){
               //search the viewData list to find the information about what to do on this view
                integer found = llListFindList(viewData,[currentView]);                
                list currViewData = llList2List(viewData, found, found+4);
                 index = getIndex(currentView);
                //get the totalItems that this view has to display on its pages
                integer totalItems = llList2Integer(currViewData,2);
                //get the command that needs to be executed to update the display
                string cmd=llList2String(currViewData,3);
                //add our authenticatedUser string to the cmd 
                cmd+=authenticatedUser;
                //get the channel we need to send the command out on
                integer chan = llList2Integer(currViewData,4);               
                //in the command, there is a marker for the index, find it and replace it with the index for this request              
                integer marker = llSubStringIndex(cmd,"{index}");
                if (button=="NEXT PAGE"){ 
                     if( index+PAGE_SIZE<totalItems) 
                         index+=PAGE_SIZE;
                }//endif
                else                        
                if (button=="PREV PAGE"){
                     index=index - PAGE_SIZE;
                }
                if (index<0) index=0;
                viewData = llListReplaceList(viewData,[index,totalItems], found+1, found+2);
                string newCmd = llGetSubString(cmd,0, marker-1)+(string)index+llGetSubString(cmd,marker+7,llStringLength(cmd));
                    //send out command
                    llMessageLinked(LINK_SET,chan,newCmd,NULL_KEY);
                 //*********************************
                 // Now we must HIDE or SHOW the  next and previous arrow depending on the index for the current view
                 //*********************************                 
                if (index+PAGE_SIZE<totalItems){
                     //hide the next arrow if we are on the last page
                      llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:DISPLAY NEXT ARROW", NULL_KEY);
                 }else{
                     llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:HIDE NEXT ARROW", NULL_KEY);
                 }
                //*********************************
                 // Handle the display of the PREV arrow 
                 //*********************************                                  
                    if (index>=PAGE_SIZE){
                     //hide the next arrow if we are on the last page
                      llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:DISPLAY PREV ARROW", NULL_KEY);
                 }else{

                     llMessageLinked(LINK_SET, UI_CHANNEL, "COMMAND:HIDE PREV ARROW", NULL_KEY);
                 }
                 //*********************************
                 // Handle the display of the Page number 
                 //*********************************                  
                  llMessageLinked(LINK_SET, DISPLAY_PAGE_NUMBER_STRING, "PAGE "+(string)(llCeil((float)index/(float)PAGE_SIZE)+1), NULL_KEY);
        }//if button == next / prev page
      }//end if command==BUTTON_PRESS
  }//end if channel==UI_CHANNEL
}//end linked_message event
}
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
    object_rez(key id) {
        llGiveInventory(id, "sloodle_config");
    }
}

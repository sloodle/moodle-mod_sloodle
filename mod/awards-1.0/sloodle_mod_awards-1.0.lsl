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
*sloodle_mod_award.lsl 
*
* PURPOSE
*  This script is part of the SLOODLE Award System.
*  The  SLOODLE Award System is a motivational scoreboard system which is intended for educator in Second Life using the SLOODLE module plugin for the 
*  their MOODLE Learning Management system.
*
*  
* This script connects with linker.php of sloodle to update scoreboard information and points in the sloodle_award_trans database
*
* USE CASE
*  ~~~~~~~~~~~~~
*  A owner clicks on the scoreboard, and gets a menu - "Update View"  "Setup"
*  
*  ~~~~~ Owner selects (Update view)  ~~~~~~
*  If the user chooses Update View- the scoreboard retrieves 10 users from current page of users from the moodle course and prints it on the xytext
*
*
*  ~~~~~ Owner clicks on a name on the scoreboard ~~~~~~
*  If the owner clicks on a name printed on the scoreboard, the scoreboard prims name will be sent via a linked message on the AWARDGATEWAY_CHANNEL
*  The link_message event will be raised, and the number that was sent will be retrieved
*  Since each scoreboard prim is named numerically from 0-9 based on it's row, we will use this number to determine 
*  which "slot" or user the owner wants to modify.  
*  A menu with the following options: [-1000,-500,-100,-10,0,10,100,500,1000 or ~~ Save ~~] is then displayed
*  The selected option will be chatted on a unique channel which is the USER_CHANNEL constant + the slot number
*  When an option is selected, the listen event will fire.
*  We then analyse the channel the message was sent on, to determine which user to apply the point modification to.
*  We then store the modify value into a list called modifyPoints, which has a space for each user.
*  We then display the modify menu agin, and repeat the process until the user presses "save"
*
*  When the user selects "save", the saveAmountModification(slotNum) function is called. The value of the userPoints
*  in the slots list is added to the value in the modifyPoints list, and an http request is sent to linker.php
*  The mysql database is then updated.  An "UPDATE COMPLETE" http response is then sent from the linker.php and received
*  by the GUI script.  The GUI script passes this message to a handleResponse function.
*  the handleResponse function then then prints the update on the xytext
*
/**********************************************************************************************/
string  SLOODLE_AWARD_LINKER = "/mod/sloodle/mod/awards-1.0/linker.php";
key http; 
string sortMode="name"; //the default sort mode - retrieves users in alphabetical order - can be changed via the Setup Menu by the owner // can also be set to "balance" - to sort by points
integer PLAYERNAME=0; //constant which defines a list postion our specific data is in to make code more readable
integer PLAYERPOINTS=1; //constant which defines a list postion our specific data is in to make code more readable
integer SLOTCHANNEL=2; //constant which defines a list postion our specific data is in to make code more readable
integer AVUUID=3; //constant which defines a list postion our specific data is in to make code more readable
key myChannel; //xml channel of xmlrpc 
integer assignmentId;
string stringToPrint;
string assignmentName;
integer numbits;
string text;
string fullCourseName; 
string sloodleModName;
string sloodleModIntro;
string tempStringA;
string currency;
string saveDetails;
string awardIdText;
integer SETTEXT_CHANNEL=-776644;
integer slotNum;
integer ADDON_CHANNEL=-8877221;
string sloodlecoursename;
string owner;
string sloodledata;
string body;
integer intNumStrides;
integer intOffset;
integer intListIndex;
integer intStrideIndex;
integer intSubIndex;
list lstRetVal;
integer intOffSet;
string blanks;
integer userChannel;
integer MAX_XY_LETTER_SPACE=30;
integer spaceLen;
// *************************************************** HOVER TEXT COLORS
vector     RED            = <0.77278, 0.04391, 0.00000>;//RED
vector     YELLOW         = <0.82192, 0.86066, 0.00000>;//YELLOW
vector     GREEN         = <0.12616, 0.77712, 0.00000>;//GREEN
vector     PINK         = <0.83635, 0.00000, 0.88019>;//INDIGO
// *************************************************** HOVER TEXT VARIABLES
string  sloodleserverroot = "";
string  sloodlepwd = "";
integer sloodlecontrollerid = 0;
integer sloodlemoduleid = 0;
integer sloodleobjectaccessleveluse = 0; // Who can use this object?
integer sloodleobjectaccesslevelctrl = 0; // Who can control this object?
integer sloodleserveraccesslevel = 0; // Who can use the server resource? (Value passed straight back to Moodle)
integer DISPLAY_PAGE_NUMBER_STRING      = 304000;
integer DISPLAY_TITLE_STRING          = 404000;

integer PAGE_SIZE=10; //can display only 10 users at once.
integer SLOT_LIST_STRIDE_LENGTH=4; //The number of fields in the slot list. 
integer SLOT_LIST_CHANNEL_STRIDE_INDEX;
// *************************************************** TRANSLATION VARIABLES
// This is common translation code.
// Link message channels
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_TRANSLATION_RESPONSE = -1928374652;

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
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
integer SET_COLOR_INDIVIDUAL= 8888999;
integer SLOODLE_CHANNEL_AVATAR_DIALOG = 1001;
string  SLOODLE_EOF = "sloodleeof";
integer SLOODLE_OBJECT_ACCESS_LEVEL_PUBLIC = 0;
integer SLOODLE_OBJECT_ACCESS_LEVEL_OWNER = 1;
integer SLOODLE_OBJECT_ACCESS_LEVEL_GROUP = 2;
integer eof= FALSE;
integer awardId;
integer totalPages;
integer page=1;
integer DATA0=1; //constant which defines a list postion our specific data is in to make code more readable
integer DATA1=2; //constant which defines a list postion our specific data is in to make code more readable
integer DATA2=3; //constant which defines a list postion our specific data is in to make code more readable
integer DATA3=4; //constant which defines a list postion our specific data is in to make code more readable
integer strideLen;
integer USER_CHANNEL=99000;
integer AWARD_GATEWAY_CHANNEL=89997;
integer XY_TEXT_CHANNEL    = 100100;
integer ALL_MEMORY=9000; //linked message channel all memory listens too
integer COMMAND=0; //a constant used to indicate the COMMAND field in the list
string     response;   //string used for linked_message stings
key     gSetupQueryId; //used for reading settings notecards
string     gSetupNotecardName="settings";//used for reading settings notecards
integer gSetupNotecardLine;//used for reading settings notecards
integer MENU_CHANNEL;
integer i;//used with for loops
string dialogMessage;//used with dialogs
key listenHandler0; //a handler returned when creating a listener.  Can be used to dispose listenter later
integer MEMORY_CONTROLLER=-20; //MEMORY CONTROLLER USES 20 FOR link_num for linked messages
integer AWARD_DATA_CHANNEL=890;
integer slotChan;
list updateData;
key sourceId;
string avuuid;
string avName;
integer newAmount;
string updatedUser;
string dialogText;
integer ii;
integer modPoints;
string  userName;
integer userPoints;
string userAvuuid;
integer numLines;
integer counter1;
integer isconfigured;
key av;
string command;
integer user_channel;
integer numStudents;
list statusLine;
integer status;
string name;
key senderUuid;
string value1;
string value2;
integer index;
list dataBits;
list user;
list slots;//used to identify users on xytext
list responseList; //used for linked_message strings
list gInventoryList;//used for reading settings notecards
list details;
list avNames;
list buttons;
list commandList;
list pointMods; //this is a list of values an owner can modify a users points to //["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000",
list modifyPointList; //this is a temp list that is used to store point modifications in.  When Save is pressed on a menu, these points are applied to the users point bank
// *************************************************** SLOODLE TRANSLATION
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch)
{
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}

/****************************************************************************************************
* sendCommand(string command, string data,api)
*  This command wraps the award command and data into something the linker.php can read
*
*  The linker.php is expecting something that looks like this:
* 
*       sloodleauthid=365
*       sloodleobjtype=award-1.0
*       sloodlecontrollerid=31
*       sloodleuuid=b8cec8fe-2cd5-47f3-bcf7-5d8c233341a8 // this is the avatar UUID must be in the sloodle user database and a user of the site
*       sloodleavname=SLOODLE Alchemi //must also send the avatar name
*      sloodlepwd=d2ce06b2-9998-241e-9b53-ad02904c287e|726413072  //this is the password specific to this authorized object
*      sloodlemoduleid=114  //module id of this award
*      sloodleserveraccesslevel=0 //parameter set during config stage of the award        
*      command=makeTransaction  //we can send different commands to our php
*      data=2|Fire Centaur|4000  //this data is specific to our award makeTransaction function in linker.php
*
*
*      There are other commands we can send to our linker via the command and data parameters:
*  
****************************************************************************************************/
sendCommand(string command,string data){
        
        if (llGetFreeMemory()<1500) {
            llOwnerSay("Running low on memory, reseting Sloodle Awards System...");
            llResetScript(); //guard against memory leaks
        }
        llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY::top display|STRING::Sloodle Award System: "+sloodleModName+"\nCourse: "+sloodlecoursename+"\nAssignment Link: "+assignmentName+" \nContacting Server, please wait|COLOR::"+(string)PINK+"|ALPHA::1.0",NULL_KEY);
//llOwnerSay("HttpScript:  sending this to linker.php\n"+sloodleserverroot + SLOODLE_AWARD_LINKER+"?"+sloodledata + "&command="+command+awardIdText+"&data="+data);
    llSetTimerEvent(10);
     http = llHTTPRequest(sloodleserverroot + SLOODLE_AWARD_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], sloodledata + "&command="+command+awardIdText+"&data="+data);
       
}

debugMessage(string s){
 llOwnerSay((string)llGetFreeMemory()+"********************** "+s);
   s="";
}
/****************************************************************************************************
* handles sloodle configuration
****************************************************************************************************/
integer sloodle_handle_command(string str)
{
//llSay(0,str);
    dataBits = llParseString2List(str,["|"],[]);
    numbits = llGetListLength(dataBits);

    name = llList2String(dataBits,0);
    value1 = "";
    value2 = "";
    if (numbits > 1) value1 = llList2String(dataBits,1);
    if (numbits > 2) value2 = llList2String(dataBits,2);
    if (name == "set:sloodleserverroot") sloodleserverroot = value1;
    else if (name == "set:sloodlepwd") {       
        // The password may be a single prim password, or a UUID and a password
        if (value2 != "") sloodlepwd = value1 + "|" + value2;
        else sloodlepwd = value1;
    } else if (name == "set:sloodlecontrollerid") sloodlecontrollerid = (integer)value1;
    else if (name == "set:sloodlemoduleid") {
        sloodlemoduleid = (integer)value1;
        awardId=sloodlemoduleid;
    }else if (name=="set:sloodlecoursename_full"){
        sloodlecoursename = (string)value1;        
    }
    else if (name == "set:sloodleobjectaccessleveluse") sloodleobjectaccessleveluse = (integer)value1;
    else if (name == "set:sloodleobjectaccesslevelctrl") sloodleobjectaccesslevelctrl = (integer)value1;
    else if (name == "set:sloodleserveraccesslevel") sloodleserveraccesslevel = (integer)value1;
    
    // TODO: Add additional configuration parameters here
    else if (name == SLOODLE_EOF) eof = TRUE;
    // This line figures out if we have all the core data we need.
    // TODO: If you absolutely need any other core data in the configuration, then add it to this condition.
    dataBits = [];
    str="";
    name="";
    return (sloodleserverroot != "" && sloodlepwd != "" && sloodlecontrollerid > 0 && sloodlemoduleid > 0);
}
/***********************************************
*  displayModMenu(string userName,integer userPoints, integer user_channel)
*  Is used to display a dialog menu so owner can modify the points awarded 
***********************************************/
displayModMenu(string userName,integer userPoints, integer user_channel){                     
                     modPoints = userPoints + llList2Integer(modifyPointList,user_channel-USER_CHANNEL);                                      
                     llDialog(owner," -~~~ Modify iPoints awarded: "+(string)userPoints+" ~~~-\n"+userName+"\nModify Points to: "+(string) modPoints, ["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000"] + ["~~ SAVE ~~"], user_channel);
                 }


/***********************************************
*  random_integer()
*  |-->Produces a random integer
***********************************************/ 
integer random_integer( integer min, integer max )
{
  return min + (integer)( llFrand( max - min + 1 ) );
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
        owner=llGetOwner();
       slots = [" "," "," "," "," "," "," "," "," "," "];
       blanks="";
        for (i=0;i<300;i++){
            blanks+=" ";    
        }
        llMessageLinked(LINK_SET, XY_TEXT_CHANNEL, blanks, "0");
        blanks="";
        modifyPointList=[];
        modifyPointList=[0,0,0,0,0,0,0,0,0,0];
      // readInventory();
        MENU_CHANNEL=random_integer(10000,30000);//used for dialog menus
        pointMods = ["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000"];
        llMessageLinked(LINK_SET, DISPLAY_PAGE_NUMBER_STRING, "          ", "0");     
        llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:requestconfig", "0"); 
    }
    /***********************************************
    *  linked message event
    *  SOURCES:
    *  |--> Messages come from:
    * 
    *  MESSAGES:
    *  |-->           
    ***********************************************/
    link_message(integer sender_num, integer link_channel, string str, key id) {
      //  llSay(0,str);
        responseList=llParseString2List(str, ["|"],[""]);
        response=llList2String(responseList,COMMAND);
        if (link_channel==ALL_MEMORY){            
            //when all config has been received from our web_setup or notecard scripts, retreive the number of users stored
            if (str=="LOADING DONE"){
                responseList=[];
                response="";
                state registerXmlChannel;  
            }
        }
         if (link_channel == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            dataBits=[];
            dataBits = llParseString2List(str, ["\n"], []);                       
            isconfigured=FALSE;
            numLines =  llGetListLength(dataBits);
            for (i=0; i<numLines; i++) {
                isconfigured = sloodle_handle_command(llList2String(dataBits,i));
            }
            dataBits = [];          
            // If we've got all our data AND reached the end of the configuration data, then move on
            if (eof == TRUE) {
                if (isconfigured == TRUE) {
                    sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], NULL_KEY, "");                    
                     llMessageLinked(LINK_THIS,ALL_MEMORY, "LOADING DONE","");
                       state registerXmlChannel;
                } else {
                    // Go all configuration but, it's not complete... request reconfiguration
                    //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configdatamissing", [], NULL_KEY, "");
                    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_OBJECT_DIALOG, "do:reconfigure", NULL_KEY);                    
                    eof = FALSE;
                }
           
        }
        dataBits=[];
        responseList=[];
        response="";
    }
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
}
state registerXmlChannel{
      /***********************************************
    *  on_rez event
    *  |--> Reset Script to ensure proper defaults on rez
    ***********************************************/
    on_rez(integer start_param) {
        llResetScript();
       
    }
    state_entry() {
        sloodledata="sloodlecontrollerid=" + (string)sloodlecontrollerid;
        sloodledata += "&sloodlepwd=" + (string)sloodlepwd;
        sloodledata += "&sloodlemoduleid=" + (string)sloodlemoduleid;
        sloodledata += "&sloodleserveraccesslevel=" + (string)sloodleserveraccesslevel;       
        sloodledata += "&sloodleavname=" + llEscapeURL(llKey2Name(owner));
        sloodledata += "&sloodleuuid=" + (string)owner;         
        
        llOwnerSay("Opening XML Channel... please wait...");
        llOpenRemoteDataChannel();
        
    }
      remote_data(integer type, key channel, key uid, string from, integer integerValue, string stringValue) {
        if (type == REMOTE_DATA_CHANNEL) {
            myChannel = channel;
                llOwnerSay("Channel Open..."+(string)myChannel);    
                sendCommand("REGISTER",myChannel);      
        }
    }
    timer() {
        llSetTimerEvent(0.0);
        sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[] , "awards:timeout", ["ok"], owner, "awards");        
         sloodle_translation_request(SLOODLE_TRANSLATE_HOVER_TEXT_BASIC, [RED, 1.0], "awards:timeout", [], NULL_KEY, "awards");            
    }

         http_response(key id,integer status,list meta,string body) {
      
        if ((id != http)) return;
        (http = NULL_KEY);
       
        if ((status != 200)) {
            return;
        }
         llSetTimerEvent(0.0);
           //retrieve lines from the http body   
    dataBits = llParseStringKeepNulls(body,["\n"],[]);
    body="";//VERY IMPORTANT - LAGE UNEMPTIED STRINGS ARE SOURCES OF MEMORY LEAKS!!!
  //   llSay(0,"**************************** Free Memory: "+(string)llGetFreeMemory());   
    //get status code
    statusLine =llParseString2List(llList2String(dataBits,0),["|"],[]);
    status =llList2Integer(statusLine,0); 
    numStudents = llList2Integer(llParseString2List((llList2String(dataBits,3)), [":"],[]),1);
    fullCourseName = llList2String(llParseString2List((llList2String(dataBits,4)), [":"],[]),1);
    sloodleModName =llList2String(llParseString2List((llList2String(dataBits,5)), [":"],[]),1);
    sloodleModIntro =llList2String(llParseString2List((llList2String(dataBits,6)), [":"],[]),1);
    currency=llList2String(llParseString2List((llList2String(dataBits,7)), [":"],[]),1);
    awardId=llList2Integer(llParseString2List((llList2String(dataBits,8)), [":"],[]),1);
    assignmentId=llList2Integer(llParseString2List((llList2String(dataBits,9)), [":"],[]),1);
    assignmentName =llList2String(llParseString2List((llList2String(dataBits,10)), [":"],[]),1);
    statusLine=[];
    llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY::top display|STRING::Sloodle Award System: "+sloodleModName+"\nCourse: "+sloodlecoursename+"\nAssignment Link: "+assignmentName+" \nDisplay Updated Complete|COLOR::"+(string)GREEN+"|ALPHA::1.0",NULL_KEY);
    //count number of lines
    numLines = llGetListLength(dataBits);    
    senderUuid = llList2Key(dataBits,1);
    //what command was sent back?
    command = llList2String(llParseString2List((llList2String(dataBits,2)), [":"],[]),1);
    dataBits=[];
     if (command == "REGISTER RESPONSE") {  //this is a result of the award storing our xml channel we sent
         if (status==1){
             state ready;         
         }
     }
    }
}
state ready{
      /***********************************************
    *  on_rez event
    *  |--> Reset Script to ensure proper defaults on rez
    ***********************************************/
    on_rez(integer start_param) {
        llResetScript();
       
    }
    state_entry() {
      
         awardIdText="&awardId=" +(string)awardId;  
        for (i=0;i<10;i++){
            llListen(USER_CHANNEL+i, "", "", "");
  
        }      
        llDialog(owner,"Please select an option.",["Update View", "Setup"],MENU_CHANNEL);
        llListen(MENU_CHANNEL, "","","");
        for (i=0;i<10;i++){
            llListen(USER_CHANNEL+i,llGetObjectName(), llGetKey(), "");
        }
      llListen(ADDON_CHANNEL, "", "", "");
      saveDetails= "DETAILS:owner%20modify%20ipoints,OWNER:"+llEscapeURL(llKey2Name(owner))+",SCOREBOARD:"+(string)llGetKey()+",SCOREBOARDNAME:"+llGetObjectName();     
      llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY::top display|STRING::Sloodle Award System: "+sloodleModName+"\nCourse: "+sloodlecoursename+"\nAssignment Link: "+assignmentName+" \nContacting Server, please wait|COLOR::"+(string)PINK+"|ALPHA::1.0",NULL_KEY);            
      http = llHTTPRequest(sloodleserverroot + SLOODLE_AWARD_LINKER, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], sloodledata + "&command=getClassList"+awardIdText+"&data=index:0|SORT:"+sortMode);      
    }
    remote_data(integer type, key channel, key uid, string from, integer integerValue, string stringValue) {
        if (type == REMOTE_DATA_REQUEST) {
        //    llSay(0,"*********************************"+stringValue);
          if (stringValue=="UPDATE"){                  
                  sendCommand("getClassList","index:"+(string)((page-1)*PAGE_SIZE)+"|SORT:"+sortMode);
          }
        } 
    }
    touch_start(integer num_detected) {
        if (llDetectedKey(0)==owner)
            llDialog(llDetectedKey(0),"Please selectin  a view",["Update View", "Setup"],MENU_CHANNEL);
        else llInstantMessage(llDetectedKey(0), "Sorry, only the owner can control this Award");        
    }
    listen(integer channel, string name, key id, string message) {
          
           if ((channel >=USER_CHANNEL) && (channel <= USER_CHANNEL+10)){  
                            
            //Here, we will accept messages sent from a menu dialog box when the owner is updating the points of its users
            //messages sent on these channels can be "-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000","~~ SAVE ~~"
            //when these messages come in, we need to determine which user to apply the point updates to.
            //Since our Slots list has the following data in it:  
            // 0: [avname,points,channel]
            // 1: [avname,points,channel]
            // 2: [avname,points,channel]
            // ..
            // ..
            //9: [avname,points,channel]
            // since there are only 10 slots, and the USER Channels start at the USER_CHANNEL constant
            // we simply need to subtract USER_CHANNEL from the channel the message was sent on to determine our index
            slotNum = channel - USER_CHANNEL;
            //now using this slotNum, we can reach into our slots list, and retrieve user specific data
               user = llList2List(slots, slotNum* 4, slotNum* 4 + 3); 
               
              //key userAvuuid= llList2Key(user,AVUUID);
            //Now determine if a number was pressed, or the (~~ SAVE ~~) Button was pressed
            if (llListFindList(["-5","-10","-100","-500","-1000","+5","+10","+100","+500","+1000"],[message])!=-1){                            
                //now just modify the value.            
                //modify points
                newAmount = llList2Integer(modifyPointList,slotNum)+(integer)message;
                modifyPointList= llListReplaceList(modifyPointList,[newAmount], slotNum, slotNum);
                displayModMenu(llList2String(user, PLAYERNAME),llList2Integer(user, PLAYERPOINTS),llList2Integer(user,SLOTCHANNEL));//display mod menu again
                user=[];
            } else if (message=="~~ SAVE ~~"){
                //now send a request to the linker.php script.  If successfull, we will update the display, slot list, and modifyPoints list
               
               
                /****************************************************************************************************
                * Now examine which user is currently printed on the xy text in the slot number sent
                *  It will then look in the modifiedAmount list, and send this amount as a transaction to our linker.php
                * which will then save it to our moodle db.  it will then clear the modifiedStipendAmount to zero
                * and re-download all userLists using buildUserLists
                ****************************************************************************************************/
                user = llList2List(slots, slotNum* 4, slotNum* 4 + 3); 
                //         slots=[playerName,playerPoints,userChannel,avuuid;
                //send command will send an http request to the server. Response will be upDateStipend
                //send details about this transaction    
                //*  |-->SOURCE_UUID: |AVUUID:|AVNAME:|POINTS:|DETAILS:Attendance,SOURCE_UUID:,SIGNIN_NAME:,SIGNIN_KEY:,"SIGNIN_POINTS:,SIGNIN_TIME:"+(string)llGetUnixTime();    
                value1  = "SOURCE_UUID:"+(string)llGetKey();
                value1 += "|AVUUID:"+llList2String(user,AVUUID);
                value1 += "|AVNAME:"+llEscapeURL(llList2String(user, PLAYERNAME));
                value1 += "|POINTS:"+llList2String(modifyPointList,slotNum);;
                value1 += "|"+saveDetails;
                modifyPointList = llListReplaceList(modifyPointList, [0], slotNum,slotNum);    
                 sendCommand("makeTransaction", value1);

                tempStringA="";
                value1="";
                user=[];
        }
    }else
         if (channel==ADDON_CHANNEL){
       /*      if (llStringLength(message)>11) message = llGetSubString(message,0,11);
          //   llSay(0,"got addon message");             
             integer found = llListFindList(addons, [message]);
             if (found!=-1){
                 llRezObject(llList2String(addons,found), llGetPos()+<1,0,1>, llGetVel(), llGetRot(), 1);
             }
             */
             
             if (message=="Stipend")  llRezObject("Sloodle Award Stipend Giver Addon", llGetPos()+<1,1,-2>, llGetVel(),ZERO_ROTATION , 1); else
             if (message=="Attendance")  llRezObject("Sloodle Award Attendance Checker Addon", llGetPos()+<1,1,-2>, llGetVel(), ZERO_ROTATION, 1); 
         } else     
        if (channel==MENU_CHANNEL){
        //      debugMessage("in menu channels");   
            //if user wants to view all users
            if (message=="Update View"){
                   sendCommand("getClassList","index:"+(string)((page-1)*PAGE_SIZE)+"|SORT:"+sortMode);  
            }              
            else if (message=="Setup"){
                llDialog(owner, "Please select an option:\nSort Mode=How you want to sort the list\nMy Key= My UUID for inworld tools\nHelp = General Help", ["Sort Mode","Rez Addon","Assignment","Web Link"], MENU_CHANNEL);
            }           
            else if (message=="Assignment"){
                llLoadURL(id, "View Assignment Grades",sloodleserverroot+"/mod/assignment/submissions.php?id="+(string)assignmentId);
            }
            else if (message=="Web Link"){
                llLoadURL(id, "View Sloodle Award System in Moodle?",sloodleserverroot+"/mod/sloodle/view.php?id="+(string)sloodlemoduleid);
            }
            else if (message=="Sort Mode"){
                  llDialog(owner, "How would you like to sort the list?\n", ["By Balance","By Name"], MENU_CHANNEL);
            }
            else if (message=="Rez Addon"){
              
                   llDialog(owner, "Select an Addon",["Stipend"], ADDON_CHANNEL);
            }
            else if ((message=="By Balance")||(message=="By Name")){
                if (message=="By Balance") sortMode="balance"; else sortMode="name";
                  sendCommand("getClassList","index:"+(string)((page-1)*PAGE_SIZE)+"|SORT:"+sortMode);         
         
        }
}
}
    link_message(integer sender_num, integer link_channel, string str, key id) {
        //The IBANKGATEWAY_CHANNEL is used to receive messages from the xy_text prims.  Each xy_prim is part of a row on the scoreboard
        //Each row on the scoreboard consists of three xy_prims. Each xy_prim can hold ten letters.
        //Thus, on the scoreboard, one row will contain the players name, and their points.
        //The owner of this award can click on any row, and modify the points for that user
        if (link_channel==AWARD_GATEWAY_CHANNEL){
             dataBits = llParseString2List(str,["|"],[]);
             command = llList2String(llParseString2List((llList2String(dataBits,0)), [":"],[]),1);
             //the slotNum is the row that was clicked on             
             if (command=="DISPLAY MENU"){
                 slotNum = llList2Integer(llParseString2List((llList2String(dataBits,1)), [":"],[]),1);
                 av= llList2Key(llParseString2List((llList2String(dataBits,2)), [":"],[]),1);
             if (av==owner){
                 user = llList2List(slots, slotNum* 4, slotNum* 4 + 3);                 
                 //the user list above has 3 elements:  avName,avPoints,Channel 
                 //Each row will communicate on a separate link message channel.  We will do this to identify which user
                 //a menu dialog update corresponds to.  We have to use this approach because the menu buttons used to update
                 //a users ipoint balance are numeric - ie: 100,500,1000 etc.
                 //therefore when our listen event receives a message with the value "500" we have to somehow tie that information
                 //to a particular user.  We can do this by querying the channel, and then checking our userList to see which slot
                 //the channel has been saved on, and then, in turn, discover which user the update pertains to.                   
                 displayModMenu(llList2String(user,PLAYERNAME),llList2Integer(user,PLAYERPOINTS),llList2Integer(user,SLOTCHANNEL));
                 user=[];
                 dataBits=[];  
                 command="";          
                     
                 return;
        }                
             }else if (command=="NEXT PAGE"){
                 page++;
                 if (page>=(totalPages)){
                     //hide the next arrow if we are on the last page
                      llMessageLinked(LINK_SET, AWARD_GATEWAY_CHANNEL, "COMMAND:HIDE NEXT ARROW", NULL_KEY);
                 }
                 if (page>1 ){
                     //display previous page button if more than one page and we are on page 2 (page 1 or higher)
                     llMessageLinked(LINK_SET, AWARD_GATEWAY_CHANNEL, "COMMAND:DISPLAY PREV ARROW", NULL_KEY);
                 }
                  modifyPointList=[];
                  modifyPointList=[0,0,0,0,0,0,0,0,0,0];
                    sendCommand("getClassList","index:"+(string)((page-1)*10)+"|SORT:"+sortMode); 

                 return;
             }else if (command=="PREV PAGE"){    
        
                 --page;                 
                 if (page==1){
                     //hide the prev arrow if we are on the 1st page
                     llMessageLinked(LINK_SET, AWARD_GATEWAY_CHANNEL, "COMMAND:HIDE PREV ARROW", NULL_KEY);           
                 }
                 if (page<totalPages){
                     //display next page button if there are more pages to be displayed
                     llMessageLinked(LINK_SET, AWARD_GATEWAY_CHANNEL, "COMMAND:DISPLAY NEXT ARROW", NULL_KEY);
                 }
                      sendCommand("getClassList","index:"+(string)((page-1)*10)+"|SORT:"+sortMode); 
                
                 modifyPointList=[];
                 modifyPointList=[0,0,0,0,0,0,0,0,0,0];     
                 return;
             } 
            }
       
            
    
    }
    http_response(key id,integer status,list meta,string body) {
        
        if ((id != http)) return;
        if ((status != 200)) {
            return;
        }
       llSetTimerEvent(0.0);
        http="";
    dataBits = llParseStringKeepNulls(body,["\n"],[]);
    body="";//VERY IMPORTANT - LAGE UNEMPTIED STRINGS ARE SOURCES OF MEMORY LEAKS!!!
    // llSay(0,"****************************** Free Memory: "+(string)llGetFreeMemory());
    //get status code
    statusLine =llParseString2List(llList2String(dataBits,0),["|"],[]);
    status =llList2Integer(statusLine,0); 
     //count number of dataBits 
    numLines = llGetListLength(dataBits);
  /*  for (i=0;i<numLindataBits+){
        llSay(0,(string)i+" "+llList2String(dataBits,i));
    }    
    
    */
    senderUuid = llList2Key(dataBits,1);
    //what command was sent back?
    command = llList2String(llParseString2List((llList2String(dataBits,2)), [":"],[]),1);
     ii=0;   
     if (command == "getClassListResponse") {     
         llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY::top display|STRING::Sloodle Award System: "+sloodleModName+"\nCourse: "+sloodlecoursename+"\nAssignment Link: "+assignmentName+" \nReady|COLOR::"+(string)GREEN+"|ALPHA::1.0",NULL_KEY);                 
         user=[];
         for (ii=11; ii<numLines;ii++){        
                 user+=llParseString2List(llList2String(dataBits,ii),["|"],[]);             
         }
         totalPages=numStudents/PAGE_SIZE+1;
         if ((page==1)&&(totalPages>1)){
                    llMessageLinked(LINK_SET,AWARD_GATEWAY_CHANNEL,"COMMAND:DISPLAY NEXT ARROW", NULL_KEY);                     
                }
          if (page ==1) llMessageLinked(LINK_SET,AWARD_GATEWAY_CHANNEL,"COMMAND:HIDE PREV ARROW", NULL_KEY);
        //display page number 
          llMessageLinked(LINK_SET, DISPLAY_PAGE_NUMBER_STRING, "PAGE "+(string)page, NULL_KEY);
          //****************          
             userChannel=USER_CHANNEL;    
            numLines=llGetListLength(user);
             stringToPrint="";
             numLines = numLines/4;
            for (i=0;i<numLines;i++){
                //extrapolate user data
                 details = llList2List(user, i* 4, i* 4 + 3);                                                        
                 userPoints=llList2Integer(details,2);
                 userName=llStringTrim(llList2String(details,1),STRING_TRIM);
                 //add user to the scoreboard (slot) list            
                 slots=llListReplaceList(slots, [userName,userPoints,userChannel++,llStringTrim(llList2String(details,0),STRING_TRIM)],i*4,i*4+4);
                 details=[];
                 //right align points
                 spaceLen=MAX_XY_LETTER_SPACE - (llStringLength    ((string)((i+1+10*(page-1))))+2+llStringLength(userName)+llStringLength((string)userPoints));         
                 text=(string)(i+1+10*(page-1))+") "+userName;
                 text+=llGetSubString("                              ", 0, spaceLen-1) + (string)userPoints;
                 stringToPrint+=text;   
                 text="";
             }
             user=[];
         llMessageLinked(LINK_SET, XY_TEXT_CHANNEL,stringToPrint, NULL_KEY);
         stringToPrint="";
     }else 
        if (command == "transactionComplete") {       
            llMessageLinked(LINK_SET,SETTEXT_CHANNEL,"DISPLAY::top display|STRING::Sloodle Award System: "+sloodleModName+"\nCourse: "+sloodlecoursename+"\nAssignment Link: "+assignmentName+" \nTransaction Complete|COLOR::"+(string)YELLOW+"|ALPHA::1.0",NULL_KEY);
            dataBits =llParseString2List(llList2String(dataBits,11),["|"],[]);
            avuuid=llList2String(llParseString2List((llList2String(dataBits,1)), [":"],[]),1);
            avName = llList2String(llParseString2List((llList2String(dataBits,2)), [":"],[]),1);
            newAmount = llList2Integer(llParseString2List((llList2String(dataBits,3)), [":"],[]),1);
            slotNum = llListFindList(slots, [avName])/4;        
            slotChan = USER_CHANNEL+slotNum;
            avName="";
            if (slotNum!=-1){            
                slots =  llListReplaceList(slots,[avName,newAmount,slotChan,avuuid], slotNum*4,slotNum*4+4);             
                  sendCommand("getClassList","index:"+(string)((page-1)*PAGE_SIZE)+"|SORT:"+sortMode);   

            }           
        }
        dataBits = [];
        updateData=[];
        updatedUser ="";
        user=[];
        sourceId = "";
        avName="";
        avuuid="";
        senderUuid=""; 
        command ="";      
        body="";
        statusLine=[];
        stringToPrint="";
        details=[];
        userName="";
        text="";
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
        llGiveInventory(id,"secretword");//this is an added level of security for your objects
        llGiveInventory(id,"sloodle_config");
    }
    timer() {
        llSetTimerEvent(0.0);

        sloodle_translation_request(SLOODLE_TRANSLATE_SAY,[] , "award:timeout", ["ok"], owner, "awards");
    }
  
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/sloodle_mod_awards-1.0.lsl 

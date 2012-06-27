//
// The line above should be left blank to avoid script errors in OpenSim.

/**********************************************************************************************
*  memory_controller.lsl
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html

*  Part of the SLOODLE Project see http://sloodle.org
*
*  Contributors:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
*
* INTENT
*  This script was created so that we can add a gaming element to the SLOODLE Educational Project
*  See http://sloodle.org 
*
*  This script is an example of how to issue commands to store data in mem_array scripts.  See the documentation
*  in the mem_array scripts for more information
*
*  I hope this script is useful to you, and encourages you to make some exciting new scripts and help us all
*  expand the virtual world - and maybe even make a few educational games!
*
*  Sincerely, Paul Preibisch
*/
integer DATA0; //constant to make code more readible.  Used in llList2String commands to retrieve a data field in data0 
integer DATA1; //constant to make code more readible.  Used in llList2String commands to retrieve a data field in column1 
integer MEMORY_CONTROLLER=-1; //all messages to the MEMORY CONTROLLER should be sent on -1 FOR link_num in linked messages
string command; //local var used to determin which command was sent
integer i; //local var used in for loops
string data0; //temporary var, represents a single data field value in column0
string data1; //temporary var, represents a single data field value in column1
string response; //local var to determine response received from mem_arrays
string data; //local var used in linked messages
list commandList; //local var used in linked messages
/***********************************************
*  clean()
*  Is used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  PLAYSOUND|50091bcd-d86d-3749-c8a2-055842b33484|soundPlayer 3|0.8  we send it instead like this:
*  COMMAND:PLAYSOUND|SOUND_UUID:50091bcd-d86d-3749-c8a2-055842b33484|SCRIPT_NAME:soundPlayer 3|VOLUME:0.8
*  By adding a context to the messages, the programmer can understand whats going on when debugging
*  All this function does is strip off the text before the ":" char 
***********************************************/
string clean(string cmd){     
     return llList2String(llParseString2List(cmd, [":"],[]),1);
}
default {
    state_entry() {
        llListen(0, "",llGetOwner(),"");    
    }
    listen(integer channel, string name, key id, string message) {
        llOwnerSay("Command Received");
        commandList = llParseString2List(message,[" "],[]);
        string command = llList2String(commandList, 0);
        data0=llList2String(commandList,1);
        data1=llList2String(commandList,2);
        data="data0:"+data0+"|data1:"+data1;
        if (command=="i"){//insert
            llOwnerSay("Sending insert command: "+data);
            llMessageLinked(LINK_SET,0,"COMMAND:INSERT|"+data, NULL_KEY);
        }
        else if (command=="r"){//remove
            llMessageLinked(LINK_SET,0,"COMMAND:REMOVE|data0:"+data0, NULL_KEY);
            llOwnerSay("Sending remove command: "+data);
            }
        else if (command=="l"){//list            
            llMessageLinked(LINK_SET,0,"COMMAND:LIST", NULL_KEY);
            llOwnerSay("Sending list command: "+data);
        }
        else if (command=="s"){//search
            llMessageLinked(LINK_SET,0,"COMMAND:GETDATA|data0:"+data0, NULL_KEY);
            llOwnerSay("Sending search command: "+data);
        }
        else if (command=="test"){//test
             llOwnerSay("Sending test command: "+data);
            for (i=0;i<1000;i++){
                llMessageLinked(LINK_SET,0,"COMMAND:INSERT|data0:"+(string)llFrand(1000)+"|data1:"+(string)llFrand(1000), NULL_KEY);
                
            }
        }
        else if (command=="c"){//count
             llOwnerSay("Sending count command: "+data);           
                llMessageLinked(LINK_SET,0,"COMMAND:COUNT|data0:0", NULL_KEY);                
            }
        
        
    }


    /***********************************************
    *  link_message
    *  
    *  SOURCES:
    *  Messages come from mem_array
    * 
    *  MESSAGES:
    *  RESPONSE:FOUND SEARCHITEM0|data0:some data|data1:somedata     //this is a response from  COMMAND:GETDATA|data0:somedata
    *  RESPONSE:NOTFOUND|data0:"+searchItem0                              //this is a response from  COMMAND:GETDATA|data0:somedata
    *  RESPONSE:INSERT COMPLETE|data0:somedata|data1:somedata        //this is a response from  COMMAND:INSERT|data0:somedata|data1:somedata
    *  RESPONSE:REMOVED ROW|data0:somedata|data1:somedata            //this is a response from  COMMAND:REMOVE|data0:somedata
    *  RESPONSE:NOT FOUND, REMOVE CANCELED|data0:somedata                //this is a response from  COMMAND:REMOVE|data0:somedata
    *  RESPONSE:COUNT|number of rows stored                                //this is a response from COMMAND:COUNT|0 sent to retrieve number of rows 
    ***********************************************/
    
    link_message(integer sender_num, integer mem_array_channel, string str, key id) {
        if (mem_array_channel==MEMORY_CONTROLLER){
            commandList = llParseString2List(str,["|"],[]);
            response = clean(llList2String(commandList,0));
            data0 = clean(llList2String(commandList,1));
            data1 = clean(llList2String(commandList,2));
            if (response=="FOUND SEARCHITEM0"){
                llSay(0,"Found: " + data0+", "+data1);
            }else if (response=="NOTFOUND"){
                llSay(0,"Not found: " + data0);
            }else if (response=="INSERT COMPLETE"){
               // llSay(0,"Insert complete: " + data0+", "+data1);
            }else if (response=="REMOVED ROW"){
                llSay(0,"Removed Row: " + data0+", "+data1);
            }else if (response=="NOT FOUND, REMOVE CANCELED"){
                llSay(0,"Error - remove canceled. Row not found: " + data0);
            }else if (response=="COUNT"){
                llSay(0,"Number of rows: " + data0);
            }
            llRemoteLoadScriptPin(llGetKey(), "mem_array",5577, TRUE, 0);
        }
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: assets/misc/memory_controller.lslp 

/**********************************************************************************************
*  mem_array.lsl
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  Contributors:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com  
/**********************************************************************************************

/**********************************************************************************************
* INTENT
*  This script was created in order to add a gaming element to the SLOODLE Educational Project
*  See http://sloodle.org 
*  I've used an earlier version of it, in my zombie attacks game here: 
*  http://www.youtube.com/watch?v=LPowKJA6Tnw&feature=channel_page
*
*  By using this script, developers can store data in SL using linked messages without having to worry about
*  storage limitations of LSL Lists (providing there are enough mem_array scripts in the prim)
*
*  Using this script, I am able to download student data from a mysql database directly into lsl memory
*  This way, my scripts can respond faster to in-world events without having to perform HTTP requests during
*  times which require faster responses.  Make sure you compile this script in mono to increase memory availability
*  
*  I hope this script is useful to you, and encourages you to make some exciting new scripts and help us all
*  expand the virtual world - and maybe even make a few educational games!
*  I'd also like to thank Linden Lab for developing a platform where 3d content can be created and shared in a 
*  Massively Multiplayer environment.  I hope others will emerge soon and join the fun!
*
*  Sincerely, Paul Preibisch
*
*  PURPOSE
*  The Purpose of this script is to increase the amount of data we can store using lsl lists.  Instead of 
*  storing data in a local list in your script, you can instead issue a llMessageLinked message to store the data
*  in the mem_array scripts.  These scripts work together in a chain like pattern.  Ie: commands are always 
*  issued to
*  the first mem_array script, then, go to mem_array 1, mem_array 2 etc, until the last mem_array script is reached.
*  In this way, the calling script can operate independantly of the mem_array scriots, and doesnt need to keep track
*  of how many mem_array scripts there are, it simply needs to issue
*  commands, and wait for a response.
* 
*  I've modelled this script after a typical database system which has rows and columns.
*  Therefore, you'll see that I've used lsl lists to represent "Columns" in a database table.  And 
*  individual list items consititute a table row.  So, for example
*  the entire database table in this script is comprised of:
*  list column0;
*  list column1;
*
*  To print Row 0 of the table would then be:  llSay(0,llList2String(column0,0) +", " + llList2String(column1,0);
* 
*  You'll also notice that I've made use of several constant values throughout the script
*  I've designed this script in this way, in order to be easy to read as a developer.
*  So, when sending a linked message, I don't just send the data, alone like:  INSERT|somedata|somedata
*  But instead,  I preface the data with contextual dextriptions
*  ie: COMMAND:INSERT|COLUMN0:some data|COLUMN1:somedata
*  In this way, the developer can easily see what is being sent in the linked message.  This may seam unnecessary
*  but since LindenLab, or another 3rd party hasn't developed a code stepper where
*  we can watch the values of our variables etc
*  during the debug stage, this can greatly help to see what is going on using a few llOwnerSay 
*  commands in the linked_message event.
*  --------------------------------------------------------------------------------------------------
*  INSERTING DATA
*  --------------------------------------------------------------------------------------------------
*  To insert data into the chain, I've created a memory_controller script.  As mentioned, this script operates independantly
*  of the mem_array scripts.  It simply needs to issue an insert command, and the mem_array scripts will handle the rest.
*    
*  llMessageLinked(LINK_SET, 0, "COMMAND:INSTERT|COLUMN0:some data|COLUMN1:some data", NULL_KEY);
*
*  WHAT HAPPENS:  
*  Since link_num was set to 0 when this command was executed, only the first mem_array script will respond. 
*  It will first check if it has any free memory, if it does, it will store the column0 data in a list called column0, and the column1 data in a list called column1
*  If you need to save more than 2 data elements, simply modify this script by adding more lists - called column2,column3 etc
*  
*  If the mem_array script is getting full, instead of inserting the data in it's column lists, it will instead relay the INSERT message to the next
*  mem_array script. (ie: if "mem_array 1" is full, it will pass the insert message to "mem_array 2".  If all mem_arrays are full, then the last
*  mem_array script will report an error to the calling script, via a linked message.  Thus, all commands trickle down through the chain until
*  the end of the chain.
*  --------------------------------------------------------------------------------------------------  
*  RETRIEVING DATA
*  --------------------------------------------------------------------------------------------------
*  To retrieve data, you simply need to issue the following linked message:
*  
*  llMessageLinked(LINK_SET,0,"COMMAND:GETDATA|COLUMN0:some data, NULL_KEY);
*
*  Example:  Maybe you are using these to store a list of visitor names.  Then you issue:
*  llMessageLinked(LINK_SET,0,"COMMAND:GETDATA|COLUMN0:Fire Centaur, NULL_KEY);
*
*  WHAT HAPPENS:
*  "mem_array" (the first script) would receive the command, search through column0, and if found, send a linked message 
*  back to your script with the other columns appended.
*  a typical response would be:
*
*  RESPONSE:FOUND SEARCHITEM0|COLUMN0:Fire Centaur|COLUMN1:other data which was stored
*
*  
*  --------------------------------------------------------------------------------------------------  
*  REMOVING A ROW
*  --------------------------------------------------------------------------------------------------
*  To remove a row, simply issue the following:
* 
*  llMessageLinked(LINK_SET,0,"COMMAND:REMOVE|COLUMN0:Fire Centaur", NULL_KEY);
*  
*  WHAT HAPPENS:
*  "mem_array" (the first script) would receive the command, search through column0, and if found, 
*  remove the data from column0, column1 etc
*  If the data was found, then the mem_array will send back a sucess response to the memory controller (listed below). 
*  If mem_array can't find the data to be removed, it will relay the remove command to the next mem_array script.
*  If the command trickles down to the last link in the chain without finding the data to be removed
*  an error response will be sent back to the memory controller script
*
*  RESPONSE:REMOVED ROW|COLUMN0:Fire Centaur|COLUMN1:other data 
*
*  or:
*
*  RESPONSE:NOT FOUND, REMOVE CANCELED|COLUMN0:Fire Centaur     
*
*  --------------------------------------------------------------------------------------------------  
*  LISTING rows
*  --------------------------------------------------------------------------------------------------
*  For testing purposes, I added a LIST command that will simply print out all rows stored.
* 
*  llMessageLinked(LINK_SET,0,"COMMAND:LIST", NULL_KEY);
*
*  WHAT HAPPENS:
*  "mem_array" (the first script) would receive the command, and simply iterate through the lists llSaying each data field
*  When complete, the LIST command is sent to the next mem_array
*
*  --------------------------------------------------------------------------------------------------  
*  COUNTING DATA ELEMENTS
*  --------------------------------------------------------------------------------------------------
*  To remove a retrieve a count of all the data elements stored in the mem_arrays, simply issue the following:
* 
*  llMessageLinked(LINK_SET,0,"COMMAND:COUNT|COLUMN0:0", NULL_KEY);
*
*  WHAT HAPPENS:
*  "mem_array" (the first script) would receive the command, count the number of elements in column0
*  and then relay this total to the next mem_array
*  The next mem_array would add the amount sent to it's count, and relay the message to the next.
*  This continues until the last link in the chain is reached, and then the grand total is sent back to the memory controller
*
*  RESPONSE:COUNT|number of rows stored 
*  
**********************************************************************************************/

integer MIN_MEMORY_LIMIT=2000;
integer COLUMN0=1; //a constant used in llList2String commands to make code more readable
integer COLUMN1=2; //a constant used in llList2String commands to make code more readable 
integer COMMAND=0; //a constant used in llList2String commands to make code more readable
integer DATA0;//a constant used in llList2String commands to make code more readable
integer DATA1;//a constant used in llList2String commands to make code more readable
integer SEARCHITEM0=1; //a constant used in llList2String commands to make code more readable
string searchItem0; //local var used when searching through columns
integer count;     //used to get the cummulative total of all elements stored in the mem_arrays
integer prevTotal; //used to get the cummulative total of all elements stored in the mem_arrays
integer true=1;    //a constant used to make the code more readable
integer false=-1;  //a constant used to make the code more readable
integer MEMORY_CONTROLLER=-1; //MEMORY CONTROLLER USES 0 FOR link_num for linked messages
integer myLinkNum; //This is used to identify the script
list column0;      //this can be seen as column0 of a table row, to add more data elements, add column2,3,4 throughout the code
list column1;       //this can be seen as column1 of a table row, to add more data elements, add column2,3,4 throughout the code
string data;      //temporary vars
string data0;      //temporary var, represents a single data field value in column0
string data1;     //temporary vars, represents a single data field value in column1
integer LAST_LINK_IN_MEM_ARRAY=-1; //switch var, which indicates if this is the last link in the chain.  Determined by script name
list    mem_array_script_list; //used to count how many mem_array's exist in the prim
integer s; //local var used in count_mem_array_scripts function to determin number of scripts in the prim
integer numArrays; //local var used in count_mem_array_scripts function to determin number of scripts in the prim
list message;  //local var used in linked_message events
integer foundIndex;//local var used to search lists
integer i; //local var used for for loops
/***********************************************
*  clean()
*  Is used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  By adding a context to the messages, the programmer can understand whats going on when debugging
*  All this function does is strip off the text before the ":" char 
***********************************************/
string clean(string cmd){     
     return llList2String(llParseString2List(cmd, [":"],[]),1);
}

/***********************************************
*  count_mem_array_scripts()
* 
*  This function will count the number of mem_array scripts that exist, 
*  and will check if this is the last mem_array script in the chain
*
***********************************************/
integer count_mem_array_scripts()
{
    mem_array_script_list = [];
    s = llGetInventoryNumber(INVENTORY_SCRIPT);
    numArrays=0;     
    while(s){
        string scriptName = llGetSubString(llGetInventoryName(INVENTORY_SCRIPT, --s),0,8);        
        if (scriptName=="mem_array") 
            numArrays++;
     
    }
    
    if (myLinkNum == (numArrays-1))  
        LAST_LINK_IN_MEM_ARRAY = 1; 
        else LAST_LINK_IN_MEM_ARRAY = -1; 
    return LAST_LINK_IN_MEM_ARRAY;
}
default
{
    state_entry()
    {

        llSetTextureAnim( ANIM_ON|LOOP|SMOOTH, ALL_SIDES, 1, 1, 0, 1, -0.05 );
        myLinkNum = (integer)llGetSubString(llGetScriptName(), 9, -1);   
        llSay(0,(string)llGetFreeMemory());  
        count_mem_array_scripts();
    }
    /***********************************************
    *  link_message
    *  
    *  SOURCES:
    *  Messages come from memory_controller, or other mem_array
    * 
    *  MESSAGES:
    *  COMMAND:GETUUID|SEARCHITEM0:someuuid        
    ***********************************************/
    link_message(integer sender_num, integer mem_array_link, string str, key id) {
        
       list message=llParseString2List(str, ["|"],[]);
     
        /*
        * This script will only respond to this link_message event if the link_message is for us. This is determinted by looking at mem_array_link var, and comparing
        * that with our script name.  If mem_array_link is the same as our script number, ie: if this is mem_array 1, then
        * our script number is 1 
        */
        if (mem_array_link==myLinkNum){
            /*
            *     "GETPLAYER" is a search message sent from the MEMORY CONTROLLER
            *   The message sent from the memory controller looks like this:
            *   COMMAND:GETDATA|SEARCHITEM0:some data
            */
            if (clean(llList2String(message,COMMAND)) == "GETDATA")
            {
                
                searchItem0=clean(llList2String(message,SEARCHITEM0)); //retrieve searchItem0 from the linked message             
                foundIndex= llListFindList(column0,[searchItem0]); //search through column0 for searchItem0
                //FOUND: If the SEARCHITEM0 was found, then we can send back data                
                if (foundIndex != -1) 
                {
                    //This mem_array contains several lists.  Each list pertains to a particular field of data
                    //in our case we are only storing two fields of data per row.
                    //[COLUMN0][COLUMN1].  Therefore, index 0 of column0, and scoreboardUuidList represent one row of data
                    //In order to hold more field values, simply add another list to this script. Example:
                    //We could add another list called: playerPoints, then, a typical row of data would be:
                    //[COLUMN0][COLUMN1][COLUMN2] 
                    //We will now return COLUMN0, and COLUMN1 to the Memory_controller                                       
                    llMessageLinked(LINK_SET, MEMORY_CONTROLLER, "COMMAND:FOUND SEARCHITEM0|COLUMN0:"+llList2String(column0,foundIndex)+"|COLUMN1:"+llList2String(column1,foundIndex), NULL_KEY);
                    
                }else { //NOT FOUND
                    /*
                    * The SEARCHITEM0 is NOT held in this mem_array. Therefore, we must tell the next mem_array in the chain to
                    * search for the SEARCHITEM0.  If this is the last mem_array in the chain, then we must send a NOT FOUND message back
                    * to the MEMORY_CONTROLLER
                    */
                    if (LAST_LINK_IN_MEM_ARRAY==true)
                         llMessageLinked(LINK_SET, MEMORY_CONTROLLER, "RESPONSE:NOTFOUND|COLUMN0:"+searchItem0, NULL_KEY);
                    else
                        //If we aren't the last link of the mem_arrays, we need to tell the next mem_array to perform a search
                        llMessageLinked(LINK_SET, myLinkNum+1, "COMMAND:GETDATA|COLUMN0:"+searchItem0, NULL_KEY);
                    
                    
                }
            }
            /*
            *     "INSERT" is a request sent from the MEMORY CONTROLLER to store data
            *
            *   The message sent from the memory controller looks like this:
            *   COMMAND:INSERT|DATA0:some data|DATA1:some data
            */
            else if (clean(llList2String(message,COMMAND))=="INSERT"){
                data0=clean(llList2String(message,1));
                data1=clean(llList2String(message,2));
                data="COLUMN0:"+data0+"|COLUMN1:"+data1;
                
                if (llGetFreeMemory()> MIN_MEMORY_LIMIT){
                    
                    column0+=data0;
                    column1+=data1;
                    llMessageLinked(LINK_SET, MEMORY_CONTROLLER, "RESPONSE:INSERT COMPLETE|"+data, NULL_KEY);
                    llSay(0,llGetScriptName()+" inserted data");
                }else{                     
                    //the memory is full, so we need to pass insert command to the next mem_array, but if we are the last mem_array, we need to report an error
                     if (LAST_LINK_IN_MEM_ARRAY==true){
                         llRemoteLoadScriptPin(llGetKey(), "mem_array",5577, TRUE, 0);
                         //llOwnerSay(llGetScriptName()+":LAST mem_array ********* mem error "+str);
                         llMessageLinked(LINK_SET, MEMORY_CONTROLLER, "RESPONSE:MEMORY ERROR|"+data, NULL_KEY);
                    }else{
                        //llOwnerSay(llGetScriptName()+":********* REALYING INSERT "+str);
                        //If we aren't the last link of the mem_arrays, we need to tell the next mem_array to perform a search and destroy
                        //MESSAGE FORMAT: COMMAND:INSERT|DATA0:some data
                        llMessageLinked(LINK_SET, myLinkNum+1, "COMMAND:INSERT|"+data, NULL_KEY);
                    }                     
                }
            }
            /*
            *     "REMOVE" is a request sent from the MEMORY CONTROLLER to REMOVE a row data
            *
            *   The message sent from the memory controller looks like this:
            *   COMMAND:REMOVE|DATA0:some data
            */
            else if (clean(llList2String(message,COMMAND))=="REMOVE"){     
                llOwnerSay(llGetScriptName()+":in REMOVE "+str);                       
                searchItem0=clean(llList2String(message,SEARCHITEM0)); //retrieve searchItem0 from the linked message
                foundIndex= llListFindList(column0,[searchItem0]); //search through column0 for searchItem0               
                //FOUND: If the SEARCHITEM0 was found, then delete it from this mem_array           
                if (foundIndex != -1) 
                {
                    
                    llMessageLinked(LINK_SET, MEMORY_CONTROLLER, "RESPONSE:REMOVED ROW|COLUMN0:"+llList2String(column0,foundIndex)+"|COLUMN1:"+llList2String(column1,foundIndex), NULL_KEY);
                    column0 = llDeleteSubList(column0, foundIndex, foundIndex);
                    column1 = llDeleteSubList(column1, foundIndex, foundIndex);
                }else { //NOT FOUND
                    /*
                    * The SEARCHITEM0 is NOT held in this mem_array. Therefore, we must tell the next mem_array in the chain to
                    * search for the SEARCHITEM0 and if found delete it. 
                    *  If this is the last mem_array in the chain, then we must send a NOT FOUND message back
                    *  to the MEMORY_CONTROLLER
                    */
                    if (LAST_LINK_IN_MEM_ARRAY==true){
                         llMessageLinked(LINK_SET, MEMORY_CONTROLLER, "RESPONSE:NOT FOUND, REMOVE CANCELED|COLUMN0:"+searchItem0, NULL_KEY);
                    }else{
                        //If we aren't the last link of the mem_arrays, we need to tell the next mem_array to perform a search and destroy
                        //MESSAGE FORMAT: COMMAND:REMOVE|DATA0:some data
                        llMessageLinked(LINK_SET, myLinkNum+1, "COMMAND:REMOVE|COLUMN0:"+searchItem0, NULL_KEY);
                    } 
                    
                }
            }
            /*
            *     "LIST" is a request sent from the MEMORY CONTROLLER to LIST all data row data
            *
            *   The message sent from the memory controller looks like this:
            *   COMMAND:LIST
            */
            else if (clean(llList2String(message,COMMAND))=="LIST"){
                for (i=0;i<llGetListLength(column0);i++)
                    llOwnerSay(llGetScriptName()+" "+(string)i+": "+llList2String(column0, i)+", "+llList2String(column1, i));
                
                llMessageLinked(ALL_SIDES, myLinkNum+1, "COMMAND:LIST", NULL_KEY);
            } 
            /*
            *     "COUNT" is a message sent from the MEMORY CONTROLLER. It will go through each mem array and count
            *   how many values are currently stored
            *   The message sent from the memory controller looks like this:
            *   COMMAND:COUNT
            *   After counting, it will relay the count to the next mem_array, until the last mem_array is visited.
            *   The cummulative total will be sent back to the memory controller
            */
            if (clean(llList2String(message,COMMAND)) == "COUNT"){
                count = llGetListLength(column0);
                prevTotal = (integer)clean(llList2String(message,COLUMN0));
                count+= prevTotal; 
                 if (LAST_LINK_IN_MEM_ARRAY==true){
                         llMessageLinked(LINK_SET, MEMORY_CONTROLLER, "RESPONSE:COUNT|COLUMN0:"+(string)count, NULL_KEY);
                    }else{
                        //If we aren't the last link of the mem_arrays, we need to tell the next mem_array to perform a search and destroy
                        //MESSAGE FORMAT: COMMAND:REMOVE|DATA0:some data
                        llMessageLinked(LINK_SET, myLinkNum+1, "COMMAND:COUNT|COLUMN0:"+(string)count, NULL_KEY);
                    } 
            }

        }
}
    
    /***********************************************
    *  changed event
    *  
    *  Every time the inventory changes, we must count the number of mem_array scripts to determin if this is the last
    *  mem_array in the chain.  This is important because, if we ARE the last mem_array script, we are responsible for
    *  sending NOT FOUND messages back to the memory controller if searches through the entire chain of mem_array scripts fail.
    *        
    ***********************************************/
    changed(integer change) {
     if (change ==CHANGED_INVENTORY){         
         count_mem_array_scripts();
     }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: lib/lsl/mem_array.lsl 

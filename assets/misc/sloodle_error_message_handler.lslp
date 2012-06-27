//
// The line above should be left blank to avoid script errors in OpenSim.

/**********************************************************************************************
*  sloodle_error_message_handler.lsl
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header 
*  as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*  This script is intended to translate error messages sent via linked messages from sloodle scripts.
*  All Sloodle Status codes from our wiki at: http://slisweb.sjsu.edu/sl/index.php/Sloodle_status_codes 
*  have been added to an LSL list.  I have also added standard HTTP error status's so we can give more
*  detailed information to our lovely sloodlers during the confuration stage of Sloodle.
*
*  USE:  To use this script, simply include our premade function "sloodle_error_code" in your script
*  sloodle_error_code(string method, key avuuid,integer statuscode){
*       llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST, method+"|"+(string)avuuid+"|
*       +(string)statuscode, NULL_KEY);
*   }
*  
*  Then in your code, use it like: sloodle_error_code(SLOODLE_TRANSLATE_SAY, NULL_KEY,statuscode); 
*
*  All messages should be sent on this channel: 
*  integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
*
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  Copyright
*  Paul G. Preibisch (Fire Centaur in SL) fire@b3dMultiTech.com  
*  Edmund Edgar
/**********************************************************************************************/
integer SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST=-1828374651;
list errorMessages;

// Translation output methods
string SLOODLE_TRANSLATE_LINK = "link";                     // No output parameters - simply returns the translation on SLOODLE_TRANSLATION_RESPONSE link message channel
string SLOODLE_TRANSLATE_SAY = "say";                       // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_WHISPER = "whisper";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SHOUT = "shout";                   // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_REGION_SAY = "regionsay";          // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";            // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";                 // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";              // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_LOAD_URL_PARALLEL = "loadurlpar";  // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";          // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_IM = "instantmessage";             // Recipient avatar should be identified in link message keyval. No output parameters.

string sloodle_get_error_string(integer statusCode){
    list found =fncFindStride(errorMessages, [statusCode],3);
    integer index = llList2Integer(found,0);
    list values;    
    string trans;
    if (llList2Integer(found,0)!=-1){
         values = fncGetStride(errorMessages, index, 3);    //will return a stride of len 3 - ie:  [-213,"error message"]
         trans = llList2String(values,1);
    }
    return trans; 
}

/****************************************************************
* integer fncStrideCount(list source, integer stride)
*
* Returns the number of strides found within a list.
* Source is the list to operate on, and stride is the length of each stride within the list.
* list Source = ["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"];
* integer Result = fncStrideCount(Source, 3);
* Returns 3
* Returns number of Strides in a List
*********************************************************************/
integer fncStrideCount(list lstSource, integer intStride)
{
  return llGetListLength(lstSource) / intStride;
}

/*********************************************************************
* list fncGetStride(list source, integer index, integer stride)
* Returns a single stride from the list.
* Source is the list to retrieve from, index is which stride to return (zero indexed), and stride is the length of each stride.
* list Source = ["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"];
* 
* list Result = fncGetStride(Source, 1, 3);
* 
*  Returns ["B1", "B2", "B3"]
*  On failure returns an empty list
**********************************************************************/
list fncGetStride(list lstSource, integer intIndex, integer intStride)
{
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = intIndex * intStride;
    return llList2List(lstSource, intOffset, intOffset + (intStride - 1));
  }
  return [];
}
/****************************************************************
* list fncFindStride(list source, list item, integer stride)
*
* Returns the stride number and element number of an element within a stride, within a list. (zero indexed)
* Source is the list to search, item is a single element list containing the item to search for, and stride is the length of each stride.
* list Source = ["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"];
* list Item = ["B3"];
* 
* list Result = fncFindStride(Source, Item, 3);
* Returns [1, 2].
* The first number is which stride Item is in.
* The second is which element of the stride is Item.
* 
* If item is not found, it will return [-1, -1]
*********************************************************************/
list fncFindStride(list lstSource, list lstItem, integer intStride)
 {
     integer intListIndex = llListFindList(lstSource, lstItem);
   
   if (intListIndex == -1) { return [-1, -1]; }
   
   integer intStrideIndex = intListIndex / intStride;
   integer intSubIndex = intListIndex % intStride;
   
  return [intStrideIndex, intSubIndex];
}
default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        errorMessages=[-1 ,"An unspecified error occured","MISC"];
        errorMessages+=[-101,"An unknown system error occured","SYSTEM"];
        errorMessages+=[-102,"Could not connect to the database.","SYSTEM"];
        errorMessages+=[-103,"Could not fetch data we expected to be there. ","SYSTEM"];
        errorMessages+=[-104,"Data formatting error ","SYSTEM"];
        errorMessages+=[-105,"XMLRPC error","SYSTEM"];
        errorMessages+=[-106,"The Sloodle module is not installed in Moodle ","SYSTEM"];
        errorMessages+=[-111,"System is temporarily down for maintenance. ","SYSTEM"];
        errorMessages+=[-121,"Failed to send required email ","SYSTEM"];
        errorMessages+=[-131,"Failed to load plugins ","PLUGIN"];
        errorMessages+=[-132,"The required plugin was not found ","PLUGIN"];
        errorMessages+=[-201,"There was an unspecified problem authenticating the object. ","OBJECT_AUTH"];
        errorMessages+=[-212,"Object did not supply the necessary information to authenticate itself. ","OBJECT_AUTH"];
        errorMessages+=[-213,"Object authentication key was invalid ","OBJECT_AUTH"];
        errorMessages+=[-214,"Object not authorised in this context ","OBJECT_AUTH"];
        errorMessages+=[-215,"Prim password access has been disabled for this Controller. ","OBJECT_AUTH"];
        errorMessages+=[-216,"Object not found in database","USER_AUTH"];
        errorMessages+=[-217,"Could not save HTTP-in URL (v2.0 etc)","OBJECT_AUTH"];
        errorMessages+=[-218,"Active object not found while trying to save HTTP-in URL (v2.0 etc)","OBJECT_AUTH"];
        errorMessages+=[-219,"Sending configuration to object via HTTP-in URL failed","OBJECT_AUTH"];
        errorMessages+=[-301,"There was an unspecified problem authenticating the user. ","USER_AUTH"];
        errorMessages+=[-311,"Object did not supply the necessary information to authenticate the user. ","USER_AUTH"];
        errorMessages+=[-321,"User was not registered and we weren't allowed to register them automatically. ","USER_AUTH"];
        errorMessages+=[-322,"User was not registered and we tried to register them but failed. ","USER_AUTH"];
        errorMessages+=[-331,"User did not have permission to access the resources requested . ","USER_AUTH"];
        errorMessages+=[-341,"Password cannot be reset via Sloodle, as user was not auto-registered (or has since registered an email account). ","USER_AUTH"];
        errorMessages+=[-401,"There was an unspecified problem involving course enrolment. ","USER_ENROL"];
        errorMessages+=[-421,"User was not enrolled on the course and we weren't allowed to enrol them automatically","USER_ENROL"];
        errorMessages+=[-422,"User was not enrolled on the course and tried to enrol them but failed. ","USER_ENROL"];
        errorMessages+=[-501,"There was an unspecified problem involving the course you ar trying to use. ","COURSE"];
        errorMessages+=[-511,"The course you are trying to use was not specified. ","COURSE"];
        errorMessages+=[-512,"The course you are trying to use was not found. ","COURSE"];
        errorMessages+=[-513,"The course you are trying to use was inactive. ","COURSE"];
        errorMessages+=[-514,"The course you are trying to use was forbidden from being used with Sloodle. ","COURSE"];
        errorMessages+=[-601,"There was an unspecifed problem involving the module you're trying to use. ","MODULE"];
        errorMessages+=[-611,"The module you are trying to use was not specified.","MODULE"];
        errorMessages+=[-612,"The module you are trying to use was found. ","MODULE"];
        errorMessages+=[-613,"The module you are trying to use was inactive. ","MODULE"];
        errorMessages+=[-614,"The module you are trying to use was forbidden from being used by Sloodle. ","MODULE"];    
        errorMessages+=[-701,"There was an unspecifed problem involving the module instance you're trying to use. ","MODULE_INSTANCE"];
        errorMessages+=[-711,"The module instance you are trying to use was not specified. ","MODULE_INSTANCE"];
        errorMessages+=[-712,"The module instance you are trying to use was not found. ","MODULE_INSTANCE"];
        errorMessages+=[-713,"The module instance you are trying to use was inactive. ","MODULE_INSTANCE"];
        errorMessages+=[-714,"The module instance you are trying to use was forbidden from being used by Sloodle. ","MODULE_INSTANCE"];
        errorMessages+=[-801,"Requested script permanently deleted. ","REQUEST"];
        errorMessages+=[-802,"Requested script moved (new location may be specified in the first data line) ","REQUEST"];
        errorMessages+=[-811,"Request incomplete (not all required data present) ","REQUEST"];
        errorMessages+=[-812,"Requested resource could not be found (although the request itself was handled successfully) ","REQUEST"];
        errorMessages+=[-901,"Unknown profile error ","PROFILE"];
        errorMessages+=[-902,"Profile does not exist ","PROFILE"];
        errorMessages+=[-903,"Profile already exists ","PROFILE"];
        errorMessages+=[-904,"Unknown profile command ","PROFILE"];
        errorMessages+=[-777000,"Transaction for this user was not found","TRANSACTION"];
        errorMessages+=[10001,"Obtained results successfully","CHOICE_QUERY"];
        errorMessages+=[10011,"Added new choice selection for user ","CHOICE_SELECT"];
        errorMessages+=[10012,"Updated choice selection for user ","CHOICE_SELECT"];
        errorMessages+=[10013,"User had previously selected the same option ","CHOICE_SELECT"];
        errorMessages+=[10101,"Successfully added a chat message into the database (commonly used as a side-effect code) ","CHAT_MESSAGE"];
        errorMessages+=[-10001,"Unable to query choice status for unknown reason ","CHOICE_QUERY"];
        errorMessages+=[-10011,"The user has already selected a choice, and choices cannot be updated ","CHOICE_SELECT"];
        errorMessages+=[-10012,"Maximum number of selections for this choice already made ","CHOICE_SELECT"];
        errorMessages+=[-10013,"Choice is not yet open for selections ","CHOICE_SELECT"];
        errorMessages+=[-10014,"Choice has been closed ","CHOICE_SELECT"];
        errorMessages+=[-10015,"Specified option not found in choice ","CHOICE_SELECT"];
        errorMessages+=[-10016,"Unable to make choice selection for unknown reason (usually more data appended in data lines) ","CHOICE_SELECT"];
        errorMessages+=[-10021,"Unable to query list of choice instances for unknown reason ","CHOICE_LIST_QUERY"];
        errorMessages+=[-10022,"Not choice instances available in course ","CHOICE_LIST_QUERY"];
        errorMessages+=[-10101,"Failed to add chat message to database ","CHAT_MESSAGE"];
        errorMessages+=[-10201,"User is not authorised to submit assignments ","ASSIGNMENT"];
        errorMessages+=[-10202,"Assignment is not yet open for submissions ","ASSIGNMENT"];
        errorMessages+=[-10203,"Assignment due date has passed, and is closed for submissions ","ASSIGNMENT"];
        errorMessages+=[-10204,"Assignment due date has passed, but is still accepting submissions (typically a side effect code) ","ASSIGNMENT"];
        errorMessages+=[-10205,"Resubmissions are not permitted ","ASSIGNMENT"];
        errorMessages+=[-10301,"Student has used all quiz attempts ","QUIZ"];
        errorMessages+=[-10302,"Quiz requires password - this is not supported by Sloodle ","QUIZ"];
        errorMessages+=[-10303,"      Error loading questions ","QUIZ"];        
        errorMessages+=[-10401,"Blogging is disabled on this site. ","BLOG"];
        errorMessages+=[-10402,"User does not have permission to write blogs ","BLOG"];
        errorMessages+=[-10501,"There are no slides in this presentation. ","PRESENTER"];
        errorMessages+=[301 ,"HTTP Server error (301)\"Moved Permanently\" -  The page you are trying to connect to has moved","HTTP"];
        string errMess= "HTTP Server error (400)\"Bad Request\" -  The Web server considers the data stream ";
        errMess+= "sent by your Second Life object to be 'malformed' i.e. it has not sent a complete HTTP request. In such cases ";
        errMess+= "the web server is unable to process the request. Have you recently added beta code to your server?";
        errorMessages+=[400  ,errMess,"HTTP"];
        errMess = "HTTP Server error (401) \"Unauthorized\" -  It seams Sloodle is trying to access a password protected directory on ";
        errMess+= "your server. In such cases you should check whether you have specified the correct folder during installation.";
        errorMessages+=[401  ,errMess,"HTTP"];
        errMess = "HTTP Server error (403) \"Forbidden\" -  This error message means that Sloodle is trying to open a folder or a file ";
        errMess += "it does not have access to. If you are receiving this error message on your website, you should check the .htaccess files in your ";
        errMess += "web hosting account for any restrictive rules.";        
        errorMessages+=[403  ,errMess,"HTTP"];
        errMess = "HTTP Server error (404) \"Not Found\" -  It seams Sloodle is trying to access a non-existent page or a folder. ";
        errMess += "In such cases you should check if the link you are trying to access is correct.";
        errorMessages+=[404  ,errMess,"HTTP"];
        errMess ="An internal server error has occured. This is a standard HTTP 500 error, Perhaps Sloodle is trying to access code that is broken.  Have you installed any beta software recently?  Make sure you make backups before upgrading your Sloodle.  ";
        errMess +="Error 500 is a \'catch-all\' error generated by the Web server. Basically something has gone wrong, but the server can not be more specific about the error condition in its response to Sloodle.";
        errorMessages+=[500  ,errMess,"HTTP"];
        errMess = "An HTTP 503 error has occured.  This is a standard HTTP error that means \"Service Unavailable.\"";
        errMess +="It can have nothing to do with Sloodle - but instead, an essential program on your server may have crashed";
        errMess +=" You often see HTTP 503 when a website has exceeded its monthly bandwidth allowance";
        errMess +=" It could also mean a connection to a database has failed or is misconfigured.  Most likely, you never typed the address of your sloodle website correctly during the Sloodle configuration stage.";
        errMess +="Click the mouse on the object you are trying to configure, and try again with the correct address.";
        errorMessages+=[503  ,errMess,"HTTP"];
        
        
    }
    link_message(integer sender_num, integer channel, string str, key id) {
        if (channel==SLOODLE_CHANNEL_ERROR_TRANSLATION_REQUEST){
            //message will be in the format
            //status code|senderuuid;
            list fields = llParseStringKeepNulls(str, ["|"], []);
            
            integer numfields = llGetListLength(fields);            
            string method= llList2String(fields,0);
            key senderUuid = llList2Key(fields,1);
            integer statusCode = llList2Integer(fields,2);
            
            //TRANSLATE status code//
            string   trans = sloodle_get_error_string(statusCode);
            if (trans == "") {
                // Error code missing.
		// In Sloodle 2, the script sending the error may send us a message to say to the user.
		// For example, if you don't have enough points to use an object, there may be a user-defined message telling you that.
                // If we intended to produce a message in the right language on the server side, we leave the error string undefined on purpose.
                if (llGetListLength(fields) > 3) {
                    trans = llList2String(fields,3);
                }
            }

            if (trans!=""){
                if (method == SLOODLE_TRANSLATE_SAY)    llSay(0,"Error Message: "+trans);
                else if (method==SLOODLE_TRANSLATE_IM) llInstantMessage(senderUuid,"Error Message: " + trans);
            }else    llSay(0,"Error Message Translation not found - please view http://slisweb.sjsu.edu/sl/index.php/Sloodle_status_codes for more information: Error Code: "+(string)statusCode);      
        }
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: lsl/sloodle_error_message_handler.lsl

//
/* The line above should be left blank to avoid script errors in OpenSim.

  router
        
  Part of the Sloodle project (www.sloodle.org)
  
  Copyright (c) 2006-9 Sloodle (various contributors)
  
  Released under the GNU GPL
  
  Contributors:
  	Edmund Edgar
  	Paul Preibisch

  This script receives requests from SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG linked message channel, and passes it along to 6 sloodle_quiz_question_handler scripts in waiting
  After it passes it along, it marks that script as busy, until that script notifies the router it is free again for work.  I created this to help spead up the response time of 
  http requests 
     	
*/
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG = -1639271126; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
list slots = [NULL_KEY,NULL_KEY,NULL_KEY,NULL_KEY,NULL_KEY,NULL_KEY];
integer len;
integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG0 = -170000; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
		integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG1 = -1700001; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
		integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG2 = -1700002; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
		integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG3= -1700003; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
		integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG4 = -1700004; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
		integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG5 = -1700005; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
		integer SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG6 = -1700006; // Tells the question handler scripts to ask the question with the ID in str to the avatar with key VIA DIALOG.
integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text		
list qChannels =[SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG0,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG1,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG2,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG3,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG4,SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG5];
integer SLOODLE_CHANNEL_ANSWER_SCORE_FOR_AVATAR = -1639271113; // Tells anyone who might be interested that we scored the answer. Score in string, avatar in key.
default {
    state_entry() {
        llOwnerSay("Hello Scripter");
        len= llGetListLength(slots);
    }
    link_message(integer sender_num, integer num, string str, key user_key) {
    
        if (num==SLOODLE_CHANNEL_QUIZ_ASK_QUESTION_DIALOG){
            key not_used;
            integer index=0;
            integer free=-1;
            do{
                not_used = llList2Key(slots,index);
                if (not_used==NULL_KEY){
                    free=index;       
                    llOwnerSay("found free: "+(string)index);     
                    slots = llListReplaceList(slots , [user_key], free, free);   
                }
                if (index>=len-1){
                    index=0;
                }else{
                 index++;   
                }
            
            } while(not_used!=NULL_KEY);
            
            llOwnerSay(llList2CSV(slots));
            llMessageLinked(LINK_SET, llList2Integer(qChannels, free), str, user_key);
                     
        }else 
        if (num==SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR){
        	integer found = llListFindList(slots, [user_key]);
        	if (found!=-1){
        		slots=llListReplaceList(slots, [NULL_KEY], found, found);
        		llOwnerSay("-----------------------------------slot "+(string)found+" is now available");
        	}
        }
    
    }
}

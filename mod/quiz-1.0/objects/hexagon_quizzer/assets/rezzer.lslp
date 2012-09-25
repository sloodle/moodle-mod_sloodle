float size_x_half=3.0965;
float size_y=5.3662;
list rezzed_hexes;
integer PIN=7961;
integer SLOODLE_CHANNEL_ANIM= -1639277007; 
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
integer SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE= -1639277008;
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER = -1639271116; //mod quiz script is in state CHECK_QUIZ
string HEXAGON_PLATFORM="Hexagon Platform";
integer my_start_param;
debug (string message ){
     list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
     if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 

rez_hexagon(integer edge){
     integer my_oposite_section;
     vector my_coord=llGetPos();
     vector child_coord=my_coord;
     integer DIVISER=1;
     if (edge==1){
         child_coord.y=my_coord.y+2*(size_y);  
        my_oposite_section=4;                              
     }else
     if (edge==2){
        child_coord.x=my_coord.x+3*(size_x_half);
        child_coord.y=my_coord.y+1*(size_y);
        my_oposite_section=5;
     }else
     if (edge==3){
         child_coord.x=my_coord.x+3*(size_x_half);
         child_coord.y=my_coord.y-1*(size_y);
        my_oposite_section=6;
     }else
     if (edge==4){
         child_coord.y=my_coord.y-2*(size_y);
        my_oposite_section=1;
     }else 
     if (edge==5){
         child_coord.x=my_coord.x-3*(size_x_half);
        child_coord.y=my_coord.y-1*(size_y);
        my_oposite_section=2;
     }else
     if (edge==6){
         child_coord.x=my_coord.x-3*(size_x_half);
        child_coord.y=my_coord.y+1*(size_y);
     }
    //rez a new hexagon, and pass my_oppsosite_section as the start_parameter so that the new hexagon wont rez on that the my_oposite_section edge
    llRezAtRoot(HEXAGON_PLATFORM, child_coord, ZERO_VECTOR,  llGetRot(), my_oposite_section);
}

default {
    on_rez(integer start_param){
        
        
    }
  	state_entry() {
          string name=llGetObjectName();
          if (name=="Hexagon Quizzer"){
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "edge expand show|1,2,3,4,5,6|10", NULL_KEY);    
          }  
    }
    link_message(integer link_set, integer link_message_channel, string str, key id) {
        if (link_message_channel ==SLOODLE_CHANNEL_USER_TOUCH){
            list data= llParseString2List(str, ["|"], []);
            string type = llList2String(data,0);
            //this is a rez edge attempt
            if (type!="edge"){
                 return;
            }
            if (type=="edge"){
            	// a user touched an edge selector, so rez an edge
            	integer edge=llList2Integer(data, 1);
	            rez_hexagon(edge);
	            //after a user presses an edge selector, hide the selector
	            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "edge expand hide|"+(string)edge, NULL_KEY);
            }
            
        }
    }
    object_rez(key platform) {
    	//a new hex was rezzed, listen to the new hex platform
    		llListen(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "", platform, "");
        	rezzed_hexes+=platform;
        	llGiveInventory(platform, HEXAGON_PLATFORM);
        	debug("giving platform script");
        	llRemoteLoadScriptPin(platform, "platform", PIN, TRUE,0);
        
    }
    listen(integer channel, string name, key id, string message) {
        list data = llParseString2List(message, ["|"], []);
        string command = llList2String(data, 0);
        debug("**************************"+message);
        if (channel==SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST){
        	if (command=="GET QUESTION"){
        		key user_key = llList2Key(data,1);
				debug("received request from "+llKey2Name(id));
            	//llRegionSayTo(id,SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "A question|"+(string)llGetKey());
            	llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER, "", user_key);
        	}
        }
            
    }
}

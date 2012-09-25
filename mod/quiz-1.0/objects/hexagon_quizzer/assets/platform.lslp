
//hexagon platform
float size_x_half=3.0965;
float size_y=5.3662;
list rezzed_hexes;
integer PIN=7961;
integer SLOODLE_CHANNEL_ANIM= -1639277007; 
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE= -1639277008;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
string HEXAGON_PLATFORM="Hexagon Platform";
string HEXAGON_MASTER="Hexagon Quizzer";
integer my_oposite_edge;
key MASTERS_KEY=NULL_KEY; //key of this childs parent
integer master_listener;
debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 
default {
    on_rez(integer start_param) {
         llResetScript();
    }
    state_entry() {
    	master_listener=llListen(SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, HEXAGON_MASTER, "", "");
        llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "GET QUESTION");
    }
   
    listen(integer channel, string name, key id, string message) {
    	if (channel==SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE){
    		list data = llParseString2List(message, ["|"], []);
    		string command = llList2String(data,0);
    		if (MASTERS_KEY==NULL_KEY){
    			MASTERS_KEY= llList2Key(data,1);
    			debug("got masters key: "+(string)MASTERS_KEY);
    			//we now have the master's key, so stop listening to all other keys on the SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE channel
    			//and only listen to the master on this channel from now on.
    			llListenRemove(master_listener);
    			master_listener=llListen(SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "", MASTERS_KEY, "");
    		}else{
    				debug("already have masters key: "+(string)MASTERS_KEY);
    		}
    	
    		
    	}
    }
}

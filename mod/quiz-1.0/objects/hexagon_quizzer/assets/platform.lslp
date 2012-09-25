
//hexagon platform
float size_x_half=3.0965;
float size_y=5.3662;
list rezzed_hexes;
integer PIN=7961;
vector RED =<1.00000, 0.00000, 0.00000>;
vector ORANGE=<1.00000, 0.43763, 0.02414>;
vector YELLOW=<1.00000, 1.00000, 0.00000>;
vector GREEN=<0.00000, 1.00000, 0.00000>;
vector BLUE=<0.00000, 0.00000, 1.00000>;
vector BABYBLUE=<0.00000, 1.00000, 1.00000>;
vector PINK=<1.00000, 0.00000, 1.00000>;
vector PURPLE=<0.57338, 0.25486, 1.00000>;
vector BLACK= <0.00000, 0.00000, 0.00000>;
vector WHITE= <1.00000, 1.00000, 1.00000>;
vector AVCLASSBLUE= <0.06274,0.247058,0.35294>;
vector AVCLASSLIGHTBLUG=<0.8549,0.9372,0.9686>;//#daeff7
integer SLOODLE_CHANNEL_ANIM= -1639277007; 
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE= -1639277008;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
string HEXAGON_PLATFORM="Hexagon Platform";
string HEXAGON_MASTER="Hexagon Quizzer";
integer my_oposite_edge;
key MASTERS_KEY=NULL_KEY; //key of this childs parent
integer master_listener;
integer num_links;
integer question_prim;
debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 
set_question_prim_text(string text,vector color){
	llSetLinkPrimitiveParamsFast(question_prim, [PRIM_TEXT,text,color,1] );
}
default {
    on_rez(integer start_param) {
         llResetScript();
    }
    state_entry() {
    	num_links=llGetNumberOfPrims();
    	integer i;
    	for (i=0;i<num_links;i++){
    		if (llGetLinkName(i)=="question_prim"){
    			question_prim=i;
    			debug("found question prim: "+(string)question_prim);
    		}
    	}
    	set_question_prim_text("Click, to load a question",GREEN);
    	master_listener=llListen(SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, HEXAGON_MASTER, "", "");
      
    }
    link_message(integer sender_num, integer num, string str, key id) {
      	if (num==SLOODLE_CHANNEL_USER_TOUCH){
      		if (str=="QUESTION BUTTON"){
	      		llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "GET QUESTION|"+(string)id);
	      		set_question_prim_text("Loading question...",YELLOW);
      		}
      		
      	}
      	
    }
    listen(integer channel, string name, key id, string message) {
    	if (channel==SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE){
    		list data = llParseString2List(message, ["|"], []);
    		string command = llList2String(data,0);
    		if (MASTERS_KEY==NULL_KEY){
    			MASTERS_KEY= llList2Key(data,1);
    			//we now have the master's key, so stop listening to all other keys on the SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE channel
    			//and only listen to the master on this channel from now on.
    			llListenRemove(master_listener);
    			master_listener=llListen(SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "", MASTERS_KEY, "");
    		}else{
    				
    		}
    	
    		
    	}
    }
}

float size_x_half=3.0965;
float size_y=5.3662;
list rezzed_hexes;
integer PIN=7961;
integer SLOODLE_CHANNEL_ANIM= -1639277007; 
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
integer SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE= -1639277008;
integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER = -1639271116; //mod quiz script is in state CHECK_QUIZ
string HEXAGON_PLATFORM="Hexagon Platform";
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
integer question_prim;
integer num_links;
set_question_prim_text(string text,vector color){
    llSetLinkPrimitiveParamsFast(question_prim, [PRIM_TEXT,text,color,1] );
}
get_question_prim(){
    num_links=llGetNumberOfPrims();
    integer i;
    for (i=0;i<=num_links;i++){
        if (llGetLinkName(i)=="question_prim"){
            question_prim=i;
            debug("found ------------------- question prim:"+(string)question_prim);
        }else{
        	debug("not found ------------------- :"+(string)i);
        }
    }
}
default {
    on_rez(integer start_param){
        llResetScript();
    }
    state_entry() {
        get_question_prim();
        
        set_question_prim_text("Initializing the quiz. Please wait.",YELLOW);
        llTriggerSound("SND_STARTING_UP", 1);
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ){
            state ready;
        }
    }
}
    state ready{
      state_entry() {
            set_question_prim_text("Ready. Click a colored orb",GREEN);
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
                debug("received request from "+llKey2Name(id)+" for user: "+llKey2Name(user_key));
                //llRegionSayTo(id,SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "A question|"+(string)llGetKey());
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER, "", user_key);
            }
        }
            
    }
}

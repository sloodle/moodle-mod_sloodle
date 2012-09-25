
//hexagon platform
debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 
float size_x_half=3.0965;
float size_y=5.3662;
list rezzed_hexes;
integer PIN=7961;
integer SLOODLE_CHANNEL_ANIM= -1639277007; 
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
string HEXAGON_PLATFORM="Hexagon Platform";
integer my_oposite_edge;
default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
    	
        my_oposite_edge=llGetStartParameter();
        llSleep(5);
        llRegionSay(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "GET QUESTION");
        debug("-----My oposite edge is: "+(string)my_oposite_edge);
       
    }
}


//pin
debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 

integer PIN=7961;

default {
	on_rez(integer start_param) {
	    llResetScript();
	}
    state_entry() {
    	llSetRemoteScriptAccessPin(PIN);
       
    }
}

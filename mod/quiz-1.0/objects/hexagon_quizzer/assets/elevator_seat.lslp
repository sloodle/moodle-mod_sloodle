
//elevator seat
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
vector myColor;
rotation myRot;
debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 
sloodle_set_pos(vector targetposition){
    integer counter=0;
    debug("***going to: "+(string)targetposition);
    while ((llVecDist(llGetPos(), targetposition) > 0.001)&&(counter<50)) {
        counter+=1;
        llSetPos(targetposition);
    }
    llUnSit(sitter);

}
integer myZ;
key sitter;
vector myPos;
default {
    on_rez(integer start_param) {
        myPos=llGetPos();
        llSitTarget(<0,0,1.0>, ZERO_ROTATION);
        debug("***mypos: "+(string)myPos);
        if (start_param==1||start_param==-1){
            myColor=YELLOW;
                    
        }else
        if (start_param==2||start_param==-2){
            myColor=PINK;
        
        }else
        if (start_param==3||start_param==-3){
            myColor=BABYBLUE;
        
        }else
        if (start_param==4||start_param==-4){
            myColor=RED;
        
        }else
        if (start_param==5||start_param==-5){
            myColor=BLUE;
        
        }else
        if (start_param==6||start_param==-6){
            myColor=GREEN;
        
        }
        //if a negative start_param was sent, that means we are a down elevator
        if (1*start_param<0){
            myZ=-5;
        }else{
        //if a positive start_param was sent, that means we are an up elevator            
            myZ=5;
        }
        llSetColor(myColor, ALL_SIDES);
    }
    state_entry() {
      llSitTarget(<0,0,1.0>, ZERO_ROTATION);
      myPos=llGetPos();
     
    }
    changed(integer change) {
     	  
             
             sitter = llAvatarOnSitTarget();
         if(change & CHANGED_LINK){
        
            if (sitter!=NULL_KEY){
            	   
                if(llGetPos()==myPos){
                	
                	
                    if (myZ>0){
                        llTriggerSound("SND_POWER_UP", 1);
                    }else{
                        llTriggerSound("SND_POWER_DOWN", 1);
                    }
                    sloodle_set_pos(myPos+<0,0,myZ>);
                    llSetTimerEvent(3);
                }
            }
             
         }
    
    }
    timer() {
        llSetTimerEvent(0);
        sloodle_set_pos(myPos);
    }
}

integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer DELAY;
integer my_num;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 

close(integer p){
    debug("closing "+(string)p);
    if (p==1){
         llSetPrimitiveParams([8, <-0.18301,-0.68301,0.18301,0.68301> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]); 
         llTriggerSound("pop"+(string)my_num, 1);                
    }else
    if (p==2){
        llSetPrimitiveParams([8, <-0.68610,-0.17106,0.68610,0.17106> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);
        llTriggerSound("pop"+(string)my_num, 1);        
    }
    if (p==3){
        llSetPrimitiveParams([8, <-0.49562,-0.50434,0.49562,0.50434> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);
        llTriggerSound("pop"+(string)my_num, 1); 
    
    }else
    if (p==4){
        llSetPrimitiveParams([9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);
        llTriggerSound("pop"+(string)my_num, 1);                 
    }else
    if (p==5){
        llSetPrimitiveParams([8, <-0.68610,-0.17106,0.68610,0.17106> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);  
        llTriggerSound("pop"+(string)my_num, 1);                             
    }else
    if (p==6){
        llSetPrimitiveParams([8, <-0.49562,-0.50434,0.49562,0.50434> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);  
        llTriggerSound("pop"+(string)my_num, 1);                      
    }

}
open(integer p){
    debug("opening "+(string)p);
    if (p==1){
        llSetPrimitiveParams([8, <0.68592,-0.17181,-0.68592,0.17181> / llGetRootRotation(),9,3,0,<0.980000, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);
        llTriggerSound("pop"+(string)my_num, 1);                 
    }else
    if (p==2){
        llSetPrimitiveParams([8, <-0.68610,-0.17106,0.68610,0.17106> / llGetRootRotation(),9,3,0,<0.980000, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);
        llTriggerSound("pop"+(string)my_num, 1);
    }else
    if (p==3){
        llSetPrimitiveParams([8, <-0.49562,-0.50434,0.49562,0.50434> / llGetRootRotation(),9,3,0,<0.980000, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);
        llTriggerSound("pop"+(string)my_num, 1);
    }else
    if (p==4){
        llSetPrimitiveParams([9,3,0,<0.980000, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);
        llTriggerSound("pop"+(string)my_num, 1);
    }else
    if (p==5){
        llSetPrimitiveParams([8, <0.17181,-0.68592,-0.17181,0.68592> / llGetRootRotation(),9,3,0,<0.980000, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]); 
        llTriggerSound("pop"+(string)my_num, 1);
    }else
    if (p==6){
        llSetPrimitiveParams([8, <0.50000,-0.50000,-0.50000,0.50000> / llGetRootRotation(),9,3,0,<0.980000, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);
        llTriggerSound("pop"+(string)my_num, 1);
    }
    
}
default{
    on_rez(integer r){llResetScript();} 

    state_entry() {
        
        my_num = (integer)llGetObjectName();
        open(my_num);
        
    }
    touch_start(integer num_detected) {
        integer j;
        for (j=0;j<num_detected;j++){
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_USER_TOUCH, "edge|"+(string)my_num, llDetectedKey(j));
        }
    }
    link_message(integer s, integer n, string m, key id){
             
        integer stat=llGetStatus(1);
        if (n!=SLOODLE_CHANNEL_ANIM) return;
        list data = llParseString2List(m, ["|"], []);
           string command = llList2String(data, 0);
           
           if (command!="edge expand show"&&command!="edge expand hide") return;
           
           list  edges = llParseString2List(llList2String(data, 1), [","], []);
           integer found = llListFindList(edges, [(string)my_num]);
    debug("command: "+command+" found: "+(string)found+" mynum: "+(string)my_num+" m: "+m); 
           if (found==-1) {
            return;
        }
        if (command=="edge expand show"){
             close(my_num);
        }
        if (command=="edge expand hide"){
              open(my_num);
        }
        if(stat){llSetStatus(1,1);}
    }
   
}
 

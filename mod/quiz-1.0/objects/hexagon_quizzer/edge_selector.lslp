integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer DELAY;
integer my_num;

close(integer p){
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
        close(my_num);
        
    }
    link_message(integer s, integer n, string m, key id){
             
        integer stat=llGetStatus(1);
        if (n!=SLOODLE_CHANNEL_ANIM) return;
        list data = llParseString2List(m, ["|"], []);
   		string command = llList2String(data, 0);
   		 
   		if (command!="edge expand show"&&command!="edge expand hide") return;
   		
   		list  edges = llParseString2List(llList2String(data, 1), [","], []);
   		integer found = llListFindList(edges, [(string)my_num]);
   		if (found==-1) {
            return;
        }
        if (command=="edge expand show"){
             open(my_num);
        }
        if (command=="edge expand hide"){
              close(my_num);
        }
        if(stat){llSetStatus(1,1);}
    }
   
}
 

integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer DELAY;
integer my_num;

close(integer p){
	 llSetTimerEvent(0);
	llTriggerSound("close", 1);
	if (p==0){
		vector Zfire=llGetScale();
		vector zFire=<2.77730,-0.00770,-0.05180>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.97030,0.24192> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);        
    }else
    if (p==1){
		vector Zfire=llGetScale();
		vector zFire=<1.42570,2.36230,-0.07440>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.18311,0.68289,-0.68310,0.18304> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 		        
    }else
    if (p==2){
		vector Zfire=llGetScale();
		vector zFire=<4.10570,2.36340,-0.07440>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.18310,0.68311,-0.68298,-0.18269> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 		        
    }
    if (p==3){
		vector Zfire=llGetScale();
		vector zFire=<5.44710,0.04300,-0.07440>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.50010,0.50001,-0.49989,-0.50001> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 	 
    }else
    if (p==4){
		vector Zfire=llGetScale();
		vector zFire=<4.10750,-2.27860,-0.07440>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.61250,0.35348,0.61232,0.35349> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (p==5){
		vector Zfire=llGetScale();
		vector zFire=<1.42750,-2.27960,-0.07440>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.35370,0.61234,0.35326,0.61248> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);
    }else
    if (p==6){
		vector Zfire=llGetScale();
		vector zFire=<0.08130,0.04020,-0.07440>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.70711,0.0,0.70711> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }

}
open(integer p){
	llTriggerSound("open", 1);
	if (p==0){
		vector Zfire=llGetScale();
		vector zFire=<2.77730,-0.00770,-0.05180>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.97030,0.24192> / llGetRootRotation(),9,3,0,<0.230000, 0.250000, 0.0>,0.949970,<0.0, 0.0, 0.0>,<0.480000, 0.520000, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961,25,3,0.101961,25,4,0.101961,25,5,0.101961]);         
    }else
    if (p==1){
		vector Zfire=llGetScale();
		vector zFire=<0.15818,4.56322,-0.02004>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.25826,-0.96603,0.00904,0.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);		         
    }else
    if (p==2){
		vector Zfire=llGetScale();
		vector zFire=<5.36464,4.54609,-0.01989>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.25862,-0.96594,0.00831,0.00178> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (p==3){
		vector Zfire=llGetScale();
		vector zFire=<8.00394,0.04244,-0.02004>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.70718,0.70703,0.00007,0.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (p==4){
		vector Zfire=llGetScale();
		vector zFire=<5.39636,-4.50922,-0.02004>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.86600,0.49998,0.00756,0.00437> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 		     
    }else
    if (p==5){
		vector Zfire=llGetScale();
		vector zFire=<0.13931,-4.51117,-0.02004>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.50000,0.86603,0.0,0.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (p==6){
		vector Zfire=llGetScale();
		vector zFire=<-2.44546,0.04020,-0.02004>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,-1.0,0.0,0.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }
    llSetTimerEvent(DELAY);
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
   		list  pie_slices = llParseString2List(llList2String(data, 1), [","], []);
   		integer found = llListFindList(pie_slices, [(string)my_num]);
   		DELAY =llList2Integer(data, 2); 
          if (found==-1) {
            return;
        }
        if (command=="open"){
             open(my_num);
        }
        if (command=="close"){
              close(my_num);
        }
        if(stat){llSetStatus(1,1);}
    }
    timer() {
        llSetTimerEvent(0);
        close(my_num);
    }
}
 

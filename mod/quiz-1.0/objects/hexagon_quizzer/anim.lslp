integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer DELAY;
integer my_num;

close(integer p){
	 llSetTimerEvent(0);
	llTriggerSound("close", 1);
    if (p==1){
		vector Zfire=llGetScale();
		vector zFire=<0.09540,2.36231,1.35922>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.35354,0.35345,-0.61250,0.61230> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>]);        
    }else
    if (p==2){
		vector Zfire=llGetScale();
		vector zFire=<0.09540,2.36337,4.03922>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.61241,0.61221,-0.35347,0.35385> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>]);        
    }
    if (p==3){
		vector Zfire=llGetScale();
		vector zFire=<0.09540,0.04298,5.38055>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.70710,0.70712,0.00015,0.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>]); 
    
    }else
    if (p==4){
        vector Zfire=llGetScale();
		vector zFire=<0.09540,-2.27855,4.04102>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.86608,-0.00001,-0.00013,0.49990> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>]);    
    }else
    if (p==5){
		vector Zfire=llGetScale();
		vector zFire=<0.09540,-2.27956,1.36104>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.49990,-0.00010,-0.00031,0.86608> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>]);                
    }else
    if (p==6){
     	vector Zfire=llGetScale();
 	 	vector zFire=<0.09538,0.04023,0.01480>;
	 	vector zfIre=<0.19941,6.19295,5.36619>;
	 	vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
	 	vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
	 	llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.0,1.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>]);          
    }

}
open(integer p){
	llTriggerSound("open", 1);
    if (p==1){
		vector Zfire=llGetScale();
		vector zFire=<2.68034,4.68430,0.01843>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.18908,0.68168,-0.18765,0.68143> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>]);         
    }else
    if (p==2){
		vector Zfire=llGetScale();
		vector zFire=<2.68030,4.42282,5.22885>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.21243,0.69019,0.15296,0.67462> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>]);  
    }else
    if (p==3){
		vector Zfire=llGetScale();
		vector zFire=<2.68030,0.04229,7.89137>;
		vector zfIre=<6.19295,0.19941,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.50866,0.50856,0.49131,0.49117> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>]);       
    }else
    if (p==4){
		vector Zfire=llGetScale();
		vector zFire=<2.68030,-4.47172,5.30817>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.61766,0.35038,-0.60714,0.35653> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>]);     
    }else
    if (p==5){
		vector Zfire=llGetScale();
		vector zFire=<2.67835,-4.45476,0.10533>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <-0.36245,0.59608,-0.34438,0.62827> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>]);
    }else
    if (p==6){
		vector Zfire=llGetScale();
		vector zFire=<2.67788,0.04023,-2.73273>;
		vector zfIre=<0.19941,6.19295,5.36619>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.00008,0.71479,-0.00013,0.69934> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>]);	                 
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
 

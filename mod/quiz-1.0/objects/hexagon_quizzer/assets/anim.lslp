integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer DELAY;
integer my_num;

close(integer p){
    llSetTimerEvent(0);
    llTriggerSound("close", 1);
  if (p==1){
        vector Zfire=llGetScale();
        vector zFire=<2.30604,-1.45804,-0.02260>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.61831,0.34288,-0.34286,-0.61853> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);                  
    }else
    if (p==2){
        vector Zfire=llGetScale();
        vector zFire=<-0.05974,-2.71720,-0.02260>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.70711,-0.01240,0.01204,-0.70689> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);                  
    }else
    if (p==3){
        vector Zfire=llGetScale();
        vector zFire=<-2.33349,-1.29816,-0.02260>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.60614,-0.36428,0.36422,-0.60600> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (p==4){
        vector Zfire=llGetScale();
        vector zFire=<-2.24062,1.38060,-0.02260>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.19480,0.67982,-0.19486,0.67965> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);          
    }else
    if (p==5){
        vector Zfire=llGetScale();
        vector zFire=<0.12521,2.63967,-0.02260>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.50859,0.49134,-0.50883,0.49094> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (p==6){
        vector Zfire=llGetScale();
        vector zFire=<2.40291,1.22341,-0.02260>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.68610,0.17106,-0.68610,0.17106> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);     
    }
}

open(integer p){
    llTriggerSound("open", 1);
    if (p==1){
        vector Zfire=llGetScale();
        vector zFire=<4.49702,-2.82586,-2.59885>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.87457,-0.48489,0.00004,0.00014> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
   
    if (p==2){
        vector Zfire=llGetScale();
        vector zFire=<-0.14661,-5.23544,-2.61083>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.99982,0.01726,0.00028,0.00849> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);    
    }else
    if (p==3){
        vector Zfire=llGetScale();
        vector zFire=<-4.59131,-2.49803,-2.61099>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.85711,-0.51513,0.00002,0.00007> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);     
    }else
    if (p==4){
        vector Zfire=llGetScale();
        vector zFire=<-4.42583,2.74503,-2.61099>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.27562,0.96123,-0.00241,0.00839> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);
    }else
    if (p==5){
        vector Zfire=llGetScale();
        vector zFire=<0.21495,5.21479,-2.61099>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.71934,0.69466,0.0,0.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (p==6){
        vector Zfire=llGetScale();
        vector zFire=<4.63391,2.40965,-2.61099>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.97030,-0.24192,0.0,0.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);
        llSetTimerEvent(DELAY);
    }
}
default{
    on_rez(integer r){llResetScript();} 

    state_entry() {
        
        my_num = (integer)llGetSubString(llGetObjectName(),-1, -1);
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
 

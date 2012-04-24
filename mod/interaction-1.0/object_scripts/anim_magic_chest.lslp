default
{// zFire Xue Prim Animator Generator 5.1 Fastest Web Version.
// Script belongs to Fire Centaur
// This script goes into prim named: Object
on_rez(integer r){llResetScript();} 
link_message(integer s, integer n, string m, key id)
{integer stat=llGetStatus(1);
if (n!=-99)return;
if(m=="p0"){ //zF Animation Frame #0
vector Zfire=llGetScale();
vector zFire=<-0.01074,-0.00003,0.36711>;
vector zfIre=<0.91800,0.67032,1.81060>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.01234,0.70698,-0.70701,0.01258> / llGetRootRotation(),9,1,0,<0.500000, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0]); }

if(m=="p1"){ //zF Animation Frame #1  
vector Zfire=llGetScale(); 
vector zFire=<0.12543,0.00005,0.67592>;
vector zfIre=<0.91800,0.67032,1.81060>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.24763,-0.66231,0.66242,0.24742> / llGetRootRotation(),9,1,0,<0.500000, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0]); }

if(stat){llSetStatus(1,1);}}}
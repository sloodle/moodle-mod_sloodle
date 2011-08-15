default
{// zFire Xue Prim Animator Generator 5.1 Fastest Web Version.
// Script belongs to Fire Centaur
// Licensed under the same license as Sloodle.
// This script goes into prim named: Sloodle Awards System Revision 4
on_rez(integer r){llResetScript();} 
link_message(integer s, integer n, string m, key id)
{integer stat=llGetStatus(1);
if (n!=-99)return;
if(m=="p0"){ //zF Animation Frame #0
vector Zfire=llGetScale();
vector zFire=<0.15671,0.05450,-0.04028>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.70711,0.0,0.0,0.70711> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }

if(m=="p1"){ //zF Animation Frame #1
vector Zfire=llGetScale();
vector zFire=<0.02252,0.05450,3.16541>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.70711,0.0,0.0,0.70711> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }


if(m=="p2"){ //zF Animation Frame #2
vector Zfire=llGetScale();
vector zFire=<3.48306,0.05450,-0.01477>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.70711,0.0,0.0,0.70711> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }


if(m=="p3"){ //zF Animation Frame #3
vector Zfire=llGetScale();
vector zFire=<-0.03548,0.05450,-3.28662>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.70711,0.0,0.0,0.70711> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }


if(m=="p4"){ //zF Animation Frame #4
vector Zfire=llGetScale();
vector zFire=<-3.52482,0.05450,0.02893>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.70711,0.0,0.0,0.70711> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }


if(m=="p11"){ //zF Animation Frame #11
vector Zfire=llGetScale();
vector zFire=<0.02252,-0.49185,3.01306>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.83867,0.0,0.0,0.54464> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }


if(m=="p22"){ //zF Animation Frame #22
vector Zfire=llGetScale();
vector zFire=<3.13603,-0.82437,-0.01477>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.66857,-0.23024,-0.23024,0.66857> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }


if(m=="p33"){ //zF Animation Frame #33
vector Zfire=llGetScale();
vector zFire=<-0.03548,-0.63159,-3.00110>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.50754,0.0,0.0,0.86163> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }


if(m=="p44"){ //zF Animation Frame #44
vector Zfire=llGetScale();
vector zFire=<-2.98730,-1.04871,-0.01477>;
vector zfIre=<2.80000,2.80000,0.01000>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.64088,0.29879,0.29879,0.64088> / llGetRootRotation(),25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }

if(stat){llSetStatus(1,1);}}}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/scoreboard-1.0/sloodle_admin_animation.lsl

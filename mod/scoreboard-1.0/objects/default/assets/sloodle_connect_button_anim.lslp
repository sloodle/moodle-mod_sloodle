//
// The line above should be left blank to avoid script errors in OpenSim.

default
{// zFire Xue Prim Animator Generator 5.1 Fastest Web Version.
// Script belongs to Fire Centaur
// This script goes into prim named: CONNECT HUD
on_rez(integer r){llResetScript();} 
link_message(integer s, integer n, string m, key id)
{integer stat=llGetStatus(1);

if(m=="p12"){ //zF Animation Frame #12
vector r=<0.32424,0.06091,0.19606>;
llSetScale(r);
vector Zfire=llGetScale();
vector zFire=<0.34291,-0.12018,1.33655>;
vector zfIre=<0.32424,0.06091,0.19606>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.00223,1.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,18,0,<0.239216, 0.239216, 0.239216>,1.000000,18,1,<1.0, 1.0, 1.0>,1.000000,18,2,<0.239216, 0.239216, 0.239216>,1.000000,18,3,<0.239216, 0.239216, 0.239216>,1.000000,18,4,<0.239216, 0.239216, 0.239216>,1.000000,18,5,<0.239216, 0.239216, 0.239216>,1.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }

if(m=="p13"){ //zF Animation Frame #13
vector r=<0.32424,0.06091,0.19606>;
llSetScale(r);
vector Zfire=llGetScale();
vector zFire=<0.34291,-0.04047,1.33655>;
vector zfIre=<0.32424,0.06091,0.19606>;
vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.00223,1.0> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,18,0,<0.239216, 0.239216, 0.239216>,1.000000,18,1,<1.0, 1.0, 1.0>,1.000000,18,2,<0.239216, 0.239216, 0.239216>,1.000000,18,3,<0.239216, 0.239216, 0.239216>,1.000000,18,4,<0.239216, 0.239216, 0.239216>,1.000000,18,5,<0.239216, 0.239216, 0.239216>,1.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); }

if(stat){llSetStatus(1,1);}}}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/scoreboard-1.0/objects/default/assets/sloodle_connect_button_anim.lslp 

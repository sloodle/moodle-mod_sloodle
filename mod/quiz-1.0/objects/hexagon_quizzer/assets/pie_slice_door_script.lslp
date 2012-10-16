//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*  Part of the Sloodle project (www.sloodle.org)
*
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
*  -------------------------------------------
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  All scripts must maintain this copyrite information, including the contributer information listed
*
*  Contributors:
*  Paul Preibisch
*
*  DESCRIPTION
*  anim.lslp is an animation script for the pie_slices of the hexagon.  The Close function will make the pie slices rotate to a horizontal positon
*  so the avatars can stand on a full hexagon.
*  This script lists for a linked message in the format: 0,0,0,0,0,1,0
*  where 0 = incorrect, 1 = correct.
*  Each pieslice will look at the index in this list that matches their index, and if 0, perform the open animation, if 1 perform close animation
*
*/

integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer DELAY;
integer my_num;

close(integer pie_slice){
    llSetTimerEvent(0);
    llTriggerSound("close", 1);
      if (pie_slice==1){
          
        vector Zfire=llGetScale();
        vector zFire=<2.30604,-1.45806,-0.02260>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.61831,-0.34288,0.34286,0.61853> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);                         
      }else
      if (pie_slice==2){
        vector Zfire=llGetScale();
        vector zFire=<-0.05974,-2.71724,-0.02260>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.70711,0.01240,-0.01204,0.70689> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);           
      }else
    if (pie_slice==3){
        vector Zfire=llGetScale();
        vector zFire=<-2.33349,-1.29818,-0.02260>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.60614,0.36428,-0.36422,0.60600> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);
    }else
    if (pie_slice==4){
        vector Zfire=llGetScale();
        vector zFire=<-2.24065,1.38060,-0.02260>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.19480,0.67982,-0.19486,0.67965> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (pie_slice==5){
        vector Zfire=llGetScale();
        vector zFire=<0.12521,2.63967,-0.02260>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.50859,0.49134,-0.50883,0.49094> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);         
    }else
    if (pie_slice==6){
        vector Zfire=llGetScale();
        vector zFire=<2.40295,1.22341,-0.02260>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.68610,0.17106,-0.68610,0.17106> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);         
    }
}

open(integer pie_slice){
    llTriggerSound("open", 1);
    if (pie_slice==1){
        
        vector Zfire=llGetScale();
        vector zFire=<5.03571,-3.13984,-2.54680>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.86808,0.48128,0.05911,0.10642> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else   
    if (pie_slice==2){
        vector Zfire=llGetScale();
        vector zFire=<-0.15295,-6.09687,-2.53812>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.98887,-0.01706,0.00241,0.14779> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);         
    }else
    if (pie_slice==3){
        vector Zfire=llGetScale();
        vector zFire=<-5.68454,-3.10747,-2.34772>;
        vector zfIre=<6.19295,0.19941,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.83406,-0.50130,-0.11855,0.19743> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]); 
    }else
    if (pie_slice==4){
        vector Zfire=llGetScale();
        vector zFire=<-5.53202,3.52431,-2.31256>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.26616,-0.92850,-0.07125,0.24893> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);         
    }else
    if (pie_slice==5){
        vector Zfire=llGetScale();
        vector zFire=<0.23875,6.63274,-2.27363>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.69331,-0.66923,-0.19207,0.18588> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);        
    }else
    if (pie_slice==6){
        vector Zfire=llGetScale();
        vector zFire=<5.74368,2.98785,-2.36991>;
        vector zfIre=<0.19941,6.19295,5.36619>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <-0.94544,-0.23569,-0.21825,0.05438> / llGetRootRotation(),9,0,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.0, 0.0>,<0.0, 0.0, 0.0>,23,0,<0.000000, 0.000000, 0.000000>,0.000000,0.000000,0.000000,25,0,0.0,25,1,0.0,25,2,0.0,25,3,0.0,25,4,0.0,25,5,0.0]);         
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
        //6 integers will be broadcase on the SLOODLE_CHANNEL_ANIM channel ie: 0,1,0,0,0,0
        //0 indicates the pie_slice represents a false answer, and should open, 1 indicates correct, and should stay closed
        list data = llParseString2List(m, ["|"], []);
        string command = llList2String(data,0);
        if (command!="pie_slice"){
            return;
        }
        list  pie_slice_grades = llParseString2List(llList2String(data,1), [","], []);
        integer my_grade=llList2Integer(pie_slice_grades,my_num-1);
        if (my_grade<=0){
            open(my_num);
        }else{
             close(my_num);
        }
        llSetTimerEvent(7);
        if(stat){llSetStatus(1,1);}
    }
    timer() {
        llSetTimerEvent(0);
        close(my_num);
    }
}
 

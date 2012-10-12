

/* edge selector.lslp
*
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
*  As mentioned, this script has been  licensed under GPL 3.0
*  Basically, that means, you are free to use the script, commercially etc, but if you include
*  it in your objects, you must make the source viewable to the person you are distributuing it to -
*  ie: it can not be closed source - GPL 3.0 means - you must make it open!
*  This is so that others can modify it and contribute back to the community.
*  The SLOODLE github can be found here: https://github.com/sloodle
*
*  Enjoy!
*
*  Contributors:
*   Paul Preibisch
*
*  DESCRIPTION
*  The main purpose of this script is to power a spherical prim that sits on the edge of a hexagon quizzer's pie slice.  A user can request that a 
*  new hexagon be joined to this edge (hence the name edge_selector) by clicking on the orb.
*  When the orb is touched, this script will send a linked message to the hexagon rezzer script telling it who touched
*  it.  It will also set the prims properties so that the orb reshapes itself small enough to be hidden (close) when needed.
*
 
*/

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

show(integer orb){
    debug("showing "+(string)orb);
    if (orb==0){
        vector Zfire=llGetScale();
        vector zFire=<4.54343,-2.85621,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.87462,0.48481> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]); 
    }else
    if (orb==1){
        vector Zfire=llGetScale();
        vector zFire=<4.54343,-2.85621,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.87462,0.48481> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);    }else
    if (orb==2){
        vector Zfire=llGetScale();
        vector zFire=<-0.14007,-5.34330,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.0,1.0> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);    }else
    if (orb==3){
		vector Zfire=llGetScale();
		vector zFire=<-4.72358,-2.45155,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.52250,0.85264> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);
    }else
    if (orb==4){
        vector Zfire=llGetScale();
        vector zFire=<-4.49461,2.79145,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.87462,0.48481> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]); 
    }else
    if (orb==5){
        vector Zfire=llGetScale();
        vector zFire=<0.08851,5.29755,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.0,1.0> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);        
    }else
    if (orb==6){
        vector Zfire=llGetScale();
        vector zFire=<4.77234,2.38687,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.52250,0.85264> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);         
    }

}
hide(integer orb){
    debug("opening "+(string)orb);
    if (orb==0){
        vector Zfire=llGetScale();
        vector zFire=<4.54343,-2.85621,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.87462,0.48481> / llGetRootRotation(),9,3,0,<0.725000, 0.750000, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);                   
    }else
    if (orb==1){
        vector Zfire=llGetScale();
        vector zFire=<4.54343,-2.85621,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.87462,0.48481> / llGetRootRotation(),9,3,0,<0.725000, 0.750000, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);     
    } else
    if (orb==2){
        vector Zfire=llGetScale();
        vector zFire=<-0.14006,-5.34330,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.06972,0.00182,-0.02614,0.99722> / llGetRootRotation(),9,3,0,<0.705000, 0.725000, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);     
    }else
    if (orb==3){
		vector Zfire=llGetScale();
		vector zFire=<-4.72358,-2.45155,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.04681,-0.07352,-0.50564,0.85833> / llGetRootRotation(),9,3,0,<0.700000, 0.750000, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]); 
    }else
    if (orb==4){
        vector Zfire=llGetScale();
        vector zFire=<-4.49461,2.79145,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.05488,-0.09901,-0.86899,0.48170> / llGetRootRotation(),9,3,0,<0.700000, 0.725000, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);
    } else
    if (orb==5){
        vector Zfire=llGetScale();
        vector zFire=<0.08852,5.29755,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.01745,0.99985> / llGetRootRotation(),9,3,0,<0.730000, 0.775000, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]);
    }else 
    if (orb==6){
        vector Zfire=llGetScale();
        vector zFire=<4.77234,2.38687,0.00000>;
        vector zfIre=<1.26456,1.26456,1.26456>;
        vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
        vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
        llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.52250,0.85264> / llGetRootRotation(),9,3,0,<0.730000, 0.775000, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961]); 
    }
    
}
default{
    on_rez(integer r){llResetScript();} 

    state_entry() {
        string name = llGetObjectName();
        my_num = (integer)llGetSubString(name, -1, -1);
        show(my_num);
        
    }
    touch_start(integer num_detected) {
        integer j;
        for (j=0;j<num_detected;j++){
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_USER_TOUCH, "orb|"+(string)my_num, llDetectedKey(j));
            debug("orb|"+(string)my_num);
        }
    }
    link_message(integer s, integer n, string m, key id){
             
        integer stat=llGetStatus(1);
        if (n!=SLOODLE_CHANNEL_ANIM) return;
        list data = llParseString2List(m, ["|"], []);
           string command = llList2String(data, 0);
           
           if (command!="orb show"&&command!="orb hide") return;
           
           list  orbs = llParseString2List(llList2String(data, 1), [","], []);
           integer found = llListFindList(orbs, [(string)my_num]);
    debug("command: "+command+" found: "+(string)found+" mynum: "+(string)my_num+" m: "+m); 
           if (found==-1) {
               return;
           }
           if (command=="orb show"){
                   show(my_num);
           }
           if (command=="orb hide"){
                  hide(my_num);
           }
           if(stat){llSetStatus(1,1);}
    }
   
}
 

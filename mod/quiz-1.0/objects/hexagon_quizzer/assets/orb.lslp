

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

close(integer p){
    debug("closing "+(string)p);
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
		vector zFire=<4.54343,-2.85621,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.87462,0.48481> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]);                        
    }else
    if (p==2){
		vector Zfire=llGetScale();
		vector zFire=<-0.14007,-5.34330,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.0,1.0> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961]); 
    }
    if (p==3){
		vector Zfire=llGetScale();
		vector zFire=<-4.72358,-2.45155,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.52250,0.85264> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]); 
    }else
    if (p==4){
		vector Zfire=llGetScale();
		vector zFire=<-4.49462,2.79145,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.87462,0.48481> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]); 
    }else
    if (p==5){
		vector Zfire=llGetScale();
		vector zFire=<0.08851,5.29755,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.0,1.0> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961]); 
    }else
    if (p==6){
		vector Zfire=llGetScale();
		vector zFire=<4.77234,2.38687,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.52250,0.85264> / llGetRootRotation(),9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,23,1,<0.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961]); 
    }

}
open(integer p){
    debug("opening "+(string)p);
    if (p==0){
		          
    }else
    if (p==1){
	vector Zfire=llGetScale();
		vector zFire=<4.98021,-3.12915,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,-0.87462,0.48481> / llGetRootRotation(),9,3,0,<0.505000, 0.525000, 0.0>,0.950000,<0.0, 0.0, 0.0>,<0.459960, 0.520000, 0.0>,23,1,<1.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961,25,3,0.101961,25,4,0.101961,25,5,0.101961]);                       
    } else
    if (p==2){
		vector Zfire=llGetScale();
		vector zFire=<-0.14007,-5.78597,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.0,1.0> / llGetRootRotation(),9,3,0,<0.980000, 1.0, 0.0>,0.949970,<0.0, 0.0, 0.0>,<0.459960, 0.520000, 0.0>,23,1,<1.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961,25,3,0.101961,25,4,0.101961,25,5,0.101961]); 	     
    }else
    if (p==3){
		vector Zfire=llGetScale();
		vector zFire=<-5.14255,-2.66503,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.36583,0.62116,-0.36215,0.59091> / llGetRootRotation(),9,3,0,<0.980000, 1.0, 0.0>,0.949970,<0.0, 0.0, 0.0>,<0.499990, 0.520000, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961,25,3,0.101961,25,4,0.101961,25,5,0.101961]); 		 
	}else
    if (p==4){
		vector Zfire=llGetScale();
		vector zFire=<-4.91237,3.05250,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.61845,0.34281,-0.61845,0.34281> / llGetRootRotation(),9,3,0,<0.980000, 1.0, 0.0>,0.949970,<0.0, 0.0, 0.0>,<0.459990, 0.480000, 0.0>,23,1,<1.000000, 0.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961,25,3,0.101961,25,4,0.101961,25,5,0.101961]);	}else
    if (p==5){
		vector Zfire=llGetScale();
		vector zFire=<0.08850,5.80453,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.0,0.0,0.0,1.0> / llGetRootRotation(),9,3,0,<0.505000, 0.525000, 0.0>,0.949970,<0.0, 0.0, 0.0>,<0.459980, 0.520000, 0.0>,23,1,<0.000000, 0.000000, 1.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961,25,3,0.101961,25,4,0.101961,25,5,0.101961]);     }else
    if (p==6){
		vector Zfire=llGetScale();
		vector zFire=<4.98710,2.41001,0.00000>;
		vector zfIre=<1.26456,1.26456,1.26456>;
		vector zfiRe=< zFire.x/zfIre.x,zFire.y/zfIre.y,zFire.z/zfIre.z>;
		vector zfirE=< Zfire.x*zfiRe.x,Zfire.y*zfiRe.y,Zfire.z*zfiRe.z>;
		llSetPrimitiveParams([6, zfirE,8, <0.35413,0.60129,-0.37424,0.61072> / llGetRootRotation(),9,3,0,<0.505000, 0.525000, 0.0>,0.949970,<0.0, 0.0, 0.0>,<0.459990, 0.480000, 0.0>,23,1,<0.000000, 1.000000, 0.000000>,1.000000,10.100000,0.000000,25,0,0.101961,25,1,0.101961,25,2,0.101961,25,3,0.101961,25,4,0.101961,25,5,0.101961]); 	}
    
}
default{
    on_rez(integer r){llResetScript();} 

    state_entry() {
        string name = llGetObjectName();
        my_num = (integer)llGetSubString(name, -1, -1);
        close(my_num);
        
    }
    touch_start(integer num_detected) {
        integer j;
        for (j=0;j<num_detected;j++){
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_USER_TOUCH, "edge|"+(string)my_num, llDetectedKey(j));
            debug("edge|"+(string)my_num);
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
 



/* orb.lslp
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
key root_key;
string  my_state;
float edge_length;
float tip_to_edge;
float sensor_range;
integer SLOODLE_OBSTRUCTION=1639277021;
integer OBSTRUCTED=FALSE;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 

show(integer orb){
    my_state="show";
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
    my_state="hide";
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
    llSetText("", <0,0,0>, 1);
    
}

/*
Search through all linked prims, and returns the prims link number which matches the name
*/
integer get_prim(string name){
    integer num_links=llGetNumberOfPrims();
    integer i;
    integer prim=-1;
    for (i=0;i<=num_links;i++){
        if (llGetLinkName(i)==name){
            prim=i;
        }else{
        }
    }
    return prim;
}
default{
    on_rez(integer r){llResetScript();} 

    state_entry() {
    	llListen(SLOODLE_OBSTRUCTION, "", "", "CHECK OBSTRUCTED");
        string name = llGetObjectName();
        my_num = (integer)llGetSubString(name, -1, -1);
        hide(my_num);
        //determine the edge length
            integer pie_slice6 = get_prim("pie_slice6");
            list pie_slice_data = llGetLinkPrimitiveParams(pie_slice6, [PRIM_SIZE] );
            vector pie_slice_size=llList2Vector(pie_slice_data, 0);
            tip_to_edge = pie_slice_size.z+2;//since we are looking for the length starting from the tip of the pie_slice to the middle of the edge, we need to choose the z dimension for this particular pie slice
            edge_length= pie_slice_size.y;//since we are looking for  the length of an edge we need to choose the y dimension for this particular pie slice
            sensor_range=tip_to_edge;
    }
    touch_start(integer num_detected) {
         integer j;
         if (my_state=="show"){
        	for (j=0;j<num_detected;j++){
            	llMessageLinked(LINK_SET, SLOODLE_CHANNEL_USER_TOUCH, "orb|"+(string)my_num, llDetectedKey(j));
             	//debug("sending touch event");
        	} 
         }else{
         	sloodle_translation_request (SLOODLE_TRANSLATE_DIALOG, [1 , "Ok"], "not_allowed_to_click" , ["Ok"], id , "hex_quizzer");
         }
        
    }
    listen(integer channel, string name, key id, string message) {
     		list prim_data = llGetLinkPrimitiveParams( LINK_ROOT, [PRIM_NAME]);
            string root_name=llList2String(prim_data,0);
            root_key = llGetLinkKey( LINK_ROOT );
            debug("root name is: "+root_name+" my range is: "+(string)sensor_range);
            llSensor(root_name, "", SCRIPTED, sensor_range, TWO_PI);
    }
    link_message(integer s, integer n, string m, key id){
             
        integer stat=llGetStatus(1);
        if (n!=SLOODLE_CHANNEL_ANIM) return;
        list data = llParseString2List(m, ["|"], []);
           string command = llList2String(data, 0);
          //   debug("command:"+command);
           if (command!="orb show"&&command!="orb hide") return;
           
           list  orbs = llParseString2List(llList2String(data, 1), [","], []);
       //    debug("orbs:"+llList2CSV(orbs));
      //     debug("my_num:"+(string)my_num);
           integer ismyorb = llListFindList(orbs, [(string)my_num]);
     	//	debug("ismyorb:"+(string)ismyorb);
           if (ismyorb==-1) {
               return;
           }
           llWhisper(SLOODLE_OBSTRUCTION, "CHECK OBSTRUCTED");
           if (command=="orb show"){
           				
                       //do a sensor to first see if another hex is within the vincinity, in which case, dont rez orb otherwise it will overlap
                       //search for a scripted object the same name as me 
                        list prim_data = llGetLinkPrimitiveParams( LINK_ROOT, [PRIM_NAME]);
                        string root_name=llList2String(prim_data,0);
                        root_key = llGetLinkKey( LINK_ROOT );
                        debug("root name is: "+root_name+" my range is: "+(string)sensor_range);
                       llSensor(root_name, "", SCRIPTED, sensor_range, TWO_PI);
                   
           }
           if (command=="orb hide"){
                  hide(my_num);
           }
           
         }
         sensor(integer num_detected) {
             integer k;
             for (k=0;k<num_detected;k++){
                 if (llDetectedKey(k)!=root_key){
                     hide(my_num);
                     OBSTRUCTED=TRUE;
                  //   debug("hex found!");
                 }else{
                 	if (!OBSTRUCTED){
                 		//only detected my root
                 		show(my_num);
                 	}
                    
                 }
                     
             }
           
             
         }
         no_sensor() {
          //   debug("no hex found!");
             show(my_num);
         }
    
}
 
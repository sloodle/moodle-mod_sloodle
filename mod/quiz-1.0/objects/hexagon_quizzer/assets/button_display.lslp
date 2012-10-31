

/* button_display.lslp
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
*  The main purpose of this script is to power a button prim that sits on the edge of a hexagon quizzer's pie slice.  A user can request that a 
*  new hexagon be joined to this edge by clicking on the horizontal rod, or vertical rod
*  When the horizontal rod or vertical rod is touched, this script will send a linked message to the hexagon rezzer script telling
*  it who touched
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
string SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM= "hovertext_linked_prim"; // 3 output parameters: colour <r,g,b>,  alpha value, link number
string SLOODLE_TRANSLATE_HOVER_TEXT = "hovertext";          // 2 output parameters: colour <r,g,b>, and alpha value
string SLOODLE_TRANSLATE_WHISPER = "whisper";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_SAY = "say";               // 1 output parameter: chat channel number
string SLOODLE_TRANSLATE_OWNER_SAY = "ownersay";    // No output parameters
string SLOODLE_TRANSLATE_DIALOG = "dialog";         // Recipient avatar should be identified in link message keyval. At least 2 output parameters: first the channel number for the dialog, and then 1 to 12 button label strings.
string SLOODLE_TRANSLATE_LOAD_URL = "loadurl";      // Recipient avatar should be identified in link message keyval. 1 output parameter giving URL to load.
string SLOODLE_TRANSLATE_IM = "instantmessage";     // Recipient avatar should be identified in link message keyval. No output parameters.
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
debug (string message ){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 
// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}
hide(integer orb){
    my_state="hide";
    debug("*******************************************************hiding");
    if (myType=="orb"){
    	llSetPrimitiveParams([9,3,0,<0.730000, 0.750000, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>]);
    }else
    if (myType=="rod_hor"){
    	llSetPrimitiveParams([9,4,0,<0.505000, 0.525000, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.500000, 0.0>,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,1.0,0.0,0.0]);
    }else
    if (myType=="rod_ver"){
    	llSetPrimitiveParams([9,4,0,<0.505000, 0.525000, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.500000, 0.0>,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,1.0,0.0,0.0]);
    } 
    llSetText("", <0,0,0>, 1);
}
show(integer orb){
    my_state="show";
    debug("*******************************************************showing");
	if (myType=="orb"){
    	 llSetPrimitiveParams([9,3,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>]);
    }else
    if (myType=="rod_hor"){
    	llSetPrimitiveParams([9,4,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.500000, 0.0>,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,1.0,0.0,0.0]);
    }else
    if (myType=="rod_ver"){
    	llSetPrimitiveParams([9,4,0,<0.0, 1.0, 0.0>,0.0,<0.0, 0.0, 0.0>,<1.0, 0.500000, 0.0>,<0.0, 0.0, 0.0>,<0.0, 1.0, 0.0>,<0.0, 0.0, 0.0>,1.0,0.0,0.0]);
    }   
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
list myFamily;
string myType;
init(){
	//determine the edge length
        integer pie_slice6 = get_prim("pie_slice6");
        list pie_slice_data = llGetLinkPrimitiveParams(pie_slice6, [PRIM_SIZE] );
        vector pie_slice_size=llList2Vector(pie_slice_data, 0);
        tip_to_edge = pie_slice_size.z+2;//since we are looking for the length starting from the tip of the pie_slice to the middle of the edge, we need to choose the z dimension for this particular pie slice
        edge_length= pie_slice_size.y;//since we are looking for  the length of an edge we need to choose the y dimension for this particular pie slice
		sensor_range=tip_to_edge;
		myType = llGetSubString(llGetObjectName(), 0, -2);
		string name = llGetObjectName();
        integer len = llGetNumberOfPrims();
        integer k=0;
        for (k=0;k<len;k++){
            myFamily+=llGetLinkKey(k);
        }
        my_num = (integer)llGetSubString(name, -1, -1);
}
default{
    on_rez(integer r){llResetScript();} 

    state_entry() {
    	init();
        llListen(SLOODLE_OBSTRUCTION, "", "", "CHECK OBSTRUCTED");
        hide(my_num);
        
    }
    touch_start(integer num_detected) {
         integer j;
         for (j=0;j<num_detected;j++){
         	vector touch_pos= llDetectedTouchPos(j);
         	vector my_pos = llGetPos();
            if (my_state=="show"){         
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_USER_TOUCH, myType+"|"+(string)my_num+"|"+(string)touch_pos+"|"+(string)my_pos, llDetectedKey(j));
                 //debug("sending touch event");
            }else{
             sloodle_translation_request (SLOODLE_TRANSLATE_DIALOG, [1 , "Ok"], "not_allowed_to_click" , ["Ok"], llDetectedKey(j) , "hex_quizzer");
            }
        }
        
    }
    listen(integer channel, string name, key id, string message) {
            list prim_data = llGetLinkPrimitiveParams( LINK_ROOT, [PRIM_NAME]);
            string root_name=llList2String(prim_data,0);
            root_key = llGetLinkKey( LINK_ROOT );
            if (llGetSubString(name, 0, -2)!=myType){
            	debug("heard that "+name+" was rezzed but it is not a "+myType+", returning");
            	
            return;
            }
            debug("heard a whisper that "+name+" is near me, going to fire off a sensor event to detect if it is one of my family");
            llSensor(root_name, "", SCRIPTED, sensor_range, TWO_PI);
    }
    link_message(integer s, integer n, string m, key id){
             
        integer stat=llGetStatus(1);
        if (n!=SLOODLE_CHANNEL_ANIM) return;
        debug("------------------------------------"+m);
        list data = llParseString2List(m, ["|"], []);
           string command = llList2String(data, 0);
          //   debug("command:"+command);
           if (command!="show user buttons"&&command!="hide user buttons") return;
           list  objects_to_show = llParseString2List(llList2String(data, 1), [","], []);
           integer ismynum = llListFindList(objects_to_show, [(string)my_num]);
           if (ismynum==-1) {
               return;
           }
         
           if (command=="show user buttons"){
               debug("-----------received show user buttons ");
                   
                       llWhisper(SLOODLE_OBSTRUCTION, "CHECK OBSTRUCTED");   
                       //do a sensor to first see if another hex is within the vincinity, in which case, dont rez orb otherwise it will overlap
                       //search for a scripted object the same name as me 
                        list prim_data = llGetLinkPrimitiveParams( LINK_ROOT, [PRIM_NAME]);
                        string root_name=llList2String(prim_data,0);
                        root_key = llGetLinkKey( LINK_ROOT );
                        llSensor(root_name, "", SCRIPTED, sensor_range, TWO_PI);
                   
           }
           if (command=="hide user buttons"){
                  hide(my_num);
           }
           
         }
         sensor(integer num_detected) {
             integer k;
             for (k=0;k<num_detected;k++){
                 //if detected keys are orbs in the same linkset, ignore
                 
                 if (llListFindList(myFamily,[llDetectedKey(k)])!=-1){
                 	//its in the list so my family
                     show(my_num);
                     OBSTRUCTED=TRUE;
                     debug("im a sensor, and heard that "+llDetectedName(k)+" has been rezzed around me, and it is of my family, I am going to show");
                 }else{
                         //only detected my root
                          debug("im a sensor, and heard that "+llDetectedName(k)+" has been rezzed around me, and it is NOT a family member so hiding so  dont overlap!");
                         hide(my_num);
                }
             }
         }
         no_sensor() {
          //   debug("no hex found!");
             show(my_num);
         }
    
}
 
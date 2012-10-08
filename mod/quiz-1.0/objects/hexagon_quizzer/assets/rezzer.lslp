float edge_length;
float edge_length_half;
float tip_to_edge;
list rezzed_hexes;
integer PIN=7961;
integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer SLOODLE_SET_TEXTURE= -1639277010; 
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
integer SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE= -1639277008;
integer SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ = -1639271109;
integer SLOODLE_CHANNEL_TRANSLATION_REQUEST = -1928374651;
integer SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR = -1639271105; //Sent by main quiz script to tell UI scripts that question has been asked to avatar with key. String contains question ID + "|" + question text
integer SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER = -1639271116; //mod quiz script is in state CHECK_QUIZ
integer SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM= -1639277009; // 3 output parameters: colour <r,g,b>,  alpha value, link number
string HEXAGON_PLATFORM="Hexagon Platform";
vector RED =<1.00000, 0.00000, 0.00000>;
vector ORANGE=<1.00000, 0.43763, 0.02414>;
vector YELLOW=<1.00000, 1.00000, 0.00000>;
vector GREEN=<0.00000, 1.00000, 0.00000>;
vector BLUE=<0.00000, 0.00000, 1.00000>;
vector BABYBLUE=<0.00000, 1.00000, 1.00000>; 
vector PINK=<1.00000, 0.00000, 1.00000>;
vector PURPLE=<0.57338, 0.25486, 1.00000>;
vector BLACK= <0.00000, 0.00000, 0.00000>;
vector WHITE= <1.00000, 1.00000, 1.00000>;
vector AVCLASSBLUE= <0.06274,0.247058,0.35294>;
vector AVCLASSLIGHTBLUG=<0.8549,0.9372,0.9686>;//#daeff7
list MY_SLICES;
integer already_received_question=FALSE;
integer my_start_param;

vector get_my_coord(){
    integer center_orb= get_prim("orb0");
    list center_orb_data = llGetLinkPrimitiveParams(center_orb, [PRIM_POSITION] );
    vector my_coord = llList2Vector(center_orb_data,0);
    return my_coord;
        
}
debug (string message ){
     list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
     if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 

rez_hexagon(integer edge){
     integer my_oposite_section;
     vector my_coord= llGetPos();//get_my_coord();
     if (edge==0){
         return;
     }
     vector child_coord=my_coord;
     integer DIVISER=1;
     if (edge==1){//yellow
        child_coord.y=my_coord.y+edge_length+edge_length/2;  
        child_coord.x=my_coord.x-tip_to_edge;
        my_oposite_section=4;                              
     }else
     if (edge==2){//pink
       child_coord.y=my_coord.y+edge_length+edge_length/2;  
       child_coord.x=my_coord.x+tip_to_edge;
        my_oposite_section=5;
     }else
     if (edge==3){
        child_coord.y=my_coord.y;  
        child_coord.x=my_coord.x+2*tip_to_edge; 
        my_oposite_section=6;
     }else
     if (edge==4){
        child_coord.y=my_coord.y-edge_length-edge_length/2;  
        child_coord.x=my_coord.x+tip_to_edge; 
        my_oposite_section=1;
     }else 
     if (edge==5){
        child_coord.y=my_coord.y-edge_length-edge_length/2;  
        child_coord.x=my_coord.x-tip_to_edge; 
        my_oposite_section=2;
     }else
     if (edge==6){
        child_coord.y=my_coord.y;  
        child_coord.x=my_coord.x-2*tip_to_edge; 
        my_oposite_section=3;
     }
    //rez a new hexagon, and pass my_oppsosite_section as the start_parameter so that the new hexagon wont rez on that the my_oposite_section edge
    llRezAtRoot(HEXAGON_PLATFORM, child_coord, ZERO_VECTOR,  llGetRot(), my_oposite_section);
}
string get_detected_pie_slice(vector avatar){
    //returns name of pie_slice
    integer i;
    float closest_orb_distance=100.0;
    string  name_of_closest_orb="";
    integer closest_orb_link_number;

    for (i=1;i<=6;i++){
        integer orb_link_number = get_prim("orb"+(string)i);
        list orb_data=llGetLinkPrimitiveParams(orb_link_number, [PRIM_POSITION]);
        
        vector pos = llList2Vector(orb_data, 0);
        float detected_distance_from_avatar_to_orb = llVecDist(pos, avatar);
        if (detected_distance_from_avatar_to_orb<closest_orb_distance){
            closest_orb_distance = detected_distance_from_avatar_to_orb;
            name_of_closest_orb="orb"+(string)i;
        }
    }
    
    return name_of_closest_orb;
}

set_texture_pie_slices(string texture){
            //clear the rest of the prims
            integer j;
            for (j=1;j<=6;j++){
                integer face=4;
                if (j==1||j==2||j==3){
                    face = 1;
                }
                llMessageLinked(LINK_SET, SLOODLE_SET_TEXTURE, "pie_slice"+(string)j+"|"+(string)face+"|"+texture,NULL_KEY);
            }

} 
set_texture_pie_slice(string texture,integer pie_slice){
            //clear the rest of the prims
            integer face=4;
            if (pie_slice==1||pie_slice==2||pie_slice==3){
                face = 1;
            }
            
            debug("sending message on "+(string)SLOODLE_SET_TEXTURE+" "+ "pie_slice"+llStringTrim((string)pie_slice,STRING_TRIM)+"|"+(string)face+"|"+llStringTrim(texture,STRING_TRIM));
            llMessageLinked(LINK_SET, SLOODLE_SET_TEXTURE, "pie_slice"+llStringTrim((string)pie_slice,STRING_TRIM)+"|"+(string)face+"|"+llStringTrim(texture,STRING_TRIM),NULL_KEY);
            

}
integer question_prim;
integer num_links;
set_prim_text(integer prim,string text,vector color){
    llSetLinkPrimitiveParamsFast(prim, [PRIM_TEXT,text,color,1] );
}
/*
Search through all linked prims, and returns the prims link number which matches the name
*/
integer get_prim(string name){
    num_links=llGetNumberOfPrims();
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
// Send a translation request link message
sloodle_translation_request(string output_method, list output_params, string string_name, list string_params, key keyval, string batch){
    llMessageLinked(LINK_THIS, SLOODLE_CHANNEL_TRANSLATION_REQUEST, output_method + "|" + llList2CSV(output_params) + "|" + string_name + "|" + llList2CSV(string_params) + "|" + batch, keyval);
}
        
init(){
    //get the dimensions of a pie_slice so we can determin the length of the sides of a pieslice.  In this case, we will choose pie_slice6 (they all have same dimensions)
        integer pie_slice6 = get_prim("pie_slice6");
        list pie_slice_data = llGetLinkPrimitiveParams(pie_slice6, [PRIM_SIZE] );
        vector pie_slice_size=llList2Vector(pie_slice_data, 0);
        tip_to_edge = pie_slice_size.z;//since we are looking for the length starting from the tip of the pie_slice to the middle of the edge, we need to choose the z dimension for this particular pie slice
        edge_length= pie_slice_size.y;//since we are looking for  the length of an edge we need to choose the y dimension for this particular pie slice
        question_prim= get_prim("question_prim");
        sloodle_translation_request("SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM", [YELLOW, 1.0,question_prim], "initquiz", [], "", "hex_quizzer");
        set_texture_pie_slices("blank_white");
        integer num_prims = llGetNumberOfPrims();
        integer i=0;
        //clear text
        for (i=0;i<num_prims;i++){
            sloodle_translation_request("SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM", [GREEN, 1.0,i], "clear", [" "], "", "hex_quizzer");
        }
            
}
default {
    on_rez(integer start_param){
        llResetScript();
    }
    state_entry() {
        init();
        llTriggerSound("SND_STARTING_UP", 1);
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==SLOODLE_CHANNEL_QUIZ_LOADING_QUIZ){
            state ready;
        }
    }
}
    state ready{
         on_rez(integer start_param){
        llResetScript();
    }
      state_entry() {
            MY_SLICES=[1,2,3,4,5,6];
            MY_SLICES=llListRandomize(MY_SLICES, 1);//randomize list of pie slices so we can dont display the question options over the same pie_slices each time
          sloodle_translation_request("SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM", [GREEN, 1.0,question_prim], "ready_click_colored_orb", [], "", "hex_quizzer");
          string name=llGetObjectName();
          //show orbs
          llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "edge expand show|0,1,2,3,4,5,6|10", NULL_KEY);    
    }
    link_message(integer link_set, integer link_message_channel, string str, key id) {
        if (link_message_channel ==SLOODLE_CHANNEL_USER_TOUCH){
            if (already_received_question==TRUE){
             //   return;
            }
            list data= llParseString2List(str, ["|"], []);
            string type = llList2String(data,0);
            //this is a rez edge attempt
            if (type!="edge"){
                 return;
            }
            if (type=="edge"){
                // a user touched an edge selector, so rez an edge
                
                integer edge=llList2Integer(data, 1);
                if (edge==0){
                    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER, "", id);
                }
                rez_hexagon(edge);
                //after a user presses an edge selector, hide the selector
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "edge expand hide|"+(string)edge, NULL_KEY);
            }
            
        }else 
        if (link_message_channel==SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR){
            debug("SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR");
            already_received_question=TRUE;
            llPlaySound("SND_LOADING_COMPLETE", 1);
            list data= llParseString2List(str, ["|"], []);
            //llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUESTION_ASKED_AVATAR, qdialogtext+"|"+qdialogoptions, user_key);//send back to rezzer so that pie_slices can show hovertext for each option
            string qdialogtext = llList2String(data,0);
            list qdialogoptions= llParseString2List(llList2String(data,1), [","], []);
            list qGrade= llParseString2List(llList2String(data,2), [","], []);
            debug("---------------received question! "+llList2CSV(qdialogoptions)+" "+qdialogtext+" answers are: "+llList2CSV(qGrade));
            sloodle_translation_request("SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM", [ORANGE, 1.0,get_prim("question_prim")], "option", [qdialogtext], "", "hex_quizzer");
            key user_key=id;
            integer j=0;
            
            //set the hover text of the pie_slices to the questions options
            integer num_options=llGetListLength(qdialogoptions); 
            set_texture_pie_slices("blank_white");
            for (j=0;j<num_options;j++){
                llSay(0,"setting texture: "+(string)j); 
                string pie_slice=llStringTrim(llList2String(MY_SLICES,j),STRING_TRIM);
                integer prim = get_prim("pie_slice"+(string)pie_slice);
                string option = llList2String(qdialogoptions,j);
             //   sloodle_translation_request("SLOODLE_TRANSLATE_HOVER_TEXT_LINKED_PRIM", [YELLOW, 1.0,prim], "option", [option], "", "hex_quizzer");
                set_texture_pie_slice((string)option,(integer)pie_slice);
            }
            
        }
    }
    object_rez(key platform) {
        //a new hex was rezzed, listen to the new hex platform
            llListen(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "", platform, "");
            rezzed_hexes+=platform;
            llGiveInventory(platform, HEXAGON_PLATFORM);
            debug("giving platform script");
            llRemoteLoadScriptPin(platform, "platform", PIN, TRUE,0);
        
    }
    listen(integer channel, string name, key id, string message) {
        list data = llParseString2List(message, ["|"], []);
        string command = llList2String(data, 0);
        debug("**************************"+message);
        if (channel==SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST){
            if (command=="GET QUESTION"){
                key user_key = llList2Key(data,1);
                debug("received request from "+llKey2Name(id)+" for user: "+llKey2Name(user_key));
                //llRegionSayTo(id,SLOODLE_CHANNEL_QUIZ_MASTER_RESPONSE, "A question|"+(string)llGetKey());
                llMessageLinked(LINK_SET, SLOODLE_CHANNEL_QUIZ_STATE_ENTRY_LOAD_QUIZ_FOR_USER, "", user_key);
            }
        }
            
    }
}

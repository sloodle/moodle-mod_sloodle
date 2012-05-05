//
// The line above should be left blank to avoid script errors in OpenSim.

integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_OWNER = -1639270111; // set the main shared media panel to the specified URL, accessible to the owner
integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_GROUP = -1639270112; // set the main shared media panel to the specified URL, accessible to the group
integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_ANYONE = -1639270114; // set the main shared media panel to the specified URL, accessible to anyone
integer side = 0;
setMessage(string str){
        string url = "data:text/html,<body style=\"width:1000px;height:1000px;background-color:#23212e;color:white;font-weight:bold;\">";
        url+="<div style=\"position:relative;top:19px;text-align:center;width:1000px;height:750px;font-size:50px;\" >";
        url+=str;
        url+="</div></body>";
        llClearPrimMedia(side);
        llSetPrimMediaParams( side, [ PRIM_MEDIA_CURRENT_URL, url, PRIM_MEDIA_HOME_URL, url, PRIM_MEDIA_FIRST_CLICK_INTERACT, TRUE, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER, PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE ] );
}
integer channel=9;
string SLOODLE_EOF = "sloodleeof";
integer eof= FALSE;
integer isconfigured=FALSE;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script.
string chalkboardtext;
integer sloodle_handle_command(string str) 
        {
    
            list bits = llParseString2List(str,["|"],[]);
            integer numbits = llGetListLength(bits);
            string name = llList2String(bits,0);
            string value1 = "";
            string value2 = "";
            
            if (numbits > 1) value1 = llList2String(bits,1);
            if (numbits > 2) value2 = llList2String(bits,2);
            
            if (name == "set:chalkboardtext"){
                 chalkboardtext = (string)value1;
               setMessage(chalkboardtext);
            }else
            if (name == "set:channel"){
                 channel= (integer)value1;
               
            }
            else if (name == SLOODLE_EOF) eof = TRUE;
          
            return (chalkboardtext != "");
        }
default
{
   // touch_start(integer d){
   // llSay(0,(string)llDetectedTouchFace(0));
  //}
    state_entry(){
        llClearPrimMedia( 1);
        setMessage(llKey2Name(llGetOwner())+", \"type /9 message\" to write a message");
        llListen(channel, "", llGetOwner(), "");
   }
   listen(integer channel, string name, key id, string message) {
            llClearPrimMedia(side);
            setMessage(message);
   }
   
     
     link_message( integer sender_num, integer num, string str, key id)
            {
                // Check the channel
                if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Split the message into lines
                    list lines = llParseString2List(str, ["\n"], []);
                    integer numlines = llGetListLength(lines);
                    integer i = 0;
                    for (; i < numlines; i++) {
                        isconfigured = sloodle_handle_command(llList2String(lines, i));
                    }
                    
                    // If we've got all our data AND reached the end of the configuration data, then move on
                    if (eof == TRUE) {
                        if (isconfigured == TRUE) {
                            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], null_key, "");
                           
                        }
                    }
                }
    }
            
    on_rez(integer start_param) {
        //llClearPrimMedia(3);                
        // Give the object a starting texture.
        // If we just use llClearPrimMedia here, we get a strange problem where if you click on it before it's ready, autozoom fails until you look away then look back.
        string url = "data:text/html,<body style=\"width:1000px;height:1000px;background-color:#595c67;color:white;font-weight:bold;\"><div style=\"position:relative;top:200px;text-align:center;width:1000px;height:750px;font-size:200%\" >Waiting for Message</div></body>";
        llSetPrimMediaParams( side, [ PRIM_MEDIA_CURRENT_URL, url, PRIM_MEDIA_HOME_URL, url, PRIM_MEDIA_FIRST_CLICK_INTERACT, TRUE, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER, PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE ] );
                
                
           
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/furniture-1.0/object_scripts/chalkboard.lsl


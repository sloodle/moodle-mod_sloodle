//
// The line above should be left blank to avoid script errors in OpenSim.

string SLOODLE_EOF = "sloodleeof";
integer eof= FALSE;
integer isconfigured=FALSE;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script.
string color= "#e7dfbc";
string bgcolor = "#8a4c23";
string title="";
integer fontsize=150;
integer side=1;
setMessage(string str,string color,string bgcolor){
            llClearPrimMedia(side);
            string url = "data:text/html,<body style=\"width:1000px;height:500px;background-color:"+bgcolor+";color:"+color+";font-weight:bold;\">";
            url+="<div style=\"position:relative;top:19px;text-align:center;width:1000px;height:500px;font-size:"+(string)fontsize+"px;\" >";
            url+=str;
            url+="</div></body>";
            
            llSetPrimMediaParams( side, [ PRIM_MEDIA_CURRENT_URL, url, PRIM_MEDIA_HOME_URL, url, PRIM_MEDIA_FIRST_CLICK_INTERACT, TRUE, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER, PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE ] );
    }
integer sloodle_handle_command(string str) 
        {
            list bits = llParseString2List(str,["|"],[]);
            integer numbits = llGetListLength(bits);
            string name = llList2String(bits,0);
            string value1 = "";
            string value2 = "";
            
            if (numbits > 1) value1 = llList2String(bits,1);
            if (numbits > 2) value2 = llList2String(bits,2);
            
            if (name == "set:color"){
                 color = (string)value1;
                 
            }else
            if (name == "set:bgcolor"){
                 bgcolor = (string)value1;
                 
            }else
            if (name=="set:title"){
                title = (string)value1;
            }
            else
            if (name=="set:fontsize"){
                fontsize= (integer)value1;
            }
            else if (name == SLOODLE_EOF) eof = TRUE;
            
            return (color != ""&&title!="");
        }
default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        
    }
     link_message( integer sender_num, integer num, string str, key id)
            {
                // Check the channel
                if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Split the message into lines
                    list lines = llParseString2List(str, ["\n"], []);
                    integer numlines = llGetListLength(lines);
                    integer i = 0;
                    for (i=0; i < numlines; i++) {
                        isconfigured = sloodle_handle_command(llList2String(lines, i));
                    }
                    if (isconfigured){
                        state ready;
                    
                    }
                    
                    // If we've got all our data AND reached the end of the configuration data, then move on
                    
                }
    }
    
    
            
}
state bready{
    state_entry() {
        state ready;
    }

}
state ready{
   on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        setMessage(title,color,bgcolor);
    }
  link_message( integer sender_num, integer num, string str, key id)
            {
                // Check the channel
                if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
                    // Split the message into lines
                    list lines = llParseString2List(str, ["\n"], []);
                    integer numlines = llGetListLength(lines);
                    integer i = 0;
                    for (i=0; i < numlines; i++) {
                        isconfigured = sloodle_handle_command(llList2String(lines, i));
                    }
                    if (isconfigured) state bready;
                    
                    // If we've got all our data AND reached the end of the configuration data, then move on
                    
                }
    }


}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/furniture-1.0/object_scripts/sign.lsl

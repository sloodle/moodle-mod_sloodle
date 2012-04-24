/*********************************************************************************************************    
 *  Avatar Classroom Seating
 *  This is a script that works with the Avatar Classroom HttpIn Object Definition Configuration Script
 *  
 *  
 *  Copyright (c) 2011 Avatar Classroom(various contributors)
 *  Released under the GNU GPL
 *  
 *  	Contributors:
 *			Edmund Edgar
 *			Paul Preibisch
 *
 *  This script will listen for a "color" config parameter, and set the color of the objects face 0        
*/        
string SLOODLE_EOF = "sloodleeof";
integer eof= FALSE;
integer isconfigured=FALSE;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script.
vector color= <0,0,0>;
integer sloodle_handle_command(string str) 
{
            list bits = llParseString2List(str,["|"],[]);
            integer numbits = llGetListLength(bits);
            string name = llList2String(bits,0);
            string value1 = "";
            string value2 = "";
            if (numbits > 1) value1 = llList2String(bits,1);
            if (numbits > 2) value2 = llList2String(bits,2);
            if (name == "color"){
                 color = (vector)value1;
                 llSetColor(color, 0);
            }
            else if (name == SLOODLE_EOF) eof = TRUE;
            return (color != ZERO_VECTOR);
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
                    for (; i < numlines; i++) {
                        isconfigured = sloodle_handle_command(llList2String(lines, i));
                    }
                    
                    // If we've got all our data AND reached the end of the configuration data, then move on
                    if (eof == TRUE) {
                        if (isconfigured == TRUE) {
                            //sloodle_translation_request(SLOODLE_TRANSLATE_SAY, [0], "configurationreceived", [], null_key, "");
                            state ready;
                        }
                    }
                }
    }
    
            
}
state ready{

    
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
                            state ready;
                        }
                    }
                }
    }
    on_rez(integer start_param) {
        llResetScript();
    }
    
}

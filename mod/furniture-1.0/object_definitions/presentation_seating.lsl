// LSL script generated: furniture-1.0.object_definitions.presentation_seating.lslp Sat Nov 19 14:36:29 Tokyo Standard Time 2011
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
integer eof = FALSE;
integer isconfigured = FALSE;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
vector color = <0,0,0>;
integer sloodle_handle_command(string str){
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    string name = llList2String(bits,0);
    string value1 = "";
    string value2 = "";
    if ((numbits > 1)) (value1 = llList2String(bits,1));
    if ((numbits > 2)) (value2 = llList2String(bits,2));
    if ((name == "color")) {
        (color = ((vector)value1));
        llSetColor(color,0);
    }
    else  if ((name == SLOODLE_EOF)) (eof = TRUE);
    return (color != ZERO_VECTOR);
}

default {

    on_rez(integer start_param) {
        llResetScript();
    }

    state_entry() {
    }

     link_message(integer sender_num,integer num,string str,key id) {
        if ((num == SLOODLE_CHANNEL_OBJECT_DIALOG)) {
            list lines = llParseString2List(str,["\n"],[]);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (; (i < numlines); (i++)) {
                (isconfigured = sloodle_handle_command(llList2String(lines,i)));
            }
            if ((eof == TRUE)) {
                if ((isconfigured == TRUE)) {
                    state ready;
                }
            }
        }
    }
}
state ready {


    
     link_message(integer sender_num,integer num,string str,key id) {
        if ((num == SLOODLE_CHANNEL_OBJECT_DIALOG)) {
            list lines = llParseString2List(str,["\n"],[]);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (; (i < numlines); (i++)) {
                (isconfigured = sloodle_handle_command(llList2String(lines,i)));
            }
            if ((eof == TRUE)) {
                if ((isconfigured == TRUE)) {
                    state ready;
                }
            }
        }
    }

    on_rez(integer start_param) {
        llResetScript();
    }
}


integer SLOODLE_QUESTION_IMAGE=-1639277025;//used for in quiz scripts, when a question is recieved, send the image url|question dialog to an display
   
print_message(string question_text){
    string CommandList = ""; // Storage for our drawing commands
    integer font_size=42;
      vector Extents = osGetDrawStringSize( "vector", question_text, "Arial", font_size );
         CommandList = osSetFontSize( CommandList, font_size );             // Use 10-point text
        integer xpos = 512 - ((integer) Extents.x >> 1);            // Center the text horizontally
        integer ypos =  255 - ((integer) Extents.y >> 1);            //   and vertically
        CommandList = osMovePen( CommandList, xpos, ypos );         // Position the text
        CommandList = osDrawText( CommandList, question_text ); // Place some text
 
        // Now draw the image
        osSetDynamicTextureData( "", "vector", CommandList, "width:1024,height:512", 0 );
    
}   
default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        print_message("");
    }
    link_message(integer sender_num, integer channel, string str, key id) {
        if (channel==SLOODLE_QUESTION_IMAGE){
            list data = llParseString2List(str, ["|"], []);
            string qImageUrl = llList2String(data,0);
            string qText= llList2String(data,1);
            print_message(qText);
        }
    }
}

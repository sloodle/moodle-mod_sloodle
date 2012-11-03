
integer SLOODLE_QUESTION_IMAGE=-1639277025;//used for in quiz scripts, when a question is recieved, send the image url|question dialog to an display
   
print_image(string qImageUrl){
    	if (qImageUrl==""){
			llSetTexture("TEXTURE_WHITE", ALL_SIDES);
			return;    	
    	}
    	string CommandList = ""; // Storage for our drawing commands
        CommandList = osMovePen( CommandList, 0, 0 );                // Upper left corner at <0,0>
        CommandList = osDrawImage( CommandList, 256, 256, qImageUrl ); 
 		
        // Now draw the image
        osSetDynamicTextureData( "", "vector", CommandList, "width:256,height:256", 0 );
    
}   
default {
	on_rez(integer start_param) {
		llResetScript();
	}
    state_entry() {
        print_image("");
    }
    link_message(integer sender_num, integer channel, string str, key id) {
    	if (channel==SLOODLE_QUESTION_IMAGE){
    		list data = llParseString2List(str, ["|"], []);
    		string qImageUrl = llList2String(data,0);
    		string qText= llList2String(data,1);
    		print_image(qImageUrl);
    	}
    }
}

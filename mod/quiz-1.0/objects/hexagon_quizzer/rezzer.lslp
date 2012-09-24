float size_x_half=3.0965;
float size_y=5.3662;
list rezzed_hexes;
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
integer SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST= -1639277006;
default {
    state_entry() {
        
    }
    link_message(integer link_set, integer link_message_channel, string str, key id) {
        if (link_message_channel ==SLOODLE_CHANNEL_USER_TOUCH){
            integer sub_section_index= (integer)str;
            integer my_oposite_section;
            vector my_coord=llGetPos();
            vector child_coord=my_coord;
            integer DIVISER=1;
            if (sub_section_index==1){
                child_coord.y=my_coord.y+2*(size_y);  
                my_oposite_section=4;                              
            }else
            if (sub_section_index==2){
                child_coord.x=my_coord.x+3*(size_x_half);
                child_coord.y=my_coord.y+1*(size_y);
                my_oposite_section=5;
            }else
            if (sub_section_index==3){
                child_coord.x=my_coord.x+3*(size_x_half);
                child_coord.y=my_coord.y-1*(size_y);
                my_oposite_section=6;
            }else
            if (sub_section_index==4){
                child_coord.y=my_coord.y-2*(size_y);
                my_oposite_section=1;
            }else 
            if (sub_section_index==5){
                child_coord.x=my_coord.x-3*(size_x_half);
                child_coord.y=my_coord.y-1*(size_y);
                my_oposite_section=2;
            }else
            if (sub_section_index==6){
                child_coord.x=my_coord.x-3*(size_x_half);
                child_coord.y=my_coord.y+1*(size_y);
            }
            //rez a new hexagon, and pass my_oppsosite_section as the start_parameter so that the new hexagon wont rez on that the my_oposite_section edge
            llRezAtRoot("Hexagon Quizzer", child_coord, ZERO_VECTOR,  llGetRot(), my_oposite_section);
        }
        
        
    }
    object_rez(key nex_hex) {
    	rezzed_hexes+=nex_hex;
    	llGiveInventory(nex_hex, "Hexagon Quizzer");
    	llListen(SLOODLE_CHANNEL_QUIZ_MASTER_REQUEST, "", nex_hex, "");
    }
    listen(integer channel, string name, key id, string message) {
    
    }
    
}

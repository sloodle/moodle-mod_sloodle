float size_x_half=3.0965;
float size_y=5.3662;

integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
default {
    state_entry() {
        
    }
    link_message(integer link_set, integer link_message_channel, string str, key id) {
        if (link_message_channel ==SLOODLE_CHANNEL_USER_TOUCH){
            integer hex_num= (integer)str;
            vector my_coord=llGetPos();
            vector child_coord=my_coord;
            integer DIVISER=1;
            if (hex_num==1){
                child_coord.y=my_coord.y+2*(size_y);                                
            }else
            if (hex_num==2){
                child_coord.x=my_coord.x+3*(size_x_half);
                child_coord.y=my_coord.y+1*(size_y);
            }else
            if (hex_num==3){
                child_coord.x=my_coord.x+3*(size_x_half);
                child_coord.y=my_coord.y-1*(size_y);
            }else
            if (hex_num==4){
                child_coord.y=my_coord.y-2*(size_y);
            }else
            if (hex_num==5){
                child_coord.x=my_coord.x-3*(size_x_half);
                child_coord.y=my_coord.y-1*(size_y);
            }else
            if (hex_num==6){
                child_coord.x=my_coord.x-3*(size_x_half);
                child_coord.y=my_coord.y+1*(size_y);
            }
            llRezAtRoot("Hexagon Quizzer", child_coord, ZERO_VECTOR,  llGetRot(), hex_num);
        }
        
        
    }
    object_rez(key id) {
    	llGiveInventory(id, "Hexagon Quizzer");
    }
    
}

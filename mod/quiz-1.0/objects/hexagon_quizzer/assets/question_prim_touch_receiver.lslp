
//question_prim_touch_receiver
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
default {
    state_entry() {
       
    }
    touch_start(integer num_detected) {
    	integer j;
    	key user_key;
    	for (j=0;j<num_detected;j++){
    		user_key=llDetectedKey(j);
    		llMessageLinked(LINK_SET, SLOODLE_CHANNEL_USER_TOUCH, "QUESTION BUTTON",user_key);
    	}
    }
}

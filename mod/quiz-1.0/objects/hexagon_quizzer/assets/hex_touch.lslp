
integer SLOODLE_CHANNEL_USER_TOUCH = -1639277002;//user touched object
default {
    state_entry() {
         
    }
    touch_start(integer num_detected) {
    	llMessageLinked(LINK_SET, SLOODLE_CHANNEL_USER_TOUCH, llGetObjectName(), NULL_KEY);
    }
}

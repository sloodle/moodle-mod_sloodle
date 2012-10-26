
integer SLOODLE_HTTPIN_MESSAGE_RECEIVED=1639277020;//used to tell other scripts a message has been received
vector BLUE=<0.00000, 0.00000, 1.00000>;
vector BABYBLUE=<0.00000, 1.00000, 1.00000>;
vector REZZER_GREY=<0.282353,0.282353,0.282353>;
integer SLOODLE_BLINKER=1639277019;//used to send commands to a prim which should blink
default {
    state_entry() {
        
    }
    link_message(integer sender_num, integer channel, string str, key id) {
    	if (channel==SLOODLE_HTTPIN_MESSAGE_RECEIVED){
    		llMessageLinked(LINK_SET, SLOODLE_BLINKER, "blinker_prim|"+(string)ALL_SIDES+"|"+(string)BABYBLUE+"|"+(string)BLUE+"|"+(string)REZZER_GREY+"|3", NULL_KEY);
    	}
    }
}

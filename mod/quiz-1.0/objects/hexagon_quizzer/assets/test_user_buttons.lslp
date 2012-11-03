
integer SLOODLE_CHANNEL_ANIM= -1639277007;
integer toggle;
default {
    state_entry() {
        llOwnerSay("Hello Scripter");
    }
    touch_start(integer num_detected) {
      if (toggle==-1){
          llSay(0,"showing");
          llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "show user buttons|1,2,3,4,5,6|10", NULL_KEY);
          toggle=1;
      }else
      if (toggle==1){
          llSay(0,"hiding");
          llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "hide user buttons|1,2,3,4,5,6|10", NULL_KEY);
          toggle=1;
      }
      
    }
}

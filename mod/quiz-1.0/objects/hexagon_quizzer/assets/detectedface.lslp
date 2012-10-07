

default {
    state_entry() {
        llOwnerSay("Hello Scripter");
    }
    touch_start(integer num_detected) {
    	llSay(0,llDetectedTouchFace(0));
    }
}

//pie_slice_1,2,3=1

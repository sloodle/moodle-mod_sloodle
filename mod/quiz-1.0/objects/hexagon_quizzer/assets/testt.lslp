

default {
    state_entry() {
        llOwnerSay("Hello Scripter");
    }
    touch_start(integer num_detected) {
        integer num = llGetNumberOfPrims();
        integer j;
        llSay(0,(string)num);
     for (j=0;j<num;j++){
                
                
                list rules = [ PRIM_TEXTURE,  ALL_SIDES, "blank_white", <1,1,1>,ZERO_VECTOR, ZERO_ROTATION ];
                llSay(0,"***********************************************setting texture for pie_slice"+(string)j+" linked prim "+(string)j);
                llSetLinkPrimitiveParamsFast(j, rules);
         }
    }
}

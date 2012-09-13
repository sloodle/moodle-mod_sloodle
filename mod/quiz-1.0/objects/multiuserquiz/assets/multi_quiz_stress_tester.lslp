list bots;

default {
	on_rez(integer start_param) {
		llResetScript();
	}
    state_entry() {
        bots+=(key)"5257e210-8eef-4e7d-bb86-4c66ca8403f9";//annamarieflower
        bots+=(key)"e761ccef-5ddb-4397-92c5-75183fcc361a";//ScarletFeeva
        bots+=(key)"38ab4e14-216c-43ed-b66f-40f77496d777";//bobbyWilliams
        bots+=(key)"a7063b87-560f-42dd-b741-404be513c1a1";//Petradish
        bots+=(key)"0ba5b1f7-2fa6-446f-b75d-422a0694c2ad";//WillowSparks
        bots+=(key)"d1cde898-4435-4a2f-ab0a-2aa9feadd4a3";//FrankyJSmith
    }
    touch_start(integer num_detected) {
    	integer len = llGetListLength(bots);
    	integer i;
    	for (i=0;i<len;i++){
    		llSay(-9,llList2String(bots,i));
    		llOwnerSay((string)i+") "+llKey2Name((key)llList2Key(bots,i))+" is asking a question");
    	}
    }
}

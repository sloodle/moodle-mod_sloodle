string scriptname = "zFire Animator 5.2.8";//changes the script name your loading onto child prims
integer pin = 878;
integer startP = 123;
list acceptible_prims;
default
{
    state_entry(){
    	integer j;
    	for (j=1;j<=6;j++){
    		acceptible_prims+="rod_hor_"+(string)j;
    		acceptible_prims+="rod_ver_"+(string)j;
    		acceptible_prims+="orb"+(string)j;
    		//acceptible_prims+="pie_slice"+(string)j;
    	}
    }
    touch_start(integer total_number)
    {
        integer len = llGetNumberOfPrims();
        integer i;
        llSay(0,"starting "+llList2CSV(acceptible_prims));
        for( i = 2; i < len; i++ ){
        	string name=llGetLinkName(i);
        		llOwnerSay("i: "+(string)i);
           				
           if (llListFindList(acceptible_prims, [llGetLinkName(i)])!=-1){
           	if (llGetSubString(name,0,3)=="orb"){
           		llRemoteLoadScriptPin(llGetLinkKey(i), "orb.lslp", pin, 1, startP);
           		llOwnerSay("giving away orb.lslp to: "+name);
           				
           	}
           	if (llGetSubString(name,0,6)=="rod_ver"){
           		llRemoteLoadScriptPin(llGetLinkKey(i), "rod_ver.lslp", pin, 1, startP);
           		llOwnerSay("giving away rod_ver.lslp to: "+name);
           				
           	}
           	if (llGetSubString(name,0,6)=="rod_hor"){
           		llRemoteLoadScriptPin(llGetLinkKey(i), "rod_hor.lslp", pin, 1, startP);
           		llOwnerSay("giving away rod_hor.lslp to: "+name);
           				
           	}
           }
        }
    }
}
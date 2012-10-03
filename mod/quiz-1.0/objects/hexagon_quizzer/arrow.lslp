

sloodle_set_pos(vector target_position){
    integer counter=0;
    while ((llVecDist(llGetPos(), target_position) > 0.001)&&(counter<50)) {
        counter+=1;
        llSetPos(target_position);
    }

}

default {
    state_entry() {
      llListen(-27, "", "", "");
         
    }
    listen(integer channel, string name, key id, string message) {
        list data = llParseString2List(message, ["|"], []);
        //go|v0|"+(string)v0
        string command = llList2String(data,0);
        string my_name = llGetObjectName();
        string object =  llList2String(data,1);
        vector target_position=llList2Vector(data, 2);
        
        if (command=="go"){
            if (my_name ==object){
                llOwnerSay("My name is :"+my_name +" my target is: "+(string)target_position+" Going now!");
                sloodle_set_pos(target_position);
            }
        }
        
    }
}

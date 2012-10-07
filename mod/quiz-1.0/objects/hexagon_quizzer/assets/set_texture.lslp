integer SLOODLE_SET_TEXTURE= -1639277010;

default {
    link_message(integer sender_num, integer num, string str, key id) {
        if (num==SLOODLE_SET_TEXTURE){
            list data = llParseString2List(str, ["|"], []);
            string prim=llList2String(data, 0);
            if (prim!=llGetObjectName()){
                return;
            }
            integer face=llList2Integer(data, 1);
            string texture=llList2String(data, 2);
            llSetTexture(texture, face);
        }
    }
}

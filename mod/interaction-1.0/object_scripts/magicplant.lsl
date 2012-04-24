// LSL script generated: interaction-1.0.object_scripts.magicplant.lslp Sat Nov 19 14:36:29 Tokyo Standard Time 2011
/*
* magicplant.lsl
* Part of the Sloodle project (www.sloodle.org)
* 
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
* 
*  Contributors:
*  Edmund Edgar
*  Paul Preibisch
*
*  This script will accept touches.  When tocuhed it will tell the mod_touchable-1.0.lsl script to send a touch event to the server
*  That touch action will check to see if the user has X water in their inventory, and if so, subtract water 
* Once watered 5 times, this script will rezz a flower object, and shout out the person the flower object should float towards
* Once the flower object reaches its target it will tell this plant object to give the user a flower in their inventory 
*/
integer counter = 0;
list plantPhase = ["p2","p1","p0","p10","p11","p12","p13"];
integer SLOODLE_NOT_ENOUGH_CURRENCY = -1001;
integer SLOODLE_OBJECT_INTERACTION_FLOWER = -1639271134;
integer SLOODLE_OBJECT_REGISTER_INTERACTION = -1639271133;
key userKey;
integer SLOODLE_OBJECT_FLOWER_POWER = -1639271136;
grow(){
    integer len = llGetListLength(plantPhase);
    integer phase = (counter++);
    if ((counter > (len - 1))) {
        (counter = 0);
    }
    llMessageLinked(LINK_SET,(-99),llList2String(plantPhase,counter),NULL_KEY);
}
shrink(){
    integer len = llGetListLength(plantPhase);
    integer phase = (counter--);
    if ((counter < 0)) {
        (counter = 0);
    }
    llMessageLinked(LINK_SET,(-99),llList2String(plantPhase,counter),NULL_KEY);
}
giveFlower(){
    llSay(0,"A flower has bloomed!");
    vector pos = llGetPos();
    llRezObject("flower",<pos.x,pos.y,(pos.z + 2)>,<0,0,2>,ZERO_ROTATION,1);
}
default {

    state_entry() {
        llMessageLinked(LINK_SET,(-99),"p2",NULL_KEY);
        llListen(SLOODLE_OBJECT_FLOWER_POWER,"","","");
        llSetTimerEvent(120);
    }

    touch_start(integer num_detected) {
        llMessageLinked(LINK_SET,SLOODLE_OBJECT_REGISTER_INTERACTION,"water",llDetectedKey(0));
        llSay(0,"Attempting to water plant");
    }

    listen(integer channel,string name,key id,string message) {
        list data = llParseString2List(message,["|"],[]);
        string command = llList2String(data,0);
        key plantUuid = llList2Key(data,1);
        (userKey = llList2Key(data,2));
        if ((command == "GOT FLOWER")) {
            if ((plantUuid != llGetKey())) {
                return;
            }
            llMessageLinked(LINK_SET,SLOODLE_OBJECT_REGISTER_INTERACTION,"flower",userKey);
        }
    }

    link_message(integer sender_num,integer num,string str,key id) {
        list lines = llParseStringKeepNulls(str,["\n"],[]);
        integer numlines = llGetListLength(lines);
        list statusfields = llParseStringKeepNulls(llList2String(lines,0),["|"],[]);
        integer statuscode = llList2Integer(statusfields,0);
        key user = llList2Key(statusfields,6);
        if ((statuscode <= 0)) {
            if ((statuscode == SLOODLE_NOT_ENOUGH_CURRENCY)) {
                llTriggerSound("NEEDWATER",1);
            }
            string msg;
            if ((numlines > 1)) {
                (msg = llList2String(lines,1));
            }
            return;
        }
        else  {
            string task = llList2String(lines,1);
            if ((task == "complete")) {
                grow();
                (userKey = user);
                giveFlower();
            }
            else  if ((task == "water")) {
                llTriggerSound("water drip",1);
                llTriggerSound("water drip",1);
                llTriggerSound("water drip",1);
                grow();
                llMessageLinked(LINK_SET,SLOODLE_OBJECT_REGISTER_INTERACTION,"complete",user);
            }
            else  if ((task == "flower")) {
                grow();
                llSay(0,(("Added a flower to " + llKey2Name(user)) + "'s backpack!"));
            }
        }
    }

    object_rez(key id) {
        llSleep(2);
        llRegionSay(SLOODLE_OBJECT_INTERACTION_FLOWER,((((((string)id) + "|") + ((string)llGetKey())) + "|") + ((string)userKey)));
    }

    timer() {
        shrink();
    }
}

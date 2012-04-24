string getScream(){
    screams = ["scream1","scream2","scream3","scream4"];
    integer screamLen = llGetListLength(screams);
    screamCounter++;
    if  (screamCounter>screamLen-1){
        screamCounter=0;
    }
    return llList2String(screams,screamCounter);

}
default
{
    state_entry()
    {
        llSetStatus(STATUS_ROTATE_X,FALSE);
         llSetStatus(STATUS_ROTATE_Y,FALSE);
         llSensorRepeat("","",AGENT,30,PI,5);
    }
    sensor(integer s){
        //llLookAt(llDetectedPos(0),2,2);
       llSetStatus(STATUS_PHYSICS,TRUE);
       vector randomoffset=<llFrand(20)-10,llFrand(20)-10,0>;
       vector deathTarget = llDetectedPos(0);
       target_id = llTarget(deathTarget, 0.5);
       llMoveToTarget(deathTarget+randomoffset, 3);
       llSleep(1);llSetStatus(STATUS_PHYSICS,FALSE);
        
    }
    at_target(integer tnum, vector targetpos, vector ourpos)
    {
        if (tnum == target_id)
        {
            llTriggerSound(getScream(), 0.3);
            //llTriggerSound("SND_JELLY_ATTACK",  0.5);
            attackTimes++;
            //changeColor(WHITE,1,0.2);
            llPushObject(deathKey,<5,5,5>, <5,5,5>, TRUE);
            llTargetRemove(target_id);
            if (attackTimes>5) {
                attackTimes= 0;
                state ready;
            }
        }  
    } 


}

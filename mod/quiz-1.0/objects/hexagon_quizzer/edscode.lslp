rotation VectorToRotation( vector V )
{
    V = llVecNorm( V );
    vector UP = < 0.0, 0.0, 1.0 >;
    vector LEFT = llVecNorm(UP%V);
    V = llVecNorm(LEFT%UP); // confined to the horizontal plane
    return llAxes2Rot(V, LEFT, UP);
}
 debug (string message ){
              list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
              if ( llList2Integer (params ,0)==PRIM_MATERIAL_FLESH ){
                   llOwnerSay(llGetScriptName ()+": " +message );
             }
        } 
        
getRot(key target){

    vector vTarget=llList2Vector(llGetObjectDetails(target,[OBJECT_POS]),0);
	vector vPos=llGetPos(); //object position
	float fDistance=llVecDist(<vTarget.x,vTarget.y,0>,<vPos.x,vPos.y,0>); // XY Distance, disregarding height differences.
	rotation result = llRotBetween(<1,0,0>,llVecNorm(<fDistance,0,vTarget.z - vPos.z>)) * llRotBetween(<1,0,0>,llVecNorm(<vTarget.x - vPos.x,vTarget.y - vPos.y,0>)));
}        

default
{
    state_entry()
    {
        
        llSensor("", NULL_KEY, AGENT, 20.0, PI);

    }
 
    sensor(integer num) {
        integer i;
        for (i=0; i<num; i++) {
            vector avpos = llDetectedPos(i);
            vector mypos = llGetPos();
            //avpos.z = mypos.z;
                        
           // llLookAt(avpos, 3.0, 1.0);
            //rotation myrot = llGetRot();
            rotation myrot = VectorToRotation(avpos-mypos);
        
            float myanglerads = llRot2Angle(myrot);
            float myangle = myanglerads *RAD_TO_DEG;
        	debug((string)myangle);
            if (myangle > 180) {
                myangle = myangle - 180;
            }
 
                     
            if (mypos.y > avpos.y) {
                llOwnerSay("up");
            } else {
                llOwnerSay("down");
            }
    
            if (mypos.x > avpos.x) {
                llOwnerSay("left");
            } else {
                llOwnerSay("right");
            }    
          
            llOwnerSay((string)myangle); 
            
            if (myangle > 150 || myangle <= 30) {
                if (mypos.x > avpos.x) {
                    llOwnerSay("green");                       
                } else {
                    llOwnerSay("light blue");                   
                }
            } else if (myangle > 30 || myangle <= 90) {
                if (mypos.x > avpos.x) {                
                    llOwnerSay("yellow");
                } else {
                    llOwnerSay("red");                    
                }
            } else {
                llOwnerSay("dunno");
            }
        }
         
        
    }

    touch_start(integer num) {   
        llSensor("", NULL_KEY, AGENT, 20.0, PI);    
    }    
}
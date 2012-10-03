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

integer get_prim(string name){
    integer num_links=llGetNumberOfPrims();
    integer i;
    integer prim=-1;
    for (i=0;i<=num_links;i++){
        if (llGetLinkName(i)==name){
            prim=i;
            //debug("found ------------------- "+name+": "+(string)name);
        }else{
            //debug("not found ------------------- "+name+": "+(string)i);
        }
    }
    return prim;
}
string pie_slice_for_position(vector avatar){
    //returns name of pie_slice
    integer i;
    float closest_so_far=100.0;
    string  closest_so_far_link="";

    for (i=1;i<=6;i++){
        integer link_num = get_prim("orb"+(string)i);
        list link_data=llGetLinkPrimitiveParams(link_num, [PRIM_POSITION]);
        
        vector pos = llList2Vector(link_data, 0);
        float dist = llVecDist(pos, avatar);
        if (dist<closest_so_far){
            closest_so_far=dist;
            closest_so_far_link="orb"+(string)i;
        }
    }
    
    return closest_so_far_link;
}
        
rotation getRot(key target){

    vector vTarget=llList2Vector(llGetObjectDetails(target,[OBJECT_POS]),0);
    vector vPos=llGetPos(); //object position
    float fDistance=llVecDist(<vTarget.x,vTarget.y,0>,<vPos.x,vPos.y,0>); // XY Distance, disregarding height differences.
    rotation result = llRotBetween(<1,0,0>,llVecNorm(<fDistance,0,vTarget.z - vPos.z>)) * llRotBetween(<1,0,0>,llVecNorm(<vTarget.x - vPos.x,vTarget.y - vPos.y,0>));
    return result;
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
           
           llSay(0,llDetectedName(i)+" "+pie_slice_for_position(llDetectedPos(i)));
           
        }
         
        
    }

    touch_start(integer num) {   
        llSensor("", NULL_KEY, AGENT, 20.0, PI);    
    }    
}
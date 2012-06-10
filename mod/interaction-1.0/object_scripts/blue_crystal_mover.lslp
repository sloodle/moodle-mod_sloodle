/*  blue_crystal_mover
*  Part of the Sloodle project (www.sloodle.org)
*
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
*  -------------------------------------------
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  All scripts must maintain this copyrite information, including the contributer information listed
*
*  Contributors:
*   Paul Preibisch
*   Edmund Edgar
*
*  DESCRIPTION
*  This script is intended for a blue crystal which the students must find in order to powerup the teleporter.
*  Once a student rezzes this crytsal, it will ask them if they want to put it into TARGET_NAME.  TARGET_NAME is defined 
*  via the objects description input field in SL. Example: 
*  CHANNEL:99882234,TARGET_NAME:Teleporter,REZSOUND:SND_dancershort,DROPSOUND:SND_splash2
*  Here you can see the description field TARGET_NAME is set to Teleporter.  Once rezed,
*  search for a nearby object named Teleporter, and move towards it
*  When it reaches TARGET_NAME, it will shout out on the CHANNEL a message to the TARGET_NAME
*  the TARET_NAME object should be programmed to listen on this channel, and react accordingly.
*  In our case, the teleporter will "Activate" allowing the student to teleport.
*
*  Required Sounds:
*   SND_DRIP_CAVE - http://www.freesound.org/people/jnr%20hacksaw/sounds/11126/
*   SND_DANCER_SHORT - http://www.freesound.org/people/ERH/sounds/49603/
*   SND_ERH_STRINGS - http://www.freesound.org/people/ERH/sounds/40775/
*/
string MOVE_SOUND ="SND_DANCER_SHORT";
string DROP_SOUND ="SND_DRIP_CAVE";
string REZ_SOUND = "SND_ERH_STRINGS";
integer TARGET_CHANNEL;
string TARGET_NAME;
string  CONTROLLER_ID = "A"; // See comments at end regarding CONTROLLERS.
integer AUTO_START = TRUE;   // Optionally FALSE only if using CONTROLLERS.

list particle_parameters=[]; // stores your custom particle effect, defined below.
list target_parameters=[]; // remembers targets found using TARGET TEMPLATE scripts.
float fade=0;

particle_effect_rez(){
    //this is a white particle effect - has stright vertical lines
llParticleSystem([PSYS_PART_FLAGS,257
,PSYS_SRC_PATTERN,2
,PSYS_SRC_TEXTURE,""
,PSYS_PART_START_COLOR,<0.60465, 0.63310, 0.78060>
,PSYS_PART_END_COLOR,<1.00000, 1.00000, 1.00000>
,PSYS_PART_START_ALPHA,0.756198
,PSYS_PART_END_ALPHA,0.132786
,PSYS_PART_START_SCALE,<0.05465, 0.62644, 0.00000>
,PSYS_PART_END_SCALE,<0.03877, 1.42060, 0.00000>
,PSYS_SRC_ANGLE_BEGIN,0.000000
,PSYS_SRC_ANGLE_END,0.000000
,PSYS_SRC_MAX_AGE,0.000000
,PSYS_PART_MAX_AGE,0.615562
,PSYS_SRC_ACCEL,<-0.01659, -0.01659, 0.02312>
,PSYS_SRC_OMEGA,<3.37895, 3.30414, 5.34893>
,PSYS_SRC_BURST_PART_COUNT,27
,PSYS_SRC_BURST_RADIUS,0.019946
,PSYS_SRC_BURST_RATE,0.139070
,PSYS_SRC_BURST_SPEED_MIN,0.218485
,PSYS_SRC_BURST_SPEED_MAX,0.218485
]);
}

/***********************************************
*  extractResponse()
*  Is used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  By adding a context to the messages, the programmer can understand whats going on when debugging
*  All this function does is strip off the text before the ":" char 
***********************************************/
string extractResponse(string cmd){     
     return llList2String(llParseString2List(cmd, [":"],[]),1);
}
/***********************************************
*  random_integer()
*  |-->Produces a random integer
***********************************************/ 
integer random_integer( integer min, integer max )
{
  return min + (integer)( llFrand( max - min + 1 ) );
}
integer MENU_CHANNEL;


default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        string        Name = llGetRegionName();
        vector Where = llGetPos();
        
        string objDesc=llGetObjectDesc();
        list objD = llParseString2List(objDesc, [","], []);
        TARGET_CHANNEL=(integer)extractResponse(llList2String(objD,0));
        TARGET_NAME=extractResponse(llList2String(objD,1));
       
       
        integer ix= (integer)Where.x;
        integer  iy = (integer)Where.y;
        integer  iz = (integer)Where.z;
        string SLURL = "http://slurl.com/secondlife/"+ llEscapeURL(llGetRegionName()) + "/"+(string)ix +"/"+(string)iy+"/"+(string)iz+"/";         
        llRegionSay(TARGET_CHANNEL,"COMMAND:USER REZZED LEAF|LEAFNAME:"+llGetObjectName()+"|AVUUID:"+(string)llGetOwner()+"|"+SLURL); 
        llSetAlpha(0.0, ALL_SIDES);
        particle_effect_rez();        
        llTriggerSound(REZ_SOUND, 1.0); 
        llSetTimerEvent(0.5);
    }
    timer() {
        fade+=0.2;
        llSetAlpha(0+fade,ALL_SIDES);
        if (fade>=1.0) {
            llSetTimerEvent(0.0);
            llParticleSystem([]);
            state ask;
            
        }
    }
   


}


    


state ask {
    
    on_rez(integer start_param) {
        llResetScript();
    }
  /*
    touch_start(integer num_detected) {
        for (j=0;j<num_detected;j++){
            MENU_CHANNEL=random_integer(2142483000,2147483000); //creatae a random MENU_CHANNEL index within a range of 5,000,000 numbers - to avoid conflicts with other objects
            key userkey =  llDetectedKey(j);
            llListen(MENU_CHANNEL, "",userkey, "");
            llDialog(userkey, "Do you want to put this "+llGetObjectName()+ " into the "+TARGET_NAME, ["Put it in!","No, keep it!"], MENU_CHANNEL);
        }
        
    }
    */
    touch_start(integer num_detected) {
        if (llDetectedKey(0)!=llGetOwner()) return;
        llSetTimerEvent(30);
            MENU_CHANNEL=random_integer(2142483000,2147483000); //creatae a random MENU_CHANNEL index within a range of 5,000,000 numbers - to avoid conflicts with other objects
            key userkey =  llGetOwner();
            llListen(MENU_CHANNEL, "",userkey, "");
            llDialog(userkey, "Do you want to put this "+llGetObjectName()+ " into the "+TARGET_NAME, ["Put it in!","No, keep it!"], MENU_CHANNEL);
    }
    state_entry() {
        llSetTimerEvent(30);
            MENU_CHANNEL=random_integer(2142483000,2147483000); //creatae a random MENU_CHANNEL index within a range of 5,000,000 numbers - to avoid conflicts with other objects
            key userkey =  llGetOwner();
            llListen(MENU_CHANNEL, "",userkey, "");
            llDialog(userkey, "Do you want to put this "+llGetObjectName()+ " into the "+TARGET_NAME, ["Put it in!","No, keep it!"], MENU_CHANNEL);
    }
    listen(integer channel, string name, key id, string message) {
        if (message=="Put it in!"){
            state sendLeafToCauldron;
        }else
        if (message=="No, keep it!"){
            state dontPutIn;
        }
    }
    timer(){
        state fadeOut;
    }
}

state sendLeafToCauldron{
        on_rez(integer start_param) {
        llResetScript();
    }
    
    state_entry() {
            llSensorRepeat(TARGET_NAME, "", PASSIVE, 30.0, PI, 1.0);   
            llSensorRepeat(TARGET_NAME, "", ACTIVE, 30.0, PI, 1.0);
            llSay(0,"Searching for "+TARGET_NAME+"...");
            particle_parameters = [  // start of particle settings
           // Texture Parameters:
           PSYS_SRC_TEXTURE, llGetInventoryName(INVENTORY_TEXTURE, 0),
           PSYS_PART_START_SCALE, <0.2, 0.2, FALSE>, PSYS_PART_END_SCALE, <0.2,0.2, FALSE>, 
           PSYS_PART_START_COLOR, <1.00,1.00,1.00>,    PSYS_PART_END_COLOR, <1.00,1.00,1.00>, 
           PSYS_PART_START_ALPHA, (float) 1.0,         PSYS_PART_END_ALPHA, (float) 1.0,     
           
           // Production Parameters:
           PSYS_SRC_BURST_PART_COUNT, (integer)  2, 
           PSYS_SRC_BURST_RATE,         (float) 0.2,  
           PSYS_PART_MAX_AGE,           (float)  10.0, 
        // PSYS_SRC_MAX_AGE,            (float)  0.00, 
            
           // Placement Parameters:
           PSYS_SRC_PATTERN, (integer) 1, // 1=DROP, 2=EXPLODE, 4=ANGLE, 8=CONE,
           PSYS_SRC_ACCEL, < 00.00, 00.00, -00.1>,
           PSYS_PART_FLAGS, (integer) ( 0                  // Texture Options:     
                                | PSYS_PART_INTERP_COLOR_MASK   
                                | PSYS_PART_INTERP_SCALE_MASK   
                                | PSYS_PART_EMISSIVE_MASK   
                                | PSYS_PART_FOLLOW_VELOCITY_MASK
                                                  // After-effect & Influence Options:
                                | PSYS_PART_WIND_MASK            
                             // | PSYS_PART_BOUNCE_MASK          
                             // | PSYS_PART_FOLLOW_SRC_MASK     
                                | PSYS_PART_TARGET_POS_MASK     
                              | PSYS_PART_TARGET_LINEAR_MASK    
                            ) 
            //end of particle settings                     
        ];
        
      // llParticleSystem( particle_parameters );
        
    }
    
  
   
   sensor(integer num_detected) {
       
       llSay(0,TARGET_NAME+" found! Sending "+llGetObjectName());
    //target_parameters = [ PSYS_SRC_TARGET_KEY, llDetectedKey(0) ];
      //      llParticleSystem( particle_parameters + target_parameters );
       //llPlaySound(DROP_SOUND, 1.0);
       llSetStatus (STATUS_PHYSICS,TRUE);
       llTriggerSound(MOVE_SOUND, 1);
     llMoveToTarget( llDetectedPos(0)+<0,0,1>, 5);
     
   llSensorRemove( );
   
   llSetTimerEvent(10.0);
}

timer() {
    
    llSetTimerEvent(0.0);
    state fadeOut;
}
}
state fadeOut{
        on_rez(integer start_param) {
        llResetScript();
    }
    
    state_entry() {
        llSetTimerEvent(0.5);
    }
    timer() {
        fade-=0.2;
        llSetAlpha(0+fade,ALL_SIDES);
        if (fade<=0.0) state done;
    }
}

state dontPutIn{
        on_rez(integer start_param) {
        llResetScript();
    }
    
    state_entry() {
        llSetTimerEvent(0.5);
    }
    timer() {
        fade-=0.2;
        llSetAlpha(0+fade,ALL_SIDES);
        if (fade<=0.0) state finish;
    }
}
state done{
    
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
    
       llTriggerSound(DROP_SOUND, 1.0);
        
          
           llParticleSystem( [] );
           particle_effect_rez();  
           llSetTimerEvent(4.0);
           llListen(2, "",llGetOwner(), "r");
    }
    listen(integer channel, string name, key id, string message) {
        if (channel==2) {
            if (message="r") state default;
        }
    }
    timer() {
        llParticleSystem( [] );
         llShout(TARGET_CHANNEL,"COMMAND:INSERT|NAME:"+llGetObjectName()+"|AVUUID:"+(string)llGetOwner());
        llSetTimerEvent(0);
       llTriggerSound(DROP_SOUND, 1.0);
       llDie();
    }

}

state finish{
    
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
           llParticleSystem( [] );
           particle_effect_rez();  
           llSetTimerEvent(4.0);
    
    }
    
    timer() {
        llParticleSystem( [] );    
        llSetTimerEvent(0);
       llDie();
    }

}

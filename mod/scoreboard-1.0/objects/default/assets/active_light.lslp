//
// The line above should be left blank to avoid script errors in OpenSim.


/*
Blink - this will make an object start blinking different colors for MAX_TIME if a message is received on a BLINK_CHANNEL
*/
//SLOODLE vars
integer SLOODLE_AWARDS_POINTS_CHANGE_NOTIFICATION= 10601;

integer MAX_TIME=13;
integer BLINK_CHANNEL;

vector RED =<1.00000, 0.00000, 0.00000>;
vector ORANGE=<1.00000, 0.43763, 0.02414>;
vector YELLOW=<1.00000, 1.00000, 0.00000>;
vector GREEN=<0.00000, 1.00000, 0.00000>;
vector BLUE=<0.00000, 0.00000, 1.00000>;
vector BABYBLUE=<0.00000, 1.00000, 1.00000>;
vector PINK=<1.00000, 0.00000, 1.00000>;
vector PURPLE=<0.57338, 0.25486, 1.00000>;
vector BLACK= <0.00000, 0.00000, 0.00000>;
vector WHITE= <1.00000, 1.00000, 1.00000>;
list colors;
integer currentColor=0;
integer counter=0;
integer toggle=-1;

vector getColor(){
    currentColor++;
    if (currentColor>llGetListLength(colors)-1){
        currentColor=0;
    }
    
    
    
    return llList2Vector(colors, currentColor);
}

vector color;
blink(vector c){
   llParticleSystem([
             PSYS_PART_FLAGS , 0  | PSYS_PART_BOUNCE_MASK | PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_TARGET_POS_MASK | PSYS_PART_FOLLOW_VELOCITY_MASK | PSYS_PART_EMISSIVE_MASK,
             PSYS_SRC_PATTERN, 4, PSYS_SRC_TEXTURE, (key)"e050e81b-d754-d1a4-d358-5dc01ae9b613", PSYS_SRC_TARGET_KEY, (key)"NULL_KEY",
             PSYS_SRC_MAX_AGE, 0.000000, PSYS_PART_MAX_AGE, 0.443290, PSYS_SRC_BURST_RATE, 0.100000, PSYS_SRC_BURST_PART_COUNT, 4,
             PSYS_SRC_BURST_RADIUS, 0.168301, PSYS_SRC_ACCEL, <0.00000, 0.00000, -2.00000>,
             PSYS_SRC_BURST_SPEED_MIN, 1.514547, PSYS_SRC_BURST_SPEED_MAX, 5.217438,
             PSYS_PART_START_COLOR,c, PSYS_PART_END_COLOR,c,
             PSYS_PART_START_ALPHA, 0.211864, PSYS_PART_END_ALPHA, 0.000000,
             PSYS_PART_START_SCALE, <1.00000, 1.00000, 2.00000>, PSYS_PART_END_SCALE, <1.00000, 1.00000, 5.00000>,
             PSYS_SRC_ANGLE_BEGIN, 0.000000, PSYS_SRC_ANGLE_END, 6.000000,
             PSYS_SRC_OMEGA, <0.00000, 0.00000, 0.00000>]); 
}
float change;
handle_points_notification(string str) {

    string changeduserid;
    string newbalance;

    list lines = llParseStringKeepNulls(str,["\n"],[]);
    integer l;
   // llOwnerSay("points notification: "+str);
    for(l=0; l<llGetListLength(lines); l++) {
        string line = llList2String(lines, l);
        list bits = llParseStringKeepNulls(line,["|"],[]);
        integer numbits = llGetListLength(bits);
        string name = llList2String(bits,0);
        string value = ""; 
        if (llGetListLength(bits) > 1) {
            value = llList2String(bits,1);
        }
        if (name == "balance") newbalance = value;
        if (name == "change") change= (float)value;
        if (name == "userid") changeduserid = value;
    }
    if ((float)newbalance>0){
                color=GREEN;
     }else {
                color=RED;        
    }
    blink(color);
    llTriggerSound("loud_moon", 1);
    llSetTimerEvent(0.2);    
    
}

default {
    state_entry() {
        llSetColor(WHITE, ALL_SIDES);
        //change this if not using sloodle
        BLINK_CHANNEL=SLOODLE_AWARDS_POINTS_CHANGE_NOTIFICATION;
        //define colors 
          
    }
    
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SLOODLE_AWARDS_POINTS_CHANGE_NOTIFICATION){
            handle_points_notification(str);
                
        } 
        
    }
    timer() {
        counter++;
        if (toggle==-1){
            llSetColor(BABYBLUE, ALL_SIDES);
        }else{
            llSetColor(WHITE, ALL_SIDES);
        }

        if (counter>MAX_TIME){
            counter=0; 
            llSetTimerEvent(0);
            llParticleSystem([]);
            llSetColor(WHITE, ALL_SIDES);
        }
        toggle*=-1;
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/scoreboard-1.0/objects/default/assets/active_light.lslp

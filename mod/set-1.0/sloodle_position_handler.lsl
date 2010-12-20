integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;

vector rezzer_position_offset;
rotation rezzer_rotation_offset;
key rezzer_uuid;
integer isconfigured = 0;

move_to_layout_position() {
    
   // llOwnerSay("todo: move to position "+(string)rezzer_position_offset+", rot "+(string)rezzer_rotation_offset+ " in relation to rezzer "+(string)rezzer_uuid);   

    list rezzerdetails = llGetObjectDetails( rezzer_uuid, [ OBJECT_POS, OBJECT_ROT ] );
    vector rezzerpos = llList2Vector( rezzerdetails, 0 );
    rotation rezzerrot = llList2Rot( rezzerdetails, 1 );

    llSetPos( rezzerpos + ( rezzer_position_offset * rezzer_rotation_offset ) );
    llSetRot( rezzerrot * rezzer_rotation_offset );

}

// Configure by receiving a linked message from another script in the object
// Returns TRUE if the object has all the data it needs
integer sloodle_handle_command(string str) 
{
    list bits = llParseString2List(str,["|"],[]);
    integer numbits = llGetListLength(bits);
    
    if (numbits >= 1 ) {
        string name = llList2String(bits,0);
        if (name == "set:position") {    
            rezzer_position_offset = (vector)llList2String(bits,1);
            rezzer_rotation_offset = llList2Rot(bits,2);
            rezzer_uuid = llList2Key(bits,3);
            return 1;            
        } else if (name == "do:derez") {
            llDie();
        }
    } 
    return 0;
}

default
{
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;          
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
                if (isconfigured == 1) {
                    move_to_layout_position();
                    state ready;
                }
            }                  
        }
    }
    on_rez(integer start_param)
    {
        llResetScript();
    }        
}

state ready {    
            
    state_entry()
    {
        llListen(232323, "", rezzer_uuid, "");        
    } 

    // Listen for reconfiguration
    link_message( integer sender_num, integer num, string str, key id)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG) {
            // Split the message into lines
            list lines = llParseString2List(str, ["\n"], []);
            integer numlines = llGetListLength(lines);
            integer i = 0;
            for (i=0; i < numlines; i++) {
                isconfigured = sloodle_handle_command(llList2String(lines, i));
                if (isconfigured == 1) {
                    move_to_layout_position();
                }
            }  
        }
    }   

    listen(integer channel, string name, key id, string message) {
    
       // llOwnerSay(message);
    
        list bits = llParseString2List( message, ["|"], [] );
        vector change_pos = (vector)llList2String( bits, 0 );
        rotation change_rot = (rotation)llList2String( bits, 1 );
        vector parent_pos = (vector)llList2String( bits, 2);
       // llOwnerSay("got message" + message);       

        // Apply the position changes first, then the rotation
        vector before_pos = llGetPos();
        if (before_pos.z > 0) { // sometimes this comes out at 0, but we don't want to go to the corner of the sim
            llSetPos( before_pos - change_pos );
        }

        before_pos = llGetPos();
        rotation before_rot = llGetRot();

        //llOwnerSay("Rot: "+(string)llRot2Euler(change_rot));
        // llOwnerSay((string)(before_rot - change_rot));
        // llOwnerSay("new pos: "+(string)(llGetPos() + ( before_pos - parent_pos) * change_rot));
        //change_rot = llEuler2Rot( < 0, 0, 15 * DEG_TO_RAD > ); // pretend we rotated 15 degrees
        vector currentPosition = llGetPos();
        vector currentOffset = currentPosition - parent_pos;
        //llOwnerSay("I plan to be "+(string)llVecDist(currentOffset, <0,0,0>)+" from parent");
        vector rotatedOffset = currentOffset * change_rot;
        vector newPosition = parent_pos + rotatedOffset;
        llSetPos(newPosition);
        
        //llOwnerSay("new pos: "+(string)(llGetPos() + ( ( before_pos - parent_pos) * change_rot ) ) );        
        // llSetPos( before_pos + ( ( parent_pos - before_pos ) * change_rot ) );        
        
        llSetRot( llGetRot() * change_rot );

        //  llGetPos() + vPosOffset * llGetRot(), ZERO_VECTOR, llGetRot()        
        
    }
    on_rez(integer start_param)
    {
        llResetScript();
    }        
}


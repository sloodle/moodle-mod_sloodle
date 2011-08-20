integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_OWNER = -1639270111; // set the main shared media panel to the specified URL, accessible to the owner

integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_GROUP = -1639270112; // set the main shared media panel to the specified URL, accessible to the group

integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_ANYONE = -1639270114; // set the main shared media panel to the specified URL, accessible to anyone


default
{
   // touch_start(integer d){
   // llSay(0,(string)llDetectedTouchFace(0));
  //}
    state_entry(){

   }
    link_message( integer sender_num, integer num, string str, key id ){        
        
        if ( (num == SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_OWNER) || (num == SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_GROUP) ||(num == SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_ANYONE ) ) {
llSetColor(<1.00000, 1.00000, 1.00000>,3);
            integer perms = PRIM_MEDIA_PERM_OWNER;
            if (num == SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_GROUP) {
                perms = PRIM_MEDIA_PERM_GROUP;
            } else if (num == SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_ANYONE) {
                perms = PRIM_MEDIA_PERM_GROUP;
            }
                              

                
            llSetPrimMediaParams( 3, [ PRIM_MEDIA_CURRENT_URL, str, PRIM_MEDIA_HOME_URL, str, PRIM_MEDIA_FIRST_CLICK_INTERACT, TRUE, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, perms, PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE ] );

//        llSetPrimMediaParams( 3, [ PRIM_MEDIA_CURRENT_URL, str, PRIM_MEDIA_HOME_URL, str, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, perms, PRIM_MEDIA_PERMS_CONTROL, perms ] );                
            
        }

    }
            
    on_rez(integer start_param) {
        llClearPrimMedia(3);    
    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_shared_media_screen.lsl

default
{
    link_message( integer sender_num, integer num, string str, key id ){
        
        if ( (num == PRIM_MEDIA_PERM_OWNER) || (num == PRIM_MEDIA_PERM_GROUP) ||(num == PRIM_MEDIA_PERM_ANYONE ) ) {
                          
            llSetPrimMediaParams( 0, [ PRIM_MEDIA_CURRENT_URL, str, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, num, PRIM_MEDIA_PERMS_CONTROL, num ] );
            llSetPrimMediaParams( 0, [ PRIM_MEDIA_HOME_URL, str, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, num, PRIM_MEDIA_PERMS_CONTROL, num ] );
            
        }

    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/scoreboard-1.0/sloodle_admin_control_panel.lsl

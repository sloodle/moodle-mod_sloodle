//
// The line above should be left blank to avoid script errors in OpenSim.

integer SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_SET_ADMIN_URL_CHANNEL = -1639271128; // This is the channel that the scoreboard shouts out its admin URL
integer SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_CHANGE_ADMIN_URL_CHANNEL= -1639271129; // This is the channel that the scoreboard shouts out its admin URL WHEN It has changed due to a region event (lost its url etc)
integer face = 4;
key currentScoreboard;
vector localpos;
default
{
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        llListen(SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_SET_ADMIN_URL_CHANNEL, "", "", "");
        llListen(SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_CHANGE_ADMIN_URL_CHANNEL, "", "", "");
        llClearPrimMedia(face);
        
    }
   
  link_message(integer sender_num, integer num, string str, key id) {
      
  if (str== "hide")
        {  
            
            vector localpos = llGetLocalPos();
            llSetPos(<localpos.x, localpos.y, (localpos.z - 0.75)>); 
                   
        }
        
     if (str == "show")
        {  
            vector localpos = llGetLocalPos();
            llSetPos(<localpos.x, localpos.y, (localpos.z + 0.75)>);            
        }    
  
  }
       //this listen event gets fired after the owner has touched a scoreboard which is there, and has selected "update" from the
       //dialog menu
    listen(integer channel, string name, key id, string message) {
       
        list parsedMsg = llParseString2List(message, ["|"], []);
        //format: (string)admin_url+"|"+(string)llGetOwner()+"|"+(string)llGetKey()); 
        string admin_url = llList2String(parsedMsg,0);
        key owner = llList2Key(parsedMsg,1);
        //check if the shoutout's uuid has the same owner as this hud (ie: the owner touched it and is wearing a hud)
        if (owner!=llGetOwner())return;
        
        
        if (channel == SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_SET_ADMIN_URL_CHANNEL){
            currentScoreboard= id;
            //set media    
            llSetPrimMediaParams( face, [ PRIM_MEDIA_CURRENT_URL, admin_url, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, face, PRIM_MEDIA_PERMS_CONTROL, face ] );
            llSetPrimMediaParams( face, [ PRIM_MEDIA_HOME_URL, admin_url, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, face, PRIM_MEDIA_PERMS_CONTROL, face ] );
        }else
        if (channel == SLOODLE_CHANNEL_SCOREBOARD_SHARED_MEDIA_CHANGE_ADMIN_URL_CHANNEL){
            currentScoreboard= id;
            //set media
            llSetPrimMediaParams( face, [ PRIM_MEDIA_CURRENT_URL, admin_url, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, face, PRIM_MEDIA_PERMS_CONTROL, face ] );
            llSetPrimMediaParams( face, [ PRIM_MEDIA_HOME_URL, admin_url, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, face, PRIM_MEDIA_PERMS_CONTROL, face ] );
        }            
    }
   
     attach(key id) {
        vector correctrot = <0,0,0> * DEG_TO_RAD;
        llSetRot(llEuler2Rot(correctrot));   
    }
    
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/scoreboard-1.0/sloodle_admin_hud.lsl 

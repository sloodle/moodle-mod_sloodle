//
// The line above should be left blank to avoid script errors in OpenSim.

integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_OWNER = -1639270111; // set the main shared media panel to the specified URL, accessible to the owner
integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_GROUP = -1639270112; // set the main shared media panel to the specified URL, accessible to the group
integer SLOODLE_CHANNEL_SET_SET_SHARED_MEDIA_URL_ANYONE = -1639270114; // set the main shared media panel to the specified URL, accessible to anyone
integer side = 0;
string searchterm="";
string caption = "";
string title = "";
setData(string searchTerm,string caption,string title){
         llClearPrimMedia(side);
        string twitterText ="<body><script>";
        twitterText +="new TWTR.Widget({";
        twitterText +="version: 2,";
        twitterText +="type: 'search',";
        twitterText +="search: '"+searchTerm+"',";
        twitterText +="interval: 30000,";
        twitterText +="title: '"+title+"',";
        twitterText +="subject: '"+caption+"',";
        twitterText +="width: 250,";
        twitterText +="height: 300,";
        twitterText +="theme: {";
        twitterText +="shell: {";
        twitterText +="background: '#7c001a',";
        twitterText +="color: '#ffffff'";
        twitterText +="},";
        twitterText +="tweets: {";
        twitterText +="background: '#ffffff',";
        twitterText +="color: '#444444',";
        twitterText +="links: '#1985b5'";
        twitterText +="}";
        twitterText +="},";
        twitterText +="features: {";
        twitterText +="scrollbar: false,";
        twitterText +="loop: true,";
        twitterText +="live: true,";
        twitterText +="hashtags: true,";
        twitterText +="timestamp: true,";
        twitterText +="avatars: true,";
        twitterText +="toptweets: true,";
        twitterText +="behavior: 'default'";
        twitterText +="}";
        twitterText +="}).render().start();";
        twitterText +="</script>";
        string url = "data:text/html,<head><script src=\"http://widgets.twimg.com/j/2/widget.js\"></script></head>";
        
        url+=twitterText+ "</body>";
        llSetPrimMediaParams( side, [ PRIM_MEDIA_CURRENT_URL, url, PRIM_MEDIA_HOME_URL, url, PRIM_MEDIA_FIRST_CLICK_INTERACT, TRUE, PRIM_MEDIA_AUTO_ZOOM, TRUE, PRIM_MEDIA_AUTO_PLAY, TRUE, PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER, PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE ] );
}

string text;
integer channel;
string SLOODLE_EOF = "sloodleeof";
integer eof= FALSE;
integer isconfigured=FALSE;
integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343; // an arbitrary channel the sloodle scripts will use to talk to each other. Doesn't atter what it is, as long as the same thing is set in the sloodle_slave script.
string chalkboardtext;
integer newChannel;

integer sloodle_handle_command(string str) 
        {
    
            list bits = llParseString2List(str,["|"],[]);
            integer numbits = llGetListLength(bits);
            string name = llList2String(bits,0);
            string value1 = "";
            string value2 = "";
            
            if (numbits > 1) value1 = llList2String(bits,1);
            if (numbits > 2) value2 = llList2String(bits,2);
            
            if (name == "set:searchterm"){
                 searchterm= (string)value1;
            }else
            if (name == "set:caption"){
                 caption= (string)value1;
            }else
            if (name == "set:title"){
                 title= (string)value1;
            }else
            
            if (name == "set:channel"){
                 channel= (integer)value1;
                 llListenRemove(newChannel);
                 
                 newChannel = llListen(channel, "", llGetOwner(), "");
                 llOwnerSay("Listening to " +llKey2Name(llGetOwner())+" on "+(string)channel+"  \nType /"+(string)channel+" searchterm, to change the search term");
            }
            else if (name == SLOODLE_EOF) eof = TRUE;
          
            return (searchterm != ""&&caption!=""&&title!="");
        }
default
{
   // touch_start(integer d){
   
  //}
    state_entry(){
        //llClearPrimMedia( side);
        llListenRemove(newChannel);
        newChannel = llListen(channel, "", llGetOwner(), "");
         llOwnerSay("Listening to " +llKey2Name(llGetOwner())+" on "+(string)channel+"  \nType /"+(string)channel+" searchterm, to change the search term");
       
   }
   listen(integer channel, string name, key id, string message) {
           llClearPrimMedia(side);
           setData(message,caption,title);
   }
   
     
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
                    }if (isconfigured){
                        setData(searchterm,caption,title);
                    
                    }
                }
    }
            
    on_rez(integer start_param) {
        llClearPrimMedia(side);                
        // Give the object a starting texture.
        // If we just use llClearPrimMedia here, we get a strange problem where if you click on it before it's ready, autozoom fails until you look away then look back.
       
    } 
                
           
    }
   
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/furniture-1.0/object_scripts/twitterwall.lsl

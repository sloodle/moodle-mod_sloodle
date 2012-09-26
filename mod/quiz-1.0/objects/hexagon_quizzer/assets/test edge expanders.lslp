	integer SLOODLE_CHANNEL_ANIM= -1639277007;
	
	integer TOGGLE=-1;
	default {
	    state_entry() {
	       llListen(-9, "", llGetOwner(), "");
	    }
	   listen(integer channel, string name, key id, string message) {
	        if (TOGGLE==-1){
	            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "edge expand show|1,2,3,4,5,6|10", NULL_KEY);
	            
	
	            TOGGLE=1;
	            llSay(0,"open");
	        }else
	        if (TOGGLE==1){
	            llSay(0,"close");
	            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_ANIM, "edge expand hide|1,2,3,4,5,6|10", NULL_KEY);
	                                                
	            TOGGLE=-1;
	        }
	        
	    }
	}

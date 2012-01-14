integer SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_STARTED = -1639270082;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_FINISHED = -1639270083;
integer SLOODLE_CHANNEL_OBJECT_CREATOR_WILL_REZ_AT_POSITION = -1639270084;
integer SLOODLE_CHANNEL_SET_CONFIGURED = -1639270091;
integer SLOODLE_CHANNEL_SET_RESET = -1639270092;


default
{
    link_message(integer sender_num, integer num, string str, key id) {
        if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_STARTED) {
        // TODO: Change color or something
        //llSetTimerEvent(5.0);         
        } else if (num == SLOODLE_CHANNEL_OBJECT_CREATOR_REZZING_FINISHED) {
          //  llParticleSystem([]);
        } else if (num == SLOODLE_CHANNEL_SET_CONFIGURED) {
        } else if (num == SLOODLE_CHANNEL_SET_RESET) {
        }
    }
    state_entry()
    {
        llSetText("", <0,0,0>, 0.0);
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/set-1.0/sloodle_set_effects_simple.lsl

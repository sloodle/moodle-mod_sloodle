// This is a Particles and Sound Effects Script for the SLOODLE Stipend GIVER
// If you'd like to prevent sounds and particles 
// from playing in the stipendgiver, simply delete this script
// You may also modify the sounds played in this script by replacing the Sound UUID's within the script itself
//
// This script is part of the Sloodle project.
// Copyright (c) 2008 Sloodle (various contributors)
// Released under the GNU GPL v3
//
// Contributors:

//  Paul Preibisch - aka Fire Centaur
//
        

integer SLOODLE_CHANNEL_OBJECT_DIALOG = -3857343;
key avkey;
list data;
string command;
//sloodle particle effect when the user gets money
StartParticles (key id)
{
    llParticleSystem ([
        PSYS_SRC_PATTERN,2,
        PSYS_PART_FLAGS,
        (0|PSYS_PART_INTERP_SCALE_MASK|PSYS_PART_FOLLOW_SRC_MASK),
        PSYS_PART_START_COLOR, <0.96,0.99,0.95>,
        PSYS_PART_END_COLOR, <0.44,0.93,0.06>,
        PSYS_PART_START_ALPHA, 0.76,
        PSYS_PART_END_ALPHA, 0.00,
        PSYS_PART_START_SCALE, <0.75,0.18,0>,
        PSYS_PART_END_SCALE, <1.82,1.85,0>,
        PSYS_SRC_BURST_SPEED_MIN, 13.10,
        PSYS_SRC_BURST_SPEED_MAX, 0.00,
        PSYS_SRC_ACCEL, <-1.63,-1.32,-1.65>,
        PSYS_SRC_OMEGA, <1.17,-0.26,1.06>,
        PSYS_SRC_ANGLE_END, 0.00,
        PSYS_SRC_ANGLE_BEGIN, 0.03,
        PSYS_PART_MAX_AGE, 13.03,
        PSYS_SRC_BURST_PART_COUNT, 81,
        PSYS_SRC_BURST_RATE, 8.84,
        PSYS_SRC_BURST_RADIUS, 14.16,
        PSYS_SRC_MAX_AGE, 8.54,
        PSYS_SRC_TEXTURE, "c053ac85-c412-0a0e-5a85-774745118c00",
        PSYS_SRC_TARGET_KEY, id
            ]);
}
StopParticles ()
{
    llParticleSystem ([]);
}


default
{

    link_message( integer sender_num, integer num, string str, key id)
    {
        // Received a link message possibly containing configuration data.
        // Split it up and process it.

        // Check the channel
        if (num == SLOODLE_CHANNEL_OBJECT_DIALOG)
        {
            // Split the message into lines
            list data = llParseString2List(str, ["|"], []);
            integer i = 0;
            command = llList2String(data,0);

            //********poofer effects
            if (command=="poof:money"){
                avkey= llList2Key(data,1);
                state poofer;
            }else
            //*******Sound effects

            if (command=="playsound:rez"){
                llPlaySound("676bd8f1-a061-72f4-b56c-93408f9cba46", 1.0);
            }else
            if (command=="playsound:startup"){
                llPlaySound("676bd8f1-a061-72f4-b56c-93408f9cba46", 1.0);
            }else
            if (command=="playsound:userclick"){
                llPlaySound("50091bcd-d86d-3749-c8a2-055842b33484",1.0);
            }else
            if (command=="playsound:nomoney"){
                llPlaySound("d5da8d8e-23de-5a07-b4da-ad2ff5ea97e7",1.0);
            }

        }
    }
}

state poofer{


    state_entry(){
        StartParticles(avkey);
        //nice money sound
        llPlaySound("676bd8f1-a061-72f4-b56c-93408f9cba46",1.0);
        llSetTimerEvent(1.0);
    }
    timer(){
        StopParticles ();
        state default;

    }
    state_exit(){
        llSetTimerEvent(0.0);

    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/particle_and_sound_effects.lsl 

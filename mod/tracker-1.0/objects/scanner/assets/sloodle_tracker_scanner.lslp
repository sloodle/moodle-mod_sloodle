//
// The line above should be left blank to avoid script errors in OpenSim.

// This file is part of SLOODLE Tracker.
// Copyright (c) 2009-11 Sloodle community (various contributors)
    
// SLOODLE Tracker is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
    
// SLOODLE Tracker is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License.
// If not, see <http://www.gnu.org/licenses/>
//
// Contributors:
// Peter R. Bloomfield  
// Julio Lopez (SL: Julio Solo)
// Michael Callaghan (SL: HarmonyHill Allen)
// Kerri McCusker  (SL: Kerri Macchi)

// A project developed by the Serious Games and Virtual Worlds Group.
// Intelligent Systems Research Centre.
// University of Ulster, Magee    


integer CHANNEL = 447851; // Channel for the tasks to comunicate  
string MY_TYPE = "scanner"; // What type of tracker tool is this?
float RANGE = 20.0; // How far should we scan?
integer REPORT_SCANS = FALSE; // TRUE means every avatar who is scanned will be reported in local chat. FALSE disables this.

// Used to know who has already been detected and sent to Moodle.
list recorded = [];
list not_reported = [];
key httpchat = NULL_KEY; // Request used to send/receive chat


default
{
    state_entry()
    {
        llSetTimerEvent(30.0);  
        llSensorRepeat("", NULL_KEY, AGENT, RANGE, PI,5);
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
        
    sensor(integer total_number)
    {
        // Go through each detected avatar to see if it has been recorded yet
        integer i = 0;
        for (i = 0; i < total_number; i++)
        {
            key id = llDetectedKey(i);
            if (llListFindList(recorded, [id]) < 0)
            {
                not_reported += [id];
                recorded += [id];
            }
        }

        // Report each new avatar
        if (not_reported != [])
        {
            key id_object = llGetKey();
            string name_object = llGetObjectName();

            i = 0;
            integer numNotReported = llGetListLength(not_reported);
            for (i = 0; i < numNotReported; i++)
            {
                llMessageLinked(LINK_THIS, CHANNEL, "INTERACTION|"+MY_TYPE+"|1", llList2Key(not_reported,i));
                llSleep(1.0);
            }
            not_reported = [];
        }
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Was this an interaction response?
        if (sval == "INTERACTION_RESPONSE" && kval != NULL_KEY)
        {
            if (REPORT_SCANS) llSay(0,  "Avatar detected: " + llKey2Name(kval));
        }
    }
 
    touch_start(integer total_number)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            llSensorRemove();
            state off;
        } else {
            string name = llDetectedName(0);
            llSay(0, "Sorry, " + name + ", you can't control this object.");
        }
    }
    
    timer()
    {
        recorded = [];
        not_reported = [];
    }
}


state off
{
    state_entry()
    {
        llSetText("Scanner OFF", <0.0, 1.0, 0.0>, 0.8);
    }
    
    state_exit()
    {
        llSetText("", <0.0, 1.0, 0.0>, 0.8);
    }
    
    touch_start(integer total_number)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            recorded = [];
            not_reported = [];
            state default;
        } else {
            string name = llDetectedName(0);
            llSay(0, "Sorry, " + name + ", you can't control this object.");
        }
    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/tracker-1.0/sloodle_tracker_scanner.lsl

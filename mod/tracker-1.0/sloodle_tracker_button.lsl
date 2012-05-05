//
// The line above should be left blank to avoid script errors in OpenSim.

// This file is part of SLOODLE Tracker.
// It provides the button functionality.
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
string MY_TYPE = "button"; // What type of tracker tool is this?

default
{
    touch_start(integer total_number)
    {
        // Inform the main script of each avatar who has touched this object
        integer i = 0;        
        for (i = 0; i < total_number; i++)
        {
            llMessageLinked(LINK_THIS, CHANNEL, "INTERACTION|"+MY_TYPE+"|0", llDetectedKey(i));
        }
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Was this an interaction response?
        if (sval == "INTERACTION_RESPONSE" && kval != NULL_KEY)
        {
            llSay(0, llKey2Name(kval) + " touched this button.");
        }
    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/tracker-1.0/sloodle_tracker_button.lsl

//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*  Part of the Sloodle project (www.sloodle.org)
*  movelikeashark.lsl
*
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
*  -------------------------------------------
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  All scripts must maintain this copyrite information, including the contributer information listed
* 
*  As mentioned, this script has been  licensed under GPL 3.0
*  Basically, that means, you are free to use the script, commercially etc, but if you include
*  it in your objects, you must make the source viewable to the person you are distributuing it to -
*  ie: it can not be closed source - GPL 3.0 means - you must make it open!
*  This is so that others can modify it and contribute back to the community.
*  The SLOODLE github can be found here: https://github.com/sloodle
*
*  Enjoy!
*
*  Contributors:
*   Paul Preibisch
*   Edmund Edgar
*
*  DESCRIPTION
*  makes the object's movements look like a fish 
*/


vector degrees_of_swish = < 0.0, 0.0, 10.0 >;
vector degrees_of_antiswish = < 0.0, 0.0, -10.0 >;

rotation quat_of_swish;
rotation quat_of_antiswish;
integer side = 0;

default
{
    state_entry()
    {
        degrees_of_swish *= DEG_TO_RAD;
        degrees_of_antiswish *= DEG_TO_RAD;
        
        quat_of_swish = llEuler2Rot( degrees_of_swish );
        quat_of_antiswish = llEuler2Rot( degrees_of_antiswish );
        
        llSetTimerEvent( 1.5 );
        side = 1;
    }

    timer()
    {
        if ( side != 1 )
        {
            //llSetLocalRot( llGetLocalRot() * quat_of_swish  );
            //llSetPrimitiveParams([ PRIM_ROTATION, ( (llGetRot() * quat_of_swish) / llGetRootRotation() ) ]);
            llSetPrimitiveParams([ PRIM_ROTATION, ( quat_of_swish * llGetRootRotation() ) ]);
            side = 1;
        }
        else
        {
            //llSetLocalRot( llGetLocalRot() * quat_of_antiswish );
            //llSetPrimitiveParams([ PRIM_ROTATION, ( (llGetRot() * quat_of_antiswish) / llGetRootRotation() ) ]);
            llSetPrimitiveParams([ PRIM_ROTATION, ( quat_of_antiswish * llGetRootRotation() ) ]);
            side = 2;
        }
        
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/gaming-1.0/object_scripts/sharks/movelikeashark.lsl 

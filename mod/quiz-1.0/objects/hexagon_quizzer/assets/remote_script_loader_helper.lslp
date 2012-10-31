//
// The line above should be left blank to avoid script errors in OpenSim.

// LSL script generated: mod.set-1.0.rezzer_reset_btn.lslp Tue Nov 15 15:49:28 Tokyo Standard Time 2011
/*
*  Part of the Sloodle project (www.sloodle.org)
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
*  Contributors:
*  Paul Preibisch
*
*  DESCRIPTION
*  remote_script_loader_helper.lslp
*  This script is responsible for:
*  *** remote loading a script into a prim.  Used by other scripts to avoid script sleep. 
*  *** This script will sleep for 3 seconds after executing the llRemoteLoadScriptPin command due to Lsl caveats - see http://wiki.secondlife.com/wiki/LlRemoteLoadScriptPin
*      
*
*/
integer SLOODLE_REMOTE_LOAD_SCRIPT=1639277018;
integer my_script_id;
debug (string message ){
     list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
     if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay("memory: "+(string)llGetFreeMemory()+" Script name: "+llGetScriptName ()+": " +message );
     }
} 

default {
    on_rez(integer start_param) {
        llResetScript();
    }
    state_entry() {
        integer begin = llStringLength("remote_script_loader_helper.lslp")-1; 
        integer end=-1; 
        my_script_id=(integer)llGetSubString(llGetScriptName(), begin,end);
        
    }
    link_message(integer sender_num, integer channel, string str, key id) {
        //llMessageLinked(LINK_SET, SLOODLE_REMOTE_LOAD_SCRIPT, "0|"+(string)PIN+"|sloodle_translation_en.lslp", platform);
        list data = llParseString2List(str, ["|"], []);
        integer script_num = llList2Integer(data,0);
        integer PIN = llList2Integer(data,1);
        string script_name = llList2String(data,2);
        key destination = llList2Key(data,3);
        integer running = llList2Integer(data,4); 
        integer start_param = llList2Integer(data,5);
        if (channel == SLOODLE_REMOTE_LOAD_SCRIPT){
            if (script_num!=my_script_id){
                return;
            }
            llRemoteLoadScriptPin(destination, script_name, PIN, running, start_param);
            debug(llGetScriptName()+ "my id is: " + (string)my_script_id+ "I am loading " + script_name+ " into "+(string)destination);
        
        }
        
    }
}

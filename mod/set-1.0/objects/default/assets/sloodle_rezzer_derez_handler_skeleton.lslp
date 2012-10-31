//
// The line above should be left blank to avoid script errors in OpenSim.

/*********************************************
*  Copyright (c) 2009 - 2012 various contributors (see below)
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  sloodle_rezzer_derez_handler_skeleton
*  Copyright:
*  Paul G. Preibisch (Fire Centaur in SL) fire@avatarclassroom.com  
*  Edmund Edgar (Edmund Earp in SL) ed@avatarclassroom.com
*
*  This script will wait for a linked message on the SLOODLE_CHANNEL_SET_CLEANUP_AND_DEREZ channel.
*  When it gets a message from the sloodle_rezzer_object script, it should do any cleanup tasks it needs to do, then llDie().
*  It is intended for times when an object needs to do something before derezzing.
*  For example, it may have rezzed child objects that need also to be derezzed...
*  ... or it may have been given inventory that it needs to do something with, like giving it to the owner.
*
*  Do not include a version of this script in your object if you don't need to do anything except llDie().
*  If a script called sloodle_rezzer_derez_handler doesn't exist, llDie() will be called automatically by sloodle_rezzer_object.
*/

// THIS IS AN EXAMPLE. REPLACE THE llOwnerSay() CODE WITH SOMETHING USEFUL.

integer SLOODLE_CHANNEL_SET_CLEANUP_AND_DEREZ = -1639270131; // linked message to tell the object to derez if it has some object-specific cleanup tasks.

default
{
    link_message(integer sender_num, integer num, string msg, key id) 
    {
        if (num == SLOODLE_CHANNEL_SET_CLEANUP_AND_DEREZ) {
            llOwnerSay("Perform custom cleanup steps here.");
            llSleep(2);
            llDie(); // You should always do this once you're finished.
        }
    }
}

// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/set-1.0/objects/default/assets/sloodle_rezzer_derez_handler_skeleton.lslp


/**********************************************************************************************
*  AccessPin.lsl
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL as part of the SLOODLE.org Project
*
*  Contributors:
*  Paul G. Preibisch (Fire Centaur in SL)
*  fire@b3dMultiTech.com
*  
*  PURPOSE
*  This script enables other scripts to copy items into its inventory.
*
**********************************************************************************************/

default
{
    state_entry()
    {
       llSetRemoteScriptAccessPin(5577);
    }

}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/AccessPin.lsl 

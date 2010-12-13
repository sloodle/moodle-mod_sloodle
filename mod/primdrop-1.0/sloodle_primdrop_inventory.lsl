// Sloodle PrimDrop inventory checker.
// Receives dropped prims, and checks for the most recently added one
// Part of the Sloodle project (www.sloodle.org)
//
// Copyright (c) 2007-8 Sloodle
// Released under the GNU GPL
//
// Contributors:
//  Jeremy Kemp
//  Peter R. Bloomfield
//


///// DATA /////

// Link message channel
integer SLOODLE_CHANNEL_PRIMDROP_INVENTORY = -1639270071;
// Link message identifiers
string PRIMDROP_RECEIVE_DROP = "do:receivedrop"; // Instructs the object to receive a drop
string PRIMDROP_CANCEL_DROP = "do:canceldrop"; // Cancel drop receiving
string PRIMDROP_FINISHED_DROP = "set:droppedobject"; // The drop has finished (object name passed as parameter after pipe character)

// Stores the inventory
list inventory = [];


///// FUNCTIONS /////


// Returns a list of all inventory (all types)
list get_inventory(integer type)
{
    list inv = [];
    integer num = llGetInventoryNumber(type);
    integer i;
    for (i = 0; i < num; i++) {
        inv += [llGetInventoryName(type, i)];
    }
    
    return inv;
}


// Compares 2 lists
// Returns the first item on list1 that is not on list2
// Returns an empty string if nothing is found
string ListDiff(list list1, list list2) {
    integer i;

    for (i = 0; i < llGetListLength(list1); i++) {
        if (llListFindList(list2, llList2List(list1, i, i)) == -1) {
            return(llList2String(list1, i));
        }
    }
    return("");
}

///// STATES /////

// Idle state - waiting to be instructed to receive a drop
default
{
    state_entry()
    {
        llAllowInventoryDrop(FALSE);
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_PRIMDROP_INVENTORY) {
            if (sval == PRIMDROP_RECEIVE_DROP) {
                // Start awaiting a drop
                state drop;
                return;
            }
        }
    }
}

// Waiting for a drop to take place
state drop
{
    state_entry()
    {
        // Check our current inventory
        inventory = get_inventory(INVENTORY_ALL);
        // Prepare to receive drops
        llAllowInventoryDrop(TRUE);
    }
    
    state_exit()
    {
        llAllowInventoryDrop(FALSE);
    }
    
    changed(integer change)
    {
        // Has out inventory changed?
        if ((change & CHANGED_INVENTORY) || (change & CHANGED_ALLOWED_DROP)) {
            // Stop receiving inventory drops
            llAllowInventoryDrop(FALSE);
            // Check our new inventory, and find what's changed
            list new_inventory = get_inventory(INVENTORY_ALL);
            string submit_obj = ListDiff(new_inventory, inventory);
            new_inventory = [];
            inventory = [];
            
            // Notify the other script(s)
            llMessageLinked(LINK_SET, SLOODLE_CHANNEL_PRIMDROP_INVENTORY, PRIMDROP_FINISHED_DROP + "|" + submit_obj, NULL_KEY);
            state default;
            return;
        }
    }
    
    link_message(integer sender_num, integer num, string sval, key kval)
    {
        // Check the channel
        if (num == SLOODLE_CHANNEL_PRIMDROP_INVENTORY) {
            if (sval == PRIMDROP_CANCEL_DROP) {
                // Stop waiting for a drop
                llAllowInventoryDrop(FALSE);
                state default;
                return;
            }
        }
    }
    
    on_rez(integer par)
    {
        llResetScript();
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/primdrop-1.0/sloodle_primdrop_inventory.lsl 

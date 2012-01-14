integer toggle;
default
{
    state_entry() {
        llSetTexture("hidehud", ALL_SIDES);
        toggle=-1;
    }
    touch_start(integer total_number)
    {
        if (toggle==-1){
            llMessageLinked(LINK_SET,0,"hide",NULL_KEY);
            
            llSetTexture("showhud", ALL_SIDES);
            llSetObjectName("show");
        }else
        if (toggle==1){
            llMessageLinked(LINK_SET,0,"show",NULL_KEY);
            llSetTexture("hidehud", ALL_SIDES);
            llSetObjectName("hide");
        }
        toggle*=-1;
    }
}

// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/scoreboard-1.0/sloodle_admin_hud_show_hide_button.lsl 

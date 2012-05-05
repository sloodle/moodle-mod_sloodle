//
// The line above should be left blank to avoid script errors in OpenSim.

//////////
// SLODLE Quiz Chair Poseball (www.sloodle.org)
// For SLOODLE 0.4
//
// Note: designed for the "myCourse Quiz Chair" design, supplied by Solent University
//
// Copyright (c) 2009 SLOODLE Project (various contributors)
//
// Released under the GNU GPL v3.
//////////


// Name of the animation to use
string anim = "sit";
// Stores the key of the avatar who's sitting on us
key sitter = NULL_KEY;


// Start the poseball animation
startPoseballAnimation()
{
    if (anim != "sit") {
        llStopAnimation("sit"); // Stop the regular sit animation first
        llStartAnimation(anim);
    }
}

// Stop the poseball animation
stopPoseballAnimation()
{
    if (anim != "sit") {
        llStopAnimation(anim);
    }
}

// Checks if we have animation permissions for the current sitter.
integer gotAnimationPermissions()
{
    if (sitter == NULL_KEY) return FALSE;
    if ((llGetPermissions() & PERMISSION_TRIGGER_ANIMATION) && (llGetPermissionsKey() == sitter)) return TRUE;
    return FALSE;
}


default
{
    state_entry()
    {
        // Set our sit target
        llSitTarget(<0.25, 0.0, 0.4>, ZERO_ROTATION);
    }
    
    on_rez(integer par)
    {
        llResetScript();
    }
    
    changed(integer change)
    {
        // Has it been a link change?
        if (change & CHANGED_LINK) {
            // Is there an avatar sitting on us?
            key av = llAvatarOnSitTarget();
            if (av == NULL_KEY) {
                // Stop the animation
                if (gotAnimationPermissions()) stopPoseballAnimation();
                sitter = NULL_KEY;
                
            } else if (av != sitter) {
                // Make sure we have animation permission
                sitter = av;
                if (gotAnimationPermissions()) startPoseballAnimation();
                else llRequestPermissions(sitter, PERMISSION_TRIGGER_ANIMATION);    
            }
        }
        
    }
    
    run_time_permissions(integer perm)
    {
        // Permissions have been granted - start the animation
        if (perm & PERMISSION_TRIGGER_ANIMATION) startPoseballAnimation();
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/quiz-1.0/sloodle_quiz_chair_poseball.lsl 

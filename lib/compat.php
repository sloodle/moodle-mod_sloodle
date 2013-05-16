<?php
/*
Functions used for compatibility where the Moodle APIs change.
We should probably move db.php in here too.
*/
function sloodle_require_js($js) {

    global $PAGE;
    global $CFG;

    // Moodle 2.4
    // We could probably go earlier than this, but this is where it definitively breaks.
    if ($CFG->version >= 2012120303) {
        $PAGE->requires->js( new moodle_url($js) );
    } else {
        require_js($js);
    }

}

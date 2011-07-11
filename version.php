<?php

////////////////////////////////////////////////////////////////////////////////
//  Code fragment to define the module version etc.
//  This fragment is called by /admin/index.php
////////////////////////////////////////////////////////////////////////////////

$module->version  = 2011071104;
$module->requires = 2007021500;  // Requires Moodle 1.8

// For Moodle 2, we have to pretend we don't work on Moodle 1.9 or Moodle gets upset.
global $CFG;
if ($CFG->version > 2010060800) {
    $module->requires = 2010000000;  // Requires Moodle 2.0 
}

$module->cron     = 60;

?>

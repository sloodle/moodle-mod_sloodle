<?php

require(dirname(__FILE__).'/../lib/db.php');

/**
* Database upgrade script for Moodle's db-independent XMLDB.
* @ignore
* @package freemail 
*/


// This file keeps track of upgrades to
// the freemail module
//
// Sometimes, changes between versions involve
// alterations to database structures and other
// major things that may break installations.
//
// The upgrade function in this file will attempt
// to perform all the necessary actions to upgrade
// your older installation to the current version.
//
// If there's something it cannot do itself, it
// will tell you what you need to do.
//
// The commands in here will all be database-neutral,
// using the functions defined in lib/ddllib.php

function xmldb_freemail_upgrade($oldversion=0) {

    global $CFG, $THEME, $db;

    $result = true;

    return $result; 
}

?>

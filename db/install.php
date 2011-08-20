<?php

// This file replaces:
//   * STATEMENTS section in db/install.xml
//   * lib.php/modulename_install() post installation hook
//   * partially defaults.php

function xmldb_sloodle_install() {
    global $DB;
 
    // Moodle 2 only - on Moodle 1.x you'll have to insert them manually...
    if ($DB != null) {

        $newCurrency = new stdClass();
        $newCurrency->name="Credits";

        $DB->insert_record('sloodle_currency_types', $newCurrency, false);

    }

}

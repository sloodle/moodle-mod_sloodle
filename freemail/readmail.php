<?php
/**
* Freemail v1.1 with SL patch
*
* @package freemail
* @copyright Copyright (c) 2008 Serafim Panov
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @author Serafim Panov
* @contributor: Paul G. Preibisch - aka Fire centaur in Second Life
* @contributor: Edmund Edgar
*
*/

if (isset($argv)) {
    define('CLI_SCRIPT', true);
}
require_once "../../config.php";

// Class for handling an imap message connection, and fetching and parsing emails one by one.
require_once 'lib/freemail_imap_message_handler.php'; 

// The following are base classes, but with static methods to load inherited classes.

// We'll need an email_processor to parse our email - for example if it looks like a Second Life snapshot, we'll want one of those.
require_once 'lib/freemail_email_processor.php'; 

// It will then need to find something to do with the email, like import it into the blog.
require_once 'lib/freemail_moodle_importer.php';

$verbose = in_array("-v", $argv);
$daemon = in_array("-d", $argv);
$nodelete = in_array("-n", $argv); // Useful when testing. 

if ($nodelete && $daemon) {
    echo "Refusing to run in daemon mode with nodelete specified, as this will spam you into oblivion.\n";
    exit;
}

if ($daemon) {

    while ($handler = freemail_email_processor::read_mail($CFG, $verbose, $daemon, $handler, false)) {
        freemail_email_processor::verbose_output($verbose, "Handling run done, sleeping");
        sleep(2);
    }

} else {

    freemail_email_processor::read_mail($CFG, $verbose, $daemon, null, $nodelete);

}

exit;

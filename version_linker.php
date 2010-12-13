<?php
// This file is part of the Sloodle project (www.sloodle.org)

/**
* Version linker script, to allow in-world tools to check the Sloodle version information
*
* @package sloodle
* @copyright Copyright (c) 2007-8 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*
*/

// If called without any parameters, this script will return version info.
// If successful in checking version information, this script will return
//  with status code 1, and the data line will contain 2 fields.
// The first data field will be the Sloodle version (e.g. 0.2), and the
//  second will be the module verison (e.g. 2008020501).
// For example:
//
//  1
//  0.2|2008013101

// If an error occurs, then an appropriate standard status code will be given
//  and a message should be given in the status line.

// FUTURE WORK: the ability to query compatibility with a particular tool
//  version may implemented at some point. This will require a request
//  parameter, and will likely return "true" or "false" on the data line.

/** Let's SLOODLE know we're in a linker script. */
define('SLOODLE_LINKER_SCRIPT', true);

/** Sloodle/Moodle configuration information. */
require_once('sl_config.php');
/** Sloodle API. */
require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

// Process the request
sloodle_debug('Processing request...<br/>');
$sloodle = new SloodleSession();

// Check the installed Sloodle version
sloodle_debug('Checking for installed Sloodle version...<br/>');
$moduleinfo = get_record('modules', 'name', 'sloodle');
if (!$moduleinfo) {
 sloodle_debug('ERROR: Sloodle not installed<br/>');
 $sloodle->response->quick_output(-106, 'SYSTEM', 'The Sloodle module is not installed on this Moodle site.', false);
 exit();
}

// Extract the module version number
$moduleversion = (string)$moduleinfo->version;
sloodle_debug('Sloodle version: '.(string)SLOODLE_VERSION.'<br/>');
sloodle_debug("Module version: $moduleversion<br/>");

// Construct and render the response
sloodle_debug('Rendering response...<br/>');
$sloodle->response->set_status_code(1);
$sloodle->response->set_status_descriptor('OK');
$sloodle->response->add_data_line(array((string)SLOODLE_VERSION, $moduleversion));
sloodle_debug('<br/><pre>');
$sloodle->response->render_to_output();
sloodle_debug('</pre>');

exit();

?>

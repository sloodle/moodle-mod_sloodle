<?php
/**
* Interface script to view SLOODLE information about a particular course.
* Parameter 'id' should identify which course is being viewed.
*
* @package sloodle
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*/

/** SLOODLE and Moodle configuration */
require_once('sl_config.php');
/** General SLOODLE library functionality */
require_once(SLOODLE_LIBROOT.'/general.php');


// View the course
if (!sloodle_view('course')) error('SLOODLE: failed to display course view');

?>

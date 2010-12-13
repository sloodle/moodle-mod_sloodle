<?php
/**
* Interface script to view SLOODLE information about a particular SLOODLE module sub-type.
* Optional parameter '_type' should identify what type of resource is being viewed, e.g. 'module' (default), 'course', 'user', 'users'. This determines which script is loaded.
* Any other parameters depend upon which type of resource is being accessed.
*
* @package sloodle
* @copyright Copyright (c) 2008-9 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
*/

/** SLOODLE and Moodle configuration */
require_once('sl_config.php');
/** General SLOODLE library functionality */
require_once(SLOODLE_LIBROOT.'/general.php');

// Get the type of resource being accessed
$type = optional_param('_type', 'module', PARAM_CLEAN);

// View the course
if (!sloodle_view($type)) error('SLOODLE: failed to display resource type');

?>
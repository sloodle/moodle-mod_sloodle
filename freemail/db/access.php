<?php

/**
* Moodle capability definitions for the Freemail module.
*
* The capabilities are loaded into the database table when the module is
* installed or updated. Whenever the capability definitions are updated,
* the module version number should be bumped up.
*
* @package freemail 
* @copyright Copyright (c) 2008 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Edmund Edgar
*
*/

//
// The system has four possible values for a capability:
// CAP_ALLOW, CAP_PREVENT, CAP_PROHIBIT, and inherit (not set).
//
//
// CAPABILITY NAMING CONVENTION
//
// It is important that capability names are unique. The naming convention
// for capabilities that are specific to modules and blocks is as follows:
//   [mod/block]/<component_name>:<capabilityname>
//
// component_name should be the same as the directory name of the mod or block.
//
// Core moodle capabilities are defined thus:
//    moodle/<capabilityclass>:<capabilityname>
//
// Examples: mod/forum:viewpost
//           block/recent_activity:view
//           moodle/site:deleteuser
//
// The variable name for the capability definitions array follows the format
//   $<componenttype>_<component_name>_capabilities
//
// For the core capabilities, the variable is $moodle_capabilities.

// NOTE: many Sloodle components relate directly to Moodle components.
// In these cases, the standard capabilities for those components apply.
// For example, Sloodle module configuration is covered by the Moodle standard capability:
//  moodle/course:manageactivities

// Viewing and editing avatar details will be handled by the user profile capabilities.


$mod_freemail_capabilities = array(

    // Considered a 'staff' member in SL
    'mod/freemail:viewsummary' => array(
        'captype' => 'read',
        'contextlevel' => CONTEXT_MODULE,
        'legacy' => array(
            'teacher' => CAP_ALLOW,
            'editingteacher' => CAP_ALLOW,
            'coursecreator' => CAP_ALLOW,
            'admin' => CAP_ALLOW,
            'user' => CAP_ALLOW,
            'guest' => CAP_PREVENT,
            'student' => CAP_ALLOW,
        )
    ),

    // Whether we'll let you blog using email
    'mod/freemail:emailtoblog' => array(
        'captype' => 'write',
        'contextlevel' => CONTEXT_MODULE,
        'legacy' => array(
            'user' => CAP_ALLOW,
            'guest' => CAP_PREVENT,
            'student' => CAP_ALLOW,
            'teacher' => CAP_ALLOW,
            'editingteacher' => CAP_ALLOW,
            'coursecreator' => CAP_ALLOW,
            'admin' => CAP_ALLOW
        )
    )

);

?>

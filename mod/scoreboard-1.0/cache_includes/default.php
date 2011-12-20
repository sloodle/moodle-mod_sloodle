<?php
SloodleDebugLogger::log('DEBUG', 'in incldue');
    // This script is part of the Sloodle project
    // Created for Avatar Classroom, with the intention of eventually being ported back to regular Sloodle.
    // Some assumptions that are true for Avatar Classroom won't be true for arbitrary Moodle sites.

    /**
    * @package sloodle
    * @copyright Copyright (c) 2011 various contributors (see below)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    *
    */

	require_once(dirname(__FILE__).'/../shared_media/scoreboard_active_object.inc.php');
	require_once '../../../lib/json/json_encoding.inc.php';
	//ini_set('display_errors', 1);
	//error_reporting(E_ALL);

	// Register the set using URL parameters

	$content = array();

        $sao = SloodleScoreboardActiveObject::ForUUID( $this->uuid );

        $is_admin = false;

        $student_scores = $sao->get_student_scores($is_admin);
	$result = 'refreshed';

	$content = array(
		'result' => $result,
		'error' => $error,
		'updated_scores' => $student_scores
	);

	$output = json_encode($content);
	$sao->write_cache_output($output, 'refresh_changed_scores.json');

?>

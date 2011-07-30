<?php
	require_logout();
	header('Location: http://api.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/'.$baseurl.'&ts='.time().'&logout');
	exit;
?>

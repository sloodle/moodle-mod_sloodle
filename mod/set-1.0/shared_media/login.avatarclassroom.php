<?php
require_once('../../../sl_config.php');

require_once('/var/www/instantclassroom/master/resources/lib/avatar_classroom_session.inc.php');

if (!$USER || !$USER->id) {

	$session = new AvatarClassroomSignedSiteListSession();
	if ($session->isUserAllowedToUseSite('http://'.$_SERVER['SERVER_NAME'])) {
		$user = get_record('user', 'username', 'admin');
		if ($user) {
			add_to_log(SITEID, 'user', 'login', "", $user->id, 0, $user->id);
			$USER = complete_user_login($user);
			header('Location: index.php?'.$_SERVER['QUERY_STRING']);
		}
	}
	header('Location: '.'http://api.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/index.php?'.$_SERVER['QUERY_STRING']);
	exit;

}
?>

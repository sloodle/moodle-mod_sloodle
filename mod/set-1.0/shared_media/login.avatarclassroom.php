<?php
if ( !defined('SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE') || (SLOODLE_SHARED_MEDIA_LOGIN_INCLUDE == '') ) {
    exit;
}

require_once('/var/www/instantclassroom/master/resources/lib/avatar_classroom_session.inc.php');

if (!$USER || !$USER->id) {

	$session = new AvatarClassroomSignedSiteListSession();
	if ($session->isUserAllowedToUseSite('http://'.$_SERVER['SERVER_NAME'])) {
		$user = sloodle_get_record('user', 'username', 'admin');
		if ($user) {
			add_to_log(SITEID, 'user', 'login', "", $user->id, 0, $user->id);
			$USER = complete_user_login($user);
			header('Location: index.php?'.$_SERVER['QUERY_STRING']);
			exit;
		}
	}
    if (isset($_REQUEST['sloodleobjname'])) {
        // Old version
        header('Location: '.SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL.'index.php?'.$_SERVER['QUERY_STRING'].'&bounced');
    } else {
        // New version
        header('Location: '.SLOODLE_SHARED_MEDIA_SITE_LIST_BASE_URL.'main.php?sloodleobjuuid='.$_REQUEST['sloodleobjuuid']);
    }
	exit;

}
?>

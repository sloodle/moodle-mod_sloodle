<?php
//require_once('../../sl_config.php');

if (!$USER || !$USER->id) {

	$username = optional_param('username', NULL, PARAM_RAW);
	$password = optional_param('password', NULL, PARAM_RAW);

	$errors = array();
	$loggedin = false;

	if ($username && $password) {
		$user = authenticate_user_login($username, $password);
		//$user = get_record('user', 'username', 'admin')
		if ($user) {
			add_to_log(SITEID, 'user', 'login', "", $user->id, 0, $user->id);
			$USER = complete_user_login($user);
			redirect('index.php?'.$_SERVER['QUERY_STRING']);
			exit;
		} else {
			$errors[] = 'invalidlogin';
		}
	} 

	include('login.template.php');
	exit;

}
?>

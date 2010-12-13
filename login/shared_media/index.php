<?php
//require_once('../../sl_config.php');

if ($USER && $USER->id) {
	// logged in - ok
}

$username = optional_param('username', NULL, PARAM_RAW);
$password = optional_param('password', NULL, PARAM_RAW);

$errors = array();

if ($username && $password) {
	$user = authenticate_user_login($username, $password);
	if ($user) {
		add_to_log(SITEID, 'user', 'login', "", $user->id, 0, $user->id);
		$USER = complete_user_login($user);
	} else {
		$errors[] = 'invalidlogin';
	}
}

//require_once('../../../../login/index.php');
//$CFG->alternateloginurl
?>
<html>
<head>
<title>Login to Moodle</title>
</head>
<body>
<?php
//var_dump($USER);
?>
	<div class="outer_container">
		<div class="inner_container">
			<div class="error_message_container">
			<?php 
			if (count($errors) > 0) {
				foreach($errors as $err) {
					echo '<p class="error_message">'.$err.'</p>';
				}
			}
			?>
			</div>
			<form method="POST" class="login_form">
				<div class="username_container">	
					<input type="text" name="username" value="<?= htmlentities($username) ?>" />				
				</div>
				<div class="password_container">	
				<input type="password" name="password" value="" />				
				</div>
				<div class="username_container">	
					<input type="submit" value="Login" />				
				</div>
			</form>
		</div>
	</div>
</body>
</html>

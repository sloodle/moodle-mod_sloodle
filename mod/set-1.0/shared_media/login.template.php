<?php $full = false; ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Avatar Classroom Configuration</title>
<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
<link rel="apple-touch-icon" href="iui/iui-logo-touch-icon.png" />
<meta name="apple-touch-fullscreen" content="YES" />
<style type="text/css" media="screen">@import "iui/iui.css";</style>
<style type="text/css" media="screen">@import "layout.css";</style>
<!--
<script type="application/x-javascript" src="http://10.0.1.2:1840/ibug.js"></script>
-->
</head>

<body>

    <div class="toolbar">
        <h1 id="pageTitle">Login</h1>
<!--
        <a id="backButton" class="button" href="#"></a>
        <a class="button" href="index.php?logout">Logout</a>
-->
    </div>
     
<!--
    <ul id="home" title="Login" selected="true">
        <li class="group">Sites</li>
        <li class="group">Add a site</li>
        <li><a href="#addsite">Add a site</a></li>
	<li></li>
    </ul>
-->
<!--
			<div class="error_message_container">
 foreach($errors as $err) {
					echo '<p class="error_message">'.$err.'</p>';
				}
			}
			?>
			</div>
-->

	<form class="panel" id="home" method="POST" class="login_form" selected="true">
	<fieldset style="width:50%; margin-left:25%; margin-top:150px; margin-bottom:400px;">
		<?php if (count($errors) > 0) { ?>
		<div class="row" >
		<?php foreach($errors as $error) { ?>	
			<?=htmlentities($error) ?>
		<?php } ?>
		</div>
		<?php } ?>
		<div class="row" >
			<label for="username">Username</label>
			<input id="password" name="username" value="<?= htmlentities($username) ?>" class="panel" style="width:80%; height:40px; margin:10px;">
		</div>
		<div class="row" >
			<label for="password">Password</label>
			<input type="password" id="password" name="password" class="panel" style="width:80%; height:40px; margin:10px;">
		</div>
		<div class="row" >
			<input type="submit" id="login" value="Login" name="login" class="panel" style="width:90%; height:60px; margin:10px;">
		</div>
	</fieldset>
	</form>

</body>
</html>

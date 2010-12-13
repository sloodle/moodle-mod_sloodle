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
<style type="text/css" media="screen">@import "iui/iui_ext.css";</style>
<style type="text/css" media="screen">@import "layout.css";</style>
<script type="application/x-javascript" src="iui/iui.js"></script>
<script type="application/x-javascript" src="iui/iui_ext.js"></script>
<script type="application/x-javascript" src="../../../lib/jquery/jquery.js"></script>
<script type="text/javascript">
	iui.animOn = true;

	var actionStatus = 'unrezzed';
	var pendingRequests = new Object();
	var numPendingRequests = 0;
	var maxPendingRequests = 2;
	var timeoutMilliseconds = 20000;

	var statusPollingInterval= 5; // how often we should poll the server for activeobject updates

	var lastStatusPoll = 0;

	var timer;

	function purgeRequestList() {
/*
	// TODO: Purge the request list of things that have timed out.
	// That will cause the script to try them again.
		for (entryid in pendingRequests) {
			if ( ( pendingRequests[""+entryid] + timeoutMilliseconds ) > ( new Date().getTime() ) ) {
				$('#layoutentryid_'+entryid).removeClass('rezzing').addClass('timed_out');;
				delete pendingRequests[""+entryid];
				numPendingRequests--;
			}
		}	
*/
	}

	function update_labels() {
		$('li.waiting_to_rez > span.rezzable_item_status').html('Waiting to rez');
		$('li.rezzed > span.rezzable_item_status').html('Rezzed');
		$('li.rezzing> span.rezzable_item_status').html('Rezzing');
		$('li.waiting_to_derez > span.rezzable_item_status').html('Waiting to derez');
		$('li.derezzed > span.rezzable_item_status').html('Derezzed');
		$('li.derezzing> span.rezzable_item_status').html('Derezzing');
		$('li.configured > span.rezzable_item_status').html('Ready');
	}

	function do_whatever_needs_to_be_done( itemspan, itemspanjq) {
		var bits = itemspan.id.split("_");
		var entryid = bits.pop();	
		if ( itemspanjq.hasClass( 'waiting_to_rez' ) ) {
			if (!pendingRequests[""+entryid]) {
				numPendingRequests++;
			}
			pendingRequests[""+entryid] = new Date().getTime();	
			itemspanjq.removeClass( 'waiting_to_rez' );
			itemspanjq.addClass( 'rezzing' );
			//itemspanjq.$('span').html('Waiting to rez');
			rez_layout_item( entryid );
		} else if ( itemspanjq.hasClass( 'waiting_to_derez' ) ) {
			if (!pendingRequests[""+entryid]) {
				numPendingRequests++;
			}
			pendingRequests[""+entryid] = new Date().getTime();	
			itemspanjq.removeClass( 'waiting_to_derez' );
			itemspanjq.addClass( 'derezzing' );
			derez_layout_item( entryid );
		}

	}

	function check_done_tasks() {
		if (actionStatus == 'rezzing') {
			if ( ( $('li.rezzing').length == 0 ) && ( $('li.waiting_to_rez').length == 0 ) ) {
				actionStatus = 'rezzed';
				$('#rez_all_objects').html('Derez all objects');
				$('#rez_all_objects').unbind('click');
				$('#rez_all_objects').click(function() {
					start_derez_all();
				});
			}
		} else if (actionStatus == 'derezzing') {
			if ( ( $('li.derezzing').length == 0 ) && ( $('li.waiting_to_derez').length == 0 ) ) {
				actionStatus = 'derezzed';
				$('#rez_all_objects').html('Rez all objects');
				$('#rez_all_objects').unbind('click');
				$('#rez_all_objects').click(function() {
					start_rez_all();
				});
			}
		}

	}

	function eventLoop() {

		clearTimeout( timer );

		// Make the text labels match the CSS classes
		update_labels();

		// Clear out any timed-out requests.
		purgeRequestList();

		if (numPendingRequests < maxPendingRequests) { // Go easy on the server / rezzer
			// Check for anything that needs to be done
			$('.rezzable_item').each(function(itempos,itemspan) {
				if (numPendingRequests < maxPendingRequests) { 
					do_whatever_needs_to_be_done( itemspan, $(this) );	
				}
			});
		}

		
		check_done_tasks();

		update_labels();

		timer = setTimeout( 'eventLoop()', 10000 );

	}

	function rez_layout_item(entryid) {
		$.getJSON(  
			"rez_object.php",  
			{layoutentryid: entryid},  
			function(json) {  
				var result = json.result;
				if (result == 'rezzed') {
					$('#layoutentryid_'+entryid).removeClass('rezzing').addClass('rezzed');;
					if (pendingRequests[""+entryid]) {
						delete pendingRequests[""+entryid];
						numPendingRequests--;
					}
					eventLoop();
				}	
			}  
		);  
			//alert(entryid);
	}

	function derez_layout_item(entryid) {
		$.getJSON(  
			"derez_object.php",  
			{layoutentryid: entryid},  
			function(json) {  
				var result = json.result;
				if (result == 'derezzed') {
					$('#layoutentryid_'+entryid).removeClass('derezzing').addClass('derezzed');;
					delete pendingRequests[""+entryid];
					numPendingRequests--;
					eventLoop();
				}	
			}  
		);  
	}

	function start_derez_all() {
		actionStatus= 'derezzing';
		$('li.rezzed').addClass( 'waiting_to_derez' );
		$('li.waiting_to_derez').removeClass('rezzed');
		$('#rez_all_objects').html('Stop derezzing objects');
		$('#rez_all_objects').unbind('click');
		$('#rez_all_objects').click(function() {
			stop_derez_all();	
		});
		eventLoop();
	}

	function start_rez_all() {
		actionStatus= 'rezzing';
		$('li.derezzed').removeClass('derezzed');
		$('li.rezzable_item').not('li.rezzed').addClass( 'waiting_to_rez' );
		$('#rez_all_objects').html('Stop rezzing objects');
		$('#rez_all_objects').unbind('click');
		$('#rez_all_objects').click(function() {
			stop_rez_all();	
		});
		eventLoop();
	}

	function stop_derez_all() {
		$('li.rezzable_item').removeClass( 'waiting_to_derez' );
		$('#rez_all_objects').html('Derez all objects');
		$('#rez_all_objects').unbind('click');
		$('#rez_all_objects').click(function() {
			start_derez_all();
		});
		eventLoop();
	}

	function stop_rez_all() {
		$('li.rezzable_item').removeClass( 'waiting_to_rez' );
		$('#rez_all_objects').html('Rez all objects');
		$('#rez_all_objects').unbind('click');
		$('#rez_all_objects').click(function() {
			start_rez_all();
		});
		eventLoop();
	}

	function show_rezzing_state() {
	}

	$(document).ready(function () {
		$('#rez_all_objects').click(function() {
			start_rez_all();	
		});
	});
</script>
<!--
<script type="application/x-javascript" src="http://10.0.1.2:1840/ibug.js"></script>
-->
</head>

<body>

    <div class="toolbar">
        <h1 id="pageTitle"></h1>
        <a id="backButton" class="button" href="#"></a>
        <a class="button" href="#searchForm">Logout</a>
    </div>
     
<?php /*
    <ul id="home" title="Avatar Classroom Site" selected="true">
        <li class="group">Sites</li>
        <li><a href="#site1">http://edmund_earp.avatarclassroom.com</a></li>
        <li><a href="#site2">http://fire_centaur.avatarclassroom.com</a></li>
	<li></li>
        <li class="group">Add a site</li>
        <li><a href="#addsite">Add a site</a></li>
	<li></li>
    </ul>
*/
        foreach($courses as $course) {
                $cid = $course->id;
                $cn  = $course->fullname;
                print '<div id="course'.$cid.'" class="course">';
                print '<h3><a href="?courseid='.$cid.'">'.htmlentities($cn).'</a></he>';
                print '<ul class="course_list">';
                foreach($controllers[$cid] as $cont) {
                        print '<li class="controller_item">';
                        print '<table><tr valign="middle">';
                        print '<td >'.htmlentities($cont->name).'</td>';
                        //$id = $cont->get_id();
                        print '<td><form action="index.php"><input type="hidden" name="cmid" value="'.intval($id).'"><input type="submit" value="Use this classroom" /></form></td>';
                        /*
                        print '<ul class="layout_list">';
                        $layouts = $courselayouts[ $cid ];
                        foreach($layouts as $layoutname) {
                                print '<li class="layout_item">';
                                print htmlentities($layoutname);
                                print '</li>';
                        }
                        print '</ul>';
                        */
                        print '</li>';
                }
                print '<input type="submit" value="Add a classroom" />';
                print '</ul>';
                print '</div>';
        }

?>
    <ul id="site1" title="edmund_earp.avatarclassroom.com" selected="true">
        <li class="group">Courses</li>
	<?php 
	foreach($courses as $course) { 
		$cid = $course->id; 
		$cn = $course->fullname; 
		foreach($controllers[$cid] as $cont) {
			$contid = $cont->id;
?>
			<li><a href="#controller<?= intval($cid)?>-<?= intval($contid) ?>"><?= htmlentities( $cn ) ?> <?= htmlentities( $cont->name ) ?></a></li>
<?php
		}
	}
?>
<?php if ($full) { ?>
	<li></li>
        <li class="group">Add a course</li>
        <li><a href="#addcontroller">Add a course</a></li>
	<li></li>
<?php } ?>
    </ul>

<?php if ($full) { ?>
     
    <form id="addcontroller" class="panel" title="Add a Course">
    <fieldset>
       <div class="row" style="height:60px;">
          <label for="course_name" name="course_name">Name</label>
          <input id="course_name" name="course_name" class="panel" style="width:80%; height:40px; margin:10px;">
       </div>
       <div class="row" style="height:60px;">
          <label for="course">Course</label>
          <select id="course" class="az" name="course" style="height:40px; width:80%; margin:1-px;">
	  <option value="1">Japanese For Beginners</option>
        <option value="2">Spanish For Dummies</option>
      </select></div>
	<a class="whiteButton" type="submit" href="#">Add Course</a>
    </fieldset>
    </form>

<?php } ?>


<?php 
	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		foreach($controllers[$cid] as $cont) {
			$contid = $cont->id;
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
?>
    <ul id="controller<?= intval($cid)?>-<?= intval($contid) ?>" title="<?= htmlentities( $cn ) ?> <?= htmlentities( $cont->name ) ?>">
        <li class="group">Scenes</li>
        <li><a href="#layout<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>"><?= htmlentities($layout->name) ?></a></li>
<?php if ($full) { ?>
	<li></li>
        <li class="group">Add a scene</li>
        <li><a href="#addlayout">Add a layout</a></li>
<?php } ?>
    </ul>
<?php 
			}
		}
	}
?>

    <form id="addlayout" class="panel" title="Add a Scene">
	<fieldset>
	<div class="row" >
		<label for="layout_name">Name</label>
		<input id="layout_name" name="layout_name" class="panel" style="width:80%; height:40px; margin:10px;">
	</div>
	</fieldset>
	<a class="whiteButton" type="submit" href="#">Create Layout</a>
    </form>

<?php 
	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		foreach($controllers[$cid] as $cont) {
			$contid = $cont->id;
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
				$entries = $layoutentries[ $layout->id ];
?>
			    <ul id="layout<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" title="<?= htmlentities( $layout->name ) ?>">
				<li class="group"><?= htmlentities( $layout->name ) ?></li>
				<span id="rez_all_objects" class="whiteButton activeButton">Rez All Objects</span>
				<span id="derez_all_objects" class="hiddenButton">Rez All Objects</span>
				<li></li>
<?php
				$lettergroup = '';
				foreach($entries as $e) {
					$entryname = $e->name;	
					$entryname = preg_replace('/SLOODLE\s/', '', $entryname);
					$firstletter = substr($entryname, 0, 1);
					if ($lettergroup != $firstletter) { 
						$lettergroup = $firstletter;
?>
				<li class="group"><?= htmlentities($lettergroup) ?></li>
<?php 
					}
?>
<?php /*
				<li><a href="#<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?= intval($e->id) ?>"><?= htmlentities($entryname) ?><span style="float:right; margin-right:10px; color:grey; font-style:italic" class="rezzable_item">Rezzed</span> <span style="float:right; margin-right:100px; color:grey; font-style:italic" class="rezzable_item">Moved</span></a></li>
*/ ?>
				<li id="layoutentryid_<?= intval( $e->id ) ?>" class="rezzable_item"><?= htmlentities($entryname) ?><span style="float:right; margin-right:10px; color:grey; font-style:italic" class="rezzable_item_status">&nbsp;</span> </li>
<?php
				}
?>
			<?php if ($full) { ?>
				<li></li>
				<li class="group">Add objects</li>
				<li><a href="#addobjects">Add objects</a></li>
				<li></li>
				<a class="whiteButton" style="width:40%" type="submit" href="#clonelayout">Save current positions</a>
				<br />
				<a class="whiteButton" style="float:right; width:40%" type="submit" href="#deletelayout">Delete this layout</a>
				<a class="whiteButton" style="width:40%" type="submit" href="#clonelayout">Clone this layout</a>
			<?php } ?>
			    </ul>
<?php
			}
		}
	}
?>
    <form id="clonelayout" class="panel" title="Clone Boxy Classroom Layout">
	<fieldset>
	<div class="row" >
		<label for="layout_name">Name</label>
		<input id="layout_name" name="layout_name" class="panel" style="width:80%; height:40px; margin:10px;">
	</div>
	</fieldset>
	<a class="whiteButton" type="submit" href="#">Clone Layout</a>
    </form>

    <ul id="addobjects" title="Add objects">
        <li class="group">Learning</li>
        <li><a href="#quizchair01">Quiz Chair: Japanese Vocab</a></li>
        <li><a href="#quizchair02">Quiz Chair: Spanish Nouns</a></li>
        <li class="group">Assignments</li>
        <li><a href="#primdrop0">Prim Drop: Architecture Assignment</a></li>
        <li class="group">Communication</li>
        <li><a href="#webintercom0">Web Intercom: Class chatroom</a></li>
        <li class="group">Registration</li>
        <li><a href="#regenrol0">RegEnrol Booth</a></li>
        <li><a href="#passreset0">Password Reset</a></li>
        <li class="group">Experimental</li>
        </li>
    </ul>
    </ul>
     
<form id="quizchair01" class="panel" title="Quiz Chair">
<!--
<a class="whiteButton" type="submit" href="#scr_buy_pricelist">Rez / Derez Now</a>
-->
<fieldset>
<div class="row"><label for="buy_fromStation">Quiz</label>
Japanese Vocab
<!--
<select id="presenter" class="az" name="from">
<option value="1">Japanese Vocab</option>
<option value="2">Spanish Nouns</option>
</select>
-->
</div>
</fieldset>

<fieldset>
<div class="row">
<label for="buy_travellertype">Moodle Access</label>
<input type="radio" name="access"> Public
<input type="radio" name="access"> Registered users
<input type="radio" name="access"> Course members
<input type="radio" name="access"> Staff
</div>
<div class="row">
<label for="buy_travellerclass">SL / OpenSim Access</label>
<input type="radio" name="access"> Public
<input type="radio" name="access"> Owner 
<input type="radio" name="access"> Group
</div>
</fieldset>
<a class="whiteButton" type="submit" href="#scr_buy_pricelist">Add Quiz Chair</a>
</form>


<?php if ($full) { ?>
<form id="presenter1" class="panel" title="Presentation">
<!--
<a class="whiteButton" type="submit" href="#scr_buy_pricelist">Rez / Derez Now</a>
-->
<fieldset>
<div class="row"><label for="buy_fromStation">Presentation</label><select id="presenter" class="az" name="from">
<option value="1">All About Dogs</option>
<option value="2">Pictures of cats</option>
</select></div>
</fieldset>

<fieldset>
<div class="row">
<label for="buy_travellertype">Moodle Access</label>
<input type="radio" name="access"> Public
<input type="radio" name="access"> Registered users
<input type="radio" name="access"> Course members
<input type="radio" name="access"> Staff
</div>
<div class="row">
<label for="buy_travellerclass">SL / OpenSim Access</label>
<input type="radio" name="access"> Public
<input type="radio" name="access"> Owner 
<input type="radio" name="access"> Group
</div>
</fieldset>
<a class="whiteButton" type="submit" href="#scr_buy_pricelist">Change Presenter</a>
<br />
<a class="whiteButton" style="width:40%; float:right" type="submit" href="#scr_buy_pricelist">Delete Presenter</a>
</form>
<?php } else { ?>
<div id="presenter1" class="panel" title="Presentation">
        <p>This is an explanation about the presenter.</p>
        <p>Eventually you'll be able to configure it, but not yet.</p>
</div>
<?php } ?>

    <div id="player" class="panel" title="Now Playing">
        <h2>If this weren't just a demo, you might be hearing a song...</h2>
    </div>
    
    <form id="searchForm" class="dialog" action="search.php">
        <fieldset>
            <h1>Music Search</h1>
            <a class="button leftButton" type="cancel">Cancel</a>
            <a class="button blueButton" type="submit">Search</a>
            
            <label>Artist:</label>
            <input id="artist" type="text" name="artist"/>
            <label>Song:</label>
            <input type="text" name="song"/>
        </fieldset>
    </form>

    <div id="settings" title="Settings" class="panel">
        <h2>Playback</h2>
        <fieldset>
            <div class="row">
                <label>Repeat</label>
                <div class="toggle" onclick=""><span class="thumb"></span><span class="toggleOn">ON</span><span class="toggleOff">OFF</span></div>
            </div>
            <div class="row">
                <label>Shuffle</label>
                <div class="toggle" onclick="" toggled="true"><span class="thumb"></span><span class="toggleOn">ON</span><span class="toggleOff">OFF</span></div>
            </div>
        </fieldset>
        
        <h2>User</h2>
        <fieldset>
            <div class="row">
                <label>Name</label>
                <input type="text" name="userName" value="johnappleseed"/>
            </div>
            <div class="row">
                <label>Password</label>
                <input type="password" name="password" value="delicious"/>
            </div>
            <div class="row">
                <label>Confirm</label>
                <input type="password" name="password" value="delicious"/>
            </div>
        </fieldset>
    </div>
<div class="container" style="width:400px">
</div>
</body>
</html>

<?php $full = false; ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Avatar Classroom Configuration</title>
<link rel="apple-touch-icon" href="iui/iui-logo-touch-icon.png" />
<style type="text/css" media="screen">@import "iui/iui.css";</style>
<style type="text/css" media="screen">@import "layout.css";</style>
<script type="application/x-javascript" src="iui/iui.js"></script>
<script type="application/x-javascript" src="../../../lib/jquery/jquery.js"></script>
<script type="application/x-javascript" src="layout.js"></script>
<!--
-->
<script type="text/javascript">
	iui.animOn = true;
	var rezzer_uuid = '<?= htmlentities($_REQUEST['sloodleobjuuid']) ?>';
</script>
</head>

<body>

    <div class="toolbar">
        <h1 id="pageTitle"></h1>
        <a id="backButton" class="button" href="#"></a>
        <a class="button" onclick="document.location.href = '<?= $baseurl.'&logout=1&ts='.time()?>'" href="<?= $baseurl.'&logout=1&ts='.time()?>">Logout</a>
    </div>
     
    <?php if ($hasSites) { ?>
    <ul id="home" title="Avatar Classroom Site" selected="true">
        <li class="group">Sites</li>
	<?php foreach($sites as $site) { ?>
	<?php if ('http://'.$_SERVER["SERVER_NAME"] == $site) { ?>
        <li><a href="#site_1"><?=$site?></a></li>
	<?php } else { ?>
        <li><a href="<?=$site?>"><?=$site?></a></li>
	<?php } ?>
	<?php } ?>
	<li></li>
        <li class="group">Add a site</li>
        <li><a href="#addsite">Add a site</a></li>
	<li ></li>
    </ul>
    <?php } ?>

    <ul id="site_1" title="<?= "http://".$_SERVER["SERVER_NAME"]?>" <?= $hasSites ? '' : ' selected="true"' ?> >
        <li class="group">Courses</li>
	<?php 
	foreach($courses as $course) { 
		$cid = $course->id; 
		$cn = $course->fullname; 
		foreach($controllers[$cid] as $contid=>$cont) {
?>
			<li><a href="#controller_<?= intval($cid)?>-<?= intval($contid) ?>"><?= htmlentities( $cn ) ?> <?= htmlentities( $cont->name ) ?></a></li>
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
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
?>
    <ul class="layout_link" id="controller_<?= intval($cid)?>-<?= intval($contid) ?>" title="<?= htmlentities( $cn ) ?> <?= htmlentities( $cont->name ) ?>">
        <li class="group">Scenes</li>
        <li><a href="#layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>"><?= htmlentities($layout->name) ?></a></li>
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
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
				$entriesbygroup = $layoutentries[ $layout->id ];
?>
			    <ul class="layout_container" id="layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" title="<?= htmlentities( $layout->name ) ?>">
				<li class="group"><?= htmlentities( $layout->name ) ?></li>
				<span id="set_configuration_status" class="">Configuring set</span>
				<span id="rez_all_objects" class="whiteButton activeButton">Rez All Objects</span>
				<li></li>
<?php
				foreach($entriesbygroup as $group => $entries) {
?>
					<li class="group"><?= htmlentities($group) ?></li>
<?php
					foreach($entries as $e) {
						$entryname = $e->name;	
						$entryname = preg_replace('/SLOODLE\s/', '', $entryname);
						$firstletter = substr($entryname, 0, 1);
						if ($lettergroup != $firstletter) { 
							$lettergroup = $firstletter;
	?>
	<?php 
						}
	?>
	<?php /*
					<li><a href="#<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?= intval($e->id) ?>"><?= htmlentities($entryname) ?><span style="float:right; margin-right:10px; color:grey; font-style:italic" class="rezzable_item">Rezzed</span> <span style="float:right; margin-right:100px; color:grey; font-style:italic" class="rezzable_item">Moved</span></a></li>
	*/ ?>
					<?php /* NB If you change this, you also need to change layout.js, which creates some of these dynamically. */ ?>
					<li id="layoutentryid_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?=intval( $e->id ) ?>" class="rezzable_item"><a href="#configure_layoutentryid_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?=intval( $e->id ) ?>"><?= htmlentities($entryname) ?><span style="float:right; margin-right:10px; color:grey; font-style:italic" class="rezzable_item_status">&nbsp;</span> </a></li>
	<?php
					}
?>
					<li class="after_group_<?=$group?>"></li>
<?php
				}
?>
				<li class="group add_object_group">Add objects</li>
				<li><a href="#addobjects_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>">Add objects</a></li>
				<li></li>
			<?php if ($full) { ?>
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

	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
?>
    <ul id="addobjects_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" title="Add objects">
<?php 
	foreach($object_configs as $object_title => $config) {
?>
        <li><a href="#addobject_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>_<?= $config['modname']?>"><?= htmlentities($object_title) ?></a></li>
<?php 
	}
?>
        <li class="group">Learning</li>
        <li><a href="#quizchair01">Quiz Chair: Japanese Vocab</a></li>
        </li>
    </ul>
     
<?php
			}
		}
	}
?>
<?php
	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {

	foreach($object_configs as $object_title => $config) {
/*
The following form is used for adding the object.
But once it's been added, it will be clone()d to make a form to update the object we added.
*/
?>
<form class="add_object_form panel" id="addobject_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>_<?= $config['modname']?>" title="<?= htmlentities($object_title) ?>">
<span data-updating-text="Updating <?= htmlentities( $object_title ) ?>" data-update-text="Update <?= htmlentities( $object_title ) ?>" data-adding-text="Adding <?= htmlentities( $object_title ) ?>" data-add-text="Add <?= htmlentities( $object_title ) ?>" class="whiteButton active_button add_to_layout_button" target="_self" type="submit">Add <?= htmlentities( $object_title ) ?></span>
<input type="hidden" name="objectname" value="<?= htmlentities($object_title) ?>" />
<input type="hidden" name="objectgroup" value="<?= htmlentities($config['group']) ?>" />
<input type="hidden" name="layoutid" value="<?= intval($layout->id) ?>" />
<input type="hidden" name="layoutentryid" value="0" />
<input type="hidden" name="controllerid" value="<?= intval($contid) ?>" />
<input type="hidden" name="courseid" value="<?= intval($cid) ?>" />
<?php foreach($config['field_sets'] as $fs) { ?>
<fieldset>
<?php foreach($fs as $fieldname => $ctrl) { ?>
<div class="row">
<label for="<?= $fieldname ?>"><?= get_string($ctrl['title'], 'sloodle') ?></label>
<?php if ($ctrl['type'] == 'radio') { ?>
<span class="sloodle_config">
<?php foreach($ctrl['options'] as $opn => $opv) { ?>
<input type="radio" name="<?= $ctrl['title'] ?>" value="<?= $opn ?>" <?= $opn == $ctrl['default'] ? 'checked ' : '' ?>> <?= get_string($opv, 'sloodle') ?> 
<?php } ?>
</span>
<?php } else {?>
not radio: <?=$ctrl['type']?>
<?php } ?>
</div>
<?php } ?>
</fieldset>
<?php } ?>
<span data-delete-text="Delete <?= htmlentities($object_title) ?>" data-deleting-text="Deleting <?= htmlentities($object_title) ?>" class="whiteButton active_button delete_layout_entry_button hiddenButton" style="width:40%; float:right" type="submit">Delete <?= htmlentities($object_title) ?></span>
</form>
<?php 
	}
?>
     
<?php
			}
		}
	}
?>


<?php 
/*
Configuration form for each 
*/
	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
				$entriesbygroup = $layoutentries[ $layout->id ];
				foreach($entriesbygroup as $group => $entries) {
					foreach($entries as $e) {
						$entryname = $e->name;	
						$config = $object_configs[$entryname]; // TODO: Merge in the layout entries
						$entryname = preg_replace('/SLOODLE\s/', '', $entryname);
						$object_title = $entryname;

?>
<form id="configure_layoutentryid_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?=intval( $e->id ) ?>" class="panel" title="<?= htmlentities($object_title) ?>">
<span data-updating-text="Updating <?= htmlentities( $object_title ) ?>" data-update-text="Update <?= htmlentities( $object_title ) ?>" class="whiteButton active_button update_layout_entry_button" target="_self" type="submit">Update <?= htmlentities( $object_title ) ?></span>
<input type="hidden" name="layoutentryid" value="<?= intval($e->id) ?>" />
<input type="hidden" name="objectgroup" value="<?= htmlentities( $group ) ?>" />
<?php foreach($config['field_sets'] as $fs) { ?>
<fieldset>
<?php foreach($fs as $fieldname => $ctrl) { ?>
<div class="row">
<label for="<?= $fieldname ?>"><?= get_string($ctrl['title'], 'sloodle') ?></label>
<?php if ($ctrl['type'] == 'radio') { ?>
<span class="sloodle_config">
<?php foreach($ctrl['options'] as $opn => $opv) { ?>
<input type="radio" name="<?= $ctrl['title'] ?>" value="<?= $opn ?>" <?= $opn == $ctrl['default'] ? 'checked ' : '' ?>> <?= get_string($opv, 'sloodle') ?> 
<?php } ?>
</span>
<?php } else {?>
not radio: <?=$ctrl['type']?>
<?php } ?>
</div>
<?php } ?>
</fieldset>
<?php } ?>

<br />
<span data-delete-text="Delete <?= htmlentities($object_title) ?>" data-deleting-text="Deleting <?= htmlentities($object_title) ?>" class="whiteButton active_button delete_layout_entry_button" style="width:40%; float:right" type="submit">Delete <?= htmlentities($object_title) ?></span>
</form>
<?php 
					}
				}
			}
		}
	}
?>
<span id="add_configuration_above_me"></span>






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

<?php 

function print_html_top($loadfrom = '', $is_logged_in) { 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Scoreboard</title>
<link rel="apple-touch-icon" href="iui/iui-logo-touch-icon.png" />
<style type="text/css" media="screen">@import "<?=$loadfrom?>iui/iui_avatarclassroom.css";</style>
<style type="text/css" media="screen">@import "<?=$loadfrom?>scoreboard.css";</style>
<script type="application/x-javascript" src="../../../lib/jquery/jquery.js"></script>
<script type="application/x-javascript" src="../../../lib/jquery/jquery.ba-hashchange.min.js"></script>
<script type="application/x-javascript" src="scoreboard.js?ts=<?= time() ?>"></script>
<!--
-->
<script type="text/javascript">
	var rezzer_uuid  = '<?= htmlentities($_REQUEST['sloodleobjuuid']) ?>';
	var do_full_updates = <?= $is_logged_in ? 'true' : 'false' ?>; 
</script>
</head>

<body>

<?php
}

function print_toolbar( $baseurl, $is_logged_in ) {
?>
    <div class="toolbar">
        <h1 id="pageTitle"></h1>
        <a id="backButton" class="button" href="#"></a>
	<?php if ($is_logged_in) { ?>
        <a class="button" onclick="document.location.href = '<?= $baseurl.'&logout=1&ts='.time()?>'" href="<?= $baseurl.'&logout=1&ts='.time()?>">Logout</a>
	<?php } ?>
    </div>
<?php
}

// A placeholder div 
// Never actually loaded - we intercept "sitelist" and use it to redirect to the api. site.
function print_site_placeholder( $sitesURL ) {
?>
	<div id="sitelist" data-parent-url="<?= $sitesURL ?>" title="Avatar Classroom"></div>
<?php
}

function print_round_list($rounds) {

?>
    <ul id="roundlist" title="Rounds">
        <li class="group">All Rounds</li>
    </ul>

<?php
}

function print_score_list( $group_name, $student_scores, $active_object_uuid, $currencyid, $roundid, $refreshtime, $is_logged_in, $is_admin ) {
?>
<script>
var active_object_uuid = '<?= htmlentities($active_object_uuid) ?>';
</script>

     
    <ul id="scorelist" class="<?= $is_admin ? 'admin_view' : 'student_view' ?>" data-refresh-seconds="<?=intval($refreshtime) ?>" data-parent="roundlist" title="Scores" selected="true">
        <li class="group divider"><?= $is_admin ? 'Students Displayed On Scoreboard' : 'All Students' ?> </li>
	<?php
	foreach($student_scores as $score) { 
		if ($score->has_scores) {
			render_score_li($score, $is_admin); 
		}
	}
	?>
	<li class="divider"></li>
	<?php if ($is_admin) { ?>
        <li class="group divider">Students Not Displayed On Scoreboard</li>
	<?php
	foreach($student_scores as $score) { 
		if (!$score->has_scores) {
			render_score_li($score, $is_admin); 
		}
	}
	?>
	<li class="group divider end"></li>
	<li class="new_round_link">New round</li>
	<?php } ?>

<?php /*
	<li><span id="update_score_list_link">Update</span></li>
	<li><span id="save_dirty_link">Save Dirty</span></li>
*/ ?>
    </ul>

    <?php
	$dummy_score = new stdClass();
	$dummy_score->avname = '';
	$dummy_score->firstname = '';
	$dummy_score->lastname = '';
	$dummy_score->userid = 0;
	$dummy_score->has_scores = true;
    ?>
    <ul class="dummy_item_template" id="dummy_score_ul"> 
	<?php render_score_li( $dummy_score, $is_admin ); ?>
    </ul>



<?php 
}

function render_score_li($score, $is_admin) { 
?>
        <li class="<?= $score->has_scores ? 'has_scores' : 'no_scores' ?> score_entry" id="student_score_<?= intval($score->userid) ?>" data-userid="<?= intval($score->userid) ?>" data-dirty-change="0" data-last-clean-ts="0" >
	<?php if (false &&$is_logged_in) { ?>
		<a data-userid="<?= $score->userid?>" href="#edit_student" class="student_edit_link" >
	<?php } ?>
		<span class="avatar_name"><?= ( $score->avname != '' ) ? htmlentities( $score->avname ) : htmlentities($score->firstname.' '.$score->lastname) ?></span>
	<?php 
	if ($is_admin) { 
	?>
		<span class="score_change_section">
		<span class="show_link score_change" data-score-change="0">Show </span>
		<span class="user_score_delete_link" >Delete </span>
		&nbsp; 
		&nbsp; 
	<?php
		foreach( array("+1","+5","+10","+25","+100","-100","-25","-10","-5","-1") as $score_change ) {
	?>
			<span class="score_change" data-score-change="<?=intval($score_change) ?>"><?=intval($score_change) ?></span>
	<?php
		}
	?>
		</span>
	<?php
	} ?>
		<span class="score_info"><?= intval($score->balance) ?></span>
	<?php if ($is_logged_in) { ?>
		</a>
	<?php } ?>
	</li>
	<?php
}

function print_user_points_change_form( ) {
?>
    <form data-parent="scorelist" id="edit_student" class="panel" title="Edit Points">
	<fieldset>
	<span id="student_name_span">Student Name</span>
	<div class="row" >
		<label for="layoutname">Add Points</label>
		<input id="addpoints" name="addpoints" class="panel" style="width:10%; height:40px; margin:10px;">
	</div>
	<div class="row" >
		<label for="layoutname">Remove Points</label>
		<input id="addpoints" name="removepoints" class="panel" style="width:10%; height:40px; margin:10px;">
	</div>
	</fieldset>
	<span data-addingpoints-text="Changing Points" data-created-text="Change Points" class="active_button change_points_button" type="submit" href="#">Change Points</span>
    </form>
<?php
}

function print_html_bottom() {
?>
</body>
</html>
<?php
}
?>
<?php 
function print_layout_lists( $courses, $controllers, $courselayouts, $layoutentries, $rezzeruuid) {

	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		if (!isset($controllers[$cid])) {
			continue;
		}
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
				$hasactiveobjects = $layout->has_active_objects_rezzed_by_rezzer( $rezzeruuid );
				$entriesbygroup = $layoutentries[ $layout->id ];

				$rezzed_entries = $layout->rezzed_active_objects_by_layout_entry_id( $rezzeruuid );

?>
			    <ul data-parent="controller_<?= intval($cid)?>-<?= intval($contid) ?>" class="layout_container layout_container_<?= intval($layout->id) ?>" id="layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" title="<?= htmlentities( $layout->name ) ?>" data-rez-mode="<?= $hasactiveobjects ? 'rezzed' : 'unrezzed'?>" data-action-status="<?= $hasactiveobjects ? 'rezzed' : 'unrezzed'?>" data-connection-status="disconnected">
				<li class="group"><?= htmlentities( $layout->name ) ?></li>
				<span id="set_configuration_status_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" class="button_goes_here_zone set_configuration_status"><?=get_string('layoutmanager:connectingtorezzer','sloodle') ?></span>
				<span id="rez_all_objects_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" class="active_button rez_all_objects">Rez All Objects</span>

				<span id="generate_standard_layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" data-generate-text="Import Moodle Activities for <?=htmlentities( $cn ) ?>" data-generating-text="Importing Moodle Activities" data-layoutid="<?= intval($layout->id) ?>" class="active_button generate_standard_layout">Import Moodle Activities for <?=htmlentities( $cn ) ?></span>
<?php
				foreach($entriesbygroup as $group => $entries) {
?>
					<li class="group"><?= htmlentities( get_string('objectgroup:'.$group, 'sloodle') ) ?></li>
<?php
					foreach($entries as $e) {

						$isrezzed = isset( $rezzed_entries[ $e->id ]);
				
//print "rezzedentries";
//var_dump($rezzed_entries);
						/*
						$firstletter = substr($entryname, 0, 1);
						if ($lettergroup != $firstletter) { 
							$lettergroup = $firstletter;
						}
						*/

						print_rezzable_item_li( $e, $cid, $contid, $layout, $isrezzed);
						


					}
?>
					<li class="after_group_<?=$group?>"><a href="#addobjectgroup_<?= $group ?>_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>">Add objects<!--: <?= get_string('objectgroup:'.$group,'sloodle') ?>--></a></li>
					<li></li>
<?php
				}
?>

				<span class="active_button sync_object_positions" style="width:98%" type="submit" href="#clonelayout">Save current positions</span>
				<br />
				<span class="active_button delete_layout_button" data-layoutid="<?= intval($layout->id) ?>" data-deleted-text="Deleted, derezzing objects" data-delete-text="Delete this Scene" data-deleting-text="Deleting Scene" style="float:right; width:40%" type="submit">Delete this scene</span>
				<span class="active_button clone_layout_button" data-layoutid="<?= intval($layout->id) ?>" data-cloned-text="Clone this scene" data-cloning-text="Cloning scene" data-clone-text="Clone this scene" style="width:40%" type="submit" >Clone this scene</span>
					
				<span class="active_button rename_layout_button" data-layoutid="<?= intval($layout->id) ?>" data-renamed-text="Rename this scene" data-rename-text="Rename scene" data-renaming-text="Renaming Scene" class="active_button" style="width:40%" type="submit" ><span class="rename_label">Rename this scene</span> <span class="rename_input"><input class="rename_layout_input" data-rename-input-layoutid="<?= intval($layout->id) ?>" value="<?= htmlentities( $layout->name ) ?>" /> <span class="rename_input_save_button">Rename</span></span></span>

			    </ul>

<?php
			}
		}
	}
?>
<span id="add_layout_lists_above_me"></span>
<?php
}

function print_rezzable_item_li( $e, $cid, $contid, $layout, $isrezzed) {

	$entryname = $e->name;	
	$entryname = preg_replace('/SLOODLE\s/', '', $entryname);

	$modTitle = $e->get_course_module_title();
	?>
<?php /*
					<li><a href="#<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?= intval($e->id) ?>"><?= htmlentities($entryname) ?><span style="float:right; margin-right:10px; color:grey; font-style:italic" class="rezzable_item">Rezzed</span> <span style="float:right; margin-right:100px; color:grey; font-style:italic" class="rezzable_item">Moved</span></a></li>
	*/ ?>
							<?php /* NB If you change this, you also need to change layout.js, which creates some of these dynamically. */ ?>
							<li data-layoutentryid="<?= $e->id?>" id="layoutentryid_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?=intval( $e->id ) ?>" class="rezzable_item <?= ( $isrezzed ? 'rezzed' : '' ) ?>"><a href="#configure_layoutentryid_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?=intval( $e->id ) ?>"><?= htmlentities($entryname) ?><span class="module_info"><?=htmlentities($modTitle)?></span><span class="rezzable_item_status">&nbsp;</span> <span class="rezzable_item_positioning">&nbsp;</span> </a></li>
<?php
}

function print_add_object_item_li( $object_title, $config, $cid, $contid, $layout) {
	$object_title = preg_replace('/^SLOODLE /', '', $object_title);
	$id = "linkto_addobject_{$cid}-{$contid}-{$layout->id}_{$config->object_code}";
?>
        <li id="<?=$id?>"><a href="#addobject_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>_<?= $config->object_code?>"><?= htmlentities($object_title) ?></a></li>
<?php 
	return $id;

}

function print_layout_add_object_groups( $courses, $controllers, $courselayouts, $objectconfigsbygroup) {

	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		if (!isset($controllers[$cid])) {
			continue;
		}
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
?>
<?php 
				foreach($objectconfigsbygroup as $group => $groupobjectconfigs) {
?>
    <ul <?= $group == 'misc' ? 'class="object_group_misc"' : '' ?> data-parent="layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" id="addobjectgroup_<?= $group ?>_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" title="Add objects: <?= htmlentities( get_string('objectgroup:'.$group, 'sloodle') ) ?>">
        <li class="group">Add objects: <?= htmlentities( get_string('objectgroup:'.$group, 'sloodle') ) ?></li>
<?php
	foreach($groupobjectconfigs as $object_title => $config) {
		print_add_object_item_li( $object_title, $config, $cid, $contid, $layout );
	}

?>
        <li></li>

    </ul>
<?php
				}
			}
		}
	}
?>
<span id="add_add_object_groups_above_me"></span>
<?php
}

function print_add_object_forms($courses, $controllers, $courselayouts, $object_configs ) {

	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		if (!isset($controllers[$cid])) {
			continue;
		}
		foreach($controllers[$cid] as $contid => $cont) {
			if (!isset($courselayouts[ $cid ]) ) {
				continue;
			}
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
				foreach($object_configs as $object_title => $config) {
/*
The following form is used for adding the object.
But once it's been added, it will be clone()d to make a form to update the object we added.
*/
					print_add_object_form( $config, $cid, $contid, $layout, $object_title );
?>

<?php 
				}
			}
		}
	}
?>
<span id="add_add_object_forms_above_me"></span>
<?php
}

function print_add_object_form( $config, $cid, $contid, $layout, $object_title ) {
	$id = "addobject_{$cid}-{$contid}-{$layout->id}_{$config->object_code}";
?>
<form data-parent="addobjectgroup_<?= $config->group ?>_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" class="add_object_form panel addobject_layout_<?= intval($layout->id) ?>_<?= $config->object_code?>" id="<?=$id?>" title="<?= htmlentities($object_title) ?>">
<span data-updating-text="Updating <?= htmlentities( $object_title ) ?>" data-update-text="Update <?= htmlentities( $object_title ) ?>" data-adding-text="Adding <?= htmlentities( $object_title ) ?>" data-add-text="Add <?= htmlentities( $object_title ) ?>" class="active_button add_to_layout_button" target="_self" type="submit">Add <?= htmlentities( $object_title ) ?></span>
<input type="hidden" name="objectname" value="<?= htmlentities($object_title) ?>" />
<input type="hidden" name="objectgroup" value="<?= htmlentities($config->group) ?>" />
<input type="hidden" name="layoutid" value="<?= intval($layout->id) ?>" />
<input type="hidden" name="layoutentryid" value="0" />
<input type="hidden" name="controllerid" value="<?= intval($contid) ?>" />
<input type="hidden" name="courseid" value="<?= intval($cid) ?>" />
<?php if ($config->module) { 
$moduleoptionselect = $config->course_module_select( $cid, $val = null ); 
?>
<fieldset>
<div class="row">
<label for="<?= 'sloodlemoduleid' ?>"><?= get_string($config->module_choice_message, 'sloodle') ?></label>
<span class="sloodle_config">
<?= $moduleoptionselect ? $moduleoptionselect : get_string($config->module_no_choices_message, 'sloodle') ?>
</span>
</div>
</fieldset>
<?php
} ?>
<?php foreach($config->field_sets as $fs) { ?>
<fieldset>
<?php foreach($fs as $ctrl) { ?>
<?php $fieldname = $ctrl->fieldname; ?>
<div class="row">
<label for="<?= $fieldname ?>"><?= get_string($ctrl->title, 'sloodle') ?></label>
<span class="sloodle_config">
<?php if ( ($ctrl->type == 'radio') || ($ctrl->type == 'yesno') ) { ?>
<?php foreach($ctrl->options as $opn => $opv) { ?>
<input type="radio" name="<?= $fieldname ?>" value="<?= $opn ?>" <?= $opn == $ctrl->default ? 'checked ' : '' ?>> <?= get_string($opv, 'sloodle') ?> &nbsp; &nbsp; 
<?php } ?>
<?php } else if ($ctrl->type == 'input') { ?>
<input type="text" size="<?= $ctrl->size ?>" maxlength="<?= $ctrl->max_length ?>" name="<?= $fieldname ?>" value="<?= $ctrl->default ?>" /> 
<?php } else { ?>
not radio: <?=$ctrl->type?>
<?php } ?>
</span>
</div>
<?php } ?>
</fieldset>
<?php } ?>
<span data-delete-text="Delete <?= htmlentities($object_title) ?>" data-deleting-text="Deleting <?= htmlentities($object_title) ?>" class="active_button delete_layout_entry_button hiddenButton" style="width:40%; float:right" type="submit">Delete <?= htmlentities($object_title) ?></span>
</form>

<br />

<?php
	return $id;
}

/*
Configuration form for each 
*/
function print_edit_object_forms($courses, $controllers, $courselayouts, $object_configs, $layoutentries) {

	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
				$entriesbygroup = $layoutentries[ $layout->id ];
				$lid = $layout->id;
				foreach($entriesbygroup as $group => $entries) {
					foreach($entries as $e) {
						$entryname = $e->name;	
						$config = $object_configs[$entryname]; // TODO: Merge in the layout entries

						print_config_form( $e, $config, $cid, $contid, $lid, $group );
						
					}
				}
?>
<span id="add_configuration_above_me_layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>"></span>
<?php
			}
		}
	}
?>
<span id="add_edit_object_forms_above_me"></span>
<?php
}

function print_config_form( $e, $config, $cid, $contid, $lid, $group ) {

						$lconfig = $e->get_layout_entry_configs_as_name_value_hash();
						$entryname = preg_replace('/SLOODLE\s/', '', $e->name);
						$object_title = $entryname;

	$id = "configure_layoutentryid_{$cid}-{$contid}-{$lid}-{$e->id}";

?>
<form data-parent="layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($lid) ?>" id="<?=$id?>" class="panel" title="<?= htmlentities($object_title) ?>">
<span data-updating-text="Updating <?= htmlentities( $object_title ) ?>" data-update-text="Update <?= htmlentities( $object_title ) ?>" class="active_button update_layout_entry_button" target="_self" type="submit">Update <?= htmlentities( $object_title ) ?></span>
<input type="hidden" name="layoutid" value="<?= intval($lid) ?>" />
<input type="hidden" name="layoutentryid" value="<?= intval($e->id) ?>" />
<input type="hidden" name="controllerid" value="<?= intval($contid) ?>" />
<input type="hidden" name="objectgroup" value="<?= htmlentities( get_string('objectgroup:'.$group, 'sloodle' ) ) ?>" />
<?php if ($config->module) { 
$moduleoptionselect = $config->course_module_select( $cid, $lconfig['sloodlemoduleid'] ); 
?>
<fieldset>
<div class="row">
<label for="<?= $fieldname ?>"><?= get_string($config->module_choice_message, 'sloodle') ?></label>
<span class="sloodle_config">
<?= $moduleoptionselect ? $moduleoptionselect : get_string($config->module_no_choices_message, 'sloodle') ?>
</span>
</div>
</fieldset>
<?php
} ?>
<?php foreach($config->field_sets as $fs) { ?>
<fieldset>
<?php foreach($fs as $ctrl) { ?>
<?php $fieldname = $ctrl->fieldname; ?>
<?php 	$val = isset($lconfig[$fieldname]) ? $lconfig[$fieldname] : ''; ?>
<div class="row">
<label for="<?= $fieldname ?>"><?= get_string($ctrl->title, 'sloodle') ?></label>
<span class="sloodle_config">
<?php if ( ($ctrl->type == 'radio') || ($ctrl->type == 'yesno') ) { ?>
<?php foreach($ctrl->options as $opn => $opv) { ?>
<input type="radio" name="<?= $fieldname ?>" value="<?= $opn ?>" <?= $opn == $val ? 'checked ' : '' ?>> <?= get_string($opv, 'sloodle') ?> &nbsp; &nbsp; 
<?php } ?>
<?php } else if ($ctrl->type == 'input') {?>
<input type="text" size="<?= $ctrl->size ?>" maxlength="<?= $ctrl->max_length ?>" name="<?= $fieldname ?>" value="<?= $val ?>" /> 
<?php } else {?>
not radio: <?=$ctrl->type?>
<?php } ?>
</span>
</div>
<?php } ?>
</fieldset>
<?php } ?>

<span data-delete-text="Delete <?= htmlentities($object_title) ?>" data-deleting-text="Deleting <?= htmlentities($object_title) ?>" class="active_button delete_layout_entry_button" style="width:40%; float:right" type="submit">Delete <?= htmlentities($object_title) ?></span>

</form>

<br />
<?php 

	return $id;
}
?>

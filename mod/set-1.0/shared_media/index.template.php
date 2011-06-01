<?php 

function print_html_top($loadfrom = '') { 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Avatar Classroom Setup</title>
<link rel="apple-touch-icon" href="iui/iui-logo-touch-icon.png" />
<style type="text/css" media="screen">@import "<?=$loadfrom?>iui/iui_avatarclassroom.css";</style>
<style type="text/css" media="screen">@import "<?=$loadfrom?>layout.css";</style>
<script type="application/x-javascript" src="../../../lib/jquery/jquery.js"></script>
<script type="application/x-javascript" src="layout.js?<?= time() ?>"></script>
<!--
-->
<script type="text/javascript">
	var rezzer_uuid = '<?= htmlentities($_REQUEST['sloodleobjuuid']) ?>';
</script>
</head>

<body>

<?php
}

function print_toolbar( $baseurl ) {
?>
    <div class="toolbar">
        <h1 id="pageTitle"></h1>
        <a id="backButton" class="button" href="#sitelist">Avatar Classroom</a>
        <a class="button" onclick="document.location.href = '<?= $baseurl.'&logout=1&ts='.time()?>'" href="<?= $baseurl.'&logout=1&ts='.time()?>">Logout</a>
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

function print_site_list( $sites ) {
?>
     
    <ul id="sitelist" title="Avatar Classroom" selected="true">
        <li class="group">Sites</li>
	<?php foreach($sites as $site) { ?>
	<?php if ('http://'.$_SERVER["SERVER_NAME"] == $site) { ?>
        <li><a class="active_site_link" href="#site_1"><?=$site?></a></li>
	<?php } else { ?>
        <li><a href="<?=$site?>"><?=$site?></a></li>
	<?php } ?>
	<?php } ?>
	<li></li>
        <li class="group">Add a site</li>
        <li><a href="#addsite">Add a site</a></li>
	<li ></li>
    </ul>

<?php 
}

function print_controller_list( $courses, $controllers, $hasSites, $sitesURL ) {
$hasSites = false;
$full = false;
?>

    <ul id="site_1" data-parent="sitelist" title="<?= "http://".$_SERVER["SERVER_NAME"]?>" <?= $hasSites ? '' : ' selected="true"' ?> >
        <li class="group">Courses enabled for Sloodle</li>
	<?php 
	foreach($courses as $course) { 
		$cid = $course->id; 
		$cn = $course->fullname; 
		if (isset($controllers[$cid])) { 
			foreach($controllers[$cid] as $contid=>$cont) {
?>
				<li><a href="#controller_<?= intval($cid)?>-<?= intval($contid) ?>"><?= htmlentities( $cn ) ?> <?= htmlentities( $cont->name ) ?></a></li>
<?php
			}
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
     
    <form data-parent="site_1" id="addcontroller" class="panel" title="Add a Course">
    <fieldset>
       <div class="row" style="height:60px;">
          <label for="course_name" name="course_name">Name</label>
          <input id="course_name" name="course_name" class="panel" style="width:80%; height:40px; margin:10px;">
       </div>
       <div class="row" style="height:60px;">
          <label for="course">Course</label>
          <select id="course" class="az" name="course" style="height:40px; width:80%; margin:10px;">
	  <option value="1">Japanese For Beginners</option>
        <option value="2">Spanish For Dummies</option>
      </select></div>
	<a class="active_button" type="submit" href="#">Add Course</a>
    </fieldset>
    </form>

<?php } 

}

function print_layout_list( $courses, $controllers, $courselayouts ) {

	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
		if (!isset($controllers[$cid])) {
			continue;
		}
		foreach($controllers[$cid] as $contid => $cont) {
?>
    <ul data-parent="site_1" id="controller_<?= intval($cid)?>-<?= intval($contid) ?>" title="<?= htmlentities( $cn ) ?> <?= htmlentities( $cont->name ) ?>" class="controllercourselayouts_<?= intval($cid)?>" data-id-prefix="layout_<?= intval($cid)?>-<?= intval($contid) ?>-">
        <li class="group">Scenes</li>
<?php
			$layouts = $courselayouts[ $cid ];
			foreach($layouts as $layout) {
?>
        <li data-layout-link-li-id="<?= intval($layout->id) ?>" ><a class="layout_link" href="#layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>"><?= htmlentities($layout->name) ?></a></li>
<?php
			}
?>
	<li class="add_layout_above_me"></li>
        <li class="group">Add a scene</li>
        <li><a href="#addlayout_<?= intval($cid) ?>-<?= intval($contid) ?>">Add a scene</a></li>
    </ul>
<?php 
		}

	}
}


function print_add_layout_forms( $courses, $controllers ) {
	foreach($courses as $course) {
		$cid = $course->id;
		foreach($controllers[$cid] as $contid => $cont) {
?>
    <form data-parent="controller_<?= intval($cid)?>-<?= intval($contid) ?>" id="addlayout_<?= intval($cid)?>-<?= intval($contid) ?>" class="panel" title="Add a Scene to <?= htmlentities($course->fullname) ?>">
	<input type="hidden" name="courseid" value="<?= intval($cid)?>" />
	<fieldset>
	<div class="row" >
		<label for="layoutname">Name</label>
		<input id="layoutname" name="layoutname" class="panel" style="width:80%; height:40px; margin:10px;">
	</div>
	</fieldset>
	<span data-creating-text="Creating Scene" data-created-text="Create Scene" class="active_button create_layout_button" type="submit" href="#">Create Scene</span>
    </form>
<?php
		}
	}
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
						$entryname = $e->name;	
						$entryname = preg_replace('/SLOODLE\s/', '', $entryname);

						$modTitle = $e->get_course_module_title();

						$isrezzed = isset( $rezzed_entries[ $e->id ]);
				
//print "rezzedentries";
//var_dump($rezzed_entries);
						/*
						$firstletter = substr($entryname, 0, 1);
						if ($lettergroup != $firstletter) { 
							$lettergroup = $firstletter;
						}
						*/
	?>
	<?php /*
					<li><a href="#<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?= intval($e->id) ?>"><?= htmlentities($entryname) ?><span style="float:right; margin-right:10px; color:grey; font-style:italic" class="rezzable_item">Rezzed</span> <span style="float:right; margin-right:100px; color:grey; font-style:italic" class="rezzable_item">Moved</span></a></li>
	*/ ?>
					<?php /* NB If you change this, you also need to change layout.js, which creates some of these dynamically. */ ?>
					<li data-layoutentryid="<?= $e->id?>" id="layoutentryid_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?=intval( $e->id ) ?>" class="rezzable_item <?= ( $isrezzed ? 'rezzed' : '' ) ?>"><a href="#configure_layoutentryid_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>-<?=intval( $e->id ) ?>"><?= htmlentities($entryname) ?><span class="module_info"><?=htmlentities($modTitle)?></span><span class="rezzable_item_status">&nbsp;</span> <span class="rezzable_item_positioning">&nbsp;</span> </a></li>
	<?php
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
    <ul data-parent="layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" id="addobjectgroup_<?= $group ?>_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" title="Add objects: <?= htmlentities( get_string('objectgroup:'.$group, 'sloodle') ) ?>">
        <li class="group">Add objects: <?= htmlentities( get_string('objectgroup:'.$group, 'sloodle') ) ?></li>
<?php
	foreach($groupobjectconfigs as $object_title => $config) {
		$object_title = preg_replace('/^SLOODLE /', '', $object_title);
?>
        <li><a href="#addobject_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>_<?= $config->object_code?>"><?= htmlentities($object_title) ?></a></li>
<?php 
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
?>
<form data-parent="addobjectgroup_<?= $config->group ?>_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>" class="add_object_form panel addobject_layout_<?= intval($layout->id) ?>_<?= $config->object_code?>" id="addobject_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($layout->id) ?>_<?= $config->object_code?>" title="<?= htmlentities($object_title) ?>">
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
<input type="radio" name="<?= $fieldname ?>" value="<?= $opn ?>" <?= $opn == $ctrl->default ? 'checked ' : '' ?>> <?= get_string($opv, 'sloodle') ?> 
<?php } ?>
<?php } else if ($ctrl->type == 'input') { ?>
<input type="text" name="<?= $fieldname ?>" value="<?= $ctrl->default ?>" /> 
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
				}
			}
		}
	}
?>
<span id="add_add_object_forms_above_me"></span>
<?php
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

?>
<form data-parent="layout_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($lid) ?>" id="configure_layoutentryid_<?= intval($cid)?>-<?= intval($contid) ?>-<?= intval($lid) ?>-<?=intval( $e->id ) ?>" class="panel" title="<?= htmlentities($object_title) ?>">
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
<input type="radio" name="<?= $fieldname ?>" value="<?= $opn ?>" <?= $opn == $val ? 'checked ' : '' ?>> <?= get_string($opv, 'sloodle') ?>
<?php } ?>
<?php } else if ($ctrl->type == 'input') {?>
<input type="text" name="<?= $fieldname ?>" value="<?= $val ?>" /> 
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
}
?>

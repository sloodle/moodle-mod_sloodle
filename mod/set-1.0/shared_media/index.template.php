<?php 
function print_home_javascript() {
?>
<html>
<head>
<script language="JavaScript">
window.home();
</script>
</head>
</html>
<?php
}

function print_html_top($loadfrom = '') { 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><?php echo  s(get_string('rezzer:sloodlesetup', 'sloodle')) ?></title>
<link rel="apple-touch-icon" href="iui/iui-logo-touch-icon.png" />
<style type="text/css" media="screen">@import "<?php echo $loadfrom?>iui/iui_avatarclassroom.css";</style>
<style type="text/css" media="screen">@import "<?php echo $loadfrom?>layout.css";</style>
<script type="application/x-javascript" src="../../../lib/jquery/jquery.js"></script>
<script type="application/x-javascript" src="layout.js"></script>
<!--
-->
<script type="text/javascript">
	var rezzer_uuid = '<?php echo  htmlentities($_REQUEST['sloodleobjuuid']) ?>';
	var heartbeatMilliseconds = <?php echo (SLOODLE_REZZER_STATUS_CONFIRM_INTERVAL*1000/2);?> // We do automatic refreshes to see if anything has changed in-world. This decides how often.
</script>
</head>

<body>

<?php
}

function print_toolbar( $baseurl, $sitesURL ) {
?>
    <div class="toolbar">
        <h1 id="pageTitle"></h1>
        <a id="backButton" class="button" href="#sitelist"><?php echo  ( $sitesURL != '' ) ? s(get_string('rezzer:avatarclassroom', 'sloodle')) : '' ?></a>
        <a class="button" onclick="document.location.href = '<?php echo  $baseurl.'&logout=1&ts='.time()?>'" href="<?php echo  $baseurl.'&logout=1&ts='.time()?>"><?php echo  s(get_string('rezzer:logout', 'sloodle')) ?></a>
    </div>
<?php
}

// A placeholder div 
// Never actually loaded - we intercept "sitelist" and use it to redirect to the api. site.
function print_site_placeholder( $sitesURL ) {
?>
	<div id="sitelist" data-parent-url="<?php echo  $sitesURL ?>" title="<?php echo  ( $sitesURL != '' ) ? s(get_string('rezzer:avatarclassroom', 'sloodle')) : '' ?>"></div>
<?php
}

function print_site_list( $sites ) {
?>
     
    <ul id="sitelist" title="<?php echo  s(get_string('rezzer:avatarclassroom','sloodle')) ?>" selected="true">
        <li class="group"><?php echo  s(get_string('rezzer:sites', 'sloodle')) ?></li>
	<?php foreach($sites as $site) { ?>
	<?php if ('http://'.$_SERVER["SERVER_NAME"] == $site) { ?>
        <li><a class="active_site_link" href="#site_1"><?php echo $site?></a></li>
	<?php } else { ?>
        <li><a href="<?php echo $site?>"><?php echo $site?></a></li>
	<?php } ?>
	<?php } ?>
	<li></li>
        <li class="group"><?php echo  s(get_string('rezzer:addsite', 'sloodle'))?></li>
        <li><a href="#addsite"><?php echo  s(get_string('rezzer:addsite', 'sloodle'))?></a></li>
	<li ></li>
    </ul>

<?php 
}

function print_controller_list( $courses, $controllers, $hasSites, $sitesURL, $hasCourses, $hasControllers, $hasControllersWithPermission) {
$hasSites = false;
$full = false;
?>

    <ul id="site_1" data-parent="sitelist" title="<?php echo  "http://".$_SERVER["SERVER_NAME"]?>" <?php echo  $hasSites ? '' : ' selected="true"' ?> >

<div class="upper_button_zone">
<span class="left_zone">

	<span class="title_text"><?php echo  s( get_string('rezzer:controllers','sloodle')) ?></span>
</span>
<span class="right_zone">


<span class="control_button reload_page_button" type="submit"><?php echo  s(get_string('rezzer:refreshconfig', 'sloodle', "")) ?></span>

</span>
</div>

	<?php if (!$hasControllersWithPermission) { ?>
		<?php if (!$hasCourses) { ?>
			<li><?php echo s(get_string('rezzer:nocourses','sloodle'))?></li>
		<?php } else if (!$hasControllers) { ?>
			<li><?php echo s(get_string('rezzer:nocontrollers','sloodle'))?></li>
		<?php } else if (!$hasControllersWithPermission) { ?>
			<li><?php echo s(get_string('rezzer:nocontrollerswithpermission','sloodle'))?></li>
		<?php } ?>
	<?php } ?>

	<?php 
	foreach($courses as $course) { 
		$cid = $course->id; 
		$cn = $course->fullname; 
		if (isset($controllers[$cid])) { 
			foreach($controllers[$cid] as $contid=>$cont) {
?>
				<li><a href="#controller_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>"><?php echo  s( $cn ) ?> <?php echo  s( $cont->name ) ?></a></li>
<?php
			}
		}
	}
?>
<?php if ($full) { ?>
	<li></li>
        <li class="group"><?php echo  s(get_string('rezzer:addcontroller', 'sloodle'))?></li>
        <li><a href="#addcontroller"></a></li>
	<li></li>
<?php } ?>
    </ul>

<?php if ($full) { ?>
     
    <form data-parent="site_1" id="addcontroller" class="panel" title="Add a Course">
    <fieldset>
       <div class="row" style="height:60px;">
          <label for="course_name" name="course_name"><?php echo  s(get_string('rezzer:name', 'sloodle'))?></label>
          <input id="course_name" name="course_name" class="panel" style="width:80%; height:40px; margin:10px;">
       </div>
       <div class="row" style="height:60px;">
          <label for="course"><?php echo  s(get_string('rezzer:course'))?></label>
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
    <ul data-parent="site_1" id="controller_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>" title="<?php echo  s( $cn ) ?> <?php echo  s( $cont->name ) ?>" class="controllercourselayouts_<?php echo  intval($cid)?>" data-id-prefix="layout_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-">
        <li class="group">Scenes</li>
<?php
			$layouts = $courselayouts[ $cid ][$contid];
			foreach($layouts as $layout) {
?>
        <li data-layout-link-li-id="<?php echo  intval($layout->id) ?>" ><a class="layout_link" href="#layout_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>"><?php echo  s($layout->name) ?></a></li>
<?php
			}
?>
	<li class="add_layout_above_me"></li>
        <li class="group"><?php echo  s(get_string('rezzer:addlayout', 'sloodle'))?></li>
        <li><a class="add_layout_link" href="#addlayout_<?php echo  intval($cid) ?>-<?php echo  intval($contid) ?>"><?php echo  s(get_string('rezzer:addlayout', 'sloodle'))?></a></li>
    </ul>
<?php 

		}

	}

}


function print_add_layout_forms( $courses, $controllers, $rezzeruuid ) {
    if (count($courses) > 0) {
	foreach($courses as $course) {
		$cid = $course->id;
        if ( (isset($controllers[$cid]) ) && (count($controllers[$cid]) > 0) ) {
		foreach($controllers[$cid] as $contid => $cont) {
?>
    <form data-parent="controller_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>" id="addlayout_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>" class="panel" title="<?php echo  s(get_string('rezzer:addlayout', 'sloodle'))?> <?php echo  s($course->fullname) ?>">

<div class="upper_button_zone">
<span class="left_zone">
                                <span class="title_text"><?php echo  s( get_string('rezzer:createscene','sloodle')) ?></span>

</span>
<span class="right_zone">

	<span data-creating-text="<?php echo  s(get_string('rezzer:creatingscene', 'sloodle'))?>" data-create-text="<?php echo  s(get_string('rezzer:createscenetitle','sloodle'))?>" class="control_button create_layout_button" type="submit" href="#"><?php echo  s(get_string('rezzer:createscene','sloodle'))?></span>

</span>
</div>

	<input type="hidden" name="courseid" value="<?php echo  intval($cid)?>" />
	<input type="hidden" name="rezzeruuid" value="<?php echo  s($rezzeruuid)?>" />
	<input type="hidden" name="controllerid" value="<?php echo  intval($contid)?>" />
	<fieldset>
	<div class="row" >
		<label for="layoutname"><?php echo  s(get_string('rezzer:layoutname', 'sloodle'))?></label>
		<input id="layoutname" name="layoutname" class="panel" style="width:80%; height:40px; margin:10px;">
	</div>
	</fieldset>
    </form>
<?php
		}
        }
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
			$layouts = $courselayouts[ $cid ][$contid];
			foreach($layouts as $layout) {

				if ($layout->controllerid != $contid) {
					continue;
				}

				$hasactiveobjects = $layout->has_active_objects_rezzed_by_rezzer( $rezzeruuid );
				$entriesbygroup = $layoutentries[ $layout->id ];


				$rezzed_entries = $layout->rezzed_active_objects_by_layout_entry_id( $rezzeruuid );


?>
			    <ul data-parent="controller_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>" class="layout_container layout_container_<?php echo  intval($layout->id) ?>" id="layout_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>" title="<?php echo  htmlentities( $layout->name ) ?>" data-rez-mode="<?php echo  $hasactiveobjects ? 'rezzed' : 'unrezzed'?>" data-action-status="<?php echo  $hasactiveobjects ? 'rezzed' : 'unrezzed'?>" data-connection-status="disconnected">


				<li class="group"><?php echo  s( $layout->name ) ?></li>

<li class="upper_button_zone">
<span class="left_zone">
				<span class="title_text rename_input_text"><?php echo  s( $layout->name) ?></span>
				<span style="display:none" class="rename_input"><input size="20" maxlength="20" class="rename_layout_input" data-rename-input-layoutid="<?php echo  intval($layout->id) ?>" value="<?php echo  s( $layout->name ) ?>" /></span>
			
</span>

<span class="right_zone">

				<span class="control_button rename_layout_button" data-layoutid="<?php echo  intval($layout->id) ?>" data-renamed-text="<?php echo  s(get_string('rezzer:renamelayout', 'sloodle'))?>" data-rename-text="<?php echo  s(get_string('rezzer:renamelayout','sloodle'))?>" data-renaming-text="<?php echo  s(get_string('rezzer:renaminglayout', 'sloodle'))?>" class="control_button" type="submit" ><?php echo  s(get_string('rezzer:renamelayout','sloodle'))?></span>

				<span class="control_button delete_layout_button" data-layoutid="<?php echo  intval($layout->id) ?>" data-deleted-text="<?php echo  s(get_string('rezzer:deletedderezzingobjects', 'sloodle')) ?>" data-delete-text="<?php echo  s(get_string('rezzer:deletelayout', 'sloodle'))?>" data-deleting-text="<?php echo  s(get_string('rezzer:deletinglayout','sloodle'))?>" type="submit"><?php echo  s(get_string('rezzer:deletelayout', 'sloodle'))?></span>

				<span class="control_button clone_layout_button" data-layoutid="<?php echo  intval($layout->id) ?>" data-cloned-text="<?php echo  s(get_string('rezzer:clonelayout','sloodle'))?>" data-cloning-text="<?php echo s(get_string('rezzer:cloninglayout','sloodle'))?>" data-clone-text="<?php echo s(get_string('rezzer:clonelayout','sloodle'))?>" type="submit" ><?php echo s(get_string('rezzer:clonelayout','sloodle'))?></span>
									
				<span class="control_button sync_object_positions" data-freeze-text="<?php echo  s(get_string('rezzer:savecurrentposition', 'sloodle'))?>" data-freezing-text="<?php echo  s(get_string('rezzer:savingcurrentposition', 'sloodle'))?>" type="submit" href="#clonelayout"><?php echo  s(get_string('rezzer:savecurrentposition', 'sloodle'))?></span>

				<span id="derez_all_objects_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>" class="control_button derez_all_objects"> &nbsp; <?php echo  s(get_string('rezzer:derezallobjects', 'sloodle'))?></span>

				<span id="rez_all_objects_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>" class="control_button rez_all_objects double_width"> &nbsp; <?php echo  s(get_string('rezzer:rezallobjects', 'sloodle'))?></span>

				<span id="generate_standard_layout_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>" data-generate-text="<?php echo  s(get_string('rezzer:importmoodleactivities','sloodle', $cn )) ?>" data-generating-text="<?php echo  s(get_string('rezzer:importingmoodleactivities', 'sloodle'))?>" data-layoutid="<?php echo  intval($layout->id) ?>" class="control_button double_width generate_standard_layout"><?php echo  s(get_string('rezzer:importmoodleactivities', 'sloodle', $cn )) ?></span>

</span>

</li>

<li class="fatal_error_zone">
<span class="fatal_error_text">
<?php echo  s(get_string('rezzer:couldnotconnect', 'sloodle', $cn )) ?>
</span>
</li>

<li class="delete_confirmation_zone confirmation_zone">
<span class="delete_confirmation_text confirmation_text">
<?php echo  s(get_string('rezzer:reallydeletescene', 'sloodle'))?>
</span>
<span class="delete_confirmation_button_cancel confirmation_button_cancel"><?php echo s(get_string('No', 'sloodle')); ?></span>
<span class="delete_confirmation_button_ok confirmation_button_ok"><?php echo s(get_string('rezzer:yesdeletelayout', 'sloodle')); ?></span>
</li>

<li class="clone_confirmation_zone confirmation_zone">
<span class="clone_confirmation_text confirmation_text">
<?php echo  s(get_string('rezzer:reallyclonescene', 'sloodle'))?>
</span>
<span class="clone_confirmation_button_cancel confirmation_button_cancel"><?php echo s(get_string('No', 'sloodle')); ?></span>
<span class="clone_confirmation_button_ok confirmation_button_ok"><?php echo s(get_string('rezzer:yesclonescene', 'sloodle')); ?></span>
</li>




<?php
                if (count($entriesbygroup) > 0) {
				foreach($entriesbygroup as $group => $entries) {
?>
					<li class="group"><?php echo  htmlentities( get_string('objectgroup:'.$group, 'sloodle') ) ?></li>
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
					<li class="after_group_<?php echo $group?>"><a class="add_object_link" href="#addobjectgroup_<?php echo  $group ?>_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>"><?php echo s(get_string('rezzer:addobjects', 'sloodle'))?></a></li>
					<li></li>
<?php
				}
                }
?>
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
?><li data-layoutentryid="<?php echo  $e->id?>" id="layoutentryid_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>-<?php echo intval( $e->id ) ?>" class="rezzable_item <?php echo  ( $isrezzed ? 'rezzed' : '' ) ?>"><a href="#configure_layoutentryid_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>-<?php echo intval( $e->id ) ?>"><?php echo  s($entryname) ?><span class="module_info"><?php echo s($modTitle)?></span></span> <span class="rezzable_item_rez_button">&nbsp;</span><span class="rezzable_item_derez_button">&nbsp;</span> <span class="rezzable_item_status">&nbsp;</span> <span class="rezzable_item_positioning">&nbsp;</span> </a></li>
<?php
}

function print_add_object_item_li( $object_title, $config, $cid, $contid, $layout) {
    if (!$config->do_show()) {
        return false;
    }
	$object_title = preg_replace('/^SLOODLE /', '', $object_title);
	$id = "linkto_addobject_{$cid}-{$contid}-{$layout->id}_{$config->type_for_link()}";
?>
        <li id="<?php echo $id?>"><a href="#addobject_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>_<?php echo  $config->type_for_link()?>"><?php echo  s($object_title) ?></a></li>
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
			$layouts = $courselayouts[ $cid ][$contid];
			foreach($layouts as $layout) {
?>
<?php 
				foreach($objectconfigsbygroup as $group => $groupobjectconfigs) {
?>
    <ul <?php echo  $group == 'misc' ? 'class="object_group_misc"' : '' ?> data-parent="layout_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>" id="addobjectgroup_<?php echo  $group ?>_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>" title="<?php echo s(get_string('rezzer:addobjectsforgroup', 'sloodle', $group) ) ?>">
        <li class="group"><?php echo s(get_string('rezzer:addobjectsforgroup', 'sloodle', $group) ) ?></li>
<?php
	foreach($groupobjectconfigs as $object_title => $config) {
        if (!$config) {
            continue;
        }
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

function print_add_object_forms($courses, $controllers, $courselayouts, $object_configs, $rezzeruuid ) {

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
			$layouts = $courselayouts[ $cid ][$contid];
			foreach($layouts as $layout) {
				foreach($object_configs as $object_title => $config) {
/*
The following form is used for adding the object.
But once it's been added, it will be clone()d to make a form to update the object we added.
*/
					print_add_object_form( $config, $cid, $contid, $layout, $object_title, $rezzeruuid );
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

function print_add_object_form( $config, $cid, $contid, $layout, $object_title, $rezzeruuid ) {
    if (!$config->do_show()) {
        return false;
    }
	$id = "addobject_{$cid}-{$contid}-{$layout->id}_{$config->type_for_link()}";
?>
<form data-parent="addobjectgroup_<?php echo  $config->group ?>_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>" class="add_object_form panel addobject_layout_<?php echo  intval($layout->id) ?>_<?php echo  $config->type_for_link()?>" id="<?php echo $id?>" title="<?php echo  s($object_title) ?>" data-primname="<?php echo  s($config->primname)?>" data-courseid="<?php echo intval($cid)?>"  >

<div class="upper_button_zone">
<span class="left_zone">
                                <span class="title_text"><?php echo  s( $object_title) ?></span>

</span>
<span class="right_zone">

<span data-delete-text="<?php echo  s(get_string('rezzer:deleteobject', 'sloodle', $object_title)) ?>" data-deleting-text="<?php echo  s(get_string('rezzer:deletingobject', 'sloodle', $object_title)) ?>" class="control_button delete_layout_entry_button hiddenButton" type="submit"><?php echo  s(get_string('rezzer:deleteobject', 'sloodle', $object_title)) ?></span>

<span data-refresh-text="<?php echo  s(get_string('rezzer:refreshconfig', 'sloodle', $object_title)) ?>" data-refreshing-text="<?php echo  s(get_string('rezzer:refreshingconfig', 'sloodle', $object_title)) ?>" class="control_button refresh_config_button" type="submit"><?php echo  s(get_string('rezzer:refreshconfig', 'sloodle', $object_title)) ?></span>

<span data-updating-text="<?php echo  s(get_string('rezzer:updatingobject', 'sloodle', $object_title )) ?>" data-update-text="<?php echo  s(get_string('rezzer:updateobject', 'sloodle', $object_title )) ?>" data-adding-text="<?php echo  s( get_string('rezzer:addingobject', 'sloodle', $object_title )) ?>" data-add-text="<?php echo  s( get_string('rezzer:addobject', 'sloodle', $object_title )) ?>" class="control_button add_to_layout_button" target="_self" type="submit"><?php echo  s( get_string('rezzer:addobject', 'sloodle', $object_title) )  ?></span>

</span>
</div>


<input type="hidden" name="rezzeruuid" value="<?php echo  htmlentities($rezzeruuid) ?>" />
<input type="hidden" name="objectname" value="<?php echo  htmlentities($object_title) ?>" />
<input type="hidden" name="objectgroup" value="<?php echo  htmlentities($config->group) ?>" />
<input type="hidden" name="layoutid" value="<?php echo  intval($layout->id) ?>" />
<input type="hidden" name="layoutentryid" value="0" />
<input type="hidden" name="controllerid" value="<?php echo  intval($contid) ?>" />
<input type="hidden" name="courseid" value="<?php echo  intval($cid) ?>" />
<?php if ($config->module) { 
$moduleoptionselect = $config->course_module_select( $cid, $val = null ); 
?>
<fieldset>
<div class="row">
<label for="<?php echo  'sloodlemoduleid' ?>"><?php echo  $config->module_choice_message ? get_string($config->module_choice_message, 'sloodle') : ''?></label>
<span class="sloodle_config" data-fieldname="sloodlemoduleid">
<?php echo  $moduleoptionselect ? $moduleoptionselect : '<span class="no_options_placeholder" data-fieldname="sloodlemoduleid">'.( ( $config->module_no_choices_message != '' ) ? get_string($config->module_no_choices_message , 'sloodle') : '' ) .'</span>' ?>
</span>
</div>
</fieldset>
<?php
} ?>
<?php foreach($config->field_set_row_groups() as $fsrg) { ?>
<fieldset>
<?php foreach($fsrg as $ctrls) { ?>
<?php $ctrls_reversed = array_reverse($ctrls); ?>
<?php $first_ctrl = array_shift($ctrls); ?>
<div class="row" data-row-name="<?php echo  isset($first_ctrl->row_name) ? $first_ctrl->row_name : '' ?>" >
<label for="<?php echo  isset($first_ctrl->fieldname) ? $first_ctrl->fieldname : '' ?>"><?php echo  $first_ctrl->title ? s(get_string($first_ctrl->title,'sloodle')) : ''?></label>
<?php foreach($ctrls_reversed as $ctrl) { ?>
<?php $fieldname = $ctrl->fieldname; ?>
<span class="sloodle_config object_<?php echo  s($config->type_for_link())?>" data-courseid="<?php echo intval($cid)?>" data-fieldname="<?php echo $fieldname?>">
<?php if ( ($ctrl->type == 'radio') || ($ctrl->type == 'yesno') ) { ?>
<?php foreach($ctrl->options as $opn => $opv) { ?>
<input type="radio" name="<?php echo  $fieldname ?>" value="<?php echo  $opn ?>" <?php echo  $opn == $ctrl->default ? 'checked ' : '' ?>> <?php echo  $ctrl->is_value_translatable ? get_string($opv, 'sloodle') : s($opv) ?> &nbsp; &nbsp; 
<?php } ?>
<?php } else if ($ctrl->type == 'select') { ?>
<select name="<?php echo  $fieldname ?>">
<?php foreach($ctrl->options as $opn => $opv) { ?>
<option value="<?php echo  $opn ?>" <?php echo  $opn == $ctrl->default ? 'selected="selected"' : '' ?>> <?php echo  $ctrl->is_value_translatable ? get_string($opv, 'sloodle') : s($opv) ?></option>
<?php } ?>
</select>
<?php } else if ($ctrl->type == 'input') { ?>
<input type="text" size="<?php echo  $ctrl->size ?>" maxlength="<?php echo  $ctrl->max_length ?>" name="<?php echo  $fieldname ?>" value="<?php echo  $ctrl->default ?>" /> 
<?php } else { ?>
<?php echo $ctrl->type?>
<?php } ?>
</span>
<?php } ?>
</div>
<?php } ?>
</fieldset>
<?php } ?>
</form>

<br />

<?php
	return $id;
}

/*
Configuration form for each 
*/
function print_edit_object_forms($courses, $controllers, $courselayouts, $object_configs, $layoutentries, $rezzeruuid) {

    if (count($courses) > 0) {
	foreach($courses as $course) {
		$cid = $course->id; 
		$cn = $course->fullname; 
        if ( ( isset($controllers[$cid]) ) && (count($controllers[$cid]) > 0) ) {
		foreach($controllers[$cid] as $contid => $cont) {
			$layouts = $courselayouts[ $cid ][$contid];
            if (count($layouts) > 0) {
			foreach($layouts as $layout) {
				$entriesbygroup = $layoutentries[ $layout->id ];
				$lid = $layout->id;
                if (count($entriesbygroup) > 0) {
				foreach($entriesbygroup as $group => $entries) {
                    if (count($entries) > 0) {
					foreach($entries as $e) {
						$entryname = $e->name;	
                        if (!isset($object_configs[$entryname])) {
                            //print "error: no config for entry :$entryname:";
                            //var_dump($object_configs);
                            //print ":";
                            //var_dump(array_keys($object_configs));
                            //exit;
                            continue; // No config - skip it.
                        }
						$config = $object_configs[$entryname]; // TODO: Merge in the layout entries

						print_config_form( $e, $config, $cid, $contid, $lid, $group, $rezzeruuid );
						
					}
                    }
				}
                }
?>
<span id="add_configuration_above_me_layout_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($layout->id) ?>"></span>
<?php
			}
            }
		}
        }
	}
    }
?>
<span id="add_edit_object_forms_above_me"></span>
<?php
}

function print_config_form( $e, $config, $cid, $contid, $lid, $group, $rezzeruuid ) {

						$lconfig = $e->get_layout_entry_configs_as_name_value_hash();
						$entryname = preg_replace('/SLOODLE\s/', '', $e->name);
						$object_title = $entryname;

	$id = "configure_layoutentryid_{$cid}-{$contid}-{$lid}-{$e->id}";

?>
<form data-parent="layout_<?php echo  intval($cid)?>-<?php echo  intval($contid) ?>-<?php echo  intval($lid) ?>" id="<?php echo $id?>" class="panel edit_object_form" title="<?php echo  s($object_title) ?>" data-primname="<?php echo  s($config->primname)?>" data-courseid="<?php echo intval($cid)?>">


<div class="upper_button_zone">
<span class="left_zone">
                                <span class="title_text"><?php echo  s( $object_title) ?></span>

</span>
<span class="right_zone">


<span data-delete-text="<?php echo  s(get_string('rezzer:deleteobject', 'sloodle', $object_title)) ?>" data-deleting-text="<?php echo  s(get_string('rezzer:deletingobject', 'sloodle', $object_title)) ?>" class="control_button delete_layout_entry_button" type="submit"><?php echo  s(get_string('rezzer:deleteobject', 'sloodle', $object_title)) ?></span>

<span data-refresh-text="<?php echo  s(get_string('rezzer:refreshconfig', 'sloodle', $object_title)) ?>" data-refreshing-text="<?php echo  s(get_string('rezzer:refreshingconfig', 'sloodle', $object_title)) ?>" class="control_button refresh_config_button" type="submit"><?php echo  s(get_string('rezzer:refreshconfig', 'sloodle', $object_title)) ?></span>

<span data-updating-text="<?php echo  s(get_string('rezzer:updatingobject', 'sloodle', $object_title )) ?>" data-update-text="<?php echo  s(get_string('rezzer:updateobject', 'sloodle', $object_title )) ?>" class="control_button update_layout_entry_button" target="_self" type="submit"><?php echo  s(get_string('rezzer:updateobject', 'sloodle', $object_title )) ?></span>

</span>
</div>


<input type="hidden" name="layoutid" value="<?php echo  intval($lid) ?>" />
<input type="hidden" name="rezzeruuid" value="<?php echo  htmlentities($rezzeruuid) ?>" />
<input type="hidden" name="layoutentryid" value="<?php echo  intval($e->id) ?>" />
<input type="hidden" name="controllerid" value="<?php echo  intval($contid) ?>" />
<input type="hidden" name="objectgroup" value="<?php echo  htmlentities( get_string('objectgroup:'.$group, 'sloodle' ) ) ?>" />
<?php if ($config->module) { 
$moduleoptionselect = $config->course_module_select( $cid, isset($lconfig['sloodlemoduleid']) ? $lconfig['sloodlemoduleid'] : ''); 
?>
<fieldset>
<div class="row">
<label for="<?php echo  isset($config->fieldname) ? $config->fieldname : '' ?>"><?php echo  get_string($config->module_choice_message, 'sloodle') ?></label>
<span class="sloodle_config" data-courseid="<?php echo intval($cid)?>" data-fieldname="sloodlemoduleid" >
<?php echo  $moduleoptionselect ? $moduleoptionselect : '<span class="no_options_placeholder" data-fieldname="sloodlemoduleid">'.( ( $config->module_no_choices_message != '' ) ?  get_string($config->module_no_choices_message, 'sloodle') : '').'</span>' ?>
</span>
</div>
</fieldset>
<?php
} ?>
<?php foreach($config->field_set_row_groups() as $fs => $fsrg) { ?>
<fieldset>
<?php if (count($fsrg) > 0) { ?>
<?php foreach($fsrg as $ctrls) { ?>
<?php $ctrls_reversed = array_reverse($ctrls); ?>
<?php $first_ctrl = array_shift($ctrls); ?>
<div class="row" data-row-name="<?php echo  isset($first_ctrl->row_name) ? $first_ctrl->row_name : '' ?>" >
<label for="<?php echo  $first_ctrl->fieldname ?>"><?php echo  get_string($first_ctrl->title, 'sloodle') ?></label>
<?php foreach($ctrls_reversed as $ctrl) { ?>
<?php $fieldname = $ctrl->fieldname; ?>
<?php 	$val = isset($lconfig[$fieldname]) ? $lconfig[$fieldname] : ''; ?>
<span class="sloodle_config object_<?php echo  s($config->type_for_link())?>" data-courseid="<?php echo intval($cid)?>" data-fieldname="<?php echo $fieldname?>" >
<?php if ( ($ctrl->type == 'radio') || ($ctrl->type == 'yesno') ) { ?>
<?php foreach($ctrl->options as $opn => $opv) { ?>
<input type="radio" name="<?php echo  $fieldname ?>" value="<?php echo  $opn ?>" <?php echo  $opn == $val ? 'checked ' : '' ?>> <?php echo  $ctrl->is_value_translatable ? get_string($opv, 'sloodle') : s($opv) ?> &nbsp; &nbsp; 
<?php } ?>
<?php } else if ($ctrl->type == 'select') {?>
<select name="<?php echo  $fieldname ?>">
<?php foreach($ctrl->options as $opn => $opv) { ?>
<option value="<?php echo  $opn ?>" <?php echo  $opn == $val ? 'selected="selected"' : '' ?>> <?php echo  $ctrl->is_value_translatable ? get_string($opv, 'sloodle') : s($opv) ?></option> 
<?php } ?>
</select>
<?php } else if ($ctrl->type == 'input') {?>
<input type="text" size="<?php echo  $ctrl->size ?>" maxlength="<?php echo  $ctrl->max_length ?>" name="<?php echo  $fieldname ?>" value="<?php echo  $val ?>" /> 
<?php } else {?>
<?php echo $ctrl->type?>
<?php } ?>
</span>
<?php } ?>
</div>
<?php } ?>
<?php } ?>
</fieldset>
<?php } ?>
</form>

<br />
<?php 

	return $id;
}
?>

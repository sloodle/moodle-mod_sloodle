<?php
/*
Functions used for compatibility where the Moodle APIs change.
We should probably move db.php in here too.
*/
function sloodle_require_js($js) {

    global $PAGE;
    global $CFG;

    // Moodle 2.4
    // We could probably go earlier than this, but this is where it definitively breaks.
    if ($CFG->version >= 2012120303) {
        $PAGE->requires->js( new moodle_url($js) );
    } else {
        require_js($js);
    }

}

function sloodle_helpbutton($page, $title, $module, $image =  null, $linktext = null, $text = null, $return = null, $imagetext = null) {
    global $CFG;
    global $OUTPUT;
return;
    if ($CFG->version >= 2012120303) {
	$helpicon = new help_icon();
        $helpicon->page = $page; // required
        $helpicon->text = $title; // required
        $helpicon->module = $module; // defaults to 'moodle'
        $helpicon->linktext = $linktext;
        echo $OUTPUT->help_icon($helpicon);
    } else {
        return helpbutton($page, $title, $module, $image, $linktext, $text, $return, $imagetext);
    }

}

function sloodle_heading($text, $align = null, $size = null, $class = null, $id = null) {
 
    global $CFG;
    global $OUTPUT;
    if ($CFG->version >= 2012120303) {
        return $OUTPUT->heading($text, $size, $class, $id);
    } else {
        return print_heading($text, $align, $size, $class, true, $id);
    }

}

function sloodle_print_heading($text, $align = '', $size = 2, $class = 'main', $return = null, $id = null) {
    if ($return) {
        return sloodle_heading($text, $align , $size , $class , $id ); 
    } else {
        echo sloodle_heading($text, $align , $size , $class , $id ); 
    }
}

function sloodle_header($title, $heading, $navigation, $focus, $meta, $cache, $button, $menu, $usexml, $bodytags) {
 
    global $CFG;
    global $OUTPUT;
    global $PAGE;
    if ($CFG->version >= 2012120303) {
        $PAGE->set_heading($heading); // Required
        $PAGE->set_title($title);
        $PAGE->set_cacheable($cache);
        $PAGE->set_focuscontrol($focus);
        $PAGE->set_button($button);
        if (is_array($navigation) && count($navigation)) {
           foreach($navigation as $naventry) {
              if ($naventry) {
                 $PAGE->navbar->add($naventry);
              }
           }
        }
        return $OUTPUT->header();
    } else {
        return print_header($title, $heading, $navigation, $focus, $meta, $cache, $button, $menu, $usexml, $bodytags, true); 
    }

}

function sloodle_print_header($title='', $heading='', $navigation='', $focus='',$meta='', $cache=true, $button='&nbsp;', $menu='',$usexml=false, $bodytags='', $return=false)  {
    if ($return) {
        return sloodle_header($title, $heading, $navigation, $focus, $meta, $cache, $button, $menu, $usexml, $bodytags); 
    } else {
        echo sloodle_header($title, $heading, $navigation, $focus, $meta, $cache, $button, $menu, $usexml, $bodytags); 
    }
}

function sloodle_print_header_simple($title='', $heading='', $navigation='', $focus='', $meta='',$cache=true, $button='&nbsp;', $menu='', $usexml=false, $bodytags='', $return=false) {
    if ($return) {
        return sloodle_header_simple($title, $heading, $navigation, $focus, $meta,$cache, $button, $menu, $usexml, $bodytags, true); 
    } else {
        echo sloodle_header_simple($title, $heading, $navigation, $focus, $meta,$cache, $button, $menu, $usexml, $bodytags, true); 
    }
}


function sloodle_header_simple($title='', $heading='', $navigation='', $focus='', $meta='',$cache=true, $button='&nbsp;', $menu='', $usexml=false, $bodytags='') {

    global $CFG;
    global $OUTPUT;
    global $PAGE;
    if ($CFG->version >= 2012120303) {
        $PAGE->set_heading($heading); // Required
        $PAGE->set_title($title);
        $PAGE->set_cacheable($cache);
        $PAGE->set_focuscontrol($focus);
        $PAGE->set_button($button);
        if (is_array($navigation) && count($navigation)) {
           foreach($navigation as $naventry) {
              if ($naventry) {
                 $PAGE->navbar->add($naventry);
              }
           }
        }
        return $OUTPUT->header();
    } else {
        return print_header_simple($title, $heading, $navigation, $focus, $meta, $cache, $button, $menu, $usexml, $bodytags, true); 
    }

}


function sloodle_print_footer($course = null) {
 
    global $CFG;
    global $OUTPUT;
    if ($CFG->version >= 2012120303) {
        echo $OUTPUT->footer($course);
    } else {
        print_footer($course);
    }

}

function sloodle_print_box($message, $classes = '', $ids = '') {
 
    global $CFG;
    global $OUTPUT;
    if ($CFG->version >= 2012120303) {
        echo $OUTPUT->box($message, $classes, $ids);
    } else {
        print_box($message, $classes, $ids);
    }

}

function sloodle_print_box_start($classes = '', $ids = '') {
 
    global $CFG;
    global $OUTPUT;
    if ($CFG->version >= 2012120303) {
        echo $OUTPUT->box_start($classes, $ids);
    } else {
        print_box_start($classes, $ids);
    }

}

function sloodle_print_box_end() {
 
    global $CFG;
    global $OUTPUT;
    if ($CFG->version >= 2012120303) {
        echo $OUTPUT->box_end();
    } else {
        print_box_end();
    }

}

function sloodle_print_table($table) {
 
    global $CFG;
    if ($CFG->version >= 2012120303) {
        // We've probably passed in a stdClass, so turn it into an html_table
        if (!is_a($table, 'html_table')) {
            $table = sloodle_cast(new html_table(), $table);
        }
        echo html_writer::table($table);
    } else {
        print_table($table);
    }

}

function sloodle_cast($destination, stdClass $source) {
    $sourceReflection = new ReflectionObject($source);
    $sourceProperties = $sourceReflection->getProperties();
    foreach ($sourceProperties as $sourceProperty) {
        $name = $sourceProperty->getName();
        $destination->{$name} = $source->$name;
    }
    return $destination;
}


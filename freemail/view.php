<?php
 /**
* Freemail v1.1 with SL patch
*
* @package freemail
* @copyright Copyright (c) 2008 Serafim Panov
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @author Serafim Panov
* @contributor: Paul G. Preibisch - aka Fire centaur in Second Life
*
*/


require_once "../../config.php";

$PAGE->set_context(get_system_context());
$PAGE->set_context(get_context_instance(CONTEXT_COURSE, SITEID));

$PAGE->set_url('/mod/freemail/view.php');
$PAGE->set_title('Postcard Blogger');
$PAGE->set_heading('Postcard Blogger.');

require_login();

echo $OUTPUT->header();



//$PAGE->set_context(context_system::instance());
//$PAGE->set_pagelayout('standard');

$freemail_dir = dirname(__FILE__);

require_once $freemail_dir.'/lib/freemail_imap_message_handler.php'; 
require_once $freemail_dir.'/lib/freemail_email_processor.php'; 
require_once $freemail_dir.'/lib/freemail_moodle_importer.php'; 

$noticeTable = new html_table();
$noticeTable->head = array('SLOODLE Freemail - Postcard Blogger');
$r = array();
$body = get_string('freemail_explanation_wheretosend','freemail', $CFG->freemail_mail_user_name);
$body .= ' ';
$body .= get_string('freemail_explanation_howtoblog','freemail');
$r[] = $body;

$courseTable = new stdClass();
$courseTable->class="course-view";

$noticeTable->cellpadding=10;
$noticeTable->cellspacing=10; 
$noticeTable->data[] = $r;  
echo html_writer::table($noticeTable);

$nodelete = false;
if (isset($_POST['nodelete'])) {
    $nodelete = true;
}

?>
<div style="text-align:center; width:100%">
<form method="POST">
<input type="hidden" value="1" name="do_test" />
<input type="checkbox" name="nodelete" value="1" <?php echo $nodelete ? ' checked="checked" ' : ''?>/>
<?php
echo get_string('freemail_delete_message', 'freemail');
?>
<br />
<input type="submit" value="<?php echo get_string('freemail_testbutton', 'freemail')?>" />
</form>
</div>

<p><br /></p>
<?php


if (isset($_POST['do_test'])) {

    $verbose = true;
    $daemon = false;

    echo '<textarea rows="10" style="width:100%">';
    freemail_email_processor::read_mail($CFG, $verbose, $daemon, null, $nodelete);
    echo '</textarea>';
}
if ($nodelete && $daemon) {
    echo "Refusing to run in daemon mode with nodelete specified, as this will spam you into oblivion.\n";
    exit;
}


echo $OUTPUT->footer();
exit;


//echo $OUTPUT->heading('SLOODLE Freemail - Postcard Blogger', 1);
//exit;






$PAGE->set_state(1);
$PAGE->set_state(2);

echo $OUTPUT->footer();
exit;

//$OUTPUT->footer();

?>

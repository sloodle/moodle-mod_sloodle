<?php
require_once(SLOODLED_BASE_DIR.'/init.php');

if ( !defined('SLOODLE_MESSAGE_QUEUE_TASK') || !SLOODLE_MESSAGE_QUEUE_TASK) {
    echo 'This task should be run by the sloodled daemon';
    exit;
}

if ( ($info['http_code']) != 200 ) {
    print "http code ".$info['http_code']." was wrong, giving up";
    return false;
}

// Response should look like this:
// body = (string)id+"\n"+(string)llGetKey()+"\n"+rez_object_prim_password+"\n"+(string)rez_object_http_in_password+"\n"+rez_object_layout_entry_id;
$result_lines = explode("\n",$result);
$rezzed_object_uuid = array_shift($result_lines);
$rezzeruuid = array_shift($result_lines);
$primpassword = array_shift($result_lines);
$rez_http_in_password = array_shift($result_lines);
$layoutentryid = array_shift($result_lines);

$layoutentry = new SloodleLayoutEntry();    
if ( !$layoutentry->load( $layoutentryid ) ) {
    if ($verbose) {
        print "error loading layout entry :$layoutentryid:\n";
    }
    return false; 
}
if (!$layout = $layoutentry->get_layout()) {
    if ($verbose) {
        print "error loading layout \n";
    }
    return false;
}
if (!$controllerid = $layout->controllerid) {
    if ($verbose) {
        print "error layout lacks controllerid\n";
    }
    return false;
}

// TODO: Get actual object name via layoutentryid
$objectname = $layoutentry->name;
if ( !$objectname ) {
    if ($verbose) {
        print "error no objectname\n";
    }
    return false;
}

$config = SloodleObjectConfig::ForObjectName( $objectname );

$controller = new SloodleController();
if (!$controller->load( $controllerid )) {
print "error loading controller\n";
    return false;
}

$rezzer = new SloodleActiveObject();
if ( !$rezzer->loadByUUID($rezzeruuid) ) {
print "error loading rezzer\n";
    return false;
}

$sloodleuser = new SloodleUser();
if ( !$authid = $controller->register_object($rezzed_object_uuid, $objectname, $sloodleuser, $primpassword, $rez_http_in_password, $config->type()) ) {
print "error registering\n";
    return false;
}

if (!$controller->configure_object_from_layout_entry($authid, $layoutentryid, $rezzer->uuid)) {
print "error configuring\n";
    return false;
}



return true;
// The object may have registered itself and its URL before we got here.
// In that case, send it its config.
// TODO: This uses more db hits than it should - it would be better if register_object returned the object, not just its ID.
$ao = new SloodleActiveObject();
if ($ao->loadByUUID($rezzed_object_uuid)) {
    if ($ao->httpinurl) {
            $extraParams = array('sloodlerezzeruuid' => $rezzer->uuid);
            $ao->sendConfig($extraParams, $async = false);
    }
}

?>

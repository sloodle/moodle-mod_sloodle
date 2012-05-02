<?php
if ( !defined('SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE') || (SLOODLE_SHARED_MEDIA_LOGOUT_INCLUDE == '') ) {
        exit;
}

require_logout();
if (isset($_REQUEST['sloodleobjname'])) {
    // Legacy versino
    header('Location: http://dev1.www.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/'.$baseurl.'&ts='.time().'&logout');
} else {
    header('Location: http://dev1.www.avatarclassroom.com/mod/sloodle/mod/set-1.0/shared_media/logout.php?sloodleobjuuid='.$_REQUEST['sloodleobjuuid']);
}
exit;
?>

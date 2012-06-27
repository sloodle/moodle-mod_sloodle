<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Liquid (Blue)';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('Devil Island A');
$sloodleconfig->aliases    = array();
$sloodleconfig->field_sets = array(
        'accesslevel' => array(
                'sloodleobjectaccessleveluse'  => $sloodleconfig->access_level_object_use_option(),
                'sloodleserveraccesslevel'     => $sloodleconfig->access_level_server_option(),
        ),
        'awards' => array_merge(
                $sloodleconfig->awards_deposit_options( array( 'default' => 'awards:interactwithobjectplus' ) ),
                $sloodleconfig->awards_require_options( array( 'default' => 'awards:interactwithobjectrequires' ) ),
                $sloodleconfig->awards_withdraw_options( array( 'default' => 'awards:interactwithobjectminus' ) )
         )
        //'awards' => $sloodleconfig->awards_deposit_options( array( 'touch' => 'awards:answerquestionaward' ) )
        //'awards' => $sloodleconfig->awards_setting_options() // Allows you to award points for taking part in a discussion. Not sure if we want to display this or not...
//        'awards' => $sloodleconfig->awards_pay_options()


);
?>

<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Puzzle Game';
$sloodleconfig->group      = 'activity';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Gaming A');
$sloodleconfig->aliases    = array();
$sloodleconfig->field_sets = array(
   'generalconfiguration'=> array(
        'texture_uuid' => new SloodleConfigurationOptionText( 'texture_uuid', 'misc:texture_uuid', '', '355220a5-21f2-5680-970d-67d75977eb96', 50 )
   ),
      'awards' => array_merge( 
      $sloodleconfig->awards_deposit_options( array( 'puzzlepiece' => 'awards:puzzlepieceplus' ) ),
      $sloodleconfig->awards_require_options( array( 'puzzlepiece' => 'awards:interactwithobjectrequires' ) ),
      $sloodleconfig->awards_withdraw_options( array( 'puzzlepiece' => 'awards:puzzlepieceminus' ) )


	 )
);
?>

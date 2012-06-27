<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Sign';
$sloodleconfig->group      = 'misc';
$sloodleconfig->aliases    = array('sign');
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'title' => new SloodleConfigurationOptionText( 'title', 'misc:title', '', 'Meeting Area', 50 ),
  'color' => new SloodleConfigurationOptionText( 'color', 'misc:textcolor', '', "#ffffff", 50 ),
  'bgcolor' => new SloodleConfigurationOptionText( 'bgcolor', 'misc:textcolor', '', "#965221", 10 ),
   'fontsize' => new SloodleConfigurationOptionText( 'fontsize', 'misc:fontsize', '', "150", 10 )
 ));

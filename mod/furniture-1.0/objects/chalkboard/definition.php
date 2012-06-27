<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Chalkboard';
$sloodleconfig->group      = 'misc';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'chalkboardtext' => new SloodleConfigurationOptionText( 'chalkboardtext', 'misc:chalkboardtext', '', 'Type your message on channel 9', 200 ),
  'channel' => new SloodleConfigurationOptionText( 'channel', 'misc:channel', '', '9', 10 )
 ));

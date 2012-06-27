<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'Twitter Wall';
$sloodleconfig->group      = 'misc';
$sloodleconfig->aliases    = array('Twitterwall');
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
//parameter name, translation text, description, default value, length
$sloodleconfig->field_sets = array(
'generalconfiguration'=> array(
 'searchterm' => new SloodleConfigurationOptionText( 'searchterm', 'misc:twittersearchterm', '', '#AvatarClassroom', 200 ),
 'title' => new SloodleConfigurationOptionText( 'title', 'misc:twitterwalltitle', '', 'Avatar Classroom', 50),
 'caption' => new SloodleConfigurationOptionText( 'caption', 'misc:twitterwallcaption', '', 'Twitter Wall', 50),
  'channel' => new SloodleConfigurationOptionText( 'channel', 'misc:channel', '', '10', 10 )
 ));

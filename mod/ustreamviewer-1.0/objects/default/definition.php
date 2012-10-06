<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'UStream Viewer';
$sloodleconfig->group      = 'communication';
$sloodleconfig->collections= array('Avatar Classroom 2.0 Furniture A');
$sloodleconfig->aliases    = array();
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array(
                'sloodleustreamchannel' => new SloodleConfigurationOptionText( 'sloodleustreamchannel', 'ustreamchannel', '', '', 40 ),
	),
);
?>

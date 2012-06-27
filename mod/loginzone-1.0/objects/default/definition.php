<?php
$sloodleconfig = new SloodleObjectConfig();
$sloodleconfig->primname   = 'SLOODLE LoginZone';
$sloodleconfig->group      = 'registration';
$sloodleconfig->collections= array('SLOODLE 2.0');
$sloodleconfig->aliases    = array('SLOODLE 1.1 LoginZone');
$sloodleconfig->field_sets = array( 
	'generalconfiguration' => array(
		'sloodlerefreshtime'   => new SloodleConfigurationOptionText( 'sloodlerefreshtime', 'refreshtimeseconds', '', 600, 8),
	)
);
?>

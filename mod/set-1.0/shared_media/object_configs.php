<?php
// TODO: This probably should be loaded from a config.php under each tool
if (!isset($object_configs)) {
	$object_configs = array();
} 

$object_configs['SLOODLE RegEnrol Booth'] = array(
	'group'   => 'Registration',
	'aliases' => array( 'SLOODLE 1.1 RegEnrol Booth'), 
);

$object_configs['SLOODLE Vending Machine'] = array(
	'group'   => 'Inventory',
	'aliases' => array( 'SLOODLE 1.1 Vending Machine'), 
);

$object_configs['SLOODLE LoginZone'] = array(
	'group'   => 'Registration',
	'aliases' => array( 'SLOODLE 1.1 LoginZone'), 
);
?>

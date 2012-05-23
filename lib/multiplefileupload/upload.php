<?php
// Uploadify v1.6.2
// Copyright (C) 2009 by Ronnie Garcia
// Co-developed by Travis Nickels

require_once('../../init.php');
//include('../../../../config.php');

$cmid = (int)$_GET['cmid'];
if (!$cmid) {
	echo "Module ID missing";
	exit;
}

$itemid = (int)$_GET['itemid'];
if (!$itemid) {
	echo "Module ID missing";
	exit;
}

$signature = $_REQUEST['signature'];
$signeddata = $_REQUEST['signeddata'];

if ($signature != sloodle_signature($signeddata)) {
	echo "Invalid signature";
	exit;
}

$bits = explode('-', $signeddata);
if ($bits[2] != $cmid) {
	echo "Invalid signature";
	exit;
}



if (SLOODLE_IS_ENVIRONMENT_MOODLE_2) {

	$fs = get_file_storage();
	 
//$url = $CFG->wwwroot/pluginfile.php/$forumcontextid/mod_forum/post/$postid/image.jpg
	// Prepare file record object
	//$targetPath = $CFG->dataroot.'/'.SITEID.'/presenter/'.(int)$_GET["moduleId"].'/';
	$filename = str_replace(' ','_',$_FILES['Filedata']['name']);
//$filename='edmanga3.jpg';

	$extension = ''; 
	if (preg_match('/^[A-Za-z0-9]+\.(.*?)$/', $filename, $matches)) {
		$extension = $matches[1];
	}

	$allowable = array('jpg','gif','png','mov','mpg'); 

	//get the extension of the file being uploaded              
	$fileext = strtolower($extension);
	if (!in_array($fileext, $allowable)) {
		echo "This $filename file is not allowed.";
		exit();
	}

    $context = get_context_instance(CONTEXT_MODULE, $cmid); 
    $contextid = $context->id;

	$fileinfo = array(
	    'contextid' => $contextid, // ID of context
	    'component' => 'mod_sloodle',     // usually = table name
	    'filearea' => 'presenter',     // usually = table name
	    'itemid' => $itemid,               // usually = ID of row in table
//	    'filepath' => '/presenter',           // any path beginning and ending in /
	    'filepath' => '/'.$contextid.'/mod_sloodle/presenter/'.$itemid.'/',
	    'filename' => $filename
	);

	$tmpfilename = $_FILES['Filedata']['tmp_name'] ;
//$tmpfilename='/tmp/edmanga.jpg';

	$fs->create_file_from_pathname( $fileinfo, $tmpfilename);
	echo 1;

} else {

	if (!empty($_FILES)) {

	    $tempFile = $_FILES['Filedata']['tmp_name'];
	    $targetPath = $CFG->dataroot.'/'.SITEID.'/'.$cmid.'/sloodle/presenter/';
	    $targetFile =  str_replace('//','/',$targetPath) . str_replace(' ','_',$_FILES['Filedata']['name']);
	     
	    //Server side security check
	    //only allow images!!!
	    //$allowable = array ('.jpg','.gif','.png','.htm','.html','.mov'); 
	    $allowable = array('.jpg','.gif','.png','.mov','.mpg'); 

	    $extension = ''; 
	    if(preg_match('/^[A-Za-z0-9]\.(.*?)$/', $targetFile, $matches)) {
		$extension = $matches[2];
	    }

	    //get the extension of the file being uploaded              
	    $fileext = strtolower($extension);
	    if (!in_array($fileext, $allowable)) {
	      echo "This file is not allowed.";
	      exit();
	    }
	    
	    mkdir(str_replace('//','/',$targetPath), 0755, true);
	    move_uploaded_file($tempFile,$targetFile);
	    echo 1;
	    // TODO: Change this to echo file path 

	} 

}
?>

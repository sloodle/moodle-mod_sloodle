<?php
// Uploadify v1.6.2
// Copyright (C) 2009 by Ronnie Garcia
// Co-developed by Travis Nickels

include('../../../../config.php');

if (!empty($_FILES)) {
    $tempFile = $_FILES['Filedata']['tmp_name'];
    $targetPath = $CFG->dataroot.'/'.SITEID.'/presenter/'.(int)$_GET["moduleId"].'/';
    $targetFile =  str_replace('//','/',$targetPath) . str_replace(' ','_',$_FILES['Filedata']['name']);
     
    //Server side security check
    //only allow images!!!
    $allowable = array ('.jpg','.gif','.png','.htm','html','.mov'); 
    //get the extension of the file being uploaded              
    $fileext = strtolower(substr($targetFile, -4 ));
    
     // Assume evil upload 
     $noMatch = 0;
     // Give it a try with this tiny extensionckeck    
     foreach( $allowable as $ext ) {
      if ( strcasecmp( $fileext, $ext ) == 0 ) {
         $noMatch = 1;
      }
     }   
    if(!$noMatch){ // an evil upload was attempted by an evil avatar!!!
      echo "This file is not allowed...";
      exit();
    }
   else { //oh, its a good avatar uploading good files
      mkdir(str_replace('//','/',$targetPath), 0755, true);
      move_uploaded_file($tempFile,$targetFile);
      echo "1";
   }
} 
?>

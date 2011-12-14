<?php
// This file is part of the Sloodle project (www.sloodle.org) and is released under the GNU GPL v3.

/**
* Defines the SLOODLE Presenter importer plugin for converting a PDF file to a list of images (1 image per page).
* Many thanks to Jordan Guinaud for his original code which made this plugin possible.
* Note: this plugin requires PHP >= 4.1.0 and the presence of the IMagick extension.
*
* @package sloodle
* @copyright Copyright (c) 2009 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
* @since Sloodle 0.4.1
*
* @contributor Jordan Guinaud
* @contributor Peter R. Bloomfield
*
*/


// Path to the ImageMagick "convert" program. Leave it blank to DISABLE this feature for security.
// On Linux, it is likely to be '/usr/bin/convert' or '/usr/local/bin/convert'
// On Windows, you can probably just use 'convert'
// Note: the PDF Importer plugin will attempt to auto-detect the location. You only need to modify this if the plugin can't find it.
global $IMAGICK_CONVERT_PATH;
$IMAGICK_CONVERT_PATH = '/usr/bin/convert';


/**
* Presenter plugin for importing a PDF file as a series of image slides.
*
* @package sloodle
*/
class SloodlePluginPresenterPDFImporter extends SloodlePluginBasePresenterImporter
{
    /**
    * This string will contain a description of the plugin's compatibility after the compatibility check function is called.
    * It will be stored in the current language when the compatibility check function is called, assuming there is a suitable SLOODLE language file installed.
    * @var string
    * @access public
    */
    var $compatibility_summary = '';

    /**
    * Gets the identifier of this plugin.
    * This function MUST be overridden by sub-classes to return an ID that is unique to the category.
    * It is possible to have different plugins of the same ID in different categories.
    * This function is given a very explicitly sloodley name as it lets us ignore any classes which don't declare it.
    * @access public
    * @return string|bool The ID of this plugin, or boolean false if this is a base class and should not be instantiated as a plugin.
    */
    function sloodle_get_plugin_id()
    {
        return 'pdf-imagemagick';
    }

    /**
    * Render this importer on a web page.
    * All importing functionality should be handled by this function as well.
    * @param string $url A URL to this Presenter, without a "mode" parameter.
    * @param SloodleModulePresenter $presenter An object representing this Presenter.
    */
    function render($url, $presenter)
    {
        // Get translation strings
        $struploadfile = get_string('upload:file', 'sloodle');
        $strselectuploadfile = get_string('upload:selectfile', 'sloodle');
        $strimportposition = get_string('presenter:importposition', 'sloodle');
        $strimportfromcomputer = get_string('presenter:importfrommycomputer', 'sloodle');
        $strimportname = get_string('presenter:importname', 'sloodle');
        $strimportnamecaption = get_string('presenter:importnamecaption', 'sloodle');

        // Get expected form data
        $selectfile = optional_param('selectfile', '', PARAM_CLEAN);
        $uploadfile = optional_param('uploadfile', '', PARAM_CLEAN);
        $importname = optional_param('importname', '', PARAM_CLEAN);
        $position = (int)optional_param('sloodleentryposition', -1, PARAM_INT);
        
        // Has a file been selected?
        if (!empty($selectfile)) {
            // Has a local file name been specified to import from?
            $localfile = optional_param('sloodleimportfile', '', PARAM_CLEAN);
            if (!empty($localfile)) return $this->import_file($presenter, $localfile, $importname, $position);
        }

        // Has a file been uploaded?
        if (!empty($uploadfile)) {
            // Has an upload been made which we can import from?
            $localfile = ''; $clientfile = '';
            $res = $this->process_upload($localfile, $clientfile);
            if ($res === true) {
                sloodle_debug("Upload successful<br/>\n");
                return $this->import_file($presenter, $localfile, $importname, $position, $clientfile);
            }
            if (is_string($res)) error($res, $url.'&amp;mode=edit');
        }

        // No file specified - display forms to let the user select or upload the file.

        // Determine our maximum upload size
        $maxsize = sloodle_get_max_post_upload();
        $maxsizedesc = sloodle_get_size_description($maxsize);

        // Open the form
        echo '<form action="" method="post" enctype="multipart/form-data"><fieldset style="border-style:none;">';
        echo '<input type="hidden" name="id" id="id" value="'.$presenter->cm->id.'" />';
        echo '<input type="hidden" name="mode" id="mode" value="importslides" />';
        echo '<input type="hidden" name="sloodleplugintype" id="sloodleplugintype" value="'.$this->sloodle_get_plugin_id().'" />';
        echo '</fieldset><br/>';

        // Let the user specify a name for the imported files
        echo '<label for="importname" title="'.$strimportnamecaption.'">'.$strimportname.': </label>';
        echo '<input type="text" name="importname" id="importname" value="" size="30" maxlength="100" title="'.$strimportnamecaption.'" />';
        echo "<br/><br/>\n";
        // Let the user select the position to upload to in the Presentation
        $this->print_slide_position_menu($presenter, $position);
        echo "<br/><br/>\n";

        // Display our upload form
        echo '<fieldset style="width:50%; margin-left:auto; margin-right:auto;">';
        echo '<h3>'.$strimportfromcomputer."</h3>\n";
        echo '<input type="hidden" name="MAX_FILE_SIZE" value="'.$maxsize.'" />';
        echo '<label for="userfile">'.$strselectuploadfile.': </label>';
        echo '<input type="file" name="userfile" id="userfile" size="50" />';
        echo '<p style="font-style:italic; font-size:90%;">['.get_string('upload:maxsize', 'sloodle', $maxsizedesc)."]</p><br/>\n";
        echo '<input type="submit" name="uploadfile" id="uploadfile" value="'.$struploadfile.'" /><br/>'."\n";
        echo '</fieldset><br/>';

        // TODO: add a separate section allowing the import of a file elsewhere on the web

        // TODO: add a separate section allowing the import of a file already in the course/site files

        // Close the form
        echo "</fieldset></form><br/>\n";

    }

    /**
    * Display a drop-down menu of slides in the current presentation.
    * @param SloodleModulePresenter $presenter An object representing the Presenter to work from.
    * @param integer $position Specifies the intially selected position, if known. Defaults to end.
    */
    function print_slide_position_menu($presenter, $position = -1)
    {
        // Get translation strings
        $strimportposition = get_string('presenter:importposition', 'sloodle');
        $strimportpositioncaption = get_string('presenter:importpositioncaption', 'sloodle');

        // Get a list of slides
        $slides = $presenter->get_slides();
        // Display the form element
        echo '<label for="sloodleentryposition" title="'.$strimportpositioncaption.'">'.$strimportposition.': </label>';
        echo '<select name="sloodleentryposition" id="sloodleentryposition" size="1" title="'.$strimportpositioncaption.'">'."\n";
        $selected = false;
        foreach ($slides as $curslide) {
            // Add this slide to the menu
            echo "<option value=\"{$curslide->slideposition}\"";
            if ($curslide->slideposition == $position) {
                echo ' selected="selected"';
                $selected = true;
            }
            echo ">{$curslide->slideposition}: {$curslide->name}</option>\n";
        }
        // Add an 'end' option
        if (!empty($curslide)) $endentrynum = $curslide->slideposition + 1;
		else $endentrynum = 1;
        echo "<option value=\"{$endentrynum}\"";
        if (!$selected) echo " selected=\"selected\"";
        echo ">--".get_string('end', 'sloodle')."--</option>\n";
        echo "</select>\n";
    }


    /**
    * Attempt to process a file upload.
    * @param string $path [out] This reference parameter will contain the path of the uploaded file if an upload has been performed. It will be empty if no upload has occurred.
    * @param string $name [out] This reference parameter will contain the original name of the uploaded file if an upload has been performed.
    * @return bool|string Returns true if an upload occurred succesfully. Returns false if no upload has happened. Returns a string containing an error message if an error occurred.
    */
    function process_upload(&$path, &$name)
    {
        // If no file has been uploaded, then there is nothing to do
        if (empty($_FILES['userfile']['name'])) return false;

        // Is the file empty?
        if ((int)$_FILES['userfile']['size'] == 0) return get_string('upload:emptyfile', 'sloodle');

        // Was an error code specified?
        if (isset($_FILES['userfile']['error'])) {
            switch ($_FILES['userfile']['error']) {
                case UPLOAD_ERR_INI_SIZE: case UPLOAD_ERR_FORM_SIZE: return get_string('upload:toobig', 'sloodle');
                case UPLOAD_ERR_PARTIAL: return get_string('upload:partial', 'sloodle');
            }
            if ($_FILES['userfile']['error'] != UPLOAD_ERR_OK) return get_string('upload:error', 'sloodle');
        }
        
        // Store the file path and name
        $name = $_FILES['userfile']['name'];
        $path = $_FILES['userfile']['tmp_name'];
        return true;
    }


    /**
    * Import a file to this Presenter.
    * @param SloodleModulePresenter $presenter An object representing the Presenter we are importing into.
    * @param string $path The path of the file to import (must be local... i.e. on disk!)
    * @param string $name Optional -- a name for the import. If omitted, it will be taken from the clientpath or path.
    * @param integer $position The position at which the slides should be imported. Optional. Defaults to import at the end.
    * @param string $clientpath (Optional) Specifies the original client path from which a file name can be extrapolated.
    * @return bool True if successful or false if not.
    */
    function import_file($presenter, $path, $name = '', $position = -1, $clientpath = '')
    {
        global $CFG;

	$cmid = $presenter->cm->id;
	// In Moodle 2, we make an itemid for the file api
	$itemid = time();
        
        if (!file_exists($path)) error("Import file doesn't exist.");

        // Start by running a compatibility check -- this just makes sure the extensions are loaded.
        $this->check_compatibility();

        // PHP 4 doesn't support recursive creation of folders, so we need to do this the manual way

	// For Moodle 2, we upload to a temporary directory, then use the file api to move to the relevant place.
        $dir_sitefiles = SLOODLE_IS_ENVIRONMENT_MOODLE_2 ? $CFG->dataroot.'/temp/sloodle' : $CFG->dataroot.'/'.SITEID;
        //$dir_sitefiles = $CFG->dataroot.'/'.SITEID;
        $dir_presenter = $dir_sitefiles.'/presenter';
        $dir_import = $dir_presenter.'/'.$presenter->cm->id;
        if (!file_exists($dir_sitefiles)) mkdir($dir_sitefiles);
        if (!file_exists($dir_presenter)) mkdir($dir_presenter);
        if (!file_exists($dir_import)) mkdir($dir_import);
        // Now check on last time that the import folder exists
        if (!file_exists($dir_import)) {
            error("Failed to create directory for imported images. Please check the file permissions for your MoodleData folder.<br/><br/>Attempted to create: {$dir_import}");
        }

        // Construct the URL of the folder for viewing the files
        $dir_view = $CFG->wwwroot;
	if (SLOODLE_IS_ENVIRONMENT_MOODLE_2) {
		$dir_view .= '/pluginfile.php/'.intval($cmid).'/mod_sloodle/presenter/'.intval($itemid);
	} else {
		$dir_view .= '/file.php/'.SITEID.'/presenter/'.$presenter->cm->id;
	}

	// In Moodle 2, make a file path, as distinct to the temporary file saving location
	$fileapipath = '';
	if (SLOODLE_IS_ENVIRONMENT_MOODLE_2) {
		$fileapipath = '/'.intval($cmid).'/mod_sloodle/presenter/'.intval($itemid).'/';
	} 

        // Use the file name from the path if necessary
        if (empty($name)) {
            if (!empty($clientpath)) $name = basename($clientpath, '.pdf');
            else $name = basename($path);
        }
        // Construct a basic identifier for the files which will be imported.
        // It will consist of a timestamp and the import name
        $filebase = gmdate('U').'_'.str_replace(" ", "_", $name);

        // We'll use JPG files as standard just now. We could make this customizable in future?
        $ext = 'jpg';

        // Attempt each importing method in turn
        $result = $this->_import_MagickWand($presenter, $path, $dir_import, $dir_view, $filebase, $ext, $name, $position, $itemid, $cmid, $fileapipath);
        if ($result === false) $result = $this->_import_ImageMagick($presenter, $path, $dir_import, $dir_view, $filebase, $ext, $name, $position, $itemid, $cmid, $fileapipath);

        // Prepare a "Continue" link which takes us to edit mode
        $continueURL = $CFG->wwwroot."/mod/sloodle/view.php?id={$presenter->cm->id}&amp;mode=edit";

        // Display the results (in future, it might be good to show a list of slides, and let the user rename or delete them before addition to the presentation)
        if ($result === false) {
            echo "<h3>",get_string('presenter:importfailed', 'sloodle'),"</h3>\n";
            echo "<h4>",get_string('presenter:importneedimagick', 'sloodle'),"</h4>\n";
			$strcontinue = get_string('continue');
			echo "<p style=\"text-align:center;\">( <a href=\"{$continueURL}\">{$strcontinue}</a> )</p>";
            return false;
        }
        echo "<h3>",get_string('presenter:importsuccessful', 'sloodle', $result),"</h3>\n";
        redirect($continueURL, '', 5);
        return true;
    }
    

    /**
    * Imports the given file using the MagickWand extension if possible. (Internal only)
    * @param SloodleModulePresenter $presenter An object representing the Presenter we are importing into.
    * @param string $srcfile Full path of the PDF file we are importing
    * @param string $destpath Folder path to which the imported files will be added.
    * @param string $viewurl URL of the folder in which the imported files will be viewed
    * @param string $destfile Name for the output files (excluding extension, such as .jpg). The page numbers will be appended automatically, before the extension
    * @param string $destfileext Extension for destination files, not including the dot. (e.g. "jpg" or "png").
    * @param string $destname Basic name to use for each imported slide. The page numbers will be appended automatically.
    * @param integer $position The position within the Presentation to add the new slides. Optional. Default is to put them at the end.
    * @return integer|bool If successful, an integer indicating the number of slides loaded is displayed. If the import does not (or cannot) work, then boolean false is returned.
    * @access private
    */
    function _import_MagickWand($presenter, $srcfile, $destpath, $viewurl, $destfile, $destfileext, $destname, $position = -1, $itemid = '', $cmid = '', $fileapipath = '')
    {
        global $CFG;
        // Only continue if the MagickWand extension is loaded (this is done by the check_compatibility function)
        if (!extension_loaded('magickwand')) return false;
        
        // Load the PDF file
        sloodle_debug('Loading PDF file... ');
        $mwand = NewMagickWand();
        if (!MagickReadImage($mwand, $srcfile)) {
            sloodle_debug('failed.<br/>');
            return false;
        }
        sloodle_debug('OK.<br/>');
        
        // Quick validation - position should start at 1. (-ve numbers mean "at the end")
        if ($position == 0) $position = 1;

        // Go through each page
        sloodle_debug('Preparing to iterate through pages of document...<br/>');
        MagickSetFirstIterator($mwand);
        $pagenum = 0; $page_position = -1;
        do {
            // Determine this page's position in the Presentation
            if ($position > 0) $page_position = $position + $pagenum;
            $pagenum++;

            // Construct the file and slide names for this page
            $page_filename = "{$destpath}/{$destfile}-{$pagenum}.{$destfileext}"; // Where it gets uploaded to
            $page_slidesource = "{$viewurl}/{$destfile}-{$pagenum}.{$destfileext}"; // The URL to access it publicly
            $page_slidename = "{$destname} ({$pagenum})";

            // Output the file
            sloodle_debug(" Writing page {$pagenum} to file...");
            if (!MagickWriteImage($mwand, $page_filename)) {
                sloodle_debug('failed.<br/>');
            } else {
                sloodle_debug('OK.<br/>');
            }

            if (SLOODLE_IS_ENVIRONMENT_MOODLE_2) {
                $registered = $this->_register_moodle_api_file( $page_filename, $itemid, $cmid, $fileapipath, "{$destfile}-{$pagenum}.{$destfileext}");
                @unlink($page_filename);
                if (!$registered) {
                     return false;
                }
           }



    // Add the entry to the Presenter
            sloodle_debug("  Adding slide \"{$page_slidename}\" to presentation at position {$page_position}... ");
            if (!$presenter->add_entry($page_slidesource, 'image', $page_slidename, $page_position)) {
                sloodle_debug('failed.<br/>');
            } else {
                sloodle_debug('OK.<br/>');
            }
            
        } while (MagickNextImage($mwand));
        sloodle_debug('Finished.<br/>');
        DestroyMagickWand($mwand);
        return $pagenum;
    }


    /**
    * Imports the given file using the ImageMagick command line programs if possible. (Internal only)
    * @param SloodleModulePresenter $presenter An object representing the Presenter we are importing into.
    * @param string $srcfile Full path of the PDF file we are importing
    * @param string $destpath Folder path to which the imported files will be added.
    * @param string $viewurl URl of the folder in which the files can be viewed
    * @param string $destfile Name for the output files (excluding extension, such as .jpg). The page numbers will be appended automatically, before the extension
    * @param string $destfileext Extension for destination files, not including the dot. (e.g. "jpg" or "png").
    * @param string $destname Basic name to use for each imported slide. The page numbers will be appended automatically.
    * @param integer $position The position within the Presentation to add the new slides. Optional. Default is to put them at the end.
    * @param string $itemid The item id - used to make a unique directory name to avoid naming clashes.
    * @return integer|bool If successful, an integer indicating the number of slides loaded is displayed. If the import does not (or cannot) work, then boolean false is returned.
    * @access private
    */
    function _import_ImageMagick($presenter, $srcfile, $destpath, $viewurl, $destfile, $destfileext, $destname, $position = -1, $itemid = '', $cmid = '', $fileapipath = '')
    {
        global $IMAGICK_CONVERT_PATH;

        // Do a security check -- has command-line execution of IMagick been disabled by the admin?
        sloodle_debug("<br/><strong>Attempting to use ImageMagick by command-line.</strong><br/>");
        if (empty($IMAGICK_CONVERT_PATH)) {
            sloodle_debug(" ERROR: path to ImageMagick \'convert\' program is blank.");
            return false;
        }
        // Now make sure there are no quotation marks in the source/destination file and path names
        //  (these could be used to execute malicious commands on the server)
        if (strpos($srcfile, "\"") !== false || strpos($destpath, "\"") !== false || strpos($destfile, "\"") !== false || strpos($destfileext, "\"") != false) error("Invalid file name -- please remove quotation marks from file names.");

        // Construct the conversion command
		$srcfile_shell_clean = escapeshellarg($srcfile);
		$destpath_shell_clean = escapeshellarg($destpath.'/'.$destfile.'-');
		$destfileext_shell_clean = escapeshellarg('.'.$destfileext);
		//$cmd = "\"{$IMAGICK_CONVERT_PATH}\" -verbose \"{$srcfile_shell_clean}\" \"{$destpath_shell_clean}/{$destfile_shell_clean}-%d.{$destfileext_shell_clean}\"";
		$cmd = "{$IMAGICK_CONVERT_PATH} -verbose {$srcfile_shell_clean} {$destpath_shell_clean}%d{$destfileext_shell_clean}";
		if (substr(php_uname(), 0, 7) == "Windows") $cmd = 'start /B "" '.$cmd; // Windows compatibility
		
		sloodle_debug(" Executing shell command: {$cmd}<br/>");
		$output = array();
        $result = @exec($cmd, $output);
        // If all the output is empty, then execution failed
        if (empty($result) && empty($output)) {
            sloodle_debug(" ERROR: execution of the shell command failed.<br/>");
            //echo "<hr><pre>"; print_r($output); echo "</pre><hr>";
            return false;
        }
        
        // Quick validation - position should start at 1. (-ve numbers mean "at the end")
        if ($position == 0) $position = 1;

        // Go through each page which was created.
        // Stop when we encounter a file which wasn't created -- that will be the end of the document.
        $pagenum = 0; $page_position = -1;
        $stop = false;
        while ($stop == false && $pagenum < 10000) {
            // Determine this page's position in the Presentation
            if ($position > 0) $page_position = $position + $pagenum;

            // Construct the file and slide names for this page
            $page_filename = "{$destpath}/{$destfile}-{$pagenum}.{$destfileext}"; // Where it gets uploaded to
            $page_slidesource = "{$viewurl}/{$destfile}-{$pagenum}.{$destfileext}"; // The URL to access it publicly
            $page_slidename = "{$destname} (".($pagenum + 1).")";
            // Was this file created?
            if (file_exists($page_filename)) {

		if (SLOODLE_IS_ENVIRONMENT_MOODLE_2) {
			$registered = $this->_register_moodle_api_file( $page_filename, $itemid, $cmid, $fileapipath, "{$destfile}-{$pagenum}.{$destfileext}"); 
			@unlink($page_filename);
			if (!$registered) {
				return false;	
			}
		}

                // Add it to the Presenter
                $presenter->add_entry($page_slidesource, 'image', $page_slidename, $page_position);
                $pagenum++;
            } else {
                $stop = true;
            }
        }

        return $pagenum;
    }
    
    function _register_moodle_api_file( $tempfile, $itemid, $cmid, $fileapipath, $filename ) {

        $fs = get_file_storage();

        $fileinfo = array(
            'contextid' => $cmid, // ID of context
            'component' => 'mod_sloodle',     // usually = table name
            'filearea' => 'presenter',     // usually = table name
            'itemid' => $itemid,               // usually = ID of row in table
            'filepath' => $fileapipath,
            'filename' => $filename
        );

        $fs->create_file_from_pathname( $fileinfo, $tempfile);

	return true;

    }


    /**
    * Gets the human-readable name of this plugin.
    * @param string $lang Optional -- can specify the language we want the plugin name in, as an identifier like "en_utf8". If unspecified, then the current Moodle language should be used.
    * @access public
    * @return string The human-readable name of this plugin 
    */
    function get_plugin_name($lang = null)
    {
        return 'PDF Importer';
    }

    /**
    * Gets the human-readable description of this plugin.
    */
    function get_plugin_description($lang = null)
    {
        return 'Imports an Adbobe Acrobat (PDF) file into your Presentation. Each page becomes a single image slide.';
    }

    /**
    * Gets the internal version number of this plugin.
    * This should be a number like the internal version number for Moodle modules, containing the date and release number.
    * Format is: YYYYMMDD##.
    * For example, "2009012302" would be the 3rd release on the 23rd January 2009.
    * @return int The version number of this module.
    */
    function get_version()
    {
        return 2010020400;
    }

    /**
    * Checks the compatibility of this plugin with the current installation.
    * Override this for any plugin which has non-standard requirements, such as relying on particular PHP extensions.
    * Note that the default (base class) implementation of this function returns true.
    * @todo It would be useful if this function performed the auto-detection of the ImageMagick 'convert' program whether MagickWand is available or not.
    * @return bool True if plugin is compatible, or false if not.
    */
    function check_compatibility()
    {
        global $IMAGICK_CONVERT_PATH;

        $this->compatibility_summary = '';
        // Check to see if the MagickWand extension is already loaded..
        if (extension_loaded('magickwand'))
        {
            $this->compatibility_summary .= get_string('presenter:usingmagickwand', 'sloodle');
            return true;
        }
        // Attempt to load the extension, depending on OS.
        if ( (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') && function_exists('dl')) @dl('php_magickwand.dll');
        else if (function_exists('dl')) @dl('magickwand.so');
        // Check if MagickWand has been successfully loaded now.
        if (extension_loaded('magickwand'))
        {
            $this->compatibility_summary .= get_string('presenter:usingmagickwand', 'sloodle');
            return true;
        }
        
        $this->compatibility_summary .= get_string('presenter:magickwandnotinstalled', 'sloodle').' ';

        // Only do this if the use of ImageMagick via shell commands has not been disabled
        if (!empty($IMAGICK_CONVERT_PATH)) {
            // Build a list of locations to check for the ImageMagick program
            $checkLocs = array();
            $checkLocs[] = $IMAGICK_CONVERT_PATH;
            $checkLocs[] = '/usr/bin/convert';
            $checkLocs[] = '/usr/local/bin/convert';
		// Edmund Edgar, 2011-10-30:
		// Disabling this - I'm not happy with the security implications of trusting any file called "convert" or "convert.exe" in the web user's path.
		// Uncomment if you're really sure you want to do this.
		//	$checkLocs[] = 'convert';
		//	$checkLocs[] = 'convert.exe';
            
            // Check for the presence of the ImageMagick convert program at each location
            foreach ($checkLocs as $loc) {
                // Make sure it's a safe command
                $cmd = $loc.' -version';
                // Attempt to execute it
                $output = array();
                @exec($cmd, $output);

                // Do we have any output? And does it look like ImageMagick output?
                if (!empty($output) && strpos($output[0], 'ImageMagick') !== false) {
                    // Store this path
                    $this->compatibility_summary .= get_string('presenter:usingexecutable', 'sloodle');
                    if ($loc != $IMAGICK_CONVERT_PATH) $IMAGICK_CONVERT_PATH = $loc;
                    return true;
                }
            }
            $this->compatibility_summary .= get_string('presenter:convertnotfound', 'sloodle');
        } else {
            $this->compatibility_summary .= get_string('presenter:convertdisabled', 'sloodle');
        }

        return false;
    }
    
    /**
    * After check_compatibility() has been called, this function will return a string summarising the compatibility of the plugin.
    * For example, it may explain that a particular extension is being used, or that it could not be loaded.
    * @return string A summary of the compatibility of the plugin.
    */
    function get_compatibility_summary()
    {
        return $this->compatibility_summary;
    }
    
    /**
    * Run a full compatibility test and output the results to the webpage.
    * @return bool True if plugin is compatible, or false otherwise.
    */
    function run_compatibility_test()
    {    
        global $IMAGICK_CONVERT_PATH;
        
        // Check to see if the MagickWand extension is already loaded
        echo "<h3>MagickWand</h3>\n";
        echo "Checking to see if MagickWand extension is loaded.<br/>";
        if (extension_loaded('magickwand'))
        {
            echo "Success. MagickWand extension was already loaded.<br/>";
            return true;
        }
        echo "MagickWand extension not already loaded.<br/>";
        
        // Attempt to load the extension, depending on OS.
        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN')
        {
            echo "Windows OS detected. Attempting to load 'php_magickwand.dll' extension dynamically.<br/>";
	    if(function_exists('dl')) {
                @dl('php_magickwand.dll');
	    }
        } else {
            echo "Attempting to load 'php_magickwand.so' extension dynamically.<br/>";
	    if(function_exists('dl')) {
                @dl('magickwand.so');
	    }
        }
        // Check if MagickWand has been successfully loaded now.
        if (extension_loaded('magickwand'))
        {
            echo "Success. MagickWand extension can be loaded dynamically.<br/>";
            return true;
        }
        echo "MagickWand extension could not be loaded. This plugin will attempt to use ImageMagick directly.<br/>";
        echo "<h3>ImageMagick</h3>\n";

        // Only do this if the use of ImageMagick via shell commands has not been disabled
        if (!empty($IMAGICK_CONVERT_PATH)) {
            echo "Attempting to auto-detect location of the ImageMagick 'convert' program.<br/>";
        
            // Build a list of locations to check for the ImageMagick program
            $checkLocs = array();
            $checkLocs[] = $IMAGICK_CONVERT_PATH;
            $checkLocs[] = '/usr/bin/convert';
            $checkLocs[] = '/usr/local/bin/convert';
	    // Edmund Edgar, 2011-10-30:
		// Disabling this - I'm not happy with the security implications of trusting any file called "convert" or "convert.exe" in the web user's path.
		// Uncomment if you're really sure you want to do this.
		// $checkLocs[] = 'convert';
		// $checkLocs[] = 'convert.exe';
            
            // Check for the presence of the ImageMagick convert program at each location
            foreach ($checkLocs as $loc) {
                echo "<br/>Checking for program at location: \"{$loc}\"...<br/>";
            
                // Make sure it's a safe command
                $cmd = $loc.' -version';
                // Attempt to execute it
                $output = array();
                @exec($cmd, $output);
                                
                if (empty($output)) {
                    echo " - path is not executable.<br/>";
                } else if (strpos($output[0], 'ImageMagick') === false) {
                    echo " - executable does not appear to belong to Imagemagick.<br>";
                } else {
                    echo "- success. This appears to be the ImageMagick 'convert' program.<br/>";
                    return true;
                }
            }
            echo "<br/>Unable to locate the ImageMagick 'convert' program.<br/>";
            return false;
        }
        
        echo "The use of ImageMagick by shell execution has been disabled.<br/>";
        return false;
    }

}


?>

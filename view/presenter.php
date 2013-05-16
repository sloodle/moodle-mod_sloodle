<?php
/**
* Defines a class for viewing the SLOODLE Presenter module in Moodle.
* Derived from the module view base class.
*
* @package sloodle
* @copyright Copyright (c) 2008-9 Sloodle (various contributors)
* @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
*
* @contributor Peter R. Bloomfield
* @contributor Paul Preibisch
*/


//
// The mode of operation is defined by the "mode" HTTP parameter.
// The available modes are as follows:
//
//  - view = viewing the Presentation (default)
//  - edit = editing the Presentation
//  - editslide = editing a particular slide
//  - addslide = adding a new slide
//  - addfiles = uploading multiple slides
//  - moveslide = moving a slide (part of 'edit' mode)
//  - deleteslide = deleting a particular slide (user has confirmed) (part of 'edit' mode)
//  - confirmdeleteslide = asking user to confirm that they want to delete a slide (part of 'edit' mode)
//  - deletemultiple = deleting multiple slides (user has confirmed) (part of 'edit' mode)
//  - confirmdeletemultiple = asking user to confirm that they want to delete multiple slides (part of 'edit' mode)
//  - importslides = add new slides using an importer plugin
//  - compatibility = run a full compatibility check of a specified plugin
//


/** The base module view class */
require_once(SLOODLE_DIRROOT.'/view/base/base_view_module.php');
/** The SLOODLE Session data structures */
require_once(SLOODLE_LIBROOT.'/sloodle_session.php');

/** ID of the 'view' tab for the Presenter. */
define('SLOODLE_PRESENTER_TAB_VIEW', 1);
/** ID of the 'edit' tab for the Presenter */
define('SLOODLE_PRESENTER_TAB_EDIT', 2);
/** ID of the 'edit slide' tab for the Presenter */
define('SLOODLE_PRESENTER_TAB_EDIT_SLIDE', 3);
/** ID of the 'add slide' tab for the Presenter */
define('SLOODLE_PRESENTER_TAB_ADD_SLIDE', 4);
/** ID of the 'bulk upload' tab for the Presenter */
define('SLOODLE_PRESENTER_TAB_ADD_FILES', 5);
/** ID of the 'import slides' tab for the Presenter */
define('SLOODLE_PRESENTER_TAB_IMPORT_SLIDES', 6);



/**
* Class for rendering a view of a Presenter module in Moodle.
* @package sloodle
*/
class sloodle_view_presenter extends sloodle_base_view_module
{
    /**
    * A Presenter object (secondary table).
    * @var object
    * @access private
    */
    var $presenter = null;
   
    /**
    * Our current mode of access to the Presenter.
    * This can be 'view', 'edit', 'editslide', 'bulkupload', 'upload'.
    * NOTE: 'edit' mode is for the presentation as a whole (slide order), while 'editslide' shows the slide editing form.
    * @var string
    * @access private
    */
    var $presenter_mode = 'view';
    
    /**
    * ID of the entry we are moving.
    * @var int
    * @access private
    */
    var $movingentryid = 0;

    /**
    * A SLOODLE session object to give us access to plugins and other functionality.
    * @var SloodleSession
    * @access private
    */
    var $_session = null;
    
    /**
    * Stores an optional feedback string which we may pick up from session data.
    * @var string
    * @access private
    */
    var $feedback = '';

    /**
    * Constructor.
    */
    function sloodle_view_presenter()
    {
    }

    /**
    * Processes request data to determine which Presenter is being accessed.
    */
    function process_request()
    {
        // Process the basic data
        parent::process_request();

        // Grab any feedback left from a previous action
        if (!empty($_SESSION['sloodle_presenter_feedback'])) $this->feedback = $_SESSION['sloodle_presenter_feedback'];
        unset($_SESSION['sloodle_presenter_feedback']);

        // Construct a SLOODLE Session and load a module
        $this->_session = new SloodleSession(false);
        $this->presenter = new SloodleModulePresenter($this->_session);
        if (!$this->presenter->load($this->cm->id)) return false;
        $this->_session->module = $this->presenter;

        // Load available Presenter plugins
        if (!$this->_session->plugins->load_plugins('presenter')) {
            error('Failed to load Presenter plugins.');
            return false;
        }
    }
    
    /**
    * Process any form data which has been submitted.
    */
    function process_form()
    {
        global $CFG;
              
        // Slight hack to put this here. We need to have the permissions checked before we do this.
        // Default to view mode. Only allow other types if the user has sufficient permission
        if ($this->canedit) {
            $this->presenter_mode = optional_param('mode', 'view', PARAM_TEXT);
        } else {
            $this->presenter_mode = 'view';
        }
        // If we're in moving mode, then grab the entry ID
        if ($this->presenter_mode == 'moveslide') $this->movingentryid = (int)optional_param('entry', 0);

        // Make sure Moodle includes our JavaScript files if necessary
        if ($this->presenter_mode == 'edit' || $this->presenter_mode == 'addfiles') {
            sloodle_require_js($CFG->wwwroot .'/mod/sloodle/lib/jquery/jquery.js');
            sloodle_require_js($CFG->wwwroot .'/mod/sloodle/lib/jquery/jquery.uploadify.js');
            sloodle_require_js($CFG->wwwroot .'/mod/sloodle/lib/jquery/jquery.checkboxes.js');
            sloodle_require_js($CFG->wwwroot .'/mod/sloodle/lib/multiplefileupload/extra.js');
            sloodle_require_js($CFG->wwwroot .'/lib/filelib.php');      
        }
        if ( $this->presenter_mode == 'addfiles') {
            sloodle_require_js($CFG->wwwroot .'/mod/sloodle/lib/js/presenter_addfiles.js"');      
	}


        // Should we process any incoming editing commands?
        if ($this->canedit) {

            // We may want to redirect afterwards to prevent an argument showing up in the address bar
            $redirect = false;
        
            // Are we deleting a single slide?
            if ($this->presenter_mode == 'deleteslide') {
                // Make sure the session key is specified and valid
                if (required_param('sesskey') != sesskey()) {
                    error('Invalid session key');
                    exit();
                }
                
                // Determine what slide is to be deleted
                $entryid = (int)required_param('entry', PARAM_INT);
                
                // Get the requested slide from the presentation
                $entry = $this->presenter->get_slide($entryid);
                if ($entry) {
                    // Delete the slide
                    $this->presenter->delete_entry($entryid);
                    // Set our feedback information, so the user knows it has been successful
                    $_SESSION['sloodle_presenter_feedback'] = get_string('presenter:deletedslide', 'sloodle', $entry->name);
                } else {
                    // Set our feedback information, so the user knows it has not been successful;
                    $_SESSION['sloodle_presenter_feedback'] = get_string('presenter:deletedslides', 'sloodle', 0);
                }
                
                // Redirect back to the edit tab to get rid of our messy request parameters (and to prevent accidental repeat of the operation)
                $redirect = true;
            }
            
            // Are we deleting multiple slides?
            if ($this->presenter_mode == 'deletemultiple') {
                // Make sure the session key is specified and valid
                if (required_param('sesskey') != sesskey()) {
                    error('Invalid session key');
                    exit();
                }
                
                // Fetch the IDs of the slides which are being deleted
                if (isset($_REQUEST['entriesstr'])) $entryids = explode(',',$_REQUEST['entriesstr']);
                else error("Expected HTTP parameter 'entries' not found.");

                // Go through the given entry IDs and attempt to delete them
                $numdeleted = 0;
                foreach ($entryids as $entryid) {
                    if ($this->presenter->delete_entry($entryid)) $numdeleted++;
                }
                // Set our feedback information so the user knows whether or not this was successful
                $_SESSION['sloodle_presenter_feedback'] = get_string('presenter:deletedslides', 'sloodle', $numdeleted);
                
                // Redirect back to the edit tab to get rid of our messy request parameters (and to prevent accidental repeat of the operation)
                $redirect = true;
            }
            
            // Are we relocating an entry?
            if ($this->presenter_mode == 'setslideposition') {
                $entryid = (int)required_param('entry', PARAM_INT);
                $position = (int)required_param('position', PARAM_INT);
                $this->presenter->relocate_entry($entryid, $position);
                $redirect = true;
            }
            
            
            
            // Has a new entry been added?
            if (isset($_REQUEST['fileaddentry']) ||isset($_REQUEST['sloodleaddentry'])) {
                if (isset($_REQUEST['fileaddentry'])) { 
                    $urls = $_REQUEST['fileurl'];                    
                    $names =  $_REQUEST['filename']; 
                    $i = 0;                   
                    foreach ($urls as $u) {    
                        $fnamelen= strlen($u);
                        $extension= substr($u,$fnamelen-4); 
                        $ftype = strtolower($extension);
                        switch ($ftype){
                            case ".mov": $ftype = "video"; break;
                            case ".mp4": $ftype = "video"; break;
                            case ".jpg": $ftype = "image"; break;
                            case ".png": $ftype = "image"; break;
                            case ".gif": $ftype = "image"; break;
                            case ".bmp": $ftype = "image"; break;
                            case ".htm": $ftype = "web";   break;
                            case "html": $ftype = "web";   break;                              
                        }
                        $this->presenter->add_entry(sloodle_clean_for_db($u), $ftype, sloodle_clean_for_db($names[$i++]));        
                    }
                        
                    $redirect = true;
                }
               
                if (isset($_REQUEST['sloodleaddentry'])) {
                    if ($_REQUEST['sloodleentryurl']!='') {
                        $sloodleentryurl = sloodle_clean_for_db($_REQUEST['sloodleentryurl']);
                        $sloodleentrytype = sloodle_clean_for_db($_REQUEST['sloodleentrytype']);
                        $sloodleentryname = sloodle_clean_for_db($_REQUEST['sloodleentryname']);
                        $sloodleentryposition = (int)$_REQUEST['sloodleentryposition'];
                        // Store the type in session data for next time we're adding a slide
                        $_SESSION['sloodle_presenter_add_type'] = $sloodleentrytype;
                        $this->presenter->add_entry($sloodleentryurl, $sloodleentrytype, $sloodleentryname, $sloodleentryposition);
                    }
                } 
                
                $redirect = true; 
            }
            
            
            // Has an existing entry been edited?
            if (isset($_REQUEST['sloodleeditentry'])) {
                $sloodleentryid = (int)$_REQUEST['sloodleentryid'];
                $sloodleentryurl = sloodle_clean_for_db($_REQUEST['sloodleentryurl']);
                $sloodleentrytype = sloodle_clean_for_db($_REQUEST['sloodleentrytype']);
                $sloodleentryname = sloodle_clean_for_db($_REQUEST['sloodleentryname']);
                $sloodleentryposition = (int)$_REQUEST['sloodleentryposition'];

                $this->presenter->edit_entry($sloodleentryid, $sloodleentryurl, $sloodleentrytype, $sloodleentryname, $sloodleentryposition);
                $redirect = true;
            }
            
            // Redirect back to the edit page -- this is used to get rid of intermediate parameters.
            if ($redirect && headers_sent() == false) {
                header("Location: ".SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&mode=edit");
                exit();
            }
        }
    }
    
    
    /**
    * Render the View of the Presenter.
    * Called from with the {@link render()} function when necessary.
    */
    function render_view()
    {        
        
        //display any feedback
        if (!empty($this->feedback)) echo $this->feedback;
        
          // Get a list of entry slides in this presenter
        $entries = $this->presenter->get_slides();
        if (!is_array($entries)) $entries = array();
        $numentries = count($entries);
        // Open the presentation box
        //print_box_start('generalbox boxaligncenter boxwidthwide');

        // Was a specific entry requested? This is the number of entry within the presentation, NOT entry ID.
        // They start at 1 and go up from there within each presentation.
        if (isset($_REQUEST['sloodledisplayentry'])) {
            $displayentrynum = (int)$_REQUEST['sloodledisplayentry'];
            if ($displayentrynum < 1 || $displayentrynum > $numentries) $displayentrynum = 1;
        } else {
            $displayentrynum = 1;
        }
        
        // Do we have any entries to work with?
        if ($numentries > 0) {
            // Yes - go through them to figure out which entry to display
            $currententry = null;
            foreach ($entries as $entryid => $entry) {
                // Check if this is our current entry
                if ($displayentrynum == $entry->slideposition) {                  
                    $currententry = $entry;
                }
            }
    
            // Display the entry header
            echo "<div style=\"text-align:center;\">";
            echo "<h2 id=\"slide\">\"<a href=\"{$currententry->source}\" title=\"".get_string('directlink', 'sloodle')."\">{$currententry->name}</a>\"</h2>\n";

            // Display the presentation controls
            $strof = get_string('of', 'sloodle');
            $strviewprev = get_string('viewprev', 'sloodle');
            $strviewnext = get_string('viewnext', 'sloodle');
            $strviewjumpforward = get_string('jumpforward', 'sloodle');
            $strviewjumpback = get_string('jumpback', 'sloodle');
            echo '<p style="font-size:200%; font-weight:bold;">';
           // if ($displayentrynum > 1) echo "<a href=\"?id={$this->cm->id}&sloodledisplayentry=",$displayentrynum - 1,"#slide\" title=\"{$strviewprev}\">&larr;</a>";
           // else echo "<span style=\"color:#bbbbbb;\">&larr;</span>";
           // echo "&nbsp;{$displayentrynum} {$strof} {$numentries}&nbsp;";
           //  if ($displayentrynum < $numentries) echo "<a href=\"?id={$this->cm->id}&sloodledisplayentry=",$displayentrynum + 1,"#slide\" title=\"{$strviewnext}\">&rarr;</a>";

            //else echo "<span style=\"color:#bbbbbb;\">&rarr;</span>";            
            echo "</p>\n";

 
            global $OUTPUT;

            echo '<div style="text-align:center;" >';
            echo '<table border="0" width="100%"><tr><td align="center">';
            
            $entrynumcounter=1;            
            $jumpNumber=5;
            //display >>
            $arrowLinks = new stdClass();       
            $arrowLinks->class='texrender';     
            $arrowLinks->size = array('40px', '40px','40px','40px','40px');
            $arrowLinks->cellpadding='1';
            $arrowLinks->width='500px';
            
            $slideLinks= new stdClass();
            $slideLinks->class='texrender';     
            $slideLinks->size = array('20px', '20px','20px','20px','20px','20px','20px');
            $slideLinks->cellpadding='1';
            $row = array(); 
            $arow = array(); 
            
            $start = $displayentrynum - $jumpNumber-1;
            if ($start>=0) $arow[]= "<a href=\"?id={$this->cm->id}&sloodledisplayentry={$start}#slide\" title=\"{$strviewjumpback} ".$jumpNumber." slides\"><img style=\"vertical-align:middle;\" alt=\"{$strviewjumpback} ".$jumpNumber." slides\" src=\"".SLOODLE_WWWROOT."/lib/media/bluecons_rewind.gif\" width=\"50\" height=\"50\"></a>"; 
            else $arow[]="<img style=\"vertical-align:middle;\" alt=\"{$strviewjumpback} ".$jumpNumber." slides\" src=\"".SLOODLE_WWWROOT."/lib/media/bluecons_rewind.gif\" width=\"50\" height=\"50\">"; 
            $prev=$displayentrynum-1;
            if ($displayentrynum>=2) $arow[]= "<a href=\"?id={$this->cm->id}&sloodledisplayentry={$prev}#slide\" title=\"{$strviewprev}\"><img alt=\"{$strviewprev}\" style=\"vertical-align:middle;\" src=\"".SLOODLE_WWWROOT."/lib/media/bluecons_prev.gif\" width=\"40\" height=\"40\"></a>  "; 
            else $arow[]= "<img alt=\"{$strviewprev}\" style=\"vertical-align:middle;\" src=\"".SLOODLE_WWWROOT."/lib/media/bluecons_prev.gif\" width=\"40\" height=\"40\">"; 
           
            // display hyperlinks for each slide
            $row="<table width='100%'><tr>";
            foreach ($entries as $entryid => $entry) {
                //get start and end slides                 
                $start = $displayentrynum - $jumpNumber;
                if ($start<0) $start =0;
                $end = $displayentrynum + $jumpNumber;
                if ($end>$numentries) $end =$numentries;
                if (($entrynumcounter >= $start)&& ($entrynumcounter<=$end)){
                    if ($entrynumcounter==$displayentrynum) $row.= "<td style=\"font-weight:bold; font-size:larger;\">"."<a href=\"?id={$this->cm->id}&sloodledisplayentry=".$entrynumcounter."#slide\" title=\"{$entry->name}\">{$entrynumcounter}</a></td>";
                    else $row.= "<td style='padding:10px'><a href=\"?id={$this->cm->id}&sloodledisplayentry=".$entrynumcounter."#slide\" title=\"{$entry->name}\">{$entrynumcounter}</td>";
                }
                $entrynumcounter++;
            }
            $row.="</tr></table>";
            $arow[]=$row;
            $end = $displayentrynum + $jumpNumber+1;
            $next=$displayentrynum+1;
            
            if ($displayentrynum+1 <=$numentries) $arow[]= "<a href=\"?id={$this->cm->id}&sloodledisplayentry={$next}#slide\" title=\"{$strviewnext}\"><img alt=\"{$strviewnext}\" style=\"vertical-align:middle;\" src=\"".SLOODLE_WWWROOT."/lib/media/bluecons_next.gif\" width=\"40\" height=\"40\"></a>  "; 
            else $arow[]="<img alt=\"{$strviewnext}\" style=\"vertical-align:middle;\" src=\"".SLOODLE_WWWROOT."/lib/media/greycons_next.gif\" width=\"40\" height=\"40\">"; 
            if ($end<=$numentries) $arow[]= "<a href=\"?id={$this->cm->id}&sloodledisplayentry=".$end."#slide\" title=\"{$strviewjumpforward} ".$jumpNumber." slides\"><img alt=\"{$strviewjumpforward} ".$jumpNumber."\" style=\"vertical-align:middle;\" src=\"".SLOODLE_WWWROOT."/lib/media/bluecons_fastforward.gif\" width=\"50\" height=\"50\"></a>  "; 
            else $arow[]="<img alt=\"{$strviewjumpforward} ".$jumpNumber."\" style=\"vertical-align:middle;\" src=\"".SLOODLE_WWWROOT."/lib/media/greycons_fastforward.gif\" width=\"50\" height=\"50\">"; 
            
            
            //$slideLinks->data[]=$row;
            $arrowLinks->data[]=$arow;
            
            echo '<div>';
            print_table($arrowLinks); 
            echo '</div>';
            echo "<br><br>";
            echo '</td></tr>';
            echo '</table>';
            echo '</div>';
            // Get the frame dimensions for this Presenter
            $framewidth = $this->presenter->get_frame_width();
            $frameheight = $this->presenter->get_frame_height();            

            // Get the plugin for this slide
            $slideplugin = $this->_session->plugins->get_plugin('presenter-slide', $currententry->type);
            if (is_object($slideplugin)) {
                // Render the content for the web
                echo $slideplugin->render_slide_for_browser($currententry);
            } else {
                echo '<p style="font-size:150%; font-weight:bold; color:#880000;">',get_string('unknowntype','sloodle'),': presenter-slide::',$currententry->type, '</p>';
            }
            

            // Display a direct link to the media
            echo "<p>";
            print '<a href="'.$slideplugin->get_absolute_url($currententry->source).'">';
            print_string('trydirectlink', 'sloodle');
            print "</a>";
            echo "</p>\n";
            echo "</div>";
    
        } else {
            echo '<h4>'.get_string('presenter:empty', 'sloodle').'</h4>';
             if ($this->canedit) echo '<p>'.get_string('presenter:clickaddslide', 'sloodle').'</p>';
        }

        
    }
 
    /**
    * Render the Edit mode of the Presenter (lists all the slides and allows re-ordering).
    * Called from with the {@link render()} function when necessary.
    */
    function render_edit()
    {
        //display any feedback
        if (!empty($this->feedback)) echo $this->feedback;

        global $CFG;      
        $streditpresenter = get_string('presenter:edit', 'sloodle');
        $strviewanddelete = get_string('presenter:viewanddelete', 'sloodle');
        $strnoentries = get_string('noentries', 'sloodle');
        $strnoslides = get_string('presenter:empty', 'sloodle');
        $strdelete = get_string('delete', 'sloodle');
        $stradd = get_string('presenter:add', 'sloodle');
        $straddatend = get_string('presenter:addatend', 'sloodle');
        $straddbefore = get_string('presenter:addbefore', 'sloodle');
        $strtype = get_string('type', 'sloodle');
        $strurl = get_string('url', 'sloodle');
        $strname = get_string('name', 'sloodle');
        
        $stryes = get_string('yes');
        $strno = get_string('no');
        
        $strmove = get_string('move');
        $stredit = get_string('edit', 'sloodle');
        $strview = get_string('view', 'sloodle');
        $strdelete = get_string('delete');
        
        $strmoveslide = get_string('presenter:moveslide', 'sloodle');
        $streditslide = get_string('presenter:editslide', 'sloodle');
        $strviewslide = get_string('presenter:viewslide', 'sloodle');
        $strdeleteslide = get_string('presenter:deleteslide', 'sloodle');

	// pixpath breaks in Moodle 2.
	if ( SLOODLE_IS_ENVIRONMENT_MOODLE_2 ) {
		global $OUTPUT;	 
		$moveheregif = $OUTPUT->pix_url('movehere');
		$movegif = $OUTPUT->pix_url('t/move');
		$editgif = $OUTPUT->pix_url('t/edit');
		$previewgif = $OUTPUT->pix_url('t/preview');
		$deletegif = $OUTPUT->pix_url('t/delete');
	} else {
		$moveheregif = "{$CFG->pixpath}/movehere.gif";
		$movegif = "{$CFG->pixpath}/t/move.gif";
		$editgif = "{$CFG->pixpath}/t/edit.gif";
		$previewgif = "{$CFG->pixpath}/t/preview.gif";
		$deletegif = "{$CFG->pixpath}/t/delete.gif";	
	}

        
         // Get a list of entry URLs
        $entries = $this->presenter->get_slides();
        if (!is_array($entries)) $entries = array();
        $numentries = count($entries);
        // Any images to display?
        if ($entries === false || count($entries) == 0) {
            echo '<h4>'.$strnoslides.'</h4>';
            echo '<h4><a href="'.SLOODLE_WWWROOT.'/view.php?id='.$this->cm->id.'&amp;mode=addslide">'.$stradd.'</a></h4><br>';
        } else {
        
            // Are we being asked to confirm the deletion of a slide?
            if ($this->presenter_mode == 'confirmdeleteslide') {
                // Make sure the session key is specified and valid
                if (required_param('sesskey') != sesskey()) {
                    error('Invalid session key');
                    exit();
                }
                // Determine which slide is being deleted
                $entryid = (int)required_param('entry', PARAM_INT);
                
                // Make sure the specified entry is recognised
                if (isset($entries[$entryid])) {
                    // Construct our links
                    $linkYes = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=deleteslide&amp;entry={$entryid}&amp;sesskey=".sesskey();
                    $linkNo = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=edit";

                    // Output our confirmation form
                    notice_yesno(get_string('presenter:confirmdelete', 'sloodle', $entries[$entryid]->name), $linkYes, $linkNo);
                    echo "<br/>";
                }
            }
            
            // Are we being asked to confirm the deletion of multiple slides?
            $deletingentries = array();
            if ($this->presenter_mode == 'confirmdeletemultiple') {
                // Make sure the session key is specified and valid
                if (required_param('sesskey') != sesskey()) {
                    error('Invalid session key');
                    exit();
                }
                // Grab the array of entries to be deleted
                if (isset($_REQUEST['entries'])) $deletingentries = $_REQUEST['entries'];
                if (is_array($deletingentries) && count($deletingentries) > 0) {
                    // Construct our links
                    $entriesparam = 'entriesstr=';
                    $delim = '';
                    foreach($deletingentries as $de) {
                        $entriesparam .= $delim.intval($de);
                        $delim = ',';
                    }
                    $linkYes = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=deletemultiple&amp;{$entriesparam}&amp;sesskey=".sesskey();
                    $linkNo = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=edit";
                    // Output our confirmation form
                    notice_yesno(get_string('presenter:confirmdeletemultiple', 'sloodle', count($deletingentries)), $linkYes, $linkNo);
                    echo "<br/>";
                } else {
                    // No slides selected.
                    // Inform the user to select slides first, and then click the button again.
                    notify(get_string('presenter:noslidesfordeletion', 'sloodle'));
                }
            }
            
            // Are we currently moving a slide?
            if ($this->presenter_mode == 'moveslide') {
              
                $linkCancel = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=edit";
                $strcancel = get_string('cancel');
                // Display a message and an optional 'cancel' link
                print_box_start('generalbox', 'notice');
                echo "<p>", get_string('presenter:movingslide', 'sloodle', $entries[$this->movingentryid]->name), "</p>\n";
                echo "<p>(<a href=\"{$linkCancel}\">{$strcancel}</a>)</p>\n";
                print_box_end();
            }
        
            // Setup a table object to display Presenter entries
            $entriesTable = new stdClass();
            $entriesTable->head = array(get_string('position', 'sloodle'),'<div id="selectboxes"><a href="#"><div style=\'text-align:center;\' id="selectall">'.get_string('selectall','sloodle').'</div></a></div>', get_string('name', 'sloodle'), get_string('type', 'sloodle'), get_string('actions', 'sloodle'));
            $entriesTable->align = array('center', 'center', 'left', 'left', 'center');
            $entriesTable->size = array('5%', '5%', '30%', '20%', '30%');
            
            // Go through each entry
            $numentries = count($entries);
              foreach ($entries as $entryid => $entry) {
                // Create a new row for the table
                $row = array();
                
                // Extract the entry data
                $slideplugin = $this->_session->plugins->get_plugin('presenter-slide', $entry->type);
                if (is_object($slideplugin)) $entrytypename = $slideplugin->get_plugin_name();
                else $entrytypename = '(unknown type)';
                // Construct the link to the entry source
                $entrylink = "<a href=\"{$entry->source}\" title=\"{$entry->source}\">{$entry->name}</a>";
                // If this is the slide being moved, then completely ignore it
                if ($this->movingentryid == $entryid) {
                    continue;
                }
                
    
                // If we are in move mode, then add a 'move here' row before this slide
                if ($this->presenter_mode == 'moveslide') { 
                    $movelink = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=setslideposition&amp;entry={$this->movingentryid}&amp;position={$entry->slideposition}";
                    $movebutton = "<a href=\"{$movelink}\" title=\"{$strmove}\"><img src=\"{$moveheregif}\" class=\"\" alt=\"{$strmove}\" /></a>\n";
                    $entriesTable->data[] = array('', '', $movebutton, '', '', '');

                    // If the current row belongs to the slide being moved, then emphasise it, and append (moving) to the end
                     if ($entryid == $this->movingentryid) $entrylink = "<strong>{$entrylink}</strong> <em>(".get_string('moving','sloodle').')</em>';
                }
                
                // Define our action links
                $actionBaseLink = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}";
                $actionLinkMove = $actionBaseLink."&amp;mode=moveslide&amp;entry={$entryid}";
                $actionLinkEdit = $actionBaseLink."&amp;mode=editslide&amp;entry={$entryid}";
                $actionLinkView = $actionBaseLink."&amp;mode=view&amp;sloodledisplayentry={$entry->slideposition}#slide";
                $actionLinkDelete = $actionBaseLink."&amp;mode=confirmdeleteslide&amp;entry={$entryid}&amp;sesskey=".sesskey();
                
               
                // Prepare the add buttons separately
                $actionLinkAdd = $actionBaseLink."&amp;mode=addslide&amp;sloodleentryposition={$entry->slideposition}";
                $addButtons = "<a href=\"{$actionLinkAdd}\" title=\"{$straddbefore}\"><img src=\"".SLOODLE_WWWROOT."/lib/media/add.png\" alt=\"{$stradd}\" /></a>\n";
                
                // Construct our list of action buttons
                $actionButtons = '';
                $actionButtons .= "<a href=\"{$actionLinkMove}\" title=\"{$strmoveslide}\"><img src=\"{$movegif}\" class=\"iconsmall\" alt=\"{$strmove}\" /></a>\n";
                $actionButtons .= "<a href=\"{$actionLinkEdit}\" title=\"{$streditslide}\"><img src=\"{$editgif}\" class=\"iconsmall\" alt=\"{$stredit}\" /></a>\n";
                $actionButtons .= "<a href=\"{$actionLinkView}\" title=\"{$strviewslide}\"><img src=\"{$previewgif}\" class=\"iconsmall\" alt=\"{$strview}\" /></a>\n";
                $actionButtons .= "<a href=\"{$actionLinkDelete}\" title=\"{$strdeleteslide}\"><img src=\"{$deletegif}\" class=\"iconsmall\" alt=\"{$strdelete}\" /></a>\n";
                $actionButtons .= $addButtons;

               
                //create checkbox for multiple edit functions
                $checked = '';
                if (in_array($entryid, $deletingentries)) $checked = "checked=\"checked\"";
                $checkbox = "<div style='text-align:center;'><input  type=\"checkbox\" name=\"entries[]\" {$checked} value=\"{$entryid}\" /></div>";
                
                // Add each item of data to our table row.
                // The first item is a check box for multiple deletes
                // The second items are the position and the name of the entry, hyperlinked to the resource.
                // The next is the name of the entry type.
                // The last is a list of action buttons -- move, edit, view, and delete.                
                $row[] = $entry->slideposition;
                $row[] = $checkbox;  
                $row[] = $entrylink;
                $row[] = $entrytypename;
                $row[] = $actionButtons;
                
                
                // Add the row to our table
                $entriesTable->data[] = $row;
            }
              
            
            // If we are in move mode, then add a final 'move here' row at the bottom
            // We need to add a final row at the bottom
            // Prepare the action link for this row
            $endentrynum = $entry->slideposition + 1;
            $actionLinkAdd = $actionBaseLink."&amp;mode=addslide&amp;sloodleentryposition={$endentrynum}";
            $addButtons = "<a href=\"{$actionLinkAdd}\" title=\"{$straddatend}\"><img src=\"".SLOODLE_WWWROOT."/lib/media/add.png\" alt=\"{$stradd}\" /></a>\n";
            $sloodleInsert = get_string("presenter:sloodleinsert","sloodle");
            // It will contain a last 'add' button, and possibly a 'move here' button too (if we are in move mode)
            $movebutton = '';
            if ($this->presenter_mode == 'moveslide') {
                $movelink = SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=setslideposition&amp;entry={$this->movingentryid}&amp;position={$endentrynum}";
                $movebutton = "<a href=\"{$movelink}\" title=\"{$strmove}\"><img src=\"{$moveheregif}\" class=\"\" alt=\"{$strmove}\" /></a>\n";
            }
            
            // Add a button to delete all selected slides
            $deleteButton = '<input type="submit" value="'.get_string('deleteselected','sloodle').'" />';
            $entriesTable->data[] = array('',' <div id="selectboxes2"><a href="#"><div style=\'text-align:center;\' id="selectall2">'.get_string('selectall','sloodle').'</div></a></div>', $movebutton , '', $deleteButton.'&nbsp;&nbsp;'.$addButtons);
            
            // Put our table inside a form to allow us to delete multiple slides based on the checkboxes
            echo '<form action="" method="get" id="editform" name="editform">';
            echo "<input type=\"hidden\" name=\"id\" value=\"{$this->cm->id}\" />\n"; // Course module ID so that the request comes to the right places
            echo "<input type=\"hidden\" name=\"mode\" value=\"confirmdeletemultiple\" />\n"; // The operation being conducted
            print_table($entriesTable);
            echo "<input type=\"hidden\" name=\"sesskey\" value=\"".sesskey()."\" />\n"; // Session key to ensure unauthorised deletions are not possible (e.g. using XSS)
            echo '</form>';                
           
        }
        
    }
    
    /**
    * Render the "Upload Many" tab.
    */        
    function render_add_files()
    {
        global $CFG;
	global $USER;


	/*
	Normally Moodle would use the itemid for something that the image belongs to, eg. a forum post.
	We don't really need one here - we have slides, but they are assigned after the file has been uploaded.
	We'll set this parameter to a unique ID per upload page.
	This will prevent clashes if you try to re-upload another file with the same name.
	(The upload component expects to know what the name of the uploaded file will be, so we have to assign it before doing the upload.)
	*/
	$itemid = time();

        // Setup variables to store the data
        $entryid = 0;
        $entryname = '';
        $entryurl = '';
        $entrytype = '';

        // Fetch a list of existing slides
        $entries = $this->presenter->get_entry_urls();
        // Check what position we are adding the new slide to
        // (default to negative, which puts it at the end)
        $position = (int)optional_param('sloodleentryposition', '-1', PARAM_INT);

      
        // Fetch our translation strings
        $streditpresenter = get_string('presenter:edit', 'sloodle');
        $strviewanddelete = get_string('presenter:viewanddelete', 'sloodle');
        $strnoentries = get_string('noentries', 'sloodle');
        $strdelete = get_string('delete', 'sloodle');
        $strBulkUpload = get_string('presenter:bulkupload', 'sloodle');
        $stradd = get_string('presenter:addfiles', 'sloodle');
        $strtype = get_string('type', 'sloodle');
        $strurl = get_string('url', 'sloodle');
        $strname = get_string('name', 'sloodle');
        $strposition = get_string('position', 'sloodle');
        $strsave = get_string('save', 'sloodle');
        $strend = get_string('end', 'sloodle');
        
        $stryes = get_string('yes');
        $strno = get_string('no');
        $strcancel = get_string('cancel');
        
        $strmove = get_string('move');
        $stredit = get_string('edit', 'sloodle');
        $strview = get_string('view', 'sloodle');
        $strdelete = get_string('delete');

        // Construct an array of available entry types, associating the identifier to the human-readable name.
        // In future, this will be built from a list of plugins, but for now we'll hard code it.
        $availabletypes = array();
        $availabletypes['image'] = get_string('presenter:type:image','sloodle');
        $availabletypes['video'] = get_string('presenter:type:video','sloodle');
        $availabletypes['web'] = get_string('presenter:type:web','sloodle');
        //display instructions
        echo get_string('presenter:uploadInstructions','sloodle');
        // We'll post the data straight back to this page
        echo '<form action="" method="post"><fieldset style="border-style:none;">';
        
        
        // Identify the module
    
    /*
    * Uploadify Multiple File uploader added by Paul Preibisch
    * @see http://www.uploadify.com/documentation
    * 
    * @var uploadWwwDir         - place to store files
    * @var uploadArray[]          - array to hold complete file names  
    * @var extension            - temp var to hold extension type of current file
    * @var tableData            - used to construct table rows
    * @uses upload.php          - upload.php is the upload handler script
    * @uses uploader.swf        - enables multiple file uploading     
    */   

    $context = get_context_instance(CONTEXT_MODULE, $this->cm->id);
    $contextid = $context->id;

    echo '<script type="text/javascript">';                                                           
    if (SLOODLE_IS_ENVIRONMENT_MOODLE_2) {
	    echo 'var uploadWwwDir="'.$CFG->wwwroot.'/pluginfile.php/'.intval($contextid).'/mod_sloodle/presenter/'.intval($itemid).'/'.'";'."\n";
    } else {
	    echo 'var uploadWwwDir="'.$CFG->wwwroot.'/file.php/1/presenter/'.intval($this->cm->id).'/";'."\n";
    }
    echo 'var uploadArray = [];'."\n";
    echo 'var qSize=0;'."\n";
    echo 'var uploadLimit='.((integer)INI_GET('post_max_size')*1000000).';'."\n";

    echo 'var uploadArrayLen=0;'."\n";
    echo 'var counter=0;'."\n";
    echo 'var extension=\'\';'."\n";  
    echo 'var tableData=\'\';'."\n";

    echo 'var cmid = '.intval($this->cm->id)."\n";
    echo 'var itemid = '.intval($itemid)."\n";
    echo "var stradd = '".s($stradd)."';\n";


    $signeddata = date('Ymd').'-'.intval($USER->id).'-'.intval($this->cm->id).'-'.'presenter';
    echo "var signeddata = '".s($signeddata)."';"."\n";
    echo "var signature = '".s(sloodle_signature($signeddata))."';"."\n";

	echo "</script>";
                 
        echo '<input type="file" name="fileInput" id="fileInput" />';
        //this div is where the uploaded files will be displayed
        echo '<div name="filesUploaded" id="filesUploaded"><div name="fileTables" id="fileTables"></div></div>';             
        echo '<div name="qSize" id="qSize"></div></fieldset>';          
        echo '<div style="display:none;" name="uploadButton" id="uploadButton"><a href="javascript:startUpload(\'fileUpload\')">Start Upload</a></div></form>';
        // Add a button to let us cancel and go back to the main edit tab
        echo '<form action="" method="get"><fieldset style="border-style:none;">';
        echo "<input type=\"hidden\" name=\"id\" value=\"{$this->cm->id}\" />";
        echo "<input type=\"hidden\" name=\"mode\" value=\"edit\" />";
        echo "<input type=\"submit\" value=\"{$strcancel}\" />";        
        echo '</fieldset></form>';   
        

    }         
    /**
    * Render the slide editing form of the Presenter (lets you edit a single slide).
    * Called from with the {@link render()} function when necessary.
    */
    function render_slide_edit()
    {
        // Setup variables to store the data
        $entryid = 0;
        $entryname = '';
        $entryurl = '';
        $entrytype = '';
        // Fetch a list of existing slides
        $entries = $this->presenter->get_slides();
        // Check what position we are adding the new slide to
        // (default to negative, which puts it at the end)
        $position = (int)optional_param('sloodleentryposition', '-1', PARAM_INT);

        // Are we adding a slide, or editing one?
        $newslide = false;
        if ($this->presenter_mode == 'addslide') {
            // Adding a new slide
            $newslide = true;
            // Grab the last added type from session data
            if (isset($_SESSION['sloodle_presenter_add_type'])) $entrytype = $_SESSION['sloodle_presenter_add_type'];

        } else {
            // Editing an existing slide
            $entryid = (int)required_param('entry', PARAM_INT);
            // Fetch the slide details
            if (!isset($entries[$entryid])) {
                error("Cannot find entry {$entryid} in the database.");
                exit();
            }
           $entryurl = $entries[$entryid]->source;
           $entrytype = $entries[$entryid]->type;
           $entryname = $entries[$entryid]->name;
        }
        // Fetch our translation strings
        $streditpresenter = get_string('presenter:edit', 'sloodle');
        $strviewanddelete = get_string('presenter:viewanddelete', 'sloodle');
        $strnoentries = get_string('noentries', 'sloodle');
        $strdelete = get_string('delete', 'sloodle');
        $stradd = get_string('presenter:add', 'sloodle');
        $strtype = get_string('type', 'sloodle');
        $strurl = get_string('url', 'sloodle');
        $strname = get_string('name', 'sloodle');
        $strposition = get_string('position', 'sloodle');
        $strsave = get_string('save', 'sloodle');
        $strend = get_string('end', 'sloodle');
        
        $stryes = get_string('yes');
        $strno = get_string('no');
        $strcancel = get_string('cancel');
        
        $strmove = get_string('move');
        $stredit = get_string('edit', 'sloodle');
        $strview = get_string('view', 'sloodle');
        $strdelete = get_string('delete');

        // Construct an array of available entry types, associating the identifier to the human-readable name.
        $availabletypes = array();
        $pluginids = $this->_session->plugins->get_plugin_ids('presenter-slide');
        if (!$pluginids) exit('Failed to query for SLOODLE Presenter slide plugins.');
        foreach ($pluginids as $pluginid) {
            // Fetch the plugin and store its human-readable name
            $plugin = $this->_session->plugins->get_plugin('presenter-slide', $pluginid);
            $availabletypes[$pluginid] = $plugin->get_plugin_name();
        }       
        // We'll post the data straight back to this page
        echo '<form action="" method="post"><fieldset style="border-style:none;">';
        // Identify the module
        echo "<input type=\"hidden\" name=\"id\" value=\"{$this->cm->id}\" />";
        // Identify the entry being edited, if appropriate
        if (!$newslide) echo "<input type=\"hidden\" name=\"sloodleentryid\" value=\"{$entryid}\" />";
        // Add boxes for the URL and name of the entry
        echo '<label for="sloodleentryname">'.$strname.': </label> <input type="text" id="sloodleentryname" name="sloodleentryname" value="'.$entryname.'" size="100" maxlength="255" /><br/><br/>'; 
        echo '<label for="sloodleentryurl">'.$strurl.': </label> <input type="text" id="sloodleentryurl" name="sloodleentryurl" value="'.$entryurl.'" size="100" maxlength="255" /><br/><br/>'; 
        // Add a selection box for the entry type
        echo '<label for="sloodleentrytype">'.$strtype.': </label> <select name="sloodleentrytype" id="sloodleentrytype" size="1">';
        foreach ($availabletypes as $typeident => $typename) {
            echo "<option value=\"{$typeident}\"";
            if ($typeident == $entrytype) echo " selected=\"selected\"";
            echo ">{$typename}</option>";
        }
        echo '</select><br/><br/>';

        // Add a selection box to let the user change the position of the entry
        echo '<label for="sloodleentryposition">'.$strposition.': </label> <select name="sloodleentryposition" id="sloodleentryposition" size="1">'."\n";
        $selected = false;
        foreach ($entries as $curentryid => $curentry) {
            // Add this entry to the list
            echo "<option value=\"{$curentry->slideposition}\"";
            if ($curentry->slideposition == $position || $curentryid == $entryid) {
                echo ' selected="selected"';
                $selected = true;
            }
            echo ">{$curentry->slideposition}: {$curentry->name}</option>\n";
        }
        // Add an 'end' option so that the entry can be placed at the end of the presentation
        $endentrynum = $curentry->slideposition + 1;
        echo "<option value=\"{$endentrynum}\"";
        if (!$selected) echo " selected=\"selected\"";
        echo ">--{$strend}--</option>\n";
        echo "</select><br/><br/>\n";

        // Display an appropriate submit button
        if ($newslide) echo ' <input type="submit" value="'.$stradd.'" name="sloodleaddentry" />';
        else echo ' <input type="submit" value="'.$strsave.'" name="sloodleeditentry" />';
        // Close the form
        echo '</fieldset></form>';

        // Add a button to let us cancel and go back to the main edit tab
        echo '<form action="" method="get"><fieldset style="border-style:none;">';
        echo "<input type=\"hidden\" name=\"id\" value=\"{$this->cm->id}\" />";
        echo "<input type=\"hidden\" name=\"mode\" value=\"edit\" />";
        echo "<input type=\"submit\" value=\"{$strcancel}\" />";
        echo '</fieldset></form>'; 
    }


    /**
    * Render the tab for importing slides from some source.
    * If necessary, this will first display a form letting the user select which importer to use.
    * It will then rely on the plugin to sort out everything else.
    */
    function render_import_slides()
    {
        global $CFG;

        // Construct an array of available importers, associating the identifier to the human-readable name.
        $availableimporters = array();
        $pluginids = $this->_session->plugins->get_plugin_ids('presenter-importer');
        if (!$pluginids) error('Failed to load any SLOODLE Presenter importer plugins. Please check your plugins folder.');
        foreach ($pluginids as $pluginid) {
            // Fetch the plugin and store its human-readable name
            $plugin = $this->_session->plugins->get_plugin('presenter-importer', $pluginid);
            $availableimporters[$pluginid] = $plugin->get_plugin_name();
        }

        // We are expecting a few parameters
        $position = (int)optional_param('sloodleentryposition', '-1', PARAM_INT);
        $plugintype = strtolower(optional_param('sloodleplugintype', '', PARAM_CLEAN));

        // Fetch translation strings
        $strselectimporter = get_string('presenter:selectimporter', 'sloodle');
        $strsubmit = get_string('submit');
        $strincompatible = get_string('incompatible', 'sloodle');
        $strcompatible = get_string('compatible', 'sloodle');
        $strincompatibleplugin = get_string('incompatibleplugin', 'sloodle');
        $strcheck = get_string('check', 'sloodle');
        $strclicktocheck = get_string('clicktocheckcompatibility', 'sloodle');
        $strclicktochecknoperm = get_string('clicktocheckcompatibility:nopermission', 'sloodle');
        
        // Do we have a valid plugin type already specified?
        if (empty($plugintype) || !array_key_exists($plugintype, $availableimporters)) {
            // No - display a menu to select the desired importer
            
            // Sort the list of importers by name
            natcasesort($availableimporters);
            // Setup a base link for all importer types
            $baselink = "{$CFG->wwwroot}/mod/sloodle/view.php?id={$this->cm->id}&amp;mode=importslides";
            // Setup a base link for checking compatibility
            $checklink = "{$CFG->wwwroot}/mod/sloodle/view.php?id={$this->cm->id}&amp;mode=compatibility";
            
            // Make sure this user has site configuration permission, as running this test may reveal sensitive information about server architecture
            $module_context = get_context_instance(CONTEXT_MODULE, $this->cm->id);
            $cancheckcompatibility = (bool)has_capability('moodle/site:config', $module_context);

            // Go through each one and display it in a menu
            $table = new stdClass();
            $table->head = array(get_string('name', 'sloodle'), get_string('description'), get_string('compatibility', 'sloodle'));
            $table->size = array('20%', '70%', '10%');
            $table->align = array('center', 'left', 'center');
            $table->data = array();
            foreach ($availableimporters as $importerident => $importername) {

                // Get the description of the plugin
                $plugin = $this->_session->plugins->get_plugin('presenter-importer', $importerident);
                $desc = $plugin->get_plugin_description();

                // Check the compatibility of the plugin
                $linkclass = '';
                $compatibility = '';
                if (!$plugin->check_compatibility()) {
                    $linkclass = ' class="dimmed"';
                    $compatibility = '<abbr title="'.$plugin->get_compatibility_summary().'"><span class="highlight2" style="font-weight:bold;">[ '.$strincompatible.' ]</span></abbr>';
                }

                // Construct this line of the table
                $line = array();
                
                // Add the name of the importer to the table as a link
                $link = "{$baselink}&amp;sloodleplugintype={$importerident}";
                $line[] = "<span style=\"font-size:120%; font-weight:bold;\"><a href=\"{$link}\" title=\"{$desc}\" {$linkclass}>{$importername}</a></span><br/>{$compatibility}";
                // Add the description
                $line[] = $desc;
                // Add a link to a compatibility check if the user has permission.
                if ($cancheckcompatibility) {
                    $link = "{$checklink}&amp;sloodleplugintype={$importerident}";
                    $line[] = "<a href=\"{$link}\" title=\"{$strclicktocheck}\">{$strcheck}</a>";
                } else {
                    $line[] = "<span title=\"{$strclicktochecknoperm}\">-</span>";
                }

                $table->data[] = $line;
            }

            echo "<h4>{$strselectimporter}: </h4>\n";
            print_table($table);
            

            return;
        }
        
        // Grab the importer plugin object
        $importer = $this->_session->plugins->get_plugin('presenter-importer', $plugintype);

        // Display a heading for this importer
        echo '<h2 style="margin-bottom:0px; padding-bottom:0px;">'.$importer->get_plugin_name()."</h2>\n";

        // Render the plugin display
        $importer->render("{$CFG->wwwroot}/mod/sloodle/view.php?id={$this->cm->id}", $this->presenter);
        
    }
    
    /**
    * Render a compatibility test of a particular plugin.
    */
    function render_compatibility_test()
    {
        global $CFG;
        
        // Which plugin has been requested?
        $plugintype = strtolower(required_param('sloodleplugintype', PARAM_CLEAN));
        // Attempt to load the specified plugin
        $plugin = $this->_session->plugins->get_plugin('presenter-importer', $plugintype);
        if ($plugin === false) exit(get_string('pluginloadfailed', 'sloodle'));
        $name = $plugin->get_plugin_name();
        
        // Make sure this user has site configuration permission, as running this test may reveal sensitive information about server architecture
        $module_context = get_context_instance(CONTEXT_MODULE, $this->cm->id);
        if (!has_capability('moodle/site:config', $module_context)) error(get_string('clicktocheckcompatibility:nopermission', 'sloodle'), "{$CFG->wwwroot}/mod/sloodle/view.php?id={$this->cm->id}&amp;mode=importslides");
        
        // Display a heading for this compatibility check
        echo '<h1>',get_string('runningcompatibilitycheck', 'sloodle'),'</h1>';
        echo '<h2>'.$name."</h2>\n";
        echo "<p>( <a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?id={$this->cm->id}&amp;mode=importslides\">",get_string('presenter:backtoimporters','sloodle'),"</a> )</p>\n";
        // Run the compatibility test
        echo "<div style=\"text-align:left;\">";
        $result = $plugin->run_compatibility_test();
        echo "</div>\n";
        
        if ($result) echo "<h1>",get_string('compatibilitytestpassed', 'sloodle'),"</h1>";
        else echo "<h1>",get_string('compatibilitytestfailed', 'sloodle'),"</h1>";
        echo "<p>( <a href=\"{$CFG->wwwroot}/mod/sloodle/view.php?id={$this->cm->id}&amp;mode=importslides\">",get_string('presenter:backtoimporters','sloodle'),"</a> )</p>\n";
    }

    /**
    * Render the view of the Presenter.
    */
    function render()
    {
        global $CFG;
        
        // Setup our list of tabs
        // We will always have a view option
        $presenterTabs = array(); // Top level is rows of tabs
        $presenterTabs[0] = array(); // Second level is individual tabs in a row
        $presenterTabs[0][] = new tabobject(SLOODLE_PRESENTER_TAB_VIEW, SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=view", get_string('view', 'sloodle'), get_string('presenter:viewpresentation', 'sloodle'), true);
        // Does the user have authority to edit this module?
        if ($this->canedit) {
            // Add the 'Edit' tab, for editing the presentation as a whole
            $presenterTabs[0][] = new tabobject(SLOODLE_PRESENTER_TAB_EDIT, SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=edit", get_string('edit', 'sloodle'), get_string('presenter:edit', 'sloodle'), true);

            // Add the 'Add Slide' tab
            $presenterTabs[0][] = new tabobject(SLOODLE_PRESENTER_TAB_ADD_SLIDE, SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=addslide", get_string('presenter:add', 'sloodle'), get_string('presenter:add', 'sloodle'), true);

            // Add the 'Bulk Upload' tab
            $presenterTabs[0][] = new tabobject(SLOODLE_PRESENTER_TAB_ADD_FILES, SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=addfiles", get_string('presenter:bulkupload', 'sloodle'), get_string('presenter:bulkupload', 'sloodle'), true);

            // Add the 'Import Slides' tab
            $presenterTabs[0][] = new tabobject(SLOODLE_PRESENTER_TAB_IMPORT_SLIDES, SLOODLE_WWWROOT."/view.php?id={$this->cm->id}&amp;mode=importslides", get_string('presenter:importslides', 'sloodle'), get_string('presenter:importslides', 'sloodle'), true);

            // If we are editing a slide, then add the 'Edit Slide' tab
            if ($this->presenter_mode == 'editslide') {
                $presenterTabs[0][] = new tabobject(SLOODLE_PRESENTER_TAB_EDIT_SLIDE, '', get_string('editslide', 'sloodle'), '', false);
            }
        }
        // Determine which tab should be active
        $selectedtab = SLOODLE_PRESENTER_TAB_VIEW;
        switch ($this->presenter_mode)
        {
        case 'edit': $selectedtab = SLOODLE_PRESENTER_TAB_EDIT; break;
        case 'addslide': $selectedtab = SLOODLE_PRESENTER_TAB_ADD_SLIDE; break;
        case 'addfiles': $selectedtab = SLOODLE_PRESENTER_TAB_ADD_FILES; break;
        case 'editslide': $selectedtab = SLOODLE_PRESENTER_TAB_EDIT_SLIDE; break;
        case 'moveslide': $selectedtab = SLOODLE_PRESENTER_TAB_EDIT; break;
        case 'deleteslide': $selectedtab = SLOODLE_PRESENTER_TAB_EDIT; break;
        case 'confirmdeleteslide': $selectedtab = SLOODLE_PRESENTER_TAB_EDIT; break;
        case 'deletemultiple': $selectedtab = SLOODLE_PRESENTER_TAB_EDIT; break;
        case 'confirmdeletemultiple': $selectedtab = SLOODLE_PRESENTER_TAB_EDIT; break;
        case 'importslides': $selectedtab = SLOODLE_PRESENTER_TAB_IMPORT_SLIDES; break;
        case 'compatibility': $selectedtab = SLOODLE_PRESENTER_TAB_IMPORT_SLIDES; break;
        }
        
        // Display the tabs
        print_tabs($presenterTabs, $selectedtab);
        echo "<div style=\"text-align:center;\">\n";
        
        // Call the appropriate render function, based on our mode
        switch ($this->presenter_mode)
        {
        case 'edit': $this->render_edit(); break;
        case 'addslide': $this->render_slide_edit(); break;
        case 'addfiles': $this->render_add_files(); break;
        case 'editslide': $this->render_slide_edit(); break;
        case 'moveslide': $this->render_edit(); break;
        case 'deleteslide': $this->render_edit(); break;
        case 'confirmdeleteslide': $this->render_edit(); break;
        case 'deletemultiple': $this->render_edit(); break;
        case 'confirmdeletemultiple': $this->render_edit(); break;
        case 'importslides': $this->render_import_slides(); break;
        case 'compatibility': $this->render_compatibility_test(); break;
        default: $this->render_view(); break;
        }
        
        echo "</div>\n";
    }

}


?>

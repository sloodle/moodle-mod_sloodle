<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines the Sloodle awards module.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    * @contributor Paul G. Preibisch - aka Fire Centaur 
    */
    
    /** The Sloodle module base. */
    require_once(SLOODLE_LIBROOT.'/modules/module_base.php');
    /** General Sloodle functions. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    
    /** SLOODLE course object data structure */
    require_once(SLOODLE_LIBROOT.'/sloodlecourseobject.php');

    /** SLOODLE stipendgiver object data structure */
    require_once(SLOODLE_DIRROOT.'/mod/awards-1.0/awards_object.php');
    /** Sloodle Session code. */
        
    /**
    * The Sloodle StipendGiver module class.
    * @package sloodle
    */
    class SloodleModuleAwards extends SloodleModule
    {
    // DATA //
    
        /**
        * Internal for Moodle only - course module instance.
        * Corresponds to one record from the Moodle 'course_modules' table.
        * @var object
        * @access private
        */
        var $cm = null;
    
        /**
        * Internal only - Sloodle module instance database object.
        * Corresponds to one record from the Moodle 'sloodle' table.
        * @var object
        * @access private
        */
        var $sloodle_module_instance = null;
        
        /**
        * Internal only - Sloodle StipendGiver instance database object.
        * Corresponds to one record from the Moodle 'sloodle_awards' table.
        * @var object
        * @access private
        */
        var $sloodle_awards_instance = null;
        
        var $sCourseObj = null;
        

        
        var $sloodleid = null;       
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleModuleAwards(&$_session)
        {
            $constructor = get_parent_class($this);
            parent::$constructor($_session);
        }
        
        /**
        * Loads data from the database.
        * Note: even if the function fails, it may still have overwritten some or all existing data in the object.
        * @param mixed $id The site-wide unique identifier for all modules. Type depends on VLE. On Moodle, it is an integer course module identifier ('id' field of 'course_modules' table)
        * @return bool True if successful, or false otherwise
        */
        function load($id)
        {
            // Make sure the ID is valid
            if (!is_int($id) || $id <= 0) return false;
            
            // Fetch the course module data
            if (!($this->cm = get_coursemodule_from_id('sloodle', $id))) return false;
            // Load from the primary table: Sloodle instance
            if (!($this->sloodle_module_instance = get_record('sloodle', 'id', $this->cm->instance))) return false;
            // Load from the primary table: sloodle instance
            if (!($this->sloodle_instance = get_record('sloodle', 'id', $this->cm->instance))) {
                sloodle_debug("Failed to load Sloodle module with instance ID #{$cm->instance}.<br/>");
                return false;
            }
            
            
            
            if ($this->sloodle_module_instance->type != SLOODLE_TYPE_AWARDS) return false;
            
            // Load from the secondary table: StipendGiver instance
            if (!($this->sloodle_awards_instance = get_record('sloodle_awards', 'sloodleid', $this->cm->instance))) return false;
            
            return true;
        }
        
        
        /**
        * Gets a list of all objects for this StipendGiver.
        * @return array An array of strings, each string containing the name of an object in this StipendGiver.
        */
        function get_objects()
        {
            // Get all StipendGiver record entries for this StipendGiver
            $recs = get_records('sloodle_award_trans', 'sloodleid', $this->sloodle_awards_instance->id);
            if (!$recs) return array();
            // Convert it to an array of strings
            $entries = $recs;
            
            
            return $entries;
        }
        
         /**
    * Gets a list of students in the class
    */
      function get_class_list(){
            $fulluserlist = get_users(true, '');
            if (!$fulluserlist) $fulluserlist = array();
            $userlist = array();
            // Filter it down to members of the course
            foreach ($fulluserlist as $ful) {
                // Is this user on this course?
                if (has_capability('moodle/course:view', $this->course_context, $ful->id)) {
                    // Copy it to our filtered list and exclude administrators
                    if (!isadmin($ful->id))
                      $userlist[] = $ful;
                }
            }
            return $userlist;
      
      }
      
      
        /**
        * This attempts to withdraw money.
        * @param array $info is an array which first lists the intent of what the stipend will be used for
        * the next element is the uuid of the avatar
        * @return bool True if successful, or false if not
        */
                           
        
        
    // ACCESSORS //
    
        /**
        * Gets the name of this module instance.
        * @return string The name of this controller
        */
        function get_name()
        {
            return $this->sloodle_module_instance->name;
        }
        
        /**
        * Gets the intro description of this module instance, if available.
        * @return string The intro description of this controller
        */
        function get_intro()
        {
            return $this->sloodle_module_instance->intro;
        }
        
        /**
        * Gets the identifier of the course this controller belongs to.
        * @return mixed Course identifier. Type depends on VLE. (In Moodle, it will be an integer).
        */
        function get_course_id()
        {
            return (int)$this->sloodle_module_instance->course;
        }
        
        /**
        * Gets the time at which this instance was created, or 0 if unknown.
        * @return int Timestamp
        */
        function get_creation_time()
        {
            return $this->sloodle_module_instance->timecreated;
        }
        function get_amount(){
          return $this->sloodle_awards_instance->amount;
      }
        
        /**
        * Gets the time at which this instance was last modified, or 0 if unknown.
        * @return int Timestamp
        */
        function get_modification_time()
        {
            return $this->sloodle_module_instance->timemodified;
        }
        
        
        /**
        * Gets the short type name of this instance.
        * @return string
        */
        function get_type()
        {
            return SLOODLE_TYPE_AWARDS;
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return get_string('moduletype:'.SLOODLE_TYPE_AWARDS, 'sloodle');
        }
         // BACKUP AND RESTORE //
        function get_trans($id)
        {
            // Sanitize the data
            $id = (int)$id;
       
            // Fetch the requested slide
            $r = get_record('sloodle_award_trans', 'id', $id);
            if (!$r) return false;
            return new SloodleAwardTransaction($r->id, $this, $r->avuuid,$r->avname,$r->userid,$r->itype,$r->amount,$r->idata);                
        }

        /**
        * Gets an ordered associative array of transactions for the sloodle awards
        * @return Array associating award IDs to SloodleAwards objects if successful, or false if not.
        */
        function get_transactions()
        {
            
            // Fetch the database records
            $recs = get_records_select('sloodle_award_trans', "sloodleid = {$this->sloodle_awards_instance->id}");
            if (!$recs) return array();
            // Construct the array of objects
            $output = array();
            foreach ($recs as $r) {
                // Substitute the source data for the name if no name is given.
                

                // Add the slide to our list
                $output[$r->id] = new SloodleAwardTransaction($r->id, $this, $r->avuuid,$r->avname,$r->userid,$r->itype,$r->amount,$r->idata);                
                
            }
            return $output;
        }
        /**
        * Backs-up secondary data regarding this module.
        * That includes everything except the main 'sloodle' database table for this instance.
        * @param $bf Handle to the file which backup data should be written to.
        * @param bool $includeuserdata Indicates whether or not to backup 'user' data, i.e. any content. Most SLOODLE tools don't have any user data.
        * @return bool True if successful, or false on failure.
        */
 function backup($bf, $includeuserdata)
        {
            // Data about the Presenter itself
            fwrite($bf, full_tag('ID', 5, false, $this->sloodle_instance->id));
            fwrite($bf, full_tag('ICURRENCY', 5, false, $this->sloodle_awards_instance->icurrency));
            fwrite($bf, full_tag('MAXPOINTS', 5, false, $this->sloodle_awards_instance->maxpoints));
            
            
            // Attempt to fetch all the transactions for the award
            $transactions= $this->get_transactions();
            if (!$transactions) return false;
            
            // Data about the transactions for the award.            
            fwrite($bf, start_tag('TRANSACTIONS', 5, true));
            foreach ($transactions as $trans) {
                fwrite($bf, start_tag('TRANSACTION', 6, true));
                
               
                
                fwrite($bf, full_tag('ID', 7, false, $trans->id));
                fwrite($bf, full_tag('AVUUID', 7, false, $trans->avuuid));
                fwrite($bf, full_tag('AVNAME', 7, false, $trans->avname));
                fwrite($bf, full_tag('USERID', 7, false, $trans->userid));
                fwrite($bf, full_tag('ITYPE', 7, false, $trans->itype));
                fwrite($bf, full_tag('AMOUNT', 7, false, $trans->amount));
                fwrite($bf, full_tag('IDATA', 7, false, $trans->idata));
                
                fwrite($bf, end_tag('TRANSACTION', 6, true));
            }
            fwrite($bf, end_tag('TRANSACTIONS', 5, true));
            
            
            return true;
        }
        
        /**
        * Restore this module's secondary data into the database.
        * This ignores any member data, so can be called statically.
        * @param int $sloodleid The ID of the primary SLOODLE entry this restore belongs to (i.e. the ID of the record in the "sloodle" table)
        * @param array $info An associative array representing the XML backup information for the secondary module data
        * @param bool $includeuserdata Indicates whether or not to restore user data
        * @return bool True if successful, or false on failure.
        */
        function restore($sloodleid, $info, $includeuserdata)
        {
            // Construct the database record for the Presenter itself
            $award = new object();
            $award->sloodleid = $info['ID']['0']['#'];
            $award->icurrency= $info['ICURRENCY']['0']['#'];
            $award->maxpoints= $info['MAXPOINTS']['0']['#'];           
            $award->id = insert_record('sloodle_awards', $award);
            
            
            
            // Go through each slide in the presenter backup
            $numtrans = count($info['TRANSACTIONS']['0']['#']['TRANS']);
            $curtran= null;
            for ($trannum = 0; $trannum < $numtrans; $trannum++) {
                // Get the current award trans data
                $curtran = $info['TRANSACTIONS']['0']['#']['TRANS'][$trannum]['#'];
                // Construct a new transaction database object
                $trans= new object();
                $trans->sloodleid = $sloodleid;
                $trans->avuuid= $info['AVUUID']['0']['#'];
                $trans->avname= $info['AVNAME']['0']['#'];
                $trans->userid= $info['USERID']['0']['#'];
                $trans->itype= $info['ITYPE']['0']['#'];
                $trans->amount= $info['AMOUNT']['0']['#'];
                $trans->idata= $info['IDATA']['0']['#'];
                $trans->id = insert_record('sloodle_award_trans', $trans);
            }
        
            return true;
        }


	function ProcessInteractions( $relevant_configs, $controllerid, $multiplier, $userid ) {

		global $CFG;

		// Find the active round for the controller, or make one if there isn't one.
		$timets = time();
		$roundrecs = get_records_select('sloodle_award_rounds', "controllerid = $controllerid AND ( (timestarted <= $timets ) OR (timestarted = 0) ) AND ( (timeended >= $timets ) OR (timeended = 0) ) ");

		$need_notify = false;

		$round = null;
		if ( $roundrecs || ( count($roundrecs) > 0 ) ) {
			$round = array_pop($roundrecs);
		} else {
			$round = new stdClass();
			$round->controllerid = $controllerid;
			$round->timestarted = time();
			$round->timeended = 0;
			$round->name = '';
			if ( !insert_record('sloodle_award_rounds', $round) ) {
				return false;
			}
		}

		if (!$roundid = $round->id) {
			return false;
		}

		$time = time();

		if ( isset($relevant_configs['sloodleawardsdeposit_numpoints']) && isset($relevant_configs['sloodleawardsdeposit_currency']) ) {

			$numpoints  = intval($relevant_configs['sloodleawardsdeposit_numpoints']);
			$currencyid = intval($relevant_configs['sloodleawardsdeposit_currency']);

			if (!$currencyid) {
				return false;
			}

			$award = new stdClass();	
			$award->userid = $userid;
			$award->currencyid = $currencyid;
			$award->amount = $numpoints * $multiplier;
			$award->timeawarded = $time;
			$award->roundid = $roundid;

			if ( !insert_record('sloodle_award_points', $award) ) {
				return false;
			}

			$need_notify = true;

		}

		if ( isset($relevant_configs['sloodleawardswithdraw_numpoints']) && isset($relevant_configs['sloodleawardswithdraw_currency']) ) {

			$numpoints  = intval($relevant_configs['sloodleawardswithdraw_numpoints']) * -1;
			$currencyid = intval($relevant_configs['sloodleawardswithdraw_currency']);

			if (!$currencyid) {
				return false;
			}

			$award = new stdClass();	
			$award->userid = $userid;
			$award->currencyid = $currencyid;
			$award->amount = $numpoints * $multiplier;
			$award->timeawarded = $time;
			$award->roundid = $roundid;
			if ( !insert_record('sloodle_award_points', $award) ) {
				return false;
			}

			$need_notify = true;
		}

		if ($need_notify) {
			// Notify any active objects that care about changes to scores
			// We'll check this in the object definition.
			// TODO: We should probably do this with a notification_request table, 
			// ...where the scoreboard etc will register with Sloodle that it's interested in certain events.

			// TODO: Figure out the round/controller filters
			$user_point_total_recs = get_records_sql( "select sum(amount) as balance from {$CFG->prefix}sloodle_award_points where currencyid=$currencyid and roundid=$roundid and userid=$userid;");
			if (!$user_point_total_recs && (count($user_point_total_recs) == 0 ) ) {
				return false;
			}
			$first_rec = array_shift($user_point_total_recs);
			$balance = $first_rec->balance;

			SloodleActiveObject::NotifySubscriberObjects( 'awards_points_change', 10601, $controllerid, $userid, array('balance' => $balance, 'roundid' => $roundid, 'userid' => $userid, 'currencyid' => $currencyid, 'timeawarded' => $time ) );
		}
		
		return true;

	}
	
	function InteractionConfigNames() {
		return array(
                        'sloodleawardsdeposit_numpoints',
                        'sloodleawardsdeposit_currency',
                        'sloodleawardswithdraw_numpoints',
                        'sloodleawardswithdraw_currency'
		);
	}

    }

    /**
    * Defines a single slide from a presentation, containing raw data.
    * The data will usually need to interpreted by a slide plugin.
    * @package sloodle
    */
    class SloodleAwardTransaction
    {
    // FUNCTIONS //

        // Constructor
        function SloodleAwardTransaction($id=0, $trans=null, $avuuid='', $avname='',$userid=0,$itype='',$amount=0,$idata='')
        {
            $this->id = $id;
            $this->avuuid = $avuuid;
            $this->avname = $avname;
            $this->userid = $userid;
            $this->itype= $itype;
            $this->idata= $idata;
        }

    // DATA //

        /**
        * The ID of this transaction in the DB table of transactions.
        * @access public
        * @var int
        */
        var $id = 0;
    
        /**
        * The SloodleAwardTransaction object relating the presentation this slide is in
        * @access public
        * @var SloodleModulePresenter
        */
        var $trans = null;

        /**
        * The uuid of the user making the transaction
        * @access public
        * @var string
        */
        var $avuuid = '';

        /**
        * The avname for this transaction. 
        * @access public
        * @var string
        */
        var $avname = '';
        var $userid=0;
        var $itype='';
        var $amount=0;
        var $idata='';

    }
?>

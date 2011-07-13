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
            if (!($this->sloodle_module_instance = sloodle_get_record('sloodle', 'id', $this->cm->instance))) return false;
            // Load from the primary table: sloodle instance
            if (!($this->sloodle_instance = sloodle_get_record('sloodle', 'id', $this->cm->instance))) {
                sloodle_debug("Failed to load Sloodle module with instance ID #{$cm->instance}.<br/>");
                return false;
            }
            
            
            
            if ($this->sloodle_module_instance->type != SLOODLE_TYPE_AWARDS) return false;
            
            // Load from the secondary table: StipendGiver instance
            if (!($this->sloodle_awards_instance = sloodle_get_record('sloodle_awards', 'sloodleid', $this->cm->instance))) return false;
            
            return true;
        }
        
	function ProcessInteractions( $relevant_configs, $controllerid, $multiplier, $userid ) {

		global $CFG;

		// Find the active round for the controller, or make one if there isn't one.
		$timets = time();
		$roundrecs = sloodle_get_records_select('sloodle_award_rounds', "controllerid = $controllerid AND ( (timestarted <= $timets ) OR (timestarted = 0) ) AND ( (timeended >= $timets ) OR (timeended = 0) ) ");

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
			if ( !sloodle_insert_record('sloodle_award_rounds', $round) ) {
				return false;
			}
		}

		if (!$roundid = $round->id) {
			return false;
		}

  SloodleDebugLogger::log('DEBUG', "looking for relevant configs");
  SloodleDebugLogger::log('DEBUG', join('::', array_keys($relevant_configs)));

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

			if ( !sloodle_insert_record('sloodle_award_points', $award) ) {
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
			if ( !sloodle_insert_record('sloodle_award_points', $award) ) {
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
			$user_point_total_recs = sloodle_get_records_sql( "select sum(amount) as balance from {$CFG->prefix}sloodle_award_points where currencyid=$currencyid and roundid=$roundid and userid=$userid;");
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
?>

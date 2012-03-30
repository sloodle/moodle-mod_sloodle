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
        
	function ProcessActions( $relevant_configs, $controllerid, $multiplier, $userid, $useruuid, $objuuid) {

		global $CFG;

		$controller = new SloodleController();
		if (!$controller->load_by_course_module_id($controllerid)) {
			return false;
		}

		if (!$roundid = $controller->get_active_roundid(true)) {
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
			$user_point_total_recs = sloodle_get_records_sql_params( "select sum(amount) as balance from {$CFG->prefix}sloodle_award_points where currencyid=? and roundid=? and userid=?;", array($currencyid, $roundid, $userid));
			if (!$user_point_total_recs && (count($user_point_total_recs) == 0 ) ) {
				return false;
			}
			$first_rec = array_shift($user_point_total_recs);
			$balance = $first_rec->balance;

            // This sends a single points change notification to an object.
            // It's used by the shared media scoreboard to prompt a re-fetch of score data.
			SloodleActiveObject::NotifySubscriberObjects( 'awards_points_change', 10601, $controllerid, $userid, array('balance' => $balance, 'roundid' => $roundid, 'userid' => $userid, 'currencyid' => $currencyid, 'timeawarded' => $time ) );


		}
		
		return true;

	}

	function UserCurrencyBalance( $userid, $currencyid) {

		global $CFG;
		$userid = intval($userid);
		$currencyid = intval($currencyid);
		$balancesql = "select sum(amount) as balance from {$CFG->prefix}sloodle_award_points where userid = ? and currencyid = ?";
		$results = sloodle_get_records_sql_params( $balancesql, array($userid, $currencyid) );
		if (!$results || ( count($results) == 0) ) {
			  //SloodleDebugLogger::log('DEBUG', "nothing found for $balancesql");
			return 0;
		}
		$result = array_shift($results);
		  //SloodleDebugLogger::log('DEBUG', "balance for sql $balancesql was ".$result->balance);

		return $result->balance;

	}

	/*
	Returns an array of error messages for requirements that haven't been satisfied.
	...eg. If an object has been configured to require 3 gold coins, and the user doesn't have enough, it'll return a message saying you don't have enough gold coins. 
	*/
	function RequirementFailures( $relevant_configs, $controllerid, $multiplier, $userid, $useruuid ) {

  //SloodleDebugLogger::log('DEBUG', "in ProcessRequirements");
		global $CFG;

		$minimum_balances = array();

		$failures = array();

		if ( isset($relevant_configs['sloodleawardsrequire_numpoints']) && isset($relevant_configs['sloodleawardsrequire_currency']) ) {

			$numpoints  = intval($relevant_configs['sloodleawardsrequire_numpoints']); 
			$currencyid = intval($relevant_configs['sloodleawardsrequire_currency']);

			if ($currencyid && $numpoints) {
				if ( SloodleModuleAwards::UserCurrencyBalance($userid, $currencyid) < $numpoints ) {
					if (isset($relevant_configs['sloodleawardsrequire_notenoughmessage']) && $relevant_configs['sloodleawardsrequire_notenoughmessage'] != '') {
						$failures = array_merge( $failures, array($relevant_configs['sloodleawardsrequire_notenoughmessage']));
					} else {
						$failures = array_merge( $failures, array(get_string('awards:notenoughcurrency', 'sloodle')) );
					}
				}
			}

		} 

		if ( isset($relevant_configs['sloodleawardswithdraw_numpoints']) && isset($relevant_configs['sloodleawardswithdraw_currency']) ) {

			$numpoints  = intval($relevant_configs['sloodleawardswithdraw_numpoints']); 
			$currencyid = intval($relevant_configs['sloodleawardswithdraw_currency']);

			if ($currencyid && $numpoints) {
				if ( SloodleModuleAwards::UserCurrencyBalance($userid, $currencyid) < $numpoints ) {
					if (isset($relevant_configs['sloodleawardswithdraw_notenoughmessage']) && $relevant_configs['sloodleawardswithdraw_notenoughmessage'] != '') {
						$failures = array_merge( $failures, array($relevant_configs['sloodleawardswithdraw_notenoughmessage']));
					} else {
						$failures = array_merge( $failures, array(get_string('awards:notenoughcurrency', 'sloodle')) );
					}
				}
			}

		}

		return $failures;

	}
	
	/*
	An array of the names of config parameters that are understood by this module to mean it should do something.
	Will have the name of the specific interaction appended to it.
	eg. awards makes available an interaction config called "sloodleawardsdeposit_numpoints".
	    The quiz would then have a config name=>value pair like sloodleawards_deposit_numpoints_answerquestion => 3 
            Via the ActiveObject, the quiz will tell the awards module that answerquestion has happened to a particular user
            ...and the awards module will give them the points.
	*/
	function ActionConfigNames() {
		return array(
            'sloodleawardsdeposit_numpoints',
            'sloodleawardsdeposit_currency',
            'sloodleawardswithdraw_numpoints',
            'sloodleawardswithdraw_currency'
		);
	}

	/*
	An array of the names of config parameters that are understood by this module to check something before doing whatever it would normally do.
	Will have the name of the specific interaction appended to it.
	*/
	function RequirementConfigNames() {
		return array(
            'sloodleawardsrequire_numpoints',
            'sloodleawardsrequire_currency',
            'sloodleawardsrequire_notenoughmessage',
            'sloodleawardswithdraw_numpoints',
            'sloodleawardswithdraw_currency',
			'sloodleawardswithdraw_notenoughmessage'
		);
	}

        /**
        * Gets the short type name of this instance.
        * @return string
        */
        function get_type()
        {
            return 'awards';
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return get_string('modulename', 'awards');
        }



        /*
        Prepare a page full of scoreboard results and send it to the specified active objects.
        This was originally designed for the zztext scoreboard.
        If it finds a config parameter called sloodleactivepage it will limit to that page.
        */
        function PageScoreMessage( $aoarr, $notification_action, $success_code, $controllerid, $userid, $params, $addtimestampparams ) {

            global $CFG;

            if (count($aoarr) == 0) {
                return true;
            }


            $roundid = $params['roundid'];
            $currencyid = $params['currencyid'];
            $currencyname = '';

            if ($currencyid) {
                // Ge the name of the currency
                $currency_recs = sloodle_get_records_sql_params( "select id, name as currency_name from {$CFG->prefix}sloodle_currency_types where id = ?;", array($currencyid));
                $currency_rec = array_shift($currency_recs);
                $currencyname = $currency_rec->currency_name;
            }

            $user_point_total_recs = sloodle_get_records_sql_params( "select p.userid as userid, sum(amount) as balance, su.avname as avname, su.uuid as uuid from {$CFG->prefix}sloodle_award_points p inner join {$CFG->prefix}sloodle_users su on p.userid=su.userid where currencyid=? and roundid=? group by userid order by balance desc;", array($currencyid, $roundid));

            foreach($aoarr as $ao) {

                $response = new SloodleResponse();
                //$response->set_status_code($success_code);
                $response->set_status_code(1639271140);
                $response->set_status_descriptor('NOTIFICATION');
                $response->set_request_descriptor('NOTIFICATION');
                $response->set_http_in_password($ao->httpinpassword);

                $def = $ao->objectDefinition();
                $linesperpage = 10;
                if ( isset($def->fixed_parameters) && isset($def->fixed_parameters['linesperpage']) ) {
                    $linesperpage = $def->fixed_parameters['linesperpage'];
                }
                $charactersperline = 40;
                if ( isset($def->fixed_parameters) && isset($def->fixed_parameters['charactersperline']) ) {
                    $charactersperline = $def->fixed_parameters['charactersperline'];
                }

                $page = $ao->config_value( 'sloodleactivepage' );
                if (!$page) {
                    $page = 1;
                }

                $scoreboardtitle= $ao->config_value('sloodleobjecttitle');

                /*
                foreach($params as $n=>$v) {
                    $response->add_data_line($n.'|'.$v);
                }
                */

                $num_pages = ceil( count($user_point_total_recs) / $linesperpage );
                $response->add_data_line("status|$page|$num_pages|$scoreboardtitle||$currencyid|$currencyname");

                $offset = ( ($page-1) * $linesperpage );
                $page_points = array_slice( $user_point_total_recs, $offset, $linesperpage );
                foreach($page_points as $up) {
                    $uuid = $up->uuid;
                    $avname = $up->avname;  
                    $score = $up->balance;
                    $availablechars = $charactersperline - ( strlen($score) + 1 ); // leave room for a space folowed by the score
                    $displayavname = substr($avname, 0, $availablechars); // truncate the name if it's too long to fit.
                    $displayavname = str_pad( $displayavname, $availablechars, " ");
                    $displayline = $displayavname." ".$score;
                    $response->add_data_line("$uuid|$score|$displayline"); 
                }

                $renderStr="";
                $response->render_to_string($renderStr);

                // If this stuff fails, tough. We did our best.
                if ($resarr = $ao->sendMessage($renderStr, true)) {
                    if($resarr['info']['http_code'] == 200){
                        $ao->lastmessagetimestamp = time();
                        $ao->save();
                    }
                }

            }

            return true;

        }


}
?>

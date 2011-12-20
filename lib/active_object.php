<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    /**
    * Defines a structure to store information about an active object
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Edmund Edgar
    * @contributor Paul Preibisch
    * sloodle/lib/object_httpin_linker.php
    */

    /**
    * An active object, relating to the Sloodle active objects DB table.
    * @package sloodle
    */
    class SloodleActiveObject
    {
        /**
        * The UUID of this object.
        * @var string
        * @access public
        */
        var $uuid = '';

        /**
        * The ID of this object.
        * @var integer 
        * @access public
        */
        var $id = 0;

        /**
        * The name of this object.
        * @var string
        * @access public
        */
        var $name = '';

        /**
        * The password of this object.
	* Used for the server to check a message from the object is legitimate.
        * @var string
        * @access public
        */
        var $password = '';

        /**
        * The http-in password of this object.
	* Used for the object to check a message from the server is legitimate.
        * @var string
        * @access public
        */
        var $httpinpassword= '';

        /**
        * The type of this object. This corresponds to the mod/ directory its linker lives in.
        * @var string
        * @access public
        */
        var $type = '';

        /**
        * The code of this object. 
	* If we have multiple objects sharing the same linked, they will have different codes.	
	* Corresponds to the files inside object_definitions/
	* eg. Two quiz chairs, one of which was a rocket would both have the type of quiz-1.0
	* ...and be distinguished as 'quiz-chair' and 'quiz-rocket'.
	* NB For backwards compatibility, this can be undefined
	* ...in which case we'll expect a definition called 'default'.
        * @var string
        * @access public
        */
        var $object_code = null;

        /**
        * The course/controller which this object is authorised for.
        * @var SloodleCourse
        * @access public
        */
        var $course = null;

        /**
        * The user who authorised this object.
        * @var SloodleUser
        * @access public
        */
        var $user = null;

        /**
        * The httpin for this object
	* For SL, this will look like: http://sim5395.agni.lindenlab.com:12046/cap/e93d6ad8-b75d-83ff-dac2-979ec82633a1
        * @var string
        * @access public
        */
        var $httpinurl = null;

        /**
        * The layoutentryid this object was rezzed to represent, if there is one.
        * @var string
        * @access public
        */
        var $layoutentryid = null;

        /**
        * The rezzeruuid of the object that controls this object, if there is one.
        * @var string
        * @access public
        */
        var $rezzeruuid = null;

        /**
        * The position of the object relative to its rezzer, or the position the object should go to if it has just been configured.
        * @var string
        * @access public
        */
        var $position = null;

        /**
        * The rotation of the object relative to its rezzer, or the rotation the object should adopt if it has just been configured.
        * @var string
        * @access public
        */
        var $rotation = null;

        var $response = null;



	// The following functions are used to allow the Moodle server to connect to an OpenSim server through a tunnel or proxy.

	// For example, if your Moodle server is on the public internet, but your OpenSim server is behind a firewall...
	// ...your Moodle server will not usually be able to send HTTP-In messages to your OpenSim server.

	// You can work around this with a reverse SSH tunnel from your OpenSim server to your Moodle server...
	// ...so your Moodle server will send messages to a local port
	// ...which will then be forwarded through your SSH tunnel to your OpenSim server.

	// For now, we'll turn this on by define()ing a constant in sl_config. 
	// Ultimately, we may want to make this configurable for a particular controller or rezzer
	// ...as you may need different values for different OpenSim servers.
	function httpProxyURL() {
		if ( defined( 'SLOODLE_HTTP_IN_PROXY_OR_TUNNEL' ) ) {
			return SLOODLE_HTTP_IN_PROXY_OR_TUNNEL;
		}
		return null;
	}

	function objectDefinition() {

		if ($this->type == '') {
			return null;
		}
		
		return SloodleObjectConfig::ForObjectType( $this->type );

	}

        //sends a curl message to our objects httpinurl
        public function sendMessage($msg){

		SloodleDebugLogger::log('HTTP-IN', $msg);

                $ch = curl_init();    // initialize curl handle
                curl_setopt($ch, CURLOPT_URL, $this->httpinurl ); // set url to post to
                curl_setopt($ch, CURLOPT_FAILONERROR,0);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
                curl_setopt($ch, CURLOPT_TIMEOUT, 10); // times out after 4s
                curl_setopt($ch, CURLOPT_POST, 1); // set POST method
                curl_setopt($ch, CURLOPT_POSTFIELDS,$msg); // add POST fields
		if ($proxy = $this->httpProxyURL()) {
			curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 1);
			curl_setopt($ch, CURLOPT_PROXY, $this->httpProxyURL() ); 
		}

                $result = curl_exec($ch); // run the whole process
                $info = curl_getinfo($ch);
                curl_close($ch);
                return array('info'=>$info,'result'=>$result);
	}

	/*
	Request a list of inventory from the rezzer.
	NB The format is slightly different to the one used by the vending machine.
	$include_sloodle can be set to false to ignore things beginning with SLOODLE.
	Hopefully this will give us a list of third-party objects that we don't already know about.
	*/
	public function listInventory( $include_sloodle = true ) {

		$response = new SloodleResponse();
                $response->set_status_code(1);
                $response->set_status_descriptor('SYSTEM');
                $response->set_request_descriptor('LIST_INVENTORY');
                $response->add_data_line('do:list_inventory');

                //create message - NB for some reason render_to_string changes the string by reference instead of just returning it.
                $renderStr="";
                $response->render_to_string($renderStr);
                //send message to httpinurl
                $reply = $this->sendMessage($renderStr);

		if ( !( $reply['info']['http_code'] == 200 ) ) {
			return false;
		}

		$result = $reply['result'];

		$ret = array();

		$lines = explode("\n", $result);
		array_shift($lines);
		foreach($lines as $l) {
			if (!$include_sloodle) {
				if (preg_match('/^SLOODLE/', $l)) {
					continue;
				}
			}
			$ret[] = $l;
		}	

		return $ret;

	}

	// Sends a message to the object telling it to derez itself.
	// Deletes the active_object record if successful.
	// NB the object can't report back whether it successfully derezzed itself, because it no longer exists.	
	// We'll go by whether it acknowledged the derez command, which is as close as we can get.
	// Return true on success, false on failure
	public function deRez() {

		if (!$this->httpinurl) {
			return false;
		}
		//build response string
		$response = new SloodleResponse();
		$response->set_status_code(1);
		$response->set_status_descriptor('SYSTEM');
		$response->set_request_descriptor('DEREZ');
		$response->set_http_in_password($this->httpinpassword);
		$response->add_data_line('do:derez');

		//create message - NB for some reason render_to_string changes the string by reference instead of just returning it.
		$renderStr="";
		$response->render_to_string($renderStr);
		//send message to httpinurl
		$reply = $this->sendMessage($renderStr);
		if ( !( $reply['info']['http_code'] == 200 ) ) {
			return false;
		}

		return $this->delete();

	}

	// Sends a message to the object telling it to refresh its configuration.
	// Return true on success, false on failure
	public function refreshConfig() {

		if (!$this->httpinurl) {
			return false;
		}
		//build response string
		$response = new SloodleResponse();
		$response->set_status_code(1);
		$response->set_status_descriptor('SYSTEM');
		$response->set_request_descriptor('REFRESH_CONFIG');
		$response->add_data_line('do:requestconfig');

		//create message - NB for some reason render_to_string changes the string by reference instead of just returning it.
		$renderStr="";
		$response->render_to_string($renderStr);
		//send message to httpinurl
		$reply = $this->sendMessage($renderStr);
		if ( !( $reply['info']['http_code'] == 200 ) ) {
			return false;
		}

		return true;

	}


        /*
        * writes config data to a response object, and sends it this objects httpinurl
        * @var $extraParameters array()
        *
        */
        public function sendConfig( $extraParameters = NULL ){//inside active_object.php
		global $CFG;
            //construct the body
           if ($extraParameters === NULL) {
               $extraParameters = array();
            }
            //build response string
            $response = new SloodleResponse();
            $response->add_data_line(array('set:sloodlecontrollerid', $this->controllerid));
            $response->add_data_line(array('set:sloodlecoursename_short', $this->course->get_short_name()));
            $response->add_data_line(array('set:sloodlecoursename_full', $this->course->get_short_name()));
            $response->add_data_line(array('set:sloodlepwd', $this->uuid.'|'.$this->password)); // NB We need to prepend the UUID - otherwise Sloodle treats it like a prim password
            $response->add_data_line(array('set:sloodleserverroot', $CFG->wwwroot));
            $response->add_data_line(array('set:sloodleobjtype', $this->type));
	    if ($this->layoutentryid) {
		    $response->add_data_line(array('set:position', $this->position, $this->rotation, $this->rezzeruuid));
		    //$response->add_data_line(array('set:rezzeruuid', $this->rezzeruuid));
		    //$response->add_data_line(array('set:rotation', $this->rotation));
		    $response->add_data_line(array('set:layoutentryid', $this->layoutentryid));
	    }
            //search for setings for this object
            $settings = sloodle_get_records('sloodle_object_config', 'object', $this->id);
             if (!$settings) {
                // Error: no configuration settings... there should be at least one indicating the type
/*
                $response->set_status_code(-103);
                $response->set_status_descriptor('SYSTEM');
                $response->add_data_line('Object not configured yet.');
                $renderStr="";
                //create message
                $response->render_to_string($renderStr);
                //send message to httpinurl
                return $this->sendMessage($renderStr);
*/
            }
            $layoutentry = NULL;
            $position = NULL;
            $rotation = NULL;
            // Output each setting
            foreach ($settings as $s) {
                $response->add_data_line(array('set:'.$s->name, $s->value));
            }//end foreach
            foreach( $extraParameters as $n => $v) {
                $response->add_data_line( 'set:'.$n.'|'.$v );
            }//endforeach
            $response->set_status_code(1);

	    /*
	    If we send the object a CONFIG_PERSISTENT descriptor, it will keep the config and use it if re-rezzed or copied.
	    This is set in sl_config.php.
	    Normally this would be on, but if you're developing a set to give to other people, you want it off
	    Otherwise it will use your server details, rather than getting new ones.
	    */
	    $request_descriptor = SLOODLE_ENABLE_OBJECT_PERSISTANCE ? 'CONFIG_PERSISTENT' : 'CONFIG';
            $response->set_status_descriptor('CONFIG');
            $response->set_request_descriptor($request_descriptor);
            $response->set_http_in_password($this->httpinpassword);
            $renderStr="";
            $response->render_to_string($renderStr);
            //curl send this to our object's httpinurl


            return $this->sendMessage( $renderStr );
        }

	// Deletes a record from the active object table.
	// Returns true on success.
	// NB If you need to get rid of the record from world as well, use deRez(). 
	// deRez will call this function in turn.
	public function delete() {

 	    if (!$this->id) {
	        return false;
	    } 

            // Delete all config entries and the object record itself
            return ( sloodle_delete_records('sloodle_object_config', 'object', $this->id) && sloodle_delete_records('sloodle_active_object', 'id', $this->id) );

	}

        public function save(){
           //write local data to a new or existing record
           //search for id
           //if exists update
           $result = sloodle_get_record("sloodle_active_object",'id',$this->id);
           if (!$result ) {
                //id,controllerid,userid,uuid,password,name,type,timeupdated
                    // No - insert a new record
                    $result = new stdClass();
                    $result->controllerid = $this->controllerid;
                    $result->userid = $this->userid;
                    $result->uuid = $this->uuid;
                    $result->httpinurl = $this->httpinurl;
                    $result->httpinpassword = $this->httpinpassword;
                    $result->position = $this->position;
                    $result->rotation = $this->rotation;
                    $result->rezzeruuid = $this->rezzeruuid;
                    $result->layoutentryid = $this->layoutentryid;
                    $result->password = $this->password;
                    $result->name = $this->name;
                    $result->type = $this->type;
                    $result->mediakey = $this->mediakey;
                    $result->lastmessagetimestamp = $this->lastmessagetimestamp;
                    $success = sloodle_insert_record('sloodle_active_object', $result );

           }//endif
           else {
                    $result->controllerid = $this->controllerid;
                    $result->userid = $this->userid;
                    $result->uuid = $this->uuid;
                    $result->httpinurl = $this->httpinurl;                    
                    $result->position = $this->position;
                    $result->rotation = $this->rotation;
                    $result->rezzeruuid = $this->rezzeruuid;
                    $result->layoutentryid = $this->layoutentryid;
                    $result->password = $this->password;
                    $result->name = $this->name;
                    $result->type = $this->type;
                    $result->httpinpassword = $this->httpinpassword;
                    $result->mediakey = $this->mediakey;
                    $result->lastmessagetimestamp = $this->lastmessagetimestamp;
                    if (sloodle_update_record('sloodle_active_object', $result)) $success = $result->id;
           }//end else

	    $this->course = new SloodleCourse();
	    $this->course->load_by_controller($this->controllerid);


           return $success;
        }//end function

        // Load data for the specified id
        // Return true on success, false on fail
        public function load( $id) {

            $rec = sloodle_get_record('sloodle_active_object','id',$id);

            if ($rec) {
                $this->loadFromRecord($rec);

                return true;

            }

            return false;

        }

        // Load data for the specified UUID
        // Return true on success, false on fail
        public function loadByUUID( $uuid ) {

		//SloodleDebugLogger::log('DEBUG', "loading for uuid :$uuid:");
            $rec = sloodle_get_record('sloodle_active_object','uuid',$uuid);

            if ($rec) {
		//SloodleDebugLogger::log('DEBUG', "loaded for uuid :$uuid:");
                $this->loadFromRecord($rec);
                return true;
            }

            return false;

        }

        public function loadFromRecord($rec) {
           $this->id = $rec->id;
           $this->controllerid = $rec->controllerid;
           $this->userid = $rec->userid;
           $this->uuid = $rec->uuid;
           $this->password = $rec->password;
           $this->name = $rec->name;
           $this->type = $rec->type;
           $this->timeupdated = $rec->timeupdated;
           $this->httpinurl = $rec->httpinurl;
	   $this->httpinpassword = $rec->httpinpassword;
           $this->layoutentryid = $rec->layoutentryid;
           $this->position = $rec->position;
           $this->rotation = $rec->rotation;
           $this->rezzeruuid = $rec->rezzeruuid;
	   $this->mediakey = $rec->mediakey;
	   $this->lastmessagetimestamp = $rec->lastmessagetimestamp;

	   // TODO: This is probably mostly not needed.
           // We should fetch this lazily when we need the course name or whatever it is we want here.
           $this->course = new SloodleCourse();
           $this->course->load_by_controller($this->controllerid);

 	   return true;

        }

	// Configures an activeobject for its layoutentryid, which should already have been set, if there is one.
        // TODO: This functionality is partially duplicated in controller->configure_object_from_layout_entry($authid, $layout_entry_id, $rezzeruuid = null) 
	// Remove it from there, and do it all here.
	// NB This doesn't actually send the config to the object - you need to call sendConfig separately to do that.
	public function configure_for_layout() {

		// We should already have been inserted when this gets called.
		if (!$id = $this->id) {
			return false;
		}

		if (!$layoutentryid = $this->layoutentryid) {
			return false;
		}

		$existingconfigs = $this->config_name_config_hash();
		$done_configs = array();

		$configs = sloodle_get_records('sloodle_layout_entry_config','layout_entry', $layoutentryid);
		$ok = true;
		if (count($configs) > 0) {
			foreach($configs as $config) {
				$name = $config->name;
				if ( isset($existingconfigs[ $name ])) {
					// No change
					if ($existingconfigs[ $name ]->value == $config->value) {
						$done_configs[ $name ] = true;
						continue;
					} else {
						$updated_config = $existingconfigs[ $name ];
						$updated_config->value = $config->value;
						sloodle_update_record( 'sloodle_object_config', $updated_config);
						$done_configs[ $name ] = true;
					}
				} else {
					$config->id = null;
					$config->object = $this->id;
					if (!sloodle_insert_record('sloodle_object_config',$config)) {
						$ok = false;
					}
				}
			}
		}

		// Original configs that are no longer in the layout, so we'll kill them.
		if (count($existingconfigs) > 0) {
			foreach($existingconfigs as $config) {
				if (!isset($done_configs[ $config->name ] )) {
					sloodle_delete_records('sloodle_object_config', 'id', $config->id);
				}
			}	
		}

		return $ok;
            
	}
           
        /**
        * Updates the last active timer on an object.
        * @return bool True if successful, or false if not.
	* Replaces controller->ping_object().
        */
	public function recordAccess() {
	   if (!$this->id) {
		return false;
	   }
            $this->timeupdated = time();
            return sloodle_update_record('sloodle_active_object', $this);
	}

	public function config_value( $name ) {
		if ($config = sloodle_get_record('sloodle_object_config', 'object', $this->id, 'name', $name)) {
			return $config->value;
		}
		$config = sloodle_get_record('sloodle_object_config', 'object', $this->id);

		return null;
	}


	public function requirement_failures( $interaction, $multiplier, $userid, $useruuid) {

		if ( !$userid = intval($userid) ) {
			return array();
		}

		if ( $multiplier == 0 ) {
			return array();
		}

		if (!$controllerid = intval($this->controllerid) ) {
			return array();
		}

		$all_configs = sloodle_get_records('sloodle_object_config', 'object', $this->id);
		if (count($all_configs) == 0) {
			// Nothing to do here
			return array();
		}

		$all_module_classes = sloodle_available_modules();
		if (count($all_module_classes) == 0) {
			return array();
		}

		$failures = array();

		foreach($all_module_classes as $module_class) {

			// Find each of the tasks we have to handle for the interaction.
			// This information is stored in the object config
			$relevant_configs = array();

			if (!method_exists($module_class,'RequirementConfigNames')) {
				continue;
			}

			$relevant_config_names = call_user_func(array($module_class, 'RequirementConfigNames'));
			if (count($relevant_config_names) == 0) {
				continue;
			}

			foreach($relevant_config_names as $configname) {
				$fieldname = $configname.'_'.$interaction;
				foreach($all_configs as $c) {
					if ($c->name == $fieldname) {
						$relevant_configs[ $configname] = $c->value;
					}				
				}
			}

			if (count($relevant_configs) == 0) {
				// Nothing to do here
				continue;
			}

			SloodleDebugLogger::log('DEBUG', "about to check RequirementFailures for $module_class, ".join($relevant_configs,':') );

			$module_failures = call_user_func_array( array($module_class, 'RequirementFailures'), array( $relevant_configs, $controllerid, $multiplier, $userid, $this->uuid ));
			SloodleDebugLogger::log('DEBUG', "done checking RequirementFailures for $module_class");

			if($module_failures) {
				$failures = array_merge($failures, $module_failures);
			}
		}
		SloodleDebugLogger::log('DEBUG', "done checking all RequirementFailures ");

		return $failures;

	}

	/*
	Modules (awards, tracker etc) may specify that they can handle certain kinds of events.
	The object can be configred to trigger those events when particular interactions happen. 
	For example, the awards module has an event called "sloodleawardsdeposit_numpoints".
	If this is called, we should give the user that number of points.
	*/
	public function process_interaction( $interaction, $multiplier, $userid, $useruuid ) {


		if ( !$userid = intval($userid) ) {
			return false;
		}

		if ( $multiplier == 0 ) {
			return false;
		}

		if (!$controllerid = intval($this->controllerid) ) {
			return false;
		}
		$all_configs = sloodle_get_records('sloodle_object_config', 'object', $this->id);
		if (count($all_configs) == 0) {
			return true;
		}

		$all_module_classes = sloodle_available_modules();

		foreach($all_module_classes as $module_class) {

			if (!class_exists($module_class)) {
				continue;
			}

			if (!method_exists($module_class, 'ActionConfigNames')) {
				continue;
			} 

			// Find each of the tasks we have to handle for the interaction.
			// This information is stored in the object config
			$relevant_configs = array();

			$relevant_config_names = call_user_func(array($module_class, 'ActionConfigNames'));
			if (count($relevant_config_names) == 0) {
				continue;
			}
			/*
			$relevant_config_names = array( 
				'sloodleawardsdeposit_numpoints', 
				'sloodleawardsdeposit_currency', 
				'sloodleawardswithdraw_numpoints', 
				'sloodleawardswithdraw_currency'
			);
			*/

			foreach($relevant_config_names as $configname) {
				$fieldname = $configname.'_'.$interaction;
				foreach($all_configs as $c) {
					if ($c->name == $fieldname) {
						$relevant_configs[ $configname] = $c->value;
					}				
				}
			}

			if (count($relevant_configs) == 0) {
				// Nothing to do here
				continue;
			}

			if (!method_exists($module_class, 'ProcessActions')) {
				continue;
			} 

			call_user_func_array( array($module_class, 'ProcessActions'), array( $relevant_configs, $controllerid, $multiplier, $userid, $useruuid, $this->uuid ));

		}

		return true;

	}

        function HandleObjectCacheCallbacks( $notification_action, $success_code, $controllerid, $userid, $params, $addtimestampparams ) {

		global $CFG;

		// No cache dir defined, nothing to do.
		if ( ( !defined('SLOODLE_STATIC_CACHE_DIRROOT') ) || ( SLOODLE_STATIC_CACHE_DIRROOT == '') ) {
			return true;
		}

		$interested_object_types = SloodleObjectConfig::TypesOfObjectsRequiringCacheCallbacks( $notification_action );

		//$interested_object_types = array('SLOODLE Scoreboard'=>[Object Definition]);
		if (count($interested_object_types) == 0) {
			// nobody cares, we're done..
			return true;
		}

		$instr = '';
		$delim = '';
		$queryparams = array(intval($controllerid));
		foreach($interested_object_types as $ot) {
			$queryparams[] = $ot;
			$instr .= $delim.'?';
			$delim = ',';
		}
		$queryparams[] = time() - (3600+600); // Ping time and then some. All objects that are alive should have updated within this time.
		$sql = "select a.* from {$CFG->prefix}sloodle_active_object a inner join {$CFG->prefix}sloodle_object_config c on a.id=c.object where c.name='controllerid' and c.value=? and a.httpinurl IS NOT NULL and a.type in ($instr) and a.timeupdated>? order by a.timeupdated desc;";
		$recs = sloodle_get_records_sql_params($sql, $queryparams);


		foreach($recs as $rec) {
			$obj = new SloodleActiveObject();
			$obj->loadFromRecord($rec);
			$obj->handleCacheCallback( $notification_action, $success_code, $controllerid, $userid, $params, $addtimestampparams ); 
		}

		return true;

	}

	function handleCacheCallback( $notification_action, $success_code, $controllerid, $userid, $params, $addtimestampparams ) {

		if (!$def = $this->objectDefinition()) {
			return false;
		}

		$cache_path = $def->cache_include_path();
		if (!file_exists($cache_path)) {
			return false;
		}
		include $cache_path;

	}

	function write_cache_output( $output, $filename ) {

		if ( ( !defined('SLOODLE_STATIC_CACHE_DIRROOT') ) || ( SLOODLE_STATIC_CACHE_DIRROOT == '') ) {
			return false;
		}

		if (!$def = $this->objectDefinition()) {
			return false;
		}

		$cache_path = SLOODLE_STATIC_CACHE_DIRROOT.'/'.$this->uuid.'/'.$def->cache_directory_suffix();
		if (!file_exists($cache_path)) {
			if (!mkdir($cache_path, 0755, true)) {
				return false;
			}
		}

		$fp = fopen($cache_path.'/'.$filename, "w");
		flock($fp,LOCK_SH); 
		$written = fputs($fp, $output); 
		fclose($fp);
		
		return $written;

	}

	/*
	Notify any active objects that are interested in the action $action.
	...so that an object can tell us what it's interested in hearing about.
	*/
	function NotifySubscriberObjects( $notification_action, $success_code, $controllerid, $userid, $params, $addtimestampparams ) {

		global $CFG;

		$interested_object_types = SloodleObjectConfig::TypesOfObjectsRequiringNotification( $notification_action );

		//$interested_object_types = array('SLOODLE Scoreboard');
		if (count($interested_object_types) == 0) {
			// nobody cares, we're done..
			return true;
		}


		$instr = '';
		$delim = '';
		$queryparams = array(intval($controllerid));
		foreach($interested_object_types as $ot) {
			$queryparams[] = $ot;
			$instr .= $delim.'?';
			$delim = ',';
		}
		$queryparams[] = time() - (3600+600); // Ping time and then some. All objects that are alive should have updated within this time.
		$sql = "select a.* from {$CFG->prefix}sloodle_active_object a inner join {$CFG->prefix}sloodle_object_config c on a.id=c.object where c.name='controllerid' and c.value=? and a.httpinurl IS NOT NULL and a.type in ($instr) and a.timeupdated>? order by a.timeupdated desc;";
		$recs = sloodle_get_records_sql_params($sql, $queryparams);

		$msg = "$success_code\n"; 
		
		// Check if there's a function that allows us to create caching json

		foreach($recs as $rec) {
			$ao = new SloodleActiveObject();
			$ao->loadFromRecord( $rec );

			$response = new SloodleResponse();
			$response->set_status_code($success_code);
			$response->set_status_descriptor('AWARDS');
			$response->set_request_descriptor('UPDATE_SCOREBOARD');
			$response->set_http_in_password($ao->httpinpassword);

			foreach($params as $n=>$v) {
				$response->add_data_line($n.'|'.$v);
			}

			// We can set extra fields to allow the object to keep track of messages being sent.
			// That way if a message fails to get delivered, the lastmessagesendtimestamp won't match what the object remembers
			// ...and the object will know it needs to do something to catch up, like polling the server.
			$ts = time();
			if ($addtimestampparams) {
				$response->add_data_line("lastmessagetimestamp|".$ao->lastmessagetimestamp);
				$response->add_data_line("messagetimestamp|".$ts);
			}

			$renderStr="";
			$response->render_to_string($renderStr);

			// If this stuff fails, tough. We did our best.
			if ($resarr = $ao->sendMessage($renderStr)) {
				if($resarr['info']['http_code'] == 200){
					$ao->lastmessagetimestamp = time();
					$ao->save();
				}
			}
		}

		return true;
		
	}

	// An array of config objects, keyed by config name
        function config_name_config_hash() {
	
		$id = $this->id;	

		// If the ID is empty, then we have no configuration settings to get
		if (empty($id)) return array();

		$recs = sloodle_get_records('sloodle_object_config', 'object', $id);
		if (!$recs) return false;

		$config = array();
		foreach ($recs as $r) {
			$config[$r->name] = $r;
		}
		return $config;

	}

	// An array of config values, keyed by config name
        function config_name_value_hash() {
	
		if (!$config_hash = $this->config_name_config_hash()) {
			return false;
		}

		if (count($config_hash) == 0) {
			return array();
		}

		$config = array();
		foreach ($config_hash as $r) {
			$config[$r->name] = $r->value;
		}

		return $config;

	}

	function has_custom_config() {

		return ( $this->objectDefinition() != null );
		
	}
    }

?>

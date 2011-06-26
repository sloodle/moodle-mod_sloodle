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
        * The name of this object.
        * @var string
        * @access public
        */
        var $name = '';

        /**
        * The password of this object.
        * @var string
        * @access public
        */
        var $password = '';

        /**
        * The type of this object.
        * @var string
        * @access public
        */
        var $type = '';

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

        //sends a curl message to our objects httpinurl
        public function sendMessage($msg){
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
            $response->add_data_line(array('set:position', $this->position, $this->rotation, $this->rezzeruuid));
            //$response->add_data_line(array('set:rezzeruuid', $this->rezzeruuid));
            //$response->add_data_line(array('set:rotation', $this->rotation));
            $response->add_data_line(array('set:layoutentryid', $this->layoutentryid));
            //search for setings for this object
            $settings = get_records('sloodle_object_config', 'object', $this->id);
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
            $response->set_status_descriptor('OK');
            $renderStr="";
            $response->render_to_string($renderStr);
            //curl send this to our object's httpinurl

            SloodleDebugLogger::log('HTTP-IN', $renderStr);

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
            return ( delete_records('sloodle_object_config', 'object', $this->id) && delete_records('sloodle_active_object', 'id', $this->id) );

	}

        public function save(){
           //write local data to a new or existing record
           //search for id
           //if exists update
           $result = get_record("sloodle_active_object",'id',$this->id);
           if (!$result ) {
                //id,controllerid,userid,uuid,password,name,type,timeupdated
                    // No - insert a new record
                    $result = new stdClass();
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
                    $success = insert_record('sloodle_active_object', $result );

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
                    $result->httpinurl = $this->httpinurl;
                    if (update_record('sloodle_active_object', $result)) $success = $result->id;
           }//end else

	    $this->course = new SloodleCourse();
	    $this->course->load_by_controller($this->controllerid);


           return $success;
        }//end function

        // Load data for the specified id
        // Return true on success, false on fail
        public function load( $id) {

            $rec = get_record('sloodle_active_object','id',$id);

            if ($rec) {
                $this->loadFromRecord($rec);
                return true;
            }

            return false;

        }

        // Load data for the specified UUID
        // Return true on success, false on fail
        public function loadByUUID( $uuid ) {

            $rec = get_record('sloodle_active_object','uuid',$uuid);

            if ($rec) {
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
           $this->layoutentryid = $rec->layoutentryid;
           $this->position = $rec->position;
           $this->rotation = $rec->rotation;
           $this->rezzeruuid = $rec->rezzeruuid;
        }
    }



?>

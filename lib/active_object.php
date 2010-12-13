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
        * @var string
        * @access public
        */
        var $response = null;
        var $httpinurl = null;

        //sends a curl message to our objects httpinurl
        public function sendMessage($msg){
                $ch = curl_init();    // initialize curl handle
                curl_setopt($ch, CURLOPT_URL,$this->httpinurl); // set url to post to
                curl_setopt($ch, CURLOPT_FAILONERROR,0);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
                curl_setopt($ch, CURLOPT_TIMEOUT, 10); // times out after 4s
                curl_setopt($ch, CURLOPT_POST, 1); // set POST method
                curl_setopt($ch, CURLOPT_POSTFIELDS,$msg); // add POST fields
                $result = curl_exec($ch); // run the whole process
                $info = curl_getinfo($ch);
                curl_close($ch);
                return array('info'=>$info,'result'=>$result);
            }
        /*
        * writes config data to a response object, and sends it this objects httpinurl
        * @var $extraParameters array()
        *
        */
        public function sendConfig( $extraParameters = NULL ){//inside active_object.php
            //construct the body
           if ($extraParameters === NULL) {
               $extraParameters = array();
            }
            //build response string
            $response = new SloodleResponse();
            $response->add_data_line(array('set:sloodlecontrollerid', $this->controllerid));
            $response->add_data_line(array('set:sloodlecoursename_short', $this->course->get_short_name()));
            $response->add_data_line(array('set:sloodlecoursename_full', $this->course->get_short_name()));
            $response->add_data_line(array('set:sloodlepwd', $this->password));
            $response->add_data_line(array('set:sloodleserverroot', SLOODLE_WWWROOT));
            //search for setings for this object
            $settings = get_records('sloodle_object_config', 'object', $this->id);
             if (!$settings) {
                // Error: no configuration settings... there should be at least one indicating the type
                $response->set_status_code(-103);
                $response->set_status_descriptor('SYSTEM');
                $response->add_data_line('Object not configured yet.');
                $renderStr="";
                //create message
                $response->render_to_string($renderStr);
                //send message to httpinurl
                $this->sendMessage($renderStr);
                return;
            }
            $layoutentry = NULL;
            $position = NULL;
            $rotation = NULL;
            // Output each setting
            foreach ($settings as $s) {
                $response->add_data_line(array('set:'.$s->name, $s->value));
                if ($s->name == 'sloodlelayoutentryid') {
                    $layoutentryid = $s->value;
                    //get position and rotation
                    $layoutentry = get_record('sloodle_layout_entry','id',$layoutentryid);
                    //   sloodle_layout_entry id,layout,name,position,rotation
                    if ($layoutentry){
			$rezzeruuid = ( isset( $extraParameters['sloodlerezzeruuid'] ) ? $extraParameters['sloodlerezzeruuid'] : '' );
			$response->add_data_line("set:position|{$layoutentry->position}|{$layoutentry->rotation}|$rezzeruuid");
                    } //endif
                }//endif
            }//end foreach
            foreach( $extraParameters as $n => $v) {
                $response->add_data_line( 'set:'.$n.'|'.$v );
            }//endforeach
            $response->set_status_code(1);
            $response->set_status_descriptor('OK');
            $renderStr="";
            $response->render_to_string($renderStr);
            //curl send this to our object's httpinurl
            return $this->sendMessage( $renderStr );
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
        }
    }



?>

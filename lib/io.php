<?php
    // This file is part of the Sloodle project (www.sloodle.org) and is released under the GNU GPL v3.
    
    /**
    * Sloodle input/output library.
    *
    * Provides general request and response functionality for interacting with in-world LSL scripts.
    *
    * @package sloodle
    * @copyright Copyright (c) 2007-8 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    * @since Sloodle 0.2
    *
    * @contributor Peter R. Bloomfield
    *
    */
            

    // NOTE: this file requires that the Sloodle "config.php" file already be included
    
    /** Include our general library. */
    require_once(SLOODLE_DIRROOT . '/lib/general.php');
    
          
    /** Defines the HTTP parameter name for a Sloodle password. */
    define('SLOODLE_PARAM_PASSWORD', 'sloodlepwd');
    /** Defines the HTTP parameter name for a course ID. */
    define('SLOODLE_PARAM_COURSE_ID', 'sloodlecourseid');
    /** Defines the HTTP parameter name for a Sloodle controller ID. */
    define('SLOODLE_PARAM_CONTROLLER_ID', 'sloodlecontrollerid');
    /** Defines the HTTP parameter name for a module ID. */
    define('SLOODLE_PARAM_MODULE_ID', 'sloodlemoduleid');
    /** Defines the HTTP parameter name for an avatar UUID. */
    define('SLOODLE_PARAM_AVATAR_UUID', 'sloodleuuid');
    /** Defines the HTTP parameter name for an avatar name. */
    define('SLOODLE_PARAM_AVATAR_NAME', 'sloodleavname');
    
    /** Defines the HTTP parameter name for a request descriptor. */
    define('SLOODLE_PARAM_REQUEST_DESC', 'sloodlerequestdesc');
    /** Defines the HTTP parameter name for indicating a request which relates to an object instead of a user. */
    define('SLOODLE_PARAM_IS_OBJECT', 'sloodleisobject');
    /** Defines the HTTP parameter name for specifying server access level. */
    define('SLOODLE_PARAM_SERVER_ACCESS_LEVEL', 'sloodleserveraccesslevel');

    
    /**
    * A helper class to validate and structure data for output according to the {@link http://slisweb.sjsu.edu/sl/index.php/Sloodle_communications_specification Sloodle communications specification}.
    * @package sloodle
    */
    class SloodleResponse
    {
      // DATA //
      
        /**
        * The separation string between lines of the response (typically just a newline).
        * @var string
        * @access private
        */
        var $line_separator = "\n";
        
        /**
        * The separation string between fields of a response line (by default, a pipe character |).
        * @var string
        * @access private
        */
        var $field_separator = "|";
      
        /**
        * Integer status code of the response.
        * Refer to the {@link http://slisweb.sjsu.edu/sl/index.php/Sloodle_status_codes status codes} page on the Sloodle wiki for a reference.
        * <b>Required.</b>
        * @var int
        * @access private
        */
        var $status_code = null;
        
        /**
        * Status descriptor string.
        * Should contain a generalised description/category of the status code.
        * <b>Optional but recommended. Ignored if null.</b>
        * @var string
        * @access private
        */
        var $status_descriptor = null;
        
        /**
        * Integer side effect(s) codes.
        * Status code(s) of side effect(s) incurred during the operation.
        * Can be a single integer, or an array of integers.
        * <b>Optional. Ignored if null.</b>
        * @var mixed
        * @access private
        */
        var $side_effects = null;
        
        /**
        * Request descriptor.
        * A brief string passed into the request by an LSL script (via HTTP parameter 'sloodlerequestdesc'),
        * which is returned so that it can correctly distinguish one request from anotehr.
        * <b>Optional. Ignored if null.</b>
        * @var string
        * @access private
        */
        var $request_descriptor = null;
        
        /**
        * Timestamp when the request was originally made by the LSL script.
        * This is <i>not</i> filled-in automatically. You must do it manually if you need it.
        * <b>Optional. Ignored if null.</b>
        * @var integer
        * @access private
        */
        var $request_timestamp = null;
        
        /**
        * Timestamp when the response was generated on the Moodle site.
        * This is <i>not</i> filled-in automatically. You must do it manually if you need it.
        * <b>Optional. Ignored if null.</b>
        * @var integer
        * @access private
        */
        var $response_timestamp = null;
        
        /**
        * Avatar UUID.
        * Should be a string specifying the UUID key of the agent in-world being handled. (Typically of the user who initiated the request).
        * <b>Optional. Ignored if null.</b>
        * @var string
        * @access private
        */
        var $avatar_uuid = null;
        
        /**
        * Tracking code of the request.
        * Use of this value is undefined. Please do not use it.
        * <b>Optional. Ignored if null.</b>
        * @var mixed
        * @access private
        */
        var $tracking_code = null;
        
        /**
        * Total number of pages.
        * If a response requires multiple pages, this value indicates how many pages there are.
        * <b>Optional, unless $page_number is specified. Ignored if null.</b> <i>Not yet supported.</i>
        * @var integer
        * @access private
        */
        var $page_total = null;
        
        /**
        * Current page number.
        * If a response requires multiple pages, this value indicates which page is being returned in this response.
        * <b>Optional, unless $page_total is specified. Ignored if null.</b> <i>Not yet supported.</i>
        * @var integer
        * @access private
        */
        var $page_number = null;
        
        /**
        * HTTP-In password
        * Used when sending an http-in message to an object.
        * Allows the object to confirm that we are authorized to talk to it.
        * @var string 
        * @access private
        */
        var $http_in_password= null;
     
        /**
        * Return URL
        * Used when sending a one-way message, where you want a reply to be sent somewhere.
        * This is intended to be used in situations where we can't make http-in reqests to the grid
        * ...and we instead queue them on the server and have a process in SL/OpenSim to pass them on.
        * @var string
        * @access private
        */
        var $return_url = null;
 

        /**
        * Data to render following the status line in the response.
        * This value can either be a scalar (single value, e.g. int, string, float), or an array.
        * If it is a single scalar, it is rendered as a single line.
        * If it is an array, then each element becomes one line.
        * If an element is a scalar, then it is directly output onto the line.
        * If an element is an array, then each child element is output as a separate field on the same line.
        * <b>Optional. Ignored if null.</b>
        * @see SloodleResponse::set_data()
        * @see SloodleResponse::add_data_line()
        * @see SloodleResponse::clear_data()
        * @var mixed
        * @access private
        */
        var $data = null;
        
    
      // ACCESSORS //
    
    
        /**
        * Sets the line separator.
        * @param string $sep A string to separate lines
        * @return void
        */
        function set_line_separator($sep)
        {
            $this->line_separator = $sep;
        }
        
        /**
        * Gets the line separator.
        * @return string The current line separator string
        */
        function get_line_separator()
        {
            return $this->line_separator;
        }
        
        
        /**
        * Sets the field separator.
        * @param string $sep A string to separate fields
        * @return void
        */
        function set_field_separator($sep)
        {
            $this->field_separator = $sep;
        }
        
        /**
        * Gets the field separator.
        * @return string The current field separator string
        */
        function get_field_separator()
        {
            return $this->field_separator;
        }
        
    
        /**
        * Accessor function to set member value {@link $status_code}
        * @param integer $par A non-zero status code
        * @return void
        */
        function set_status_code($par)
        {
            // Validate
            if (is_int($par) == false || $par == 0) {
                $this->_internal_validation_error("Sloodle - LSL response: invalid status code specified; should be non-zero integer", 0);
            }
            // Store
            $this->status_code = $par;
        }
    
        /**
        * Accessor function to set member value {@link $status_descriptor}
        * @param mixed $par A status descriptor string, or null to clear it
        * @return void
        */
        function set_status_descriptor($par)
        {
            // Validate
            if (is_string($par) == false && is_null($par) == false) {
                $this->_internal_validation_error("Sloodle - LSL response: invalid status descriptor specified; should be a string or null", 0);
            } else {
                $this->status_descriptor = $par;
            }
        }
    
        /**
        * Accessor function to set member value {@link $side_effects}. <b>Note:</b> it is recommended that you use {@link add_side_effect()} or {@link add_side_effects()} instead.
        * @param mixed $par An integer side effect code, an array of integer side effect codes, or null to clear it
        * @return void
        */
        function set_side_effects($par)
        {
            // We'll use a variable to store the validity
            $valid = true;
            if (is_array($par)) {
                // Array types are acceptable
                // Make sure each array element is valid
                foreach ($par as $elem) {
                    if (!is_int($elem)) $valid = false;
                }
                // Were all elements valid?
                if ($valid == false) {
                    $this->_internal_validation_error("Sloodle - LSL response: invalid element in array of side effect codes; all elements should be integers", 0);
                }
            } else if (is_int($par) == false && is_null($par) == false) {
                // It's not an array, an integer or null
                $valid = false;
                $this->_internal_validation_error("Sloodle - LSL response: invalid side effect type; should be an integer, an array of integers, or null", 0);
            }
            // Was it valid?
            if ($valid) {
                $this->side_effects = $par;
            }
        }

        /**
        * Adds one or more integer side effect codes to member {@link $status_code}.
        * @param mixed $par An integer side effect code, or an array of them.
        * @return void
        */
        function add_side_effects($par)
        {
            // We'll use a variable to store the validity
            $valid = true;
            if (is_array($par)) {
                // Array types are acceptable
                // Make sure each array element is valid
                foreach ($par as $elem) {
                    if (!is_int($elem)) $valid = false;
                }
                // Were all elements valid?
                if ($valid == false) {
                    $this->_internal_validation_error("Sloodle - LSL response: cannot add side effects. Invalid element in array of side effect codes. All elements should be integers", 0);
                }
            } else if (is_int($par) == false) {
                // It's not an array or an integer
                $valid = false;
                $this->_internal_validation_error("Sloodle - LSL response: cannot add side effect. Invalid side effect type. should be an integer or an array of integers", 0);
            }
            // Was it valid?
            if ($valid) {
                // If we were passed just a single side effect, then convert it to an array
                if (is_int($par)) {
                    $par = array($par);
                }
                // Make sure our existing side effect member is an array
                if (is_null($this->side_effects)) $this->side_effects = array();
                else if (is_int($this->side_effects)) $this->side_effects = array($this->side_effects);
                        
                // Append our new side effect(s)               
                foreach ($par as $cur) {
                    $this->side_effects[] = $cur;
                }
            }
        }
        
        /**
        * Adds a single side effect code to member {@link $status_code}
        * @param integer $par An integer side-effect code.
        * @return void
        */
        function add_side_effect($par)
        {
            // Make sure the parameter is valid
            if (!is_int($par))
                $this->_internal_validation_error("Sloodle - LSL response: cannot add side effect. Invalid side effect type. Should be an integer.", 0);
            $this->add_side_effects($par);
        }
        
        /**
        * Accessor function to set member value {@link $request_descriptor}
        * @param mixed $par A string request descriptor, or null to clear it
        * @return void
        */
        function set_request_descriptor($par)
        {
            // Validate
            if (is_string($par) == false && is_null($par) == false) {
                $this->_internal_validation_error("Sloodle - LSL response: invalid request descriptor specified; should be a string or null", 0);
            } else {
                $this->request_descriptor = $par;
            }
        }
        
        /**
        * Accessor function to set member value {@link $request_timestamp}
        * @param mixed $par An integer timestamp, or null to clear it
        * @return void
        */
        function set_request_timestamp($par)
        {
            // Validate
            if (is_int($par) == false && is_null($par) == false) {
                $this->_internal_validation_error("Sloodle - LSL response: invalid request timestamp; should be an integer, or null", 0);
            } else {
                $this->request_timestamp = $par;
            }
        }
        
        /**
        * Accessor function to set member value {@link $response_timestamp}
        * @param mixed $par An integer timestamp, or null to clear it
        * @return void
        */
        function set_response_timestamp($par)
        {
            // Validate
            if (is_int($par) == false && is_null($par) == false) {
                $this->_internal_validation_error("Sloodle - LSL response: invalid response timestamp; should be an integer, or null", 0);
            } else {
                $this->response_timestamp = $par;
            }
        }
        
        /**
        * Accessor function to set member value {@link $avatar_uuid}
        * @param mixed $par A string containing a UUID, or null to clear it
        * @return void
        */
        function set_avatar_uuid($par)
        {
            // Validate
            if (is_string($par) == false && is_null($par) == false) {
                $this->_internal_validation_error("Sloodle - LSL response: invalid avatar UUID specified; should be a string or null", 0);
            } else {
                $this->avatar_uuid = $par;
            }
        }
        
        /**
        * Accessor function to set member value {@link $tracking_code}
        * @param mixed $par Any scalar value
        * @return void
        */
        function set_tracking_code($par)
        {
            $this->tracking_code = $par;
        }
        
        /**
        * Accessor function to set member value {@link $page_total}
        * @param mixed $par A positive page total count, or null to clear it
        * @return void
        */
        function set_page_total($par)
        {
            // Validate
            if ((is_int($par) == false || $par < 0) && is_null($par) == false) {
                $this->_internal_validation_error("Sloodle - LSL response: invalid page total; should be a positive integer, or null", 0);
            } else {
                $this->page_total = $par;
            }
        }
        
        /**
        * Accessor function to set member value {@link $page_number}
        * @param mixed $par A positive page number, or null to clear it
        * @return void
        */
        function set_page_number($par)
        {
            // Validate
            if ((is_int($par) == false || $par < 0) && is_null($par) == false) {
                $this->_internal_validation_error("Sloodle - LSL response: invalid page number; should be a positive integer, or null", 0);
            } else {
                $this->page_number = $par;
            }
        }
  
        /**
        * Accessor function to set member value {@link $http_in_password}
        * @param mixed $par Any scalar value
        * @return void
        */
        function set_http_in_password($pwd)
        {
            $this->http_in_password = $pwd;
        }
   
        /**
        * Accessor function to set member value {@link $return_url}
        * @param mixed $par Any scalar value
        * @return void
        */
        function set_return_url($url)
        {
            $this->return_url = $url;
        }
       

     

        /**
        * Accessor function to set member value {@link $data}. <b>Note: it is recommended that you use the {@link add_data_line()} and {@link clear_data()} functions instead of this.</b>
        * @param mixed $par Any scalar value, or a mixed array of scalars or scalar arrays, or null to clear it
        * @return void
        */
        function set_data($par)
        {
            // We'll use a variable to store validity
            $valid = true;
            if (is_array($par)) {
                // Check each element
                foreach ($par as $elem) {
                    // Is this element another array? Or is it a scalar/null value?
                    if (is_array($elem)) {
                        // Check each inner element for validity
                        foreach ($elem as $innerelem) {
                            // Is this element scalar or null? If not, it is invalid
                            if (is_scalar($innerelem) == false && is_null($innerelem) == false) {
                                $valid = false;
                            }
                        }
                    } else if (is_scalar($elem) == false && is_null($elem) == false) {
                        // Not an array, nor a scalar/null value - it is invalid
                        $valid = false;
                    }
                }
                if ($valid == false) {
                    $this->_internal_validation_error("Sloodle - LSL response: non-scalar element in array of items for a data line");
                }
            } else if (is_scalar($par) == false && is_null($par) == false) {
                $valid = false;
                $this->_internal_validation_error("Sloodle - LSL response: each line of data must be a scalar type, or an array of scalars");
            }
            // Store it if it is valid
            if ($valid) {
                $this->data = $par;
            }
        }
    
        /**
        * Adds one line of data to the {@link $data} member
        * @param mixed $par A scalar, or an array of scalars
        * @return void
        */
        function add_data_line($par)
        {
            // We'll use a variable to store validity
            $valid = true;
            if (is_array($par)) {
                // Check each element
                foreach ($par as $elem) {
                    if (is_scalar($elem) == false && is_null($elem) == false) $valid = false;
                }
                if ($valid == false) {
                    $this->_internal_validation_error("Sloodle - LSL response: non-scalar element in array of items for a data line");
                }
            } else if (is_scalar($par) == false && is_null($par) == false) {
                $valid = false;
                $this->_internal_validation_error("Sloodle - LSL response: each line of data must be a scalar type, or an array of scalars");
            }
            // Store it if it is valid
            if ($valid) {
                // Remove line separators
                $par = str_replace(array($this->line_separator, "\r"), ' ', $par); // We'll remove carriage returns, as they screw everything up... thanks to Microsoft...
                $this->data[] = $par;
            }
        }
        
        /**
        * Clears all data from member {@link $data}
        * @return void
        */
        function clear_data()
        {
            $this->data = null;
        }
        
        
      // OTHER FUNCTIONS //
      
        /**
        * <i>Constructor</i> - can intialise some variables
        * @param int $status_code The initial status code for the response (optional - ignore if null)
        * @param string $status_descriptor The initial status descriptor for the response (optional - ignore if null)
        * @param mixed $data The initial data for the response, which can be a scalar, or a mixed array of scalars/scalar-arrays (see {@link SloodleResponse::$data}) (optional - ignore if null)
        * @return void
        * @access public
        */
        function SloodleResponse($status_code = null, $status_descriptor = null, $data = null)
        {
            // Store the data
            if (!is_null($status_code)) $this->status_code = (int)$status_code;
            if (!is_null($status_descriptor)) $this->status_descriptor = (string)$status_descriptor;
            if (!is_null($data)) $this->data = $data;
        }
      
        /**
        * Renders the response to a string.
        * Prior to rendering, this function will perform final validation on all the data.
        * If anything fails, then the script will terminate with an LSL-friendly error message.
        *
        * @param string &$str Reference to a string object which the response should be rendered to.
        * @return void
        * @access public
        */
        function render_to_string(&$str)
        {
            // Clear the string
            $str = "";
            
            // We can omit any unnecessary items of data, but the number of field-separators must be correct
            // E.g. if item 4 is specified, but items 2 and 3 are not, then empty field-separators must be output as if items 2 and 3 were present, e.g.:
            // 1|||AVATAR_LIST
            // (where the pipe-character | is the field separator)
            
            // We will step backwards through out list of fields, and as soon as one item is specified, all of them should be
            $showall = false;

            // return url
            if ($showall || is_null($this->return_url) == false) {
                $showall = true;
                $str = $this->field_separator . $this->return_url. $str;
            }

            // HTTP In Password?
            if ($showall || is_null($this->http_in_password) == false) {
                $showall = true;
                $str = $this->field_separator . $this->http_in_password. $str;
            }

            // Make sure that if the page number is specified, that the total is as well
            if (is_null($this->page_number) xor is_null($this->page_total)) {
                $this->_internal_validation_error("Sloodle - LSL response: script must specify both \"page_total\" *and* \"page_number\", or specify neither");
            } else if ($showall || is_null($this->page_number) == false) {
                $showall = true;
                $str = $this->field_separator . (string)$this->page_total . $this->field_separator . (string)$this->page_number . $str;
            }
            
            // Do we have a tracking code?
            if ($showall || is_null($this->tracking_code) == false) {
                $showall = true;
                $str = $this->field_separator . (string)$this->tracking_code . $str;
            }
            
            // User key?
            if ($showall || is_null($this->avatar_uuid) == false) {
                $showall = true;
                $str = $this->field_separator . $this->avatar_uuid . $str;
            }
            
            // Response timestamp?
            if ($showall || is_null($this->response_timestamp) == false) {
                $showall = true;
                $str = $this->field_separator . (string)$this->response_timestamp . $str;
            }
            
            // Request timestamp?
            if ($showall || is_null($this->request_timestamp) == false) {
                $showall = true;
                $str = $this->field_separator . (string)$this->request_timestamp . $str;
            }
            
            // Request descriptor?
            if ($showall || is_null($this->request_descriptor) == false) {
                $showall = true;
                $str = $this->field_separator . $this->request_descriptor . $str;
            }
            
            // Side-effects?
            if ($showall || is_null($this->side_effects) == false) {
                $showall = true;
                // Is this an array?
                if (is_array($this->side_effects)) {
                    // Yes - output each side effect code in a comma-separated list
                    $selist = "";
                    $isfirst = true;
                    foreach ($this->side_effects as $cur_side_effect) {
                        if (!$isfirst)  $selist .= ",";
                        else $isfirst = false;
                        $selist .= (string)$cur_side_effect;
                    }
                    // Add that list to the output
                    $str = $this->field_separator . $selist . $str;
                    
                } else {
                    // Not at an array - output the single item
                    $str = $this->field_separator . (string)$this->side_effects . $str;
                }
            }
            
            // Status descriptor?
            if ($showall || is_null($this->status_descriptor) == false) {
                $showall = true;
                $str = $this->field_separator . $this->status_descriptor . $str;
            }
            
            // Ensure that a status code has been specified
            if (is_null($this->status_code)) {
                // Not specified - report an error
                $this->_internal_validation_error("Sloodle - LSL response: no status code specified");
            } else {
                // Output the status code
                $str = (string)$this->status_code . $str;
            }
                       
            
            // Has any data been specified?
            if (is_null($this->data) == false) {
                
                // Do we have an outer array?
                if (is_array($this->data)) {
                
                    // Go through each element in the outer array
                    foreach ($this->data as $outer_elem) {
                        
                        // Do we have an inner array on this element?
                        if (is_array($outer_elem)) {
                        
                            // Construct the line, piece-at-a-time
                            $line = "";
                            $isfirst = true;
                            foreach ($outer_elem as $inner_elem) {
                                // Use the standard field separator
                                if (!$isfirst) $line .= $this->field_separator;
                                else $isfirst = false;
                                $line .= (string)$inner_elem;
                            }
                            // Append the new line of data
                            $str .= $this->line_separator . (string)$line;
                        
                        } else {
                            // Output the single item
                            $str .= $this->line_separator . (string)$outer_elem;
                        }
                    }
                
                } else {
                    // Output the single item
                    $str .= $this->line_separator . (string)$this->data;
                }
            }
        }
        
        /**
        * Outputs the response directly to the HTTP response.
        *
        * @access public
        * @return void
        * @uses SloodleResponse::render_to_string() Outputs the result from this function directly to the HTTP response stream.
        */
        function render_to_output()
        {
            // Attempt to render the output to a string, and then copy that string to the HTTP response
            $str = "";
            $this->render_to_string($str);
            SloodleDebugLogger::log('RESPONSE', $str);
            echo $str;
        }
        
        
        // Quick-output
        // Can be called statically to allow simple output of basic data
        // The status code is required, but the other parameters are optional
        // If an error occurs, the LSL-friendly error message is output to the HTTP response, and the script terminated
        // If $static is true (default) then this will be treated as a static call, and a new response object will be used
        // If $static is false then this is treated as adding data to an existing response object
        /**
        * Quick output of data to avoid several accessor calls if the response is very basic.
        * Can be called statically to allow simple output of basic data.
        * The status code is required, but the other parameters are optional
        * If an error occurs, the LSL-friendly error message is output to the HTTP response, and the script terminated
        *
        * @param int $status_code The status code for the response (required)
        * @param string $status_descriptor The status descriptor for the response (optional - ignored if null)
        * @param mixed $data The data for the response, which can be a scalar, or a mixed array of scalars/scalar-arrays (see {@link SloodleResponse::$data}) (optional - ignored if null)
        * @param bool $static If true (default), then this function will assume it is being call statically, and construct its own response object. Otherwise, it will all the existing member data to render the output.
        * @return void
        * @access public
        */
        function quick_output($status_code, $status_descriptor = null, $data = null, $static = true)
        {
            // Is this s static call?
            if ($static) {
                // Construct and render the output of a response object
                $response = new SloodleResponse($status_code, $status_descriptor, $data);
                $response->render_to_output();
            } else {
                // Set all our data
                $this->status_code = $status_code;
                if ($status_descriptor != null) $this->status_descriptor = $status_descriptor;
                if ($data != null) $this->add_data_line($data);
                // Output it
                $this->render_to_output();
            }
        }
    
        
        /**
        * Internal function to report a data validation error.
        * Outputs an LSL-friendly error message, and terminates the script
        *
        * @param string $msg The error message to output.
        * @return void
        * @access private
        */
        function _internal_validation_error($msg)
        {
            exit("-104".$this->field_separator."SYSTEM".$this->line_separator.$msg);
        }
    }
    
    
    /**
    * Obtains a named HTTP request parameter, and terminates script with an error message if it was not provided.
    * This is a 'Sloodle-friendly' version of the Moodle "required_param" function.
    * Instead of terminate the script with an HTML-formatted error message, it will terminate with a message
    *  which conforms for the {@link http://slisweb.sjsu.edu/sl/index.php/Sloodle_communications_specification Sloodle communications specification},
    *  making it suitable for use in {@link http://slisweb.sjsu.edu/sl/index.php/Linker_Script linker scripts}.
    *
    * @param string $parname Name of the HTTP request parameter to fetch.
    * @param int $type Type of parameter expected, such as "PARAM_RAW". See Moodle documentation for a complete list.
    * @return mixed The appropriately parsed and/or cleaned parameter value, if it was found.
    * @deprecated
    */
    function sloodle_required_param($parname, $type)
    {
        exit('ERROR: deprecated function \'sloodle_required_param()\' called.');
        // Attempt to get the parameter
        $par = optional_param($parname, null, $type);
        // Was it provided?
        if (is_null($par)) {
            // No - report the error
            SloodleResponse::quick_output(-811, "SYSTEM", "Expected request parameter '$parname'.");
            exit();
        }
        
        return $par;
    }
    
    
    // This class handles an HTTP request
    /**
    * Handles incoming HTTP requests, typically from LSL if dealing with Second Life.
    * This class will perform much of the complex and repetitive processing required for handling HTTP requests.
    *
    * @uses SloodleResponse Outputs error messages in appropriate format if an error occurs.
    * @uses SloodleUser Stores and processes user data incoming from an HTTP request
    * 
    * @package sloodle
    */
    class SloodleRequest
    {
      // DATA //
        
        /**
        * Reference to the containing {@link SloodleSession} object.
        * If null, then this module is being used outwith the framework.
        * <b>Always check the status of the variable before using it!</b>
        * Note: if not provided, then this object will not render any response information.
        * @var object
        * @access protected
        */
        var $_session = null;

        /**
        * Indicates whether or not the basic request data has already been processed.
        * This is used to ensure data is processed.
        * @var bool
        * @access private
        */
        var $request_data_processed = false;
        
        
    // ACCESSORS //
    
        /**
        * Checks whether or not the request data has already been processed.
        * @return bool
        */
        function is_request_data_processed()
        {
            return $this->request_data_processed;
        }

        /**
        * Fetches the password request parameter.
        * @param bool $required If true (default) then the function will terminate the script with an error message if the HTTP request parameter was not specified.
        * @return string|null The password provided in the request parameters, or null if there wasn't one
        */
        function get_password($required = true)
        {
            return $this->get_param(SLOODLE_PARAM_PASSWORD, $required);
        }
        
        /**
        * Fetches the course ID request parameter.
        * @param bool $required If true (default) then the function will terminate the script with an error message if the HTTP request parameter was not specified.
        * @return int|null The course ID provided in the request parameters, or null if there wasn't one
        */
        function get_course_id($required = true)
        {
            return (int)$this->get_param(SLOODLE_PARAM_COURSE_ID, $required);
        }
        
        /**
        * Fetches the controller ID request parameter.
        * @param bool $required If true (default) then the function will terminate the script with an error message if the HTTP request parameter was not specified.
        * @return int|null The controller ID provided in the request parameters, or null if there wasn't one
        */
        function get_controller_id($required = true)
        {
            return (int)$this->get_param(SLOODLE_PARAM_CONTROLLER_ID, $required);
        }
        
        /**
        * Fetches the module ID request parameter.
        * @param bool $required If true (default) then the function will terminate the script with an error message if the HTTP request parameter was not specified.
        * @return int|null The module ID provided in the request parameters, or null if there wasn't one
        */
        function get_module_id($required = true)
        {
            return (int)$this->get_param(SLOODLE_PARAM_MODULE_ID, $required);
        }
        
        /**
        * Fetches the avatar UUID request parameter.
        * @param bool $required If true (default) then the function will terminate the script with an error message if the HTTP request parameter was not specified.
        * @return string|null The avatar UUID provided in the request parameters, or null if there wasn't one
        */
        function get_avatar_uuid($required = true)
        {
            return $this->get_param(SLOODLE_PARAM_AVATAR_UUID, $required);
        }
        
        /**
        * Fetches the avatar name request parameter.
        * @param bool $required If true (default) then the function will terminate the script with an error message if the HTTP request parameter was not specified.
        * @return string|null The avatar name provided in the request parameters, or null if there wasn't one
        */
        function get_avatar_name($required = true)
        {
            return $this->get_param(SLOODLE_PARAM_AVATAR_NAME, $required);
        }
        
        /**
        * Fetches the request descriptor request parameter.
        * @param bool $required If true (default) then the function will terminate the script with an error message if the HTTP request parameter was not specified.
        * @return string|null The request descriptor provided in the request parameters, or null if there wasn't one
        */
        function get_request_descriptor($required = true)
        {
            return $this->get_param(SLOODLE_PARAM_REQUEST_DESC, $required);
        }
        
        /**
        * Checks the parameters to determine if the request relates to an object rather than a user
        * @return bool True if the request seems to have come from an object, or false otherwise.
        */
        function is_object_request()
        {
            $par = $this->get_param(SLOODLE_PARAM_IS_OBJECT, false, false);
            if (strcasecmp($par, 'true') == 0 || strcasecmp($par, 'yes') == 0 || $par == '1') return true;
            return false;
        }
        
        /**
        * Fetches the server access level parameter, if specified.
        * @param bool $required If true (default) then the function will terminate the script with an error message if the HTTP request parameter was not specified.
        * @return string|null The server access level provided in the request parameters, or null if there wasn't one
        */
        function get_server_access_level($required = true)
        {
            return (int)$this->get_param(SLOODLE_PARAM_SERVER_ACCESS_LEVEL, $required);
        }
        
        
      // FUNCTIONS //
      
        /**
        * <i>Constructor</i> - initialises the {@link SloodleSession} object.
        * If the session parameter is null, then this object simply does not render response information.
        *
        * @param SloodleUser $_session A reference to the {@link SloodleSession} object which this request should use, or null
        */
        function SloodleRequest(&$_session)
        {
            // Store our session object
            $this->_session = &$_session;
        }
        
        /**
        * Process all of the standard data provided by the HTTP request, and write it into our {@link SloodleSession} object.
        * Requires that a {@link SloodleSession} object was provided at construction, and is stored in the $_session member.
        * NOTE: this does not load the module part of the session. That must be done separately, using the {@link SloodleSession::load_module()} member function.
        * @param bool $require_auth If true, then the function will terminate the script with an error message if it cannot authenticate the request through a course, controller and password
        * @param bool $require_user If true, then the function will terminate the script with an error message if a legitimate user was not identified or could not be auto-registered
        * @return bool True if successful, or false otherwise.
        */
        function process_request_data($require_auth = true, $require_user = true)
        {

            SloodleDebugLogger::log('REQUEST', null);

            // Do we have a session object?
            if (!isset($this->_session)) return false;
            
            // Store the request descriptor
            $this->_session->response->set_request_descriptor($this->get_request_descriptor(false));
            // Attempt to load the controller, then the course
            // (there is a shortcut, using course->load_by_controller(), 
            //  however, that makes it harder to locate problems)
            if ($this->_session->course->controller->load( $this->get_controller_id(false) )) {
                // Got the controller... now the course
                $this->_session->course->load( $this->_session->course->controller->get_course_id() );
            } else {
                // Perhaps a course was specified in the request instead?
                $this->_session->course->load( $this->get_course_id(false) );
            }
            
            // Get the avatar details
            $uuid = $this->get_avatar_uuid(false);
            $avname = $this->get_avatar_name(false);
            
            // Attempt to load an avatar
            if ($this->_session->user->load_avatar($uuid, $avname)) {
                // Success - now attempt to load the linked VLE user
                $this->_session->user->load_linked_user();
                // If we didn't already have a UUID then get it from the user data
                if (empty($uuid)) {
                    $uuid = $this->_session->user->get_avatar_uuid();
                }
                
                // Update the user's activity listing
                $this->_session->user->set_avatar_last_active();
                $this->_session->user->write_avatar();
            }
            
            // If we now have a UUID, then add it to our response data
            if (!empty($uuid)) $this->_session->response->set_avatar_uuid($uuid);
            
            $this->request_data_processed = true;
            return true;
        }
      
        
        /**
        * Gets a database record for the course identified in the request.
        * (Note: this function does not check whether or not the user is enrolled in the course)
        *
        * @param bool $require If true, the function will NOT return failure. Rather, it will terminate the script with an error message.
        * @return object A record directly from the database, or null if the course is not found.
        */
        function get_course_record($require = true)
        {
            // Make sure the request data is processed
            $this->process_request_data();
            // Make sure the course ID was specified
            if (is_null($this->course_id)) {
                if ($require) {
                    $this->response->set_status_code(-501);
                    $this->response->set_status_descriptor('COURSE');
                    $this->response->add_data_line('No course specified in request.');
                    $this->response->render_to_output();
                    exit();
                }
                return null;
            }
            // Attempt to get the course data
            $course_record = sloodle_get_record('course', 'id', $this->course_id);
            if ($course_record === false) {
                // Course not found
                if ($require) {
                    $this->response->set_status_code(-512);
                    $this->response->set_status_descriptor('COURSE');
                    $this->response->add_data_line("Course {$this->course_id} not found.");
                    $this->response->render_to_output();
                    exit();
                }
                return null;
            }
            // Make sure the course is visible
            // TODO: any availability other checks here?
            if ((int)$course_record->visible == 0) {
                // Course not available
                if ($require) {
                    $this->response->set_status_code(-513);
                    $this->response->set_status_descriptor('COURSE');
                    $this->response->add_data_line("Course {$this->course_id} is not available.");
                    $this->response->render_to_output();
                    exit();
                }
                return null;
            }
            // TODO: in future, we need to check that the course is Sloodle-enabled
            // TODO: in future, make sure we are authenticated for this particular course
            
            // Seems fine... return the object
            return $course_record;
        }
        
        /**
        * Get a course module instance for the module specified in the request
        * Uses the ID specified in {@link $module_id}.
        *
        * @param string $type specifies the name of the module type (e.g. 'forum', 'choice' etc.) - ignored if blank (default).
        * @param bool $require If true, the function will NOT return failure. Rather, it will terminate the script with an error message.
        * @return object A database record if successful, or false if not (e.g. if instance is not found, is not visible, or is not of the correct type)
        */
        function get_course_module_instance( $type = '', $require = true )
        {
            // Make sure the request data is processed
            $this->process_request_data();
            
            // Make sure the module ID was specified
            if ($this->module_id == null) {
                if ($require) {
                    $this->response->set_status_code(-711);
                    $this->response->set_status_descriptor('MODULE_DESCRIPTOR');
                    $this->response->add_data_line('Course module instance ID not specified.');
                    $this->response->render_to_output();
                    exit();
                }
                return false;
            }
            
            // Attempt to get the instance
            if (!($cmi = sloodle_get_course_module_instance($this->module_id))) {
                if ($require) {
                    $this->response->set_status_code(-712);
                    $this->response->set_status_descriptor('MODULE_DESCRIPTOR');
                    $this->response->add_data_line('Could not find course module instance.');
                    $this->response->render_to_output();
                    exit();
                }
                return false;
            }
            
            // If the type was specified, then verify it
            if (!empty($type)) {
                if (!sloodle_check_course_module_instance_type($cmi, strtolower($type))) {
                    if ($require) {
                        $this->response->set_status_code(-712);
                        $this->response->set_status_descriptor('MODULE_DESCRIPTOR');
                        $this->response->add_data_line("Course module instance not of expected type. (Expected: '$type').");
                        $this->response->render_to_output();
                        exit();
                    }
                    return false;
                }
            }
            
            // Make sure the instance is visible
            if (!sloodle_is_course_module_instance_visible($cmi)) {
                if ($require) {
                    $this->response->set_status_code(-713);
                    $this->response->set_status_descriptor('MODULE_DESCRIPTOR');
                    $this->response->add_data_line('Specified course module instance is not available.');
                    $this->response->render_to_output();
                    exit();
                }
                return false;
            }
            
            // Everything looks fine
            return $cmi;
        }
        
        
    // UTILITY FUNCTIONS //
    
        /**
        * Obtains a named HTTP request parameter, or NULL if it has not been provided.
        * Return values are always strings.
        * @param string $parname The name of the parameter to fetch
        * @param mixed $default The value to return if the parameter cannot be found
        * @return string|mixed The raw parameter value (will be a string if the parameter was found, or the value of parameter $default otherwise)
        */
        function optional_param($parname, $default = null)
        {
            if (isset($_REQUEST[$parname])) return (string)$_REQUEST[$parname];
            return $default;
        }
    
        /**
        * Obtains a named HTTP request parameter, or terminates with an error message if it has not been provided.
        * Note: for linker scripts, this should *always* be used instead of the standard Moodle function, as this will
        *  render appropriately formatted error messages, which scripts can understand.
        * Also note that this function always returned values in the string type. They must be cast.
        *
        * @param string $parname The name of the HTTP request parameter to get.
        * @return string The raw parameter value
        */
        function required_param($parname)
        {
            // Is the parameter provided?
            if (!isset($_REQUEST[$parname])) {
                // No - report the error
                if (isset($this->_session)) {
                    $this->_session->response->set_status_code(-811);
                    $this->_session->response->set_status_descriptor('SYSTEM');
                    $this->_session->response->add_data_line("Required parameter not provided: '$parname'.");
                    $this->_session->response->render_to_output();
                }
                exit();
            }
            
            return $_REQUEST[$parname];
        }
        
        /**
        * Obtains a named HTTP request parameter, optionally requiring it or not
        * @param string $parname The name of the parameter to get
        * @param bool $required Indicates whether or not to 'require' the parameter (if it is required, but cannot be found, then the script is terminated with an error message)
        * @param mixed $default If the $require parameter is false, and the HTTP parameter cannot be found, then this value will be returned instead
        * @return string|mixed The raw value of the HTTP parameter if found, or the value of parameter $default if it was not found and parameter $require was false
        */
        function get_param($parname, $required, $default = null)
        {
            // Use the existing functions to fetch the parameter
            if ($required) return $this->required_param($parname);
            return $this->optional_param($parname, $default);
        }

}

class SloodleDebugLogger {

        // Write the contents to the debug log, if one is defined in SLOODLE_DEBUG_REQUEST_LOG. 
        // Return true if we write something, false if we don't.
        function log($type, $contents = null) {

            if ( SLOODLE_DEBUG_REQUEST_LOG == '' ) {
                return false;
            }

            $str = '';
            $str = '------START-'.$type.'-'.$_SERVER['REQUEST_URI'].'---'.$_SERVER['REMOTE_ADDR'].'---'.$_SERVER['REMOTE_PORT'].'---'.$_SERVER['REQUEST_TIME'].'------'."\n";

            if ( ($type == 'REQUEST') && ($contents == null) ) {
               if (!empty($_GET)) {
                  foreach($_GET as $n=>$v) {
                     $str .= "GET: ".$n." => ".$v."\n";
                  }
               }
               if (!empty($_POST)) {
                  foreach($_POST as $n=>$v) {
                     $str .= "POST: ".$n." => ".$v."\n";
                  }
               }
               if (!empty($_SERVER)) {
                  $interesting_server_vars = array('HTTP_X_SECONDLIFE_OBJECT_NAME', 'REQUEST_URI');
                  foreach($_SERVER as $n=>$v) {
                     if (in_array($n, $interesting_server_vars)) {
                        $str .= "SERVER: ".$n." => ".$v."\n";
                     }
                  }
               }
            } else {
               $str .= $contents."\n";
            }

            
            $str .= '------END-'.$type.'-'.$_SERVER['REQUEST_URI'].'---'.$_SERVER['REMOTE_ADDR'].'---'.$_SERVER['REMOTE_PORT'].'---'.$_SERVER['REQUEST_TIME'].'------'."\n";

            if ($fh = fopen(SLOODLE_DEBUG_REQUEST_LOG, 'a')) {
               fwrite($fh, $str);
               fclose($fh);
            }
            return false;
        }

}

?>

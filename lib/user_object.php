<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * Defines a structure to store information about a user-centric object
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
    
    
    /**
    * A user-centric object, relating to the Sloodle user objects DB table.
    * @package sloodle
    */
    class SloodleUserObject
    {
        /**
        * The database record ID of this object's entry.
        * @var int
        * @access public
        */
        var $id = 0;
    
        /**
        * The UUID of the object's user
        * @var string
        * @access public
        */
        var $avuuid = '';
    
        /**
        * The UUID of this object.
        * @var string
        * @access public
        */
        var $objuuid = '';
        
        /**
        * The name of this object.
        * @var string
        * @access public
        */
        var $objname = '';
        
        /**
        * The password of this object.
        * @var string
        * @access public
        */
        var $password = '';
        
        /**
        * Indicates whether or not this object is currently authorized.
        * @var bool
        * @access public
        */
        var $authorized = false;
        
        /**
        * Timestamp for when this object was last used.
        * @var int
        * @access public
        */
        var $timeupdated = null;
    }

?>
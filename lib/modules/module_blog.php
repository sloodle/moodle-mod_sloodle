<?php
    // This file is part of the Sloodle project (www.sloodle.org)
    
    /**
    * This file defines a blog module for Sloodle.
    *
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    */
    
    /** The Sloodle module base. */
    require_once(SLOODLE_LIBROOT.'/modules/module_base.php');
    /** General Sloodle functions. */
    require_once(SLOODLE_LIBROOT.'/general.php');
    
    
    /** Blog visibility identifier for private posts. (These can only be viewed by the person who posted them) */
    define('SLOODLE_BLOG_VISIBILITY_PRIVATE', 'draft');
    /** Blog visibility identifier for site posts. (These can be viewed by anybody who is registered on the site) */
    define('SLOODLE_BLOG_VISIBILITY_SITE', 'site');
    /** Blog visibility identifier for public posts. (These can be viewed by anybody) */
    define('SLOODLE_BLOG_VISIBILITY_PUBLIC', 'public');
    
    
    
    /**
    * The Sloodle blog module class.
    * @package sloodle
    */
    class SloodleModuleBlog extends SloodleModule
    {
    // DATA //
    
        //... None...
                
        
    // FUNCTIONS //
    
        /**
        * Constructor
        */
        function SloodleModuleBlog(&$_session)
        {
            $constructor = get_parent_class($this);
            parent::$constructor($_session);
        }
        
        
        /**
        * Checks if blogging is enabled on the site.
        * @return bool True if blogging is enabled, or false otherwise
        */
        function is_enabled()
        {
            // If blog level is not specified, then blogging is disabled
            global $CFG;
            if (empty($CFG->bloglevel)) return false;
            return true;
        }
        
        /**
        * Checks if the currently logged-in user has permission to create blog entries.
        * @return bool True if user has permission, or false otherwise
        */
        function user_can_write()
        {
            return has_capability('moodle/blog:create', get_context_instance(CONTEXT_SYSTEM, SITEID));
        }
        
        
        /**
        * Attempts to write a new blog entry to the database, attributed to the user currently loaded in the {@link SloodleSession}.
        * All of the text provided in parameters _must_ be database-safe!
        * @param string $subject The subject line of the post
        * @param string $body The body of the post
        * @param string $visibility The visibility identifier of the post (defaults to site level)
        * @return bool True if successful or false otherwise
        */
        function add_entry($subject, $body, $visibility = '')
        {
            // Make sure a user is loaded
            if (!isset($this->_session)) return false;
            if (!$this->_session->user->is_user_loaded()) return false;
            // Make sure the parameters are not empty
            if (empty($subject) || empty($body)) return false;
            if (empty($visibility)) $visibility = SLOODLE_BLOG_VISIBILITY_SITE;
            // Convert 'private' to 'draft' visibility
            if (strcasecmp($visibility, 'private') == 0) $visibility = SLOODLE_BLOG_VISIBILITY_PRIVATE;
            
            // Create a new database record
            $blogEntry = new stdClass();
            $blogEntry->subject = $subject;
            $blogEntry->summary = $body;
            $blogEntry->module = 'blog';
            $blogEntry->userid = $this->_session->user->get_user_id();
            $blogEntry->format = 1;
            $blogEntry->publishstate = $visibility;
            $blogEntry->lastmodified = time();
            $blogEntry->created = time();
            $blogEntry->courseid = 0;
            $blogEntry->groupid = 0;
            $blogEntry->moduleid = 0;
            $blogEntry->coursemoduleid = 0;
            $blogEntry->uniquehash = '';
            $blogEntry->rating = 0;
            
            // Attempt to insert it into the database
            $blogEntry->id = sloodle_insert_record('post', $blogEntry);
            if (!$blogEntry->id) return false;
            
            // Log the entry
            add_to_log(SITEID, 'blog', 'add', 'index.php?userid='.$blogEntry->userid.'&postid='.$blogEntry->id, "Entry posted from SL via Sloodle: \"{$blogEntry->subject}\"", $blogEntry->userid);
            
            return true;
        }
        
        /**
        * Gets the identified post.
        * @param mixed $id The unique site-wide identifier of the post.
        * @return SloodleBlogPost|bool Returns a {@link SloodleBlogPost} object, or FALSE if unsuccessful.
        */
        function get_post($id)
        {
            // Attempt to fetch the data from the database
            $rec = sloodle_get_record('post', id, $id);
            if (!$rec) return false;
            $post = new SloodleBlogPost();
            $post->load_data($rec);
            return true;
        }
        
        /**
        * Gets the most recent public post.
        * @return SloodleBlogPost|bool Returns a {@link SloodleBlogPost} object, or FALSE if unsuccessful.
        */
        function get_latest_public_post()
        {
            // Attempt to fetch the data from the database
            $rec = sloodle_get_records_select_params('post', "publishstate = 'public'", array(), 'created DESC', '*', 0, 1);
            if (!$rec) return false;
            $post = new SloodleBlogPost();
            $post->load_data($rec[0]);
            return true;
        }
        
        /**
        * Gets the most recent public/site level post.
        * @return SloodleBlogPost|bool Returns a {@link SloodleBlogPost} object, or FALSE if unsuccessful.
        */
        function get_latest_site_post()
        {
            // Attempt to fetch the data from the database
            $rec = sloodle_get_records_select_params('post', "publishstate = 'site' OR publishstate = 'public'", array(), 'created DESC', '*', 0, 1);
            if (!$rec) return false;
            $post = new SloodleBlogPost();
            $post->load_data($rec[0]);
            return true;
        }
        
        /**
        * Gets the most recent post by a particular user, regardless of visibility.
        * @param SloodleUser $user The user to search for. Uses the current {@link SloodleSession} user if unspecified.
        * @return SloodleBlogPost|bool Returns a {@link SloodleBlogPost} object, or FALSE if unsuccessful.
        */
        function get_latest_user_post($user = null)
        {
            // Get the user data from the Session, if needed
            if ($user == null) {
                $user = $this->_session->user;
                if (!$user->is_user_loaded()) return false;
            }
            // Attempt to fetch the data from the database
            $userid = (int)$user->get_user_id();
            $rec = sloodle_get_records_select_params('post', "userid = ?", array($userid), 'created DESC', '*', 0, 1);
            if (!$rec) return false;
            $post = new SloodleBlogPost();
            $post->load_data($rec[0]);
            return true;
        }
        
        
    // ACCESSORS //
    
        /**
        * Gets the name of this module instance.
        * @return string The name of this controller
        */
        function get_name()
        {
            return 'Blog';
        }
        
        /**
        * Gets the intro description of this module instance, if available.
        * @return string The intro description of this controller
        */
        function get_intro()
        {
            return '';
        }
        
        /**
        * Gets the identifier of the course this controller belongs to.
        * @return mixed Course identifier. Type depends on VLE. (In Moodle, it will be an integer).
        */
        function get_course_id()
        {
            return 0;
        }
        
        /**
        * Gets the time at which this instance was created, or 0 if unknown.
        * @return int Timestamp
        */
        function get_creation_time()
        {
            return 0;
        }
        
        /**
        * Gets the time at which this instance was last modified, or 0 if unknown.
        * @return int Timestamp
        */
        function get_modification_time()
        {
            return 0;
        }
        
        
        /**
        * Gets the short type name of this instance.
        * @return string
        */
        function get_type()
        {
            return 'blog';
        }

        /**
        * Gets the full type name of this instance, according to the current language pack, if available.
        * Note: should be overridden by sub-classes.
        * @return string Full type name if possible, or the short name otherwise.
        */
        function get_type_full()
        {
            return 'Blog';
        }

    }
    
    
    /**
    * Represents a single blog post
    * @package sloodle
    */
    class SloodleBlogPost
    {
        /**
        * Constructor - initialises members.
        * @param mixed $id The ID of this message - type depends on VLE, but is typically an integer
        * @param string $subject The subject line of this post
        * @param string $body The body text of this post
        * @param SloodleUser $user The user who posted this entry
        * @param string $visibility The visibility identifier of this post
        * @param int $timestamp_created Time when this post was first made
        * @param int $timestamp_modified Time when this post was last modified
        */
        function SloodleChatMessage($id=0, $subject='', $body='', $user=null, $visibility='', $timestamp_created=0, $timestamp_modified=0)
        {
            $this->id = $id;
            $this->subject = $subject;
            $this->body = $body;
            $this->user = $user;
            $this->visibility = $visibility;
            $this->timestamp_created = $timestamp_created;
            $this->timestamp_modified = $timestamp_modified;
        }
        
        /**
        * Accessor - set all members in a single call.
        * @param mixed $id The ID of this message - type depends on VLE, but is typically an integer
        * @param string $subject The subject line of this post
        * @param string $body The body text of this post
        * @param SloodleUser $user The user who posted this entry
        * @param string $visibility The visibility identifier of this post
        * @param int $timestamp_created Time when this post was first made
        * @param int $timestamp_modified Time when this post was last modified
        * @return void
        */
        function set($id, $subject, $body, $user, $visibility, $timestamp_created, $timestamp_modified)
        {
            $this->id = $id;
            $this->subject = $subject;
            $this->body = $body;
            $this->user = $user;
            $this->visibility = $visibility;
            $this->timestamp_created = $timestamp_created;
            $this->timestamp_modified = $timestamp_modified;
        }
        
        /**
        * Loads the data from a post record object.
        * @param object $rec Database record object contain the data required
        * @return void
        */
        function load_data($rec)
        {
            $this->id = $rec->id;
            $this->subject = $rec->subject;
            $this->body = $rec->summary;
            $this->visibility = $rec->publishstate;
            $this->timestamp_created = $created;
            $this->timestamp_modified = $lastmodified;
            
            $this->user = new SloodleUser();
            $this->user->load_user((int)$rec->userid);
        }
        
        /**
        * The ID of the message.
        * The type depends on the VLE, but typically is an integer.
        * @var mixed
        * @access public
        */
        var $id = 0;
        
        /**
        * The subject of the post.
        * @var string
        * @access public
        */
        var $subject = '';
    
        /**
        * The body of the post.
        * @var string
        * @access public
        */
        var $body = '';
        
        /**
        * The user who wrote this message.
        * @var SloodleUser
        * @access public
        */
        var $user = null;
        
        /**
        * The visibility of this post.
        * @var string
        * @access public
        */
        var $visibility = 0;
        
        /**
        * Timestamp of when this message was created.
        * @var int
        * @access public
        */
        var $timestamp_created = 0;
        
        /**
        * Timestamp of when this message was last modified.
        * @var int
        * @access public
        */
        var $timestamp_modified = 0;
    }


?>

<?php
/*
This is a base class for email processors.
It needs to be extended by a specific email processor, stored in the email_processors directory.
*/
class freemail_email_processor {

    // The following hold the raw data from the email.
    var $_subject;
    var $_from_address;
    var $_html_body;
    var $_plain_body;
    var $_charset;
    var $_attachments = array();

    // The following are filled during parsing. 
    var $_images= array();
    var $_userid = null;
    var $_prepared_body;
    var $_prepared_subject;

    var $_importer;

    static function available_email_processors() {

        $processor_dir = dirname(__FILE__).'/email_processors';

        if (!$dh = opendir($processor_dir)) {
            return false;
        }

        $processors = array();

        while (($processor_file = readdir($dh)) !== false) {

            if (preg_match('/^(freemail_\w+_email_processor).php$/', $processor_file, $matches)) {
                
                $clsname = $matches[1];
                require_once($processor_dir.'/'.$processor_file);
                if (!class_exists($clsname)) {
                    continue;
                }
                if (!$clsname::is_available()) {
                    continue;
                }
                $processors[] = new $clsname;

            }

        }

        return $processors;

    }

    // Adds an attachment.
    // Multi-part emails can have lots of random little attachments.
    // In sloodle we are interested in images
    // ...and narrow down to provide them in get_images().
    function add_attachment($attachment_name, $attachment_data) {
        $this->_attachments[$attachment_name] = $attachment_data;
    }

    function add_image($filename, $data) {
        $this->_images[$filename] = $data;
    }

    // Return true to say that this processor can process the email.
    // This will include finding an importer that can handle the email.
    function is_email_processable() {
        return false;
    }

    // Import the message or return false on failure
    function import() {

        if (!$this->_importer) {
            return false;
        }

        $this->_importer->set_user_id($this->_userid);
        $this->_importer->set_title($this->_prepared_subject);
        $this->_importer->set_body($this->_prepared_body);

        foreach($this->_images as $n => $imgdata) {
            $this->_importer->add_image($n, $imgdata);
        }

        return $this->_importer->import();

    }

    // Transform the raw text from the email into whatever we want to put into Moodle.
    // You probably want to overload this.
    // In the sloodle case this will consist of stripping Second Life advertising 
    // ...and adding a URL pointing to the user's location.
    function prepare() {

        $this->_prepared_body = $this->_plain_body;
        $this->_prepared_subject = $this->_subject;

        if (!$this->_userid = $this->user_id_for_email($this->_from_address)) {
            return false;
        }

        return true;

    }

    // Return the user ID
    function get_user_id() {
        return $this->_userid;
    }

    function set_charset($c) {
        $this->_charset = $c;
    }

    function get_charset() {
        return $this->_charset;
    }

    function get_plain_body() {
        return $this->_plain_body;
    }

    function set_plain_body($b) {
        $this->_plain_body = $b;
    }

    // Return the message body
    function get_html_body() {
        return $this->_html_body;
    }

    function set_html_body($m) {
        $this->_html_body = $m;
    }

    function set_subject($s) {
        $this->_subject = $s;
    }

    function set_from_address($e) {
        $this->_from_address = $e;
    }

    function get_subject() {
        return $this->_subject;
    }

    function load_importer() {
        
        $importers = freemail_moodle_importer::available_moodle_importers();
        if (!count($importers)) {
            return false;
        }

        foreach($importers as $importer) {
            if ($importer->is_email_importable()) {
                $this->_importer = $importer;
                return true;
            }
        }

        return false;
    
    }

    function user_id_for_email($email) {

        if (is_null($email)) {
            return null;
        }

        global $DB;
        $this->_userid = $DB->get_field('user', 'id', array('email'=>$email));

        return $this->_userid;

    }

    // By default, just tell the importer to notify them.
    // This would normally be an email.
    // Some handler may want to do their own handling
    // ..and just get the subject and body from the importer.
    // For example, in SLOODLE we send an in-world instant message.
    function notify_user() {

        if (!$importer = $this->_importer) {
            return false;
        }

        return $importer->notify_user();

    }

    static function verbose_output($verbose, $msg) {

        if ($verbose) {
            print $msg."\n";
        }

    }

    static function read_mail($cfg, $verbose, $daemon, $handler = null, $nodelete = false, $cron = false) {

        // This allows you to hard-code some settings in your config.php and use them in preference to whatever might be set in the web UI.
        // This is useful to us at Avatar Classroom in a multi-site setting, but probably not to anybody else.
        $cfg = isset($cfg->freemail_force_settings) ? $cfg->freemail_force_settings : $cfg;

        $statuses = array(
            'result' => array(),
            'errors' => array(),
            'messages' => array(
            )
        );

        $giveup = false;
        $msgcount = 0;

        $email_processors = freemail_email_processor::available_email_processors();
        if (!count($email_processors)) {
            freemail_email_processor::verbose_output($verbose, "No email processors available, aborting.");
            $statuses['errors']["-1"] = "No email processors available, aborting.";
            $giveup = true;
        }

        // In daemon mode, the handler is kept alive between calls to this function with its connection open.
        freemail_email_processor::verbose_output($verbose, "Trying to get connection...");
        $handler = !is_null($handler) ? $handler : new freemail_imap_message_handler();

        if (!$giveup) {
            freemail_email_processor::verbose_output($verbose, "Connecting...");
            if (!$handler->connect($cfg->freemail_mail_box_settings, $cfg->freemail_mail_user_name, $cfg->freemail_mail_user_pass)) {
                freemail_email_processor::verbose_output($verbose, "Connection failed.");
                $statuses['errors']["-2"] = "Connection failed. Could not fetch email.";
                $giveup = true;
            }
        }

        if (!$giveup) {
            if (!$msgcount = $handler->count()) {
                // In daemon mode, keep the connection open, and return the handler object so we can reuse it.
                if ($daemon) {
                    return $handler;
                }
                $handler->close();
                freemail_email_processor::verbose_output($verbose, "No messages found.");
                $statuses['result']["1"] = "No messages.";
                $giveup = true;
            }
        }

        if (!$giveup) {

            freemail_email_processor::verbose_output($verbose, "Got $msgcount messages.");

            if ($msgcount > 0)  {  

                if ($msgcount > $cfg->freemail_mail_maxcheck) {
                    $msgcount = $cfg->freemail_mail_maxcheck;
                }

                for ($mid = 1; $mid <= $msgcount; $mid++) {

                    $statuses['messages'] = array();

                    freemail_email_processor::verbose_output($verbose, "Considering loading message with ID :$mid:");

                    // Load the header first so that we can check what we need to know before downloading the rest. 
                    if (!$handler->load_header($mid)) {
                        $statuses['messages'][] = array( 
                            'errors' => array('-101' => 'Could not load header') 
                        );
                        continue;
                    }

                    $subject = $handler->get_subject();
                    $fromaddress = $handler->get_from_address();

                    $toaddress = $handler->get_to_address();
                    if (!strtolower($toaddress) == strtolower($cfg->freemail_mail_email_address)) {
                        print "not for us: $toaddress";
                        // Not for us.
                        continue;
                    }

                    $info = array(
                        'subject' => $subject,
                        'fromaddress' => $fromaddress
                    );

                    $size_in_bytes = $handler->get_size_in_bytes();
                    if ($size_in_bytes > $cfg->freemail_mail_maxsize) {
                        $statuses['messages'][] = array( 
                            'errors' => array('-101' => 'Could not load header.'),
                            'info' => $info
                        );
                        continue;
                    }
                    freemail_email_processor::verbose_output($verbose, "Message size :$size_in_bytes: small enough - continuing.");

                    // TODO: Separate load_header and load_body so we don't load the whole thing if it's too big.
                    if (!$handler->load($mid)) {
                        $statuses['messages'][] = array( 
                            'errors' => array('-102' => 'Could not load.'),
                            'info' => $info
                        );

                        continue;
                    }
                    freemail_email_processor::verbose_output($verbose, "Loaded message...");

                    $htmlmsg = $handler->get_html_message();;
                    $plainmsg = $handler->get_plain_message();; 
                    $charset = $handler->get_charset();
                    $attachments = $handler->get_attachments();

                    foreach($email_processors as $processor) {

                        freemail_email_processor::verbose_output($verbose, "Trying processor...");

                        $processor->set_subject($subject);
                        $processor->set_from_address($fromaddress);
                        $processor->set_plain_body($plainmsg);
                        $processor->set_html_body($htmlmsg);
                        $processor->set_charset($charset);

                        foreach($attachments as $attachment_filename => $attachment_body) {
                            $processor->add_attachment($attachment_filename, $attachment_body);
                        }

                        freemail_email_processor::verbose_output($verbose, "Preparing message...");
                        // Couldn't make sense of it, skip
                        if (!$processor->prepare()) {

                            $statuses['messages'][] = array( 
                                'errors' => array('-103' => 'Could not prepare email.') ,
                                'info' => $info
                            );
                            freemail_email_processor::verbose_output($verbose, "Could not prepare email.");
                            continue;
                        }

                        // Couldn't find anyone to process it, skip.
                        if (!$processor->load_importer()) {
                            freemail_email_processor::verbose_output($verbose, "Could not load importer.");

                            $statuses['messages'][] = array( 
                                'errors' => array('-104' => 'Could not load importer.'),
                                'info' => $info
                            );
                            continue;
                        }

                        // Processor can't handle this kind of email.
                        if (!$processor->is_email_processable()) {
                            freemail_email_processor::verbose_output($verbose, "Processor cannot handle this email. Will let others try.");

                            $statuses['messages'][] = array( 
                                'errors' => array('-104' => 'Could not load importer.'),
                                'info' => $info
                            );
                            continue;
                        }

                        // TODO: Get this working.
                        // Ideally we should mark messages as flagged before we start to import them
                        // ...and skip over messages that are already flagged.
                        // This should prevent multiple processes running at the same time from tripping over each other and importing the same message multiple times.
                        // Mark the message as flagged 
                        // $handler->mark_flagged($mid);

                        freemail_email_processor::verbose_output($verbose, "Importing...");
                        if (!$processor->import()) {
                            freemail_email_processor::verbose_output($verbose, "Importing failed.");
                            $statuses['messages'][] = array( 
                                'errors' => array('-105' => 'Importing failed.'),
                                'info' => $info
                            );
                            continue;
                        }

                        freemail_email_processor::verbose_output($verbose, "Notifying user...");
                        if (!$processor->notify_user()) {
                            $statuses['messages'][] = array( 
                                'success' => array('107' => 'Imported, but could not notify user..'),
                                'errors' => array('-106' => 'Imported, but could not notify user..'),
                                'info' => $info
                            );
                            break;
                        }

                        freemail_email_processor::verbose_output($verbose, "Handling of this email complete.");
                        $statuses['messages'][] = array( 
                            'success' => array('107' => 'Imported, but could not notify user..'),
                            'errors' => array('-106' => 'Imported, but could not notify user..'),
                            'info' => $info
                        );

                        break;

                    }

                    // skipping subcommand stuff
                    // list($subcomm, $messcomm) = freemail_getcommands($msg->header[$mid]['subject'], $messagebody['message'], $commands);

                    if ($nodelete) {
                        freemail_email_processor::verbose_output($verbose, "Skipping deletion of message $mid because you asked for nodelete.");
                    } else {
                        freemail_email_processor::verbose_output($verbose, "Deleting message $mid.");
                        if (!$handler->delete($mid)) {
                            freemail_email_processor::verbose_output($verbose, "Deletion of message $mid failed.");
                        }
                    }
                    //imap_delete($mailbox, $mid);

                    //print "skipping user mail content";

                }

            }

            $handler->expunge();

        }

        if ($cfg->freemail_mail_admin_email) {
            // in daemon mode, only send a report if some messages were actually processed.
            if ( (!$daemon & !$cron) || $msgcount) { 
                $subject = "Email processing report";
                $body = freemail_email_processor::status_text($statuses);
                mail($cfg->freemail_mail_admin_email, $subject, $body); 
            }
        }

        // In daemon mode, keep the handler with its connection alive and return it so it can be used again next time.
        if ($daemon) {
            return $handler;
        }

        $handler->close();

        return true;

    }

    static function status_text($statuses) {

        $str = '';

        if (count($statuses['errors'])) {
            $str .= 'Fetching email failed:'."\n";
            $str .= implode("\n", $statuses['errors'])."\n";
        }

        $str .= count($statuses['messages']).' messages processed.';

        return $str;

    }

}

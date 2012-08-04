<?php
class freemail_imap_message_handler {

    var $_connection = null;

    var $_html_message;
    var $_plain_message;
    var $_charset;
    var $_attachments = array();
    var $_header;

    public function connect($connection_string, $username, $password) {

        // Reuse the existing connection if we have one and it's still alive.
        if ( !is_null($this->_connection)) { 
            if (@imap_ping($this->_connection) ) {
                return $this->_connection; 
            }
            // Probably won't do anything, but let's be sure.
            @imap_close($this->_connection);
        }

        $this->_connection = @imap_open($connection_string, $username, $password);
        return $this->_connection;

    }

    public function count() {

        if (!$this->_connection) {
            return null;
        }

        return @imap_num_msg($this->_connection);
    
    }

    public function close() {

        if (!$this->_connection) {
            return null;
        }

        return @imap_close($this->_connection);

    }

    public function delete($mid) {

        if (!$this->_connection) {
            return null;
        }

        return @imap_delete($this->_connection, $mid);

    }

    public function expunge() {

        if (!$this->_connection) {
            return null;
        }

        return @imap_expunge($this->_connection);

    }

    public function load_header($mid) {

        return $this->_header = @imap_header($this->_connection,$mid); 

    }

    public function load($mid) {

        return $this->_get_msg($mid);

    }

    public function mark_flagged($mid) {

        if (!$this->_connection) {
            return null;
        }

        return @imap_setflag_full($this->_connection, $mid, "\\Flagged");

    }

    public function get_html_message() {
        return $this->_html_message;
    }

    public function get_plain_message() {
        return $this->_plain_message;
    }

    public function get_charset() {
        return $this->_charset;
    }
    
    public function get_attachments() {
        return $this->_attachments;
    }

    public function get_header() {
        return $this->_header;
    }

    public function get_subject() {
        return $this->_header->subject;
    }

    public function get_date() {
        return $this->_header->date;
    }

    public function get_to_address() {
        return $this->_header->toaddress;
    }

    public function get_from_address() {
        return $this->_header->fromaddress;
    }

    public function get_size_in_bytes() {
        return $this->_header->Size;
    }
    

    /*
    The following methods are adapted from code found at:
    http://php.net/manual/en/function.imap-fetchstructure.php
    david at hundsness dot com 02-Sep-2008 02:31
    ...who said:
    "Here is code to parse and decode all types of messages, including attachments. I've been using something like this for awhile now, so it's pretty robust."
    */
    private function _get_msg($mid) {
        // input $mbox = IMAP stream, $mid = message id
        // output all the following:

        if (!$mbox = $this->_connection) {
            return false;
        }

        $this->_html_message = $this->_plain_message = $this->_charset = '';
        $this->_attachments = array();

        // BODY
        $s = @imap_fetchstructure($mbox,$mid);
        if (!$s->parts) { // simple
            $this->_get_part($mid,$s,0);  // pass 0 as part-number
        } else {  // multipart: cycle through each part
            foreach ($s->parts as $partno0=>$p) {
                $this->_get_part($mid,$p,$partno0+1);
            }
        }

        return true;

    }

    private function _get_part($mid,$p,$partno) {
        // $partno = '1', '2', '2.1', '2.1.3', etc if multipart, 0 if not multipart

        if (!$mbox = $this->_connection) {
            return false;
        }

        // DECODE DATA
        $data = ($partno)?
            @imap_fetchbody($mbox,$mid,$partno):  // multipart
            @imap_body($mbox,$mid);  // not multipart

        // Any part may be encoded, even plain text messages, so check everything.
        if ($p->encoding==4) {
            $data = quoted_printable_decode($data);
        } elseif ($p->encoding==3) {
            $data = base64_decode($data);
            // no need to decode 7-bit, 8-bit, or binary
        }

        // PARAMETERS
        // get all parameters, like charset, filenames of attachments, etc.
        $params = array();
        if ($p->parameters) {
            foreach ($p->parameters as $x) {
                $params[ strtolower( $x->attribute ) ] = $x->value;
            }
        }
        if ($p->dparameters) {
            foreach ($p->dparameters as $x) {
                $params[ strtolower( $x->attribute ) ] = $x->value;
            }
        }

        // ATTACHMENT
        // Any part with a filename is an attachment,
        // so an attached text file (type 0) is not mistaken as the message.
        if ($params['filename'] || $params['name']) {
            // filename may be given as 'Filename' or 'Name' or both
            $filename = ($params['filename'])? $params['filename'] : $params['name'];
            // filename may be encoded, so see imap_mime_header_decode()
            $this->_attachments[$filename] = $data;  // this is a problem if two files have same name
        } elseif ($p->type==0 && $data) {
        // TEXT
            // Messages may be split in different parts because of inline attachments,
            // so append parts together with blank row.
            if (strtolower($p->subtype)=='plain') {
                $this->_plain_message .= trim($data) ."\n\n";
            } else {
                $this->_html_message .= $data ."<br><br>";
                $this->_charset = $params['charset'];  // assume all parts are same charset
            }
        } elseif ($p->type==2 && $data) {
            // EMBEDDED MESSAGE
            // Many bounce notifications embed the original message as type 2,
            // but AOL uses type 1 (multipart), which is not handled here.
            // There are no PHP functions to parse embedded messages,
            // so this just appends the raw source to the main message.
            $this->_plain_message .= trim($data) ."\n\n";
        }

        // SUBPART RECURSION
        if ($p->parts) {
            foreach ($p->parts as $partno0=>$p2) {
                $this->_get_part($mid,$p2,$partno.'.'.($partno0+1));  // 1.2, 1.2.1, etc.
            }
        }
    }

}


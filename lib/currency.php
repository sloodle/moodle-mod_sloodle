<?php
    // This file is part of the Sloodle project (www.sloodle.org)
   
    /**
    * @package sloodle
    * @copyright Copyright (c) 2008 Sloodle (various contributors)
    * @license http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
    *
    * @contributor Peter R. Bloomfield
    * @contributor Edmund Edgar
    * @contributor Fire Centaur
    */
   
    /** Include the general Sloodle library. */
    require_once(SLOODLE_LIBROOT.'/general.php');

   
    /**
    * The Sloodle course data class
    * @package sloodle
    */
    class SloodleCurrency
    {
    // DATA //
   
       
    // FUNCTIONS //
   
        /**
        * Constructor
        */
        function SloodleCurrency()
        {
            
        }

	function loadFromRow($row) {
		$this->id = $row->id;
		$this->name = $row->name;
		$this->timemodified = $row->timemodified;
		$this->imageurl = $row->imageurl;
		$this->displayorder = $row->displayorder;
	}

	function FetchAll() {
		$recs = sloodle_get_records('sloodle_currency_types', null, null, 'displayorder asc, name asc');
		if (!$recs) {
			return false;
		}
		$currencies = array();
		foreach($recs as $rec) {
			$c = new SloodleCurrency();	
			$c->loadFromRow($rec);
			$currencies[] = $c;
		}
		return $currencies;
	}

	function FetchIDNameHash() {

		if (!$currencies = SloodleCurrency::FetchAll()) {
			return false;
		}
		$curbyid = array();
		foreach($currencies as $cur) {
			$id = $cur->id;
			$name = $cur->name;
			$curbyid[ $id ] = $name;
		}
		return $curbyid;

	}

	function ForID($id) {
		$rec = sloodle_get_record( 'sloodle_currency_types', 'id', $id );
		if (!$rec) {
			return null;
		}
		$curr = new SloodleCurrency();
		$curr->loadFromRow( $rec );
		return $curr;
	}

}
?>

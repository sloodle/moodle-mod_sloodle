<?php
/*
Abstract base class for an object which generates a layout for your course.
*/
class SloodleLayoutRecipe {

	var $_rowsets = array();
	var $_course;

	// over-ride this function to specify a title for the recipe which can be shown to the user.
	function title() {
	}

	// over-ride this function to make the class actually do something useful.
	function generate() {
	}	

	function setCourse($course) {
		$this->_course = $course;
	}

	function addRowSet( $rowset ) {
		$this->_rowsets[] = $rowset;
	}

	// Return an array with course module ids as keys and object names as values
	function objectsByCourseModule( $objectnames = null ) {

		$moduleObjectDefinitions = array();

		foreach ($objectnames as $objn) {
			$objdefn = SloodleObjectConfig::ForObjectName( $objn );
			if (!$objdefn) { // object not found
				continue;
			}
			if (!$module = $objdefn->module) { // no module needed for this object
				continue;
			}
			if ( !isset( $moduleObjectDefinitions[ $module ] ) ) {
				$moduleObjectDefinitions[ $module ] = array();
			}
			$moduleObjectDefinitions[ $module ][] = $objdefn;
		}

		$instr = '';
		$delim = '';
		foreach( $moduleObjectDefinitions as $module => $defns ) {
			$instr .= $delim."'".addslashes( $module )."'"; 
			$delim = ',';
		}

		global $CFG;
		$sql = "select cm.id as id, cm.instance as instance, m.name as module_name from {$CFG->prefix}modules m inner join {$CFG->prefix}course_modules cm on m.id=cm.module where m.name in( $instr ) AND cm.visible = 1;";

		$recs = get_records_sql( $sql );
                if (!$recs) {
                        return false;
                }

		$objectsByCourseModule = array();
                foreach ($recs as $cm) {

			$defns = $moduleObjectDefinitions[ $cm->module_name ];
			$instance = null;

			foreach($defns as $defn) {

				$skip = false;
				// Filter by instance if there are module_filters - otherwise we can add the object without bothering to fetch the module instance
				if ( (is_array($defn->module_filters)) && (count($defn->module_filters) > 0) ) {
					if (!$instance) {
						$instance = get_record($cm->module_name, 'id', $cm->instance);
					}
					foreach($defn->module_filters as $n => $v) {
						if ($instance->$n != $v) {
							$skip = true;
							break;
						}
					}
				}
				if (!$skip) {
					$objectsByCourseModule[ $cm->id ][] = $defn;
				}
			}
                        


		}

		return $objectsByCourseModule;

	}
	
	function saveToLayoutWithID( $layoutid ) {

		$layout = new SloodleLayout();
		if (!$layout->load($layoutid)) {
			return false;
		}

		foreach( $this->_rowsets as $rowset ) {
			foreach( $rowset->getRows() as $row ) {
				if ($entries = $row->getEntries() ) {
					foreach($entries as $entry ) {
						$layout->add_entry( $entry );
					}
				}
			}
		}

		return $layout->update();
		
	}

	function addObjectAtPoint( $name, $cmid = null, $params = null, $x = 0, $y = 0, $z = 0, $rotation = "<0,0,0,0>" ) {
		$objpoint = SloodleLayoutRowSet::Point( $x, $y, $z, $rotation );
		if ( $objpoint->addEntryByName( $name, $cmid, $params ) ) {
			return $this->addRowSet( $objpoint );
		} else {
print "add failed";
}
		return false;
	}

}

class SloodleSimpleLayoutRecipe extends SloodleLayoutRecipe {

	function title() {
		return 'Simple Two-Row Layout';
	}

	function generate() {

		// Plonk a LoginZone overhead
		$this->addObjectAtPoint( 'SLOODLE LoginZone', $cmid = null, $params = null, $x = 0, $y = 0, $z = 10 );

		// Make a simple layout with one long row on each side
		// Fill it up as we go, so when the left one is full we start putting things in the right one
		$rowset = new SloodleLayoutRowSet();	

		$leftrow  = new SloodleLayoutRow();
		$leftrow->setPosition( $x = 1, $y = -5, $z = 1 );
		$leftrow->setDimensions( $x = 10, $y = 0, $z = 0 );
		$leftrow->setSpacing( $x = 2, $y = 0, $z = 0 );
		$leftrow->setDefaultRotation( "<0,0,0,0>" );
		$rowset->addRow( $leftrow  );

		$rightrow  = new SloodleLayoutRow();
		$rightrow->setPosition( $x = 1, $y = 5, $z = 1 );
		$rightrow->setDimensions( $x = 10, $y = 0, $z = 0 );
		$rightrow->setSpacing( $x = 2, $y = 0, $z = 0 );
		$rightrow->setDefaultRotation( "<0,0,0,0>" );
		$rowset->addRow( $rightrow  );

		// Give the row a RegEnrol booth and a Password Reset
		$rowset->addEntryByName( 'SLOODLE RegEnrol Booth' );
		$rowset->addEntryByName( 'SLOODLE Password Reset' );

		// Keep filling out the space with a WebIntercom and a QuizChair for each coursemodule
		// eg. If we have one chatroom and two quizzes, we'll get one WebIntercom and two QuizChairs, one for each quiz.
		$moduleObjects = $this->objectsByCourseModule( 
			array(
				'SLOODLE WebIntercom', 
				'SLOODLE QuizChair',
				'SLOODLE MetaGloss',
				'SLOODLE Choice (Horizontal)',
				'SLOODLE Presenter',
				'SLOODLE Distrutor',
				'SLOODLE PrimDrop',
			) 
		);

		foreach( $moduleObjects as $cmid => $objdefns) {
			foreach($objdefns as $defn) {
				if (!$defn) {
					continue;
				}
				if (!$defn->primname) {
					continue;
				}
				$objname = $defn->primname; 
				$rowset->addEntryByName( $objname, $cmid );
			}
		}

		$this->addRowSet( $rowset );

		return true;
	}
}

/*
Class representing a set of rows in which objects can be placed.
*/
class SloodleLayoutRowSet {

	var $_rows = array();
	var $_rowIndex = 0;

	// Static method returning a SloodleLayoutRowSet instance consisting of a single row for a single object.
	// Use this when you want to add a single object, and you know exactly where you want to put it.
	// Allows you to place an object in a single function call, without all the rest of the RowSet bureaucracy.
	function Point( $x, $y, $z, $rotation = "<0,0,0,0>" ) {

		$row = new SloodleLayoutRow();
		$row->setPosition( $x, $y, $z );
		$row->setDimensions( $x = 1, $y = 1, $z = 1 );
		$row->setSpacing( $x = 0, $y = 0, $z = 0 );
		$row->setDefaultRotation( $rotation );

		$rs = new SloodleLayoutRowSet();
		$rs->addRow( $row );

		return $rs;

	}

	// Adds a SloodleLayoutRow instance to the set
	function addRow( $row ) {
		$this->_rows[] = $row;
	}

	function getRows() {
		return $this->_rows;
	}
	
	// Creates an entry for the specified name and parameters, then adds it (see addEntry). 
	// Returns false if it can't create the entry, or if addEntry() fails to add it.
	function addEntryByName( $name, $cmid = null, $params = null ) {

		if ( !$entry = SloodleLayoutEntry::ForConfig($name) ) {
			return false;
		}
		if ($cmid) {
			$entry->set_config('sloodlemoduleid', $cmid);
		}
		if ($params) {
			foreach($params as $n => $v) {
				$entry->setConfig( $n, $v );
			}
		}
		return $this->addEntry( $entry );	
	}

	// Adds the entry to the next space in the first available row if there's room for it, returns false if there isn't.
	function addEntry( $entry ) {

		if ( $this->_rowIndex >= count($this->_rows) ) {
			return false;
		}
		$currentRow = $this->_rows[ $this->_rowIndex ];

		// Trying to add the entry to the current row 
		// If that fails, go to the next row and try again
		// If we run out of rows to try, give up and return false.
		while ( !$currentRow->addEntry( $entry ) ) {
			$this->_rowIndex++;	
			if ( $this->_rowIndex >= count($this->_rows) ) {
				return false;
			}
			$currentRow = $this->_rows[ $this->_rowIndex ];
		}

		return true;

	}

}

class SloodleLayoutRow {

	// For setting all the objects in the row to face the same way.
	// In practice we'll probably want them to face towards a central position, which involves some difficult position maths, unless we do it on the LSL side.
	var $_defaultRotation = null; 

	var $_spacingx = 0;
	var $_spacingy = 0;
	var $_spacingz = 0;

	var $_posx = 0;
	var $_posy = 0;
	var $_posz = 0;

	var $_dimx = 0;
	var $_dimy = 0;
	var $_dimz = 0;

	var $_lastposx = 0;
	var $_lastposy = 0;
	var $_lastposz = 0;

	var $_entries = array(); 

	// Adds the entry to the next space in the row if there's room for it, returns false if there isn't.
	function addEntry( $entry ) {

		if ( !$posarr = $this->nextPosition() ) {
			return false;
		}

		$x = $this->_posx + $posarr['x'];
		$y = $this->_posy + $posarr['y'];
		$z = $this->_posz + $posarr['z'];

		$entry->position = "<$x,$y,$z>";
		$entry->rotation = $this->_defaultRotation;

		$this->_entries[] = $entry;

		return true;

	}

	function setDefaultRotation( $rot ) {
		$this->_defaultRotation = $rot;
	}

	function setSpacing( $x, $y, $z ) {
		$this->_spacingx = $x;
		$this->_spacingy = $y;
		$this->_spacingz = $z;
	}

	// Position of the row
	function setPosition( $x, $y, $z ) {
		$this->_posx = $x;
		$this->_posy = $y;
		$this->_posz = $z;
	}

	// Dimensions of the row
	function setDimensions( $x = 0, $y = 0, $z = 0 ) {
		$this->_dimx = $x;
		$this->_dimy = $y;
		$this->_dimz = $z;
	}

	// Returns an array representing the next available position within the row
	// NB This is relative to the row, so it needs to be added to the row position to get a position relative to the rezzer
	function nextPosition() {

		$x = $this->_lastposx + $this->_spacingx;	
		$y = $this->_lastposy + $this->_spacingy;	
		$z = $this->_lastposz + $this->_spacingz;	

		if ( ($x > $this->_dimx) || ($y > $this->_dimy) || ($y > $this->_dimy) ) {
			return false; // Full
		}

		$this->_lastposx = $x;
		$this->_lastposy = $y;
		$this->_lastposz = $z;

		return array( 'x' => $x, 'y' => $y, 'z' => $z );

	}

	function getEntries() {
		return $this->_entries;
	}
}

?>

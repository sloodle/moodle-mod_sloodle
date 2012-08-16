<?php 
/* db.lib
Edmund Edgar, 2010-06-18
Sloodle database compatibility wrappers
For reasons best known to themselves, Moodle decided to suddenly rip out all their old db functions and put in a bunch of near-identical ones with slightly different syntax.
To avoid the need for a different release, we'll go through a layer of sloodle_ functions which wrap the appropriate Moodle database call.
We'll probably want to switch these out for the regular Moodle 2.0 calls when people have had a change to upgrade to Moodle 2.
*/

        // Fetch a list of all distributor entries
function sloodle_do_use_db_object() {
   global $CFG;
   return ($CFG->version > 2010060800); 
}

function sloodle_get_record($p1=null, $p2=null, $p3=null, $p4=null, $p5=null, $p6=null, $p7=null, $p8='*') {
   global $DB;
   if ( sloodle_do_use_db_object() ) {
      return $DB->get_record($p1, sloodle_conditions_to_array($p2,$p3,$p4,$p5,$p6,$p7) );
   } else {
      $p3 = is_null($p3) ? $p3 : sloodle_addslashes($p3);
      $p5 = is_null($p5) ? $p5 : sloodle_addslashes($p5);
      $p7 = is_null($p7) ? $p7 : sloodle_addslashes($p7);
      return get_record($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8);
   }
}

function sloodle_record_exists($p1=null, $p2=null, $p3=null, $p4=null, $p5=null, $p6=null, $p7=null) {
   global $DB;
   if ( sloodle_do_use_db_object() ) {
      return $DB->record_exists($p1, sloodle_conditions_to_array($p2,$p3,$p4,$p5,$p6,$p7) );
   } else {
      $p3 = is_null($p3) ? $p3 : sloodle_addslashes($p3);
      $p5 = is_null($p5) ? $p5 : sloodle_addslashes($p5);
      $p7 = is_null($p7) ? $p7 : sloodle_addslashes($p7);
      return record_exists($p1, $p2, $p3, $p4, $p5, $p6, $p7);
   }
}

function sloodle_get_records($p1=null, $p2=null, $p3=null, $p4=null, $p5='*', $p6=null, $p7=null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->get_records($p1, sloodle_conditions_to_array( $p2, $p3), $p4, $p5, $p6, $p7 );
   } else {
      $p3 = is_null($p3) ? $p3 : sloodle_addslashes($p3);
      return get_records($p1, $p2, $p3, $p4, $p5, $p6, $p7);
   }
}

function sloodle_get_records_sql_params($p1=null, $p2=null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->get_records_sql($p1, $p2);
   } else {
      $p1 = sloodle_parameterized_query($p1, $p2); 
      return get_records_sql($p1);
   }
}


function sloodle_get_records_select_params( $p1=null, $p2=null, $params, $p3=null, $p4 = '*', $p5 = null, $p6 = null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->get_records_select($p1, $p2, $params, $p3, $p4, $p5, $p6); // get_records_select now has an option to pass in an array of params
   } else {
      $p2 = sloodle_parameterized_query( $p2, $params );
      return get_records_select($p1, $p2, $p3, $p4, $p5, $p6);
   }
}

function sloodle_get_record_select_params( $p1=null, $p2=null, $params, $p3, $p4 = '*', $p5 = null, $p6 = null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->get_record_select($p1, $p2, $params, $p3, $p4, $p5, $p6); // get_record_select now has an option to pass in an array of params
   } else {
      $p2 = sloodle_parameterized_query( $p2, $params );
      return get_record_select($p1, $p2, $p3, $p4, $p5, $p6);
   }
}

function sloodle_insert_record($p1=null, $p2=null, $returnid=true, $primarykey='id') {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      $p2 = is_null($p2) ? $p2 : sloodle_sanitize_object( $p2 );
      return $DB->insert_record($p1, $p2, $returnid, false);  // if we need that primarykey field, I guess something will break
   } else {
      return insert_record($p1, $p2, $returnid, $primarykey );
   }
}

function sloodle_sanitize_object($obj) {
   $props = get_object_vars( $obj );
   foreach($props as $prop => $val) {
      // ignore values that aren't regular strings / ints etc
      if (is_array($val) || is_object($val)) {
         continue;
      }
      $obj->$prop = sloodle_addslashes($val);
   }
   return $obj;
}

function sloodle_update_record($p1=null, $p2=null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->update_record($p1, $p2);
   } else {
      $p2 = is_null($p2) ? $p2 : sloodle_sanitize_object( $p2 );
      return update_record($p1, $p2);
   }
}

function sloodle_count_records($p1=null, $p2=null, $p3=null, $p4 = null, $p5 = null, $p6 = null, $p7 = null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->count_records($p1, sloodle_conditions_to_array($p2, $p3, $p4, $p5, $p6, $p7) );
   } else {
      $p3 = is_null($p3) ? $p3 : sloodle_addslashes($p3);
      $p5 = is_null($p5) ? $p5 : sloodle_addslashes($p5);
      $p7 = is_null($p7) ? $p7 : sloodle_addslashes($p7);
      return count_records($p1, $p2, $p3, $p4, $p5, $p6, $p7);
   }
}

function sloodle_count_records_select_params($p1=null, $p2, $params) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->count_records_select($p1, $p2, $params) ;
   } else {
      $p2 = sloodle_parameterized_query($p2, $params);
      return count_records_select($p1, $p2);
   }
}

function sloodle_delete_records($p1=null, $p2=null, $p3=null, $p4=null, $p5=null, $p6=null, $p7=null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->delete_records($p1, sloodle_conditions_to_array($p2, $p3, $p4, $p5, $p6, $p7) );
   } else {
      $p3 = is_null($p3) ? $p3 : sloodle_addslashes($p3);
      $p5 = is_null($p5) ? $p5 : sloodle_addslashes($p5);
      $p7 = is_null($p7) ? $p7 : sloodle_addslashes($p7);
      return delete_records($p1, $p2, $p3, $p4, $p5, $p6, $p7);
   }
}

function sloodle_delete_records_select_params($p1=null, $p2=null, $params) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->delete_records_select($p1, $p2, $params);
   } else {
      $p2 = sloodle_parameterized_query($p2, $params); 
      return delete_records_select($p1, $p2);
   }
}

function sloodle_get_field($p1=null, $p2=null, $p3=null, $p4=null, $p5=null, $p6=null, $p7=null, $p8=null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->get_field($p1, $p2, sloodle_conditions_to_array($p3, $p4, $p5, $p6, $p7, $p8) );
   } else {
      return get_field($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8);
   }
}

function sloodle_get_field_sql_params($p1=null, $params) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->get_field_sql($p1, $params);
   } else {
      $p1 = sloodle_parameterized_query($p1, $params);
      return get_field_sql($p1);
   }
}

function sloodle_set_field($p1=null, $p2=null, $p3=null, $p4=null, $p5=null, $p6=null, $p7=null, $p8=null, $p9=null) {
   if ( sloodle_do_use_db_object() ) {
      global $DB;
      return $DB->set_field($p1, $p2, $p3, sloodle_conditions_to_array( $p4, $p5, $p6, $p7, $p8, $p9) );
   } else {
      $p3 = is_null($p3) ? $p3 : sloodle_addslashes($p3);
      $p5 = is_null($p5) ? $p5 : sloodle_addslashes($p5);
      $p7 = is_null($p7) ? $p7 : sloodle_addslashes($p7);
      $p9 = is_null($p9) ? $p9 : sloodle_addslashes($p9);
      return set_field($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9);
   }
}

function sloodle_sql_ilike() {

   if ( sloodle_do_use_db_object() ) {
      global $DB;
      // Probably not a very good solution, but I'm having a hard time keeping up with all these API changes...
      if (!method_exists($DB, 'sql_ilike')) {
          return 'LIKE';
      }
      return $DB->sql_ilike();
   } else {
      return sql_ilike();
   }

}

function sloodle_conditions_to_array($c1 = null, $c2 = null, $c3 = null, $c4 = null, $c5 = null, $c6 = null) {
   $conditions = array();
   if ($c1) {
      $conditions[$c1] = $c2;
   }
   if ($c3) {
      $conditions[$c3] = $c4;
   }
   if ($c5) {
      $conditions[$c5] = $c6;
   }
   return $conditions;
}

function sloodle_addslashes($p) {
   // Nasty hack, to deal with nasty hacks in clean_param() in Moodle 1.x.
   // In Moodle 1.x, input passes through addslashes on the way in, but db data doesn't.
   // This will break if you have a legitimate use for "'/" in your text.
   // ...but in practice for our purposes nothing should break that wasn't already broken.
   return addslashes(stripslashes($p));
}

// Quick-and-dirty parameterized query maker.
// NB This expects db integers to be integers and db varchar fields to be strings
// Only designed to work for queries we use in Sloodle - too crude for general use.
// Only has to keep us going until we drop 1.x, then Moodle will do this for us in the DML layer, where it belongs.
function sloodle_parameterized_query($sql, $args) {
    if (count($args) == 0) {
        return $sql;
    }
    foreach($args as $arg) {
        if (is_string($arg)) {
           $arg = "'".sloodle_addslashes($arg)."'";
        } else {
           $arg = sloodle_addslashes($arg); // shouldn't be any slashes in a non-string (integer etc), but if that's right it won't do any harm either.
        }
        $sql = preg_replace('/\?/', $arg, $sql, 1); 
    }
    return $sql;
}
?>

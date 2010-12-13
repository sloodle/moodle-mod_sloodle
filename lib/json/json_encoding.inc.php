<?php
// Ensures the json_encode and json_decode functions are available.
// Only necessary for PHP4. In PHP5 they're already there.
// Uses the JSON.php file from PEAR.
if (!function_exists('json_decode')) {
    function json_decode($content, $assoc=false) {
        require_once(realpath(dirname(__FILE__) . "/" . "JSON.php"));
        if ($assoc) {
            $json = new Services_JSON(SERVICES_JSON_LOOSE_TYPE);
        }
        else {
            $json = new Services_JSON;
        }
        return $json->decode($content);
    }
}

if (!function_exists('json_encode')) {
    function json_encode($content) {
        require_once(realpath(dirname(__FILE__) . "/" . "JSON.php"));
        $json = new Services_JSON;
        return $json->encode($content);
    }
}

?>

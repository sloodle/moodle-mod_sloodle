<?php
/*
To save memory, we'll try to leave loading the full Moodle/Sloodle thing to the last minute.
If we're just 
*/
define('CLI_SCRIPT',true);

if (file_exists('sloodle_config.php')) {
    require_once('sloodle_config.php');
}

define('SLOODLED_BASE_DIR', dirname(__FILE__));

// This is useful in the Avatar Classroom multiple-host environment
// ...where we want to be able to tell the script which database etc to write to
if (!isset($_SERVER['SERVER_NAME'])) {
    $_SERVER = array();
    $_SERVER['SERVER_NAME'] = SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_PREFIX.SLOODLE_MESSAGE_QUEUE_URL_SUFFIX;
    //SLOODLE_MESSAGE_QUEUE_SITE_PATH_PREFIX.SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_PREFIX.SLOODLE_MESSAGE_QUEUE_SITE_PATH_SUFFIX;
}

if ( !defined('SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK') || !SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK  ) {
    echo 'To run the sloodle daemon, enable SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK in sloodle_config.php';
    exit;
}

define('SLOODLE_MESSAGE_QUEUE_TASK', true);


//require_once('lib/beanstalk/Beanstalk.php');
require_once(SLOODLED_BASE_DIR.'/lib/beanstalk/Beanstalk.php');
require_once(SLOODLED_BASE_DIR.'/init.php');

/*
$sbhost = ( ( defined(SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_HOST) && (SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_HOST != '') ) ) ? SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_HOST : '127.0.0.1';
$sbport = ( defined(SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_PORT) && SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_PORT ) ? SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_PORT : 11300;
$sbtimeout = ( defined(SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_TIMEOUT) && SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_TIMEOUT ) ? SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_TIMEOUT : 1;
$sbpersistent = ( defined(SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_PERSISTENT) && SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_PERSISTENT ) ? SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK_PERSISTENT : true;

$sbconfig = array(
   'persistent' => $sbpersistent,
   'host' => $sbhost,
   'port' => $sbport,
   'timeout' => $sbtimeout
);

*/
//$sb = new Socket_Beanstalk( $sbconfig );
$sb = new Socket_Beanstalk( );
if (!$sb->connect()) {
    print "connect failed";
    return false;
}

$args = $argv;
array_shift($args); // remove the script name

// Check if the array contains the "-v", and if it does remove it from the array.
$verbose = in_array( '-v', $args );
$args = array_diff($args, array('-v') );

$stats = in_array( '-s', $args );
$args = array_diff($args, array('-s') );

$manage = in_array( '-m', $args );
$args = array_diff($args, array('-m') );

$list_tubes = in_array( '-t', $args );
$args = array_diff($args, array('-t') );

if ( $stats ) {
    var_dump($sb->stats());
    exit;
}

if ($tube = array_shift($args)) {
    if ($verbose) {
        print "Using tube $tube";
    }
}

if ($list_tubes) {
    print "List of tubes:\n";
    print join("\n",$sb->listTubes());
    print "\n";
    exit;
}

if ($manage) {
    if ($verbose) {
        print "In manage";
        $check_after = 30;
        $tubes_watched = array();
        while(1) {

            $tubes = $sb->listTubes();
            if ($verbose) {
                print "List found ".count($tubes)."\n";
            }

            foreach($tubes as $tube) {

                if ($verbose) { 
                    print "Checking tube $tube\n";
                }

                if (isset($tubes_watched[$tube])) {
                    $last_check_ts = $tubes_watched[$tube];
                    if ( ( $last_check_ts + $check_after ) < time() ) {
                        if ($verbose) { 
                            print "Time up for tube $tube - rechecking\n";
                        }
                        if (!sloodle_is_child_process_running($tube)) {
                            print "No child process found for tube $tube - spawning\n";
                            require_once(SLOODLED_BASE_DIR.'/init.php');
                            if (sloodle_spawn_child_process($tube)) {
                                print "Spawned for tube $tube \n";
                                if ($verbose) { 
                                    $tubes_watched[$tube] = time();
                                }
                            } 
                        }
                    }
                } else {
                    if (!sloodle_is_child_process_running($tube)) {
                        print "No child process found for tube $tube - spawning\n";
                        require_once(SLOODLED_BASE_DIR.'/init.php');
                        if (sloodle_spawn_child_process($tube)) {
                            if ($verbose) {
                                print "Spawned for tube $tube \n";
                            }
                        }
                        $tubes_watched[$tube] = time();
                    }
                }
            }
            sleep(1);
        }
    }
}

if ($tube) {
    $sb->watch($tube);
    sloodle_job_loop($sb, $verbose, $timeout=300);
    exit;
}

//var_dump($sb->stats());
//exit;

while (true) {

    $tubes = $sb->listTubes();
    if ($verbose) {
        //print "Listing tubes\n";
    }

    if (count($tubes) > 0) {

        foreach($tubes as $tube) {
            //print "Watching tube $tube\n";
            //print "inspecting tube $tube\n";
            /*
            if (!$sb->choose($tube)) {
                print "error: choose failed for tube $tube\n";
            }
            */
            $sb->watch($tube);

        }

        sloodle_job_loop($sb, $verbose);
            //!$pid = $sb->put(1000, 0, 10, "hello");
            //print "Put job with pid $pid\n";

    //var_dump($sb->peekReady());
   }

    //sleep(1);

}

/*
$tubes = $sb->listTubes();
foreach($tubes as $tube) {
    $sb->
}
*/
//var_dump($sb->stats());

exit;

function sloodle_job_loop($sb, $verbose, $timeout = 0) {

    while($job = $sb->reserve($timeout)) {
        $msg = $job['body'];
        $id = $job['id'];
        if ($verbose) {
            print "Handling job $id\n";
        }
        if (sloodle_handle_message($msg)) {
            if ($verbose) {
                print "Deleting job $id\n";
            }
            $sb->delete($id);
        }
        //sloodle_handle_message($sb, $job, $tube); 
    }
 
}

function sloodle_handle_message($msg) {

    $lines = explode("\n", $msg);
    $statusline = array_shift($lines);
    $body = implode("\n", $lines);

    //print $url."\n";

    if (!$statusline) {
        return false;
    }

    $bits = explode("|", $statusline);
    // We should at least have the task and address
    if (count($bits) < 2) {
        return false;
    }

    $handler_prefix = $bits[0];
    $address = $bits[1];

    if (!preg_match("/^[A-Za-z0-9_-]+$/", $handler_prefix)) {
        print "handler_prefix $handler_prefix fails regex";
        return false;
    }
    $request_handler  = $handler_prefix.'_request.php';
    $response_handler = $handler_prefix.'_response.php';

    include(SLOODLE_LIBROOT.'/message_handlers/'.$request_handler);
    if (file_exists(SLOODLE_LIBROOT.'/message_handlers/'.$response_handler)) {
        include(SLOODLE_LIBROOT.'/message_handlers/'.$response_handler);
    }

    return true;
    /*
    if (preg_match('/sloodle-(.*?)-(.*)$/', $tube)) {
       $task = $matches[1]; 
       $url  = $matches[1]; 
    }

    print $task;
    print $url;

    */

return;

    $ch = curl_init();    // initialize curl handle
    curl_setopt($ch, CURLOPT_URL, $this->httpinurl ); // set url to post to
    curl_setopt($ch, CURLOPT_FAILONERROR,0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
    curl_setopt($ch, CURLOPT_TIMEOUT, 10); // times out after 4s
    curl_setopt($ch, CURLOPT_POST, 1); // set POST method
    curl_setopt($ch, CURLOPT_POSTFIELDS,$msg); // add POST fields
    if ($proxy = $this->httpProxyURL()) {
    curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 1);
    curl_setopt($ch, CURLOPT_PROXY, $this->httpProxyURL() );
    }

    $result = curl_exec($ch); // run the whole process
    $info = curl_getinfo($ch);
    curl_close($ch);
    return array('info'=>$info,'result'=>$result);

    print "ok";

}

function sloodle_is_child_process_running($tube) {

    $cmd = "ps aux | grep ".escapeshellarg($tube).' | grep -v grep | wc -l';
    //print $cmd."\n";
    exec($cmd, $result);
    return ( isset($result[0]) && $result[0] > 0 );

}

function sloodle_spawn_child_process($tube) {

    // The tube may have the site name prefixed to it.
    $cmd = '';
    if (preg_match('/^(.*?)-.*/', $tube, $matches)) {
        $path = SLOODLE_MESSAGE_QUEUE_SITE_PATH_PREFIX.$matches[1].SLOODLE_MESSAGE_QUEUE_SITE_PATH_SUFFIX;
        $cmd = 'cd '.$path.' && ';
    }
    $cmd .= "nohup php sloodled.php ".escapeshellarg($tube).' > /dev/null 2>&1 &';
    //$cmd .= "php sloodled.php ".escapeshellarg($tube);
    
    print $cmd."\n";
    exec($cmd, $result);
 //   var_dump($result);

    return true;

}

exit();

?>

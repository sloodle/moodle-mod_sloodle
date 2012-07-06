<?php
/*
sloodled.php, Edmund Edgar, 2012-04
Copyright contributors, licensed under the same license as the rest of SLOODLE.

This script is a background daemon used to improve performance when sending messages via http-in.
It relies on having the Beanstalk daemon installed and running, and turned on in sloodle_config.php
In a normal SLOODLE install you probably won't need to use it.

You would normally run it in the background with something like:
nohup php sloodled.php -m > /dev/null 2>&1 &

Run with the -m flag, it will monitor the beanstalkd queue for tubes
...each corresponding to a particular combination of a task and an http-in address
It spawns a copy of itself as a worker process to handle each tube, which will run for 90 seconds or so then exit.

If you want to see it in action, run it with the -v flag (verbose)
php sloodled.php -m -v

If you've set things like SLOODLE_MESSAGE_QUEUE_SITE_PATH_PREFIX, 
...it will check which site the task belongs to and change to the directory of that site to run the worker process.
This is designed for Avatar Classroom, and contains some assumptions about the directory layout of multiple sites.
As such, it probably won't work for anybody else without modification.
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

//$sb = new Socket_Beanstalk( $sbconfig );
$sb = new Socket_Beanstalk( );
if (!$sb->connect()) {
    if ($verbose) {
        print "Initial connect failed\n";
    }
    // Normally we'd give up if we can't connect, but in manage mode we'll keep trying every second until beanstalkd comes up.
    if (!$manage) {
        exit(1);
    }
}

if ( $stats ) {
    var_dump($sb->stats());
    exit;
}

if ($tube = array_shift($args)) {
    if ($verbose) {
        print "Using tube $tube";
    }
    $untilts = array_shift($args);
}

if ($list_tubes) {
    print "List of tubes:\n";
    print join("\n",$sb->listTubes());
    print "\n";
    exit;
}

if ($manage) {

    if ($verbose) {
        print "In manage\n";
    }

    $check_after = 15;
    $tubes_watched = array();
    while(1) {

        $tubes = $sb->listTubes();

        if (!is_array($tubes)) {
            // Beanstalk server has gone away.
            if ($verbose) {
                print "Error: Could not get list of tubes from beanstalkd. Will disconnect and try again.\n";
            }
            $sb->disconnect();
            if ($sb->connect()) {
                $tubes = $sb->listTubes();
            }
        }

        if ($verbose) {
            if (is_array($tubes)) {
                print "List found ".count($tubes)."\n";
            }
        }

        if ( ( is_array($tubes) ) && ( count($tubes) > 0 ) ) {
            foreach($tubes as $tube) {

                if ($verbose) { 
                    print "Checking tube $tube\n";
                }

                /*
                We'll go through the active tubes, check if they have a worker process spawned for them, and if they don't, start one.

                We'll tell each script to run until the check_after time, then exit once it's finished the task it's working on.
                That will avoid the need to keep checking on all the tubes, all the time.

                If a worker process dies prematurely for some reason, it will get restarted when the check_after time comes around.

                There will be a short window between the time we tell a worker to end and the time when it actually exists, as it has to finish what it's doing.
                During that time, we'll just keep checking the process table.
                */

                $untilts = time() + $check_after;

                // Unset any records we have of tubes whose time is up.
                if (isset($tubes_watched[$tube])) {
                    // Time's up, the process should be exiting right about now.
                    if ( $tubes_watched[$tube] < time() ) {
                        unset($tubes_watched[$tube]);
                    } 
                }

                // Should already be running, won't bother to check.
                if (isset($tubes_watched[$tube])) {
                    continue;
                }

                if (sloodle_is_child_process_running($tube)) {
                    continue;
                }

                if ($verbose) {
                    print "No child process found for tube $tube - spawning\n";
                }

                if (sloodle_spawn_child_process($tube, $untilts)) {
                    // Make a note of the tube we spawned a worker for so we don't have to keep checking.
                    $tubes_watched[$tube] = $untilts;
                    if ($verbose) { 
                        print "Spawned for tube $tube \n";
                    }
                }

            }
        }

        sleep(1);

    }

}

if ($tube) {
    $sb->watch($tube);
    sloodle_job_loop($sb, $verbose, $untilts);
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

        sloodle_job_loop($sb, $verbose, $untilts);
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

function sloodle_job_loop($sb, $verbose, $untilts) {

    $timeout = 10;
    while( $untilts > time() ) {
        if ( $job = $sb->reserve($timeout) ) {
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

    include(SLOODLED_BASE_DIR.'/lib/message_handlers/'.$request_handler);
    if (file_exists(SLOODLED_BASE_DIR.'/lib/message_handlers/'.$response_handler)) {
        include(SLOODLED_BASE_DIR.'/lib/message_handlers/'.$response_handler);
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

function sloodle_spawn_child_process($tube, $untilts) {

    // The tube may have the site name prefixed to it.
    $cmd = '';
    if (preg_match('/^(.*?)-.*/', $tube, $matches)) {
        $path = SLOODLE_MESSAGE_QUEUE_SITE_PATH_PREFIX.$matches[1].SLOODLE_MESSAGE_QUEUE_SITE_PATH_SUFFIX;
        $cmd = 'cd '.$path.' && ';
    }
    $cmd .= "nohup php sloodled.php ".escapeshellarg($tube).' '.$untilts.' > /dev/null 2>&1 &';
    //$cmd .= "php sloodled.php ".escapeshellarg($tube);
    
    print $cmd."\n";
    exec($cmd, $result);
 //   var_dump($result);

    return true;

}

exit();

?>

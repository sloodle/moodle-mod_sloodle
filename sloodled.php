<?php
/*


*/
define('CLI_SCRIPT',true);

$_SERVER = array();
$_SERVER['SERVER_NAME'] = 'gershwinklata1.avatarclassroom.com';
//$_SERVER['REMOTE_ADDR'] = '';
$_SERVER['REMOTE_PORT'] = '';
$_SERVER['REQUEST_TIME'] = time();

require_once('sl_config.php');

if ( !defined('SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK') || !SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK  ) {
    echo 'To run the sloodle daemon, enable SLOODLE_MESSAGE_QUEUE_SERVER_BEANSTALK in sl_config.php';
    exit;
}

//require_once('lib/beanstalk/Beanstalk.php');
require_once(SLOODLE_LIBROOT.'/beanstalk/Beanstalk.php');

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

$verbose = in_array('-v',$argv);

if ( in_array('stats',$argv) ) {
    var_dump($sb->stats());
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
            //!$pid = $sb->put(1000, 0, 10, "hello");
            //print "Put job with pid $pid\n";

    //var_dump($sb->peekReady());
            while($job = $sb->reserve(0)) {
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

    sleep(1);

}

/*
$tubes = $sb->listTubes();
foreach($tubes as $tube) {
    $sb->
}
*/
//var_dump($sb->stats());

exit;

function sloodle_handle_message($msg) {

    $lines = explode("\n", $msg);
    $url = array_shift($lines);
    $body = implode("\n", $lines);

    //print $url."\n";

    if (!$url) {
        return false;
    }

    $ch = curl_init();    // initialize curl handle
    curl_setopt($ch, CURLOPT_URL, $url); // set url to post to
    curl_setopt($ch, CURLOPT_FAILONERROR,0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
    curl_setopt($ch, CURLOPT_TIMEOUT, 10); // times out after 4s
    curl_setopt($ch, CURLOPT_POST, 1); // set POST method
    curl_setopt($ch, CURLOPT_POSTFIELDS,$body); // add POST fields
    /*
    if ($proxy = $this->httpProxyURL()) {
        curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 1);
        curl_setopt($ch, CURLOPT_PROXY, $this->httpProxyURL() );
    }
    */

    $result = curl_exec($ch); // run the whole process
    $info = curl_getinfo($ch);
    curl_close($ch);

    //return array('info'=>$info,'result'=>$result);

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

exit();

?>

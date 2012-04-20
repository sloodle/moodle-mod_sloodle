
<?php 
//require_once(SLOODLE_LIBROOT . '/krumo/class.krumo.php');
function print_html_top($loadfrom = '', $is_logged_in) {?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
        <title>Scoreboard</title>
        <!--
        <style type="text/css" media="screen">@import "http://fonts.googleapis.com/css?family=Candal";</style>
        -->
        <style type="text/css" media="screen">@import "<?php echo $loadfrom?>scoreboard_admin.css";</style>
        <script type="application/x-javascript" src="../../../lib/jquery/jquery.js"></script>
        <script type="application/x-javascript" src="../../../lib/jquery/jquery.ba-hashchange.min.js"></script>
        <link type="text/css" href="../../../lib/jquery/css/ui-darkness/jquery-ui-1.8.18.custom.css" rel="Stylesheet" />
        <script type="text/javascript" src="../../../lib/jquery/js/jquery-ui-1.8.18.custom.min.js"></script>
        <script type="text/javascript" src="../../../lib/jquery/js/jquery.jscrollpane.min.js"></script>
        <link type="text/css" href="../../../lib/jquery/css/jquery.jscrollpane.css" rel="stylesheet" media="all" />

        <script type="text/javascript" src="../../../lib/jquery/js/jquery.mousewheel.js"></script>
        <script type="application/x-javascript" src="scoreboard.js?ts=<?php echo  time() ?>"></script>
        <script type="text/javascript">
            var rezzer_uuid  = '<?php echo  htmlentities($_REQUEST['sloodleobjuuid']) ?>';
            var do_full_updates = <?php echo  $is_logged_in ? 'true' : 'false' ?>; 
        </script>
        </head>

        <body scroll="no">
         
        <div class="wrapper">
<?php
}

function print_round_list($rounds) {

?>
    <ul id="roundlist" title="Rounds">
        <li class="group">All Rounds</li>
    </ul>

<?php
}

function print_score_list( $group_name, $student_scores, $active_object_uuid, $currency, $roundid, $refreshtime, $objecttitle, $is_logged_in, $is_admin ) {
?>
<script>
var active_object_uuid = '<?php echo  htmlentities($active_object_uuid) ?>';
</script>

    <div class="scoreboard_top">
        <span class="scoreboard_title"><?php echo s($objecttitle)?></span>
        
        <span class="new_round_button"><input type="image" alt="New Round" width="169" height="71" src="images/new_round.png"</span>
        
    </div>       
    <div id="tabs">
        <ul>
            <li><a href="#tabs-1"><span>Scores</span></a></li>
            <li><a href="#tabs-2"><span>Add Players</span></a></li>
        </ul>
        <div id="tabs-1">

            <div style="display:none" class="group divider above_scores"><?php echo  s(get_string($group_name, 'sloodle')) ?>
                 <? s(get_string('scoreboard:displayedonscreen', 'sloodle'));?> 
                 - 
                 <?php echo  s($currency->name) ?>
            </div>
            <div id="scorelist_scrollpane">
                 <ul id="scorelist" class='admin_view' data-refresh-seconds="<?php echo intval($refreshtime) ?>" data-parent="roundlist" title="Scores" selected="true">
                        <?php
                       /*
                         $student_scores =array();
                        $dummy_object= new stdClass();
                        $dummy_object->userid="7";
                        $dummy_object->avname="Edmund Edgar fake";
                        $dummy_object->has_scores=TRUE;
                        $dummy_object->balance=1234567890;
                        $dummy_object->name_html="Edmund Edgar";
                        $student_scores[]=$dummy_object;
                        
                        $dummy_object= new stdClass();
                        $dummy_object->userid="8";
                        $dummy_object->avname="Fire Centaur fake";
                        $dummy_object->has_scores=TRUE;
                        $dummy_object->balance=0;
                        $dummy_object->name_html="Fire Centaur fake";
                        $student_scores[]=$dummy_object;
                         */
                        $ranki = 1;
                        foreach($student_scores as $score) { 
                         //   krumo($score);
                         
                            if ($score->has_scores) {
                               $j=0;
                            //  for($j=0;$j<10;$j++)
                                render_score_li($score, $is_admin, $ranki); 
                                $ranki++;
                            }
                        }
                        ?>
                        <li style="display:none" class="divider below_scores"></li>
                </ul>
            </div>
         </div>
        <div id="tabs-2">
        
            <div >
            
            <?php // krumo($student_scores); ?>
                <div class="scoreboard_admin_main">
                    <ul>
                        <li class="group divider above_no_scores"></li>
                        <?php
                          
                            $ranki = 1;
                            foreach($student_scores as $score) { 
                                     // krumo($score);
                                if ($score->has_scores==false) {
                                    render_score_li($score, $is_admin, $ranki); 
                                     $ranki++;
                                }
                            }
        
                        ?>
        
                    </ul>
                    <ul style="display:none" >
                        <li class="divider end below_no_scores"></li>
                    </ul>
               </div>
                <?php
                $dummy_score = new stdClass();
                $dummy_score->avname = '';
                $dummy_score->userid = 0;
                $dummy_score->has_scores = true;
                ?>
                <ul style="display:none" class="dummy_item_template" id="dummy_score_ul"> 
                <?php render_score_li( $dummy_score, $is_admin ); ?>
                </ul>
                <div class="scoreboard_admin_bottom"></div>
              </div>
        </div>
    </div>
    <div class="scoreboard_bottom"></div>
<?php 
}    

function render_score_li($score, $is_admin, $rank_number) { 
?>
        <li class="<?php echo  $score->has_scores ? 'has_scores' : 'no_scores' ?> score_entry" id="student_score_<?php echo  intval($score->userid) ?>" data-userid="<?php echo  intval($score->userid) ?>" data-dirty-change="0" data-last-clean-ts="0" >
        <span class="user_score_delete_link" ></span>
        <span class="position_number" ><?php echo $rank_number?></span>
         <span class="avatar_name"><?php echo  s( $score->avname ) ?></span>
        <span class="show_link score_change" data-score-change="0"><?php echo  s(get_string('scoreboard:showonscoreboard', 'sloodle')) ?></span>
    <?php
        foreach( array("+1","+5","+25","+100","-100","-25","-5","-1") as $score_change ) {
            
            $class_name = ( ( $score_change > 0 ) ? 'plus' : 'minus' ).abs($score_change);
    ?>
            <span class="score_change <?php echo  $class_name?>" data-score-change="<?php echo intval($score_change) ?>"></span>
    <?php
        }
    ?>

        <span class="score_info"><?php echo  intval($score->balance) ?></span>
    </li>
    <?php
}
 

?>
<?php 
function print_html_bottom() {
?>
</div>
<!--
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
    width="40"
    height="40"
    id="audio1"
    align="middle">
    <embed src="wavplayer.swf?gui=none&sound=success.wav&"
        bgcolor="#ffffff"
        width="40"
        height="40"
        allowScriptAccess="always"
        type="application/x-shockwave-flash"
        pluginspage="http://www.macromedia.com/go/getflashplayer"
    />
</object>
-->

</body>
</html>
  <?php
} 
?>


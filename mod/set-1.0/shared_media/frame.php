<html>
<head>
<title>SLOODLE Rezzer Configuration</title>
<script language="JavaScript">
<?php
// The rezzer configuration screen div at the bottom of the page should be visible if we're not already on the rezzer configuration screen.
// Once we get there, it should hide itself.
?>
function togglePageResetDiv(currentURL) {
    var rightPlacePattern = '/mod/sloodle/mod/set-1.0/shared_media/index.php';
    // This will be null or undefined if the user has browsed to a different site.
    // Make sure we have a string so indexOf comparisons don't break.
    if (!currentURL || !currentURL.indexOf) {
        currentURL = '';
        document.getElementById('back_to_rezzer_bar').style.display = 'none';
        return;
    }
    if ( (currentURL.indexOf(rightPlacePattern) == -1) && (currentURL.indexOf('/login/index.php') == -1) ) {
        <?php
        // Hide the bottom bar if we're on the user login page, as it won't help us anyway.
        // If you have a different login flow caused by another plugin or something it will still show up
        // ...which isn't ideal, but isn't too terrible either.
        ?>
        document.getElementById('back_to_rezzer_bar').style.display = 'block';
    } else {
        document.getElementById('back_to_rezzer_bar').style.display = 'none';
    }
}
</script>
</head>
<body style="overflow:hidden;margin:0px;"> 
<iframe id="main_frame" onLoad="togglePageResetDiv(this.contentWindow.location.href);" name="main" style="width:100%;height:100%;border:0px;overflow:auto;" src="index.php?<?php echo $_SERVER['QUERY_STRING']; ?>"> 
Loading
</iframe>
<div id="back_to_rezzer_bar" style="width:100%;position:absolute;bottom:0px;background-color:gray;z-index:10;margin:0px;display:none"><a style="font-family:Helvetica;font-weight:bold;font-size:28px;color:white;margin-left:10px;margin:4px;text-decoration:none" target="main" href="index.php?<?php echo $_SERVER['QUERY_STRING']; ?>">&lt; Back To Rezzer Configuration Screen</a></div>
</body> 
</html>

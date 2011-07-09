
	var last_update = 0; // Millisecond TS for when we last polled the server for active object changes
	var refreshtime = 0;
	var view_type = null;

	function refresh_changed_scores() {
		$.getJSON(  
			"refresh_changed_scores.php",  
			{
				sloodleobjuuid: active_object_uuid,
				last_update: last_update
			},  
			function(json) {  
				var result = json.result;
				if (result == 'refreshed') {
					for(var userid in json.updated_scores) {
						var score = json.updated_scores[userid];
						var changedscorejq = $('#student_score_'+userid);
					
						// TODO: If missing, create
						if (changedscorejq.size() == 0) {
							changedscorejq = $('#student_score_0').clone();
							 $('#scorelist').find('li.group').after(changedscorejq);
							changedscorejq.attr('id', 'student_score_'+userid);
							changedscorejq.find('.avatar_name').html( score.name_html );
							changedscorejq.removeClass('dummy_item_template');
						}
						changedscorejq.find('.score_info').html( score.balance );
						if ( ( view_type != 'admin_view' ) && (!json.updated_scores[userid].has_scores) ){
							changedscorejq.remove();
						}
						update_position(changedscorejq);
					}
					//itemjq.removeClass('syncing').addClass("synced");
				} else if (result == 'failed') {
					alert('failed');
				} else {
					alert('refresh returned unknown status');
				}
			}  
		);  
	}

	function update_position(changedscorejq) {
		var balance = parseInt( changedscorejq.find('.score_info').html() );
		var has_scores = changedscorejq.hasClass('has_scores');
		var prevjq;
		var nextjq;
		while (prevjq = changedscorejq.prev()) {
			// If we don't have a score, never put us above something that does.
			if (!has_scores && prevjq.hasClass('has_scores')) {
				break;
			}
			// If we don't have score info, there's something wrong.
			if (prevjq.find('.score_info').length == 0) {
				break;
			}
			if ( has_scores && !prevjq.hasClass('has_scores') ) { // always go above something with no scores
				prevjq.before(changedscorejq);	
				continue;
			}
			// within things that both have scores, go higher if our score is higher.
			var prev_balance = parseInt( prevjq.find('.score_info').html() );
			if (balance <= prev_balance) {
				break;
			}
			prevjq.before(changedscorejq);	
		}
		while (nextjq = changedscorejq.next()) {
			// If I have scores, never go below someone with no scores
			if (has_scores && !nextjq.hasClass('has_scores')) {
				break;
			}
			// If we don't have score info, there's something wrong.
			if (nextjq.find('.score_info').length == 0) {
				break;
			}
			// If I don't have scores but the next guy does, go below him
			if (!has_scores && nextjq.hasClass('has_scores') ) {
				nextjq.after(changedscorejq);	
				continue;
			}
			var next_balance = parseInt( nextjq.find('.score_info').html() );
			if (next_balance <= balance) {
				break;
			}
			nextjq.after(changedscorejq);	
		}

	}

	function update_score_for_hash_change( hashval ) {
		// If we're on the admin view, we'll pull all the scores to make absolutely sure we've got the latest data.
		//if (view_type == 'admin_view') { 
			return refresh_changed_scores();
		//}
		// For everyone else, we'll just add whatever the hash says.
		var bits = hashval.split("_");
		var useridstr = bits[0];
		var useridbits = useridstr.split('#');
		var userid = useridbits[1];
		var balance = bits[1];
		var changedscorejq = $('#student_score_'+userid);

		// Don't have this user yet, have to do a full update.
		// Spread this over 10 seconds to avoid everyone hitting the server at once.
		if (changedscorejq.size() == 0) {
			setTimeout( 'refresh_changed_scores()', Math.random() * 10 * 1000 );
			return;
		}

		changedscorejq.find('.score_info').html( balance );
		update_position(changedscorejq);
	}

	function attach_event_handlers() {
		if ($('#scorelist').hasClass('admin_view')) {
			view_type = 'admin_view';
		} else {
			view_type = 'student_view';
		}
		$().find('#update_score_list_link').unbind('click').click( function() {
			return refresh_changed_scores();
		});
		$(window).hashchange(function(){
			//Insert event to be triggered on has change.
			update_score_for_hash_change( window.location.hash );
		})
		$().find('.score_change').unbind('click').click( function() {
			return change_score($(this));
		});
		$().find('.user_score_delete_link').unbind('click').click( function() {
			return delete_scores($(this));
		});
		$('#save_dirty_link').unbind('click').click( function() {
			return save_dirty_scores();
		});
		 //enable_slide_navigation();

	}

	function delete_scores(changespanjq) {

		var parentlijq = changespanjq.closest('li');
		parentlijq.addClass('deleting_scores');

		var deleteuserid = parentlijq.attr('data-userid');

		$.getJSON(  
			"delete_scores.php",  
			{
				sloodleobjuuid: active_object_uuid,
				userid: deleteuserid,
				last_update: last_update
			},  
			function(json) {  
				var result = json.result;
				if (result == 'deleted') {
					parentlijq.removeClass('deleting_scores');
					parentlijq.removeClass('has_scores');
					parentlijq.addClass('no_scores');
					parentlijq.find('.score_info').html( 0 );
					update_position(parentlijq);
				// TODO: On failure, remove the scores that couldn't be saved.
				} else {
					parentlijq.removeClass('deleting_scores');
					//handle_save_error( useridscorehash );
				}
			}
		); 


	}

	function change_score(changespanjq) {

		var changeby = parseInt( changespanjq.attr('data-score-change') );	
		var parentlijq = changespanjq.closest('li');
		parentlijq.addClass('has_dirty_scores');
		parentlijq.removeClass('no_scores');
		parentlijq.addClass('has_scores');
		parentlijq.attr('data-dirty-change', parseInt(parentlijq.attr('data-dirty-change')) + changeby);
		parentlijq.find('.score_info').html( parseInt(parentlijq.find('.score_info').html()) + changeby );
		setTimeout( function() { 
			update_position(parentlijq);
			},
			750
		);
		parentlijq.addClass('just_edited');
		setTimeout( function() { 
				parentlijq.removeClass('just_edited');
			}, 
			1500	
		);
		

		// TODO: Might be better to wait a few seconds then do this on a timer.
		save_dirty_scores(); // NB This will only do something if there's no pending score save request.
		
	}

	// 
	function save_dirty_scores() {

		var useridarg = '';
		var userscorearg = '';
		var useridscorehash = new Array();
		// Sometimes this will have nothing to do, if the dirty scores are in the process of being saved.
		if ($('li.has_dirty_scores').not('.saving_scores').size() == 0) {
			return true;
		}
		$('li.has_dirty_scores').not('saving_scores').each( function() {
			var changeduserid = $(this).attr('data-userid');
			var changeduserscore = $(this).attr('data-dirty-change');
			useridscorehash[ changeduserid ] = changeduserscore; // Store this in case the request fails and we have to revert the change.
			useridarg = useridarg + changeduserid + '&';
			userscorearg = userscorearg + changeduserscore + '&';
			$(this).removeClass('has_dirty_scores');
			$(this).attr('data-dirty-change', 0);
			$(this).addClass('saving_scores');
		} );

		// Make sure we get errors, even if it's a timeout or a non-parseable response
		$.ajaxSetup({"error":function(XMLHttpRequest,textStatus, errorThrown) {   
			handle_save_error( useridscorehash );
		}});

		$.getJSON(  
			"modify_scores.php",  
			{
				sloodleobjuuid: active_object_uuid,
				'userids[]': useridarg,
				'userscores[]': userscorearg,
				last_update: last_update
			},  
			function(json) {  
				var result = json.result;
				if (result == 'updated') {
					for(var userid in json.updated_scores) {
						var changedscorejq = $('#student_score_'+userid);
						var score = json.updated_scores[userid] + changedscorejq.attr('data-dirty-change');
						changedscorejq.find('.score_info').html( score.balance );
						changedscorejq.removeClass('saving_scores');
						update_position(changedscorejq);
						// There may be some scores that queued up waiting for us to finish, so save them.
						save_dirty_scores();
					}
				// TODO: On failure, remove the scores that couldn't be saved.
				} else {
					handle_save_error( useridscorehash );
				}
			}
		); 

	}

	function handle_save_error(useridscorehash) {
		for(var userid in useridscorehash) {
			var revertscorechange = useridscorehash[ userid ];
			var changedscorejq = $('#student_score_'+userid);
			var displayedscore = changedscorejq.find('.score_info').html() - revertscorechange;
			changedscorejq.find('.score_info').html(displayedscore); 
			changedscorejq.removeClass('saving_scores');
			update_position(changedscorejq);
		}
		save_dirty_scores();
	}

	$(document).ready(function () {
		attach_event_handlers();
		$('#backButton').show();
	//	iui.animOn = true;
		initialize_refresh_heartbeat();
	});

	function initialize_refresh_heartbeat() {
		refreshtime = $('#scorelist').attr('data-refresh-seconds');
		if (refreshtime == 0) {
			return false;
		}
		// To avoid everyone hitting the server at the same time, start on a random fraction of the normal refresh interval.
		var firsttimer = ( Math.random() * refreshtime * 1000 );
		setTimeout( 'refresh_heartbeat()', firsttimer);
	}

	function refresh_heartbeat() {
		if (refreshtime == 0) {
			return false;
		}
		refresh_changed_scores();
		setTimeout( 'refresh_heartbeat()', refreshtime * 1000);
	}

	function backLevels(fromPageID, num) {
		if (isBusy) {
			return;
		}
		if (num < 1) {
			return false;
		}
		// Already moved on? Leave the navigation alone
		if ( $('#'+fromPageID).attr('selected') != 'true' ) {
			alert(fromPageID + ' not currently selected, not going back levels - attr is '+$('#'+fromPageID).attr('id'));
			return false;
		}

		var nextPageID = $('#'+fromPageID).attr('data-parent');
		if (nextPageID == null) {
			alert('no next page to go to, giving up');
			return false;
		}

		fromPage = document.getElementById( fromPageID );
		toPage   = document.getElementById( nextPageID );
		//targetjq.attr('selected','true'); // Select the target

		targetjq = $('#'+nextPageID);

		// Something went wrong - do the best we can, using jquery
		if ( (fromPage == null) || (toPage == null) ) {
			targetjq.attr('selected','true'); // Select the target
			$('[selected*="true"]').attr('selected','');
		} else {
			slidePages(fromPage, toPage, true);
		}

		var parentid = targetjq.attr('data-parent');
		/*
		if ( (parentid == '') || (parentid == null) ){
			alert('Error: parent id not set in link to '+clickedid);
			return false;
		}
		*/
		$('#backButton').attr('href', '#'+parentid);
		$('#backButton').html( $('#'+parentid).attr('title') );
		$('#backButton').show();
		$('#pageTitle').html( targetjq.attr('title') );
			
		fromPageID = nextPageID;
		num--;

		setTimeout( "backLevels('"+fromPageID+"', "+num+")", 1000 );
	}

	function populate_student_edit_form( linkjq ) {

		editformjq = $('#edit_student');
		avname = linkjq.find('.avatar_name').html();
		editformjq.find('#student_name_span').html(avname);

	}

	// More-or-less duplicates the IUI functionality
	// ...but does it without messing with the URL
	// ...as the on-prim browser loses the pending javascript events when it changes the URL #hash
	// Also, uses the 
	function enable_slide_navigation() {
		$('a').live('click', function() {

			if (isBusy) {
				return;
			}

			if ($(this).hasClass('student_edit_link')) {
				populate_student_edit_form( $(this) );
			}

			var clickedid=this.hash;
			if ( clickedid == null ) {
				alert('Error: no hash found');
				return false;
			}

			if (clickedid == "#sitelist") {
				window.location = $('#sitelist').attr('data-parent-url');
				return false;
			}

			var targetjq = $(clickedid); // already begins with #
			if (targetjq.size() == 0) {
				alert('Error: no target found for id '+clickedid);
				return false;
			}

			var backwards = ($(this).attr('id') == 'backButton');

			fromPage = document.getElementById( $('[selected*="true"]').attr('id') );
			toPage   = document.getElementById( targetjq.attr('id') );
			//targetjq.attr('selected','true'); // Select the target

			// Something went wrong - do the best we can, using jquery
			if ( (fromPage == null) || (toPage == null) ) {
				targetjq.attr('selected','true'); // Select the target
				$('[selected*="true"]').attr('selected','');
			} else {
				slidePages(fromPage, toPage, backwards);
			}

			var parentid = targetjq.attr('data-parent');
			if ( (parentid == '') || (parentid == null) ){
				//alert('Error: parent id not set in link to '+clickedid);
				return false;
			}
			$('#backButton').attr('href', '#'+parentid);
			$('#backButton').html( $('#'+parentid).attr('title') );
			$('#backButton').show();
			$('#pageTitle').html( targetjq.attr('title') );
 
			return false;
		});
	}

var slideSpeed = 2;
var slideInterval = 0;

var currentPage = null;
var currentDialog = null;
var currentWidth = 0;
var currentHash = location.hash;
var hashPrefix = "#_";
var pageHistory = [];
var newPageCount = 0;
var checkTimer;
var hasOrientationEvent = false;
var portraitVal = "portrait";
var landscapeVal = "landscape";

var isBusy = false;

// The following comes from iui
function slide1(fromPage, toPage, backwards, axis, cb)
{

	if (axis == "y")
		(backwards ? fromPage : toPage).style.top = "100%";
	else
		toPage.style.left = "100%";

	scrollTo(0, 1);
	toPage.setAttribute("selected", "true");
	var percent = 100;
	slide();
	var timer = setInterval(slide, slideInterval);

	function slide()
	{
		percent -= slideSpeed;
		if (percent <= 0)
		{
			percent = 0;
			clearInterval(timer);
			cb();
		}
	
		if (axis == "y")
		{
			backwards
				? fromPage.style.top = (100-percent) + "%"
				: toPage.style.top = percent + "%";
		}
		else
		{
			fromPage.style.left = (backwards ? (100-percent) : (percent-100)) + "%"; 
			toPage.style.left = (backwards ? -percent : percent) + "%"; 
		}
	}
}

function slide2(fromPage, toPage, backwards, cb)
{
	toPage.style.webkitTransitionDuration = '0ms'; // Turn off transitions to set toPage start offset
	// fromStart is always 0% and toEnd is always 0%
	// iPhone won't take % width on toPage
	var toStart = 'translateX(' + (backwards ? '-' : '') + window.innerWidth +	'px)';
	var fromEnd = 'translateX(' + (backwards ? '100%' : '-100%') + ')';
	toPage.style.webkitTransform = toStart;
	toPage.setAttribute("selected", "true");
	toPage.style.webkitTransitionDuration = '';	  // Turn transitions back on
	function startTrans()
	{
		fromPage.style.webkitTransform = fromEnd;
		toPage.style.webkitTransform = 'translateX(0%)'; //toEnd
	}
	fromPage.addEventListener('webkitTransitionEnd', cb, false);
	setTimeout(startTrans, 0);
}

function slidePages(fromPage, toPage, backwards)
{		 

	if (isBusy) {
		return;
	}
	isBusy = true;

	var axis = (backwards ? fromPage : toPage).getAttribute("axis");

	clearInterval(checkTimer);
	
	if (canDoSlideAnim() && axis != 'y')
	{
	  slide2(fromPage, toPage, backwards, slideDone);
	}
	else
	{
	  slide1(fromPage, toPage, backwards, axis, slideDone);
	}

	function slideDone()
	{
	  if (!hasClass(toPage, "dialog"))
		  fromPage.removeAttribute("selected");
	  //setTimeout(updatePage, 0, toPage, fromPage);
	  fromPage.removeEventListener('webkitTransitionEnd', slideDone, false);
	  isBusy = false;
	}
}

function canDoSlideAnim()
{
  return (typeof WebKitCSSMatrix == "object");
}

function findParent(node, localName)
{
        while (node && (node.nodeType != 1 || node.localName.toLowerCase() != localName))
                node = node.parentNode;
        return node;
}

function hasClass(self, name)
{
        var re = new RegExp("(^|\\s)"+name+"(iui_gid|\\s)");
        return re.exec(self.getAttribute("class")) != null;
}




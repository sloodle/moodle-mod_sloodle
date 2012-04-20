
	var last_update = 0; // Millisecond TS for when we last polled the server for active object changes
	var refreshtime = 0;
	var view_type = null;
    
   
    
    
      
	var user_timeouts = {};

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
					
						var just_edited_class = '';

						// TODO: If missing, create
						if (changedscorejq.size() == 0) {
							changedscorejq = $('#student_score_0').clone();
							 $('#scorelist').find('li.below_scores').before(changedscorejq);
							changedscorejq.attr('id', 'student_score_'+userid);
							changedscorejq.find('.avatar_name').html( score.name_html );
							changedscorejq.removeClass('dummy_item_template');
							changedscorejq.removeClass('no_scores');
							changedscorejq.addClass('has_scores');
						} else {
/*
							var previous_score = parseInt(changedscorejq.find('.score_info').html());
							if (previous_score != undefined) {
								if (score > previous_score) {
									just_edited_class= 'just_added';
								} else if (score < previous_score) {
									just_edited_class = 'just_subtracted';
								}
							}
*/
						}
						changedscorejq.find('.score_info').html( score.balance );
						if ( ( view_type != 'admin_view' ) && (!json.updated_scores[userid].has_scores) ){
							changedscorejq.remove();
						}

/*
						if ( ( view_type != 'admin_view' ) && (just_edited_class != '') ) {
							changedscorejq.addClass(just_edited_class);
							setTimeout( function() {
								changedscorejq.removeClass(just_edited_class);
								},
								1500
							);
						}
*/
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
		var i = 0;
		while (prevjq = changedscorejq.prev()) {
			i++;
			// This shouldn't happen, but stop us going into an infinite loop and hanging the browser if something goes wrong.
			if (i>1000) {
				break;
			}
			// If we don't have a score, never put us above something that does.
			if (!has_scores && prevjq.hasClass('has_scores')) {
				break;
			}
			// If we don't have score info, there's something wrong.
			if (prevjq.find('.score_info').length == 0) {
				if (has_scores) {
					// if we're at the top of the no-score section, jump to the bottom of the score section.
					if ( prevjq.hasClass('above_no_scores') ) {
						$('.below_scores').before(changedscorejq);
						continue;
					}
				}
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
				if (!has_scores) {
					// if we're at the top of the no-score section, jump to the bottom of the score section.
					if ( nextjq.hasClass('below_scores') ) {
						$('.above_no_scores').after(changedscorejq);
						continue;
					}
				}
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
          
           var scorelist_scrollpane = $('#scorelist_scrollpane');
           var admin_scrollpane = $('#admin_scrollpane');
           var admin_scrollpane_api = scorelist_scrollpane.data('jsp');
           var scorelist_scrollpane_api = scorelist_scrollpane.data('jsp');

        if (scorelist_scrollpane_api){
            scorelist_scrollpane_api.reinitialise();    
        }
        if (admin_scrollpane_api){
            admin_scrollpane_api.reinitialise();
        }
    
		$('.no_scores').find('.avatar_name').unbind('click').click( function() {
			return change_score($(this));
		});

		update_rank_numbers();
//doPlay();

	}
/*
function getPlayer(pid) {
        var obj = document.getElementById(pid);
        if (obj.doPlay) return obj;
        for(i=0; i<obj.childNodes.length; i++) {
                var child = obj.childNodes[i];
                if (child.tagName == "EMBED") return child;
        }
}
function doPlay(fname) {
        var player=getPlayer("audio1");
        player.play(fname);
}
function doStop() {
        var player=getPlayer("audio1");
        player.doStop();
}
*/


	function update_rank_numbers() {
		var i=1;
		$('span.position_number').each( function() {
			$(this).html(i);
			i++;
		});
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

	function switch_to_new_round() {

		$.getJSON(  
			"new_round.php",  
			{
				sloodleobjuuid: active_object_uuid,
			},  
			function(json) {  
				var result = json.result;
				if (result == 'started') {
//TODO: Get a response with all the latest scores, use that
					refresh_changed_scores();
				// TODO: On failure, remove the scores that couldn't be saved.
				} else {
					alert('new round start failed');
					//handle_save_error( useridscorehash );
				}
			}
		); 

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
		$('.no_scores').find('.avatar_name').unbind('click').click( function() {
			return change_score($(this));
		});
		$().find('.user_score_delete_link').unbind('click').click( function() {
			return delete_scores($(this));
		});
		$('#save_dirty_link').unbind('click').click( function() {
			return save_dirty_scores();
		});
		$('.new_round_button').unbind('click').click( function() {
			return switch_to_new_round();
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

		var changeby = 0;
		// Show links don't have a data-score-change attribute, but work with a value of 0
		if (changespanjq.attr('data-score-change') != undefined) {
			changeby = parseInt( changespanjq.attr('data-score-change') );	
		}
		var parentlijq = changespanjq.closest('li');
		parentlijq.addClass('has_dirty_scores');
		parentlijq.removeClass('no_scores');
		parentlijq.addClass('has_scores');
		parentlijq.attr('data-dirty-change', parseInt(parentlijq.attr('data-dirty-change')) + changeby);
		parentlijq.find('.score_info').html( parseInt(parentlijq.find('.score_info').html()) + changeby );
		var position_timeout = ( ( changeby == 0 ) ? 0 : 1000 ); // change by zero is showing previously undisplayed name - should do that right away
		setTimeout( function() { 
			update_position(parentlijq);
			},
			position_timeout	
		);
		var just_edited_class = '';
		if (changeby >= 0) {
			just_edited_class = 'just_added';
		} else if (changeby < 0) {
			just_edited_class = 'just_subtracted';
		}
		if (just_edited_class != '') {
			parentlijq.addClass(just_edited_class);
			setTimeout( function() { 
					parentlijq.removeClass(just_edited_class);
				}, 
				1500	
			);
		}
		

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
        var scorelist_scrollpane = $('#scorelist_scrollpane');
        var admin_scrollpane = $('#admin_scrollpane');
        var scorelist_scrollpane_api; 
        var admin_scrollpane_api;
        var settings = {
            
            verticalDragMinHeight: 20,
            verticalDragMaxHeight: 20,
            horizontalDragMinWidth: 20,
            horizontalDragMaxWidth: 20
        };
          if (scorelist_scrollpane){
              $('#tabs').tabs();   
              console.log("scorelist_scrollpane initialized");
              scorelist_scrollpane.jScrollPane(settings);
              scorelist_scrollpane_api = scorelist_scrollpane.data('jsp');
              
          }
        if(admin_scrollpane){
            console.log("admin initialized");
            admin_scrollpane.jScrollPane(settings);
            admin_scrollpane_api = scorelist_scrollpane.data('jsp');
        }
		attach_event_handlers();
		//$('#backButton').show();
	//	iui.animOn = true;
		initialize_refresh_heartbeat();
		preload_css_images();
	});
   function refresh_heartbeat() {
            if (refreshtime == 0) {
                return false;
            }
            refresh_changed_scores();
            setTimeout( 'refresh_heartbeat()', refreshtime * 1000);
   }
	
    function initialize_refresh_heartbeat() {
        
        refreshtime = $('#scorelist').attr('data-refresh-seconds');
        if (refreshtime == 0) {
            return false;
        }
        // To avoid everyone hitting the server at the same time, start on a random fraction of the normal refresh interval.
        var firsttimer = ( Math.random() * refreshtime * 1000 );
        setTimeout( 'refresh_heartbeat()', firsttimer);
    }

	function preload_css_images() {

		var cssclass = null;
		if (view_type == 'admin_view') {
			cssclass = 'admin_preload';	
                } else {
			cssclass = 'user_preload';	
		}

		for (var i=0; i<10; i++) {
			$('body').append( '<div class="'+cssclass+'"></div>' );
		}

		return true;

	}



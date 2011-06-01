
//	var actionStatus = 'unrezzed'; // The state of the page. Goes to 'rezzed' when you hit the 'rez' button. 

	var timeoutMilliseconds = 30000; // How long until we give up waiting and try again. NB even after this a response may still show up, so we need to be able to handle it.
	var pendingRequests = new Object(); // A list of entries that we've made a request for, and the timestamp in milliseconds when we made them
	var numPendingRequests = 0; // Should correspond to the number of elements in pendingRequests

	var maxPendingRequests = 2; // Max outstanding requests we should have at one time. NB if requests time out but still return, there may be more outstanding.

	var statusPollingInterval= 5; // How often we should poll the server for activeobject updates

	var lastActiveObjectPollMillisecondTS = 0; // Millisecond TS for when we last polled the server for active object changes

	var timer; // Timer var used to coordinate the eventLoop, which checks for outstanding tasks and kicks them off.

	function purgeRequestList() {
	// TODO: Purge the request list of things that have timed out.
	// That will cause the script to try them again next time they get their turn in the eventLoop.
		for (entryid in pendingRequests) {
			if ( ( pendingRequests[""+entryid] + timeoutMilliseconds ) < ( new Date().getTime() ) ) {
				if ( $('#layoutentryid_'+entryid).hasClass('rezzing') ) {
					$('#layoutentryid_'+entryid).removeClass('rezzing').addClass('rezzing_timed_out');
				} else if ( $('#layoutentryid_'+entryid).hasClass('derezzing') ) {
					$('#layoutentryid_'+entryid).removeClass('derezzing').addClass('derezzing_timed_out');
				}
				delete pendingRequests[""+entryid];
				numPendingRequests--;
			}
		}	
	}

	function update_labels() {
	// Make the text of the status descriptions match their CSS classes.
	// (There's probably a cleaner way to do this - maybe better to have the text always be there and visibility depends on the CSS class?
		$('li.waiting_to_rez span.rezzable_item_status').html('Waiting to rez');
		$('li.rezzing_timed_out span.rezzable_item_status').html('Timed out');
		$('li.rezzed span.rezzable_item_status').html('Rezzed');
		$('li.rezzing span.rezzable_item_status').html('Rezzing');
		$('li.rezzing_failed span.rezzable_item_status').html('Rez Failed');
		$('li.derezzing_failed span.rezzable_item_status').html('Derez Failed');
		$('li.waiting_to_derez span.rezzable_item_status').html('Waiting to derez');
		$('li.derezzing_timed_out span.rezzable_item_status').html('Timed out');

		$('li.derezzed span.rezzable_item_status').html('Derezzed');
		$('li.derezzed span.rezzable_item_positioning').html('&nbsp;');

		$('li.derezzing span.rezzable_item_status').html('Derezzing');
		$('li.configured span.rezzable_item_status').html('Ready');

		$('li.syncing span.rezzable_item_positioning').html('Synced position');
		$('li.synced span.rezzable_item_positioning').html('Synced');
		$('li.sync_failed span.rezzable_item_positioning').html('Sync failed');
		$('li.waiting_to_sync span.rezzable_item_positioning').html('Waiting to sync');
	}

	function start_waiting_tasks( itemspan, itemspanjq, parentjq) {
	// Do whatever needs doing for an item.
	// If the class is "waiting_to" something, do that something.
		var bits = itemspan.id.split("_").pop().split("-"); // layoutentryid_1-2-3 becomes an Array(1,2,3)
		var entryid = bits.pop();	
		var layoutid = bits.pop();	
		var controllerid = bits.pop();	
		if ( itemspanjq.hasClass( 'waiting_to_rez' ) ) {
			if (!pendingRequests[""+entryid]) {
				numPendingRequests++;
			}
			pendingRequests[""+entryid] = new Date().getTime();	
			itemspanjq.removeClass( 'waiting_to_rez' );
			itemspanjq.addClass( 'rezzing' );
			rez_layout_item( itemspanjq, entryid, controllerid, parentjq );
		} else if ( itemspanjq.hasClass( 'waiting_to_derez' ) ) {
			if (!pendingRequests[""+entryid]) {
				numPendingRequests++;
			}
			pendingRequests[""+entryid] = new Date().getTime();	
			itemspanjq.removeClass( 'waiting_to_derez' );
			itemspanjq.addClass( 'derezzing' );
			derez_layout_item( itemspanjq, entryid, controllerid, parentjq );
		} else if ( itemspanjq.hasClass( 'waiting_to_sync' ) ) {
			if (!pendingRequests[""+entryid]) {
				numPendingRequests++;
			}
			pendingRequests[""+entryid] = new Date().getTime();	
			itemspanjq.removeClass( 'waiting_to_sync' );
			itemspanjq.addClass( 'syncing' );
			sync_layout_item( itemspanjq, entryid, controllerid );
		}

	}

	function check_done_tasks(parentjq) {
	// Check if all the waiting tasks are complete. 
	// If they are, we can change the actionStatus.
		actionStatus = parentjq.attr('data-action-status');
		if (actionStatus == 'rezzing') {
			if ( ( parentjq.children('li.rezzing').length == 0 ) && ( parentjq.children('li.waiting_to_rez').length == 0 ) ) {
				parentjq.attr('data-action-status', 'rezzed');
				parentjq.children('.rez_all_objects').html('Derez all objects');
				parentjq.children('.rez_all_objects').unbind('click');
				parentjq.children('.rez_all_objects').click(function() {
					start_derez_all(parentjq);
				});
				parentjq.children('.sync_object_positions').show();
			}
		} else if (actionStatus == 'derezzing') {
			if ( ( parentjq.children('li.derezzing').length == 0 ) && ( parentjq.children('li.waiting_to_derez').length == 0 ) ) {
				parentjq.attr('data-action-status', 'derezzed');
				parentjq.children('.rez_all_objects').html('Rez all objects');
				parentjq.children('.rez_all_objects').unbind('click');
				parentjq.children('.rez_all_objects').click(function() {
					start_rez_all(parentjq);
				});
				parentjq.children('.sync_object_positions').hide();
			}
		}

	}

	function eventLoop(parentjq) {

		clearTimeout( timer );

		// Make the text labels match the CSS classes
		update_labels(parentjq);
		update_buttons(parentjq);

		// Clear out any timed-out requests.
		purgeRequestList();

		if (numPendingRequests < maxPendingRequests) { // Go easy on the server / rezzer
			// Check for anything that needs to be done
			parentjq.children('.rezzable_item').each(function(itempos,itemspan) {
				if (numPendingRequests < maxPendingRequests) { 
					start_waiting_tasks( itemspan, $(this), parentjq );	
				}
			});
		}
		
		check_done_tasks(parentjq);

		update_labels(parentjq);

		update_buttons(parentjq);
	//	timer = setTimeout( 'eventLoop()', 10000 );
//		timer = setTimeout( function(){ eventLoop(parentjq); }, 10000 );

	}

	function update_buttons(parentjq) {
		// If there are no objects to rez, show the generated button
		if ( parentjq.children('.rezzable_item').length == 0 ) {
			parentjq.children('.generate_standard_layout').show();
			parentjq.children('.set_configuration_status').hide();
			parentjq.children('.rez_all_objects').hide();
			parentjq.children('.sync_object_positions').hide();

			// allow layout deletion
			parentjq.children('.delete_layout_button').show();
		} else {
			parentjq.children('.generate_standard_layout').hide(); // can't generate a layout if we already have entries
			if (parentjq.attr('data-connection-status') == 'connected') {
				parentjq.children('.set_configuration_status').hide();
				if (parentjq.attr('data-action-status') == 'rezzed') {
					parentjq.children('.sync_object_positions').show();

					parentjq.children('.rez_all_objects').html('Derez all objects');
					parentjq.children('.rez_all_objects').unbind('click');
					parentjq.children('.rez_all_objects').click(function() {
						start_derez_all(parentjq);
					});
					parentjq.children('.rez_all_objects').show();

					// allow layout deletion
					parentjq.children('.delete_layout_button').hide();

				} else if (parentjq.attr('data-action-status') == 'syncing') {
					parentjq.children('.sync_object_positions').show();

					parentjq.children('.rez_all_objects').html('Derez all objects');
					parentjq.children('.rez_all_objects').unbind('click');
					parentjq.children('.rez_all_objects').click(function() {
						start_derez_all(parentjq);
					});
					parentjq.children('.rez_all_objects').show();

					// allow layout deletion
					parentjq.children('.delete_layout_button').hide();

				} else {
					parentjq.children('.sync_object_positions').hide();

					parentjq.children('.rez_all_objects').html('Rez all objects');
					parentjq.children('.rez_all_objects').unbind('click');
					parentjq.children('.rez_all_objects').click(function() {
						start_rez_all(parentjq);
					});
					parentjq.children('.rez_all_objects').show();

					// allow layout deletion
					parentjq.children('.delete_layout_button').show();

				}
			} else {
				parentjq.children('.rez_all_objects').hide();
				parentjq.children('.set_configuration_status').show();
				parentjq.children('.sync_object_positions').hide();
				parentjq.children('.delete_layout_button').show();
			}
		}
	}

	function sync_layout_item(itemjq, entryid, controllerid) {
		$.getJSON(  
			"sync_layout_position.php",  
			{
				layoutentryid: entryid,
				rezzeruuid: rezzer_uuid,
				controllerid: controllerid,
				ts: new Date().getTime()
			},  
			function(json) {  
				var result = json.result;
				if (result == 'synced') {
					itemjq.removeClass('syncing').addClass("synced");
				} else if (result == 'failed') {
					itemjq.removeClass('syncing').addClass('syncing_failed');;
				}
				if (pendingRequests[""+entryid]) {
					delete pendingRequests[""+entryid];
					numPendingRequests--;
				}
				eventLoop( itemjq.closest('.layout_container') );
			}  
		);  
	}


	function rez_layout_item(itemjq, entryid, controllerid, parentjq) {
		$.getJSON(  
			"rez_object.php",  
			{
				layoutentryid: entryid,
				rezzeruuid: rezzer_uuid,
				controllerid: controllerid,
				ts: new Date().getTime()
			},  
			function(json) {  
				var result = json.result;
				if (result == 'rezzed') {
					itemjq.removeClass('rezzing').addClass('rezzed');;
				} else if (result == 'failed') {
					itemjq.removeClass('rezzing').addClass('rezzing_failed');;
				}
				if (pendingRequests[""+entryid]) {
					delete pendingRequests[""+entryid];
					numPendingRequests--;
				}
				eventLoop( parentjq );
			}  
		);  
	}

	function derez_layout_item(itemjq, entryid, controllerid, parentjq) {
//alert('sending derez request with rezzeruuid '+rezzer_uuid);
		$.getJSON(  
			"derez_object.php",  
			{
				layoutentryid: entryid,
				rezzeruuid: rezzer_uuid,
				controllerid: controllerid,
				ts: new Date().getTime()
			},  
			function(json) {  
				var result = json.result;
//alert('derez result:'+result);
				if (result == 'derezzed') {
					itemjq.removeClass('derezzing').addClass('derezzed');;
					itemjq.removeClass('syncing');
					itemjq.removeClass('synced');
					itemjq.removeClass('waiting_to_sync');
					itemjq.removeClass('sync_failed');
					if (itemjq.hasClass('deleted_from_layout')) {
						itemjq.remove(); // TODO: Remove the config form too
					}
				} else if (result == 'failed') {
					itemjq.removeClass('derezzing').addClass('derezzing_failed');;
				}
				if (pendingRequests[""+entryid]) {
					delete pendingRequests[""+entryid];
					numPendingRequests--;
				}
				eventLoop( parentjq );

			}  
		);  
	}

	function start_derez_all(parentjq) {
		parentjq.attr('data-action-status', 'derezzing');
		parentjq.attr('data-rez-mode', 'derezzed');

		parentjq.children('li.rezzed').addClass( 'waiting_to_derez' );
		parentjq.children('li.waiting_to_derez').removeClass('rezzed');
		parentjq.children('.rez_all_objects').html('Stop derezzing objects');
		parentjq.children('.rez_all_objects').unbind('click');
		parentjq.children('.rez_all_objects').click(function() {
			stop_derez_all(parentjq);	
		});
		eventLoop( parentjq );
	}

	function start_rez_all(parentjq) {
		parentjq.attr('data-action-status', 'rezzing');
		parentjq.attr('data-rez-mode', 'rezzed');

		parentjq.children('li.derezzing_failed').removeClass('derezzing_failed');
		parentjq.children('li.rezzing_failed').removeClass('rezzing_failed');
		parentjq.children('li.derezzed').removeClass('derezzed');
		parentjq.children('li.rezzable_item').not('li.rezzed').addClass( 'waiting_to_rez' );
		parentjq.children('.rez_all_objects').html('Stop rezzing objects');
		parentjq.children('.rez_all_objects').unbind('click');
		parentjq.children('.rez_all_objects').click(function() {
			stop_rez_all();	
		});
		eventLoop( parentjq );
	}

	function start_sync_all(parentjq) {
		parentjq.attr('data-action-status', 'syncing');
		parentjq.children('li.rezzed').addClass( 'waiting_to_sync' );
// TODO: Stop stuff
		eventLoop( parentjq );
	}

	function stop_derez_all(parentjq) {
		parentjq.children('li.waiting_to_derez').addClass( 'rezzed' ).removeClass('waiting_to_derez');;
		parentjq.children('.rez_all_objects').html('Derez all objects');
		parentjq.children('.rez_all_objects').unbind('click');
		parentjq.children('.rez_all_objects').click(function() {
			start_derez_all(parentjq);
		});
		eventLoop( parentjq );
	}

	function stop_rez_all(parentjq) {
		parentjq.children('li.rezzable_item').removeClass( 'waiting_to_rez' );
		parentjq.children('.rez_all_objects').html('Rez all objects');
		parentjq.children('.rez_all_objects').unbind('click');
		parentjq.children('.rez_all_objects').click(function() {
			start_rez_all(parentjq);
		});
		eventLoop( parentjq );
	}

	function create_layout( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-creating-text') );
		$.getJSON(  
			"add_layout.php",  
			frmjq.serialize(),
			function(json) {  
				var result = json.result;
				var layoutid = json.layoutid;
				var courseid = json.courseid;
				var layoutname = json.layoutname;
				if (result == 'added') {
					//alert('added');
					buttonjq.html( buttonjq.attr('data-create-text') );
					insert_layout_into_course_divs( layoutid, courseid, layoutname, frmjq);

					$('#add_layout_lists_above_me').before(json.add_layout_lists);
					$('#add_edit_object_forms_above_me').before(json.edit_object_forms);
					$('#add_add_object_forms_above_me').before(json.add_object_forms);
					$('#add_add_object_groups_above_me').before(json.add_object_groups);

					attach_event_handlers();

					backLevels( frmjq.attr('id'), 1 );
					//eventLoop( $('.layout_container_'+layoutid) );
					//history.back();
					//history.go(-1);
				} else if (result == 'failed') {
					//alert('Adding layout entry failed');
					buttonjq.html( buttonjq.attr('data-create-text') );
				}
			}  
		);  
		return false;

	}

	function insert_layout_into_course_divs( layoutid, courseid, layoutname, frmjq ) {
		$('.controllercourselayouts_'+courseid).each( function() {
			var newformid = $(this).attr('data-id-prefix') + layoutid;
			var newli = '<li data-layout-link-li-id="'+layoutid+'"><a class="layout_link" href="#' + newformid + '">'+layoutname+'</a></li>';
			$(this).children('.add_layout_above_me').before( newli );
		});
	}

	function generate_standard_layout( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-generating-text') );
		var layoutid = buttonjq.attr('data-layoutid');
		$.getJSON(  
			"generate_layout_entries.php",  
			{
				layoutid: layoutid,
				ts: new Date().getTime()
			},
			function(json) {  
				var result = json.result;
				if (result == 'generated') {
					buttonjq.html( buttonjq.attr('data-generate-text') );
					var addedentries = json.addedentries;
					var entryi;
					for (entryi = 0; entryi<addedentries.length; entryi++) {
						thisentry = addedentries[entryi];
						//$('.layout_container_'+layoutid).each( function() {
						$('.addobject_layout_'+layoutid+'_'+thisentry['objectcode']).each( function() {
							insert_layout_entry_into_layout_divs( thisentry['layoutid'], thisentry['layoutentryid'], thisentry['objectname'], thisentry['objectgroup'], thisentry['objectgrouptext'], thisentry['objectcode'], thisentry['moduletitle'], $(this) );
						});
					}
					eventLoop( $('.layout_container_'+layoutid) );
				} else if (result == 'failed') {
					alert('Adding layout entry failed');
					buttonjq.html( buttonjq.attr('data-generate-text') );
				}
			}  
		);  
	}

	function add_to_layout( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-adding-text') );
		$.getJSON(  
			"add_layout_entry.php",  
			frmjq.serialize(),
			function(json) {  
				var result = json.result;
				var objectgroup = json.objectgroup;
				var objectgrouptext = json.objectgrouptext;
				var objectname = json.objectname;
				var layoutid = json.layoutid;
				var objectcode = json.objectcode;
				var moduletitle = json.moduletitle;
				var layoutentryid = json.layoutentryid;
				if (result == 'added') {
					buttonjq.html( buttonjq.attr('data-add-text') );
					insert_layout_entry_into_layout_divs( layoutid, layoutentryid, objectname, objectgroup, objectgrouptext, objectcode, moduletitle, frmjq);
					eventLoop( $('.layout_container_'+layoutid) );
					//history.back();
					backLevels( frmjq.attr('id'), 2 );
					//history.go(-2);
				} else if (result == 'failed') {
					//alert('Adding layout entry failed');
					buttonjq.html( buttonjq.attr('data-add-text') );
				}
			}  
		);  
		return false;

	}

	// NB This just removes the object from the layout and marks it for deletion.
	// If rezzed, we'll do the actual of the object with another request.
	function delete_layout_configuration( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-deleting-text') );
		$.getJSON(  
			"delete_layout_entry.php",  
			frmjq.serialize(),
			function(json) {  
				var result = json.result;
				var layoutentryid = json.layoutentryid;
				var layoutid = json.layoutid;
				if ( (result == 'deleted') || (result == 'notfound') ){
					//alert('deleted');
					buttonjq.html( buttonjq.attr('data-delete-text') ); 
					regexPtn = '^layoutentryid_.+-.+-.+-'+layoutentryid+'$';
					var re = new RegExp(regexPtn,"");
					$('li').filter(function() {
						return this.id.match(regexPtn);
					}).each( function() {
						//$(this).remove();
						// TODO: What happens if we're rezzing or waiting to rez?
						// Mark it as deleted and queue it for derezzing, then let the eventLoop deal with it in its own time
						if ($(this).hasClass('rezzed')) {
							$(this).addClass('waiting_to_derez');
							$(this).addClass('deleted_from_layout');
						} else { // Not rezzed, just get rid of it
							$(this).remove();
						}
					});
					eventLoop( $('.layout_container_'+layoutid) );
					backLevels( frmjq.attr('id'), 1 );
				} else { //if (result == 'failed') 
					alert('Deleting layout entry failed');
					buttonjq.html( buttonjq.attr('data-delete-text') );
				} 
			}  
		);  
		return false;

	}

	// NB This just removes the layout from the server and marks it for deletion.
	// If rezzed, we'll derez the objects separately, and only remove the layout from view when they're done
	function delete_layout( buttonjq ) {

		frmjq = buttonjq.closest('ul');
		buttonjq.html( buttonjq.attr('data-deleting-text') );
		var layoutid = buttonjq.attr('data-layoutid');
		$.getJSON(  
			"delete_layout.php",  
			{
				layoutid: layoutid,
				ts: new Date().getTime()
			},
			function(json) {  
				var result = json.result;
				if (result == 'deleted') {
					//alert('deleted');
					$('[data-layout-link-li-id*="'+layoutid+'"]').remove();
					buttonjq.html( buttonjq.attr('data-deleted-text') ); 
					backLevels(frmjq.attr('id'), 1);
					//history.back();
				} else { //if (result == 'failed') 
					// For now we'll just live with the failure - it's probably that it's already gone
					alert('Deleting layout entry failed');
					buttonjq.html( buttonjq.attr('data-delete-text') );
				} 
			}  
		);  
		return false;

	}

	function rename_layout( spanjq ) {

		var inputjq = spanjq.find('.rename_layout_input');
		var newname = inputjq.val();
		var layoutid = inputjq.attr('data-rename-input-layoutid');

		$.getJSON(
			"rename_layout.php",
			{
				layoutid: layoutid,
				layoutname: newname,
				ts: new Date().getTime()
			},
			function(json) {
				if (json.result == 'renamed') {
                                        var orig_title = $('.layout_container_'+layoutid).attr('title');
                                        $('li[data-layout-link-li-id*="'+layoutid+'"]').find('.layout_link').html(newname);
                                        $('.layout_container_'+layoutid).attr('title', newname);
                                        $('.layout_container_'+layoutid).find('.group:first').html(newname);

					// The page title is managed by IUI. 
					// It may have changed while we were waiting for a response, in which case we leave it alone.
					// It'll be fixed next time we click on it.
					if ( $('h1#pageTitle').html() == orig_title ) {
						$('h1#pageTitle').html(newname);
					}

					spanjq.find('.rename_label').show();
					spanjq.find('.rename_input').hide();

				} else {
					alert('Rename failed');
				}
			}
		);

	}

	function clone_layout( buttonjq ) {

		buttonjq.html( buttonjq.attr('data-cloning-text') );
		var layoutid = buttonjq.attr('data-layoutid');
		var frmjq = buttonjq.closest('ul');
		$.getJSON(  
			"clone_layout.php",  
			{
				layoutid: layoutid,
				ts: new Date().getTime()
			},
			function(json) {  
				var result = json.result;
				if (result == 'cloned') {

					buttonjq.html( buttonjq.attr('data-cloned-text') ); 

					layoutid = json.layoutid;
					var layoutname = json.layoutname;
					var courseid = json.courseid;

					insert_layout_into_course_divs( layoutid, courseid, layoutname, null);

					$('#add_layout_lists_above_me').before(json.add_layout_lists);
					$('#add_edit_object_forms_above_me').before(json.edit_object_forms);
					$('#add_add_object_forms_above_me').before(json.add_object_forms);
					$('#add_add_object_groups_above_me').before(json.add_object_groups);

					attach_event_handlers();

					//eventLoop( $('.layout_container_'+layoutid) );
					//history.back();
					//history.go(-1);
					backLevels( frmjq.attr('id'), 1 );

				} else { //if (result == 'failed') 
					// For now we'll just live with the failure - it's probably that it's already gone
					alert('Cloning layout entry failed');
					buttonjq.html( buttonjq.attr('data-clone-text') );
				} 
			}  
		);  
		return false;

	}



	function update_layout_position( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		$.getJSON(  
			"sync_layout_position.php",  
			frmjq.serialize(),
			function(json) {  
				var result = json.result;
			}  
		);  
		return false;

	}

	function update_layout_configuration( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-updating-text') );
		$.getJSON(  
			"update_layout_entry.php",  
			frmjq.serialize(),
			function(json) {  
				var result = json.result;
				var objectgroup = json.objectgroup;
				var objectgrouptext = json.objectgrouptext;
				var layoutentryid = json.layoutentryid;
				var moduletitle= json.moduletitle;
				if (result == 'updated') {
					buttonjq.html( buttonjq.attr('data-update-text') );
					$('li[data-layoutentryid*="'+layoutentryid+'"]').find('.module_info').html(moduletitle);
					backLevels( frmjq.attr('id'), 1 );
					//history.back();
					//history.go(-2);
				} else { //if (result == 'failed') {
					alert('Updating layout entry failed');
					buttonjq.html( buttonjq.attr('data-update-text') );
				} 
			}  
		);  
		return false;

	}

	function insert_layout_entry_into_layout_divs( layoutid, layoutentryid, objectname, objectgroup, objectgrouptext, objectcode, moduletitle, addfrmjq ) {

		regexPtn = '^layout_.+-.+-'+layoutid+'$';
		var re = new RegExp(regexPtn,"");
		$('ul').filter(function() {
			return this.id.match(regexPtn);
		}).each( function() {
			// make an id for the new element	
			var newElementID = $(this).attr('id').replace('layout_','layoutentryid_')+'-'+layoutentryid;

			var rezMode = $(this).attr('data-rez-mode');
			var actionClass = '';
			if (rezMode == 'rezzed') {
				actionClass =' waiting_to_rez';
			}

			// already there
			if ( $(this).children('#'+newElementID).length > 0 ) {
				return;
			}

			// make a list item for the layout screen, and insert it at the bottom of its group.
			var newItem = '<li data-layoutentryid="'+layoutentryid+'" id="'+newElementID+'" class="rezzable_item' + actionClass + '"><a href="#configure_'+newElementID+'">'+objectname+'<span class="module_info">'+moduletitle+'</span>'+'<span class="rezzable_item_status">&nbsp;</span> <span class="rezzable_item_positioning">&nbsp;</span> </a></li>'

			// If we don't yet have a group to put this item in, create it
			if ( $(this).children(".after_group_"+objectgroup).size() == 0 ) {
				var groupLi = '<li class="group">'+objectgrouptext+'</li>' + '<li class="after_group_'+objectgroup+'"></li>';
				$(this).children(".add_object_group").before( groupLi );
			}

			$(this).children(".after_group_"+objectgroup).before(newItem);

			// Make a copy of the add form and change it into an edit form
			var editFrm = addfrmjq.clone(); 
			editFrm.attr('id', 'configure_'+newElementID); 
			editFrm.attr('data-parent', $(this).attr('id')); 
			editFrm.children("input[name='layoutentryid']").val(layoutentryid);  // set the layoutentryid hidden field
			editFrm.attr('selected', ''); // Remove the selected property so that iui hides the form
			editFrm.children('.add_to_layout_button').addClass('update_layout_entry_button').removeClass('add_to_layout_button');
			editFrm.children('.update_layout_entry_button').html( editFrm.children('.update_layout_entry_button:first').attr('data-update-text') );
			editFrm.removeClass('addobject_layout_'+layoutid+'_'+objectcode);


			// We keep a button hidden on the add form to use for deletion when it turns into an edit form
			editFrm.children('.delete_layout_entry_button').removeClass('hiddenButton');
			// Seems like the original click handler doesn't get created initially - maybe because it's hidden?
			editFrm.children('.delete_layout_entry_button').unbind('click').click(function() {
				return delete_layout_configuration($(this));
			});

			$('#add_configuration_above_me_'+$(this).attr('id')).before(editFrm);

			editFrm.unbind('click').click(function() {
				return update_layout_configuration($(this));
			});

		});
		
	}

	function configure_set( layoutlinkjq ) {
		var layoutjqid = layoutlinkjq.attr('href'); // looks like #layout_2-2-1
		var parentjq = $(layoutjqid); // the "#" happens to be the same notation as that used for the jquery id selector
		var bits = parentjq.attr('id').split("_").pop().split("-"); // layoutentryid_1-2-3 becomes an Array(1,2,3)
		var layoutid = bits.pop(); // pop this off - don't think we need it
		var controllerid = bits.pop();
		$.getJSON(  
			"configure_rezzer.php",  
			{
				controllerid: controllerid,
				rezzeruuid: rezzer_uuid,
				ts: new Date().getTime()
			},
			function(json) {  
				var result = json.result;
				if (result == 'configured') {
					parentjq.attr('data-connection-status', 'connected');
					update_buttons( parentjq );
				} else if (result == 'failed') {
					parentjq.children('.rez_all_objects').hide();	
				}
			}  
		);  
		return true;
	}

	function attach_event_handlers() {
		$().find('.create_layout_button').unbind('click').click(function() {
			return create_layout($(this));
		});
		$().find('.layout_link').unbind('click').click(function() {
			return configure_set($(this));
		});
		$().find('.rez_all_objects').hide();
		$().find('.rez_all_objects').unbind('click').click(function() {
			start_rez_all($(this).closest('.layout_container'));
		});
		$().find('.add_to_layout_button').unbind('click').click(function() {
			return add_to_layout($(this));
		});
		$().find('.update_layout_entry_button').unbind('click').click(function() {
			return update_layout_configuration($(this));
		});
		$().find('.delete_layout_entry_button').unbind('click').click(function() {
			return delete_layout_configuration($(this));
		});
		$().find('.sync_object_positions').unbind('click').click(function() {
			start_sync_all( $(this).closest('.layout_container') );
		});
		$().find('.delete_layout_button').unbind('click').click(function() {
			return delete_layout( $(this) );
		});
		$().find('.clone_layout_button').unbind('click').click(function() {
			return clone_layout( $(this) );
		});
		$().find('.generate_standard_layout').unbind('click').click(function() {
			return generate_standard_layout( $(this) );
		});
		$().find('.layout_container').each(function() {
			update_buttons($(this));
			update_labels($(this));
		});

		$('.rename_layout_button').find('.rename_input').hide();

		//$('.rename_layout_button').children('.rename_label').click( function() {
		/*
		$('.rename_layout_button').click( function() {
			$(this).find('.rename_label').hide();
			$(this).find('.rename_layout_input').show();
		});
		*/
		$('.rename_layout_button').each( function(){
			var btn = $(this);
			$(this).children('.rename_label').unbind('click').click( function() {
				$(this).hide();
				btn.find('.rename_input_save_button').unbind('click').click( function() {
					rename_layout( btn );
				});
				btn.find('.rename_input').show();
			});
		});
	}

	$(document).ready(function () {
		attach_event_handlers();
		enable_slide_navigation();
		$('#backButton').show();
	//	iui.animOn = true;
	});

	function backLevels(fromPageID, num) {
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

	// More-or-less duplicates the IUI functionality
	// ...but does it without messing with the URL
	// ...as the on-prim browser loses the pending javascript events when it changes the URL #hash
	// Also, uses the 
	function enable_slide_navigation() {
		$('a').live('click', function() {

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
				alert('Error: no target found');
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
				alert('Error: parent id not set in link to '+clickedid);
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
	  checkTimer = setInterval(checkOrientAndLocation, 300);
	  //setTimeout(updatePage, 0, toPage, fromPage);
	  fromPage.removeEventListener('webkitTransitionEnd', slideDone, false);
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


function orientChangeHandler()
{
	var orientation=window.orientation;
	switch(orientation)
	{
	case 0:
		setOrientation(portraitVal);
		break;	
		
	case 90:
	case -90: 
		setOrientation(landscapeVal);
		break;
	}
}


function checkOrientAndLocation()
{
	if (!hasOrientationEvent)
	{
	  if (window.innerWidth != currentWidth)
	  {	  
		  currentWidth = window.innerWidth;
		  var orient = currentWidth == 320 ? portraitVal : landscapeVal;
		  setOrientation(orient);
	  }
	}

	if (location.hash != currentHash)
	{
		var pageId = location.hash.substr(hashPrefix.length);
		//iui.showPageById(pageId);
	}
}

function setOrientation(orient)
{
	document.body.setAttribute("orient", orient);
	setTimeout(scrollTo, 100, 0, 1);
}

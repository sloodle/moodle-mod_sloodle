
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
		// If there are no objects rezzed, show the generated button
		if ( parentjq.children('.rezzable_item').length == 0 ) {
			parentjq.children('.generate_standard_layout').show();
			parentjq.children('.set_configuration_status').hide();
			parentjq.children('.rez_all_objects').hide();
			parentjq.children('.sync_object_positions').hide();
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

				} else if (parentjq.attr('data-action-status') == 'syncing') {
					parentjq.children('.sync_object_positions').show();

					parentjq.children('.rez_all_objects').html('Derez all objects');
					parentjq.children('.rez_all_objects').unbind('click');
					parentjq.children('.rez_all_objects').click(function() {
						start_derez_all(parentjq);
					});
					parentjq.children('.rez_all_objects').show();


				} else {
					parentjq.children('.sync_object_positions').hide();

					parentjq.children('.rez_all_objects').html('Rez all objects');
					parentjq.children('.rez_all_objects').unbind('click');
					parentjq.children('.rez_all_objects').click(function() {
						start_rez_all(parentjq);
					});
					parentjq.children('.rez_all_objects').show();


				}
			} else {
				parentjq.children('.rez_all_objects').hide();
				parentjq.children('.set_configuration_status').show();
				parentjq.children('.sync_object_positions').hide();
			}
		}
	}

	function sync_layout_item(itemjq, entryid, controllerid) {
		$.getJSON(  
			"sync_layout_position.php",  
			{
				layoutentryid: entryid,
				rezzeruuid: rezzer_uuid,
				controllerid: controllerid
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
				controllerid: controllerid
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
		$.getJSON(  
			"derez_object.php",  
			{
				layoutentryid: entryid,
				rezzeruuid: rezzer_uuid,
				controllerid: controllerid
			},  
			function(json) {  
				var result = json.result;
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
					itemjq.removeClass('rezzing').addClass('derezzing_failed');;
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
		buttonjq.html( buttonjq.attr('data-adding-text') );
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
					buttonjq.html( buttonjq.attr('data-add-text') );
					insert_layout_into_course_divs( layoutid, courseid, layoutname, frmjq);

					$('#add_layout_lists_above_me').before(json.add_layout_lists);
					$('#add_edit_object_forms_above_me').before(json.edit_object_forms);
					$('#add_add_object_forms_above_me').before(json.add_object_forms);
					$('#add_add_object_groups_above_me').before(json.add_object_groups);

					attach_event_handlers();

					//eventLoop( $('.layout_container_'+layoutid) );
					//history.back();
					history.go(-1);
				} else if (result == 'failed') {
					//alert('Adding layout entry failed');
					buttonjq.html( buttonjq.attr('data-add-text') );
				}
			}  
		);  
		return false;

	}

	function insert_layout_into_course_divs( layoutid, courseid, layoutname, frmjq ) {
		$('.controllercourselayouts_'+courseid).each( function() {
			var newformid = $(this).attr('data-id-prefix') + layoutid;
			var newli = '<li><a class="layout_link" href="#' + newformid + '">'+layoutname+'</a></li>';
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
				layoutid: layoutid
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
					history.go(-2);
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
					history.back();
				} else { //if (result == 'failed') 
					alert('Deleting layout entry failed');
					buttonjq.html( buttonjq.attr('data-delete-text') );
				} 
			}  
		);  
		return false;

	}

	// NB This just removes the layout from the server and marks it for deletion.
	// If rezzed, we'll derez the objects seperately, and only remove the layout from view when they're done
	function delete_layout( buttonjq ) {

		buttonjq.html( buttonjq.attr('data-deleting-text') );
		getJSON(  
			"delete_layout.php",  
			{
				layoutid: buttonjq.attr('data-layoutid')
			},
			function(json) {  
				var result = json.result;
				if (result == 'deleted') {
					//alert('deleted');
					buttonjq.html( buttonjq.attr('data-deleted-text') ); 
					alert('TODO: Object derezzing, removal from screens');
					history.back();
				} else { //if (result == 'failed') 
					alert('Deleting layout entry failed');
					buttonjq.html( buttonjq.attr('data-delete-text') );
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
					history.back();
					//history.go(-2);
				} else { //if (result == 'failed') {
					alert('Adding layout entry failed');
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

			var actionStatus = $(this).attr('data-action-status');
			var actionClass = '';
			if ( (actionStatus == 'rezzed') || (actionStatus == 'rezzing') ) {
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
			editFrm.children("input[name='layoutentryid']").val(layoutentryid);  // set the layoutentryid hidden field
			editFrm.attr('selected', ''); // Remove the selected property so that iui hides the form
			editFrm.children('.add_to_layout_button').addClass('update_layout_entry_button').removeClass('add_to_layout_button');
			editFrm.children('.update_layout_entry_button').html( editFrm.children('.update_layout_entry_button:first').attr('data-update-text') );
			editFrm.removeClass('addobject_layout_'+layoutid+'_'+objectcode);


			// We keep a button hidden on the add form to use for deletion when it turns into an edit form
			editFrm.children('.delete_layout_entry_button').removeClass('hiddenButton');
			// Seems like the original click handler doesn't get created initially - maybe because it's hidden?
			editFrm.children('.delete_layout_entry_button').click(function() {
				return delete_layout_configuration($(this));
			});

			$('#add_configuration_above_me_'+$(this).attr('id')).before(editFrm);

			editFrm.click(function() {
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
				rezzeruuid: rezzer_uuid
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
		$('.create_layout_button').click(function() {
			return create_layout($(this));
		});
		$('.layout_link').click(function() {
			return configure_set($(this));
		});
		$('.rez_all_objects').hide();
		$('.rez_all_objects').click(function() {
			start_rez_all($(this).closest('.layout_container'));
		});
		$('.add_to_layout_button').click(function() {
			return add_to_layout($(this));
		});
		$('.update_layout_entry_button').click(function() {
			return update_layout_configuration($(this));
		});
		$('.delete_layout_entry_button').click(function() {
			return delete_layout_configuration($(this));
		});
		$('.sync_object_positions').click(function() {
			start_sync_all( $(this).closest('.layout_container') );
		});
		$('.delete_layout_button').click(function() {
			return delete_layout( $(this) );
		});
		$('.generate_standard_layout').click(function() {
			return generate_standard_layout( $(this) );
		});
		$('.layout_container').each(function() {
			update_buttons($(this));
			update_labels($(this));
		});
	}

	$(document).ready(function () {
		attach_event_handlers();
	});

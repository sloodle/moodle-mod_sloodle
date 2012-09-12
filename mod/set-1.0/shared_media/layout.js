
//	var actionStatus = 'unrezzed'; // The state of the page. Goes to 'rezzed' when you hit the 'rez' button. 

	var timeoutMilliseconds = 30000; // How long until we give up waiting and try again. NB even after this a response may still show up, so we need to be able to handle it.
	var pendingRequests = new Object(); // A list of entries that we've made a request for, and the timestamp in milliseconds when we made them
	var numPendingRequests = 0; // Should correspond to the number of elements in pendingRequests

	var maxPendingRequests = 2; // Max outstanding requests we should have at one time. NB if requests time out but still return, there may be more outstanding.

	var statusPollingInterval= 5; // How often we should poll the server for activeobject updates

	var lastActiveObjectPollMillisecondTS = 0; // Millisecond TS for when we last polled the server for active object changes

	var timer; // Timer var used to coordinate the eventLoop, which checks for outstanding tasks and kicks them off.
    var heartbeatTimer;

	var isRezzerConfigured = false;
	var rezzerControllerID = null;
    var activeLayoutID = 0;
	
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

		$('li.syncing span.rezzable_item_positioning').html('Syncing position');
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

			// TODO: Stop sharing layouts between controllers and kill this
			$(".rezzable_item [data-layoutentryid='"+itemspanjq.attr('data-layoutentryid')+"']").removeClass( 'waiting_to_rez' );
			$(".rezzable_item [data-layoutentryid='"+itemspanjq.attr('data-layoutentryid')+"']").addClass( 'rezzing' );

			rez_layout_item( itemspanjq, entryid, controllerid, parentjq );
		} else if ( itemspanjq.hasClass( 'waiting_to_derez' ) ) {
			if (!pendingRequests[""+entryid]) {
				numPendingRequests++;
			}
			pendingRequests[""+entryid] = new Date().getTime();	
			itemspanjq.removeClass( 'waiting_to_derez' );
			itemspanjq.addClass( 'derezzing' );

			// TODO: Stop sharing layouts between controllers and kill this
			$(".rezzable_item [data-layoutentryid='"+itemspanjq.attr('data-layoutentryid')+"']").removeClass( 'waiting_to_derez' );
			$(".rezzable_item [data-layoutentryid='"+itemspanjq.attr('data-layoutentryid')+"']").addClass( 'derezzing' );

			derez_layout_item( itemspanjq, entryid, controllerid, parentjq );
		} else if ( itemspanjq.hasClass( 'waiting_to_sync' ) ) {
			if (!pendingRequests[""+entryid]) {
				numPendingRequests++;
			}
			pendingRequests[""+entryid] = new Date().getTime();	
			itemspanjq.removeClass( 'waiting_to_sync' );
			itemspanjq.addClass( 'syncing' );

			// TODO: Stop sharing layouts between controllers and kill this
			$(".rezzable_item [data-layoutentryid='"+itemspanjq.attr('data-layoutentryid')+"']").removeClass( 'waiting_to_sync' );
			$(".rezzable_item [data-layoutentryid='"+itemspanjq.attr('data-layoutentryid')+"']").addClass( 'syncing' );

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
                parentjq.find('.rez_all_objects').html('Rez all');
                parentjq.find('.rez_all_objects').unbind('click');
                parentjq.find('.rez_all_objects').click(function() {
                    start_rez_all(parentjq);	
                });

			}
		} else if (actionStatus == 'derezzing') {
			if ( ( parentjq.children('li.derezzing').length == 0 ) && ( parentjq.children('li.waiting_to_derez').length == 0 ) ) {
				parentjq.attr('data-action-status', 'derezzed');
                parentjq.find('.derez_all_objects').html('Derez all');
                parentjq.find('.derez_all_objects').unbind('click');
                parentjq.find('.derez_all_objects').click(function() {
                    start_derez_all(parentjq);	
                });

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
        var rezzable_items_jq = parentjq.children('.rezzable_item');
        var num_rezzable = rezzable_items_jq.length;

		if (num_rezzable  == 0 ) {

			parentjq.find('.sync_object_positions').css('visibility','hidden');

			// allow layout deletion
			parentjq.find('.delete_layout_button').css('visibility','visible')

            parentjq.find('.derez_all_objects').css('visibility','hidden');

            // The generate button takes the place of the rez all button, so we hide() one and show() the other.
            // All the other buttons keep their positions, so we make them invisible with css.
            parentjq.find('.rez_all_objects').hide();
			parentjq.find('.generate_standard_layout').show();

        } else {

            parentjq.find('.rez_all_objects').show();
            parentjq.find('.generate_standard_layout').hide(); // can't generate a layout if we already have entries

            // Have items listed, but none of them are rezzed.
            var num_rezzed = (rezzable_items_jq.filter('.rezzed, .rezzing, .rezzing_failed, .rezzing_timed_out, .derezzing, .derezzing_failed, .derezzing_timed_out')).length;
            var num_derezzed = num_rezzable - num_rezzed;

            if (num_rezzed > 0) {

                parentjq.find('.sync_object_positions').css('visibility','visible');

                if (num_rezzed < num_rezzable) {
                    parentjq.find('.derez_all_objects').css('visibility','visible');
                    //parentjq.find('.rez_all_objects').css('visibility','visible');
                } else {
                    parentjq.find('.derez_all_objects').css('visibility','visible');
                    //parentjq.find('.rez_all_objects').css('visibility','hidden');
                }

                // allow layout deletion
                parentjq.find('.delete_layout_button').css('visibility','hidden');

            } else {

                parentjq.find('.sync_object_positions').css('visibility','hidden');

                //parentjq.find('.rez_all_objects').css('visibility','visible');
                parentjq.find('.derez_all_objects').css('visibility','hidden');

                // allow layout deletion
                parentjq.find('.delete_layout_button').css('visibility','visible');

            }
        }
	}

	function heartbeat_refresh(parentjq, layoutid, rezzeruuid) {

        if (!isRezzerConfigured) {
            return false;
        }

		$.post(
			"refresh_rezzer.php",  
			{
				layoutid: layoutid,
				rezzeruuid: rezzer_uuid,
				ts: new Date().getTime()
			},  
			function(json) {  
                
				var result = json.result;
                var changed = false;

				if (result == 'refreshed') {

					//itemjq.removeClass('syncing').addClass("synced");
                    var leiduuids = json.layoutentries_to_uuids;

					parentjq.find('.rezzable_item').each( function() {

                        var leid = $(this).attr('data-layoutentryid');
                        var exists = leiduuids[ leid ];
                        var deleted = false;

                        /*
                        This gives us an update of the server's representation of the in-world scene.
                        In theory we should already know what's happening in the scene, because we gave the commands to do things and got the results.
                        But some communication may have got lost, or the rezzer may have been controlled in a different window.
                        There are some delays between the rezzer updating the server and this script polling the server.
                        */
                        if ( $(this).hasClass('waiting_to_derez') || $(this).hasClass('waiting_to_rez') || $(this).hasClass('derezzing') || $(this).hasClass('rezzing')  ) {
                            // Leave this to either catch its reponse or handle its time out.

                        } else if ( $(this).hasClass('rezzing_failed') || $(this).hasClass('rezzing_timed_out') ) {
                            // We thought it failed, but it seemed to have worked - we must have just not got the response.
                            // Mark it as rezzed.
                            if (exists) {
                                $(this).removeClass('rezzing_failed').removeClass('rezzing_timed_out').addClass('rezzed');
                                changed = true;
                            }
                        } else if ( $(this).hasClass('derezzing_failed') || $(this).hasClass('derezzing_timed_out') ) {
                            // We thought derezzing failed but it's gone. 
                            // Mark it as derezzed.
                            if (!exists) {
                                $(this).removeClass('derezzing_failed').removeClass('derezzing_timed_out').addClass('derezzed');
                                changed = true;
                                deleted = true;
                            }
                        } else if ( $(this).hasClass('rezzed') ) {
                            if (!exists) {
                                var lastupdatets = $(this).attr('data-lastupdatets'); 
                                if (!lastupdatets) {
                                    lastupdatets = 0;
                                }
                                var nowts = new Date().getTime();
                                if ( ( nowts - lastupdatets ) > 10000 ) {
                                    $(this).removeClass('rezzed').addClass('derezzed');
                                    $(this).removeAttr('data-lastupdatets');
                                    deleted = true;
                                    changed = true;
                                }
                            }
                        } else {
                            // Wasn't there originally but is now
                            // Mark it rezzed, but only if the derezzing we thought worked was a while ago.
                            if (exists) {
                                if ( $(this).hasClass('derezzed') ) {
                                    var lastupdatets = $(this).attr('data-lastupdatets'); 
                                    if (!lastupdatets) {
                                        lastupdatets = 0;
                                    }
                                    var nowts = new Date().getTime();
                                    if ( ( nowts - lastupdatets ) > 10000 ) {
                                        $(this).removeClass('derezzed');
                                        $(this).removeAttr('data-lastupdatets');
                                        changed = true;
                                    }
                                }
                                $(this).addClass('rezzed');
                                changed = true;
                            }
                        }

                        if (deleted && $(this).hasClass('deleted_from_layout') ) {
                            itemjq.remove(); // TODO: Remove the config form too
                        }

                    });

                    // Check if anything is marked as rezzed but gone, and remove the rezzed .

                    // Check if anything is marked as unrezzed but present, and create the rezzed label
				} else if (result == 'failed') {
					// This can often happen legitimately, ie layout is deleted.
					// Just ignore the failure and carry on.
					//alert('failed');
				} else {
					//alert('refresh returned unknown status');
				}

                if (changed) { 
                    eventLoop(parentjq);

                    // Changed layout 
                    if (layoutid != activeLayoutID) {
                        return;
                    }
                }

                clearTimeout(heartbeatTimer);
                heartbeatTimer = setTimeout( function(){ heartbeat_refresh( parentjq, layoutid, rezzeruuid ); }, heartbeatMilliseconds );

			}
		,'json');  
	}

	function refresh_misc_object_group( parentjq) {
		var item_list_jq = $('ul[data-parent*="'+parentjq.attr('id')+'"].object_group_misc');
		var bits = item_list_jq.attr('id').split("_").pop().split("-"); // layoutentryid_1-2-3 becomes an Array(1,2,3)
		var layoutid = bits.pop(); 
		var controllerid = bits.pop();
		var courseid = bits.pop();
		$.post(
			"update_rezzer_contents.php",  
			{
				layoutid: layoutid,
				rezzeruuid: rezzer_uuid,
				controllerid: controllerid,
				courseid: courseid,
				ts: new Date().getTime()
			},  
			function(json) {  
				var result = json.result;
				if (result == 'refreshed') {
					insert_additional_object_html_items( item_list_jq, json.html_list_items, json.add_object_forms, json.edit_object_forms );
					//itemjq.removeClass('syncing').addClass("synced");
				} else if (result == 'failed') {
					// This can often happen legitimately, ie layout is deleted.
					// Just ignore the failure and carry on.
					//alert('failed');
				} else {
					//alert('refresh returned unknown status');
				}
			}  
		,'json');  
	}


	function sync_layout_item(itemjq, entryid, controllerid) {
		$.post(
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
                    var itemjqid = itemjq.attr('id');
                    setTimeout( function() {
                        $('#'+itemjqid).removeClass('synced').find('span.rezzable_item_positioning').html('&nbsp;');
                    }, 10000);
				} else if (result == 'failed') {
					itemjq.removeClass('syncing').addClass('syncing_failed');;
				}
				if (pendingRequests[""+entryid]) {
					delete pendingRequests[""+entryid];
					numPendingRequests--;
				}
				eventLoop( itemjq.closest('.layout_container') );
			}  
		,'json');  
	}

	function rez_layout_item(itemjq, entryid, controllerid, parentjq) {
		$.post(
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
                    itemjq.attr('data-lastupdatets', new Date().getTime());
				} else if (result == 'failed') {
					itemjq.removeClass('rezzing').addClass('rezzing_failed');;
				}
				if (pendingRequests[""+entryid]) {
					delete pendingRequests[""+entryid];
					numPendingRequests--;
				}
				eventLoop( parentjq );
			}  
		,'json');  
	}

	function derez_layout_item(itemjq, entryid, controllerid, parentjq) {
//alert('sending derez request with rezzeruuid '+rezzer_uuid);
		$.post(
			"derez_object.php",  
			{
				layoutentryid: entryid,
				rezzeruuid: rezzer_uuid,
				controllerid: controllerid,
				synchronous: '0',
				ts: new Date().getTime()
			},  
			function(json) {  
				var result = json.result;
//alert('derez result:'+result);
				if (result == 'queued') {
                    // do nothing
				} else if (true || result == 'derezzed') {
					itemjq.removeClass('derezzing').addClass('derezzed');;
					itemjq.removeClass('syncing');
					itemjq.removeClass('synced');
					itemjq.removeClass('waiting_to_sync');
					itemjq.removeClass('sync_failed');
					if (itemjq.hasClass('deleted_from_layout')) {
						itemjq.remove(); // TODO: Remove the config form too
					}
                    itemjq.attr('data-lastupdatets', new Date().getTime());
				} else if (result == 'failed') {
					itemjq.removeClass('derezzing').addClass('derezzing_failed');;
				}
				if (pendingRequests[""+entryid]) {
					delete pendingRequests[""+entryid];
					numPendingRequests--;
				}
				eventLoop( parentjq );

			}  
		,'json');  
	}

    function mark_for_derez( btnjq, e ) {

        var lijq = btnjq.closest('li');

        if (!lijq.hasClass('rezzed')) {
            return false;
        }
        if (lijq.hasClass('waiting_to_derez')) {
            return false;
        }

		lijq.addClass( 'waiting_to_derez' ).removeClass('rezzed');
		eventLoop( (lijq.closest('.layout_container') ) );

        e.stopPropagation();

        return false;

    }

    function mark_for_rez( btnjq, e ) {

        var lijq = btnjq.closest('li');

        if (lijq.hasClass('rezzed')) {
            return false;
        }
        if (lijq.hasClass('waiting_to_rez')) {
            return false;
        }

		lijq.addClass( 'waiting_to_rez' ).removeClass('derezzed').removeClass('waiting_to_derez');
		eventLoop( (lijq.closest('.layout_container') ) );

        e.stopPropagation();

        return false;


    }

	function start_derez_all(parentjq) {

        /*
		parentjq.find('.derez_all_objects').html('Stop derez');
		parentjq.find('.derez_all_objects').unbind('click');
		parentjq.find('.derez_all_objects').click(function() {
			stop_derez_all(parentjq);	
		});
        */

        var oldstatus = parentjq.attr('data-action-status');
		
		parentjq.attr('data-action-status', 'derezzing');
		parentjq.attr('data-rez-mode', 'derezzed');

        if (oldstatus == 'rezzing') {
            stop_rez_all(parentjq);
        }

		parentjq.children('li.rezzed').addClass( 'waiting_to_derez' );
		parentjq.children('li.waiting_to_derez').removeClass('rezzed');

		eventLoop( parentjq );
	}

	function start_rez_all(parentjq) {

        /*
		parentjq.find('.rez_all_objects').html('Stop rez');
		parentjq.find('.rez_all_objects').unbind('click');
		parentjq.find('.rez_all_objects').click(function() {
			stop_rez_all(parentjq);	
		});
        */

        var oldstatus = parentjq.attr('data-action-status');

		parentjq.attr('data-action-status', 'rezzing');
		parentjq.attr('data-rez-mode', 'rezzed');

        if (oldstatus == 'derezzing') {
            stop_derez_all(parentjq);
        }

		parentjq.children('li.derezzing_failed').removeClass('derezzing_failed');
		parentjq.children('li.rezzing_failed').removeClass('rezzing_failed');
		parentjq.children('li.derezzed').removeClass('derezzed');
		parentjq.children('li.rezzable_item').not('li.rezzed').not('li.rezzing').addClass( 'waiting_to_rez' );

		eventLoop( parentjq );
	}

	function start_sync_all(parentjq) {
		parentjq.attr('data-action-status', 'syncing');
		parentjq.children('li.rezzed').addClass( 'waiting_to_sync' );
		eventLoop( parentjq );
	}

	function stop_derez_all(parentjq) {

        parentjq.children('.derez_all_objects').html('Derez all');
		parentjq.children('.derez_all_objects').unbind('click');
		parentjq.children('.derez_all_objects').click(function() {
			start_derez_all(parentjq);
		});

		parentjq.children('li.waiting_to_derez').addClass( 'rezzed' ).removeClass('waiting_to_derez');;

        eventLoop( parentjq );

	}

	function stop_rez_all(parentjq) {

        parentjq.children('.rez_all_objects').html('Rez all');
		parentjq.children('.rez_all_objects').unbind('click');
		parentjq.children('.rez_all_objects').click(function() {
			start_rez_all(parentjq);
		});

		parentjq.children('li.rezzable_item').removeClass( 'waiting_to_rez' ).find('.rezzable_item_status').html('Derezzed');

        eventLoop( parentjq );

	}

	function create_layout( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-creating-text') );
		$.post(
			"add_layout.php",  
			frmjq.serialize(),
			function(json) {  
				var result = json.result;
				var layoutid = json.layoutid;
				var courseid = json.courseid;
				var controllerid = json.controllerid;
				var layoutname = json.layoutname;
				if (result == 'added') {
					buttonjq.html( buttonjq.attr('data-create-text') );
					insert_layout_into_course_divs( layoutid, courseid, controllerid, layoutname, frmjq);

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
		,'json');
		return false;

	}

	function insert_layout_into_course_divs( layoutid, courseid, controllerid, layoutname, frmjq ) {
		$('#controller_'+courseid+'-'+controllerid).each( function() {
			var newformid = $(this).attr('data-id-prefix') + layoutid;
			var newli = '<li data-layout-link-li-id="'+layoutid+'"><a class="layout_link" href="#' + newformid + '">'+layoutname+'</a></li>';
			$(this).children('.add_layout_above_me').before( newli );
		});
	}

	function generate_standard_layout( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-generating-text') );
		var layoutid = buttonjq.attr('data-layoutid');
		$.post(
			"generate_layout_entries.php",  
			{
				layoutid: layoutid,
				rezzeruuid: rezzer_uuid,
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
						$('.addobject_layout_'+layoutid+'_'+thisentry['objecttypelinkable']).each( function() {
							insert_layout_entry_into_layout_divs( thisentry['layoutid'], thisentry['layoutentryid'], thisentry['objectname'], thisentry['objectgroup'], thisentry['objectgrouptext'], thisentry['objecttypelinkable'], thisentry['moduletitle'], $(this), thisentry['html_list_item'], thisentry['edit_object_form'] );
						});
					}
					eventLoop( $('.layout_container_'+layoutid) );
				} else if (result == 'failed') {
					//alert('Adding layout entry failed');
					buttonjq.html( buttonjq.attr('data-generate-text') );
				}
			}  
		,'json');
	}

    function validate_for_submit(frmjq) {
        // We have a space for the module id, which is required.
        // This may only be a placeholder if there are no selected options.
        if (frmjq.find('[data-fieldname="sloodlemoduleid"]').length > 0) {
            if (frmjq.find('input:radio[name=sloodlemoduleid]:checked').length == 0) {
                frmjq.find('[data-fieldname="sloodlemoduleid"]').addClass('validation_error');
                // Show in red for 10 seconds
                setTimeout(function(){
                      $(frmjq.find('[data-fieldname="sloodlemoduleid"]').removeClass('validation_error'));
                }, 5000);
                return false;
            }
        } 
        
        return true;
    }

	function add_to_layout( buttonjq ) {

		var frmjq = buttonjq.closest("form");
        if (!validate_for_submit(frmjq)) {
            return false;
        }
		buttonjq.html( buttonjq.attr('data-adding-text') );
		$.post(
			"add_layout_entry.php",  
			frmjq.serialize(),
			function(json) {  
				var result = json.result;
				var objectgroup = json.objectgroup;
				var objectgrouptext = json.objectgrouptext;
				var objectname = json.objectname;
				var layoutid = json.layoutid;
				var objecttypelinkable = json.objecttypelinkable;
				var moduletitle = json.moduletitle;
				var layoutentryid = json.layoutentryid;
                var edit_object_form = json.edit_object_form;
                var html_list_item = json.html_list_item;
				if (layoutid == '') {
					//alert('error: missing layoutid after adding to layout');
				}
				if (result == 'added') {
					buttonjq.html( buttonjq.attr('data-add-text') );
					insert_layout_entry_into_layout_divs( layoutid, layoutentryid, objectname, objectgroup, objectgrouptext, objecttypelinkable, moduletitle, frmjq, html_list_item, edit_object_form);
					eventLoop( $('.layout_container_'+layoutid) );
					//history.back();
					backLevels( frmjq.attr('id'), 2 );
					//history.go(-2);
				} else if (result == 'failed') {
					//alert('Adding layout entry failed');
					buttonjq.html( buttonjq.attr('data-add-text') );
				}
			}  
		,'json');  
		return false;

	}

	// NB This just removes the object from the layout and marks it for deletion.
	// If rezzed, we'll do the actual of the object with another request.
	function delete_layout_configuration( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-deleting-text') );
		$.post(
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
				//	alert('Deleting layout entry failed');
					buttonjq.html( buttonjq.attr('data-delete-text') );
				} 
			}  
		,'json');  
		return false;

	}

    function confirm_clone_layout(buttonjq) {

		var frmjq = buttonjq.closest('ul');
        var confirm_section = frmjq.find('.clone_confirmation_zone');

        if (confirm_section.is(":visible")) {
            confirm_section.hide();
            return false;
        }

        confirm_section.show();
        confirm_section.find('.clone_confirmation_button_ok').unbind('click').bind('click', function() {
            clone_layout(buttonjq);
            confirm_section.hide();
        });
        confirm_section.find('.clone_confirmation_button_cancel').unbind('click').bind('click', function() {
            confirm_section.hide();
        });

    }
    function confirm_delete_layout(buttonjq) {

		var frmjq = buttonjq.closest('ul');
        var confirm_section = frmjq.find('.delete_confirmation_zone');

        if (confirm_section.is(":visible")) {
            confirm_section.hide();
            return false;
        }

        confirm_section.show();
        confirm_section.find('.delete_confirmation_button_ok').unbind('click').bind('click', function() {
            delete_layout(buttonjq);
            confirm_section.hide();
        });
        confirm_section.find('.delete_confirmation_button_cancel').unbind('click').bind('click', function() {
            confirm_section.hide();
        });

    }

	// NB This just removes the layout from the server and marks it for deletion.
	// If rezzed, we'll derez the objects separately, and only remove the layout from view when they're done
	function delete_layout( buttonjq ) {

		frmjq = buttonjq.closest('ul');
		buttonjq.html( buttonjq.attr('data-deleting-text') );
		var layoutid = buttonjq.attr('data-layoutid');
		$.post(
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
					//alert('Deleting layout entry failed');
					buttonjq.html( buttonjq.attr('data-delete-text') );
				} 
			}  
		,'json');  
		return false;

	}

	function rename_layout( spanjq ) {

		var parentjq = spanjq.closest('ul');
		var inputjq = parentjq.find('.rename_layout_input');
		var newname = inputjq.val();
		var layoutid = inputjq.attr('data-rename-input-layoutid');

		$.post(
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

					parentjq.find('.rename_input').hide();
					parentjq.find('.rename_input_text').html(newname);
					parentjq.find('.rename_input_text').show();

				} else {
					//alert('Rename failed');
				}
			}
		,'json');

	}

	function clone_layout( buttonjq ) {

		buttonjq.html( buttonjq.attr('data-cloning-text') );
		var layoutid = buttonjq.attr('data-layoutid');
		var frmjq = buttonjq.closest('ul');
		$.post(
			"clone_layout.php",  
			{
				layoutid: layoutid,
				rezzeruuid: rezzer_uuid,
				ts: new Date().getTime()
			},
			function(json) {  
				var result = json.result;
				if (result == 'cloned') {

					buttonjq.html( buttonjq.attr('data-cloned-text') ); 

					layoutid = json.layoutid;
					var layoutname = json.layoutname;
					var courseid = json.courseid;
					var controllerid = json.controllerid;

					insert_layout_into_course_divs( layoutid, courseid, controllerid, layoutname, null);

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
					//alert('Cloning layout entry failed');
					buttonjq.html( buttonjq.attr('data-clone-text') );
				} 
			}  
		,'json');  
		return false;

	}



	function update_layout_position( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		$.post(
			"sync_layout_position.php",  
			frmjq.serialize(),
			function(json) {  
				var result = json.result;
			}  
		,'json');  
		return false;

	}

	function update_layout_configuration( buttonjq ) {

		var frmjq = buttonjq.closest("form");
		buttonjq.html( buttonjq.attr('data-updating-text') );
		$.post(
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
					//alert('Updating layout entry failed');
					buttonjq.html( buttonjq.attr('data-update-text') );
				} 
			}  
		,'json');  
		return false;

	}

	function insert_additional_object_html_items( objectlistjq, new_object_html_items, add_object_forms, edit_object_forms ) {
		for( var id in add_object_forms) {
			if ($("#"+id).length == 0){
				$('#add_add_object_forms_above_me').before(add_object_forms[id]);
			}
		}
		for( var id in edit_object_forms) {
			if ($("#"+id).length == 0){
				$('#add_edit_object_forms_above_me').before(edit_object_forms[id]);
			}
		}
		for( var id in new_object_html_items) {
			if ($("#"+id).length == 0){
				objectlistjq.append(new_object_html_items[id]);
			}
		}

		attach_event_handlers();
	}

	function insert_layout_entry_into_layout_divs( layoutid, layoutentryid, objectname, objectgroup, objectgrouptext, objecttypelinkable, moduletitle, addfrmjq, html_list_item, edit_object_form ) {

		regexPtn = '^layout_.+-.+-'+layoutid+'$';
		var re = new RegExp(regexPtn,"");
		$('ul').filter(function() {
			return this.id.match(regexPtn);
		}).each( function() {
			// make an id for the new element	
			var newElementID = $(this).attr('id').replace('layout_','layoutentryid_')+'-'+layoutentryid;

			// already there
			if ( $(this).children('#'+newElementID).length > 0 ) {
				return;
			}

			// If we don't yet have a group to put this item in, create it
			if ( $(this).children(".after_group_"+objectgroup).size() == 0 ) {
				var groupLi = '<li class="group">'+objectgrouptext+'</li>' + '<li class="after_group_'+objectgroup+'"></li>';
				$(this).children(".add_object_group").before( groupLi );
			}

			$(this).children(".after_group_"+objectgroup).before(html_list_item);

            attach_event_handlers();

			var editFrm = $(edit_object_form);

			// Seems like the original click handler doesn't get created initially - maybe because it's hidden?
			editFrm.find('.delete_layout_entry_button').unbind('click').click(function() {
				return delete_layout_configuration($(this));
			});

			$('#add_configuration_above_me_'+$(this).attr('id')).before(editFrm);

			editFrm.find('.update_layout_entry_button').unbind('click').click(function() {
				return update_layout_configuration($(this));
			});

            editFrm.find('.refresh_config_button').unbind('click').click( function() {
                refresh_form_options( $(this) );	
            });

		});
		
	}

	function refresh_form_options( buttonjq) {
		var frmjq = buttonjq.closest('form') 
		var courseid = frmjq.attr('data-courseid');
		var primname = frmjq.attr('data-primname');
		buttonjq.html( buttonjq.attr('data-refreshing-text') );
		$.post(
			"refresh_options.php",  
			{
				courseid: courseid,
				primname: primname,
				ts: new Date().getTime()
			},
			function(json) {  
				var result = json.result;
				if (result == 'refreshed') {
					var fields = json.fields;
					for (var fn in fields) {
						// This assumes we only have radios, not selects etc.
						var ops = fields[fn];
						var existing_ops = frmjq.find('.sloodle_config').find('input:radio');
						for (var o in ops) {
							if ( existing_ops.filter('[name='+fn+']').filter('[value='+o+']').length > 0 ) {
								// already got it
							} else {
								var newinput = '<input type="radio" name="'+fn+'" value="'+o+'" />' + ops[o] + '&nbsp; &nbsp;';
								var existing_op_items = existing_ops.filter('[name='+fn+']');
								if (existing_op_items.length == 0) {
									// not there yet - should have a placeholder instead
									frmjq.find('.no_options_placeholder').filter('[data-fieldname='+fn+']').before(newinput);
									frmjq.find('.no_options_placeholder').filter('[data-fieldname='+fn+']').remove();
								} else {
									existing_op_items.filter(':first').before( newinput );
								}
							}
						}
						// TODO: Should really remove old ones that no longer exist...
					}
				} else if (result == 'failed') {
					//alert('refresh failed');
				}
				buttonjq.html( buttonjq.attr('data-refresh-text') );
			}  
		,'json');  
	}

    function configure_rezzer( parentjq, controllerid, layoutid) {

        // Layout ID has changed
        // This can happen if we fail, then try to reconnect
        if (activeLayoutID != layoutid) {
            return;
        }

        $.post(
			"configure_rezzer.php",  
			{
				controllerid: controllerid,
				rezzeruuid: rezzer_uuid,
				ts: new Date().getTime()
			},
			function(json) {  
				var result = json.result;
				if (result == 'configured') {
                    isRezzerConfigured = true;
                    rezzerControllerID = controllerid;
					parentjq.attr('data-connection-status', 'connected');
					update_buttons( parentjq );
					refresh_misc_object_group( parentjq );
					rezzerControllerID = controllerid;
                    heartbeat_refresh( parentjq, layoutid, rezzer_uuid)
                    parentjq.find('.fatal_error_zone').hide();
				} else if (result == 'failed') {
                    parentjq.find('.fatal_error_zone').show();
					parentjq.children('.rez_all_objects').hide();	

                    // Try again in 30 seconds
                    setTimeout(function() {
                        configure_rezzer( parentjq, controllerid, layoutid );
                    }, 30000);

				}
			}  
		,'json');  

    }

    function handle_scene_selection( layoutlinkjq ) {
		var layoutjqid = layoutlinkjq.attr('href'); // looks like #layout_2-2-1
		var parentjq = $(layoutjqid); // the "#" happens to be the same notation as that used for the jquery id selector
		var bits = parentjq.attr('id').split("_").pop().split("-"); // layoutentryid_1-2-3 becomes an Array(1,2,3)
		var layoutid = bits.pop(); // pop this off - don't think we need it
        activeLayoutID = layoutid;
		var controllerid = bits.pop();
        /*
		if ( isRezzerConfigured && ( rezzerControllerID == controllerid) ) {
			return;
		}
        */
        configure_rezzer( parentjq, controllerid, layoutid );
        return true;
	}

	function attach_event_handlers() {
		$().find('.create_layout_button').unbind('click').click(function() {
			return create_layout($(this));
		});
		$().find('.layout_link').unbind('click').click(function() {
			return handle_scene_selection($(this));
		});
		$().find('.rez_all_objects').unbind('click').click(function() {
			start_rez_all($(this).closest('.layout_container'));
		});

		$().find('.derez_all_objects').unbind('click').click(function() {
			start_derez_all($(this).closest('.layout_container'));
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
			return confirm_delete_layout( $(this) );
		});
		$().find('.clone_layout_button').unbind('click').click(function() {
			return confirm_clone_layout( $(this) );
		});
		$().find('.generate_standard_layout').unbind('click').click(function() {
			return generate_standard_layout( $(this) );
		});
		$().find('.layout_container').each(function() {
			update_buttons($(this));
			update_labels($(this));
		});

	//	$().find('.rename_input').hide();

		$('.rename_layout_button').unbind('click').click( function(){
			handle_rename_button_click($(this));
		});

		$().find('.populate_object_group').unbind('click').click( function() {
			return refresh_misc_object_group( $(this).closest('ul') );
		});

		$('.refresh_config_button').unbind('click').click( function() {
			refresh_form_options( $(this) );	
		});
		$('.reload_page_button').unbind('click').click( function() {
			location.reload();
		});
        $().find('.rezzable_item_derez_button').unbind('click').click( function(e) {
            mark_for_derez( $(this), e );
        });
        $().find('.rezzable_item_rez_button').unbind('click').click( function(e) {
            mark_for_rez( $(this), e );
        });

        
	}

	function handle_rename_button_click(btnjq) {
		var parentjq = btnjq.closest('ul');
		if ( btnjq.hasClass('shown_textbox') ) {
			rename_layout( btnjq );
			btnjq.removeClass('shown_textbox');
		} else {
			btnjq.addClass('shown_textbox');
			parentjq.find('.rename_input_text').hide();
			parentjq.find('.rename_input').show();
		}
	}

	$(document).ready(function () {
		attach_event_handlers();
		enable_slide_navigation();
		$('#backButton').show();
	//	iui.animOn = true;
	});




	function backLevels(fromPageID, num) {
		if (isBusy) {
			return;
		}
		if (num < 1) {
			return false;
		}
		// Already moved on? Leave the navigation alone
		if ( $('#'+fromPageID).attr('selected') != 'true' ) {
			//alert(fromPageID + ' not currently selected, not going back levels - attr is '+$('#'+fromPageID).attr('id'));
			return false;
		}

		var nextPageID = $('#'+fromPageID).attr('data-parent');
		if (nextPageID == null) {
			//alert('no next page to go to, giving up');
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

			if (isBusy) {
				return;
			}

			var clickedid=this.hash;
			if ( clickedid == null ) {
				//alert('Error: no hash found');
				return false;
			}

			if (clickedid == "#sitelist") {
				window.location = $('#sitelist').attr('data-parent-url');
				return false;
			}

			var targetjq = $(clickedid); // already begins with #
			if (targetjq.size() == 0) {
				//alert('Error: no target found for id '+clickedid);
				return false;
			}

			var backwards = ($(this).attr('id') == 'backButton');

			fromPage = document.getElementById( $('[selected*="true"]').attr('id') );
			toPage   = document.getElementById( targetjq.attr('id') );
			//targetjq.attr('selected','true'); // Select the target

			if ( (targetjq.hasClass('add_object_form')) || (targetjq.hasClass('edit_object_form')) ) {
				refresh_form_options( targetjq );
			}

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

var slideSpeed = 20;
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


function slidePages(fromPage, toPage, backwards)
{		 

	if (isBusy) {
		return;
	}
	isBusy = true;

	var axis = (backwards ? fromPage : toPage).getAttribute("axis");

	clearInterval(checkTimer);
	
	slide1(fromPage, toPage, backwards, axis, slideDone);

	function slideDone()
	{
	  if (!hasClass(toPage, "dialog"))
		  fromPage.removeAttribute("selected");
	  checkTimer = setInterval(checkOrientAndLocation, 300);
	  //setTimeout(updatePage, 0, toPage, fromPage);
	  fromPage.removeEventListener('webkitTransitionEnd', slideDone, false);
	  isBusy = false;
	}

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


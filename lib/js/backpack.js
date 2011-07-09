$(document).ready(function () {
	$('#checkall').click( function() {
		if ( $(this).attr('checked') ) {
			$('input[name=userIds[]]').attr('checked', 'checked');
		} else {
			$('input[name=userIds[]]').removeAttr('checked');
		}
	});
});

/************************************************************************
*************************************************************************
@Name :      	jScrollbar - jQuery Plugin
@Revison :  1.6
@Date :        02/02/2012
@Author:	 ALPIXEL - http://www.myjqueryplugins.com - http://www.alpixel.fr
@License :		 Open Source - MIT License : http://www.opensource.org/licenses/mit-license.php
**************************************************************************
*************************************************************************/
(function($) {
	$.fn.jScrollbar= function(op) {
        var defaults = {
			scrollStep : 10,
			allowMouseWheel : true,
			showOnHover : false,
			position : 'right',
			marginPos : 15
			
        };
		
		if(this.length>0)
		return this.each(function() {
			
			/*
			// Vars
			*/
			var 
				$this = $(this),
				opts = $.extend(defaults, op),
				js_mask = $this.find('.jScrollbar_mask'),
				js_drag = $this.find('.jScrollbar_draggable a.draggable'),
				js_Parentdrag = $this.find('.jScrollbar_draggable'),
				diff = parseInt(js_mask.innerHeight()) - parseInt($this.height());
			
			/** if mask container is heighter than the main container **/
			if(diff > 0)
			{
				ApplyCSS();
				if(opts.showOnHover) {
					js_Parentdrag.hide();
					$this.hover(function(){
						js_Parentdrag.stop(true,true).fadeIn();
					},function(){
						js_Parentdrag.stop(true,true).fadeOut();
					});
				}
				else {
					js_Parentdrag.stop(true,true).show();
				}
				
				var pxDraggable = parseInt(js_Parentdrag.height()) - parseInt(js_drag.height());;
				var pxUpWhenScrollMove = opts.scrollStep;
				var pxUpWhenMaskMove = pxUpWhenScrollMove * (diff/pxDraggable);
				
				js_drag
				.click(function(e){e.preventDefault();})
				.draggable({
					axis:'y',
					containment: js_Parentdrag,
					scroll: false,
					drag: function(event, ui){
						js_mask.css('top','-'+(ui.position.top * (diff/pxDraggable))+'px');
					}
				});
				
				/** if mousewheel allowed **/
				if(opts.allowMouseWheel)
				$this.mousewheel(function(objEvent, intDelta) {
					// mousewheel up (first if)  and mousewheel down (second if)
					if (intDelta > 0 && parseInt(js_mask.css('top')) < 0){
						js_drag.stop(true, true).animate({top:'-='+pxUpWhenScrollMove+'px'}, 100);
						js_mask.stop(true, true).animate({top:'+='+pxUpWhenMaskMove+'px'},100,function(){
							RelativeTop = parseInt(js_mask.css('top'));
							if(RelativeTop > 0 ) {
								js_drag.animate({top:'0px'},150);
								js_mask.css({top:0});
							}
						});
					}
					else if (intDelta < 00 && parseInt(js_mask.css('top')) > -diff) {
						js_drag.stop(true, true).animate({top:'+='+pxUpWhenScrollMove+'px'}, 100);
						js_mask.stop(true, true).animate({top:'-='+pxUpWhenMaskMove+'px'},100,function(){
							RelativeTop = parseInt(js_mask.css('top'));
							if(RelativeTop < -diff)
							{
								js_mask.css({top:-diff});
								js_drag.animate({top:pxDraggable},150);
							}
						});
					}
				});
			}
			
			function ApplyCSS() {
				switch (opts.position) {
					case 'right' :
						js_mask.css({'float':'left'});
						js_Parentdrag.css({marginLeft:opts.marginPos});
					break;
					case 'left' :
						js_mask.css({'float':'right'});
						js_Parentdrag.css({marginRight:opts.marginPos});
					break;
					default :
						js_mask.css({'float':'left'});
						js_Parentdrag.css({marginLeft:opts.marginPos});
				}
			};
		});

	}
})(jQuery);
/**
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var CURRENT_URL     = window.location.href.split('?')[0];
var $BODY           = $('body'           );
var $MENU_TOGGLE    = $('#menu_toggle'   );
var $SIDEBAR_MENU   = $('#sidebar-menu'  );
var $SIDEBAR_FOOTER = $('.sidebar-footer');
var $LEFT_COL       = $('.left_col'      );
var $RIGHT_COL      = $('.right_col'     );
var $NAV_MENU       = $('.nav_menu'      );
var $FOOTER         = $('footer'         );

// Sidebar
$(document).ready(function()
{
	SplendidError.SystemMessage('Document Ready for Gentelella theme');
	var setContentHeight = function ()
	{
		// reset height
		$RIGHT_COL.css('min-height', $(window).height());
		// 04/24/2017 Paul.  Extend background all the way to the bottom. 
		$LEFT_COL.css('min-height', $(window).height());

		var bodyHeight    = $(window).height(); //$BODY.outerHeight();
		var footerHeight  = $FOOTER.height(); // $BODY.hasClass('footer_fixed') ? 0 : $FOOTER.height();
		var leftColHeight = $LEFT_COL.eq(1).height(); // + $SIDEBAR_FOOTER.height();
		var contentHeight = leftColHeight; // bodyHeight < leftColHeight ? leftColHeight : bodyHeight;
		var navHeight     = $NAV_MENU.height();

		$LEFT_COL.css('min-height', contentHeight);
		// normalize content
		contentHeight -= navHeight + footerHeight;
		contentHeight += 32;
		$RIGHT_COL.css('min-height', contentHeight);
	};

	// 04/18/2017 Paul.  Disable default events. 
	/*
	$SIDEBAR_MENU.find('a').on('click', function(ev)
	{
		var $li = $(this).parent();

		if ($li.is('.active'))
		{
			$li.removeClass('active active-sm');
			$('ul:first', $li).slideUp(function() 
			{
				setContentHeight();
			});
		}
		else
		{
			// prevent closing menu if we are on child menu
			if (!$li.parent().is('.child_menu'))
			{
				$SIDEBAR_MENU.find('li').removeClass('active active-sm');
				$SIDEBAR_MENU.find('li ul').slideUp();
			}
			$li.addClass('active');
			$('ul:first', $li).slideDown(function()
			{
				setContentHeight();
			});
		}
	});
	*/

	// toggle small or large menu
	$MENU_TOGGLE.on('click', function()
	{
		if ($BODY.hasClass('nav-md'))
		{
			$SIDEBAR_MENU.find('li.active ul').hide();
			$SIDEBAR_MENU.find('li.active').addClass('active-sm').removeClass('active');
		}
		else
		{
			$SIDEBAR_MENU.find('li.active-sm ul').show();
			$SIDEBAR_MENU.find('li.active-sm').addClass('active').removeClass('active-sm');
		}
		$BODY.toggleClass('nav-md nav-sm');
		setContentHeight();
	});

	// 04/18/2017 Paul.  Disable default events. 
	/*
	// check active menu
	$SIDEBAR_MENU.find('a[href="' + CURRENT_URL + '"]').parent('li').addClass('current-page');

	$SIDEBAR_MENU.find('a').filter(function ()
	{
		return this.href == CURRENT_URL;
	}).parent('li').addClass('current-page').parents('ul').slideDown(function()
	{
		setContentHeight();
	}).parent().addClass('active');
	*/

	// recompute content when resizing
	$(window).smartresize(function()
	{
		setContentHeight();
	});

	setContentHeight();
});
// /Sidebar

/**
 * Resize function without multiple trigger
 * Usage:
 * $(window).smartresize(function(){
 *     // code here
 * });
 */
(function($,sr)
{
	// debouncing function from John Hann
	// http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
	var debounce = function (func, threshold, execAsap)
	{
		var timeout;
		return function debounced ()
		{
			var obj = this, args = arguments;
			function delayed ()
			{
				if (!execAsap)
					func.apply(obj, args);
				timeout = null; 
			}

			if (timeout)
				clearTimeout(timeout);
			else if (execAsap)
				func.apply(obj, args);
			timeout = setTimeout(delayed, threshold || 100);
		};
	};

	// smartresize 
	jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };
})(jQuery,'smartresize');

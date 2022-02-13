// based on scroller by Dan Dobbs, http://www.vectorform.com/silverlight/

var mouseCheckInt;
var updateScrubberInt;
var scrollLeftRightInt;
var scrollUpDownInt;
var _root_xmouse;
var _root_ymouse;

function startDrag(s,e)
{
	this.mouse_down = 1;
	sender = s;
	me = this;
	
	key = s.name.split('_')[0];
	
	objInfo = scrollerConstraints[key];
	objInfo.click_x = e.getPosition(s).x;
	objInfo.click_y = e.getPosition(s).y;

	mouseCheckInt = setInterval('mouseChecker(sender,me,objInfo)',10);
	s.captureMouse();
}

function endDrag(s,e)
{
	this.mouse_down = 0;
	clearInterval(mouseCheckInt);
	s.releaseMouseCapture();
}

function mouseChecker(s, me, obj)
{
	if ( me.mouse_down )
	{
		if ( obj.direction == 'H' )
		{
			new_val = _root_xmouse-obj.world_offset + obj.local_offset - obj.click_x;
			calc_scroll_end = obj.track_length + obj.local_offset - s.width;
		
			val = ((new_val - obj.start_scroll) / (obj.track_length - s.width)) * 100;
			per = val / 100;
			canvas_prop = 'Canvas.Left';
		}
		else
		{
			new_val = _root_ymouse - obj.world_offset + obj.local_offset - obj.click_y;
			calc_scroll_end = obj.track_length + obj.local_offset - s.height;
		
			val = ((new_val - obj.start_scroll) / (obj.track_length - s.height)) * 100;
			per = val/100;
			canvas_prop = 'Canvas.Top';
		}
		
		if ( new_val > obj.start_scroll && new_val < calc_scroll_end )
		{
			s[canvas_prop] = new_val;
			s.findName(obj.container)[canvas_prop] = ((obj.content_length - obj.mask_length) * per) * -1;
		}
		else if(new_val<=obj.start_scroll)
		{
			s[canvas_prop] = obj.start_scroll;
			s.findName(obj.container)[canvas_prop] = 0;
		}
		else if(new_val>=calc_scroll_end)
		{
			s[canvas_prop] = calc_scroll_end;
			s.findName(obj.container)[canvas_prop] = -obj.content_length + obj.mask_length;
		}
		
	}
	else
	{
		clearInterval(mouseCheckInt);
		s.releaseMouseCapture();
	}
}

function pressTrackBar(s, e)
{
	key = s.name.split('_')[0];
	obj = scrollerConstraints[key];
	scrubber = s.findName(key + '_Scrubber');
	
	var click_x=e.getPosition(s).x;
	var click_y=e.getPosition(s).y;
	if ( obj.direction == 'H' )
	{
		click_prop = click_x;
		canvas_prop = 'Canvas.Left';
		scrubber_prop = scrubber.width;
	}
	else
	{
		click_prop = click_y;
		canvas_prop = 'Canvas.Top';
		scrubber_prop = scrubber.height;
	}
	
	if ( click_prop < scrubber[canvas_prop] )
	{
		scrubber[canvas_prop] = click_prop + obj.local_offset;
	}
	else if ( click_prop > (scrubber[canvas_prop] + scrubber_prop - obj.local_offset) )
	{
		scrubber[canvas_prop]=click_prop-scrubber_prop+obj.local_offset;
	}	
	updatePanel(scrubber[canvas_prop],s,obj);
}

function scrollerArrowPress(s, e)
{
	this.mouse_down = 1;
	sender = s;
	me = this;
	
	var key = s.name.split('_')[0];
	obj = scrollerConstraints[key];
	
	if ( obj.direction == 'H' )
	{
		scrollLeftRightInt=setInterval('scrollLeftRight(sender,me)',10);
	}
	else
	{
		scrollUpDownInt=setInterval('scrollUpDown(sender,me)',10);
	}
	s.captureMouse();
}


function scrollerArrowRelease(s, e)
{
	this.mouse_down = 0;
	sender = s;
	me = this;
	
	clearInterval(scrollLeftRightInt);
	clearInterval(scrollUpDownInt);
	
	s.releaseMouseCapture();
}

function scrollLeftRight(s, me)
{
	var key = s.name.split('_')[0];
	var btn_name = s.name.split('_')[1];
	obj = scrollerConstraints[key];
	scrubber = s.findName(key + '_Scrubber');

	var scroll_amount=obj.scroll_amount;
	if ( btn_name == 'Left' )
	{
		var pre_check = scrubber['Canvas.Left'] - scroll_amount;
		if ( pre_check > obj.local_offset )
		{
			scrubber['Canvas.Left'] = scrubber['Canvas.Left'] - scroll_amount;
		}
		else
		{
			scrubber['Canvas.Left'] = obj.local_offset;
		}
	}
	else
	{
		var calc_right_edge = obj.track_length + obj.local_offset - scrubber.width;
		var pre_check = scrubber['Canvas.Left'] + scroll_amount;
		if ( pre_check < calc_right_edge )
		{
			scrubber['Canvas.Left'] = scrubber['Canvas.Left'] + scroll_amount;
		}
		else
		{
			scrubber['Canvas.Left'] = calc_right_edge;
		}
	}
	updatePanel(scrubber['Canvas.Left'], s, obj);
}

function scrollUpDown(s, me)
{
	var key = s.name.split('_')[0];
	var btn_name = s.name.split('_')[1];
	
	obj = scrollerConstraints[key];
	scrubber = s.findName(key + '_Scrubber');
	var scroll_amount = obj.scroll_amount;
	
	if( btn_name == 'Up' )
	{
		var pre_check = scrubber['Canvas.Top'] - scroll_amount;
		if ( pre_check > obj.local_offset )
		{
			scrubber['Canvas.Top'] = scrubber['Canvas.Top'] - scroll_amount;
		}
		else
		{
			scrubber['Canvas.Top'] = obj.local_offset;
		}
	}
	else
	{
		var calc_bottom_edge = obj.track_length + obj.local_offset - scrubber.height;
		var pre_check = scrubber['Canvas.Top'] + scroll_amount;
		if ( pre_check < calc_bottom_edge )
		{
			scrubber['Canvas.Top'] = scrubber['Canvas.Top'] + scroll_amount;
		}
		else
		{
			scrubber['Canvas.Top'] = calc_bottom_edge;
		}
	}
	
	updatePanel(scrubber['Canvas.Top'], s, obj)
}

function updatePanel(new_val, s, obj)
{
	var scroll_width = s.findName(obj.container).width;
	key = s.name.split('_')[0];
	scrubber = s.findName(key + '_Scrubber');
	
	if ( obj.direction == 'H' )
	{
		val = ((new_val - obj.start_scroll) / (obj.track_length - scrubber.width)) * 100;
		canvas_prop = 'Canvas.Left';
	}
	else
	{
		val = ((new_val - obj.start_scroll) / (obj.track_length - scrubber.height)) * 100;
		canvas_prop = 'Canvas.Top';
	}
	var per = val/100;
	s.findName(obj.container)[canvas_prop] = ((obj.content_length - obj.mask_length) * per) * -1;
}

function whenMouseMoves(s, e)
{
	_root_xmouse = e.getPosition(null).x
	_root_ymouse = e.getPosition(null).y
}

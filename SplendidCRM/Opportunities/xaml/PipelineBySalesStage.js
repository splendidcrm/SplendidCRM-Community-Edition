var scrollerConstraints;

function mainCanvasLoaded(s)
{
	var main = s.findName('container');
	var scroll_region = main.findName('scroll_region');
	var grid = main.findName('grid');

	scrollerConstraints = new Array();
	scrollerConstraints['myScroller1'] = new Object();
	scrollerConstraints['myScroller1'].container      = 'scroll_region';
	scrollerConstraints['myScroller1'].direction      = 'V';
	scrollerConstraints['myScroller1'].world_offset   =  62;  //scrubber distance from main top edge 50+12 (50 from main canvas, 12 from parent canvas) - you can figure this out by script if you'd like
	scrollerConstraints['myScroller1'].local_offset   =  12;  //scrubber distance from parent top
	scrollerConstraints['myScroller1'].track_length   = scroll_region.Height - 22;  //2 less than visual track BG, 2 because trackbar is 2 px longer than scrubbing area (just for aesthetics)
	scrollerConstraints['myScroller1'].start_scroll   = scrollerConstraints['myScroller1'].local_offset;
	scrollerConstraints['myScroller1'].mask_length    = scroll_region.Height;  // should be same value as contentHolderClip rect height property in xaml, cannot not get from script currently, aka Silverlight sucks (let me know if you know how). for a hack you can put the size in the name of the clip (ex: contentHolderClip_260) and read and parse that ;-)
	scrollerConstraints['myScroller1'].content_length = grid.Height;
	scrollerConstraints['myScroller1'].scroll_amount  =   6;  //ex: 1-20
	
	//hide scroll bar if content isnt big enough to scroll
	if ( scroll_region.Height >= grid.Height )
	{
		main.findName("myScroller1_Container").visibility = "Collapsed";
	}
	var y_labels = main.findName('y_labels');
	var nLabelWidth = y_labels['Width'];
	for ( var i = 0; i < y_labels.children.count; i++ )
	{
		var lbl = y_labels.children.getItem(i);
		lbl['Canvas.Left'] = nLabelWidth - lbl.ActualWidth;
	}
}

function mainCanvasMouseLeave(s)
{
	this.mouse_down = 0;
	clearInterval(mouseCheckInt);
	s.releaseMouseCapture();
}

function HorizontalBarEnter(s, e)
{
	s['Stroke'] = "Black";
	s.findName('DetailsBar')['Text'] = s['Tag'];
}

function HorizontalBarLeave(s, e)
{
	s['Stroke'] = "#eeeeee";
	s.findName('DetailsBar')['Text'] = s.findName('DetailsBar')['Tag'];
}

function HorizontalBarClick(s, e)
{
	window.location.href = window.location.protocol + '//' + window.location.host + s.findName(s.Name + '_link')['Tag'];
}

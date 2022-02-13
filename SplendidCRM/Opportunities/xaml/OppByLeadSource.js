function mainPieCanvasLoaded(s)
{
	var main = s.findName('container');
}

function PieEnter(s, e)
{
	s['Stroke'] = "White";
	s.findName('DetailsBar')['Text'] = s['Tag'];
}

function PieLeave(s, e)
{
	s['Stroke'] = "#9b9b9b";
	s.findName('DetailsBar')['Text'] = s.findName('DetailsBar')['Tag'];
}

function PieClick(s, e)
{
	window.location.href = window.location.protocol + '//' + window.location.host + s.findName(s.Name + '_link')['Tag'];
}

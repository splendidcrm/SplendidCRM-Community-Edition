//Portions created by SugarCRM are Copyright (C) 2005 SugarCRM, Inc.; All Rights Reserved.
//See LICENSE.txt for license information
#include "colorFunctions.as"
// degree to radian converter
function toRadians(deg) {
	return deg*Math.PI/180;
}
// set document variables
var doc_height = 400;
var doc_width = 350;
// set misc variables
var padding_left = 10;
var padding_left_graph = 10;
var padding_right_graph = 10;
var padding_bottom_graph = 5;
var padding_bottom_graphTitle = 5;
var padding_top = 10;
var padding_bottom = 10;
// create XML object and get xml file path
graph_data = new XML();
graph_data.onLoad = handleLoad;
graph_data.ignoreWhite = true;
// load varibles from xml file
//graph_data.load('pie.xml');
graph_data.load(filename+"?"+Math.random());
function handleLoad(success) {
	if (success) {
		// take childNodes and turn them into arrays for looping
		var yName_temp = graph_data.firstChild.firstChild.childNodes;
		var colorLegend_temp = graph_data.firstChild.childNodes[2].childNodes;
		var graphColors = graph_data.firstChild.childNodes[4];
		// generate container movie which is the scrolling window pane
		container = createEmptyMovieClip("container", 1);
		// generate bound_box and attach to container
		bound_box = container.createEmptyMovieClip("bound_box", 1);
		bound_box.moveTo(0, 0);
		bound_box.lineStyle(0, graphColors.attributes.docBorder);
		bound_box.beginFill(0xffffff, 0);
		bound_box.lineTo(doc_width-1, 0);
		bound_box.lineTo(doc_width-1, doc_height-1);
		bound_box.lineTo(0, doc_height-1);
		bound_box.lineTo(0, 0);
		bound_box.endFill();
		bound_box._x = 0;
		bound_box._y = 0;
		bound_box._width = doc_width-1;
		bound_box._height = doc_height-1;
		// generate scrollbar movie and attach it to container
		scrollbarWidth = 10;
		scrollbarHeight = 100;
		scroller = container.createEmptyMovieClip("scroller", 2);
		scrollbar = scroller.createEmptyMovieClip("scrollbar", 1);
		scrollbar.beginFill(graphColors.attributes.scrollBar, 100);
		scrollbar.lineStyle(0, graphColors.attributes.scrollBarBorder);
		scrollbar.lineTo(scrollbarWidth, 0);
		scrollbar.lineTo(scrollbarWidth, scrollbarHeight);
		scrollbar.lineTo(0, scrollbarHeight);
		scrollbar.lineTo(0, 0);
		scrollbar.endFill();
		scrollbar._width = scrollbarWidth;
		scrollbar._height = scrollbarHeight;
		scrollbar._x = -scrollbarWidth/2;
		scrollbar._y = -scrollbarWidth/2;
		scroller._x = (doc_width-1)-(scrollbarWidth/2);
		scroller._y = scrollbarHeight/2;
		scroller._alpha = 0;
		// generate scrollbar track movie and attach it to container
		scrollbarTrack_width = scrollbar_width+2;
		scrollbarTrack = container.createEmptyMovieClip("scrollbarTrack", 0);
		scrollbarTrack.beginFill(graphColors.attributes.scrollBarTrack, 100);
		scrollbarTrack.lineStyle(0, graphColors.attributes.scrollBarTrackBorder);
		scrollbarTrack.lineTo(scrollbarTrack_width, 0);
		scrollbarTrack.lineTo(scrollbarTrack_width, doc_height);
		scrollbarTrack.lineTo(0, doc_height);
		scrollbarTrack.lineTo(0, 0);
		scrollbarTrack.endFill();
		scrollbarTrack._width = scrollbarTrack_width;
		scrollbarTrack._height = doc_height;
		scrollbarTrack._x = (doc_width-scrollbarTrack_width);
		scrollbarTrack._y = 0;
		scrollbarTrack._alpha = 0;
		// generate graph movie called docBg_mc and attach it to container
		docBg_mc = container.createEmptyMovieClip("docBg", -3);
		docBg_mc._y = 0;
		docBg_mc._x = 0;
		// generate graph title
		graphTitle_mc = docBg_mc.createEmptyMovieClip("graphTitle", 0);
		graphTitle_mc.createTextField("graphTitle_txt", 1, 0, 0, 40, 20);
		graphTitle_mc.graphTitle_txt.text = graph_data.firstChild.attributes.title;
		graphTitle_mc.graphTitle_txt.autoSize = "left";
		graphTitle_mc.graphTitle_txt.textColor = graphColors.attributes.title;
		defaultFormat = new TextFormat();
		defaultFormat.font = "_sans";
		defaultFormat.size = 12;
		defaultFormat.bold = true;
		graphTitle_mc.graphTitle_txt.setTextFormat(defaultFormat);
		graphTitle_mc._x = (doc_width-graphTitle_mc._width)/2;
		graphTitle_mc._y = padding_top;
		// loop y axis labels(vertical)
		yName_movie_y = new Array();
		for (i=0; i<yName_temp.length; i++) {
			var j = i+1;
			// generate y axis labels(vertical)
			yName_movie = docBg_mc.createEmptyMovieClip("yName_mc"+i, j);
			yName_movie.createTextField("yName_txt", 1, 0, 0, 110, 20);
			// set y axis label dimension and position
			yName_movie._x = padding_left;
			yName_movie_y[i] = padding_bottom_graphTitle+graphTitle_mc._y+graphTitle_mc._height+(yName_movie._height*j)-yName_movie._height;
			yName_movie._y = yName_movie_y[i];
			yName_movie.yName_txt.text = yName_temp[i].attributes.title;
			yName_movie.yName_txt.textColor = graphColors.attributes.yText;
			defaultFormat = new TextFormat();
			defaultFormat.font = "_sans";
			defaultFormat.align = "right";
			defaultFormat.size = 11;
			yName_movie.yName_txt.setTextFormat(defaultFormat);
			bg_height += yName_movie._height;
		}
		bg_height += yName_movie._height/4;
		var yName_movie_width = yName_movie._width;
		var xName_temp = graph_data.firstChild.childNodes[1];
		minValue = Number(xName_temp.attributes.min);
		maxValue = Number(xName_temp.attributes.max);
		lengthValue = Number(xName_temp.attributes.length);
		prefixValue = xName_temp.attributes.prefix;
		suffixValue = xName_temp.attributes.suffix;
		if (maxValue<1000) {
			incrementValue = maxValue/lengthValue;
		} else {
			incrementValue = Math.round(maxValue/lengthValue);
		}
		trace(incrementValue);
		xNameValue = minValue;
		for (i=0; i<lengthValue+1; i++) {
			var j = i+1;
			// generate x axis labels(horizontal)
			xName_movie = docBg_mc.createEmptyMovieClip("xName_mc"+i, j+yName_temp.length);
			xName_movie.createTextField("xName_txt", 1, 0, 0, 40, 15);
			xName_movie._x = yName_movie_width+padding_left+padding_left_graph+(xName_movie._width*j)-xName_movie._width;
			xName_movie._y = bg_height+graphTitle_mc._y+graphTitle_mc._height+padding_bottom_graphTitle;
			xNameValueStr = String(xNameValue);
			xName_movie.xName_txt.text = prefixValue+xNameValueStr+suffixValue;
			xName_movie.xName_txt.textColor = graphColors.attributes.xText;
			defaultFormat = new TextFormat();
			defaultFormat.font = "_sans";
			defaultFormat.size = 9;
			xName_movie.xName_txt.setTextFormat(defaultFormat);
			if (i != 0) {
				// generate x axis vertical lines
				xLine_movie = docBg_mc.createEmptyMovieClip("xLine_mc"+i, j+yName_temp.length+10);
				xLine_movie.moveTo(0, 0);
				xLine_movie.beginFill(graphColors.attributes.graphLines, 100);
				xLine_movie.lineTo(1, 0);
				xLine_movie.lineTo(1, bg_height-1);
				xLine_movie.lineTo(0, bg_height-1);
				xLine_movie.lineTo(0, 0);
				xLine_movie.endFill();
				// set x axis vertical line dimension and position
				xLine_movie._x = xName_movie._x;
				xLine_movie._y = graphTitle_mc._y+graphTitle_mc._height+padding_bottom_graphTitle+1;
				// generate x axis long markers
				xMarker_movie = docBg_mc.createEmptyMovieClip("xName_marker_mc"+i, (j+yName_temp.length+10)*2);
				xMarker_movie.moveTo(0, 0);
				xMarker_movie.beginFill(graphColors.attributes.graphBorder, 100);
				xMarker_movie.lineTo(1, 0);
				xMarker_movie.lineTo(1, 4);
				xMarker_movie.lineTo(0, 4);
				xMarker_movie.lineTo(0, 0);
				xMarker_movie.endFill();
				xMarker_movie._x = xName_movie._x;
				xMarker_movie._y = graphTitle_mc._y+graphTitle_mc._height+padding_bottom_graphTitle+1+(bg_height-xMarker_movie._height);
			}
			// generate x axis short markers
			xMarker2_movie = docBg_mc.createEmptyMovieClip("xName_marker2_mc"+i, (j+yName_temp.length+11)*3);
			xMarker2_movie.moveTo(0, 0);
			xMarker2_movie.beginFill(graphColors.attributes.graphBorder, 100);
			xMarker2_movie.lineTo(1, 0);
			xMarker2_movie.lineTo(1, 3);
			xMarker2_movie.lineTo(0, 3);
			xMarker2_movie.lineTo(0, 0);
			xMarker2_movie.endFill();
			xMarker2_movie._x = xName_movie._x+(xName_movie._width/2);
			xMarker2_movie._y = graphTitle_mc._y+graphTitle_mc._height+padding_bottom_graphTitle+1+(bg_height-xMarker2_movie._height);
			var bg_width = bg_width+xName_movie._width;
			xNameValue += incrementValue;
		}
		bgg_mc = docBg_mc.createEmptyMovieClip("bgg", -2);
		bgg_mc._x = yName_movie_width+padding_left+padding_left_graph;
		bgg_mc._y = graphTitle_mc._y+graphTitle_mc._height+padding_bottom_graphTitle;
		bgg_mc.moveTo(0, 0);
		bgg_mc.lineStyle(0, graphColors.attributes.graphBorder, 100);
		var fillType = "linear";
		var colors = [Number(graphColors.attributes.graphBg1), Number(graphColors.attributes.graphBg2)];
		var alphas = [100, 100];
		var ratios = [0, 255];
		var matrix = {matrixType:"box", x:0, y:0, w:bg_width, h:bg_height, r:toRadians(0)};
		bgg_mc.beginGradientFill(fillType, colors, alphas, ratios, matrix);
		bgg_mc.lineTo(bg_width, 0);
		bgg_mc.lineTo(bg_width, bg_height);
		bgg_mc.lineTo(0, bg_height);
		bgg_mc.lineTo(0, 0);
		bgg_mc.endFill();
		var yDataBarScale = (bg_width-xName_movie._width)/maxValue;
		//create empty movie clip and attach dynamic text field for alt text
		txt_movie = docBg_mc.createEmptyMovieClip("altText_mc", 10000);
		txt_movie.createTextField("altText_txt", 1, 0, 0, bgg_mc._width, 40);
		txt_movie.altText_txt.multiline = true;
		txt_movie.altText_txt.wordWrap = true;
		txt_movie.altText_txt.border = true;
		txt_movie.altText_txt.textColor = graphColors.attributes.altText;
		txt_movie.altText_txt.borderColor = graphColors.attributes.altBorder;
		txt_movie.altText_txt.background = true;
		txt_movie.altText_txt.backgroundColor = graphColors.attributes.altBg;
		txt_movie._x = bgg_mc._x;
		txt_movie._y = xName_movie._y+xName_movie._height+10;
		defaultFormat = new TextFormat();
		defaultFormat.font = "_sans";
		defaultFormat.size = 10;
		//create empty movie clip and attach dynamic text field for misc graph info
		graphInfo_movie = docBg_mc.createEmptyMovieClip("graphInfo_mc", 10001);
		graphInfo_movie.createTextField("graphInfo_txt", 1, 0, 0, bgg_mc._width, 30);
		graphInfo_movie.graphInfo_txt.multiline = true;
		graphInfo_movie.graphInfo_txt.wordWrap = true;
		graphInfo_movie.graphInfo_txt.html = true;
		graphInfo_txt = graph_data.firstChild.childNodes[3].firstChild.nodeValue;
		graphInfo_movie.graphInfo_txt.htmlText = graphInfo_txt;
		graphInfo_movie.graphInfo_txt.textColor = graphColors.attributes.misc;
		graphInfo_movie._x = bgg_mc._x;
		graphInfo_movie._y = txt_movie._y+txt_movie._height+10;
		defaultFormat = new TextFormat();
		defaultFormat.font = "_sans";
		defaultFormat.size = 10;
		graphInfo_movie.graphInfo_txt.setTextFormat(defaultFormat);
		// generate bars
		// create object to pass properties into bar movie
		yDataBar_movie_OP = new Object();
		yDataBar_movie_OP.yDataBarScale = yDataBarScale;
		yDataBar_movie_OP.padding = yName_movie._width+padding_left+padding_left_graph;
		yDataBar_movie_OP.colorLegend_temp = colorLegend_temp;
		yDataBar_movie_OP.txt_movie = txt_movie;
		yDataBar_movie_OP.defaultFormat = defaultFormat;
		yDataBar_movie_OP.graphColors = graphColors;
		yDataBar_movie_OP.yName_temp = yName_temp;
		yDataBar_movie_OP.yDataBar_movie_OP = yDataBar_movie_OP;
		yWholeDataBar_movie = docBg_mc.attachMovie("yWholeDataBar_mc", "yWholeDataBar_mc", 10002, yDataBar_movie_OP);
		// make scrollbar draggable
		diff_y = bound_box._height-scroller._height;
		bounds = bound_box.getBounds(container);
		top = bounds.yMin+(scroller._height/2);
		bottom = bounds.yMax-(scroller._height/2);
		if (docBg_mc._height>bound_box._height+1) {
			scroller._alpha = 100;
			scrollbarTrack._alpha = 100;
		}
		container.updateScrollbar = function() {
			docBg_mc._y = -(((scroller._y-top)/diff_y)*(docBg_mc._height-bound_box._height));
		};
		container.onMouseDown = function() {
			if (scroller.hitTest(_root._xmouse, _root._ymouse)) {
				startDrag("scroller", false, scroller._x, top, scroller._x, bottom);
				scrolling = true;
			}
		};
		// here we stop the drag and set scrolling to false
		container.onMouseUp = function() {
			stopDrag();
			scrolling = false;
		};
		container.onEnterFrame = function() {
			if (scrolling) {
				container.updateScrollbar();
			}
		};
		//fill in background gradient
		docBg_mc.moveTo(0, 0);
		docBg_mc.beginFill(0xFFFFFF, 0);
		docBg_mc.lineTo(doc_width, 0);
		docBg_mc.lineTo(doc_width, docBg_mc._height);
		docBg_mc.lineTo(0, docBg_mc._height);
		docBg_mc.lineTo(0, 0);
		docBg_mc.endFill();
		bgFill_height = doc_height;
		if (docBg_mc._height>doc_height) {
			bgFill_height = docBg_mc._height;
		}
		bgFill = createEmptyMovieClip("bgFill", -10);
		bgFill.moveTo(0, 0);
		fillType = "linear";
		colors = [Number(graphColors.attributes.docBg1), Number(graphColors.attributes.docBg2)];
		alphas = [100, 100];
		ratios = [0, 255];
		matrix = {matrixType:"box", x:0, y:0, w:doc_width, h:bgFill_height, r:toRadians(90)};
		bgFill.beginGradientFill(fillType, colors, alphas, ratios, matrix);
		bgFill.lineTo(doc_width, 0);
		bgFill.lineTo(doc_width, bgFill_height);
		bgFill.lineTo(0, bgFill_height);
		bgFill.lineTo(0, 0);
		bgFill.endFill();
	}
}

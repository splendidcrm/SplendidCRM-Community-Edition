//Portions created by SugarCRM are Copyright (C) 2005 SugarCRM, Inc.; All Rights Reserved.
//See LICENSE.txt for license information
#include "colorFunctions.as"
// degree to radian converter
function toRadians(deg) {
	return deg*Math.PI/180;
}
// set document variables
var doc_height = 400;
var doc_width = 800;
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
//graph_data.load('vBarF.xml');
graph_data.load(filename+"?"+Math.random());
function handleLoad(success) {
	if (success) {
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
		scrollbarWidth = 20;
		scrollbarHeight = 100;
		scroller = container.createEmptyMovieClip("scroller", 2);
		scrollbar = scroller.createEmptyMovieClip("scrollbar", 1);
		scrollbar.beginFill(graphColors.attributes.scrollBar, 100);
		scrollbar.lineStyle(0, graphColors.attributes.scrollBarBorder);
		scrollbar.lineTo(scrollbarWidth, 0);
		scrollbar.lineTo(scrollbarWidth, 100);
		scrollbar.lineTo(0, 100);
		scrollbar.lineTo(0, 0);
		scrollbar.endFill();
		scrollbar._width = scrollbarWidth;
		scrollbar._height = scrollbarHeight;
		scrollbar._x = -scrollbarWidth/2;
		scrollbar._y = -scrollbarHeight/2;
		scroller._x = (doc_width-1)-(scrollbarWidth/2);
		scroller._y = scrollbarHeight/2;
		scroller._alpha = 0;
		// generate scrollbar track movie and attach it to container
		scrollbarTrack_width = scrollbarWidth+2;
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
		graphTitle_mc = docBg_mc.createEmptyMovieClip("graphTitle", -1);
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
		// set y axis variables
		var yName_temp = graph_data.firstChild.childNodes[1];
		minValue = Number(yName_temp.attributes.min);
		maxValue = Number(yName_temp.attributes.max);
		yLengthValue = Number(yName_temp.attributes.length);
		prefixValue = yName_temp.attributes.prefix;
		suffixValue = yName_temp.attributes.suffix;
		if (maxValue<=1000) {
			incrementValue = maxValue/yLengthValue;
		} else {
			incrementValue = Math.round(maxValue/yLengthValue);
		}
		yNameValue = maxValue;
		yName_movie_txt_width = 90;
		yName_movie_txt_height = 15;
		yName_movie_height = 20;
		yName_movie_txt_x = yName_movie_height-yName_movie_txt_height;
		// set x axis variables
		var xName_temp = graph_data.firstChild.firstChild.childNodes;
		xLengthValue = Number(graph_data.firstChild.firstChild.attributes.length);
		xName_movie_txt_min_width = 25;
		xName_movie_txt_max_width = 100;
		bg_width = xLengthValue*xName_movie_txt_min_width;
		// loop y axis labels(vertical)
		yName_movie_y = new Array();
		docBg_level = 1;
		for (i=0; i<yLengthValue+1; i++) {
			var j = i+1;
			yName_movie = docBg_mc.createEmptyMovieClip("yName_mc"+i, i);
			yName_movie.createTextField("yName_txt", 1, 0, yName_movie_txt_x, yName_movie_txt_width, yName_movie_txt_height);
			yName_movie._x = padding_left;
			yName_movie_y[i] = padding_bottom_graphTitle+graphTitle_mc._y+graphTitle_mc._height+(yName_movie_height*j)-yName_movie_height;
			yName_movie._y = yName_movie_y[i];
			yNameValueStr = String(yNameValue);
			yName_movie.yName_txt.text = prefixValue+yNameValueStr+suffixValue;
			yName_movie.yName_txt.textColor = graphColors.attributes.yText;
			defaultFormat = new TextFormat();
			defaultFormat.font = "_sans";
			defaultFormat.align = "right";
			defaultFormat.size = 11;
			yName_movie.yName_txt.setTextFormat(defaultFormat);
			// generate y axis horizontal lines
			if (i != 0) {
				yLine_movie = docBg_mc.createEmptyMovieClip("xLine_mc"+i, yLengthValue+j);
				yLine_movie.moveTo(0, 0);
				yLine_movie.beginFill(graphColors.attributes.graphLines, 100);
				yLine_movie.lineTo(bg_width-1, 0);
				yLine_movie.lineTo(bg_width-1, 1);
				yLine_movie.lineTo(0, 1);
				yLine_movie.lineTo(0, 0);
				yLine_movie.endFill();
				// set y axis horizontal line dimension and position
				yLine_movie._x = yName_movie_txt_width+padding_left+padding_left_graph+1;
				yLine_movie._y = yName_movie._y;
				// generate y axis long markers
				yMarker_movie = docBg_mc.createEmptyMovieClip("yName_marker_mc"+i, ((yLengthValue+1)*2)+j);
				yMarker_movie.moveTo(0, 0);
				yMarker_movie.beginFill(graphColors.attributes.graphBorder, 100);
				yMarker_movie.lineTo(5, 0);
				yMarker_movie.lineTo(5, 1);
				yMarker_movie.lineTo(0, 1);
				yMarker_movie.lineTo(0, 0);
				yMarker_movie.endFill();
				yMarker_movie._x = yName_movie_txt_width+padding_left+padding_left_graph-5;
				yMarker_movie._y = yName_movie._y;
			}
			// generate y axis short markers
			yMarker2_movie = docBg_mc.createEmptyMovieClip("yName_marker2_mc"+i, ((yLengthValue+2)*3)+j);
			yMarker2_movie.moveTo(0, 0);
			yMarker2_movie.beginFill(graphColors.attributes.graphBorder, 100);
			yMarker2_movie.lineTo(3, 0);
			yMarker2_movie.lineTo(3, 1);
			yMarker2_movie.lineTo(0, 1);
			yMarker2_movie.lineTo(0, 0);
			yMarker2_movie.endFill();
			yMarker2_movie._x = yName_movie_txt_width+padding_left+padding_left_graph-3;
			yMarker2_movie._y = yName_movie._y+(yName_movie_height/2);
			yNameValue -= incrementValue;
		}
		bg_height = yName_movie_height*(yLengthValue+1);
		var yName_movie_width = yName_movie._width;
		// set more x axis variables
		xName_movie_txt_width_tmp = bg_width/xName_temp.length;
		if (xName_movie_txt_width_tmp<xName_movie_txt_min_width) {
			xName_movie_txt_width = xName_movie_txt_min_width;
		} else if (xName_movie_txt_width_tmp>xName_movie_txt_max_width) {
			xName_movie_txt_width = xName_movie_txt_max_width;
		} else {
			xName_movie_txt_width = xName_movie_txt_width_tmp;
		}
		xName_movie_txt_height = 15;
		xName_movie_start = padding_left+yName_movie_width+padding_left_graph;
		xIncrement = bg_width/xName_temp.length;
		// loop x axis labels(vertical)
		xName_movie_x = new Array();
		for (i=0; i<xName_temp.length; i++) {
			var j = i+1;
			docBg_level += j;
			xName_movie = docBg_mc.createEmptyMovieClip("xName_mc"+i, (yLengthValue*5)+j);
			xName_movie.createTextField("xName_txt", 1, 0, 0, xName_movie_txt_width, xName_movie_txt_height);
			xName_movie_x[i] = (((xIncrement*i)+xName_movie_start)-(xName_movie._width/2))+(xIncrement/2);
			xName_movie._x = xName_movie_x[i];
			xName_movie._y = bg_height+graphTitle_mc._y+graphTitle_mc._height+padding_bottom_graphTitle;
			xName_movie.xName_txt.text = xName_temp[i].attributes.title;
			xName_movie.xName_txt.textColor = graphColors.attributes.xText;
			defaultFormat = new TextFormat();
			defaultFormat.font = "_sans";
			defaultFormat.align = "center";
			defaultFormat.size = 9;
			xName_movie.xName_txt.setTextFormat(defaultFormat);
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
		var matrix = {matrixType:"box", x:0, y:0, w:bg_width, h:bg_height, r:toRadians(90)};
		bgg_mc.beginGradientFill(fillType, colors, alphas, ratios, matrix);
		bgg_mc.lineTo(bg_width, 0);
		bgg_mc.lineTo(bg_width, bg_height);
		bgg_mc.lineTo(0, bg_height);
		bgg_mc.lineTo(0, 0);
		bgg_mc.endFill();
		//create empty movie clip and attach dynamic text field for alt text
		txt_movie = docBg_mc.createEmptyMovieClip("altText_mc", 10000);
		txt_movie.createTextField("altText_txt", 1, 0, 0, bgg_mc._width, 30);
		txt_movie.altText_txt.multiline = true;
		txt_movie.altText_txt.wordWrap = true;
		txt_movie.altText_txt.textColor = graphColors.attributes.altText;
		txt_movie.altText_txt.border = true;
		txt_movie.altText_txt.borderColor = graphColors.attributes.altBorder;
		txt_movie.altText_txt.background = true;
		txt_movie.altText_txt.backgroundColor = graphColors.attributes.altBg;
		txt_movie._x = bgg_mc._x;
		txt_movie._y = xName_movie._y+xName_movie._height+10;
		defaultFormat_tm = new TextFormat();
		defaultFormat_tm.font = "_sans";
		defaultFormat_tm.size = 10;
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
		var xDataBarScale = (bg_height-yName_movie_height)/maxValue;
		xDataBar_movie_OP = new Object();
		xDataBar_movie_OP.xDataBarScale = xDataBarScale;
		xDataBar_movie_OP.padding = bgg_mc._y+bgg_mc._height;
		xDataBar_movie_OP.colorLegend_temp = colorLegend_temp;
		xDataBar_movie_OP.txt_movie = txt_movie;
		xDataBar_movie_OP.graphColors = graphColors;
		xDataBar_movie_OP.defaultFormat_tm = defaultFormat_tm;
		xDataBar_movie_OP.xName_temp = xName_temp;
		xDataBar_movie_OP.xDataBar_movie_OP = xDataBar_movie_OP;
		xWholeDataBar_movie = docBg_mc.attachMovie("xWholeDataBar_mc", "xWholeDataBar_mc", 10002, xDataBar_movie_OP);
		//create a empty movie clip for legendBox
		keyBoxSize = 14;
		legendLabel_height = 18;
		legendLabel_width = 120;
		legendBox_innerPad = 5;
		legendBox_height = (legendLabel_height*colorLegend_temp.length)+legendBox_innerPad;
		legendBox_width = legendLabel_width+keyBoxSize+(legendBox_innerPad*3);
		legendBox_mc = docBg_mc.createEmptyMovieClip("legendBox", 10003);
		legendBox_mc.moveTo(0, 0);
		legendBox_mc.lineStyle(0, graphColors.attributes.legendBorder, 100);
		fillType = "linear";
		colors = [Number(graphColors.attributes.legendBg1), Number(graphColors.attributes.legendBg2)];
		alphas = [100, 100];
		ratios = [0, 255];
		matrix = {matrixType:"box", x:0, y:0, w:legendBox_width, h:legendBox_height, r:toRadians(90)};
		legendBox_mc.beginGradientFill(fillType, colors, alphas, ratios, matrix);
		legendBox_mc.lineTo(legendBox_width, 0);
		legendBox_mc.lineTo(legendBox_width, legendBox_height);
		legendBox_mc.lineTo(0, legendBox_height);
		legendBox_mc.lineTo(0, 0);
		legendBox_mc.endFill();
		legendBox_mc._y = bgg_mc._y;
		legendBox_mc._x = bgg_mc._x+bgg_mc._width+padding_right_graph;
		legendLabels = new Array();
		//  loop through colorLegend_temp array to dynamically create Legend
		for (i=0; i<colorLegend_temp.length; i++) {
			name_txt = colorLegend_temp[i].attributes.name;
			id = colorLegend_temp[i].attributes.id;
			colorValue = Number(colorLegend_temp[i].attributes.color);
			// create empty movie clip for colored box
			newBaseColor = Color.setHexSaturation(colorValue, 40);
			legendColorKey_movie = legendBox_mc.createEmptyMovieClip("legendColorKey"+i, 1300+i);
			legendColorKey_movie.moveTo(0, 0);
			legendColorKey_movie.lineStyle(0, graphColors.attributes.legendColorKeyBorder, 100);
			var fillType = "linear";
			var colors = [colorValue, newBaseColor];
			var alphas = [100, 100];
			var ratios = [0, 255];
			var matrix = {matrixType:"box", x:0, y:0, w:keyBoxSize, h:keyBoxSize, r:toRadians(-90)};
			legendColorKey_movie.beginGradientFill(fillType, colors, alphas, ratios, matrix);
			legendColorKey_movie.lineTo(keyBoxSize, 0);
			legendColorKey_movie.lineTo(keyBoxSize, keyBoxSize);
			legendColorKey_movie.lineTo(0, keyBoxSize);
			legendColorKey_movie.lineTo(0, 0);
			legendColorKey_movie.endFill();
			legendColorKey_movie._x = legendBox_innerPad;
			//create a empty movie clip 
			legendLabel_mc = legendBox_mc.createEmptyMovieClip("legendLabel"+id, 1200+i);
			legendLabels[id] = legendBox_mc["legendLabel"+id];
			//attach text field to movie clip
			legendLabel_mc.createTextField("legendLabel_txt", 1, 0, 0, legendLabel_width, legendLabel_height);
			legendLabel_mc.legendLabel_txt.text = name_txt;
			legendLabel_mc.legendLabel_txt.textColor = graphColors.attributes.legendText;
			defaultFormat = new TextFormat();
			defaultFormat.font = "_sans";
			defaultFormat.size = 11;
			legendLabel_mc.legendLabel_txt.setTextFormat(defaultFormat);
			legendLabel_mc._x = legendColorKey_movie._x+legendColorKey_movie._width+5;
			legendLabel_mc_temp += legendLabel_mc._height;
			legendLabel_mc._y = legendLabel_mc_temp-legendLabel_mc._height+legendBox_innerPad;
			legendColorKey_movie._y = legendLabel_mc._y;
		}
		// make scrollbar draggable
		diff_y = bound_box._height-scroller._height;
		bounds = bound_box.getBounds(container);
		top = bounds.yMin+(scroller._height/2);
		bottom = bounds.yMax-(scroller._height/2);
		if (docBg_mc._height>bound_box._height+1) {
			scroller._alpha = 100;
			scrollbarTrack._alpha = 100;
		}
		container.updateScrollbar = function () {
			docBg_mc._y = -(((scroller._y-top)/diff_y)*(docBg_mc._height-bound_box._height));
		}
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

//Portions created by SugarCRM are Copyright (C) 2005 SugarCRM, Inc.; All Rights Reserved.
//See LICENSE.txt for license information
#include "drawWedge.as"
#include "colorFunctions.as"
// degree to radian converter
function toRadians(deg) {
	return deg*Math.PI/180;
}
//function for determining the max value in an array
function maxInArray(checkArray) {
	maxValue = -Number.MAX_VALUE;
	for (i=0; i<checkArray.length; i++) {
		maxVal = Math.max(checkArray[i], maxVal);
	}
	return maxVal;
}
var doc_width = 800;
var doc_height = 400;
var padding_top = 10;
var padding_bottom = 10;
var circle_radius = 100;
var maxValOffset = 10;
var textOffset = 10;
var labelText_height = 15;
var graphInfo_height = 40;
// create XML object and get xml file path
graph_data = new XML();
graph_data.onLoad = handleLoad;
graph_data.ignoreWhite = true;
// load varibles from xml file
//graph_data.load('pie.xml');
graph_data.load(filename+"?"+Math.random());
function handleLoad(success) {
	if (success) {
		var graphColors = graph_data.firstChild.childNodes[2];
		var defaultAltText = graph_data.firstChild.firstChild.attributes.defaultAltText;
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
		scrollbar.lineTo(scrollbarWidth, scrollbarHeight);
		scrollbar.lineTo(0, scrollbarHeight);
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
		graphTitle_mc = docBg_mc.createEmptyMovieClip("graphTitle", 0);
		graphTitle_mc.createTextField("graphTitle_txt", 1, 0, 0, 40, 20);
		graphTitle_mc.graphTitle_txt.text = graph_data.firstChild.attributes.title;
		graphTitle_mc.graphTitle_txt.textColor = graphColors.attributes.title;
		graphTitle_mc.graphTitle_txt.autoSize = "left";
		defaultFormat = new TextFormat();
		defaultFormat.font = "_sans";
		defaultFormat.size = 12;
		defaultFormat.bold = true;
		graphTitle_mc.graphTitle_txt.setTextFormat(defaultFormat);
		graphTitle_mc._x = (doc_width-graphTitle_mc._width)/2;
		graphTitle_mc._y = ((doc_height/2)-(circle_radius+maxValOffset+textOffset+graphTitle_mc._height+labelText_height))/2;
		// generate graph subtitle
		graphSubTitle_mc = docBg_mc.createEmptyMovieClip("graphSubTitle", 1);
		graphSubTitle_mc.createTextField("graphSubTitle_txt", 1, 0, 0, 40, 20);
		graphSubTitle_mc.graphSubTitle_txt.text = graph_data.firstChild.attributes.subtitle;
		graphSubTitle_mc.graphSubTitle_txt.autoSize = "left";
		graphSubTitle_mc.graphSubTitle_txt.textColor = graphColors.attributes.subtitle;
		defaultFormat = new TextFormat();
		defaultFormat.font = "_sans";
		defaultFormat.size = 10;
		defaultFormat.bold = true;
		graphSubTitle_mc.graphSubTitle_txt.setTextFormat(defaultFormat);
		graphSubTitle_mc._x = (doc_width-graphSubTitle_mc._width)/2;
		graphSubTitle_mc._y = graphTitle_mc._y+graphTitle_mc._height;
		//create empty movie clip and attach dynamic text field for alt text
		altText_movie_width = 220;
		altText_movie_height = 30;
		txt_movie = docBg_mc.createEmptyMovieClip("altText_mc", 1000);
		txt_movie.createTextField("altText_txt", 1, 0, 0, altText_movie_width, altText_movie_height);
		txt_movie.altText_txt.multiline = true;
		txt_movie.altText_txt.wordWrap = true;
		txt_movie.altText_txt.border = true;
		txt_movie.altText_txt.borderColor = graphColors.attributes.altBorder;
		txt_movie.altText_txt.background = true;
		txt_movie.altText_txt.backgroundColor = graphColors.attributes.altBg;
		txt_movie.altText_txt.textColor = graphColors.attributes.altText;
		txt_movie._x = (doc_width-((doc_width*.50)+circle_radius+maxValOffset))/2-(txt_movie._width/2);
		txt_movie._y = (doc_height/2)-(circle_radius+maxValOffset);
		defaultAltTextFormat = new TextFormat();
		defaultAltTextFormat.font = "_sans";
		defaultAltTextFormat.size = 10;
		//create empty movie clip and attach dynamic text field for misc graph info
		graphInfo_movie = docBg_mc.createEmptyMovieClip("graphInfo_mc", 9);
		graphInfo_movie.createTextField("graphInfo_txt", 1, 0, 0, circle_radius*2, graphInfo_height);
		graphInfo_movie.graphInfo_txt.multiline = true;
		graphInfo_movie.graphInfo_txt.wordWrap = true;
		graphInfo_movie.graphInfo_txt.html = true;
		graphInfo_txt = graph_data.firstChild.childNodes[1].firstChild.nodeValue;
		graphInfo_movie.graphInfo_txt.htmlText = graphInfo_txt;
		graphInfo_movie.graphInfo_txt.textColor = graphColors.attributes.misc;
		graphInfo_movie._x = (doc_width/2)-circle_radius;
		graphInfo_movie._y = ((doc_height/2)+(circle_radius+maxValOffset+textOffset+labelText_height+(graphInfo_movie._height/2)));
		defaultFormat = new TextFormat();
		defaultFormat.font = "_sans";
		defaultFormat.size = 10;
		graphInfo_movie.graphInfo_txt.setTextFormat(defaultFormat);
		// get the sum of wedge values
		var wedges_tmp = graph_data.firstChild.firstChild.childNodes;
		arrWedgeVal = new Array();
		for (i=0; i<wedges_tmp.length; i++) {
			wedgeSum += Number(wedges_tmp[i].attributes.value);
			arrWedgeVal[i] = Number(wedges_tmp[i].attributes.value);
		}
		wedgeMaxVal = maxInArray(arrWedgeVal);
		multiplier = 360/wedgeSum;
		// generate legend items
		keyBoxSize = 14;
		legendBox_innerPad = 5;
		legendLabel_height = 18;
		legendLabel_width = 120;
		legendBox_mc_width = legendLabel_width+(legendBox_innerPad*3)+keyBoxSize;
		legendBox_mc_height = (legendLabel_height*wedges_tmp.length)+(legendBox_innerPad*2);
		// generate legend box
		legendBox_mc = docBg_mc.createEmptyMovieClip("legendBox", 10);
		legendBox_mc.lineStyle(0, graphColors.attributes.legendBorder, 100);
		fillType = "linear";
		colors = [Number(graphColors.attributes.legendBg1), Number(graphColors.attributes.legendBg2)];
		alphas = [100, 100];
		ratios = [0, 255];
		matrix = {matrixType:"box", x:0, y:0, w:legendBox_mc_width, h:legendBox_mc_height, r:toRadians(90)};
		legendBox_mc.beginGradientFill(fillType, colors, alphas, ratios, matrix);
		legendBox_mc.lineTo(legendBox_mc_width, 0);
		legendBox_mc.lineTo(legendBox_mc_width, legendBox_mc_height);
		legendBox_mc.lineTo(0, legendBox_mc_height);
		legendBox_mc.lineTo(0, 0);
		legendBox_mc.endFill();
		legendBox_mc._y = (doc_height/2)-(circle_radius+maxValOffset);
		legendBox_mc._x = (doc_width-((doc_width-((doc_width*.50)+circle_radius+maxValOffset))/2))-(legendBox_mc._width/2);
		//  loop through wedges_tmp array to dynamically create Legend
		legendLabels = new Array();
		for (i=0; i<wedges_tmp.length; i++) {
			title_txt = wedges_tmp[i].attributes.title;
			colorValue = Number(wedges_tmp[i].attributes.color);
			// create empty movie clip for colored box
			newBaseColor = Color.setHexSaturation(colorValue, 40);
			legendColorKey_movie = legendBox_mc.createEmptyMovieClip("legendColorKey"+i, 1000+i);
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
			//create a empty movie clip for legend labels
			legendLabel_mc = legendBox_mc.createEmptyMovieClip("legendLabel"+i, 2000+i);
			legendLabels[i] = legendBox_mc["legendLabel"+i];
			//attach text field to movie clip
			legendLabel_mc.createTextField("legendLabel_txt", 1, 0, 0, legendLabel_width, legendLabel_height);
			legendLabel_mc.legendLabel_txt.textColor = graphColors.attributes.legendText;
			legendLabel_mc.legendLabel_txt.text = title_txt;
			defaultFormat = new TextFormat();
			defaultFormat.font = "_sans";
			defaultFormat.size = 11;
			legendLabel_mc.legendLabel_txt.setTextFormat(defaultFormat);
			legendLabel_mc._x = legendColorKey_movie._x+legendColorKey_movie._width+5;
			legendLabel_mc_temp += legendLabel_mc._height;
			legendLabel_mc._y = legendLabel_mc_temp-legendLabel_mc._height+legendBox_innerPad;
			legendColorKey_movie._y = legendLabel_mc._y;
		}
		// create object to stuff properties into
		wedgeMovie_prp = new Object();
		wedgeMovie_prp.multiplier = multiplier;
		wedgeMovie_prp.wedges_tmp = wedges_tmp;
		wedgeMovie_prp.wedgeMaxVal = wedgeMaxVal;
		wedgeMovie_prp.graphColors = graphColors;
		wedgeMovie_prp.txt_movie = txt_movie;
		wedgeMovie_prp.defaultAltText = defaultAltText;
		wedgeMovie_prp.defaultAltTextFormat = defaultAltTextFormat;
		// attach wedgeMovie to generate wedges
		wedgeMovie_mc = docBg_mc.attachMovie("wedgeMovie", "wedgeMovie", 2, wedgeMovie_prp);
		
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
		docBg_mc.lineTo(doc_width, docBg_mc._height+padding_bottom);
		docBg_mc.lineTo(0, docBg_mc._height+padding_bottom);
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

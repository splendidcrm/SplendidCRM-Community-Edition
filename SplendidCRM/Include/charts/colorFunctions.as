//Portions created by SugarCRM are Copyright (C) 2005 SugarCRM, Inc.; All Rights Reserved.
//See LICENSE.txt for license information
Color.RGBtoHEX = function(r,g,b) {
	r = r.toString(16);
	g = g.toString(16);
	b = b.toString(16);
	r = (r.length < 2) ? "0"+r : r;
	g = (g.length < 2) ? "0"+g : g;
	b = (b.length < 2) ? "0"+b : b;
	return "0x"+(r+g+b).toUpperCase();
}


Color.HEXtoRGB = function(hex) {
	var rgb24 = (isNaN(hex)) ? parseInt(hex, 16) : hex;
	var r = rgb24 >> 16;
	var g = (rgb24 ^ (r << 16)) >> 8;
	var b = (rgb24 ^ (r << 16)) ^ (g << 8);
	return {r:r, g:g, b:b};
}


Color.HSBtoRGB = function(h,s,v) {
	var r,g,b;
	var h = Math.round(h);
	var s = Math.round(s*255/100);
	var v = Math.round(v*255/100);
	if(s == 0) {
		r = g = b = v;
	} else {
		var t1 = v;	
		var t2 = (255-s)*v/255;	
		var t3 = (t1-t2)*(h%60)/60;
		if(h==360) h = 0;
		if(h<60) {r=t1;	b=t2;	g=t2+t3}
		else if(h<120) {g=t1;	b=t2;	r=t1-t3}
		else if(h<180) {g=t1;	r=t2;	b=t2+t3}
		else if(h<240) {b=t1;	r=t2;	g=t1-t3}
		else if(h<300) {b=t1;	g=t2;	r=t2+t3}
		else if(h<360) {r=t1;	g=t2;	b=t1-t3}
		else {r=0;	g=0;	b=0}
	}
	return {r:r, g:g, b:b};
}

Color.RGBtoHSB = function(r,g,b) {
	var hsb = new Object();
	hsb.b = Math.max(Math.max(r,g),b);
	var min = Math.min(Math.min(r,g),b);
	hsb.s = (hsb.b <= 0) ? 0 : Math.round(100*(hsb.b - min)/hsb.b);
	hsb.b = Math.round((hsb.b /255)*100);
	hsb.h = 0;
	if((r==g) && (g==b))  hsb.h = 0;
	else if(r>=g && g>=b) hsb.h = 60*(g-b)/(r-b);
	else if(g>=r && r>=b) hsb.h = 60  + 60*(g-r)/(g-b);
	else if(g>=b && b>=r) hsb.h = 120 + 60*(b-r)/(g-r);
	else if(b>=g && g>=r) hsb.h = 180 + 60*(b-g)/(b-r);
	else if(b>=r && r>=g) hsb.h = 240 + 60*(r-g)/(b-g);
	else if(r>=b && b>=g) hsb.h = 300 + 60*(r-b)/(r-g);
	else hsb.h = 0;
	hsb.h = Math.round(hsb.h);
	return hsb;
}

Color.setHexSaturation = function(hex, percent) {
	rgb = Color.HEXtoRGB(hex);
	hsb = Color.RGBtoHSB(rgb.r, rgb.g, rgb.b);
	newS = Math.round((percent/100)*hsb.s);
	newRgb = Color.HSBtoRGB(hsb.h, newS, hsb.b);
	newHex = Color.RGBtoHEX(newRGB.r, newRGB.g, newRGB.b);
	return Number(newHex);
}

//Portions created by SugarCRM are Copyright (C) 2005 SugarCRM, Inc.; All Rights Reserved.
//See LICENSE.txt for license information
/*-------------------------------------------------------------
	mc.drawOval is a method for creating circles and
	ovals. Hopefully this one is pretty straight
	forward. This method, like most of the others, is
	not as optimized as it could be. This was a
	conscious decision to keep the code as accessible as
	possible for those either new to AS or to the math
	involved in plotting points on a curve.
-------------------------------------------------------------*/
MovieClip.prototype.drawOval = function(x, y, radius, yRadius) {
	// ==============
	// mc.drawOval() - by Ric Ewing (ric@formequalsfunction.com) - version 1.1 - 4.7.2002
	// 
	// x, y = center of oval
	// radius = radius of oval. If [optional] yRadius is defined, r is the x radius.
	// yRadius = [optional] y radius of oval.
	// ==============
	if (arguments.length<3) {
		return;
	}
	// init variables
	var theta, xrCtrl, yrCtrl, angle, angleMid, px, py, cx, cy;
	// if only yRadius is undefined, yRadius = radius
	if (yRadius == undefined) {
		yRadius = radius;
	}
	// covert 45 degrees to radians for our calculations
	theta = Math.PI/4;
	// calculate the distance for the control point
	xrCtrl = radius/Math.cos(theta/2);
	yrCtrl = yRadius/Math.cos(theta/2);
	// start on the right side of the circle
	angle = 0;
	this.moveTo(x+radius, y);
	// this loop draws the circle in 8 segments
	for (var i = 0; i<8; i++) {
		// increment our angles
		angle += theta;
		angleMid = angle-(theta/2);
		// calculate our control point
		cx = x+Math.cos(angleMid)*xrCtrl;
		cy = y+Math.sin(angleMid)*yrCtrl;
		// calculate our end point
		px = x+Math.cos(angle)*radius;
		py = y+Math.sin(angle)*yRadius;
		// draw the circle segment
		this.curveTo(cx, cy, px, py);
	}
};

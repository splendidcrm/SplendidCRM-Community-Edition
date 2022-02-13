//Portions created by SugarCRM are Copyright (C) 2005 SugarCRM, Inc.; All Rights Reserved.
//See LICENSE.txt for license information
/*-------------------------------------------------------------
	mc.drawStar is a method for drawing star shaped
	polygons. Note that the stars by default 'point' to
	the right. This is because the method starts drawing
	at 0 degrees by default, putting the first point to
	the right of center. Negative values for points
	draws the star in reverse direction, allowing for
	knock-outs when used as part of a mask.
-------------------------------------------------------------*/
MovieClip.prototype.drawStar = function(x, y, points, innerRadius, outerRadius, angle) {
	// ==============
	// mc.drawStar() - by Ric Ewing (ric@formequalsfunction.com) - version 1.4 - 4.7.2002
	// 
	// x, y = center of star
	// points = number of points (Math.abs(points) must be > 2)
	// innerRadius = radius of the indent of the points
	// outerRadius = radius of the tips of the points
	// angle = [optional] starting angle in degrees. (defaults to 0)
	// ==============
	if(arguments.length < 5) {
		return;
	}
	var count = Math.abs(points);
	if (count>2) {
		// init vars
		var step, halfStep, start, n, dx, dy;
		// calculate distance between points
		step = (Math.PI*2)/points;
		halfStep = step/2;
		// calculate starting angle in radians
		start = (angle/180)*Math.PI;
		this.moveTo(x+(Math.cos(start)*outerRadius), y-(Math.sin(start)*outerRadius));
		// draw lines
		for (n=1; n<=count; n++) {
			dx = x+Math.cos(start+(step*n)-halfStep)*innerRadius;
			dy = y-Math.sin(start+(step*n)-halfStep)*innerRadius;
			this.lineTo(dx, dy);
			dx = x+Math.cos(start+(step*n))*outerRadius;
			dy = y-Math.sin(start+(step*n))*outerRadius;
			this.lineTo(dx, dy);
		}
	}
};

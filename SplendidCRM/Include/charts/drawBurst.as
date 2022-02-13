//Portions created by SugarCRM are Copyright (C) 2005 SugarCRM, Inc.; All Rights Reserved.
//See LICENSE.txt for license information
/*-------------------------------------------------------------
	mc.drawBurst is a method for drawing bursts (rounded
	star shaped ovals often seen in advertising). This
	seemingly whimsical method actually had a serious
	purpose. It was done to accommodate a client that
	wanted to have custom bursts for 'NEW!' and
	'IMPROVED!' type elements on their site...
	personally I think those look tacky, but it's hard
	to argue with a paying client. :) This method also
	makes some fun flower shapes if you play with the
	input numbers. 
-------------------------------------------------------------*/
MovieClip.prototype.drawBurst = function(x, y, sides, innerRadius, outerRadius, angle) {
	// ==============
	// mc.drawBurst() - by Ric Ewing (ric@formequalsfunction.com) - version 1.4 - 4.7.2002
	// 
	// x, y = center of burst
	// sides = number of sides or points
	// innerRadius = radius of the indent of the curves
	// outerRadius = radius of the outermost points
	// angle = [optional] starting angle in degrees. (defaults to 0)
	// ==============
	if(arguments<5) {
		return;
	}
	if (sides>2) {
		// init vars
		var step, halfStep, qtrStep, start, n, dx, dy, cx, cy;
		// calculate length of sides
		step = (Math.PI*2)/sides;
		halfStep = step/2;
		qtrStep = step/4;
		// calculate starting angle in radians
		start = (angle/180)*Math.PI;
		this.moveTo(x+(Math.cos(start)*outerRadius), y-(Math.sin(start)*outerRadius));
		// draw curves
		for (n=1; n<=sides; n++) {
			cx = x+Math.cos(start+(step*n)-(qtrStep*3))*(innerRadius/Math.cos(qtrStep));
			cy = y-Math.sin(start+(step*n)-(qtrStep*3))*(innerRadius/Math.cos(qtrStep));
			dx = x+Math.cos(start+(step*n)-halfStep)*innerRadius;
			dy = y-Math.sin(start+(step*n)-halfStep)*innerRadius;
			this.curveTo(cx, cy, dx, dy);
			cx = x+Math.cos(start+(step*n)-qtrStep)*(innerRadius/Math.cos(qtrStep));
			cy = y-Math.sin(start+(step*n)-qtrStep)*(innerRadius/Math.cos(qtrStep));
			dx = x+Math.cos(start+(step*n))*outerRadius;
			dy = y-Math.sin(start+(step*n))*outerRadius;
			this.curveTo(cx, cy, dx, dy);
		}
	}
};

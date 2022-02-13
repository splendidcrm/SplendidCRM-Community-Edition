var onchangefired=false; 

function KeySortDropDownList_onkeypress(dropdownlist, caseSensitive)
{
	// check the keypressBuffer attribute is defined on the dropdownlist
	var undefined;
	if (dropdownlist.keypressBuffer == undefined)
	{
		dropdownlist.keypressBuffer = '';
	}

	// get the key that was pressed 
	if (window.event.keyCode == 13||window.event.keyCode == 9)
	{
		// 10/16/2015 Paul.  fireEvent is not supported in IE 11. 
		if ( document.createEvent )
		{
			var evt = document.createEvent('HTMLEvents');
			evt.initEvent('change', true, false);
			dropdownlist.dispatchEvent(evt);
		}
		else if ( dropdownlist.fireEvent )
		{
			dropdownlist.fireEvent('onChange');
		}
	}

	var key = String.fromCharCode(window.event.keyCode);
	dropdownlist.keypressBuffer += key;
	if (!caseSensitive)
	{
		// convert buffer to lowercase
		dropdownlist.keypressBuffer = dropdownlist.keypressBuffer.toLowerCase();
	}
	// find if it is the start of any of the options 
	var optionsLength = dropdownlist.options.length;
	for (var n=0; n < optionsLength; n++)
	{
		var optionText = dropdownlist.options[n].text;
		if (!caseSensitive)
		{
			optionText = optionText.toLowerCase();
		}
		if (optionText.indexOf(dropdownlist.keypressBuffer,0) == 0)
		{
			dropdownlist.selectedIndex = n;
			return false; // cancel the default behavior since 
						// we have selected our own value 
		}
	}
	// reset initial key to be inline with default behavior 
	dropdownlist.keypressBuffer = key;
	return true; // give default behavior 
}


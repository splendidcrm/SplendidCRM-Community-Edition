var sDebugSQL = '';
// 02/29/2008 Paul.  startHighlight is no longer used, so remove. 

// 05/08/2010 Paul.  Create rootURL javascript variable for use by the CalendarPopup. 
// This will allow us to remove the CalendarPopup definitions in the Admin area. 
var ChangeDate = null;
function CalendarPopup(ctlDate, clientX, clientY)
{
	clientX = window.screenLeft + parseInt(clientX);
	clientY = window.screenTop  + parseInt(clientY);
	if ( clientX < 0 )
		clientX = 0;
	if ( clientY < 0 )
		clientY = 0;
	// 09/02/2018 Paul.  If popup is off the screen, shift left. 
	if ( clientX + 250 > screen.width )
		clientX = screen.width - 250;
	// 09/07/2013 Paul.  Change rootURL to sREMOTE_SERVER to match Survey module. 
	return window.open(sREMOTE_SERVER + 'Calendar/Popup.aspx?Date=' + ctlDate.value,'CalendarPopup','width=193,height=155,resizable=1,scrollbars=0,left=' + clientX + ',top=' + clientY);
}

// 03/04/2009 Paul.  In JavaScript, we need to check for undefined instead of null. 
function SelectOption(sID, sValue)
{
	var lst = document.forms[0][sID];
	if ( lst != undefined )
	{
		if ( lst.options != undefined )
		{
			for ( i=0; i < lst.options.length ; i++ )
			{
				if ( lst.options[i].value == sValue )
				{
					lst.options[i].selected = true;
					break;
				}
			}
		}
	}
}

// 03/04/2009 Paul.  In JavaScript, we need to check for undefined instead of null. 
// 03/04/2009 Paul.  If there is only one form field, then it will not have a length. 
function SelectedCount(sFieldID)
{
	var nCount = 0;
	var fld = document.forms[0][sFieldID];
	if ( fld != undefined )
	{
		if ( fld.length == undefined )
		{
			if ( fld.type == 'checkbox' )
			{
				if ( fld.checked )
					nCount++;
			}
		}
		else
		{
			for (i = 0; i < fld.length; i++)
			{
				if ( fld[i].type == 'checkbox' )
				{
					if ( fld[i].checked )
						nCount++;
				}
			}
		}
	}
	return nCount;
}

// 02/28/2008 Paul.  Replace the SugarCRM implementation with one that is more efficient. 
// There is simply no need to iterate through all elements. 
// 03/04/2009 Paul.  In JavaScript, we need to check for undefined instead of null. 
// 03/04/2009 Paul.  If there is only one form field, then it will not have a length. 
function checkAll(form, sFieldID, value)
{
	var fld = document.forms[0][sFieldID];
	if ( fld != undefined )
	{
		if ( fld.length == undefined )
		{
			if ( fld.type == 'checkbox' )
				fld.checked = value;
		}
		else
		{
			for (i = 0; i < fld.length; i++)
			{
				if ( fld[i].type == 'checkbox' )
					fld[i].checked = value;
			}
		}
	}
}

// 02/28/2008 Paul.  Simplify toggleDisplay() and move the linked toggling to AccessView. 
function toggleDisplay(sID)
{
	var fld = document.getElementById(sID);
	if ( fld != undefined )
		fld.style.display = (fld.style.display == 'none') ? 'inline' : 'none';
}

// 05/06/2010 Paul.  Move the email scripts here so that they can be outside of the UpdatePanel. 
var sChangeContactEmailADDRS        = null;
var sChangeContactEmailADDRS_IDS    = null;
var sChangeContactEmailADDRS_NAMES  = null;
var sChangeContactEmailADDRS_EMAILS = null;

function ChangeContactEmail(sCONTACT_ID, sCONTACT_NAME, sCONTACT_EMAIL)
{
	var txtADDRS        = document.getElementById(sChangeContactEmailADDRS       );
	var txtADDRS_IDS    = document.getElementById(sChangeContactEmailADDRS_IDS   );
	var txtADDRS_NAMES  = document.getElementById(sChangeContactEmailADDRS_NAMES );
	var txtADDRS_EMAILS = document.getElementById(sChangeContactEmailADDRS_EMAILS);
	if ( sCONTACT_ID == '' )
	{
		if ( txtADDRS        != null ) txtADDRS       .value = '';
		if ( txtADDRS_IDS    != null ) txtADDRS_IDS   .value = '';
		if ( txtADDRS_NAMES  != null ) txtADDRS_NAMES .value = '';
		if ( txtADDRS_EMAILS != null ) txtADDRS_EMAILS.value = '';
	}
	else
	{
		if ( txtADDRS        != null && txtADDRS       .value.length > 0 ) txtADDRS       .value += ';';
		if ( txtADDRS_IDS    != null && txtADDRS_IDS   .value.length > 0 ) txtADDRS_IDS   .value += ';';
		if ( txtADDRS_NAMES  != null && txtADDRS_NAMES .value.length > 0 ) txtADDRS_NAMES .value += ';';
		if ( txtADDRS_EMAILS != null && txtADDRS_EMAILS.value.length > 0 ) txtADDRS_EMAILS.value += ';';
		if ( txtADDRS        != null ) txtADDRS       .value += sCONTACT_NAME + ' <' + sCONTACT_EMAIL + '>';
		if ( txtADDRS_IDS    != null ) txtADDRS_IDS   .value += sCONTACT_ID   ;
		if ( txtADDRS_NAMES  != null ) txtADDRS_NAMES .value += sCONTACT_NAME ;
		if ( txtADDRS_EMAILS != null ) txtADDRS_EMAILS.value += sCONTACT_EMAIL;
	}
}

// 09/22/2013 Paul.  Add support for SMS Messages. 
var sChangeContactSmsNUMBER    = null;
var sChangeContactSmsNUMBER_ID = null;

function ChangeContactSmsNumber(sCONTACT_ID, sCONTACT_NUMBER)
{
	if ( sCONTACT_ID == '' )
		sCONTACT_NUMBER = sCONTACT_ID;
	
	var txtTO_NUMBER    = document.getElementById(sChangeContactSmsNUMBER   );
	var txtTO_NUMBER_ID = document.getElementById(sChangeContactSmsNUMBER_ID);
	if ( txtTO_NUMBER    != null ) txtTO_NUMBER    .value = sCONTACT_NUMBER;
	if ( txtTO_NUMBER_ID != null ) txtTO_NUMBER_ID .value = sCONTACT_ID    ;
}

function AddFile(sParentID, sRemoveID, sAttachmentCountID)
{
	try
	{
		var fldRemove          = document.getElementById(sRemoveID);
		var fldAttachmentCount = document.getElementById(sAttachmentCountID);
		var nAttachmentCount   = parseInt(fldAttachmentCount.value);
		nAttachmentCount++;
		fldAttachmentCount.value = nAttachmentCount;
		
		var attachments_div = document.getElementById(sParentID + '_attachments_div');
		if ( attachments_div != null )
		{
			var fileAttachment = document.createElement('input');
			fileAttachment.setAttribute('type' , 'file'  );
			fileAttachment.setAttribute('size' , '40'    );
			fileAttachment.setAttribute('id'   , sParentID + '_attachment' + nAttachmentCount);
			fileAttachment.setAttribute('name' , sParentID + '_attachment' + nAttachmentCount);
			attachments_div.appendChild(fileAttachment);

			var nbsp = document.createTextNode('\u00A0');
			attachments_div.appendChild( nbsp );

			var btnRemove = document.createElement('input');
			btnRemove.setAttribute('id'     , sParentID + '_remove_attachment' + nAttachmentCount);
			btnRemove.setAttribute('type'   , 'button');
			btnRemove.className = 'button';
			btnRemove.onclick   = Function('DeleteFile("' + sParentID + '", "' + sRemoveID + '", "' + sAttachmentCountID + '", ' + nAttachmentCount + ');');
			btnRemove.setAttribute('value'  , fldRemove.value);
			attachments_div.appendChild(btnRemove);

			var br = document.createElement('br');
			attachments_div.appendChild(br);
		}
		else
		{
			alert(sParentID + '_attachments_div' + ' is not defined.');
		}
	}
	catch(e)
	{
		alert('AddFile: ' + e.message);
	}
}

function DeleteFile(sParentID, sRemoveID, sAttachmentCountID, index)
{
	try
	{
		var attachment        = document.getElementById(sParentID + '_attachment' + index);
		var remove_attachment = document.getElementById(sParentID + '_remove_attachment' + index);
		if ( attachment != null )
		{
			var nbsp = attachment.nextSibling;
			if ( nbsp != null )
			{
				nbsp.parentNode.removeChild(nbsp);
			}
			attachment.parentNode.removeChild(attachment);
		}
		if ( remove_attachment != null )
		{
			var br = remove_attachment.nextSibling;
			if ( br != null )
			{
				br.parentNode.removeChild(br);
			}
			remove_attachment.parentNode.removeChild(remove_attachment);
		}
		var attachments_div = document.getElementById(sParentID + '_attachments_div');
		//if ( attachments_div.childNodes.length == 0 )
		//	AddFile(sParentID, sRemoveID, sAttachmentCountID);
	}
	catch(e)
	{
		alert('DeleteFile: ' + e.message);
	}
}

// 05/08/2010 Paul.  Move onkeypress to SplendidCRM.js. 
// 11/14/2005 Paul.  Trap the ENTER key at the document level so that the default action can be cancelled. 
// Use Utils.RegisterEnterKeyPress() to enable the ENTER key in any simulated sub-form. 
document.onkeypress = function()
{
	if ( (event.which ? event.which : event.keyCode) == 13 )
	{
		// 11/15/2005 Paul.  We need to allow the ENTER key for multi-line edit controls. 
		if ( event.srcElement.type == 'textarea' )
		{
			if ( event.srcElement.rows > 1 )
				return;
			// 11/19/2005 Paul.  The ENTER key should work on buttons and images, so only block if on a textbox. 
			event.returnValue = false;
			event.cancel = true;
		}
	}
}

// 01/28/2011 Paul.  Simple dumpObj from http://geekswithblogs.net/svanvliet/archive/2006/03/23/simple-javascript-object-dump-function.aspx
var MAX_DUMP_DEPTH = 10;
function dumpObj(obj, name, indent, depth)
{
	if ( typeof(indent) == 'undefined' )
		indent = '';
	if ( typeof(name) == 'undefined' )
		name = '';
	if ( typeof(depth) == 'undefined' )
		depth  = 0;

	if ( depth > MAX_DUMP_DEPTH )
	{
		return indent + name + ': <Maximum Depth Reached>\n';
	}
	if ( typeof(obj) == 'object' )
	{
		var child = null;
		var output = indent + name;
		var total = 0;
		if ( obj instanceof Array )
		{
			if ( obj.length == 0 )
			{
				for ( var item in obj )
					total++;
			}
			else
			{
				total = obj.length;
			}
			output += ' (Array)\n';
		}
		else
		{
			for ( var item in obj )
			{
				total++;
			}
			output += ' (Object)\n';
		}
		output += indent + 'Total item: ' + total + '\n';
		indent += '\t';
		if ( obj instanceof Array )
		{
			// 02/06/2011 Paul.  An associative array will not have a length. 
			if ( obj.length == 0 )
			{
				for ( var item in obj )
				{
					child = obj[item];
					output += dumpObj(child, item, indent, depth + 1);
				}
			}
			else
			{
				for ( var i = 0; i < obj.length; i++ )
				{
					child = obj[i];
					output += dumpObj(child, i, indent, depth + 1);
				}
			}
		}
		else
		{
			try
			{
				for ( var item in obj )
				{
					try
					{
						child = obj[item];
					}
					catch(e)
					{
						child = '<Unable to Evaluate>';
					}
					if ( typeof(child) == 'object' )
					{
						output += dumpObj(child, item, indent, depth + 1);
					}
					else
					{
						output += indent + item + ': ' + child + '\n';
					}
				}
			}
			catch(e)
			{
				child = '<Unable to Evaluate>';
				output += indent + name + ': ' + child + '\n';
			}
		}
		return output;
	}
	else
	{
		return obj + ' is not an object.';
	}
}

function Right(str, n)
{
	if ( n <= 0 )
		return '';
	else if ( n > String(str).length )
		return str;
	else
	{
		var iLen = String(str).length;
		return String(str).substring(iLen, iLen - n);
	}
}

// 02/27/2012 Paul.  ShowSubPanel is used in ListHeader to Collapse sub-panel. 
function ShowSubPanel(sShowSubPanel, sHideSubPanel, sSubPanel, sSubPanelFrame)
{
	var lnkShowSubPanel = document.getElementById(sShowSubPanel);
	var lnkHideSubPanel = document.getElementById(sHideSubPanel);
	var divSubPanel     = document.getElementById(sSubPanel);
	// 01/21/2017 Paul.  Panels may not exist. 
	if ( lnkShowSubPanel  != null ) lnkShowSubPanel.style.display = 'none';
	if ( lnkHideSubPanel  != null ) lnkHideSubPanel.style.display = 'inline';
	if ( divSubPanel      != null ) divSubPanel.style.display     = 'inline';
	if ( divSubPanel      != null ) deleteCookie(sSubPanel);
	// 05/25/2015 Paul.  New code for Seven theme requires that we manually hide the buttons. 
	var divSubPanelButtons = document.getElementById(sSubPanel + 'Buttons');
	if ( divSubPanelButtons != null )
		divSubPanelButtons.style.display = 'inline';
	// 05/27/2015 Paul.  New code for Seven theme requires that we manually hide the buttons. 
	var divSubPanelFrame = document.getElementById(sSubPanelFrame);
	if ( divSubPanelFrame != null )
		divSubPanelFrame.className = 'h3Row';
}
function HideSubPanel(sShowSubPanel, sHideSubPanel, sSubPanel, sSubPanelFrame, days)
{
	// 12/25/2012 Paul.  The Reminders popdown is only remembered for 1 day. 
	if ( days === undefined )
		days = 180;
	var lnkShowSubPanel = document.getElementById(sShowSubPanel);
	var lnkHideSubPanel = document.getElementById(sHideSubPanel);
	var divSubPanel     = document.getElementById(sSubPanel);
	// 01/21/2017 Paul.  Panels may not exist. 
	if ( lnkShowSubPanel  != null ) lnkShowSubPanel.style.display = 'inline';
	if ( lnkHideSubPanel  != null ) lnkHideSubPanel.style.display = 'none';
	if ( divSubPanel      != null ) divSubPanel.style.display     = 'none';
	if ( divSubPanel      != null ) setCookie(sSubPanel, 1, days);
	// 05/25/2015 Paul.  New code for Seven theme requires that we manually hide the buttons. 
	var divSubPanelButtons = document.getElementById(sSubPanel + 'Buttons');
	if ( divSubPanelButtons != null )
		divSubPanelButtons.style.display = 'none';
	// 05/27/2015 Paul.  New code for Seven theme requires that we manually hide the buttons. 
	var divSubPanelFrame = document.getElementById(sSubPanelFrame);
	if ( divSubPanelFrame != null )
		divSubPanelFrame.className = 'h3Row h3RowDisabled';
}

// 08/31/2012 Paul.  Apple and Android devices should support speech and handwriting. 
// Speech does not work on text areas, only add to single line text boxes. 
function SpeechTranscribe(sSpeechID, sFieldID)
{
	var txtSpeechID = document.getElementById(sSpeechID);
	var txtFieldID  = document.getElementById(sFieldID );
	try
	{
		txtFieldID.value += txtSpeechID.value + ' ';
		txtSpeechID.value = '';
		txtFieldID.focus();
	}
	catch(e)
	{
	}
}

// 03/07/2013 Paul. Add ALL_DAY_EVENT. 
function ToggleAllDayEvent(chk)
{
	var sBaseID = chk.id.replace('ALL_DAY_EVENT', '');
	var lstHOUR             = document.getElementById(sBaseID + 'DATE_START_lstHOUR'    );
	var lstMINUTE           = document.getElementById(sBaseID + 'DATE_START_lstMINUTE'  );
	var lstMERIDIEM         = document.getElementById(sBaseID + 'DATE_START_lstMERIDIEM');
	var fldDURATION_HOURS   = document.getElementById(sBaseID + 'DURATION_HOURS'        );
	var fldDURATION_MINUTES = document.getElementById(sBaseID + 'DURATION_MINUTES'      );
	if ( chk.checked )
	{
		if ( lstHOUR             != null ) lstHOUR            .selectedIndex = 0;
		if ( lstMINUTE           != null ) lstMINUTE          .selectedIndex = 0;
		if ( lstMERIDIEM         != null ) lstMERIDIEM        .selectedIndex = 0;
		if ( fldDURATION_MINUTES != null ) fldDURATION_MINUTES.selectedIndex = 0;
		if ( fldDURATION_HOURS   != null ) fldDURATION_HOURS  .value = 24;
	}
}

function getUrlParam(paramName)
{
	var reParam = new RegExp('(?:[\?&]|&amp;)' + paramName + '=([^&]+)', 'i') ;
	var match = window.location.search.toLowerCase().match(reParam) ;

	return (match && match.length > 1) ? match[1] : '' ;
}

function SelectAddOption(sID, sValue)
{
	var lst = document.forms[0][sID];
	if ( lst != undefined )
	{
		if ( lst.options != undefined )
		{
			var bFound = false;
			for ( i=0; i < lst.options.length ; i++ )
			{
				if ( lst.options[i].value == sValue )
				{
					lst.options[i].selected = true;
					bFound = true;
					break;
				}
			}
			if ( !bFound )
			{
				var opt = document.createElement('option');
				opt.value = sValue;
				opt.innerHTML = sValue;
				lst.appendChild(opt);
				opt.selected = true;
			}
		}
	}
}

// 09/15/2013 Paul.  Create CreateClickToCall stub to prevent an error if called when Asterisk is not registered. 
function CreateClickToCall()
{
}


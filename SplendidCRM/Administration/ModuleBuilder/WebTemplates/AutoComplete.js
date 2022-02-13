
function $tablename$_$tablenamesingular$_$firsttextfield$_Changed(fld$tablenamesingular$_$firsttextfield$)
{
	// 02/04/2007 Paul.  We need to have an easy way to locate the correct text fields, 
	// so use the current field to determine the label prefix and send that in the userContact field. 
	// 08/24/2009 Paul.  One of the base controls can contain $firsttextfield$ in the text, so just get the length minus 4. 
	var userContext = fld$tablenamesingular$_$firsttextfield$.id.substring(0, fld$tablenamesingular$_$firsttextfield$.id.length - '$tablenamesingular$_$firsttextfield$'.length)
	var fldAjaxErrors = document.getElementById(userContext + '$tablenamesingular$_$firsttextfield$_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '';
	
	var fldPREV_$tablenamesingular$_$firsttextfield$ = document.getElementById(userContext + 'PREV_$tablenamesingular$_$firsttextfield$');
	if ( fldPREV_$tablenamesingular$_$firsttextfield$ == null )
	{
		//alert('Could not find ' + userContext + 'PREV_$tablenamesingular$_$firsttextfield$');
	}
	else if ( fldPREV_$tablenamesingular$_$firsttextfield$.value != fld$tablenamesingular$_$firsttextfield$.value )
	{
		if ( fld$tablenamesingular$_$firsttextfield$.value.length > 0 )
		{
			try
			{
				SplendidCRM.$modulename$.AutoComplete.$tablename$_$tablenamesingular$_$firsttextfield$_Get(fld$tablenamesingular$_$firsttextfield$.value, $tablename$_$tablenamesingular$_$firsttextfield$_Changed_OnSucceededWithContext, $tablename$_$tablenamesingular$_$firsttextfield$_Changed_OnFailed, userContext);
			}
			catch(e)
			{
				alert('$tablename$_$tablenamesingular$_$firsttextfield$_Changed: ' + e.Message);
			}
		}
		else
		{
			var result = { 'ID' : '', 'NAME' : '' };
			$tablename$_$tablenamesingular$_$firsttextfield$_Changed_OnSucceededWithContext(result, userContext, null);
		}
	}
}

function $tablename$_$tablenamesingular$_$firsttextfield$_Changed_OnSucceededWithContext(result, userContext, methodName)
{
	if ( result != null )
	{
		var sID   = result.ID  ;
		var s$firsttextfield$ = result.$firsttextfield$;
		
		var fldAjaxErrors        = document.getElementById(userContext + '$tablenamesingular$_$firsttextfield$_AjaxErrors');
		var fld$tablenamesingular$_ID        = document.getElementById(userContext + '$tablenamesingular$_ID'       );
		var fld$tablenamesingular$_$firsttextfield$      = document.getElementById(userContext + '$tablenamesingular$_$firsttextfield$'     );
		var fldPREV_$tablenamesingular$_$firsttextfield$ = document.getElementById(userContext + 'PREV_$tablenamesingular$_$firsttextfield$');
		if ( fld$tablenamesingular$_ID        != null ) fld$tablenamesingular$_ID.value        = sID  ;
		if ( fld$tablenamesingular$_$firsttextfield$      != null ) fld$tablenamesingular$_$firsttextfield$.value      = s$firsttextfield$;
		if ( fldPREV_$tablenamesingular$_$firsttextfield$ != null ) fldPREV_$tablenamesingular$_$firsttextfield$.value = s$firsttextfield$;
	}
	else
	{
		alert('result from $modulename$.AutoComplete service is null');
	}
}

function $tablename$_$tablenamesingular$_$firsttextfield$_Changed_OnFailed(error, userContext)
{
	// Display the error.
	var fldAjaxErrors = document.getElementById(userContext + '$tablenamesingular$_$firsttextfield$_AjaxErrors');
	if ( fldAjaxErrors != null )
		fldAjaxErrors.innerHTML = '<br />' + error.get_message();

	var fld$tablenamesingular$_ID        = document.getElementById(userContext + '$tablenamesingular$_ID'       );
	var fld$tablenamesingular$_$firsttextfield$      = document.getElementById(userContext + '$tablenamesingular$_$firsttextfield$'     );
	var fldPREV_$tablenamesingular$_$firsttextfield$ = document.getElementById(userContext + 'PREV_$tablenamesingular$_$firsttextfield$');
	if ( fld$tablenamesingular$_ID        != null ) fld$tablenamesingular$_ID.value        = '';
	if ( fld$tablenamesingular$_$firsttextfield$      != null ) fld$tablenamesingular$_$firsttextfield$.value      = '';
	if ( fldPREV_$tablenamesingular$_$firsttextfield$ != null ) fldPREV_$tablenamesingular$_$firsttextfield$.value = '';
}

if ( typeof(Sys) !== 'undefined' )
	Sys.Application.notifyScriptLoaded();


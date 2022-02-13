// 06/02/2010 Paul.  Change to the wait cursor while an UpdatePanel request is being processed. 
// http://codedump.blergh.be/2008/01/18/wait-cursor-for-aspnet-ajax-actions/
var prm = Sys.WebForms.PageRequestManager.getInstance();
prm.add_initializeRequest(InitializeRequest);
prm.add_endRequest(EndRequest);

function InitializeRequest(sender, args)
{
	document.body.style.cursor = 'wait';
	if ( document.getElementById('UpdatePanelProgressDiv') != null )
	{
		$get('UpdatePanelProgressDiv').style.display = 'inline';
	}
}

function EndRequest(sender, args)
{
	document.body.style.cursor = 'default';
	if ( document.getElementById('UpdatePanelProgressDiv') != null )
	{
		$get('UpdatePanelProgressDiv').style.display = 'none';
	}
}

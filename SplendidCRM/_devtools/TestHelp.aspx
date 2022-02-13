<%@ Page language="c#" Codebehind="TestHelp.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM._devtools.TestHelp" %>
<head visible="false" runat="server" />
<html>
<head>
	<title>Test Help</title>
	<script type="text/javascript" src="<%= Application["scriptURL"] %>SplendidCRM.js"></script>
<style type="text/css">
.error
{
	color: #ff0000;
}
</style>
<script type="text/javascript">
var nLastItem = -1;
var bContinueTest = true;
var arrHelpScripts = new Array();
var nPendingAttempts = 0;
var nTimeoutAttempts = 0;
var sApplicationSiteURL = location.protocol + '//' + location.host + '<%= Application["rootURL"] %>';

function OpenerLoaded()
{
	var lstFiles      = document.getElementById('<%= lstFiles.ClientID   %>');
	var lblStatus     = document.getElementById('<%= lblStatus.ClientID  %>');
	var divTestOutput = document.getElementById('divTestOutput');
	var now = new Date();
	lblStatus.innerHTML = 'Done ' + lstFiles.options[nLastItem].value;
	lblStatus.innerHTML += '<br />' + arrHelpScripts[lblCurrent.innerHTML].SetAllFields;
	try
	{
		nPendingAttempts = 0;
		arrPendingFields = new Array();
		eval(arrHelpScripts[lblCurrent.innerHTML].SetAllFields);
		if ( arrPendingFields.length == 0 )
		{
			try
			{
				eval(arrHelpScripts[lblCurrent.innerHTML].SubmitFields);
				opener.onload
				{
					nLastItem++;
					lstFiles.options[nLastItem].selected = true;
					StartTest();
				}
			}
			catch(e)
			{
				lblStatus.innerHTML = 'SubmitFields error: ' + e.message;
			}
		}
		else
		{
			VerifyPendingFields();
		}
	}
	catch(e)
	{
		lblStatus.innerHTML = 'OpenerLoaded error: ' + e.message;
		divTestOutput.innerHTML = dumpObj(arrHelpScripts[lblCurrent.innerHTML]);
	}
}

function VerifyPendingFields()
{
	var lstFiles      = document.getElementById('<%= lstFiles.ClientID   %>');
	var lblCurrent    = document.getElementById('<%= lblCurrent.ClientID %>');
	var lblStatus     = document.getElementById('<%= lblStatus.ClientID  %>');
	var divTestOutput = document.getElementById('divTestOutput');
	try
	{
		var nVerifiedCount = 0;
		var sFailedPendingFields = '';
		for ( var i = 0; i < arrPendingFields.length; i++ )
		{
			var sValue = HelpGetValue(arrPendingFields[i].Module, arrPendingFields[i].LayoutView, arrPendingFields[i].Name);
			if ( sValue != null && sValue.length > 0 )
			{
				nVerifiedCount++;
			}
			else
			{
				if ( sFailedPendingFields.length > 0 )
					sFailedPendingFields += '; ' + arrPendingFields[i].Name;
				else
					sFailedPendingFields += arrPendingFields[i].Name;
			}
		}
		if ( nVerifiedCount < arrPendingFields.length )
		{
			nPendingAttempts++;
			if ( nPendingAttempts < 5 && bContinueTest )
			{
				lblStatus.innerHTML = 'Pending Attempt ' + nPendingAttempts + ' ' + sFailedPendingFields;
				setTimeout(VerifyPendingFields, 1000);
			}
			else
			{
				var now = new Date();
				var lblStatus  = document.getElementById('<%= lblStatus.ClientID  %>');
				lblStatus.innerHTML = 'Failed Pending ' + sFailedPendingFields;
				divTestOutput.innerHTML = '<pre>' + dumpObj(arrHelpScripts[lblCurrent.innerHTML]) + '</pre>';
				divTestOutput.innerHTML += '<pre>' + eval(arrHelpScripts[lblCurrent.innerHTML].SetAllFields.replace('();', '')) + '</pre>';
			}
		}
		else
		{
			eval(arrHelpScripts[lblCurrent.innerHTML].SubmitFields);
			opener.onload
			{
				nLastItem++;
				lstFiles.options[nLastItem].selected = true;
				StartTest();
			}
		}
	}
	catch(e)
	{
		lblStatus.innerHTML = 'VerifyPendingFields error: ' + e.message;
	}
}

function VerifyModule()
{
	var lstFiles   = document.getElementById('<%= lstFiles.ClientID   %>');
	var lblCurrent = document.getElementById('<%= lblCurrent.ClientID %>');
	var lblStatus  = document.getElementById('<%= lblStatus.ClientID  %>');
	var sModule = lblCurrent.innerHTML.split('.')[0];
	var lnkModule = opener.document.getElementById('divModuleHeader' + sModule);
	if ( lnkModule == null )
	{
		nTimeoutAttempts++;
		if ( nTimeoutAttempts < 15 && bContinueTest )
		{
			lblStatus.innerHTML = 'Attempt ' + nTimeoutAttempts;
			setTimeout(VerifyModule, 1000);
		}
		else
		{
			var now = new Date();
			var lblStatus  = document.getElementById('<%= lblStatus.ClientID  %>');
			lblStatus.innerHTML = 'Failed Module ' + lstFiles.options[nLastItem].value;
		}
	}
	else
	{
		OpenerLoaded();
	}
}

function StartTest()
{
	var lstFiles   = document.getElementById('<%= lstFiles.ClientID   %>');
	var lblCurrent = document.getElementById('<%= lblCurrent.ClientID %>');
	var lblStatus  = document.getElementById('<%= lblStatus.ClientID  %>');
	var divTestOutput = document.getElementById('divTestOutput');
	if ( bContinueTest && nLastItem < lstFiles.options.length )
	{
		lblCurrent.innerHTML = lstFiles.options[nLastItem].value;
		try
		{
			var sPath = arrHelpScripts[lblCurrent.innerHTML].RelativePath;
			sPath = sPath.replace('~/', sApplicationSiteURL);
			lblStatus.innerHTML = sPath;
			opener.window.location.href = sPath;
		}
		catch(e)
		{
			lblStatus.innerHTML = 'StartTest error: ' + e.message;
		}
		opener.onload
		{
			nTimeoutAttempts = 0;
			setTimeout(VerifyModule, 1000);
		}
	}
	else if ( !bContinueTest )
	{
		lblStatus.innerHTML += '; Compile stopped';
	}
	else if ( nLastItem >= lstFiles.options.length )
	{
		lblStatus.innerHTML += '; End of list';
	}
}

function StopTest()
{
	bContinueTest = false;
}

function ContinueTest()
{
	if ( typeof(opener) == 'undefined' )
	{
		alert('opener is not defined');
		return;
	}
	bContinueTest = true;
	var lstFiles = document.getElementById('<%= lstFiles.ClientID %>');
	nLastItem = lstFiles.selectedIndex + 1;
	if ( nLastItem < lstFiles.options.length )
	{
		lstFiles.options[nLastItem].selected = true;
		StartTest();
	}
}
</script>

<%= Application["CONFIG.help_scripts"] %>
<%= sbHelpScripts.ToString() %>
</head>
<body style="margin: 0px 0px 0px 0px;">
<form runat="server">
<table width="100%" height="100%" border="1" cellpadding="0" cellspacing="0">
	<tr>
		<td width="20%" valign="top">
			<asp:Label ID="lblCurrent" runat="server" /><br />
			<asp:Label ID="lblStatus"  runat="server" /><br />
			<a id="lnkTest" href="" target="Test"></a><br />
			<button onclick='StopTest();'>Cancel</button>
			<button onclick='ContinueTest();'>Continue</button><br />
			<asp:ListBox ID="lstFiles" DataTextField="NAME" DataValueField="NAME" SelectionMode="Single" Width="200px" Height="600px" runat="server" />
			<asp:Label ID="lblErrors"  runat="server" /><br />
		</td>
		<td valign="top">
			<div id="divTestOutput" />
			<asp:DataGrid ID="grdMain" AutoGenerateColumns="true" runat="server" />
		</td>
	</tr>
</table>
</form>
</body>
</html>

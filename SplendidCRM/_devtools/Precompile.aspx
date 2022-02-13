<%@ Page language="c#" Codebehind="Precompile.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM._devtools.Precompile" %>
<!DOCTYPE html>
<head visible="false" runat="server" />
<html>
<head>
	<title>Precompile</title>
<style type="text/css">
.error
{
	color: #ff0000;
}
</style>
	<script type="text/javascript" src="../Include/javascript/jquery-1.9.1.min.js"></script>
</head>
<body style="margin: 0px 0px 0px 0px;">
<form runat="server">
<table id="tblLayoutFrame" width="100%" height="100%" border="1" cellpadding="0" cellspacing="0">
	<tr>
		<td width="10%" valign="top">
			<asp:Label ID="lblRoot"    runat="server" /><br />
			<asp:Label ID="lblCurrent" runat="server" /><br />
			<asp:Label ID="lblStatus"  runat="server" /><br />
			<a id="lnkTest" href="" target="PrecompileTest"></a><br />
			<button onclick='StopPrecompile(); return false;'>Cancel</button>
			<button onclick='ContinuePrecompile(); return false;'>Continue</button><br />
			<asp:ListBox ID="lstFiles" DataTextField="NAME" DataValueField="NAME" SelectionMode="Single" Width="200px" Height="600px" runat="server" />
			<asp:Label ID="lblErrors"  runat="server" /><br />
		</td>
		<td valign="top">
			<div id="divPrecompileOutput">
				<asp:Repeater ID="rptLinks" Visible="false" runat="server">
					<ItemTemplate>
						<asp:HyperLink NavigateUrl='<%# lblRoot.Text + Sql.ToString(Eval("NAME")) %>' Text='<%# Eval("NAME") %>' Target="_default" runat="server" /><br />
					</ItemTemplate>
				</asp:Repeater>
			</div>
		</td>
	</tr>
</table>
<script type="text/javascript">
function RequestObject()
{
	var req = null;
	if ( window.XMLHttpRequest && !(window.ActiveXObject) )
	{
		// branch for native XMLHttpRequest object
		try
		{
			req = new XMLHttpRequest();
		}
		catch(e)
		{
			req = null;
		}
	}
	else if ( window.ActiveXObject )
	{
		// branch for IE/Windows ActiveX version
		try
		{
			req = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch(e)
		{
			try
			{
				req = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch(e)
			{
				req = null;
			}
		}
	}
	return req;
}

var lblStatus = document.getElementById('<%= lblStatus.ClientID %>');
var lnkTest   = document.getElementById('lnkTest');
var divPrecompileOutput = document.getElementById('divPrecompileOutput');
var sRandom = Math.random().toString();

function loadXMLDoc(url)
{
	var req = RequestObject();
	if ( req != null )
	{
		req.onreadystatechange = function()
		{
			try
			{
				//lblStatus.innerHTML = req.readyState;
				/*	readyState
					0 = uninitialized
					1 = loading
					2 = loaded
					3 = interactive
					4 = complete
				*/
				// only if req shows "loaded"
				switch ( req.readyState )
				{
					case 0:  lblStatus.innerHTML = 'uninitialized';  break;
					case 1:  lblStatus.innerHTML = 'loading'      ;  break;
					case 2:  lblStatus.innerHTML = 'loaded'       ;  break;
					case 3:  lblStatus.innerHTML = 'interactive'  ;  break;
					case 4:  lblStatus.innerHTML = 'complete'     ;  break;
				}
				if ( req.readyState == 4 )
				{
					// only if "OK"
					if ( req.status == 200 )
					{
						//  class="error"></span>
						// 05/09/2008 Paul.  The SystemLog page may contain errors, so try to locate the error label better. 
						var sErrorLabel = "lblError\" class=\"error\">";
						var nErrorStart = req.responseText.indexOf(sErrorLabel);
						var nErrorEnd   = 0;
						while ( nErrorStart >= 0 )
						{
							if ( req.responseText.substr(nErrorStart + sErrorLabel.length, 1) != '<' )
							{
								nErrorEnd = req.responseText.indexOf('</span>', nErrorStart + sErrorLabel.length);
								lblStatus.innerHTML = 'There was a problem: ' + req.responseText.substring(nErrorStart + sErrorLabel.length, nErrorEnd);
								lblStatus.className = 'error';
								lnkTest.href = url;
								lnkTest.innerHTML = url;

								divPrecompileOutput.innerHTML = req.responseText;
								// 10/29/2013 Paul.  -1 to exit the loop. 
								nErrorStart = -1;  // Exit the loop. 
							}
							else
								nErrorStart = req.responseText.indexOf(sErrorLabel, nErrorStart+1);
						}
						if ( nErrorEnd == 0 )
						{
							//divPrecompileOutput.innerHTML = req.responseText;
							divPrecompileOutput.innerHTML = url + ' successful';
							DoPrecompile();
						}
					}
					else
					{
						lblStatus.innerHTML = 'There was a problem: ' + req.statusText;
						lblStatus.className = 'error';
						lnkTest.href = url;
						lnkTest.innerHTML = url;
						//lnkTest.onclick = 'javascript:window.open(\'' + url + '\', \'_new\', \'addressbar=yes,menubar=yes,scrollbars=yes,resizable=yes,top=0,width=580\');';

						divPrecompileOutput.innerHTML = req.responseText;
					}
				}
			}
			catch(e)
			{
				lblStatus.innerHTML = e.message;
				lblStatus.className = 'error';
			}
		}
		// 08/31/2010 Paul.  This is the correct location to put the PrecomplieOnly flag. 
		// 08/31/2010 Paul.  This is the correct location, but adding PrecompileOnly causes the fetch to fail. 
		// 11/27/2013 Paul.  The new URLs may already have a parameter. 
		// 12/06/2018 Paul.  We are going to fix PrecompileOnly, so remove this code so that we can apply specifically. 
		if ( url.indexOf('?') > 0 )
			req.open("GET", url + '&' + sRandom + '&PrecompileOnly=1', true);
		else
			req.open("GET", url + '?' + sRandom + '&PrecompileOnly=1', true);
		req.send("");
	}
}

// 06/04/2015 Paul.  Provide a way to manually navigate. 
function getQuerystring(key, default_)
{
	if ( default_==null )
		default_ = '';
	key = key.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regex = new RegExp("[\\?&]"+key+"=([^&#]*)");
	var qs = regex.exec(window.location.href);
	if ( qs == null )
		return default_;
	else
		return qs[1];
}

var nLastItem = 0;
var bContinuePrecompile = (getQuerystring('links', '0') != '1');

function DoPrecompile()
{
	var lstFiles      = document.getElementById('<%= lstFiles.ClientID   %>');
	var lblRoot       = document.getElementById('<%= lblRoot.ClientID    %>');
	var lblCurrent    = document.getElementById('<%= lblCurrent.ClientID %>');
	var lblStatus     = document.getElementById('<%= lblStatus.ClientID  %>');
	var divScratchPad = document.getElementById('divScratchPad');
	if ( bContinuePrecompile && nLastItem < lstFiles.options.length )
	{
		lblCurrent.innerHTML = lstFiles.options[nLastItem].value.replace('/', '/ ');
		//divScratchPad.innerHTML = lblRoot.innerHTML + lblCurrent.innerHTML;
		lstFiles.options[nLastItem].selected = true;
		// 09/01/2013 Paul.  IE10 has some timing issues that requires that we update nLastItem before loading document. 
		var sURL = lblRoot.innerHTML + lstFiles.options[nLastItem].value;
		nLastItem++;
		loadXMLDoc(sURL);
	}
	else if ( !bContinuePrecompile )
	{
		lblStatus.innerHTML += '; Compile stopped';
	}
	else if ( nLastItem >= lstFiles.options.length )
	{
		lblStatus.innerHTML += '; End of list';
	}
}

function StopPrecompile()
{
	bContinuePrecompile = false;
}

function ContinuePrecompile()
{
	bContinuePrecompile = true;
	// 02/11/2009 Paul.  Allow resume to begin at desired location. 
	var lstFiles      = document.getElementById('<%= lstFiles.ClientID %>');
	nLastItem = lstFiles.selectedIndex + 1;
	if ( nLastItem < lstFiles.options.length )
		DoPrecompile();
}

function AdminLayoutResize()
{
	try
	{
		var tblLayoutFrame = document.getElementById('tblLayoutFrame');
		var rect = tblLayoutFrame.getBoundingClientRect();
		var nHeight = $(window).height() - rect.top;
		tblLayoutFrame.style.height = nHeight.toString() + 'px';
		
		var lstFiles  = document.getElementById('lstFiles' );
		rect = lstFiles.getBoundingClientRect();
		nHeight = $(window).height() - rect.top;
		lstFiles.style.height = (nHeight - 4) + 'px';
	}
	catch(e)
	{
		alert(e.message);
	}
}

window.onload = function()
{
	AdminLayoutResize();
	$(window).resize(AdminLayoutResize);
	DoPrecompile();
}
</script>
</form>
</body>
</html>

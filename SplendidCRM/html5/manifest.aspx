<%@ Page language="c#" Codebehind="manifest.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.html5.Manifest" %>
<head visible="false" runat="server" />CACHE MANIFEST
# <%= Application["SplendidVersion"] %> rev 631
NETWORK:
<%
foreach ( string sFile in lstNetworkFiles )
{
	Response.Write(sFile + ControlChars.CrLf);
}
%>
CACHE:
<%
foreach ( string sFile in lstCacheFiles )
{
	Response.Write(sFile + ControlChars.CrLf);
}
%>

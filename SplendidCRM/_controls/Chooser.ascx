<%@ Control Language="c#" AutoEventWireup="false" Codebehind="Chooser.ascx.cs" Inherits="SplendidCRM._controls.Chooser" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
<script runat="server">
/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
</script>
<script type="text/javascript">
function XmlEscape(s)
{
	s = s.replace('&', '&amp;');
	s = s.replace('<', '&lt;');
	s = s.replace('>', '&gt;');
	return s;
}

function CopyToHidden(sListID, sHiddenID)
{
	var lst = document.getElementById(sListID  );
	var txt = document.getElementById(sHiddenID);
	txt.value = '<xml>';
	for ( i=0; i < lst.options.length ; i++ )
	{
		txt.value += '<list><text>' + XmlEscape(lst.options[i].text) + '</text><value>' + XmlEscape(lst.options[i].value) + '</value></list>';
	}
	txt.value += '</xml>';
}

function MoveLeftToRight(sLeftID, sRightID, bReverse)
{
	var lstLeft  = document.getElementById(sLeftID );
	var lstRight = document.getElementById(sRightID);
	for ( i=0; i < lstLeft.options.length ; i++ )
	{
		if ( lstLeft.options[i].selected == true )
		{
			var oOption = document.createElement("OPTION");
			oOption.text  = lstLeft.options[i].text;
			oOption.value = lstLeft.options[i].value;
			lstRight.options.add(oOption);
		}
	}
	for ( i=lstLeft.options.length-1; i >= 0  ; i-- )
	{
		if ( lstLeft.options[i].selected == true )
		{
			// 10/11/2006 Paul.  Firefox does not support options.remove(), so just set the option to null. 
			lstLeft.options[i] = null;
		}
	}
	// 08/05/2005 Paul. Don't use the sLeftID & sRightID values as they can be reversed. 
	CopyToHidden('<%= lstLeft.ClientID  %>', '<%= txtLeft.ClientID  %>');
	CopyToHidden('<%= lstRight.ClientID %>', '<%= txtRight.ClientID %>');
}


function MoveUp(sID)
{
	var lst  = document.getElementById(sID);
	var sel = new Array();

	for ( i = 0; i < lst.options.length ; i++ )
	{
		if ( lst.options[i].selected == true )
			sel[sel.length] = i;
	}
	for (i in sel)
	{
		if ( sel[i] != 0 && !lst.options[sel[i]-1].selected )
		{
			var tmp = new Array(lst.options[sel[i]-1].text, lst.options[sel[i]-1].value);
			lst.options[sel[i]-1].text     = lst.options[sel[i]].text ;
			lst.options[sel[i]-1].value    = lst.options[sel[i]].value;
			lst.options[sel[i]  ].text     = tmp[0];
			lst.options[sel[i]  ].value    = tmp[1];
			lst.options[sel[i]-1].selected = true ;
			lst.options[sel[i]  ].selected = false;
		}
	}
	// 07/09/2006 Paul.  Update the hidden value as that is the real result that we process. 
	CopyToHidden('<%= lstLeft.ClientID  %>', '<%= txtLeft.ClientID  %>');
}


function MoveDown(sID)
{
	var lst  = document.getElementById(sID);
	var sel = new Array();
	for ( i = lst.options.length-1 ; i > -1 ; i-- )
	{
		if ( lst.options[i].selected == true )
			sel[sel.length] = i;
	}
	for (i in sel)
	{
		if ( sel[i] != lst.options.length-1 && !lst.options[sel[i]+1].selected )
		{
			var tmp = new Array(lst.options[sel[i]+1].text, lst.options[sel[i]+1].value);
			lst.options[sel[i]+1].text     = lst.options[sel[i]].text ;
			lst.options[sel[i]+1].value    = lst.options[sel[i]].value;
			lst.options[sel[i]  ].text     = tmp[0];
			lst.options[sel[i]  ].value    = tmp[1];
			lst.options[sel[i]+1].selected = true ;
			lst.options[sel[i]  ].selected = false;
		}
	}
	// 07/09/2006 Paul.  Update the hidden value as that is the real result that we process. 
	CopyToHidden('<%= lstLeft.ClientID  %>', '<%= txtLeft.ClientID  %>');
}
</script>

<input ID="txtLeft"  type="hidden" Runat="server" />
<input ID="txtRight" type="hidden" Runat="server" />
<asp:Table cellpadding="0" cellspacing="0" runat="server">
	<asp:TableRow>
		<asp:TableCell CssClass="dataLabel"><h4><%= L10n.Term(sChooserTitle) %></h4></asp:TableCell>
	</asp:TableRow>
	<asp:TableRow>
		<asp:TableCell>
			<asp:Table BorderWidth="0" CellPadding="0" CellSpacing="0" runat="server">
				<asp:TableRow>
					<asp:TableCell ID="tdSpacerUpDown" Runat="server">&nbsp;</asp:TableCell>
					<asp:TableCell CssClass="dataLabel" Wrap="false"><b><%= L10n.Term(sLeftTitle) %></b></asp:TableCell>
					<asp:TableCell ID="tdSpacerLeftRight" Runat="server">&nbsp;</asp:TableCell>
					<asp:TableCell CssClass="dataLabel" Wrap="false"><b><%= L10n.Term(sRightTitle) %></b></asp:TableCell>
				</asp:TableRow>
				<asp:TableRow>
					<asp:TableCell ID="tdMoveUpDown" valign="top" style="padding-right: 2px; padding-left: 2px;" Runat="server">
						<a id="ctlChooser_MoveUp" onclick="javascript:MoveUp('<%= lstLeft.ClientID %>');"  >
							<asp:Image AlternateText='<%# L10n.Term(".LNK_SORT") %>' style="margin-bottom: 1px;" SkinID="uparrow_big" Runat="server" />
						</a><br />
						<a id="ctlChooser_MoveDown" onclick="javascript:MoveDown('<%= lstLeft.ClientID %>');">
							<asp:Image AlternateText='<%# L10n.Term(".LNK_SORT") %>' style="margin-top: 1px;" SkinID="downarrow_big" Runat="server" />
						</a>
					</asp:TableCell>
					<asp:TableCell>
						<asp:ListBox ID="lstLeft" Rows="10" SelectionMode="Multiple" Runat="server" />
					</asp:TableCell>
					<asp:TableCell ID="tdMoveLeftRight" valign="top" style="padding-right: 2px; padding-left: 2px;" Runat="server">
						<a id="ctlChooser_MoveLeft" onclick="javascript:MoveLeftToRight('<%= lstRight.ClientID %>','<%= lstLeft.ClientID %>', 1);">
							<asp:Image AlternateText='<%# L10n.Term(".LNK_SORT") %>' style="margin-right: 1px;" SkinID="leftarrow_big" Runat="server" />
						</a>
						<a id="ctlChooser_MoveRight" onclick="javascript:MoveLeftToRight('<%= lstLeft.ClientID %>','<%= lstRight.ClientID %>', 0);">
							<asp:Image AlternateText='<%# L10n.Term(".LNK_SORT") %>' style="margin-left: 1px;" SkinID="rightarrow_big" Runat="server" />
						</a>
					</asp:TableCell>
					<asp:TableCell>
						<asp:ListBox ID="lstRight" Rows="10" SelectionMode="Multiple" Runat="server" />
					</asp:TableCell>
					<asp:TableCell valign="top" style="padding-right: 2px; padding-left: 2px;">
					</asp:TableCell>
				</asp:TableRow>
			</asp:Table>
			<br />
		</asp:TableCell>
	</asp:TableRow>
</asp:Table>
<script type="text/javascript">
CopyToHidden('<%= lstLeft.ClientID  %>', '<%= txtLeft.ClientID  %>');
CopyToHidden('<%= lstRight.ClientID %>', '<%= txtRight.ClientID %>');
</script>


<%@ Page language="c#" trace="false" Codebehind="SystemCheck.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.SystemCheck" %>
<%@ Import Namespace="System.Threading" %>
<%@ Import Namespace="System.Globalization" %>
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
<!DOCTYPE HTML>
<html>
<head runat="server">
	<title>SystemCheck</title>
	<link href="<%= Session["themeURL"] %>style.css" type="text/css" rel="stylesheet" />
	<style>
		h1 { padding-top: 4px; }
	</style>
</head>
<body>
<br>
&nbsp;<a href="Home/">Home</a>
<h1>System</h1>
<table border="1" cellpadding="3" cellspacing="0">
<tr><td>SplendidCRM Build     </td><td><%= Application["SplendidVersion"           ] %></td></tr>
<tr><td>Service Level         </td><td><%= Application["CONFIG.service_level"      ] %></td></tr>
<tr><td>Request Server        </td><td><%= Request.ServerVariables["SERVER_NAME"   ] %></td></tr>
<tr><td>Server Name           </td><td><%= Application["ServerName"                ] %></td></tr>
<tr><td>Machine Name          </td><td><%= sMachineName                              %></td></tr>
<tr><td>Job Server            </td><td><%= Application["SplendidJobServerFlag"     ] %></td></tr>
<tr><td>Workflow Server       </td><td><%= Application["SplendidWorkflowServerFlag"] %></td></tr>
<tr><td>ApplicationPath       </td><td><%= Request.ApplicationPath                   %></td></tr>
<tr><td>rootURL               </td><td><%= Application["rootURL"                   ] %></td></tr>
<tr><td>imageURL              </td><td><%= Application["imageURL"                  ] %></td></tr>
<tr><td>scriptURL             </td><td><%= Application["scriptURL"                 ] %></td></tr>
<tr><td>chartURL              </td><td><%= Application["chartURL"                  ] %></td></tr>
<tr><td>Splendid Provider     </td><td><%= Application["SplendidProvider"          ] %></td></tr>
<tr><td>Default Theme         </td><td><%= Application["CONFIG.default_theme"      ] %></td></tr>
<tr><td>Default Language      </td><td><%= Application["CONFIG.default_language"   ] %></td></tr>
<tr><td>Windows Authentication</td><td><%= SplendidCRM.Security.IsWindowsAuthentication() ? "Yes" : "No" %></td></tr>
<tr><td>Is Mobile Device      </td><td><%= Utils.IsMobileDevice      ? "Yes" : "No"  %></td></tr>
<tr><td>Supports Popups       </td><td><%= Utils.SupportsPopups      ? "Yes" : "No"  %></td></tr>
<tr><td>Supports Speech       </td><td><%= Utils.SupportsSpeech      ? "Yes" : "No"  %></td></tr>
<tr><td>Supports Handwriting  </td><td><%= Utils.SupportsHandwriting ? "Yes" : "No"  %></td></tr>
<tr><td>Supports Touch        </td><td><%= Utils.SupportsTouch       ? "Yes" : "No"  %></td></tr>
<tr><td>Allow Auto Complete   </td><td><%= Utils.AllowAutoComplete   ? "Yes" : "No"  %></td></tr>
<tr><td>Browser Name          </td><td><%= Request.Browser.Browser                   %></td></tr>
<tr><td>Browser Version       </td><td><%= Request.Browser.Version                   %></td></tr>
<tr><td>User-Agent            </td><td><%= Request.UserAgent                         %></td></tr>
<tr><td>User-Address          </td><td><%= Request.UserHostAddress                   %></td></tr>
<tr><td>Platform              </td><td><%= (int) Environment.OSVersion.Platform      %></td></tr>
<tr><td>Silverlight           </td><td><%= Application["CONFIG.enable_silverlight" ] %></td></tr>
<tr><td>Flash                 </td><td><%= Application["CONFIG.enable_flash"       ] %></td></tr>
<tr><td>Url.Query             </td><td><%= Request.Url.Query                         %></td></tr>
<tr><td>System Events         </td><td><%= Application["SYSTEM_EVENTS.MaxDate"     ] %></td></tr>
<tr><td>.NET Version          </td><td><%= System.Environment.Version                %></td></tr>
<tr><td>Image Runtime Version </td><td><%= Application["ImageRuntimeVersion"       ] %></td></tr>
<tr><td>Target Framework      </td><td><%= Application["TargetFramework"           ] %></td></tr>
<tr><td>.NET 4.5 or Higher    </td><td><%= Sql.ToBoolean(Application["System.NET45"]) ? "Yes" : "No" %></td></tr>
<tr><td>SQL Version           </td><td><%= sSqlVersion                               %></td></tr>
</table>

<h1>Process Model</h1>
<table border="1" cellpadding="3" cellspacing="0">
<tr><td>Auto Config           </td><td><%= processModel.AutoConfig                   %></td></tr>
<tr><td>Idle Timeout          </td><td><%= (TimeSpan.MaxValue == processModel.IdleTimeout ? "MaxValue" : processModel.IdleTimeout.TotalMinutes.ToString() ) %></td></tr>
<tr><td>Max Worker Threads    </td><td><%= processModel.MaxWorkerThreads             %></td></tr>
<tr><td>Min Worker Threads    </td><td><%= processModel.MinWorkerThreads             %></td></tr>
<tr><td>Max IO Threads        </td><td><%= processModel.MaxIOThreads                 %></td></tr>
<tr><td>Min IO Threads        </td><td><%= processModel.MinIOThreads                 %></td></tr>
</table>

<h1>User</h1>
<table border="1" cellpadding="3" cellspacing="0">
<tr><td>Session ID       </td><td><%= Session.SessionID                                     %></td></tr>
<tr><td>User Host Address</td><td><%= Request.UserHostAddress                               %></td></tr>
<tr><td>AUTH_USER        </td><td><%= Request.ServerVariables["AUTH_USER"]                  %></td></tr>
<tr><td>USER_ID          </td><td><%= SplendidCRM.Security.USER_ID                          %></td></tr>
<tr><td>FULL_NAME        </td><td><%= SplendidCRM.Security.FULL_NAME                        %></td></tr>
<tr><td>USER_NAME        </td><td><%= SplendidCRM.Security.USER_NAME                        %></td></tr>
<tr><td>EMAIL1           </td><td><%= SplendidCRM.Security.EMAIL1                           %></td></tr>
<tr><td>EXCHANGE_ALIAS   </td><td><%= SplendidCRM.Security.EXCHANGE_ALIAS                   %></td></tr>
<tr><td>TEAM_ID          </td><td><%= SplendidCRM.Security.TEAM_ID                          %></td></tr>
<tr><td>TEAM_NAME        </td><td><%= SplendidCRM.Security.TEAM_NAME                        %></td></tr>
<tr><td>IS_ADMIN         </td><td><%= SplendidCRM.Security.IS_ADMIN          ? "Yes" : "No" %></td></tr>
<tr><td>IS_ADMIN_DELEGATE</td><td><%= SplendidCRM.Security.IS_ADMIN_DELEGATE ? "Yes" : "No" %></td></tr>
<tr><td>PORTAL_ONLY      </td><td><%= SplendidCRM.Security.PORTAL_ONLY       ? "Yes" : "No" %></td></tr>
<tr><td>themeURL         </td><td><%= Session["themeURL"]                                   %></td></tr>

</table>

<h1>User Preferences</h1>
<table border="1" cellpadding="3" cellspacing="0">
<tr><td>USER_SETTINGS/CULTURE         </td><td><%= Session["USER_SETTINGS/CULTURE"         ] %></td></tr>
<tr><td>USER_SETTINGS/THEME           </td><td><%= Session["USER_SETTINGS/THEME"           ] %></td></tr>
<tr><td>USER_SETTINGS/DATEFORMAT      </td><td><%= Session["USER_SETTINGS/DATEFORMAT"      ] %></td></tr>
<tr><td>USER_SETTINGS/TIMEFORMAT      </td><td><%= Session["USER_SETTINGS/TIMEFORMAT"      ] %></td></tr>
<tr><td>USER_SETTINGS/TIMEZONE        </td><td><%= Session["USER_SETTINGS/TIMEZONE"        ] %></td></tr>
<tr><td>USER_SETTINGS/CURRENCY        </td><td><%= Session["USER_SETTINGS/CURRENCY"        ] %></td></tr>
</table>

<%
string m_sCULTURE     = SplendidCRM.Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
SplendidCRM.L10N L10n = new SplendidCRM.L10N(m_sCULTURE);
CultureInfo culture   = CultureInfo.CreateSpecificCulture(L10n.NAME);
%>
<h1>Culture Defaults</h1>
<table border="1" cellpadding="3" cellspacing="0">
<tr><td>Name                    </td><td><%= culture.Name                                  %></td></tr>
<tr><td>DisplayName             </td><td><%= culture.DisplayName                           %></td></tr>
<tr><td>ShortDatePattern        </td><td><%= culture.DateTimeFormat.ShortDatePattern       %></td></tr>
<tr><td>ShortTimePattern        </td><td><%= culture.DateTimeFormat.ShortTimePattern       %></td></tr>
<tr><td>CurrencySymbol          </td><td><%= culture.NumberFormat.CurrencySymbol           %></td></tr>
<tr><td>CurrencyGroupSeparator  </td><td><%= culture.NumberFormat.CurrencyGroupSeparator   %></td></tr>
<tr><td>CurrencyDecimalSeparator</td><td><%= culture.NumberFormat.CurrencyDecimalSeparator %></td></tr>
<tr><td>NumberGroupSeparator    </td><td><%= culture.NumberFormat.NumberGroupSeparator     %></td></tr>
<tr><td>NumberDecimalSeparator  </td><td><%= culture.NumberFormat.NumberDecimalSeparator   %></td></tr>
</table>

<br />
<%@ Register TagPrefix="SplendidCRM" Tagname="AccessView" Src="~/Administration/ACLRoles/AccessView.ascx" %>
<SplendidCRM:AccessView ID="ctlAccessView" EnableACLEditing="false" USER_ID="<%# SplendidCRM.Security.USER_ID %>" Visible='<%# SplendidCRM.Security.IsAuthenticated() && !SplendidCRM.Security.IS_ADMIN %>' Runat="Server" />

<h1>System Log</h1>
<asp:DataGrid Width="100%" CssClass="listView"
	CellPadding="3" CellSpacing="0" border="0"
	AllowPaging="false" PageSize="20" AllowSorting="false" AutoGenerateColumns="true" 
	DataSource='<%# Application["SystemErrors"] %>'
	runat="server">
	<ItemStyle            CssClass="oddListRowS1"  VerticalAlign="Top" />
	<AlternatingItemStyle CssClass="evenListRowS1" VerticalAlign="Top" />
	<HeaderStyle          CssClass="listViewThS1"  />
</asp:DataGrid>
</body>
</html>


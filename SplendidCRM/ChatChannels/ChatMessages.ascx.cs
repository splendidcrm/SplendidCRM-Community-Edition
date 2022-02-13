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
using System;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.ChatChannels
{
	/// <summary>
	///		Summary description for ChatMessages.
	/// </summary>
	public class ChatMessages : SplendidControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected _controls.SearchView     ctlSearchView    ;
		protected UniqueStringCollection arrSelectFields;
		protected Guid            gID            ;
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "ChatMessages.Create":
					{
						Response.Redirect("~/ChatMessages/edit.aspx?CHAT_CHANNEL_ID=" + gID.ToString());
						break;
					}
					case "ChatMessages.View":
					{
						Guid gCHAT_MESSAGE_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/ChatMessages/view.aspx?ID=" + gCHAT_MESSAGE_ID.ToString());
						break;
					}
					case "ChatMessages.Edit":
					{
						Guid gCHAT_MESSAGE_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/ChatMessages/edit.aspx?ID=" + gCHAT_MESSAGE_ID.ToString());
						break;
					}
					case "ChatMessages.Search":
						ctlSearchView.Visible = !ctlSearchView.Visible;
						break;
					case "Search":
						break;
					case "Clear":
						BindGrid();
						break;
					case "SortGrid":
						break;
					// 06/07/2015 Paul.  Add support for Preview button. 
					case "Preview":
						if ( Page.Master is SplendidMaster )
						{
							CommandEventArgs ePreview = new CommandEventArgs(e.CommandName, new PreviewData(m_sMODULE, Sql.ToGuid(e.CommandArgument)));
							(Page.Master as SplendidMaster).Page_Command(sender, ePreview);
						}
						break;
					default:
						throw(new Exception("Unknown command: " + e.CommandName));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void BindGrid()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
				     + "  from vwCHAT_CHANNELS_CHAT_MESSAGES" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Security.Filter(cmd, m_sMODULE, "list");
					Sql.AppendParameter(cmd, gID, "CHAT_CHANNEL_ID");
					ctlSearchView.SqlSearchClause(cmd);
					cmd.CommandText += grdMain.OrderByClause("DATE_ENTERED", "desc");

					if ( bDebug )
						RegisterClientScriptBlock("vwCHAT_CHANNELS_CHAT_MESSAGES", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								grdMain.DataBind();
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			gID = Sql.ToGuid(Request["ID"]);
			BindGrid();

			if ( !IsPostBack )
			{
				Guid gASSIGNED_USER_ID = Sql.ToGuid(Page.Items["ASSIGNED_USER_ID"]);
				ctlDynamicButtons.AppendButtons("ChatChannels." + m_sMODULE, gASSIGNED_USER_ID, gID);
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlSearchView.Command     += new CommandEventHandler(Page_Command);
			m_sMODULE = "ChatMessages";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("DATE_ENTERED"   );
			arrSelectFields.Add("CHAT_MESSAGE_ID");
			// 06/07/2015 Paul.  Must include Page_Command in order for Preview to fire. 
			this.AppendGridColumns(grdMain, "ChatChannels." + m_sMODULE, arrSelectFields, Page_Command);
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("ChatChannels." + m_sMODULE, Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}

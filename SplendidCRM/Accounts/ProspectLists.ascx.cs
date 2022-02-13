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

namespace SplendidCRM.Accounts
{
	/// <summary>
	///		Summary description for ProspectLists.
	/// </summary>
	public class ProspectLists : SubPanelControl
	{
		// 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
		protected _controls.SubPanelButtons ctlDynamicButtons;
		protected UniqueStringCollection arrSelectFields;
		protected Guid            gID                ;
		protected DataView        vwMain             ;
		protected SplendidGrid    grdMain            ;
		protected HtmlInputHidden txtPROSPECT_LIST_ID;
		protected Button          btnCreateInline   ;
		protected Panel           pnlNewRecordInline;
		protected SplendidCRM.ProspectLists.NewRecord ctlNewRecord   ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "ProspectLists.Edit":
					{
						Guid gPROSPECT_LIST_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/ProspectLists/edit.aspx?ID=" + gPROSPECT_LIST_ID.ToString());
						break;
					}
					case "ProspectLists.Remove":
					{
						Guid gPROSPECT_LIST_ID = Sql.ToGuid(e.CommandArgument);
						if ( bEditView )
						{
							this.DeleteEditViewRelationship(gPROSPECT_LIST_ID);
						}
						else
						{
							SqlProcs.spPROSPECT_LISTS_ACCOUNTS_Delete(gPROSPECT_LIST_ID, gID);
						}
						BindGrid();
						break;
					}
					case "ProspectLists.Create":
						if ( this.IsMobile || Sql.ToBoolean(Application["CONFIG.disable_editview_inline"]) )
							Response.Redirect("~/" + m_sMODULE + "/edit.aspx?PARENT_ID=" + gID.ToString());
						else
						{
							pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "inline");
							ctlDynamicButtons.HideAll();
						}
						break;
					case "NewRecord.Cancel":
						pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
						ctlDynamicButtons.ShowAll();
						break;
					case "NewRecord.FullForm":
						Response.Redirect("~/" + m_sMODULE + "/edit.aspx?PARENT_ID=" + gID.ToString());
						break;
					case "NewRecord":
						Response.Redirect(Request.RawUrl);
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
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
					if ( bEditView && IsPostBack && arrUPDATED.Count > 0 )
					{
						arrSelectFields.Remove("PROSPECT_LIST_ID"         );
						arrSelectFields.Remove("PROSPECT_LIST_NAME"       );
						arrSelectFields.Remove("ACCOUNT_ID"               );
						arrSelectFields.Remove("ACCOUNT_NAME"             );
						arrSelectFields.Remove("ACCOUNT_ASSIGNED_USER_ID");
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + "     , ID                         as PROSPECT_LIST_ID         " + ControlChars.CrLf
						     + "     , NAME                       as PROSPECT_LIST_NAME       " + ControlChars.CrLf
						     + "     , @ACCOUNT_ID                as ACCOUNT_ID               " + ControlChars.CrLf
						     + "     , @ACCOUNT_NAME              as ACCOUNT_NAME             " + ControlChars.CrLf
						     + "     , @ACCOUNT_ASSIGNED_USER_ID  as ACCOUNT_ASSIGNED_USER_ID " + ControlChars.CrLf
						     + "  from vwPROSPECT_LISTS" + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ACCOUNT_ID"              , gID);
						Sql.AddParameter(cmd, "@ACCOUNT_NAME"            , Sql.ToString(Page.Items["NAME"            ]));
						Sql.AddParameter(cmd, "@ACCOUNT_ASSIGNED_USER_ID", Sql.ToGuid  (Page.Items["ASSIGNED_USER_ID"]));
						Security.Filter(cmd, m_sMODULE, "list");
						Sql.AppendParameter(cmd, arrUPDATED.ToArray(), "ID");
					}
					else
					{
						// 10/05/2017 Paul.  Add Archive relationship view. 
						// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
						     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						// 10/08/2017 Paul.  Add Archive access right. 
						Security.Filter(cmd, m_sMODULE, (ArchiveViewEnabled() ? "archive" : "list"));
						Sql.AppendParameter(cmd, gID, "ACCOUNT_ID");
					}
					cmd.CommandText += grdMain.OrderByClause("DATE_ENTERED", "desc");

					if ( bDebug )
						RegisterClientScriptBlock("vwACCOUNTS_PROSPECT_LISTS", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								// 10/05/2017 Paul.  Add Archive relationship view. 
								this.ApplyGridViewRules("Accounts." + this.LayoutListView, dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								grdMain.DataBind();
								if ( bEditView && !IsPostBack )
								{
									this.CreateEditViewRelationships(dt, "PROSPECT_LIST_ID");
								}
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

		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			UniqueGuidCollection arrDELETED = this.GetDeletedEditViewRelationships();
			foreach ( Guid gDELETE_ID in arrDELETED )
			{
				if ( !Sql.IsEmptyGuid(gDELETE_ID) )
					SqlProcs.spPROSPECT_LISTS_ACCOUNTS_Delete(gDELETE_ID, gPARENT_ID, trn);
			}

			UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
			foreach ( Guid gUPDATE_ID in arrUPDATED )
			{
				if ( !Sql.IsEmptyGuid(gUPDATE_ID) )
					SqlProcs.spPROSPECT_LISTS_ACCOUNTS_Update(gUPDATE_ID, gPARENT_ID, trn);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			gID = Sql.ToGuid(Request["ID"]);
			Guid gPROSPECT_LIST_ID = Sql.ToGuid(txtPROSPECT_LIST_ID.Value);
			if ( !Sql.IsEmptyGuid(gPROSPECT_LIST_ID) )
			{
				try
				{
					if ( bEditView )
					{
						this.UpdateEditViewRelationship(gPROSPECT_LIST_ID);
					}
					else
					{
						SqlProcs.spPROSPECT_LISTS_ACCOUNTS_Update(gPROSPECT_LIST_ID, gID);
					}
					txtPROSPECT_LIST_ID.Value = String.Empty;
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			try
			{
				BindGrid();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}

			if ( !IsPostBack )
			{
				Guid gASSIGNED_USER_ID = Sql.ToGuid(Page.Items["ASSIGNED_USER_ID"]);
				// 10/05/2017 Paul.  Add Archive relationship view. 
				ctlDynamicButtons.AppendButtons("Accounts." + this.LayoutListView, gASSIGNED_USER_ID, gID);
				ctlNewRecord.PARENT_ID   = gID;
				ctlNewRecord.PARENT_TYPE = "Accounts";
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
			ctlNewRecord.Command      += new CommandEventHandler(Page_Command);
			m_sMODULE = "ProspectLists";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("DATE_ENTERED"             );
			arrSelectFields.Add("PROSPECT_LIST_ID"         );
			arrSelectFields.Add("ASSIGNED_USER_ID"         );
			arrSelectFields.Add("ACCOUNT_ASSIGNED_USER_ID");
			// 10/05/2017 Paul.  Add Archive relationship view. 
			m_sVIEW_NAME = "vwACCOUNTS_PROSPECT_LISTS";
			if ( ArchiveViewExists() )
				m_sVIEW_NAME = m_sVIEW_NAME + "_ARCHIVE";
			this.LayoutListView = m_sMODULE + (ArchiveView() ? ".ArchiveView" : String.Empty);
			this.AppendGridColumns(grdMain, "Accounts." + this.LayoutListView, arrSelectFields, Page_Command);
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("Accounts." + this.LayoutListView, Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}


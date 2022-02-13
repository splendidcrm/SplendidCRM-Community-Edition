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

namespace SplendidCRM.ProspectLists
{
	/// <summary>
	///		Summary description for Accounts.
	/// </summary>
	public class Accounts : SubPanelControl
	{
		protected _controls.SubPanelButtons ctlDynamicButtons;
		protected _controls.SearchView     ctlSearchView    ;
		protected UniqueStringCollection arrSelectFields;
		protected Guid            gID            ;
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected HtmlInputHidden txtACCOUNT_ID  ;
		protected Button          btnCreateInline   ;
		protected Panel           pnlNewRecordInline;
		protected SplendidCRM.Accounts.NewRecord ctlNewRecord   ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "Accounts.Import":
					{
						Response.Redirect("~/Accounts/import.aspx?PROSPECT_LIST_ID=" + gID.ToString());
						break;
					}
					case "Accounts.Edit":
					{
						Guid gACCOUNT_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/Accounts/edit.aspx?ID=" + gACCOUNT_ID.ToString());
						break;
					}
					case "Accounts.Remove":
					{
						Guid gACCOUNT_ID = Sql.ToGuid(e.CommandArgument);
						if ( bEditView )
						{
							this.DeleteEditViewRelationship(gACCOUNT_ID);
						}
						else
						{
							SqlProcs.spPROSPECT_LISTS_ACCOUNTS_Delete(gID, gACCOUNT_ID);
						}
						BindGrid();
						break;
					}
					case "Accounts.Create":
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
					{
						Guid gACCOUNT_ID = Sql.ToGuid(e.CommandArgument);
						SqlProcs.spPROSPECT_LISTS_ACCOUNTS_Update(gID, gACCOUNT_ID);
						Response.Redirect(Request.RawUrl);
						break;
					}
					case "Accounts.Search":
						ctlSearchView.Visible = !ctlSearchView.Visible;
						break;
					case "Search":
						break;
					case "Clear":
						BindGrid();
						break;
					case "SortGrid":
						break;
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
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
					if ( bEditView && IsPostBack && arrUPDATED.Count > 0 )
					{
						arrSelectFields.Remove("ACCOUNT_ID"               );
						arrSelectFields.Remove("ACCOUNT_NAME"             );
						arrSelectFields.Remove("PROSPECT_LIST_ID"         );
						arrSelectFields.Remove("PROSPECT_LIST_NAME"       );
						arrSelectFields.Remove("PROSPECT_ASSIGNED_USER_ID");
						arrSelectFields.Remove("PROSPECT_DYNAMIC_LIST"    );
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + "     , ID                         as ACCOUNT_ID               " + ControlChars.CrLf
						     + "     , NAME                       as ACCOUNT_NAME             " + ControlChars.CrLf
						     + "     , @PROSPECT_LIST_ID          as PROSPECT_LIST_ID         " + ControlChars.CrLf
						     + "     , @PROSPECT_LIST_NAME        as PROSPECT_LIST_NAME       " + ControlChars.CrLf
						     + "     , @PROSPECT_ASSIGNED_USER_ID as PROSPECT_ASSIGNED_USER_ID" + ControlChars.CrLf
						     + "     , @PROSPECT_DYNAMIC_LIST     as PROSPECT_DYNAMIC_LIST    " + ControlChars.CrLf
						     + "  from vwACCOUNTS" + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@PROSPECT_LIST_ID"         , gID);
						Sql.AddParameter(cmd, "@PROSPECT_LIST_NAME"       , Sql.ToString (Page.Items["NAME"                 ]));
						Sql.AddParameter(cmd, "@PROSPECT_ASSIGNED_USER_ID", Sql.ToGuid   (Page.Items["ASSIGNED_USER_ID"     ]));
						Sql.AddParameter(cmd, "@PROSPECT_DYNAMIC_LIST"    , Sql.ToBoolean(Page.Items["PROSPECT_DYNAMIC_LIST"]));
						Security.Filter(cmd, m_sMODULE, "list");
						Sql.AppendParameter(cmd, arrUPDATED.ToArray(), "ID");
					}
					else
					{
						// 10/05/2017 Paul.  Add Archive relationship view. 
						// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
						// 07/01/2018 Paul.  Add ERASED_FIELDS when data privacy enabled. 
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
						     + Sql.AppendDataPrivacyField(m_sVIEW_NAME)
						     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Security.Filter(cmd, m_sMODULE, "list");
						Sql.AppendParameter(cmd, gID, "PROSPECT_LIST_ID");
					}
					ctlSearchView.SqlSearchClause(cmd);
					cmd.CommandText += grdMain.OrderByClause("NAME", "asc");

					if ( bDebug )
						RegisterClientScriptBlock("vwPROSPECT_LISTS_ACCOUNTS", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								// 10/05/2017 Paul.  Add Archive relationship view. 
								this.ApplyGridViewRules("ProspectLists." + this.LayoutListView, dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								grdMain.DataBind();
								if ( bEditView && !IsPostBack )
								{
									this.CreateEditViewRelationships(dt, "ACCOUNT_ID");
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

		// 01/27/2010 Paul.  This method is only calld when in EditMode. 
		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			UniqueGuidCollection arrDELETED = this.GetDeletedEditViewRelationships();
			foreach ( Guid gDELETE_ID in arrDELETED )
			{
				if ( !Sql.IsEmptyGuid(gDELETE_ID) )
					SqlProcs.spPROSPECT_LISTS_ACCOUNTS_Delete(gPARENT_ID, gDELETE_ID, trn);
			}

			UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
			foreach ( Guid gUPDATE_ID in arrUPDATED )
			{
				if ( !Sql.IsEmptyGuid(gUPDATE_ID) )
					SqlProcs.spPROSPECT_LISTS_ACCOUNTS_Update(gPARENT_ID, gUPDATE_ID, trn);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			gID = Sql.ToGuid(Request["ID"]);
			if ( !Sql.IsEmptyString(txtACCOUNT_ID.Value) )
			{
				try
				{
					string[] arrID = txtACCOUNT_ID.Value.Split(',');
					if ( arrID != null )
					{
						if ( bEditView )
						{
							this.UpdateEditViewRelationship(arrID);
						}
						else
						{
							System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "list", arrID, "ACCOUNTS");
							if ( stk.Count > 0 )
							{
								DbProviderFactory dbf = DbProviderFactories.GetFactory();
								using ( IDbConnection con = dbf.CreateConnection() )
								{
									con.Open();
									using ( IDbTransaction trn = Sql.BeginTransaction(con) )
									{
										try
										{
											while ( stk.Count > 0 )
											{
												string sIDs = Utils.BuildMassIDs(stk);
												SqlProcs.spPROSPECT_LISTS_ACCOUNTS_MassUpdate(sIDs, gID, trn);
											}
											trn.Commit();
										}
										catch(Exception ex)
										{
											trn.Rollback();
											throw(new Exception(ex.Message, ex.InnerException));
										}
									}
								}
								txtACCOUNT_ID.Value = String.Empty;
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
				ctlDynamicButtons.AppendButtons("ProspectLists." + this.LayoutListView, gASSIGNED_USER_ID, gID);
				bool bDYNAMIC_LIST = Sql.ToBoolean(Page.Items["DYNAMIC_LIST"]);
				if ( bDYNAMIC_LIST )
					ctlDynamicButtons.DisableAll();
				ctlNewRecord.PARENT_ID = gID;
				ctlNewRecord.PARENT_TYPE = "ProspectLists";
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
			ctlSearchView.Command     += new CommandEventHandler(Page_Command);
			m_sMODULE = "Accounts";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("DATE_ENTERED"             );
			arrSelectFields.Add("ACCOUNT_ID"               );
			arrSelectFields.Add("ASSIGNED_USER_ID"         );
			arrSelectFields.Add("PROSPECT_ASSIGNED_USER_ID");
			arrSelectFields.Add("PROSPECT_DYNAMIC_LIST"    );
			// 10/05/2017 Paul.  Add Archive relationship view. 
			m_sVIEW_NAME = "vwPROSPECT_LISTS_ACCOUNTS";
			if ( ArchiveViewExists() )
				m_sVIEW_NAME = m_sVIEW_NAME + "_ARCHIVE";
			this.LayoutListView = m_sMODULE + (ArchiveView() ? ".ArchiveView" : String.Empty);
			this.AppendGridColumns(grdMain, "ProspectLists." + this.LayoutListView, arrSelectFields, Page_Command);
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("ProspectLists." + this.LayoutListView, Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}


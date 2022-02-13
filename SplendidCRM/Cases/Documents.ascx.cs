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

namespace SplendidCRM.Cases
{
	/// <summary>
	///		Summary description for Documents.
	/// </summary>
	public class Documents : SubPanelControl
	{
		// 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
		protected _controls.SubPanelButtons ctlDynamicButtons;
		// 10/05/2017 Paul.  We need to build a list of the fields used by the search clause. 
		protected UniqueStringCollection arrSelectFields;
		protected Guid            gID            ;
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected Label           lblError       ;
		protected HtmlInputHidden txtDOCUMENT_ID ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "Documents.Create":
						Response.Redirect("~/Documents/edit.aspx?PARENT_ID=" + gID.ToString());
						break;
					case "Documents.Edit":
					{
						Guid gDOCUMENT_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/Documents/view.aspx?ID=" + gDOCUMENT_ID.ToString());
						break;
					}
					case "Documents.Remove":
					{
						Guid gDOCUMENT_ID = Sql.ToGuid(e.CommandArgument);
						SqlProcs.spDOCUMENTS_CASES_Delete(gID, gDOCUMENT_ID);
						BindGrid();
						break;
					}
					case "Documents.GetLatest":
					{
						Guid gDOCUMENT_ID = Sql.ToGuid(e.CommandArgument);
						if ( bEditView )
						{
							this.DeleteEditViewRelationship(gDOCUMENT_ID);
						}
						else
						{
							SqlProcs.spDOCUMENTS_CASES_GetLatest(gID, gDOCUMENT_ID);
						}
						BindGrid();
						break;
					}
					// 10/05/2017 Paul.  Add support for Preview button. 
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
						// 10/05/2017 Paul.  We need to build a list of the fields used by the search clause. 
						arrSelectFields.Remove("DOCUMENT_ID"                  );
						arrSelectFields.Remove("SELECTED_REVISION"            );
						arrSelectFields.Remove("SELECTED_DOCUMENT_REVISION_ID");
						arrSelectFields.Remove("CASE_ID"                      );
						arrSelectFields.Remove("CASE_NAME"                    );
						arrSelectFields.Remove("CASE_ASSIGNED_USER_ID"        );
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + "     , ID                        as DOCUMENT_ID                  " + ControlChars.CrLf
						     + "     , null                      as SELECTED_REVISION            " + ControlChars.CrLf
						     + "     , null                      as SELECTED_DOCUMENT_REVISION_ID" + ControlChars.CrLf
						     + "     , @CASE_ID                  as CASE_ID                      " + ControlChars.CrLf
						     + "     , @CASE_NAME                as CASE_NAME                    " + ControlChars.CrLf
						     + "     , @CASE_ASSIGNED_USER_ID    as CASE_ASSIGNED_USER_ID        " + ControlChars.CrLf
						     + "  from vwDOCUMENTS" + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@CASE_ID"              , gID);
						Sql.AddParameter(cmd, "@CASE_NAME"            , Sql.ToString(Page.Items["NAME"            ]));
						Sql.AddParameter(cmd, "@CASE_ASSIGNED_USER_ID", Sql.ToGuid  (Page.Items["ASSIGNED_USER_ID"]));
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
						// 10/06/2017 Paul.  Make sure to filter relationship data based on team access rights. 
						// 10/08/2017 Paul.  Add Archive access right. 
						Security.Filter(cmd, m_sMODULE, (ArchiveViewEnabled() ? "archive" : "list"));
						Sql.AppendParameter(cmd, gID, "CASE_ID");
					}
					// 10/05/2017 Paul.  Move Last Sort to the database.
					cmd.CommandText += grdMain.OrderByClause("DOCUMENT_NAME", "asc");

					if ( bDebug )
						RegisterClientScriptBlock("vwCASES_DOCUMENTS", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								// 03/07/2013 Paul.  Apply business rules to subpanel. 
								// 10/05/2017 Paul.  Add Archive relationship view. 
								this.ApplyGridViewRules("Cases." + this.LayoutListView, dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								grdMain.DataBind();
								if ( bEditView && !IsPostBack )
								{
									this.CreateEditViewRelationships(dt, "DOCUMENT_ID");
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
					SqlProcs.spDOCUMENTS_CASES_Delete(gPARENT_ID, gDELETE_ID, trn);
			}

			UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
			foreach ( Guid gUPDATE_ID in arrUPDATED )
			{
				if ( !Sql.IsEmptyGuid(gUPDATE_ID) )
					SqlProcs.spDOCUMENTS_CASES_Update(gPARENT_ID, gUPDATE_ID, trn);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			gID = Sql.ToGuid(Request["ID"]);
			Guid gDOCUMENT_ID = Sql.ToGuid(txtDOCUMENT_ID.Value);
			if ( !Sql.IsEmptyGuid(gDOCUMENT_ID) )
			{
				try
				{
					if ( bEditView )
					{
						this.UpdateEditViewRelationship(gDOCUMENT_ID);
					}
					else
					{
						SqlProcs.spDOCUMENTS_CASES_Update(gID, gDOCUMENT_ID);
					}
					txtDOCUMENT_ID.Value = String.Empty;
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
				// 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
				if ( !IsPostBack )
				{
					Guid gASSIGNED_USER_ID = Sql.ToGuid(Page.Items["ASSIGNED_USER_ID"]);
					// 10/05/2017 Paul.  Add Archive relationship view. 
					ctlDynamicButtons.AppendButtons("Cases." + this.LayoutListView, gASSIGNED_USER_ID, gID);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
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
			m_sMODULE = "Documents";
			// 10/05/2017 Paul.  We need to build a list of the fields used by the search clause. 
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("DOCUMENT_ID"          );
			arrSelectFields.Add("DOCUMENT_NAME"        );
			arrSelectFields.Add("SELECTED_REVISION"    );
			arrSelectFields.Add("REVISION"             );
			arrSelectFields.Add("ASSIGNED_USER_ID"     );
			arrSelectFields.Add("CASE_ASSIGNED_USER_ID");
			// 10/05/2017 Paul.  Add Archive relationship view. 
			m_sVIEW_NAME = "vwCASES_DOCUMENTS";
			if ( ArchiveViewExists() )
				m_sVIEW_NAME = m_sVIEW_NAME + "_ARCHIVE";
			this.LayoutListView = m_sMODULE + (ArchiveView() ? ".ArchiveView" : String.Empty);
			this.AppendGridColumns(grdMain, "Cases." + this.LayoutListView, arrSelectFields, Page_Command);
			// 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("Cases." + this.LayoutListView, Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}

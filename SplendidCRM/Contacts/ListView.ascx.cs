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
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Contacts
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		// 06/05/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlModuleHeader;
		protected _controls.ExportHeader ctlExportHeader;
		protected _controls.SearchView   ctlSearchView  ;
		protected _controls.CheckAll     ctlCheckAll    ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected MassUpdate    ctlMassUpdate  ;
		// 06/06/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected Panel         pnlMassUpdateSeven;
		// 04/03/2018 Paul.  Enable Dynamic Mass Update.
		protected _controls.DynamicMassUpdate ctlDynamicMassUpdate;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					// 10/13/2005 Paul.  Make sure to clear the page index prior to applying search. 
					grdMain.CurrentPageIndex = 0;
					// 04/27/2008 Paul.  Sorting has been moved to the database to increase performance. 
					grdMain.DataBind();
				}
				// 12/14/2007 Paul.  We need to capture the sort event from the SearchView. 
				else if ( e.CommandName == "SortGrid" )
				{
					grdMain.SetSortFields(e.CommandArgument as string[]);
					// 04/27/2008 Paul.  Sorting has been moved to the database to increase performance. 
					// 03/17/2011 Paul.  We need to treat a comma-separated list of fields as an array. 
					arrSelectFields.AddFields(grdMain.SortColumn);
				}
				// 11/17/2010 Paul.  Populate the hidden Selected field with all IDs. 
				else if ( e.CommandName == "SelectAll" )
				{
					// 05/22/2011 Paul.  When using custom paging, vwMain may not be defined. 
					if ( vwMain == null )
						grdMain.DataBind();
					ctlCheckAll.SelectAll(vwMain, "ID");
					grdMain.DataBind();
				}
				// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
				else if ( e.CommandName == "ToggleMassUpdate" )
				{
					pnlMassUpdateSeven.Visible = !pnlMassUpdateSeven.Visible;
				}
				else if ( e.CommandName == "MassUpdate" )
				{
					// 11/27/2010 Paul.  Use new selected items. 
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						// 10/26/2007 Paul.  Use a stack to run the update in blocks of under 200 IDs. 
						//string sIDs = Utils.ValidateIDs(arrID);
						System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "edit", arrID, Crm.Modules.TableName(m_sMODULE));
						if ( stk.Count > 0 )
						{
							DbProviderFactory dbf = DbProviderFactories.GetFactory();
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
								using ( IDbTransaction trn = Sql.BeginTransaction(con) )
								{
									try
									{
										while ( stk.Count > 0 )
										{
											string sIDs = Utils.BuildMassIDs(stk);
											// 09/11/2007 Paul.  Mass update of teams is now available. 
											// 08/29/2009 Paul.  Add support for dynamic teams. 
											// 05/13/2016 Paul.  Add Tags module. 
											// 06/29/2018 Paul.  Placeholders for ASSIGNED_SET_LIST and ASSIGNED_SET_ADD. 
											SqlProcs.spCONTACTS_MassUpdate(sIDs, ctlMassUpdate.ASSIGNED_USER_ID, ctlMassUpdate.ACCOUNT_ID, ctlMassUpdate.LEAD_SOURCE, ctlMassUpdate.REPORTS_TO_ID, ctlMassUpdate.PRIMARY_TEAM_ID, ctlMassUpdate.TEAM_SET_LIST, ctlMassUpdate.ADD_TEAM_SET, ctlMassUpdate.TAG_SET_NAME, ctlMassUpdate.ADD_TAG_SET, String.Empty, false, trn);
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
							Response.Redirect("default.aspx");
						}
					}
				}
				// 04/03/2018 Paul.  Enable Dynamic Mass Update.
				else if ( e.CommandName == "DynamicMassUpdate" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "edit", arrID, Crm.Modules.TableName(m_sMODULE));
						if ( stk.Count > 0 )
						{
							ctlDynamicMassUpdate.Update(stk);
							Response.Redirect("default.aspx");
						}
					}
				}
				else if ( e.CommandName == "MassDelete" )
				{
					// 11/27/2010 Paul.  Use new selected items. 
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						// 10/26/2007 Paul.  Use a stack to run the update in blocks of under 200 IDs. 
						//string sIDs = Utils.ValidateIDs(arrID);
						System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "delete", arrID, Crm.Modules.TableName(m_sMODULE));
						if ( stk.Count > 0 )
						{
							DbProviderFactory dbf = DbProviderFactories.GetFactory();
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
								using ( IDbTransaction trn = Sql.BeginTransaction(con) )
								{
									try
									{
										while ( stk.Count > 0 )
										{
											string sIDs = Utils.BuildMassIDs(stk);
											SqlProcs.spCONTACTS_MassDelete(sIDs, trn);
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
							Response.Redirect("default.aspx");
						}
					}
				}
				// 12/25/2008 Paul.  Add support for merging records. 
				else if ( e.CommandName == "MassMerge" )
				{
					Server.Transfer("merge.aspx", true);
				}
				// 05/14/2011 Paul.  Add support for mail merge.
				else if ( e.CommandName == "MailMerge" )
				{
					Server.Transfer("~/MailMerge/default.aspx?Module=" + m_sMODULE, true);
				}
				else if ( e.CommandName == "Sync" )
				{
					// 11/27/2010 Paul.  Use new selected items. 
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						string sIDs = Utils.ValidateIDs(arrID);
						if ( !Sql.IsEmptyString(sIDs) )
						{
							SqlProcs.spCONTACTS_MassSync(sIDs);
							Response.Redirect("default.aspx");
						}
					}
				}
				else if ( e.CommandName == "Unsync" )
				{
					// 11/27/2010 Paul.  Use new selected items. 
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						string sIDs = Utils.ValidateIDs(arrID);
						if ( !Sql.IsEmptyString(sIDs) )
						{
							SqlProcs.spCONTACTS_MassUnsync(sIDs);
							Response.Redirect("default.aspx");
						}
					}
				}
				else if ( e.CommandName == "Export" )
				{
					// 11/03/2006 Paul.  Apply ACL rules to Export. 
					int nACLACCESS = SplendidCRM.Security.GetUserAccess(m_sMODULE, "export");
					if ( nACLACCESS  >= 0 )
					{
						// 10/05/2009 Paul.  When exporting, we may need to manually bind.  Custom paging should be disabled when exporting all. 
						if ( vwMain == null )
							grdMain.DataBind();
						// 07/06/2017 Paul.  If there is still no view, then there was an error in the select. 
						if ( vwMain != null )
						{
							if ( nACLACCESS == ACL_ACCESS.OWNER )
								vwMain.RowFilter = "ASSIGNED_USER_ID = '" + Security.USER_ID.ToString() + "'";
							// 11/27/2010 Paul.  Use new selected items. 
							string[] arrID = ctlCheckAll.SelectedItemsArray;
							SplendidExport.Export(vwMain, m_sMODULE, ctlExportHeader.ExportFormat, ctlExportHeader.ExportRange, grdMain.CurrentPageIndex, grdMain.PageSize, arrID, grdMain.AllowCustomPaging);
						}
						else
						{
							lblError.Text += ControlChars.CrLf + "vwMain is null.";
						}
					}
				}
				// 01/05/2016 Paul.  Provide a way to run a report from mass update. 
				else if ( e.CommandName == "Report" || e.CommandName == "ReportAll" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( e.CommandName == "ReportAll" )
					{
						if ( vwMain == null )
							grdMain.DataBind();
						if ( vwMain != null )
						{
							arrID = new string[vwMain.Count];
							for ( int i = 0; i < vwMain.Count; i++ )
							{
								arrID[i] = Sql.ToString(vwMain[i]["ID"]);
							}
						}
					}
					if ( arrID != null && arrID.Length > 0 )
					{
						if ( Sql.IsEmptyString(e.CommandArgument) )
						{
							throw(new Exception("Button CommandArgument is empty."));
						}
						string sRenderURL = "~/Reports/render.aspx?" + Sql.ToString(e.CommandArgument).Trim();
						if ( !sRenderURL.EndsWith("&") )
							sRenderURL += "&";
						string sTABLE_NAME         = Crm.Modules.TableName(m_sMODULE);
						string sMODULE_FIELD_NAME  = Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID";
						sRenderURL += sMODULE_FIELD_NAME + "=" + String.Join("&" + sMODULE_FIELD_NAME + "=", arrID);
						Server.Transfer(sRenderURL);
					}
					else
					{
						throw(new Exception(L10n.Term(".LBL_NOTHING_SELECTED")));
					}
				}
				// 09/26/2017 Paul.  Add Archive access right. 
				else if ( e.CommandName == "Archive.MoveData" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					ArchiveUtils archive = new ArchiveUtils(Context);
					lblError.Text = archive.MoveData(m_sMODULE, arrID);
					if ( Sql.IsEmptyString(lblError.Text) )
						Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Archive.RecoverData" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					ArchiveUtils archive = new ArchiveUtils(Context);
					lblError.Text = archive.RecoverData(m_sMODULE, arrID);
					if ( Sql.IsEmptyString(lblError.Text) )
						Response.Redirect("default.aspx?ArchiveView=1");
				}
				// 08/26/2020 Paul.  Add support for PhoneBurner. 
				else if ( e.CommandName == "PhoneBurner.BeginDialSession" )
				{
					bool bPhoneBurnerEnabled = Sql.ToBoolean(Context.Application["CONFIG.PhoneBurner.Enabled" ]);
					if ( bPhoneBurnerEnabled )
					{
						List<string> arrID = new List<string>();
						grdMain.DataBind();
						if ( vwMain != null )
						{
							int  nStartRecord  = 0                        ;
							int  nEndRecord    = vwMain.Count             ;
							int  nCurrentPage  = grdMain.CurrentPageIndex ;
							int  nPageSize     = grdMain.PageSize         ;
							bool bCustomPaging = grdMain.AllowCustomPaging;
							switch ( ctlExportHeader.ExportRange )
							{
								case "Page":
								{
									if ( !bCustomPaging )
									{
										nStartRecord = nCurrentPage * nPageSize;
										nEndRecord   = Math.Min(nStartRecord + nPageSize, vwMain.Count);
									}
									for ( int i = nStartRecord; i < nEndRecord; i++ )
									{
										arrID.Add(Sql.ToString(vwMain[i]["ID"]));
									}
									break;
								}
								case "Selected":
								{
									if ( ctlCheckAll.SelectedItemsArray != null )
									{
										arrID = new List<string>(ctlCheckAll.SelectedItemsArray);
									}
									break;
								}
								default:
								{
									for ( int i = nStartRecord; i < nEndRecord; i++ )
									{
										arrID.Add(Sql.ToString(vwMain[i]["ID"]));
									}
									break;
								}
							}
						}
						// 08/26/2020 Paul.  There must be one selected record to continue. 
						if ( arrID.Count == 0 )
						{
							throw(new Exception(L10n.Term(".LBL_LISTVIEW_NO_SELECTED")));
						}
						
						Spring.Social.PhoneBurner.DialSession dialSession = new Spring.Social.PhoneBurner.DialSession(Application);
						string redirect_url = dialSession.CreateSession(Security.USER_ID, m_sMODULE, arrID);
						RegisterClientScriptBlock("PhoneBurner", "<script type=\"text/javascript\">window.open('" + redirect_url + "', '_blank', 'scrollbars=yes,resizable=yes,status=yes,location=yes,toolbar=yes,menubar=no');</script>");
					}
				}
				// 03/08/2014 Paul.  Add support for Preview button. 
				else
				{
					grdMain.DataBind();
					if ( Page.Master is SplendidMaster )
						(Page.Master as SplendidMaster).Page_Command(sender, e);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		// 09/08/2009 Paul.  Add support for custom paging. 
		protected void grdMain_OnSelectMethod(int nCurrentPageIndex, int nPageSize)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
					// 03/31/2012 Paul.  Add support for favorites. 
					// 09/26/2017 Paul.  Add Archive access right. 
					// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
					m_sVIEW_NAME = (ArchiveViewEnabled() ? "vw" + sTABLE_NAME + "_ARCHIVE" : "vw" + sTABLE_NAME + "_List");
					cmd.CommandText = "  from " + m_sVIEW_NAME + ControlChars.CrLf
					                + "  left outer join vwSUGARFAVORITES                                       " + ControlChars.CrLf
					                + "               on vwSUGARFAVORITES.FAVORITE_RECORD_ID = ID               " + ControlChars.CrLf
					                + "              and vwSUGARFAVORITES.FAVORITE_USER_ID   = @FAVORITE_USER_ID" + ControlChars.CrLf;
					Sql.AddParameter(cmd, "@FAVORITE_USER_ID", Security.USER_ID);
					// 10/09/2015 Paul.  Add support for subscriptions. 
					if ( this.StreamEnabled() )
					{
						cmd.CommandText += "  left outer join vwSUBSCRIPTIONS                                               " + ControlChars.CrLf;
						cmd.CommandText += "               on vwSUBSCRIPTIONS.SUBSCRIPTION_PARENT_ID = ID                   " + ControlChars.CrLf;
						cmd.CommandText += "              and vwSUBSCRIPTIONS.SUBSCRIPTION_USER_ID   = @SUBSCRIPTION_USER_ID" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@SUBSCRIPTION_USER_ID", Security.USER_ID);
						arrSelectFields.Add("SUBSCRIPTION_PARENT_ID");
					}
					// 09/26/2017 Paul.  Add Archive access right. 
					Security.Filter(cmd, m_sMODULE, (ArchiveViewEnabled() ? "archive" : "list"));
					ctlSearchView.SqlSearchClause(cmd);
					// 09/23/2015 Paul.  Paginated results still need to specify export fields. 
					// 10/11/2015 Paul.  SUBSCRIPTION_PARENT_ID must be provided as it is used in the UI. 
					// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
					// 06/27/2018 Paul.  Add ERASED_FIELDS when data privacy enabled. 
					cmd.CommandText = "select " + (Request.Form[ctlExportHeader.ExportUniqueID] != null ? SplendidDynamic.ExportGridColumns(m_sMODULE + ".Export", arrSelectFields) : Sql.FormatSelectFields(arrSelectFields))
					                + (!this.StreamEnabled() ? "     , null as SUBSCRIPTION_PARENT_ID" + ControlChars.CrLf : String.Empty)
					                + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
					                + Sql.AppendDataPrivacyField(m_sVIEW_NAME)
					                + cmd.CommandText;
					if ( nPageSize > 0 )
					{
						Sql.PageResults(cmd, sTABLE_NAME, grdMain.OrderByClause(), nCurrentPageIndex, nPageSize);
					}
					else
					{
						cmd.CommandText += grdMain.OrderByClause();
					}
					
					if ( bDebug )
						RegisterClientScriptBlock("SQLPaged", Sql.ClientScriptBlock(cmd));
					
					// 01/13/2010 Paul.  Allow default search to be disabled. 
					if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								// 11/22/2010 Paul.  Apply Business Rules. 
								this.ApplyGridViewRules(m_sMODULE + "." + LayoutListView, dt);
								
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
							}
						}
						ctlExportHeader.Visible = true;
					}
					else
					{
						ctlExportHeader.Visible = false;
					}
					// 04/03/2018 Paul.  Enable Dynamic Mass Update. 
					ctlMassUpdate       .Visible = !SplendidCRM.Crm.Config.enable_dynamic_mass_update() && ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
					ctlDynamicMassUpdate.Visible =  SplendidCRM.Crm.Config.enable_dynamic_mass_update() && ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
					// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
					ctlCheckAll  .Visible = ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 09/26/2017 Paul.  Add Archive access right. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, (ArchiveViewEnabled() ? "archive" : "list")) >= 0);
			if ( !this.Visible )
				return;

			try
			{
				// 09/08/2009 Paul.  Add support for custom paging in a DataGrid. Custom paging can be enabled / disabled per module. 
				if ( Crm.Config.allow_custom_paging() && Crm.Modules.CustomPaging(m_sMODULE) )
				{
					// 10/05/2009 Paul.  We need to make sure to disable paging when exporting all. 
					// 09/18/2012 Paul.  Disable custom paging if SelectAll was checked. 
					// 01/24/2018 Paul.  Disable custom paging if Selected Records is used as selection can cross pages. 
					// 08/26/2020 Paul.  We need to determine if the PhoneBurner button has been clicked inside Page_Load. 
					grdMain.AllowCustomPaging = (Request.Form[ctlExportHeader.ExportUniqueID] == null || ctlExportHeader.ExportRange == "Page") && !ctlCheckAll.SelectAllChecked && (Request.Form[ctlExportHeader.PhoneBurnerUniqueID] == null);
					grdMain.SelectMethod     += new SelectMethodHandler(grdMain_OnSelectMethod);
					// 11/17/2010 Paul.  Disable Select All when using custom paging. 
					//ctlCheckAll.ShowSelectAll = false;
				}

				if ( this.IsMobile && grdMain.Columns.Count > 0 )
					grdMain.Columns[0].Visible = false;
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						grdMain.OrderByClause("NAME", "asc");
						
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						// 03/31/2012 Paul.  Add support for favorites. 
						// 09/26/2017 Paul.  Add Archive access right. 
						// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
						m_sVIEW_NAME = (ArchiveViewEnabled() ? "vw" + sTABLE_NAME + "_ARCHIVE" : "vw" + sTABLE_NAME + "_List");
						cmd.CommandText = "  from " + m_sVIEW_NAME + ControlChars.CrLf
						                + "  left outer join vwSUGARFAVORITES                                       " + ControlChars.CrLf
						                + "               on vwSUGARFAVORITES.FAVORITE_RECORD_ID = ID               " + ControlChars.CrLf
						                + "              and vwSUGARFAVORITES.FAVORITE_USER_ID   = @FAVORITE_USER_ID" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@FAVORITE_USER_ID", Security.USER_ID);
						// 10/09/2015 Paul.  Add support for subscriptions. 
						if ( this.StreamEnabled() )
						{
							cmd.CommandText += "  left outer join vwSUBSCRIPTIONS                                               " + ControlChars.CrLf;
							cmd.CommandText += "               on vwSUBSCRIPTIONS.SUBSCRIPTION_PARENT_ID = ID                   " + ControlChars.CrLf;
							cmd.CommandText += "              and vwSUBSCRIPTIONS.SUBSCRIPTION_USER_ID   = @SUBSCRIPTION_USER_ID" + ControlChars.CrLf;
							Sql.AddParameter(cmd, "@SUBSCRIPTION_USER_ID", Security.USER_ID);
							arrSelectFields.Add("SUBSCRIPTION_PARENT_ID");
						}
						// 09/26/2017 Paul.  Add Archive access right. 
						Security.Filter(cmd, m_sMODULE, (ArchiveViewEnabled() ? "archive" : "list"));
						ctlSearchView.SqlSearchClause(cmd);
						// 09/08/2009 Paul.  Custom paging will always require two queries, the first is to get the total number of rows. 
						if ( grdMain.AllowCustomPaging )
						{
							cmd.CommandText = "select count(*)" + ControlChars.CrLf
							                + cmd.CommandText;
							
							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
							
							// 01/13/2010 Paul.  Allow default search to be disabled. 
							if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
							{
								grdMain.VirtualItemCount = Sql.ToInteger(cmd.ExecuteScalar());
							}
						}
						else
						{
							// 04/27/2008 Paul.  The fields in the search clause need to be prepended after any Saved Search sort has been determined.
							// 09/08/2009 Paul.  The order by clause is separate as it can change due to SearchViews. 
							// 04/20/2011 Paul.  If there are no fields in the GridView.Export, then return all fields (*). 
							// 09/23/2015 Paul.  Need to include the data grid fields as it will be bound using the same data set. 
							// 10/11/2015 Paul.  SUBSCRIPTION_PARENT_ID must be provided as it is used in the UI. 
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							// 06/27/2018 Paul.  Add ERASED_FIELDS when data privacy enabled. 
							cmd.CommandText = "select " + (Request.Form[ctlExportHeader.ExportUniqueID] != null ? SplendidDynamic.ExportGridColumns(m_sMODULE + ".Export", arrSelectFields) : Sql.FormatSelectFields(arrSelectFields))
							                + (!this.StreamEnabled() ? "     , null as SUBSCRIPTION_PARENT_ID" + ControlChars.CrLf : String.Empty)
							                + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
							                + Sql.AppendDataPrivacyField(m_sVIEW_NAME)
							                + cmd.CommandText
							                + grdMain.OrderByClause();
							
							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
							
							// 01/13/2010 Paul.  Allow default search to be disabled. 
							if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
							{
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dt = new DataTable() )
									{
										da.Fill(dt);
										// 11/22/2010 Paul.  Apply Business Rules. 
										this.ApplyGridViewRules(m_sMODULE + "." + LayoutListView, dt);
										
										vwMain = dt.DefaultView;
										grdMain.DataSource = vwMain ;
									}
								}
								ctlExportHeader.Visible = true;
							}
							else
							{
								ctlExportHeader.Visible = false;
							}
							// 04/03/2018 Paul.  Enable Dynamic Mass Update. 
							ctlMassUpdate       .Visible = !SplendidCRM.Crm.Config.enable_dynamic_mass_update() && ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
							ctlDynamicMassUpdate.Visible =  SplendidCRM.Crm.Config.enable_dynamic_mass_update() && ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
							// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
							ctlCheckAll  .Visible = ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
						}
					}
				}
				if ( !IsPostBack )
				{
					// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
					//Page.DataBind();
					// 09/08/2009 Paul.  Let the grid handle the differences between normal and custom paging. 
					// 09/08/2009 Paul.  Bind outside of the existing connection so that a second connect would not get created. 
					grdMain.DataBind();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This Contact is required by the ASP.NET Web Form Designer.
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
			ctlSearchView  .Command += new CommandEventHandler(Page_Command);
			ctlExportHeader.Command += new CommandEventHandler(Page_Command);
			ctlMassUpdate  .Command += new CommandEventHandler(Page_Command);
			ctlCheckAll    .Command += new CommandEventHandler(Page_Command);
			// 04/03/2018 Paul.  Enable Dynamic Mass Update.
			ctlDynamicMassUpdate.Command += new CommandEventHandler(Page_Command);
			// 11/26/2005 Paul.  Add fields early so that sort events will get called. 
			m_sMODULE = "Contacts";
			SetMenu(m_sMODULE);
			// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("NAME");
			// 02/20/2010 Paul.  The ASSIGNED_USER_ID is used in the grid, so we must add it. 
			arrSelectFields.Add("ASSIGNED_USER_ID");
			// 03/31/2012 Paul.  Add support for favorites. 
			arrSelectFields.Add("FAVORITE_RECORD_ID");
			// 03/08/2014 Paul.  Add support for Preview button. 
			// 09/26/2017 Paul.  Add Archive access right. 
			ctlModuleHeader.Title = (ArchiveViewEnabled() ? ".LBL_ARCHIVE_VIEW" : ".moduleList.Home");
			this.AppendGridColumns(grdMain, m_sMODULE + "." + (ArchiveViewEnabled() ? "ArchiveView" : LayoutListView), arrSelectFields, Page_Command);
			// 05/02/2006 Paul.  Hide the MassUpdate control if the user cannot make changes. 
			if ( Security.GetUserAccess(m_sMODULE, "delete") < 0 && Security.GetUserAccess(m_sMODULE, "edit") < 0 )
			{
				ctlMassUpdate.Visible = false;
				// 04/03/2018 Paul.  Enable Dynamic Mass Update.
				ctlDynamicMassUpdate.Visible = false;
			}
			
			// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
			if ( SplendidDynamic.StackedLayout(Page.Theme) )
			{
				ctlModuleHeader.Command += new CommandEventHandler(Page_Command);
				ctlModuleHeader.AppendButtons(m_sMODULE + "." + LayoutListView, Guid.Empty, null);
				// 06/05/2015 Paul.  Move MassUpdate buttons to the SplendidGrid. 
				grdMain.IsMobile       = this.IsMobile;
				grdMain.MassUpdateView = m_sMODULE + ".MassUpdate";
				grdMain.Command       += new CommandEventHandler(Page_Command);
				if ( !IsPostBack )
					pnlMassUpdateSeven.Visible = false;
			}
		}
		#endregion
	}
}


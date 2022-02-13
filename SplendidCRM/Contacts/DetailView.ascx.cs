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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Contacts
{
	/// <summary>
	/// Summary description for DetailView.
	/// </summary>
	public class DetailView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlDynamicButtons;

		protected Guid        gID              ;
		protected HtmlTable   tblMain          ;
		protected PlaceHolder plcSubPanel;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Edit" )
				{
					Response.Redirect("edit.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Duplicate" )
				{
					Response.Redirect("edit.aspx?DuplicateID=" + gID.ToString());
				}
				else if ( e.CommandName == "Delete" )
				{
					SqlProcs.spCONTACTS_Delete(gID);
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
				}
				// 07/01/2019 Paul.  Perform archive lookup to see if record is archived. 
				else if ( e.CommandName == "Archive.ViewData" )
				{
					Response.Redirect("view.aspx?ID=" + gID.ToString() + "&ArchiveView=1");
				}
				// 10/10/2017 Paul.  Add Archive access right. 
				else if ( e.CommandName == "Archive.MoveData" )
				{
					ArchiveUtils archive = new ArchiveUtils(Context);
					ctlDynamicButtons.ErrorText = archive.MoveData(m_sMODULE, gID);
					if ( Sql.IsEmptyString(ctlDynamicButtons.ErrorText) )
						Response.Redirect("view.aspx?ID=" + gID.ToString() + "&ArchiveView=1");
				}
				else if ( e.CommandName == "Archive.RecoverData" )
				{
					ArchiveUtils archive = new ArchiveUtils(Context);
					ctlDynamicButtons.ErrorText = archive.RecoverData(m_sMODULE, gID);
					if ( Sql.IsEmptyString(ctlDynamicButtons.ErrorText) )
						Response.Redirect("view.aspx?ID=" + gID.ToString());
				}
				else
				{
					throw(new Exception("Unknown command: " + e.CommandName));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "view") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				// 11/28/2005 Paul.  We must always populate the table, otherwise it will disappear during event processing. 
				// 03/19/2008 Paul.  Place AppendDetailViewFields inside OnInit to avoid having to re-populate the data. 
				if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							// 02/09/2006 Paul.  SugarCRM uses the CONTACTS_USERS table to allow each user to 
							// choose the contacts they want sync'd with Outlook. 
							// 02/09/2006 Paul.  Need to allow SYNC_USER_ID to be NULL, 
							// otherwise we will not get any results if the contact is not sync'd. 
							// 03/06/2006 Paul.  The join to CONTACTS_USERS must occur external to the view. 
							// This is the only way to ensure that the record is always returned, with the sync flag set. 
							// 04/20/2006 Paul.  Use vwCONTACTS_USERS to prevent an access denied error for non-admin connections. 
							// 04/23/2006 Paul.  Bug fix.  vwCONTACTS_USERS does not have an ID, use CONTACT_ID instead. 
							// 09/18/2015 Paul.  Add SERVICE_NAME to separate Exchange Folders from Contacts Sync. 
							// 10/08/2017 Paul.  Add Archive access right. 
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							// 06/27/2018 Paul.  Add ERASED_FIELDS when data privacy enabled. 
							sSQL = "select " + m_sVIEW_NAME + ".*"                                                                        + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "view", m_sVIEW_NAME)
							     + Sql.AppendDataPrivacyField(m_sVIEW_NAME)
							     + "     , (case when vwCONTACTS_USERS.CONTACT_ID          is null then 0 else 1 end) as SYNC_CONTACT   " + ControlChars.CrLf
							     + "     , (case when vwCONTACTS_USERS_EXCHANGE.CONTACT_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf
							     + "  from            " + m_sVIEW_NAME                                                                    + ControlChars.CrLf
							     + "  left outer join vwCONTACTS_USERS                                                                  " + ControlChars.CrLf
							     + "               on vwCONTACTS_USERS.CONTACT_ID            = " + m_sVIEW_NAME + ".ID                  " + ControlChars.CrLf
							     + "              and vwCONTACTS_USERS.USER_ID               = @SYNC_USER_ID                            " + ControlChars.CrLf
							     + "              and vwCONTACTS_USERS.SERVICE_NAME is null                                             " + ControlChars.CrLf
							     + "  left outer join vwCONTACTS_USERS                         vwCONTACTS_USERS_EXCHANGE                " + ControlChars.CrLf
							     + "               on vwCONTACTS_USERS_EXCHANGE.CONTACT_ID   = " + m_sVIEW_NAME + ".ID                  " + ControlChars.CrLf
							     + "              and vwCONTACTS_USERS_EXCHANGE.USER_ID      = @SYNC_USER_ID                            " + ControlChars.CrLf
							     + "              and vwCONTACTS_USERS_EXCHANGE.SERVICE_NAME = N'Exchange'                              " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
								// 11/24/2006 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
								// 10/08/2017 Paul.  Add Archive access right. 
								Security.Filter(cmd, m_sMODULE, (ArchiveViewExists() ? "archive" : "view"));
								cmd.CommandText += "   and " + m_sVIEW_NAME + ".ID = @ID" + ControlChars.CrLf;
								Sql.AddParameter(cmd, "@ID"          , gID             );
								con.Open();

								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
										if ( dtCurrent.Rows.Count > 0 && (SplendidCRM.Security.GetRecordAccess(dtCurrent.Rows[0], m_sMODULE, "view", "ASSIGNED_USER_ID") >= 0) )
										{
											DataRow rdr = dtCurrent.Rows[0];
											// 11/11/2010 Paul.  Apply Business Rules. 
											this.ApplyDetailViewPreLoadEventRules(m_sMODULE + "." + LayoutDetailView, rdr);
											
											// 10/20/2010 Paul.  Salutation needed to be translated.  Salutation may be empty. 
											string sSALUTATION = Sql.ToString(rdr["SALUTATION"]);
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											// 06/27/2018 Paul.  Add ERASED_FIELDS when data privacy enabled. 
											ctlDynamicButtons.Title = (!Sql.IsEmptyString(sSALUTATION) ? L10n.Term(".salutation_dom." + sSALUTATION) + " " : Sql.DataPrivacyErasedField(rdr, "SALUTATION", L10n)) + Sql.DataPrivacyErasedField(rdr, "FIRST_NAME", L10n) + " " + Sql.DataPrivacyErasedField(rdr, "LAST_NAME", L10n);
											// 06/30/2018 Paul.  We don't want the erased pill in the page title. 
											string sPageTitle = L10n.Term(".moduleList." + m_sMODULE) + " - " + (!Sql.IsEmptyString(sSALUTATION) ? L10n.Term(".salutation_dom." + sSALUTATION) + " " : Sql.ToString(rdr["SALUTATION"])) + Sql.ToString(rdr["FIRST_NAME"]) + " " + Sql.ToString(rdr["LAST_NAME"]);
											SetPageTitle(sPageTitle);
											ViewState["PageTitle"] = sPageTitle;
											// 10/10/2017 Paul.  Don't update tracker in ArchiveView. 
											if ( !ArchiveView() )
												Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											
											// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
											this.AppendDetailViewRelationships(m_sMODULE + "." + LayoutDetailView, plcSubPanel);
											this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, rdr, new CommandEventHandler(Page_Command));
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											// 04/28/2008 Paul.  We will need the ASSIGNED_USER_ID in the sub-panels. 
											Page.Items["ASSIGNED_USER_ID"] = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
											// 09/08/2010 Paul.  Prefill the Account for the Opportunity. 
											Page.Items["ACCOUNT_ID"      ] = Sql.ToGuid(rdr["ACCOUNT_ID"      ]);
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 10/10/2017 Paul.  Add Archive access right. 
											int nACLACCESS_Archive = Security.GetUserAccess(m_sMODULE, "archive");
											ctlDynamicButtons.ShowButton("Archive.MoveData"   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !ArchiveView() && ArchiveEnabled());
											ctlDynamicButtons.ShowButton("Archive.RecoverData", (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) &&  ArchiveView() && ArchiveEnabled());
											// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
											ctlDynamicButtons.ShowButton("Duplicate", (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "edit"  , "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Duplicate"));
											ctlDynamicButtons.ShowButton("Edit"     , (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "edit"  , "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Edit"     ));
											ctlDynamicButtons.ShowButton("Delete"   , (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "delete", "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Delete"   ));
											// 06/28/2018 Paul.  The View Personal Info button is typicaly only visible with Data Privacy is enabled. 
											ctlDynamicButtons.ShowButton("PersonalInfo", Crm.Config.enable_data_privacy());
											// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
											ctlDynamicButtons.AppendProcessButtons(rdr);
											// 11/10/2010 Paul.  Apply Business Rules. 
											this.ApplyDetailViewPostLoadEventRules(m_sMODULE + "." + LayoutDetailView, rdr);
										}
										else
										{
											// 11/25/2006 Paul.  If item is not visible, then don't show its sub panel either. 
											plcSubPanel.Visible = false;
											
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
											// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
											// 07/01/2019 Paul.  Perform archive lookup to see if record is archived. 
											bool bRecordArchived = false;
											int nACLACCESS_Archive = Security.GetUserAccess(m_sMODULE, "archive");
											string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
											if ( (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !ArchiveView() && ArchiveEnabled() && SplendidCache.ArchiveViewExists("vw" + sTABLE_NAME) )
											{
												string sARCHIVE_VIEW = "vw" + sTABLE_NAME + "_ARCHIVE";
												using ( IDbCommand cmdArchive = con.CreateCommand() )
												{
													cmdArchive.CommandText = "select * from " + sARCHIVE_VIEW + " where ID = @ID";
													Sql.AddParameter(cmdArchive, "@ID", gID);
													((IDbDataAdapter)da).SelectCommand = cmdArchive;
													using ( DataTable dtArchive = new DataTable() )
													{
														da.Fill(dtArchive);
														if ( dtArchive.Rows.Count > 0 )
														{
															bRecordArchived = true;
															DataRow rdr = dtArchive.Rows[0];
															string sSALUTATION = Sql.ToString(rdr["SALUTATION"]);
															ctlDynamicButtons.Title = (!Sql.IsEmptyString(sSALUTATION) ? L10n.Term(".salutation_dom." + sSALUTATION) + " " : Sql.DataPrivacyErasedField(rdr, "SALUTATION", L10n)) + Sql.DataPrivacyErasedField(rdr, "FIRST_NAME", L10n) + " " + Sql.DataPrivacyErasedField(rdr, "LAST_NAME", L10n);
															string sPageTitle = L10n.Term(".moduleList." + m_sMODULE) + " - " + (!Sql.IsEmptyString(sSALUTATION) ? L10n.Term(".salutation_dom." + sSALUTATION) + " " : Sql.ToString(rdr["SALUTATION"])) + Sql.ToString(rdr["FIRST_NAME"]) + " " + Sql.ToString(rdr["LAST_NAME"]);
															SetPageTitle(sPageTitle);
															ViewState["PageTitle"] = sPageTitle;
														}
													}
												}
											}
											ctlDynamicButtons.AppendProcessButtons(null);
											ctlDynamicButtons.DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
											if ( bRecordArchived )
											{
												ctlDynamicButtons.HideAll();
												ctlDynamicButtons.ShowButton  ("Archive.ViewData", true);
												ctlDynamicButtons.EnableButton("Archive.ViewData", true);
												ctlDynamicButtons.ErrorText = L10n.Term(".LBL_ARCHIVED_RECORD");
											}
										}
									}
								}
							}
						}
					}
					else
					{
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
						// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
						ctlDynamicButtons.AppendProcessButtons(null);
						ctlDynamicButtons.DisableAll();
						//ctlDynamicButtons.ErrorText = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + "ID";
					}
				}
				else
				{
					// 06/07/2015 Paul.  Seven theme DetailView.master uses an UpdatePanel, so we need to recall the title. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					// 07/02/2018 Paul.  We don't want the erased pill in the page title. 
					SetPageTitle(Sql.ToString(ViewState["PageTitle"]));
				}
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Contacts";
			// 10/08/2017 Paul.  Add Archive access right. 
			string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
			m_sVIEW_NAME = "vw" + sTABLE_NAME;
			if ( ArchiveViewExists() )
				m_sVIEW_NAME += "_ARCHIVE";
			else
				m_sVIEW_NAME += "_Edit";
			this.LayoutDetailView = (ArchiveViewExists() ? "ArchiveView" : "DetailView");
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
				this.AppendDetailViewRelationships(m_sMODULE + "." + LayoutDetailView, plcSubPanel);
				// 12/11/2008 Paul.  Add the event handler to the detail view generator. 
				this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, null, new CommandEventHandler(Page_Command));
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
				// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
				ctlDynamicButtons.AppendProcessButtons(null);
			}
		}
		#endregion
	}
}


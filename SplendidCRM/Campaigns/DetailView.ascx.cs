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

namespace SplendidCRM.Campaigns
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

		public class SendMail
		{
			private HttpContext Context;
			private Guid        gID    ;
			private bool        bTest  ;
			
			public SendMail(HttpContext Context, Guid gID, bool bTest)
			{
				this.Context = Context;
				this.gID     = gID    ;
				this.bTest   = bTest  ;
			}
			
			// 06/16/2011 Paul.  Placing the emails in queue can take a long time, so place into a thread. 
			public void Start()
			{
				try
				{
					SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Campaign Start: " + gID.ToString() + " at " + DateTime.Now.ToString() );
					if ( !Sql.IsEmptyGuid(gID) )
					{
						Context.Application["Campaigns." + gID.ToString() + ".Sending"] = true;
						DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 08/22/2011 Paul.  We need to use the command object so that we can increase the timeout. 
									//SqlProcs.spCAMPAIGNS_SendEmail(gID, false, trn);
									using ( IDbCommand cmdCAMPAIGNS_SendEmail = SqlProcs.cmdCAMPAIGNS_SendEmail(con) )
									{
										cmdCAMPAIGNS_SendEmail.Transaction    = trn;
										cmdCAMPAIGNS_SendEmail.CommandTimeout = 0;
										Sql.SetParameter(cmdCAMPAIGNS_SendEmail, "@ID"              , gID             );
										Sql.SetParameter(cmdCAMPAIGNS_SendEmail, "@MODIFIED_USER_ID", Security.USER_ID);
										Sql.SetParameter(cmdCAMPAIGNS_SendEmail, "@TEST"            , bTest           );
										cmdCAMPAIGNS_SendEmail.ExecuteNonQuery();
									}
									trn.Commit();
								}
								catch
								{
									trn.Rollback();
									throw;
								}
							}
						}
						// 12/22/2007 Paul.  Send all queued emails, but include the date so that only these will get sent. 
						// 07/30/2012 Paul.  HttpContext.Current is not valid in a thread.  Must use Context property. 
						if ( bTest )
							EmailUtils.SendQueued(Context, Guid.Empty, gID, false);
					}
					else
					{
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Invalid Campaign ID.");
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
				}
				finally
				{
					SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Campaign End: " + gID.ToString() + " at " + DateTime.Now.ToString() );
					Context.Application.Remove("Campaigns." + gID.ToString() + ".Sending");
				}
			}
		}

		public class GenerateCalls
		{
			private HttpContext Context;
			private Guid        gID    ;
			private bool        bTest  ;
			
			public GenerateCalls(HttpContext Context, Guid gID, bool bTest)
			{
				this.Context = Context;
				this.gID     = gID    ;
				this.bTest   = bTest  ;
			}
			
			public void Start()
			{
				try
				{
					SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Campaign Start: " + gID.ToString() + " at " + DateTime.Now.ToString() );
					if ( !Sql.IsEmptyGuid(gID) )
					{
						Context.Application["Campaigns." + gID.ToString() + ".Sending"] = true;
						DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 08/22/2011 Paul.  We need to use the command object so that we can increase the timeout. 
									//SqlProcs.spCAMPAIGNS_GenerateCalls(gID, trn);
									using ( IDbCommand cmdCAMPAIGNS_GenerateCalls = SqlProcs.cmdCAMPAIGNS_GenerateCalls(con) )
									{
										cmdCAMPAIGNS_GenerateCalls.Transaction    = trn;
										cmdCAMPAIGNS_GenerateCalls.CommandTimeout = 0;
										Sql.SetParameter(cmdCAMPAIGNS_GenerateCalls, "@ID"              , gID             );
										Sql.SetParameter(cmdCAMPAIGNS_GenerateCalls, "@MODIFIED_USER_ID", Security.USER_ID);
										cmdCAMPAIGNS_GenerateCalls.ExecuteNonQuery();
									}
									trn.Commit();
								}
								catch
								{
									trn.Rollback();
									throw;
								}
							}
						}
						// 12/22/2007 Paul.  Send all queued emails, but include the date so that only these will get sent. 
						// 07/30/2012 Paul.  HttpContext.Current is not valid in a thread.  Must use Context property. 
						if ( bTest )
							EmailUtils.SendQueued(Context, Guid.Empty, gID, false);
					}
					else
					{
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Invalid Campaign ID.");
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
				}
				finally
				{
					SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Campaign End: " + gID.ToString() + " at " + DateTime.Now.ToString() );
					Context.Application.Remove("Campaigns." + gID.ToString() + ".Sending");
				}
			}
		}

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
					// 06/23/2013 Paul.  Duplicate should be a deep copy of the campaign. 
					Guid gDUPLICATE_ID = Guid.Empty;
					string sCOPY_OF = L10n.Term("Campaigns.LBL_COPY_OF");
					if ( sCOPY_OF == "Campaigns.LBL_COPY_OF" )
						sCOPY_OF = String.Empty;
					SqlProcs.spCAMPAIGNS_Duplicate(ref gDUPLICATE_ID, gID, sCOPY_OF);
					Response.Redirect("view.aspx?ID=" + gDUPLICATE_ID.ToString());
				}
				else if ( e.CommandName == "Delete" )
				{
					SqlProcs.spCAMPAIGNS_Delete(gID);
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "SendTest"  )
				{
					// 05/18/2012 Paul.  Even a test can timeout, so use thread. 
					if ( !Sql.ToBoolean(Application["Campaigns." + gID.ToString() + ".Sending"]) )
					{
						// 06/16/2011 Paul.  Placing the emails in queue can take a long time, so place into a thread. 
						// 08/22/2011 Paul.  We need to use a class so that we can pass the context and the ID. 
						SendMail send = new SendMail(this.Context, gID, true);
						System.Threading.Thread t = new System.Threading.Thread(send.Start);
						t.Start();
						// 08/22/2011 Paul.  The SendEmail thread will be aborted if we redirect the page. 
						ctlDynamicButtons.ErrorText = L10n.Term("Campaigns.LBL_SENDING");
					}
					else
					{
						ctlDynamicButtons.ErrorText = L10n.Term("Campaigns.ERR_SENDING_NOW");
					}
				}
				else if ( e.CommandName == "SendEmail" )
				{
					// 02/22/2011 Paul.  Prevent the user from Campaign running twice. 
					if ( !Sql.ToBoolean(Application["Campaigns." + gID.ToString() + ".Sending"]) )
					{
						// 06/16/2011 Paul.  Placing the emails in queue can take a long time, so place into a thread. 
						// 08/22/2011 Paul.  We need to use a class so that we can pass the context and the ID. 
						SendMail send = new SendMail(this.Context, gID, false);
						System.Threading.Thread t = new System.Threading.Thread(send.Start);
						t.Start();
						// 08/22/2011 Paul.  The SendEmail thread will be aborted if we redirect the page. 
						ctlDynamicButtons.ErrorText = L10n.Term("Campaigns.LBL_SENDING");
					}
					else
					{
						ctlDynamicButtons.ErrorText = L10n.Term("Campaigns.ERR_SENDING_NOW");
					}
				}
				// 08/27/2012 Paul.  Add CallMarketing modules. 
				else if ( e.CommandName == "GenerateCalls" )
				{
					if ( !Sql.ToBoolean(Application["Campaigns." + gID.ToString() + ".Sending"]) )
					{
						GenerateCalls send = new GenerateCalls(this.Context, gID, false);
						System.Threading.Thread t = new System.Threading.Thread(send.Start);
						t.Start();
						ctlDynamicButtons.ErrorText = L10n.Term("Campaigns.LBL_SENDING");
					}
					else
					{
						ctlDynamicButtons.ErrorText = L10n.Term("Campaigns.ERR_SENDING_NOW");
					}
				}
				// 05/14/2011 Paul.  Add support for mail merge.
				else if ( e.CommandName == "MailMerge" )
				{
					Response.Redirect("~/MailMerge/default.aspx?Module=" + m_sMODULE + "&chkMain=" + gID.ToString(), true);
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
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
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							sSQL = "select *"               + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "view", m_sVIEW_NAME)
							     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								// 11/24/2006 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
								Security.Filter(cmd, m_sMODULE, "view");
								Sql.AppendParameter(cmd, gID, "ID", false);
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
											
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											
											// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
											this.AppendDetailViewRelationships(m_sMODULE + "." + LayoutDetailView, plcSubPanel);
											this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, rdr);

											string sCAMPAIGN_TYPE = Sql.ToString(rdr["CAMPAIGN_TYPE"]);
											ViewState["CAMPAIGN_TYPE"] = sCAMPAIGN_TYPE;
											Page.Items["CAMPAIGN_TYPE"] = sCAMPAIGN_TYPE;
											//ctlDynamicButtons.ShowMailMerge = (sCAMPAIGN_TYPE == "Email");
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											// 04/28/2008 Paul.  We will need the ASSIGNED_USER_ID in the sub-panels. 
											Page.Items["ASSIGNED_USER_ID"] = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
											ctlDynamicButtons.ShowButton("Duplicate", (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "edit"  , "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Duplicate"));
											ctlDynamicButtons.ShowButton("Edit"     , (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "edit"  , "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Edit"     ));
											ctlDynamicButtons.ShowButton("Delete"   , (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "delete", "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Delete"   ));
											// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
											ctlDynamicButtons.AppendProcessButtons(rdr);
											// 04/04/2008 Paul.  Add the ROI links.
											ctlDynamicButtons.AppendLinks  (m_sMODULE + ".LinkView"  , Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 01/10/2010 Paul.  MailMerge is not supported at this time. 
											// 05/17/2011 Paul.  Enable support for Mail Merge. 
											ctlDynamicButtons.ShowButton("SendTest"  , sCAMPAIGN_TYPE == "Email");
											// 08/28/2012 Paul.  The correct button name is SendEmail, not SendEmails. 
											ctlDynamicButtons.ShowButton("SendEmail" , sCAMPAIGN_TYPE == "Email");
											ctlDynamicButtons.ShowButton("MailMerge" , sCAMPAIGN_TYPE == "Mail" || sCAMPAIGN_TYPE == "NewsLetter");
											// 08/28/2012 Paul.  Add CallMarketing modules. 
											ctlDynamicButtons.ShowButton("GenerateCalls", sCAMPAIGN_TYPE == "Telesales");
											// 11/10/2010 Paul.  Apply Business Rules. 
											this.ApplyDetailViewPostLoadEventRules(m_sMODULE + "." + LayoutDetailView, rdr);
										}
										else
										{
											// 11/25/2006 Paul.  If item is not visible, then don't show its sub panel either. 
											plcSubPanel.Visible = false;
											
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
											// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
											ctlDynamicButtons.AppendProcessButtons(null);
											// 04/04/2008 Paul.  Add the ROI links.
											ctlDynamicButtons.AppendLinks  (m_sMODULE + ".LinkView"  , Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlDynamicButtons.HideAllLinks();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
						// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
						ctlDynamicButtons.AppendProcessButtons(null);
						// 04/04/2008 Paul.  Add the ROI links.
						ctlDynamicButtons.AppendLinks  (m_sMODULE + ".LinkView"  , Guid.Empty, null);
						ctlDynamicButtons.DisableAll();
						ctlDynamicButtons.HideAllLinks();
						//ctlDynamicButtons.ErrorText = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + "ID";
					}
				}
				else
				{
					// 06/07/2015 Paul.  Seven theme DetailView.master uses an UpdatePanel, so we need to recall the title. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
					Page.Items["CAMPAIGN_TYPE"] = ViewState["CAMPAIGN_TYPE"];
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
			m_sMODULE = "Campaigns";
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			m_sVIEW_NAME = "vw" + Crm.Modules.TableName(m_sMODULE) + "_Edit";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
				this.AppendDetailViewRelationships(m_sMODULE + "." + LayoutDetailView, plcSubPanel);
				this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, null);
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
				// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
				ctlDynamicButtons.AppendProcessButtons(null);
				// 04/04/2008 Paul.  Add the ROI links.
				ctlDynamicButtons.AppendLinks  (m_sMODULE + ".LinkView"  , Guid.Empty, null);
			}
		}
		#endregion
	}
}


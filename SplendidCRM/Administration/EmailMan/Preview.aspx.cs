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
using System.Text.RegularExpressions;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.EmailMan
{
	/// <summary>
	/// Summary description for Preview.
	/// </summary>
	public class Preview : SplendidPage
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected Guid          gID              ;
		protected Label         lblError         ;
		protected Label         txtSEND_DATE_TIME;
		protected Label         txtFROM          ;
		protected Label         txtTO            ;
		protected Label         txtSUBJECT       ;
		protected Label         txtBODY_HTML     ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Delete" )
				{
					SqlProcs.spEMAILMAN_Delete(gID);
					// 12/20/2007 Paul.  Use RegisterStartupScript so that the rest of the page is rendered before the code is run. 
					Page.ClientScript.RegisterStartupScript(System.Type.GetType("System.String"), "UpdateParent", "<script type=\"text/javascript\">UpdateParent();</script>");
				}
				else if ( e.CommandName == "Send" )
				{
					EmailUtils.SendQueued(HttpContext.Current, gID, Guid.Empty, true);
					Page.ClientScript.RegisterStartupScript(System.Type.GetType("System.String"), "UpdateParent", "<script type=\"text/javascript\">UpdateParent();</script>");
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
			SetPageTitle(L10n.Term("EmailMan.LBL_LIST_FORM_TITLE"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess("EmailMan", "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				// 03/11/2008 Paul.  Move the primary binding to SplendidPage. 
				//Page DataBind();
				// 11/28/2005 Paul.  We must always populate the table, otherwise it will disappear during event processing. 
				//if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							// 01/12/2008 Paul.  Preview is different in that it does not filter on queue date. 
							sSQL = "select *                 " + ControlChars.CrLf
							     + "  from vwEMAILMAN_Preview" + ControlChars.CrLf
							     + " where 1 = 1             " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AppendParameter(cmd, gID, "ID", false);
								con.Open();

								if ( bDebug )
								{
									#pragma warning disable 618
									Page.ClientScript.RegisterClientScriptBlock(System.Type.GetType("System.String"), "SQLCode", Sql.ClientScriptBlock(cmd));
									#pragma warning restore 618
								}

								using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
								{
									if ( rdr.Read() )
									{
										// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
										ctlDynamicButtons.Title = Sql.ToString(rdr["EMAIL_MARKETING_NAME"]) + " - " + Sql.ToString(rdr["RECIPIENT_NAME"]);
										SetPageTitle(ctlDynamicButtons.Title);
										
										string sRECIPIENT_NAME  = Sql.ToString(rdr["RECIPIENT_NAME" ]);
										string sRECIPIENT_EMAIL = Sql.ToString(rdr["RECIPIENT_EMAIL"]);
										string sSUBJECT         = Sql.ToString(rdr["SUBJECT"        ]);
										string sBODY_HTML       = Sql.ToString(rdr["BODY_HTML"      ]);
										string sRELATED_TYPE    = Sql.ToString(rdr["RELATED_TYPE"   ]);
										Guid   gRELATED_ID      = Sql.ToGuid  (rdr["RELATED_ID"     ]);
										string sCAMPAIGN_NAME   = Sql.ToString(rdr["CAMPAIGN_NAME"  ]);
										Guid   gCAMPAIGN_ID     = Sql.ToGuid  (rdr["CAMPAIGN_ID"    ]);
										Guid   gMARKETING_ID    = Sql.ToGuid  (rdr["MARKETING_ID"   ]);
										string sFROM_ADDR       = Sql.ToString(rdr["EMAIL_MARKETING_FROM_ADDR"]);
										string sFROM_NAME       = Sql.ToString(rdr["EMAIL_MARKETING_FROM_NAME"]);

										// 10/11/2008 Paul.  Move email validation to a common area. 
										if ( !EmailUtils.IsValidEmail(sRECIPIENT_EMAIL) )
										{
											ctlDynamicButtons.ErrorText = L10n.Term("Campaigns.LBL_LOG_ENTRIES_INVALID_EMAIL_TITLE");
										}
										
										DataTable dtRelated = Crm.Modules.Parent(sRELATED_TYPE, gRELATED_ID);
										if ( dtRelated.Rows.Count > 0 )
										{
											// 01/20/2009 Paul.  We need to fill the emails in the correct order, otherwise $AMOUNT_TOTAL_USDOLLAR would not get replaced properly. 
											DataView  vwParentColumns = EmailUtils.SortedTableColumns(dtRelated);
											Hashtable hashCurrencyColumns = EmailUtils.CurrencyColumns(vwParentColumns);
											// 12/20/2007 Paul.  FillEmail moved to EmailUtils. 
											// 06/03/2009 Paul.  Allow the lists to be translated. 
											Hashtable hashEnumsColumns = EmailUtils.EnumColumns(Context.Application, sRELATED_TYPE);
											sSUBJECT   = EmailUtils.FillEmail(Application, sSUBJECT  , "contact", dtRelated.Rows[0], vwParentColumns, hashCurrencyColumns, hashEnumsColumns);
											sBODY_HTML = EmailUtils.FillEmail(Application, sBODY_HTML, "contact", dtRelated.Rows[0], vwParentColumns, hashCurrencyColumns, hashEnumsColumns);
										}

										Guid   gTARGET_TRACKER_KEY = Guid.NewGuid();
										string sSiteURL      = Utils.MassEmailerSiteURL(Application);
										// 06/28/2008 Paul.  The function cannot rely upon the HttpContext to get the application. 
										DataTable dtTrackers = EmailUtils.CampaignTrackers(Context, gCAMPAIGN_ID);
										// 07/16/2008 Paul.  We need to pass the Application object so that L10n_Term() can be used. 
										sBODY_HTML = EmailUtils.FillTrackers(Context, sBODY_HTML, dtTrackers, sSiteURL, gTARGET_TRACKER_KEY);

										txtSEND_DATE_TIME.Text = Sql.ToDateTime(rdr["SEND_DATE_TIME"]).ToString();
										txtFROM          .Text = sFROM_NAME      + " &lt;" + sFROM_ADDR       + "&gt;";
										txtTO            .Text = sRECIPIENT_NAME + " &lt;" + sRECIPIENT_EMAIL + "&gt;";
										txtSUBJECT       .Text = sSUBJECT  ;
										txtBODY_HTML     .Text = sBODY_HTML;
									}
								}
							}
						}
					}
				}
				if ( !IsPostBack )
				{
					ctlDynamicButtons.AppendButtons("EmailMan.Preview", Guid.Empty, Guid.Empty);
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("EmailMan.Preview", Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}


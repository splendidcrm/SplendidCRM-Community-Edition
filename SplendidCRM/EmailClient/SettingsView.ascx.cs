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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.EmailClient
{
	/// <summary>
	///		Summary description for SettingsView.
	/// </summary>
	public class SettingsView : SplendidControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;

		// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
		//private const string      sEMPTY_PASSWORD = "**********";
		protected string          sSERVICE        = "imap"      ;
		protected Guid            gID                           ;
		protected HtmlTable       tblMain                       ;

		public string Service
		{
			get { return sSERVICE; }
			set { sSERVICE = value; }
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				try
				{
					this.ValidateEditViewFields(m_sMODULE + ".EditView");
					if ( Page.IsValid )
					{
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);

						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								sSQL = "select *                    " + ControlChars.CrLf
								     + "  from vwINBOUND_EMAILS_Edit" + ControlChars.CrLf
								     + " where ID = @ID             " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@ID", gID);
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											rowCurrent = dtCurrent.Rows[0];
										}
										else
										{
											gID = Guid.Empty;
										}
									}
								}
							}
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									string sEMAIL_PASSWORD = new DynamicControl(this, "EMAIL_PASSWORD").Text;
									// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
									if ( sEMAIL_PASSWORD == Sql.sEMPTY_PASSWORD )
									{
										if ( rowCurrent != null )
											sEMAIL_PASSWORD = Sql.ToString(rowCurrent["EMAIL_PASSWORD"]);
										else
											sEMAIL_PASSWORD = "";
									}
									else
									{
										string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
										if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sEMAIL_PASSWORD )
											throw(new Exception("Decryption failed"));
										sEMAIL_PASSWORD = sENCRYPTED_EMAIL_PASSWORD;
									}
									// 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
									SqlProcs.spINBOUND_EMAILS_Update
										( ref gID
										, new DynamicControl(this, rowCurrent, "NAME"          ).Text
										, "Active"  // 07/16/2010 Paul.  STATUS is always active. 
										, new DynamicControl(this, rowCurrent, "SERVER_URL"    ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL_USER"    ).Text
										, sEMAIL_PASSWORD
										, Sql.ToInteger(new DynamicControl(this, rowCurrent, "PORT").Text)
										, new DynamicControl(this, rowCurrent, "MAILBOX_SSL"   ).Checked
										, sSERVICE
										, new DynamicControl(this, rowCurrent, "MAILBOX"       ).Text
										, true    // 07/17/2010 Paul.  MARK_READ will not likely be used. 
										, new DynamicControl(this, rowCurrent, "ONLY_SINCE"    ).Checked
										, "pick"  // 07/16/2010 Paul.  MAILBOX_TYPE will be pick. 
										, new DynamicControl(this, rowCurrent, "TEMPLATE_ID"   ).ID
										, Security.USER_ID  // 07/16/2010 Paul.  GROUP_ID will always be this user. 
										, new DynamicControl(this, rowCurrent, "FROM_NAME"     ).Text
										, new DynamicControl(this, rowCurrent, "FROM_ADDR"     ).Text
										, new DynamicControl(this, rowCurrent, "FILTER_DOMAIN" ).Text
										, true // 04/19/2011 Paul.  Add IS_PERSONAL to exclude EmailClient inbound from being included in monitored list. 
										, new DynamicControl(this, rowCurrent, "REPLY_TO_NAME" ).Text
										, new DynamicControl(this, rowCurrent, "REPLY_TO_ADDR" ).Text
										// 01/28/2017 Paul.  TEAM_ID for inbound emails.  Use team of current user. 
										, Security.TEAM_ID
										, trn
										);
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
						}
						Response.Redirect("default.aspx");
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("default.aspx");
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				if ( !IsPostBack )
				{
					// 01/24/2013 Paul.  Change view name to just SettingsView. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + ".SettingsView", Guid.Empty, null);

					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL ;
						sSQL = "select *                    " + ControlChars.CrLf
						     + "  from vwINBOUND_EMAILS_Edit" + ControlChars.CrLf
						     + " where GROUP_ID = @GROUP_ID " + ControlChars.CrLf
						     + "   and SERVICE  = @SERVICE  " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@GROUP_ID", Security.USER_ID);
							Sql.AddParameter(cmd, "@SERVICE" , sSERVICE);

							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

							// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dtCurrent = new DataTable() )
								{
									da.Fill(dtCurrent);
									if ( dtCurrent.Rows.Count > 0 )
									{
										DataRow rdr = dtCurrent.Rows[0];
										gID = Sql.ToGuid(rdr["ID"]);
										ViewState["ID"] = gID;
										// 01/24/2013 Paul.  Change view name to just SettingsView. 
										this.AppendEditViewFields(m_sMODULE + ".SettingsView", tblMain, rdr);
										if ( !Sql.IsEmptyString(rdr["EMAIL_PASSWORD"]) )
										{
											TextBox txtEMAIL_PASSWORD = FindControl("EMAIL_PASSWORD") as TextBox;
											if ( txtEMAIL_PASSWORD != null )
											{
												// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
												txtEMAIL_PASSWORD.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
											}
										}
									}
									else
									{
										// 01/24/2013 Paul.  Change view name to just SettingsView. 
										this.AppendEditViewFields(m_sMODULE + ".SettingsView", tblMain, null);
										// 07/16/2010 Paul.  MAILBOX default should be INBOX. 
										new DynamicControl(this, "MAILBOX").Text = "INBOX" ;
										new DynamicControl(this, "SERVICE").Text = sSERVICE;
										new DynamicControl(this, "PORT"   ).Text = "143"   ;
									}
								}
							}
						}
					}
				}
				else
				{
					gID = Sql.ToGuid(ViewState["ID"]);
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
			// CODEGEN: This Task is required by the ASP.NET Web Form Designer.
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
			// 01/24/2013 Paul.  This module should be EmailClient, not InboundEmail. 
			m_sMODULE = "EmailClient";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 01/24/2013 Paul.  Change view name to just SettingsView. 
				this.AppendEditViewFields(m_sMODULE + ".SettingsView", tblMain, null);
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".SettingsView", Guid.Empty, null);
			}
		}
		#endregion
	}
}


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
using System.IO;
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

using MimeKit;
using MailKit;
using MailKit.Net.Pop3;
using MailKit.Net.Imap;

namespace SplendidCRM.Administration.InboundEmail
{
	/// <summary>
	///		Summary description for Mailbox.
	/// </summary>
	public class Mailbox : SplendidControl
	{
		// 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
		protected _controls.SubPanelButtons ctlDynamicButtons;
		protected Guid            gID            ;
		protected DataTable       dtMain         ;
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected Label           lblError       ;
		protected StringBuilder   sbTrace        ;

		protected void Pop3Trace(string sText)
		{
			sbTrace.AppendLine(sText);
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				sbTrace = new StringBuilder();
				if ( e.CommandName == "Mailbox.CheckBounce" )
				{
					EmailUtils.CheckInbound(HttpContext.Current, gID, true);
				}
				else if ( e.CommandName == "Mailbox.CheckInbound" )
				{
					EmailUtils.CheckInbound(HttpContext.Current, gID, false);
				}
				if ( e.CommandName == "Mailbox.CheckMail" || e.CommandName == "Mailbox.CheckBounce" || e.CommandName == "Mailbox.CheckInbound" )
				{
					string sSERVER_URL     = Sql.ToString (ViewState["SERVER_URL"    ]);
					string sEMAIL_USER     = Sql.ToString (ViewState["EMAIL_USER"    ]);
					string sEMAIL_PASSWORD = Sql.ToString (ViewState["EMAIL_PASSWORD"]);
					int    nPORT           = Sql.ToInteger(ViewState["PORT"          ]);
					string sSERVICE        = Sql.ToString (ViewState["SERVICE"       ]);
					bool   bMAILBOX_SSL    = Sql.ToBoolean(ViewState["MAILBOX_SSL"   ]);
					string sMAILBOX        = Sql.ToString (ViewState["MAILBOX"       ]);
					// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
					bool bOFFICE365_OAUTH_ENABLED  = Sql.ToBoolean(ViewState["OFFICE365_OAUTH_ENABLED" ]);
					bool bGOOGLEAPPS_OAUTH_ENABLED = Sql.ToBoolean(ViewState["GOOGLEAPPS_OAUTH_ENABLED"]);

					dtMain = new DataTable();
					dtMain.Columns.Add("From"        , typeof(System.String  ));
					dtMain.Columns.Add("Sender"      , typeof(System.String  ));
					dtMain.Columns.Add("ReplyTo"     , typeof(System.String  ));
					dtMain.Columns.Add("To"          , typeof(System.String  ));
					dtMain.Columns.Add("CC"          , typeof(System.String  ));
					dtMain.Columns.Add("Bcc"         , typeof(System.String  ));
					dtMain.Columns.Add("Subject"     , typeof(System.String  ));
					dtMain.Columns.Add("DeliveryDate", typeof(System.DateTime));
					dtMain.Columns.Add("Priority"    , typeof(System.String  ));
					dtMain.Columns.Add("Size"        , typeof(System.Int32   ));
					dtMain.Columns.Add("ContentID"   , typeof(System.String  ));
					dtMain.Columns.Add("MessageID"   , typeof(System.String  ));
					dtMain.Columns.Add("Headers"     , typeof(System.String  ));

					// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
					if ( bOFFICE365_OAUTH_ENABLED )
					{
						// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
						Spring.Social.Office365.Office365Sync.UserSync User = new Spring.Social.Office365.Office365Sync.UserSync(Context, String.Empty, String.Empty, String.Empty, String.Empty, gID, false, bOFFICE365_OAUTH_ENABLED);
						string sFOLDER_ID = Office365Utils.GetFolderId(Context, String.Empty, String.Empty, gID, sMAILBOX);
						if ( Sql.IsEmptyString(sFOLDER_ID) )
							throw(new Exception("Could not find folder " + sMAILBOX));
						
						DataTable dt = Office365Utils.GetFolderMessages(User, sFOLDER_ID, 200, 0, "DATE_START", "desc");
						foreach ( DataRow row in dt.Rows )
						{
							DataRow rowMain = dtMain.NewRow();
							dtMain.Rows.Add(rowMain);
							rowMain["From"        ] = row["FROM"            ];
							rowMain["Sender"      ] = String.Empty;
							rowMain["ReplyTo"     ] = String.Empty;
							rowMain["To"          ] = row["TO_ADDRS"        ];
							rowMain["CC"          ] = row["CC_ADDRS"        ];
							rowMain["Bcc"         ] = String.Empty;
							rowMain["Subject"     ] = row["NAME"            ];
							rowMain["DeliveryDate"] = row["DATE_START"      ];
							rowMain["Priority"    ] = String.Empty;
							rowMain["Size"        ] = row["SIZE"            ];
							rowMain["ContentID"   ] = row["UNIQUE_ID"       ];
							rowMain["MessageID"   ] = row["MESSAGE_ID"      ];
							rowMain["Headers"     ] = row["INTERNET_HEADERS"];
						}
					}
					// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
					else if ( String.Compare(sSERVICE, "Exchange-Password", true) == 0 )
					{
						try
						{
							ExchangeSync.UserSync User = new ExchangeSync.UserSync(Context, String.Empty, String.Empty, sEMAIL_USER, sEMAIL_PASSWORD, Guid.Empty, String.Empty, false, false);
							string sFOLDER_ID = ExchangeUtils.GetFolderId(Context, sEMAIL_USER, sEMAIL_PASSWORD, Guid.Empty, sMAILBOX);
							if ( Sql.IsEmptyString(sFOLDER_ID) )
								throw(new Exception("Could not find folder " + sMAILBOX));
						
							DataTable dt = ExchangeUtils.GetFolderMessages(User, sFOLDER_ID, 200, 0, "DATE_START", "desc");
							foreach ( DataRow row in dt.Rows )
							{
								DataRow rowMain = dtMain.NewRow();
								dtMain.Rows.Add(rowMain);
								rowMain["From"        ] = row["FROM"            ];
								rowMain["Sender"      ] = String.Empty;
								rowMain["ReplyTo"     ] = String.Empty;
								rowMain["To"          ] = row["TO_ADDRS"        ];
								rowMain["CC"          ] = row["CC_ADDRS"        ];
								rowMain["Bcc"         ] = String.Empty;
								rowMain["Subject"     ] = row["NAME"            ];
								rowMain["DeliveryDate"] = row["DATE_START"      ];
								rowMain["Priority"    ] = String.Empty;
								rowMain["Size"        ] = row["SIZE"            ];
								rowMain["ContentID"   ] = row["UNIQUE_ID"       ];
								rowMain["MessageID"   ] = row["MESSAGE_ID"      ];
								rowMain["Headers"     ] = row["INTERNET_HEADERS"];
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							ctlDynamicButtons.ErrorText = ex.Message;
						}
					}
					else if ( bGOOGLEAPPS_OAUTH_ENABLED )
					{
						DataTable dt = GoogleApps.GetFolderMessages(Context, gID, sMAILBOX, false, 0, 200);
						foreach ( DataRow row in dt.Rows )
						{
							DataRow rowMain = dtMain.NewRow();
							dtMain.Rows.Add(rowMain);
							rowMain["From"        ] = row["FROM"            ];
							rowMain["Sender"      ] = String.Empty;
							rowMain["ReplyTo"     ] = String.Empty;
							rowMain["To"          ] = row["TO_ADDRS"        ];
							rowMain["CC"          ] = row["CC_ADDRS"        ];
							rowMain["Bcc"         ] = String.Empty;
							rowMain["Subject"     ] = row["NAME"            ];
							rowMain["DeliveryDate"] = row["DATE_START"      ];
							rowMain["Priority"    ] = String.Empty;
							rowMain["Size"        ] = row["SIZE"            ];
							rowMain["ContentID"   ] = row["UNIQUE_ID"       ];
							rowMain["MessageID"   ] = row["MESSAGE_ID"      ];
							rowMain["Headers"     ] = row["INTERNET_HEADERS"];
						}
					}
					// 10/28/2010 Paul.  Add support for IMAP. 
					else if ( String.Compare(sSERVICE, "imap", true) == 0 )
					{
						// 01/08/2008 Paul.  Decrypt at the last minute to ensure that an unencrypted password is never sent to the browser. 
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						sEMAIL_PASSWORD = Security.DecryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						try
						{
							if ( Sql.IsEmptyString(sMAILBOX) )
								sMAILBOX = "INBOX";
							//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
							using ( ImapClient imap = new ImapClient() )
							{
								imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
								imap.AuthenticationMechanisms.Remove ("XOAUTH2");
								// 01/22/2017 Paul.  There is a bug with NTLM. 
								// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
								imap.AuthenticationMechanisms.Remove ("NTLM");
								imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
								IMailFolder mailbox = imap.GetFolder(sMAILBOX);
								if ( mailbox != null )
								{
									mailbox.Open(FolderAccess.ReadOnly);
									// 01/21/2017 Paul.  Limit the messages to 200 to prevent a huge loop. 
									int nStartIndex = Math.Max(mailbox.Count - 200, 0);
									// All is a macro for Envelope, Flags, InternalDate, and MessageSize. 
									IList<IMessageSummary> lstMessages = mailbox.Fetch(nStartIndex, -1, MessageSummaryItems.All | MessageSummaryItems.UniqueId);
									for ( int i = 0; i < lstMessages.Count ; i++ )
									{
										IMessageSummary summary = lstMessages[i];
										string sHeaders = String.Empty;
										if ( summary.Headers != null )
										{
											using ( MemoryStream mem = new MemoryStream() )
											{
												summary.Headers.WriteTo(mem);
												mem.Position = 0;
												using ( StreamReader rdr = new StreamReader(mem) )
												{
													sHeaders = rdr.ReadToEnd();
												}
											}
										}
										
										DataRow row = dtMain.NewRow();
										dtMain.Rows.Add(row);
										row["From"        ] = Server.HtmlEncode(summary.Envelope.From    != null ? summary.Envelope.From   .ToString() : String.Empty);
										row["Sender"      ] = Server.HtmlEncode(summary.Envelope.Sender  != null ? summary.Envelope.Sender .ToString() : String.Empty);
										row["ReplyTo"     ] = Server.HtmlEncode(summary.Envelope.ReplyTo != null ? summary.Envelope.ReplyTo.ToString() : String.Empty);
										row["To"          ] = Server.HtmlEncode(summary.Envelope.To      != null ? summary.Envelope.To     .ToString() : String.Empty);
										row["CC"          ] = Server.HtmlEncode(summary.Envelope.Cc      != null ? summary.Envelope.Cc     .ToString() : String.Empty);
										row["Bcc"         ] = Server.HtmlEncode(summary.Envelope.Bcc     != null ? summary.Envelope.Bcc    .ToString() : String.Empty);
										row["Subject"     ] = Server.HtmlEncode(summary.Envelope.Subject);
										// 01/23/2008 Paul.  DateTime in the email is in universal time. 
										row["DeliveryDate"] = summary.Date.DateTime.ToLocalTime();
										row["Priority"    ] = DBNull.Value;
										if ( summary.Size.HasValue )
											row["Size"    ] = summary.Size;
										row["ContentId"   ] = DBNull.Value;
										row["MessageId"   ] = summary.Envelope.MessageId;
										row["Headers"     ] = "<pre>" + Server.HtmlEncode(sHeaders) + "</pre>";
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
					else if ( String.Compare(sSERVICE, "pop3", true) == 0 )
					{
						// 01/08/2008 Paul.  Decrypt at the last minute to ensure that an unencrypted password is never sent to the browser. 
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						sEMAIL_PASSWORD = Security.DecryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						
						//Pop3.Pop3MimeClient pop = new Pop3.Pop3MimeClient(sSERVER_URL, nPORT, bMAILBOX_SSL, sEMAIL_USER, sEMAIL_PASSWORD);
						try
						{
							using ( Pop3Client pop = new Pop3Client() )
							{
								pop.Timeout = 60 * 1000; //give pop server 60 seconds to answer
								pop.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
								pop.AuthenticationMechanisms.Remove ("XOAUTH2");
								pop.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
								
								int nTotalEmails = pop.Count;
								int nStartIndex  = nTotalEmails - 200;
								if ( nStartIndex < 0 )
									nStartIndex = 0;
								IList<int> lstMessageSizes = pop.GetMessageSizes();
								// 01/22/2017 Paul.  Get headers only. 
								IList<Stream> lstHeaders = pop.GetStreams(nStartIndex, nTotalEmails - nStartIndex, true);
								for ( int i = 0; i < lstHeaders.Count; i++ )
								{
									string sRawContent = String.Empty;
									MimeMessage mm = MimeMessage.Load(lstHeaders[i]);
									using ( MemoryStream mem = new MemoryStream() )
									{
										mm.WriteTo(mem);
										mem.Position = 0;
										using ( StreamReader rdr = new StreamReader(mem) )
										{
											sRawContent = rdr.ReadToEnd();
										}
									}
									
									DataRow row = dtMain.NewRow();
									dtMain.Rows.Add(row);
									if ( mm.From    != null ) row["From"        ] = Server.HtmlEncode(mm.From   .ToString());
									if ( mm.Sender  != null ) row["Sender"      ] = Server.HtmlEncode(mm.Sender .ToString());
									if ( mm.ReplyTo != null ) row["ReplyTo"     ] = Server.HtmlEncode(mm.ReplyTo.ToString());
									if ( mm.To      != null ) row["To"          ] = Server.HtmlEncode(mm.To     .ToString());
									if ( mm.Cc      != null ) row["CC"          ] = Server.HtmlEncode(mm.Cc     .ToString());
									if ( mm.Bcc     != null ) row["Bcc"         ] = Server.HtmlEncode(mm.Bcc    .ToString());
									if ( mm.Subject != null ) row["Subject"     ] = Server.HtmlEncode(mm.Subject);
									if ( mm.Date    != null ) row["DeliveryDate"] = T10n.FromUniversalTime(mm.Date.DateTime);
									row["Priority"    ] = mm.Priority.ToString();
									if ( nStartIndex + i < lstMessageSizes.Count )
										row["Size"        ] = lstMessageSizes[nStartIndex + i];
									row["MessageId"   ] = mm.MessageId   ;
									row["Headers"     ] = "<pre>" + Server.HtmlEncode(sRawContent) + "</pre>";
									//row["ContentId"   ] = mm.ContentId   ;
									//row["Body"        ] = mm.Body        ;
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							ctlDynamicButtons.ErrorText = ex.Message;
						}
					}
					ViewState["Inbox"] = dtMain;
					vwMain = new DataView(dtMain);
					grdMain.DataSource = vwMain;
					grdMain.DataBind();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
			finally
			{
#if DEBUG
				RegisterClientScriptBlock("Pop3Trace", "<script type=\"text/javascript\">sDebugSQL += '" + Sql.EscapeJavaScript(sbTrace.ToString()) + "';</script>");
#endif
				}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;
			
			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					ctlDynamicButtons.AppendButtons(m_sMODULE + ".Mailbox", Guid.Empty, Guid.Empty);

					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL;
						sSQL = "select *                    " + ControlChars.CrLf
						     + "  from vwINBOUND_EMAILS_Edit" + ControlChars.CrLf
						     + " where ID = @ID             " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", gID);
							con.Open();

							if ( bDebug )
								RegisterClientScriptBlock("vwINBOUND_EMAILS_Edit", Sql.ClientScriptBlock(cmd));

							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									string sSERVER_URL     = Sql.ToString (rdr["SERVER_URL"    ]);
									string sEMAIL_USER     = Sql.ToString (rdr["EMAIL_USER"    ]);
									string sEMAIL_PASSWORD = Sql.ToString (rdr["EMAIL_PASSWORD"]);
									int    nPORT           = Sql.ToInteger(rdr["PORT"          ]);
									string sSERVICE        = Sql.ToString (rdr["SERVICE"       ]);
									bool   bMAILBOX_SSL    = Sql.ToBoolean(rdr["MAILBOX_SSL"   ]);
									string sMAILBOX        = Sql.ToString (rdr["MAILBOX"       ]);
									
									ViewState["SERVER_URL"    ] = sSERVER_URL    ;
									ViewState["EMAIL_USER"    ] = sEMAIL_USER    ;
									ViewState["EMAIL_PASSWORD"] = sEMAIL_PASSWORD;
									ViewState["PORT"          ] = nPORT          ;
									ViewState["SERVICE"       ] = sSERVICE       ;
									ViewState["MAILBOX_SSL"   ] = bMAILBOX_SSL   ;
									// 04/21/2011 Paul.  We need the mailbox for Imap tests. 
									ViewState["MAILBOX"       ] = sMAILBOX       ;
									// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
									ViewState["OFFICE365_OAUTH_ENABLED" ] = Sql.ToBoolean(rdr["OFFICE365_OAUTH_ENABLED" ]);
									ViewState["GOOGLEAPPS_OAUTH_ENABLED"] = Sql.ToBoolean(rdr["GOOGLEAPPS_OAUTH_ENABLED"]);
								}
							}
						}
					}
				}
				else
				{
					if ( ViewState["Inbox"] != null )
					{
						dtMain = ViewState["Inbox"] as DataTable;
					}
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "InboundEmail";
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".Mailbox", Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}


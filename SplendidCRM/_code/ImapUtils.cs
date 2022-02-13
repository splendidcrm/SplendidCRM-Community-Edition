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
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.SessionState;
using System.Xml;
using System.Diagnostics;

using MimeKit;
using MailKit;
using MailKit.Net.Imap;

namespace SplendidCRM
{
	public class ImapUtils
	{
		public static bool Validate(HttpContext Context, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD, string sFOLDER_ID, StringBuilder sbErrors)
		{
			bool bValid = false;
			try
			{
				if ( Sql.IsEmptyString(sFOLDER_ID) )
					sFOLDER_ID = "INBOX";
				//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
				using ( ImapClient imap = new ImapClient() )
				{
					imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
					imap.AuthenticationMechanisms.Remove ("XOAUTH2");
					// 01/22/2017 Paul.  There is a bug with NTLM. 
					// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
					imap.AuthenticationMechanisms.Remove ("NTLM");
					imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
					
					IMailFolder mailbox = imap.GetFolder(sFOLDER_ID);
					if ( mailbox != null && mailbox.Exists )
					{
						// 12/13/2017 Paul.  The mailbox should be opened in order to get the count. 
						mailbox.Open(FolderAccess.ReadOnly);
						// 08/09/2018 Paul.  Allow translation of connection success. 
						string sCULTURE = Sql.ToString(Context.Application["CONFIG.default_language"]);
						if ( Context.Session != null )
							sCULTURE = Sql.ToString (Context.Session["USER_SETTINGS/CULTURE"]);
						sbErrors.AppendLine(String.Format(L10N.Term(Context.Application, sCULTURE, "Users.LBL_CONNECTION_SUCCESSFUL"), mailbox.Count.ToString(), "Inbox"));
						//sbErrors.AppendLine("Connection successful. ");
						//sbErrors.AppendLine(mailbox.Count.ToString() + " items in Inbox. ");
						//sbErrors.AppendLine(mailbox.Unread.ToString() + " unread items in Inbox. ");
						sbErrors.AppendLine("<br />");
						bValid = true;
					}
				}
			}
			catch(Exception ex)
			{
				sbErrors.AppendLine(ex.Message);
			}
			return bValid;
		}

		private static void UpdateFolderTreeNodeCounts(ImapClient imap, XmlNode xFolder)
		{
			foreach ( XmlNode xChild in xFolder.ChildNodes )
			{
				int nTotalCount  = 0;
				int nUnreadCount = 0;
				string sMailbox = XmlUtil.GetNamedItem(xChild, "Id"  );
				string sName    = XmlUtil.GetNamedItem(xChild, "Name");
				IMailFolder mailbox = imap.GetFolder(sMailbox);
				// 07/17/2010 Paul.  The [Gmail] folder will not return a mailbox. 
				if ( mailbox != null )
				{
					nTotalCount  = mailbox.Count ;
					nUnreadCount = mailbox.Unread;
				}

				XmlUtil.SetSingleNodeAttribute(xFolder.OwnerDocument, xChild, "TotalCount" , nTotalCount .ToString());
				XmlUtil.SetSingleNodeAttribute(xFolder.OwnerDocument, xChild, "UnreadCount", nUnreadCount.ToString());
				if ( nUnreadCount > 0 )
					XmlUtil.SetSingleNodeAttribute(xFolder.OwnerDocument, xChild, "DisplayName", "<b>" + sName + "</b> <font color=blue>(" + nUnreadCount.ToString() + ")</font>");
				else
					XmlUtil.SetSingleNodeAttribute(xFolder.OwnerDocument, xChild, "DisplayName", sName);
			}
		}

		public static void UpdateFolderTreeNodeCounts(HttpContext Context, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD, XmlNode xFolder)
		{
			//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
			using ( ImapClient imap = new ImapClient() )
			{
				imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
				imap.AuthenticationMechanisms.Remove ("XOAUTH2");
				// 01/22/2017 Paul.  There is a bug with NTLM. 
				// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
				imap.AuthenticationMechanisms.Remove ("NTLM");
				imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
				
				UpdateFolderTreeNodeCounts(imap, xFolder);
			}
		}

		private static void GetFolderTreeFromResults(ImapClient imap, XmlNode xParent, IMailFolder fResults)
		{
			XmlDocument xml = xParent.OwnerDocument;
			if ( fResults.Exists )
			{
				foreach ( IMailFolder fld in fResults.GetSubfolders(/* StatusItems.Count | StatusItems.Unread | StatusItems.Recent*/) )
				{
					XmlElement xChild = xml.CreateElement("Folder");
					xParent.AppendChild(xChild);
				
					XmlUtil.SetSingleNodeAttribute(xml, xChild, "Id"         , fld.FullName.ToString());
					XmlUtil.SetSingleNodeAttribute(xml, xChild, "TotalCount" , fld.Count   .ToString());
					XmlUtil.SetSingleNodeAttribute(xml, xChild, "UnreadCount", fld.Unread  .ToString());
					// 07/30/2010 Paul.  We need to separate the Name from the DisplayName due to the formatting differences. 
					XmlUtil.SetSingleNodeAttribute(xml, xChild, "Name"       , fld.Name);
					XmlUtil.SetSingleNodeAttribute(xml, xChild, "DisplayName", fld.Name);
					if ( (fld.Attributes & FolderAttributes.HasChildren) == FolderAttributes.HasChildren )
					{
						GetFolderTreeFromResults(imap, xChild, fld);
					}
				}
			}
		}

		public static XmlDocument GetFolderTree(HttpContext Context, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD)
		{
			XmlDocument xml = new XmlDocument();
			xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xml.AppendChild(xml.CreateElement("Folders"));
			XmlUtil.SetSingleNodeAttribute(xml, xml.DocumentElement, "Id"         , String.Empty              );
			XmlUtil.SetSingleNodeAttribute(xml, xml.DocumentElement, "DisplayName", "Mailbox - " + sEMAIL_USER);
			
			//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
			using ( ImapClient imap = new ImapClient() )
			{
				imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
				imap.AuthenticationMechanisms.Remove ("XOAUTH2");
				// 01/22/2017 Paul.  There is a bug with NTLM. 
				// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
				imap.AuthenticationMechanisms.Remove ("NTLM");
				imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
				
				IMailFolder root = imap.GetFolder(imap.PersonalNamespaces[0]);
				GetFolderTreeFromResults(imap, xml.DocumentElement, root);
				UpdateFolderTreeNodeCounts(imap, xml.DocumentElement);
			}
			return xml;
		}

		public static void GetFolderCount(HttpContext Context, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD, string sFOLDER_ID, ref int nTotalCount, ref int nUnreadCount)
		{
			//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
			using ( ImapClient imap = new ImapClient() )
			{
				imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
				imap.AuthenticationMechanisms.Remove ("XOAUTH2");
				// 01/22/2017 Paul.  There is a bug with NTLM. 
				// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
				imap.AuthenticationMechanisms.Remove ("NTLM");
				imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);

				IMailFolder mailbox = imap.GetFolder(sFOLDER_ID);
				if ( mailbox != null && mailbox.Exists )
				{
					nTotalCount  = mailbox.Count ;
					nUnreadCount = mailbox.Unread;
					
				}
			}
		}

		public static void DeleteMessage(HttpContext Context, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD, string sFOLDER_ID, string sUNIQUE_ID)
		{
			//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
			using ( ImapClient imap = new ImapClient() )
			{
				imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
				imap.AuthenticationMechanisms.Remove ("XOAUTH2");
				// 01/22/2017 Paul.  There is a bug with NTLM. 
				// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
				imap.AuthenticationMechanisms.Remove ("NTLM");
				imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);

				IMailFolder mailbox = imap.GetFolder(sFOLDER_ID);
				if ( mailbox != null && mailbox.Exists )
				{
					mailbox.Open(FolderAccess.ReadWrite);
					MailKit.UniqueId uid = new MailKit.UniqueId((uint) Sql.ToInteger(sUNIQUE_ID));
					mailbox.AddFlags(uid, MessageFlags.Deleted, true);
				}
			}
		}

		public static DataTable GetMessage(HttpContext Context, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD, string sFOLDER_ID, string sUNIQUE_ID)
		{
			DataTable dt = MimeUtils.CreateMessageTable();
			DataRow row = dt.NewRow();
			dt.Rows.Add(row);
			
			//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
			using ( ImapClient imap = new ImapClient() )
			{
				imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
				imap.AuthenticationMechanisms.Remove ("XOAUTH2");
				// 01/22/2017 Paul.  There is a bug with NTLM. 
				// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
				imap.AuthenticationMechanisms.Remove ("NTLM");
				imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
				
				if ( Sql.IsEmptyString(sFOLDER_ID) )
					sFOLDER_ID = "INBOX";
				
				IMailFolder mailbox = imap.GetFolder(sFOLDER_ID);
				if ( mailbox != null && mailbox.Exists )
				{
					mailbox.Open(FolderAccess.ReadOnly);
					MailKit.UniqueId uid = new MailKit.UniqueId((uint) Sql.ToInteger(sUNIQUE_ID));
					//MimeMessage email = mailbox.GetMessage(uid);
					// 01/23/2017 Paul.  Need BodyStructure to get attachment info. 
					IList<IMessageSummary> summeries = mailbox.Fetch(new List<MailKit.UniqueId>() { uid }, MessageSummaryItems.All | MessageSummaryItems.BodyStructure | MessageSummaryItems.UniqueId);
					if ( summeries != null && summeries.Count > 0 )
					{
						IMessageSummary summary = summeries[0];
						double dSize = (summary.Size.HasValue ? (double) summary.Size : 0);
						string sSize = String.Empty;
						if ( dSize < 1024 )
							sSize = dSize.ToString() + " B";
						else if ( dSize < 1024 * 1024 )
							sSize = Math.Floor(dSize / 1024).ToString() + " KB";
						else
							sSize = Math.Floor(dSize / (1024 * 1024)).ToString() + " MB";
						
						row["ID"                    ] = Guid.NewGuid().ToString().Replace('-', '_');
						row["UNIQUE_ID"             ] = summary.UniqueId.Id                ;
						row["SIZE"                  ] = summary.Size                       ;
						row["SIZE_STRING"           ] = sSize                              ;
						if ( summary.Flags.HasValue )
							row["IS_READ"           ] = ((summary.Flags.Value & MessageFlags.Seen) == MessageFlags.Seen);
						row["TO_ADDRS"              ] = (summary.Envelope.To != null ? summary.Envelope.To.ToString() : String.Empty);
						row["CC_ADDRS"              ] = (summary.Envelope.Cc != null ? summary.Envelope.Cc.ToString() : String.Empty);
						row["NAME"                  ] = summary.Envelope.Subject           ;
						row["MESSAGE_ID"            ] = summary.Envelope.MessageId         ;
						row["DATE_MODIFIED"         ] = summary.Date.DateTime.ToLocalTime();
						row["DATE_ENTERED"          ] = summary.Date.DateTime.ToLocalTime();
						row["DATE_START"            ] = summary.Date.DateTime.ToLocalTime();
						if ( summary.Envelope.From != null )
						{
							string sFROM_ADDR = String.Empty;
							string sFROM_NAME = String.Empty;
							foreach ( InternetAddress from in summary.Envelope.From )
							{
								if ( from is MailboxAddress )
								{
									MailboxAddress addr = from as MailboxAddress;
									sFROM_ADDR += addr.Address;
									sFROM_NAME += addr.Name   ;
									break;
								}
							}
							row["FROM"      ] = summary.Envelope.From.ToString();
							row["FROM_ADDR" ] = sFROM_ADDR;
							row["FROM_NAME" ] = sFROM_NAME;
						}
						
						XmlDocument xmlInternetHeaders = new XmlDocument();
						xmlInternetHeaders.AppendChild(xmlInternetHeaders.CreateElement("Headers"));
						MimeMessage email = mailbox.GetMessage(summary.UniqueId);
						for ( int i = 0; i < email.Headers.Count; i++ )
						{
							XmlElement xHeader = xmlInternetHeaders.CreateElement("Header");
							xmlInternetHeaders.DocumentElement.AppendChild(xHeader);
							XmlElement xName  = xmlInternetHeaders.CreateElement("Name" );
							XmlElement xValue = xmlInternetHeaders.CreateElement("Value");
							xHeader.AppendChild(xName );
							xHeader.AppendChild(xValue);
							xName .InnerText = email.Headers[i].Field;
							xValue.InnerText = email.Headers[i].Value;
						}
						row["INTERNET_HEADERS"] = xmlInternetHeaders.OuterXml;
						
						// 01/21/2017 Paul.  Only get the body values once as they may be computed. 
						// http://www.mimekit.net/docs/html/WorkingWithMessages.htm
						string sTextBody = email.TextBody;
						string sHtmlBody = email.HtmlBody;
						string sDESCRIPTION       = EmailUtils.XssFilter(sTextBody, Sql.ToString(Context.Application["CONFIG.email_xss"]));
						string sDESCRIPTION_HTML  = EmailUtils.XssFilter(sHtmlBody, Sql.ToString(Context.Application["CONFIG.email_xss"]));
						sDESCRIPTION_HTML = MimeUtils.EmbedInlineImages(email, sDESCRIPTION_HTML);
						row["DESCRIPTION"     ] = sDESCRIPTION;
						row["DESCRIPTION_HTML"] = sDESCRIPTION_HTML;
						if ( email.Attachments != null )
						{
							row["ATTACHMENTS"] = MimeUtils.GetAttachments(email);
						}
					}
				}
			}
			return dt;
		}

		public static byte[] GetAttachmentData(HttpContext Context, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD, string sFOLDER_ID, string sUNIQUE_ID, int nATTACHMENT_ID, ref string sFILENAME, ref string sCONTENT_TYPE, ref bool bINLINE)
		{
			byte[] byDataBinary = null;
			//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
			using ( ImapClient imap = new ImapClient() )
			{
				imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
				imap.AuthenticationMechanisms.Remove ("XOAUTH2");
				// 01/22/2017 Paul.  There is a bug with NTLM. 
				// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
				imap.AuthenticationMechanisms.Remove ("NTLM");
				imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
				
				if ( Sql.IsEmptyString(sFOLDER_ID) )
					sFOLDER_ID = "INBOX";
				
				IMailFolder mailbox = imap.GetFolder(sFOLDER_ID);
				if ( mailbox != null && mailbox.Exists )
				{
					mailbox.Open(FolderAccess.ReadOnly);
					MimeMessage email = null;
					bool bLoadSuccessful = false;
					try
					{
						MailKit.UniqueId uid = new MailKit.UniqueId((uint) Sql.ToInteger(sUNIQUE_ID));
						email = mailbox.GetMessage(uid);
						bLoadSuccessful = true;
					}
					catch
					{
					}
					if ( email != null && bLoadSuccessful )
					{
						if ( email.Attachments != null )
						{
							int nAttachment = 0;
							foreach ( MimeKit.MimeEntity att in email.Attachments )
							{
								if ( nATTACHMENT_ID == nAttachment )
								{
									if ( att is MessagePart || att is MimePart )
									{
										// http://www.mimekit.net/docs/html/WorkingWithMessages.htm
										bINLINE          = false;
										sFILENAME        = String.Empty;
										string sFILE_EXT = String.Empty;
										sCONTENT_TYPE = att.ContentType.MediaType;
										if ( att.ContentDisposition != null && att.ContentDisposition.FileName != null )
										{
											sFILENAME = Path.GetFileName (att.ContentDisposition.FileName);
											sFILE_EXT = Path.GetExtension(sFILENAME);
										}
										using ( MemoryStream mem = new MemoryStream() )
										{
											if ( att is MessagePart )
											{
												MessagePart part = att as MessagePart;
												part.Message.WriteTo(mem);
											}
											else if ( att is MimePart )
											{
												MimePart part = att as MimePart;
												part.ContentObject.DecodeTo(mem);
											}
											byDataBinary = mem.ToArray();
										}
									}
									break;
								}
								nAttachment++;
							}
						}
					}
				}
			}
			return byDataBinary;
		}

		public static DataTable GetFolderMessages(HttpContext Context, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD, string sFOLDER_ID)
		{
			DataTable dt = MimeUtils.CreateMessageTable();
			
			//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
			using ( ImapClient imap = new ImapClient() )
			{
				imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
				imap.AuthenticationMechanisms.Remove ("XOAUTH2");
				// 01/22/2017 Paul.  There is a bug with NTLM. 
				// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
				imap.AuthenticationMechanisms.Remove ("NTLM");
				imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
				
				if ( Sql.IsEmptyString(sFOLDER_ID) )
					sFOLDER_ID = "INBOX";
				
				IMailFolder mailbox = imap.GetFolder(sFOLDER_ID);
				if ( mailbox != null && mailbox.Exists )
				{
					mailbox.Open(FolderAccess.ReadOnly);
					// 01/23/2017 Paul.  Need BodyStructure to get attachment info. 
					IList<IMessageSummary> summeries = mailbox.Fetch(0, -1, MessageSummaryItems.All | MessageSummaryItems.BodyStructure | MessageSummaryItems.UniqueId);
					if ( summeries != null && summeries.Count > 0 )
					{
						foreach ( IMessageSummary summary in summeries )
						{
							DataRow row = dt.NewRow();
							dt.Rows.Add(row);
							double dSize = (summary.Size.HasValue ? (double) summary.Size : 0);
							string sSize = String.Empty;
							if ( dSize < 1024 )
								sSize = dSize.ToString() + " B";
							else if ( dSize < 1024 * 1024 )
								sSize = Math.Floor(dSize / 1024).ToString() + " KB";
							else
								sSize = Math.Floor(dSize / (1024 * 1024)).ToString() + " MB";
						
							row["ID"           ] = Guid.NewGuid().ToString().Replace('-', '_');
							row["UNIQUE_ID"    ] = summary.UniqueId.Id                ;
							row["SIZE"         ] = summary.Size                       ;
							row["SIZE_STRING"  ] = sSize                              ;
							if ( summary.Flags.HasValue )
								row["IS_READ"  ] = ((summary.Flags.Value & MessageFlags.Seen) == MessageFlags.Seen);
							row["TO_ADDRS"     ] = (summary.Envelope.To != null ? summary.Envelope.To.ToString() : String.Empty);
							row["CC_ADDRS"     ] = (summary.Envelope.Cc != null ? summary.Envelope.Cc.ToString() : String.Empty);
							row["NAME"         ] = summary.Envelope.Subject           ;
							row["MESSAGE_ID"   ] = summary.Envelope.MessageId         ;
							row["DATE_MODIFIED"] = summary.Date.DateTime.ToLocalTime();
							row["DATE_ENTERED" ] = summary.Date.DateTime.ToLocalTime();
							row["DATE_START"   ] = summary.Date.DateTime.ToLocalTime();
							if ( summary.Envelope.From != null )
							{
								string sFROM_ADDR = String.Empty;
								string sFROM_NAME = String.Empty;
								foreach ( InternetAddress from in summary.Envelope.From )
								{
									if ( from is MailboxAddress )
									{
										MailboxAddress addr = from as MailboxAddress;
										sFROM_ADDR += addr.Address;
										sFROM_NAME += addr.Name   ;
										break;
									}
								}
								row["FROM"      ] = summary.Envelope.From.ToString();
								row["FROM_ADDR" ] = sFROM_ADDR;
								row["FROM_NAME" ] = sFROM_NAME;
							}
							if ( summary.Attachments != null )
							{
								foreach ( BodyPartBasic att in summary.Attachments )
								{
									row["HAS_ATTACHMENTS"] = true;
									break;
								}
							}
							// 07/17/2010 Paul.  Another way to detect attachments. 
							// http://stackoverflow.com/questions/36881966/mimekit-imapclient-get-attachment-information-without-downloading-whole-message
							//foreach ( BodyPartBasic part in summary.BodyParts )
							//{
							//	if ( part.IsAttachment )
							//	{
							//		row["HAS_ATTACHMENTS"] = true;
							//		break;
							//	}
							//}
						}
					}
				}
			}
			return dt;
		}

		public static Guid ImportMessage(HttpContext Context, string sPARENT_TYPE, Guid gPARENT_ID, string sSERVER_URL, int nPORT, bool bMAILBOX_SSL, string sEMAIL_USER, string sEMAIL_PASSWORD, Guid gUSER_ID, Guid gASSIGNED_USER_ID, Guid gTEAM_ID, string sTEAM_SET_LIST, string sFOLDER_ID, string sUNIQUE_ID)
		{
			Guid gEMAIL_ID = Guid.Empty;
			
			//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
			using ( ImapClient imap = new ImapClient() )
			{
				imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
				imap.AuthenticationMechanisms.Remove ("XOAUTH2");
				// 01/22/2017 Paul.  There is a bug with NTLM. 
				// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
				imap.AuthenticationMechanisms.Remove ("NTLM");
				imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
				
				if ( Sql.IsEmptyString(sFOLDER_ID) )
					sFOLDER_ID = "INBOX";
				
				IMailFolder mailbox = imap.GetFolder(sFOLDER_ID);
				if ( mailbox != null && mailbox.Exists )
				{
					mailbox.Open(FolderAccess.ReadOnly);
					MimeMessage email = null;
					bool bLoadSuccessful = false;
					try
					{
						MailKit.UniqueId uid = new MailKit.UniqueId((uint) Sql.ToInteger(sUNIQUE_ID));
						email = mailbox.GetMessage(uid);
						bLoadSuccessful = true;
					}
					catch(Exception ex)
					{
						string sError = "Error loading email for " + sEMAIL_USER + ", " + sUNIQUE_ID + "." + ControlChars.CrLf;
						sError += Utils.ExpandException(ex) + ControlChars.CrLf;
						SyncError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), sError);
					}
					if ( email != null && bLoadSuccessful )
					{
						gEMAIL_ID = MimeUtils.ImportMessage(Context, sPARENT_TYPE, gPARENT_ID, gUSER_ID, gASSIGNED_USER_ID, gTEAM_ID, sTEAM_SET_LIST, sUNIQUE_ID, email);
					}
				}
			}
			return gEMAIL_ID;
		}
	}
}


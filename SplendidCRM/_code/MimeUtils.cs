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
using System.Xml;
using System.Text;
//using System.Text.RegularExpressions;
using System.Data;
using System.Data.Common;
//using System.Collections;
//using System.Collections.Generic;
//using System.Collections.Specialized;
using System.Web;
using System.Web.SessionState;
using System.Diagnostics;

using MimeKit;

namespace SplendidCRM
{
	public class MimeUtils
	{
		public static string NormalizeInternetAddressName(MailboxAddress addr)
		{
			string sDisplayName = addr.Name;
			if ( Sql.IsEmptyString(sDisplayName) )
				sDisplayName = addr.Address;
			else if ( sDisplayName.StartsWith("\"") && sDisplayName.EndsWith("\"") || sDisplayName.StartsWith("\'") && sDisplayName.EndsWith("\'") )
				sDisplayName = sDisplayName.Substring(1, sDisplayName.Length-2);
			return sDisplayName;
		}

		public static void BuildAddressList(InternetAddress to, StringBuilder sbTO_ADDRS, StringBuilder sbTO_ADDRS_NAMES, StringBuilder sbTO_ADDRS_EMAILS)
		{
			if ( to is MailboxAddress )
			{
				MailboxAddress addr = to as MailboxAddress;
				// 01/13/2008 Paul.  SugarCRM uses commas, but we prefer semicolons. 
				sbTO_ADDRS.Append((sbTO_ADDRS.Length > 0) ? "; " : String.Empty);
				sbTO_ADDRS.Append(addr.ToString());

				sbTO_ADDRS_NAMES.Append((sbTO_ADDRS_NAMES.Length > 0) ? "; " : String.Empty);
				sbTO_ADDRS_NAMES.Append(NormalizeInternetAddressName(addr));

				sbTO_ADDRS_EMAILS.Append((sbTO_ADDRS_EMAILS.Length > 0) ? "; " : String.Empty);
				sbTO_ADDRS_EMAILS.Append(addr.Address);
			}
			else if ( to is GroupAddress )
			{
				GroupAddress grp = to as GroupAddress;
				foreach ( InternetAddress grpMember in grp.Members )
				{
					BuildAddressList(grpMember, sbTO_ADDRS, sbTO_ADDRS_NAMES, sbTO_ADDRS_EMAILS);
				}
			}
		}

		public static void BuildAddressIDList(IDbConnection con, InternetAddress to, StringBuilder sbTO_ADDRS_IDS, StringBuilder sbTO_ADDRS_NAMES, StringBuilder sbTO_ADDRS_EMAILS)
		{
			if ( to is MailboxAddress )
			{
				MailboxAddress addr = to as MailboxAddress;
				if ( sbTO_ADDRS_NAMES .Length > 0 ) sbTO_ADDRS_NAMES .Append(';');
				if ( sbTO_ADDRS_EMAILS.Length > 0 ) sbTO_ADDRS_EMAILS.Append(';');
				sbTO_ADDRS_NAMES .Append(NormalizeInternetAddressName(addr));
				sbTO_ADDRS_EMAILS.Append(addr.Address);
				// 07/18/2010 Paul.  Exchange, Imap and Pop3 utils will all use this method to lookup a contact by email. 
				// 08/30/2010 Paul.  The previous method only returned Contacts, where as this new method returns Contacts, Leads and Prospects. 
				Guid gRECIPIENT_ID = Crm.Emails.RecipientByEmail(con, addr.Address);
				if ( !Sql.IsEmptyGuid(gRECIPIENT_ID) )
				{
					if ( sbTO_ADDRS_IDS.Length > 0 )
						sbTO_ADDRS_IDS.Append(';');
					sbTO_ADDRS_IDS.Append(gRECIPIENT_ID.ToString());
				}
			}
			else if ( to is GroupAddress )
			{
				GroupAddress grp = to as GroupAddress;
				foreach ( InternetAddress grpMember in grp.Members )
				{
					BuildAddressIDList(con, grpMember, sbTO_ADDRS_IDS, sbTO_ADDRS_NAMES, sbTO_ADDRS_EMAILS);
				}
			}
		}

		// 11/06/2010 Paul.  Return the Attachments so that we can show embedded images or download the attachments. 
		public static string GetAttachments(MimeMessage email)
		{
			XmlDocument xml = new XmlDocument();
			xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
			xml.AppendChild(xml.CreateElement("Attachments"));
			int i = 0;
			foreach ( MimeEntity att in email.Attachments )
			{
				if ( att is MessagePart )
				{
					MessagePart part = att as MessagePart;
					XmlNode xAttachment = xml.CreateElement("Attachment");
					xml.DocumentElement.AppendChild(xAttachment);
					XmlUtil.SetSingleNode(xml, xAttachment, "ID"                , i.ToString()                   );
					if ( part.ContentDisposition != null )
					{
						XmlUtil.SetSingleNode(xml, xAttachment, "Name"              , part.ContentDisposition.FileName   );
						XmlUtil.SetSingleNode(xml, xAttachment, "FileName"          , part.ContentDisposition.FileName   );
						XmlUtil.SetSingleNode(xml, xAttachment, "Disposition"       , part.ContentDisposition.Disposition);
						if ( part.ContentDisposition.Size.HasValue )
							XmlUtil.SetSingleNode(xml, xAttachment, "Size"          , part.ContentDisposition.Size.Value.ToString());
						if ( part.ContentDisposition.CreationDate.HasValue )
							XmlUtil.SetSingleNode(xml, xAttachment, "CreationDate"  , part.ContentDisposition.CreationDate.Value.ToLocalTime().ToString());
						if ( part.ContentDisposition.ModificationDate.HasValue )
							XmlUtil.SetSingleNode(xml, xAttachment, "ModificationDate", part.ContentDisposition.ModificationDate.Value.ToLocalTime().ToString());
					}
					XmlUtil.SetSingleNode(xml, xAttachment, "MediaType"         , part.ContentType.MediaType     );
					XmlUtil.SetSingleNode(xml, xAttachment, "CharSet"           , part.ContentType.Charset       );
					XmlUtil.SetSingleNode(xml, xAttachment, "ContentType"       , part.ContentType.ToString()    );
					XmlUtil.SetSingleNode(xml, xAttachment, "ContentID"         , part.ContentId                 );
					//XmlUtil.SetSingleNode(xml, xAttachment, "ContentDescription", part.ContentDescription        );
					//XmlUtil.SetSingleNode(xml, xAttachment, "ContentEncoding"   , part.ContentTransferEncoding.ToString());
					//XmlUtil.SetSingleNode(xml, xAttachment, "ContentMD5"        , part.ContentMD5                );
					//XmlUtil.SetSingleNode(xml, xAttachment, "ContentLanguage"   , part.ContentLanguage           );
					//XmlUtil.SetSingleNode(xml, xAttachment, "Disposition"       , part.Disposition               );
					//XmlUtil.SetSingleNode(xml, xAttachment, "Boundary"          , part.Boundary                  );
					if ( part.ContentLocation != null )
						XmlUtil.SetSingleNode(xml, xAttachment, "Location"          , part.ContentLocation.ToString());
					//XmlUtil.SetSingleNode(xml, xAttachment, "LastModifiedTime"  , part.LastModifiedTime.ToLocalTime().ToString());
				}
				else if ( att is MimePart )
				{
					MimePart part = att as MimePart;
					XmlNode xAttachment = xml.CreateElement("Attachment");
					xml.DocumentElement.AppendChild(xAttachment);
					XmlUtil.SetSingleNode(xml, xAttachment, "ID"                , i.ToString()                   );
					XmlUtil.SetSingleNode(xml, xAttachment, "Name"              , part.FileName                  );
					if ( part.ContentDisposition != null )
					{
						XmlUtil.SetSingleNode(xml, xAttachment, "FileName"          , part.ContentDisposition.FileName   );
						XmlUtil.SetSingleNode(xml, xAttachment, "Disposition"       , part.ContentDisposition.Disposition);
						if ( part.ContentDisposition.CreationDate.HasValue )
							XmlUtil.SetSingleNode(xml, xAttachment, "CreationDate"  , part.ContentDisposition.CreationDate.Value.ToLocalTime().ToString());
						if ( part.ContentDisposition.ModificationDate.HasValue )
							XmlUtil.SetSingleNode(xml, xAttachment, "ModificationDate", part.ContentDisposition.ModificationDate.Value.ToLocalTime().ToString());
					}
					if ( part.ContentObject != null && part.ContentObject.Stream != null )
						XmlUtil.SetSingleNode(xml, xAttachment, "Size"              , part.ContentObject.Stream.Length.ToString());
					XmlUtil.SetSingleNode(xml, xAttachment, "MediaType"         , part.ContentType.MediaType     );
					XmlUtil.SetSingleNode(xml, xAttachment, "CharSet"           , part.ContentType.Charset       );
					XmlUtil.SetSingleNode(xml, xAttachment, "ContentType"       , part.ContentType.ToString()    );
					XmlUtil.SetSingleNode(xml, xAttachment, "ContentID"         , part.ContentId                 );
					//XmlUtil.SetSingleNode(xml, xAttachment, "ContentDescription", part.ContentDescription        );
					XmlUtil.SetSingleNode(xml, xAttachment, "ContentEncoding"   , part.ContentTransferEncoding.ToString());
					XmlUtil.SetSingleNode(xml, xAttachment, "ContentMD5"        , part.ContentMd5                );
					//XmlUtil.SetSingleNode(xml, xAttachment, "ContentLanguage"   , part.ContentLanguage           );
					//XmlUtil.SetSingleNode(xml, xAttachment, "Boundary"          , part.Boundary                  );
					if ( part.ContentLocation != null )
						XmlUtil.SetSingleNode(xml, xAttachment, "Location"          , part.ContentLocation.ToString());
					//XmlUtil.SetSingleNode(xml, xAttachment, "LastModifiedTime"  , part.LastModifiedTime.ToLocalTime().ToString());
				}
				i++;
			}
			return xml.OuterXml;
		}

		// 01/26/2013 Paul.  The SplendidCRM email header can be found in the body of a bounced message, so consider it as a tracker key. 
		public static string[] arrTrackers = new string[] { "/RemoveMe.aspx?identifier=", "/campaign_trackerv2.aspx?identifier=", "/image.aspx?identifier=", "X-SplendidCRM-ID: " };

		public static Guid FindTargetTrackerKey(MimeMessage mm, string sHtmlBody, string sTextBody)
		{
			Guid gTARGET_TRACKER_KEY = Guid.Empty;
			if ( mm.Headers.Contains("X-SplendidCRM-ID") )
				gTARGET_TRACKER_KEY = Sql.ToGuid(mm.Headers["X-SplendidCRM-ID"]);
			if ( Sql.IsEmptyGuid(gTARGET_TRACKER_KEY) )
			{
				// 01/13/2008 Paul.  Now look for a RemoveMe tracker, or any of the other expected trackers. 
				if ( !Sql.IsEmptyString(sHtmlBody) )
				{
					foreach ( string sTracker in arrTrackers )
					{
						int nStartTracker = sHtmlBody.IndexOf(sTracker);
						if ( nStartTracker > 0 )
						{
							nStartTracker += sTracker.Length;
							gTARGET_TRACKER_KEY = Sql.ToGuid(sHtmlBody.Substring(nStartTracker, 36));
							if ( !Sql.IsEmptyGuid(gTARGET_TRACKER_KEY) )
								return gTARGET_TRACKER_KEY;
						}
					}
				}
				if ( !Sql.IsEmptyString(sTextBody) )
				{
					foreach ( string sTracker in arrTrackers )
					{
						int nStartTracker = sTextBody.IndexOf(sTracker);
						if ( nStartTracker > 0 )
						{
							nStartTracker += sTracker.Length;
							gTARGET_TRACKER_KEY = Sql.ToGuid(sTextBody.Substring(nStartTracker, 36));
							if ( !Sql.IsEmptyGuid(gTARGET_TRACKER_KEY) )
								return gTARGET_TRACKER_KEY;
						}
					}
				}
			}
			return gTARGET_TRACKER_KEY;
		}

		public static string EmbedInlineImages(MimeMessage email, string sDESCRIPTION_HTML)
		{
			// 01/21/2017 Paul.  Instead of saving the image as a separate record, save as data in the HTML. 
			// https://github.com/jstedfast/MimeKit/issues/134
			foreach ( MimeEntity att in email.BodyParts )
			{
				if ( att is MessagePart )
				{
					MessagePart part = att as MessagePart;
					if ( part.ContentId != null && part.ContentType.MediaType == "image" && (sDESCRIPTION_HTML.IndexOf("cid:" + part.ContentId) >= 0) )
					{
						byte[] b = null;
						using ( MemoryStream mem = new MemoryStream() )
						{
							part.WriteTo(mem);
							b = mem.ToArray();
						}
						string imageBase64 = "data:" + part.ContentType.MimeType + ";base64," + Convert.ToBase64String(b);
						sDESCRIPTION_HTML = sDESCRIPTION_HTML.Replace("cid:" + part.ContentId, imageBase64);
					}
				}
				else if ( att is MimePart )
				{
					MimePart part = att as MimePart;
					if ( part.ContentId != null && part.ContentObject != null && part.ContentType.MediaType == "image" && (sDESCRIPTION_HTML.IndexOf("cid:" + part.ContentId) >= 0) )
					{
						byte[] b = null;
						using ( MemoryStream mem = new MemoryStream() )
						{
							part.ContentObject.DecodeTo(mem);
							b = mem.ToArray();
						}
						string imageBase64 = "data:" + part.ContentType.MimeType + ";base64," + Convert.ToBase64String(b);
						sDESCRIPTION_HTML = sDESCRIPTION_HTML.Replace("cid:" + part.ContentId, imageBase64);
					}
				}
			}
			return sDESCRIPTION_HTML;
		}

		// 07/19/2010 Paul.  Moved ImportInboundEmail to PopUtils. 
		// 09/04/2011 Paul.  In order to prevent duplicate emails, we need to use the unique message ID. 
		// 01/21/2017 Paul.  Convert to MimeKit. 
		// 01/28/2017 Paul.  Add GROUP_TEAM_ID. 
		public static Guid ImportInboundEmail(HttpContext Context, IDbConnection con, MimeMessage mm, Guid gMAILBOX_ID, string sINTENT, Guid gGROUP_ID, Guid gGROUP_TEAM_ID, string sUNIQUE_MESSAGE_ID)
		{
			// 09/04/2011 Paul.  Return the email ID so that we can use this method with the Chrome Extension. 
			Guid gEMAIL_ID = Guid.Empty;
			//try
			//{
				string sEMAIL_TYPE = "inbound";
				string sSTATUS     = "unread";
				// 07/30/2008 Paul.  Lookup the default culture. 
				string sCultureName = SplendidDefaults.Culture(Context.Application);
				
				string sFROM_ADDR = String.Empty;
				string sFROM_NAME = String.Empty;
				if ( mm.From != null )
				{
					foreach ( InternetAddress from in mm.From )
					{
						if ( from is MailboxAddress )
						{
							MailboxAddress addr = from as MailboxAddress;
							if ( sFROM_ADDR.Length > 0 ) sFROM_ADDR += ", ";
							if ( sFROM_NAME.Length > 0 ) sFROM_NAME += ", ";
							sFROM_ADDR += addr.Address;
							sFROM_NAME += NormalizeInternetAddressName(addr);
						}
					}
				}
				
				// 01/28/2017 Paul.  Save ReplyTo if it is available. 
				string sREPLY_TO_ADDR = String.Empty;
				string sREPLY_TO_NAME = String.Empty;
				if ( mm.ReplyTo != null )
				{
					foreach ( InternetAddress replyTo in mm.ReplyTo )
					{
						if ( replyTo is MailboxAddress )
						{
							MailboxAddress addr = replyTo as MailboxAddress;
							sREPLY_TO_ADDR += addr.Address;
							sREPLY_TO_NAME += NormalizeInternetAddressName(addr);
							break;
						}
					}
				}
				
				StringBuilder sbTO_ADDRS        = new StringBuilder();
				StringBuilder sbTO_ADDRS_NAMES  = new StringBuilder();
				StringBuilder sbTO_ADDRS_EMAILS = new StringBuilder();
				if ( mm.To != null )
				{
					foreach ( InternetAddress to in mm.To )
					{
						MimeUtils.BuildAddressList(to, sbTO_ADDRS, sbTO_ADDRS_NAMES, sbTO_ADDRS_EMAILS);
					}
				}
				
				StringBuilder sbCC_ADDRS        = new StringBuilder();
				StringBuilder sbCC_ADDRS_NAMES  = new StringBuilder();
				StringBuilder sbCC_ADDRS_EMAILS = new StringBuilder();
				if ( mm.Cc != null )
				{
					foreach ( InternetAddress cc in mm.Cc )
					{
						MimeUtils.BuildAddressList(cc, sbCC_ADDRS, sbCC_ADDRS_NAMES, sbCC_ADDRS_EMAILS);
					}
				}
				
				StringBuilder sbBCC_ADDRS        = new StringBuilder();
				StringBuilder sbBCC_ADDRS_NAMES  = new StringBuilder();
				StringBuilder sbBCC_ADDRS_EMAILS = new StringBuilder();
				if ( mm.Bcc != null )
				{
					foreach ( InternetAddress bcc in mm.Bcc )
					{
						MimeUtils.BuildAddressList(bcc, sbBCC_ADDRS, sbBCC_ADDRS_NAMES, sbBCC_ADDRS_EMAILS);
					}
				}
				
				// 01/21/2017 Paul.  Only get the body values once as they may be computed. 
				// http://www.mimekit.net/docs/html/WorkingWithMessages.htm
				string sTextBody = mm.TextBody;
				string sHtmlBody = mm.HtmlBody;
				// 01/13/2008 Paul.  First look for our special header. 
				// Our special header will only exist if the email is a bounce. 
				Guid gTARGET_TRACKER_KEY = Guid.Empty;
				// 01/13/2008 Paul.  The header will always be in lower case. 
				gTARGET_TRACKER_KEY = FindTargetTrackerKey(mm, sHtmlBody, sTextBody);
				// 01/20/2008 Paul.  mm.DeliveredTo can be NULL. 
				// 01/20/2008 Paul.  Filter the XSS tags before inserting the email. 
				// 01/23/2008 Paul.  DateTime in the email is in universal time. 
				
				string sSAFE_BODY_PLAIN = EmailUtils.XssFilter(sTextBody, Sql.ToString(Context.Application["CONFIG.email_xss"]));
				string sSAFE_BODY_HTML  = EmailUtils.XssFilter(sHtmlBody, Sql.ToString(Context.Application["CONFIG.email_xss"]));
				sSAFE_BODY_HTML = MimeUtils.EmbedInlineImages(mm, sSAFE_BODY_HTML);
				
				string sRawContent = String.Empty;
				using ( MemoryStream stm = new MemoryStream() )
				{
					mm.WriteTo(stm);
					stm.Position = 0;
					using ( StreamReader rdr = new StreamReader(stm) )
					{
						sRawContent = rdr.ReadToEnd();
					}
				}
				// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						// 12/12/2017 Paul.  We are getting timeouts on Azure, so make it run forever. 
						if ( false )
						{
							// 01/08/2018 Paul.  Disable CS0162: Unreachable code detected
							#pragma warning disable 162
							SqlProcs.spEMAILS_InsertInbound
								( ref gEMAIL_ID
								, gGROUP_ID
								, mm.Subject
								, mm.Date.DateTime.ToLocalTime()
								, sSAFE_BODY_PLAIN
								, sSAFE_BODY_HTML
								, sFROM_ADDR
								, sFROM_NAME
								, sbTO_ADDRS.ToString()
								, sbCC_ADDRS.ToString()
								, sbBCC_ADDRS.ToString()
								, sbTO_ADDRS_NAMES  .ToString()
								, sbTO_ADDRS_EMAILS .ToString()
								, sbCC_ADDRS_NAMES  .ToString()
								, sbCC_ADDRS_EMAILS .ToString()
								, sbBCC_ADDRS_NAMES .ToString()
								, sbBCC_ADDRS_EMAILS.ToString()
								, sEMAIL_TYPE
								, sSTATUS
								// 09/04/2011 Paul.  In order to prevent duplicate emails, we need to use the unique message ID. 
								, sUNIQUE_MESSAGE_ID  // mm.MessageId + ((mm.DeliveredTo != null && mm.DeliveredTo.Address != null) ? mm.DeliveredTo.Address : String.Empty)
								// 07/24/2010 Paul.  ReplyTo is obsolete in .NET 4.0. 
								// 01/28/2017 Paul.  Save ReplyTo if it is available. 
								, sREPLY_TO_ADDR
								, sREPLY_TO_NAME
								, sINTENT
								, gMAILBOX_ID
								, gTARGET_TRACKER_KEY
								, sRawContent
								// 01/28/2017 Paul.  Use new GROUP_TEAM_ID value associated with InboundEmail record. 
								, gGROUP_TEAM_ID
								, trn
								);
							#pragma warning restore 162
						}
						else
						{
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.Transaction = trn;
								cmd.CommandType = CommandType.StoredProcedure;
								cmd.CommandText = "spEMAILS_InsertInbound";
								// 12/12/2017 Paul.  We are getting timeouts on Azure, so make it run forever. 
								cmd.CommandTimeout = 0;
								IDbDataParameter parID                 = Sql.AddParameter(cmd, "@ID"                , gEMAIL_ID                     );
								IDbDataParameter parMODIFIED_USER_ID   = Sql.AddParameter(cmd, "@MODIFIED_USER_ID"  ,  Security.USER_ID             );
								IDbDataParameter parASSIGNED_USER_ID   = Sql.AddParameter(cmd, "@ASSIGNED_USER_ID"  , gGROUP_ID                     );
								IDbDataParameter parNAME               = Sql.AddParameter(cmd, "@NAME"              , mm.Subject                    , 255);
								IDbDataParameter parDATE_TIME          = Sql.AddParameter(cmd, "@DATE_TIME"         , mm.Date.DateTime.ToLocalTime());
								IDbDataParameter parDESCRIPTION        = Sql.AddParameter(cmd, "@DESCRIPTION"       , sSAFE_BODY_PLAIN              );
								IDbDataParameter parDESCRIPTION_HTML   = Sql.AddParameter(cmd, "@DESCRIPTION_HTML"  , sSAFE_BODY_HTML               );
								IDbDataParameter parFROM_ADDR          = Sql.AddParameter(cmd, "@FROM_ADDR"         , sFROM_ADDR                    , 100);
								IDbDataParameter parFROM_NAME          = Sql.AddParameter(cmd, "@FROM_NAME"         , sFROM_NAME                    , 100);
								IDbDataParameter parTO_ADDRS           = Sql.AddParameter(cmd, "@TO_ADDRS"          , sbTO_ADDRS        .ToString() );
								IDbDataParameter parCC_ADDRS           = Sql.AddParameter(cmd, "@CC_ADDRS"          , sbCC_ADDRS        .ToString() );
								IDbDataParameter parBCC_ADDRS          = Sql.AddParameter(cmd, "@BCC_ADDRS"         , sbBCC_ADDRS       .ToString() );
								IDbDataParameter parTO_ADDRS_NAMES     = Sql.AddParameter(cmd, "@TO_ADDRS_NAMES"    , sbTO_ADDRS_NAMES  .ToString() );
								IDbDataParameter parTO_ADDRS_EMAILS    = Sql.AddAnsiParam(cmd, "@TO_ADDRS_EMAILS"   , sbTO_ADDRS_EMAILS .ToString() , 8000);
								IDbDataParameter parCC_ADDRS_NAMES     = Sql.AddParameter(cmd, "@CC_ADDRS_NAMES"    , sbCC_ADDRS_NAMES  .ToString() );
								IDbDataParameter parCC_ADDRS_EMAILS    = Sql.AddAnsiParam(cmd, "@CC_ADDRS_EMAILS"   , sbCC_ADDRS_EMAILS .ToString() , 8000);
								IDbDataParameter parBCC_ADDRS_NAMES    = Sql.AddParameter(cmd, "@BCC_ADDRS_NAMES"   , sbBCC_ADDRS_NAMES .ToString() );
								IDbDataParameter parBCC_ADDRS_EMAILS   = Sql.AddAnsiParam(cmd, "@BCC_ADDRS_EMAILS"  , sbBCC_ADDRS_EMAILS.ToString() , 8000);
								IDbDataParameter parTYPE               = Sql.AddParameter(cmd, "@TYPE"              , sEMAIL_TYPE                   ,  25);
								IDbDataParameter parSTATUS             = Sql.AddParameter(cmd, "@STATUS"            , sSTATUS                       ,  25);
								IDbDataParameter parMESSAGE_ID         = Sql.AddAnsiParam(cmd, "@MESSAGE_ID"        , sUNIQUE_MESSAGE_ID            , 851);
								IDbDataParameter parREPLY_TO_NAME      = Sql.AddParameter(cmd, "@REPLY_TO_NAME"     , sREPLY_TO_NAME                , 100);
								IDbDataParameter parREPLY_TO_ADDR      = Sql.AddParameter(cmd, "@REPLY_TO_ADDR"     , sREPLY_TO_ADDR                , 100);
								IDbDataParameter parINTENT             = Sql.AddParameter(cmd, "@INTENT"            , sINTENT                       ,  25);
								IDbDataParameter parMAILBOX_ID         = Sql.AddParameter(cmd, "@MAILBOX_ID"        , gMAILBOX_ID                   );
								IDbDataParameter parTARGET_TRACKER_KEY = Sql.AddParameter(cmd, "@TARGET_TRACKER_KEY", gTARGET_TRACKER_KEY           );
								IDbDataParameter parRAW_SOURCE         = Sql.AddParameter(cmd, "@RAW_SOURCE"        , sRawContent                   );
								IDbDataParameter parTEAM_ID            = Sql.AddParameter(cmd, "@TEAM_ID"           , gGROUP_TEAM_ID                );
								parID.Direction = ParameterDirection.InputOutput;
								Sql.Trace(cmd);
								cmd.ExecuteNonQuery();
								gEMAIL_ID = Sql.ToGuid(parID.Value);
							}
						}
					
						// 01/20/2008 Paul.  In a bounce, the server messages will be stored in entities. 
						// 06/12/2008 Paul.  Entities should be in the body of the message. 
						/*
						foreach ( Pop3.RxMailMessage ent in mm.Entities )
						{
							// text/plain
							// message/delivery-status
							// message/rfc822
							// 01/20/2008 Paul.  Most server status reports will not have a subject, so use the first 300 characters, but take out the CRLF. 
							// 01/21/2008 Paul.  Substring will throw an exception if request exceeds length. 
							if ( Sql.IsEmptyString(ent.Subject) && !Sql.IsEmptyString(ent.Body) )
								ent.Subject = ent.Body.Substring(0, Math.Min(ent.Body.Length, 300)).Replace("\r\n", " ");
							// 06/12/2008 Paul.  Some entities will have not subject and no body. 
							if ( !Sql.IsEmptyString(ent.Subject) )
							{
								Guid gNOTE_ID = Guid.Empty;
								// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
								SqlProcs.spNOTES_Update
									( ref gNOTE_ID
									, mm.ContentType.MediaType + ": " + ent.Subject
									, "Emails"   // Parent Type
									, gEMAIL_ID  // Parent ID
									, Guid.Empty
									, ent.Body
									, Guid.Empty // TEAM_ID
									, gGROUP_ID
									// 05/17/2017 Paul.  Add Tags module. 
									, String.Empty  // TAG_SET_NAME
									// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
									, false          // IS_PRIVATE
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									, String.Empty   // ASSIGNED_SET_LIST
									, trn
									);
							}
						}
						*/
						foreach ( MimeEntity att in mm.Attachments )
						{
							if ( att is MessagePart || att is MimePart )
							{
								// http://www.mimekit.net/docs/html/WorkingWithMessages.htm
								string sFILENAME       = String.Empty;
								string sFILE_EXT       = String.Empty;
								string sFILE_MIME_TYPE = att.ContentType.MediaType;
								// 01/14/2010 Eric.  Hotmail does not use the Name field for the filename. 
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
										if ( Sql.IsEmptyString(sFILENAME) )
										{
											sFILENAME = Path.GetFileName (part.FileName);
											sFILE_EXT = Path.GetExtension(sFILENAME);
										}
										part.ContentObject.DecodeTo(mem);
									}
									mem.Seek(0, SeekOrigin.Begin);
									
									Guid gNOTE_ID = Guid.Empty;
									SqlProcs.spNOTES_Update
										( ref gNOTE_ID
										, L10N.Term(Context.Application, sCultureName, "Emails.LBL_EMAIL_ATTACHMENT") + ": " + sFILENAME
										, "Emails"          // PARENT_TYPE
										, gEMAIL_ID         // PARENT_ID
										, Guid.Empty        // CONTACT_ID
										, Sql.ToString(att.ContentId)  // 05/06/2014 Paul.  The ContentID might be NULL. 
										// 01/28/2017 Paul.  Use new GROUP_TEAM_ID value associated with InboundEmail record. 
										, gGROUP_TEAM_ID    // TEAM_ID
										, String.Empty      // TEAM_SET_LIST
										, gGROUP_ID         // ASSIGNED_USER_ID
										// 05/17/2017 Paul.  Add Tags module. 
										, String.Empty      // TAG_SET_NAME
										// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
										, false             // IS_PRIVATE
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, String.Empty      // ASSIGNED_SET_LIST
										, trn
										);
							
									Guid gNOTE_ATTACHMENT_ID = Guid.Empty;
									SqlProcs.spNOTE_ATTACHMENTS_Insert(ref gNOTE_ATTACHMENT_ID, gNOTE_ID, sFILENAME, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE, trn);
									Crm.NoteAttachments.LoadFile(gNOTE_ATTACHMENT_ID, mem, trn);
								}
							}
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						// 07/11/2017 Paul.  We need to make sure that this actual error is caught and that the rollback is not executed if there is a timeout. 
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
						// 12/12/2017 Paul.  We must always rollback, otherwise the connection will become blocked by this transaction. 
						trn.Rollback();
						throw;
					}
				}
			// 07/11/2017 Paul.  Don't catch here because we want the throw to pass through. 
			//}
			//catch(Exception ex)
			//{
			//	SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
			//}
			return gEMAIL_ID;
		}

		public static Guid ImportMessage(HttpContext Context, string sPARENT_TYPE, Guid gPARENT_ID,  Guid gUSER_ID, Guid gASSIGNED_USER_ID, Guid gTEAM_ID, string sTEAM_SET_LIST, string sUNIQUE_ID, MimeMessage email)
		{
			Guid gEMAIL_ID = Guid.Empty;
			HttpApplicationState Application = Context.Application;
			HttpSessionState     Session     = Context.Session    ;
			long   lUploadMaxSize  = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
			string sCULTURE        = L10N.NormalizeCulture(Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
			
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					DateTime dtREMOTE_DATE_MODIFIED_UTC = email.Date.DateTime;
					// 11/06/2010 Paul.  Use simple ToLocalTime() instead of the convert function as it is prone to throwing errors. 
					// The conversion could not be completed because the supplied DateTime did not have the Kind property set correctly. 
					// For example, when the Kind property is DateTimeKind.Local, the source time zone must be TimeZoneInfo.Local.
					//DateTime dtREMOTE_DATE_MODIFIED     = TimeZoneInfo.ConvertTimeFromUtc(dtREMOTE_DATE_MODIFIED_UTC, TimeZoneInfo.Local);
					DateTime dtREMOTE_DATE_MODIFIED     = dtREMOTE_DATE_MODIFIED_UTC.ToLocalTime();
					string sFROM_ADDR = String.Empty;
					string sFROM_NAME = String.Empty;
					foreach ( InternetAddress from in email.From )
					{
						if ( from is MailboxAddress )
						{
							MailboxAddress addr = from as MailboxAddress;
							sFROM_ADDR += addr.Address;
							sFROM_NAME += addr.Name   ;
							break;
						}
					}
					
					cmd.Parameters.Clear();
					// 04/22/2010 Paul.  Always lookup the Contact. 
					Guid   gCONTACT_ID     = Guid.Empty;
					Guid   gSENDER_USER_ID = gUSER_ID;
					string sSQL = String.Empty;
					sSQL = "select ID                      " + ControlChars.CrLf
					     + "  from vwCONTACTS              " + ControlChars.CrLf;
					cmd.CommandText = sSQL;
					// 04/26/2018 Paul.  Exchange Sync needs to follow team hierarchy rules. 
					Security.Filter(cmd, "Contacts", "view");
					Sql.AppendParameter(cmd, sFROM_ADDR, "EMAIL1");
					using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
					{
						if ( rdr.Read() )
						{
							gCONTACT_ID = Sql.ToGuid(rdr["ID"]);
						}
					}
					
					string sREPLY_TO_NAME = String.Empty;
					string sREPLY_TO_ADDR = String.Empty;
					if ( email.ReplyTo != null )
					{
						foreach ( InternetAddress replyTo in email.ReplyTo )
						{
							if ( replyTo is MailboxAddress )
							{
								MailboxAddress addr = replyTo as MailboxAddress;
								sFROM_ADDR += addr.Address;
								sFROM_NAME += addr.Name   ;
								break;
							}
						}
					}
					
					StringBuilder sbTO_ADDRS_IDS    = new StringBuilder();
					StringBuilder sbTO_ADDRS_NAMES  = new StringBuilder();
					StringBuilder sbTO_ADDRS_EMAILS = new StringBuilder();
					if ( email.To != null )
					{
						foreach ( InternetAddress to in email.To )
						{
							MimeUtils.BuildAddressIDList(con, to, sbTO_ADDRS_IDS, sbTO_ADDRS_NAMES, sbTO_ADDRS_EMAILS);
						}
					}
					StringBuilder sbCC_ADDRS_IDS    = new StringBuilder();
					StringBuilder sbCC_ADDRS_NAMES  = new StringBuilder();
					StringBuilder sbCC_ADDRS_EMAILS = new StringBuilder();
					if ( email.Cc != null )
					{
						foreach ( InternetAddress cc in email.Cc )
						{
							MimeUtils.BuildAddressIDList(con, cc, sbCC_ADDRS_IDS, sbCC_ADDRS_NAMES, sbCC_ADDRS_EMAILS);
						}
					}
					StringBuilder sbBCC_ADDRS_IDS    = new StringBuilder();
					StringBuilder sbBCC_ADDRS_NAMES  = new StringBuilder();
					StringBuilder sbBCC_ADDRS_EMAILS = new StringBuilder();
					if ( email.Bcc != null )
					{
						foreach ( InternetAddress bcc in email.Bcc )
						{
							MimeUtils.BuildAddressIDList(con, bcc, sbBCC_ADDRS_IDS, sbBCC_ADDRS_NAMES, sbBCC_ADDRS_EMAILS);
						}
					}
					// 01/21/2017 Paul.  Only get the body values once as they may be computed. 
					// http://www.mimekit.net/docs/html/WorkingWithMessages.htm
					string sTextBody = email.TextBody;
					string sHtmlBody = email.HtmlBody;
					string sDESCRIPTION       = EmailUtils.XssFilter(sTextBody, Sql.ToString(Context.Application["CONFIG.email_xss"]));
					string sDESCRIPTION_HTML  = EmailUtils.XssFilter(sHtmlBody, Sql.ToString(Context.Application["CONFIG.email_xss"]));
					sDESCRIPTION_HTML = MimeUtils.EmbedInlineImages(email, sDESCRIPTION_HTML);
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							SqlProcs.spEMAILS_Update
								( ref gEMAIL_ID
								, gASSIGNED_USER_ID
								, email.Subject
								, email.Date.DateTime.ToLocalTime()
								, sPARENT_TYPE
								, gPARENT_ID
								, sDESCRIPTION
								, sDESCRIPTION_HTML
								, sFROM_NAME
								, sFROM_ADDR
								, (email.To != null) ? email.To.ToString() : String.Empty
								, (email.Cc != null) ? email.Cc.ToString() : String.Empty
								, String.Empty
								, sbTO_ADDRS_IDS    .ToString()
								, sbTO_ADDRS_NAMES  .ToString()
								, sbTO_ADDRS_EMAILS .ToString()
								, sbCC_ADDRS_IDS    .ToString()
								, sbCC_ADDRS_NAMES  .ToString()
								, sbCC_ADDRS_EMAILS .ToString()
								, sbBCC_ADDRS_IDS   .ToString()
								, sbBCC_ADDRS_NAMES .ToString()
								, sbBCC_ADDRS_EMAILS.ToString()
								, "archived"
								, email.MessageId  // MESSAGE_ID
								, sREPLY_TO_NAME
								, sREPLY_TO_ADDR
								, String.Empty  // INTENT
								, Guid.Empty    // MAILBOX_ID
								, gTEAM_ID
								, sTEAM_SET_LIST
								// 05/17/2017 Paul.  Add Tags module. 
								, String.Empty  // TAG_SET_NAME
								// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
								, false         // IS_PRIVATE
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty  // ASSIGNED_SET_LIST
								, trn
								);
										
							// 08/31/2010 Paul.  The EMAILS_SYNC table was renamed to EMAIL_CLIENT_SYNC to prevent conflict with Offline Client sync tables. 
							SqlProcs.spEMAIL_CLIENT_SYNC_Update(gUSER_ID, gEMAIL_ID, sUNIQUE_ID, sPARENT_TYPE, gPARENT_ID, dtREMOTE_DATE_MODIFIED, dtREMOTE_DATE_MODIFIED_UTC, trn);
							// 04/01/2010 Paul.  Always add the current user to the email. 
							SqlProcs.spEMAILS_USERS_Update(gEMAIL_ID, gUSER_ID, trn);
							// 04/01/2010 Paul.  Always lookup and assign the contact. 
							if ( !Sql.IsEmptyGuid(gCONTACT_ID) )
							{
								SqlProcs.spEMAILS_CONTACTS_Update(gEMAIL_ID, gCONTACT_ID, trn);
							}
							foreach ( MimeEntity att in email.Attachments )
							{
								if ( att is MessagePart || att is MimePart )
								{
									// http://www.mimekit.net/docs/html/WorkingWithMessages.htm
									string sNAME           = String.Empty;
									string sFILENAME       = String.Empty;
									string sFILE_EXT       = String.Empty;
									string sFILE_MIME_TYPE = att.ContentType.MediaType;
									// 01/14/2010 Eric.  Hotmail does not use the Name field for the filename. 
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
											sNAME = sFILENAME;
											part.Message.WriteTo(mem);
										}
										else if ( att is MimePart )
										{
											MimePart part = att as MimePart;
											sNAME = part.FileName;
											part.ContentObject.DecodeTo(mem);
										}
										mem.Seek(0, SeekOrigin.Begin);
										long lFileSize = mem.Length;
										if ( (lUploadMaxSize == 0) || (lFileSize <= lUploadMaxSize) )
										{
											Guid gNOTE_ID = Guid.Empty;
											// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
											SqlProcs.spNOTES_Update
												( ref gNOTE_ID
												, L10N.Term(Context.Application, sCULTURE, "Emails.LBL_EMAIL_ATTACHMENT") + ": " + sFILENAME
												, "Emails"   // Parent Type
												, gEMAIL_ID  // Parent ID
												, Guid.Empty
												, Sql.ToString(att.ContentId)  // 05/06/2014 Paul.  The ContentID might be NULL. 
												, gTEAM_ID       // TEAM_ID
												, sTEAM_SET_LIST // TEAM_SET_LIST
												, gASSIGNED_USER_ID
												// 05/17/2017 Paul.  Add Tags module. 
												, String.Empty   // TAG_SET_NAME
												// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
												, false          // IS_PRIVATE
												// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
												, String.Empty   // ASSIGNED_SET_LIST
												, trn
												);
											Guid gNOTE_ATTACHMENT_ID = Guid.Empty;
											SqlProcs.spNOTE_ATTACHMENTS_Insert(ref gNOTE_ATTACHMENT_ID, gNOTE_ID, sNAME, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE, trn);
											// 11/06/2010 Paul.  Move LoadFile() to Crm.NoteAttachments. 
											Crm.NoteAttachments.LoadFile(gNOTE_ATTACHMENT_ID, mem, trn);
										}
									}
								}
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
			}
			return gEMAIL_ID;
		}

		public static DataTable CreateMessageTable()
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("ID"              , typeof(System.String  ));
			dt.Columns.Add("UNIQUE_ID"       , typeof(System.String  ));
			dt.Columns.Add("NAME"            , typeof(System.String  ));
			dt.Columns.Add("DATE_START"      , typeof(System.DateTime));
			dt.Columns.Add("FROM"            , typeof(System.String  ));
			dt.Columns.Add("FROM_ADDR"       , typeof(System.String  ));
			dt.Columns.Add("FROM_NAME"       , typeof(System.String  ));
			dt.Columns.Add("TO_ADDRS"        , typeof(System.String  ));
			dt.Columns.Add("CC_ADDRS"        , typeof(System.String  ));
			dt.Columns.Add("TYPE"            , typeof(System.String  ));
			dt.Columns.Add("STATUS"          , typeof(System.String  ));
			dt.Columns.Add("MESSAGE_ID"      , typeof(System.String  ));
			dt.Columns.Add("REPLY_TO_NAME"   , typeof(System.String  ));
			dt.Columns.Add("REPLY_TO_ADDR"   , typeof(System.String  ));
			dt.Columns.Add("DATE_ENTERED"    , typeof(System.DateTime));
			dt.Columns.Add("DATE_MODIFIED"   , typeof(System.DateTime));
			dt.Columns.Add("DESCRIPTION"     , typeof(System.String  ));
			dt.Columns.Add("DESCRIPTION_HTML", typeof(System.String  ));
			dt.Columns.Add("INTERNET_HEADERS", typeof(System.String  ));
			dt.Columns.Add("SIZE"            , typeof(System.Int32   ));
			dt.Columns.Add("SIZE_STRING"     , typeof(System.String  ));
			dt.Columns.Add("HAS_ATTACHMENTS" , typeof(System.Boolean ));
			dt.Columns.Add("IS_READ"         , typeof(System.Boolean ));
			dt.Columns.Add("CATEGORIES"      , typeof(System.String  ));
			dt.Columns.Add("ATTACHMENTS"     , typeof(System.String  ));
			return dt;
		}

		public static DataRow CreateMessageRecord(HttpContext Context, DataTable dt, MimeMessage email, double dSize)
		{
			DataRow row = dt.NewRow();
			dt.Rows.Add(row);
			string sSize = String.Empty;
			if ( dSize < 1024 )
				sSize = dSize.ToString() + " B";
			else if ( dSize < 1024 * 1024 )
				sSize = Math.Floor(dSize / 1024).ToString() + " KB";
			else
				sSize = Math.Floor(dSize / (1024 * 1024)).ToString() + " MB";
			
			row["ID"            ] = Guid.NewGuid().ToString().Replace('-', '_');
			if ( !Sql.IsEmptyString(email.MessageId) )
			{
				row["UNIQUE_ID" ] = email.MessageId;
				row["MESSAGE_ID"] = email.MessageId;
			}
			else if ( email.Date != null )
			{
				// 07/18/2010 Paul.  If there is no Message ID, then we will need to make one. 
				// 11/06/2010 Paul.  Should use ToString and not IsEmptyString. 
				row["UNIQUE_ID"] = email.Date.DateTime.ToString() + " " + email.From.ToString();
			}
			row["SIZE"        ] = dSize        ;
			row["SIZE_STRING" ] = sSize        ;
			row["IS_READ"     ] = true         ;
			if ( email.To != null )
				row["TO_ADDRS"] = email.To     ;
			if ( email.Cc != null )
				row["CC_ADDRS"] = email.Cc     ;
			row["NAME"        ] = email.Subject;
			if ( email.Date.DateTime != null )
			{
				row["DATE_MODIFIED"] = email.Date.DateTime.ToLocalTime();
				row["DATE_ENTERED" ] = email.Date.DateTime.ToLocalTime();
				row["DATE_START"   ] = email.Date.DateTime.ToLocalTime();
			}
			else
			{
				row["DATE_MODIFIED"] = DateTime.Now;
				row["DATE_ENTERED" ] = DateTime.Now;
				row["DATE_START"   ] = DateTime.Now;
			}
			if ( email.From != null )
			{
				string sFROM_ADDR = String.Empty;
				string sFROM_NAME = String.Empty;
				foreach ( InternetAddress from in email.From )
				{
					if ( from is MailboxAddress )
					{
						MailboxAddress addr = from as MailboxAddress;
						sFROM_ADDR += addr.Address;
						sFROM_NAME += addr.Name   ;
						break;
					}
				}
				row["FROM"      ] = email.From.ToString();
				row["FROM_ADDR" ] = sFROM_ADDR;
				row["FROM_NAME" ] = sFROM_NAME;
			}
			if ( email.To != null )
			{
				row["TO_ADDRS"] = email.To.ToString();
			}
			if ( email.Cc != null )
			{
				row["CC_ADDRS"] = email.Cc.ToString();
			}
			
			// 01/21/2017 Paul.  Only get the body values once as they may be computed. 
			// http://www.mimekit.net/docs/html/WorkingWithMessages.htm
			string sTextBody = Sql.ToString(email.TextBody);
			string sHtmlBody = Sql.ToString(email.HtmlBody);
			string sDESCRIPTION       = EmailUtils.XssFilter(sTextBody, Sql.ToString(Context.Application["CONFIG.email_xss"]));
			string sDESCRIPTION_HTML  = EmailUtils.XssFilter(sHtmlBody, Sql.ToString(Context.Application["CONFIG.email_xss"]));
			sDESCRIPTION_HTML = MimeUtils.EmbedInlineImages(email, sDESCRIPTION_HTML);
			row["DESCRIPTION"     ] = sDESCRIPTION;
			row["DESCRIPTION_HTML"] = sDESCRIPTION_HTML;
			
			XmlDocument xmlInternetHeaders = new XmlDocument();
			xmlInternetHeaders.AppendChild(xmlInternetHeaders.CreateElement("Headers"));
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
			
			if ( email.Attachments != null )
			{
				row["HAS_ATTACHMENTS"] = true;
				row["ATTACHMENTS"    ] = MimeUtils.GetAttachments(email);
			}
			return row;
		}
	}
}

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
using System.Web;
using System.Net;
using System.Net.Mail;
using System.Security.Cryptography.X509Certificates;
using System.Diagnostics;

namespace SplendidCRM
{
	public class SplendidMailSmtp : SplendidMailClient
	{
		private SmtpClient     smtpClient    ;

		public SplendidMailSmtp(HttpApplicationState Application)
		{
			string sSmtpServer      = Sql.ToString (Application["CONFIG.smtpserver"     ]);
			int    nSmtpPort        = Sql.ToInteger(Application["CONFIG.smtpport"       ]);
			bool   bSmtpAuthReq     = Sql.ToBoolean(Application["CONFIG.smtpauth_req"   ]);
			bool   bSmtpSSL         = Sql.ToBoolean(Application["CONFIG.smtpssl"        ]);
			string sSmtpUser        = Sql.ToString (Application["CONFIG.smtpuser"       ]);
			string sSmtpPassword    = Sql.ToString (Application["CONFIG.smtppass"       ]);
			string sX509Certificate = Sql.ToString (Application["CONFIG.smtpcertificate"]);
			if ( !Sql.IsEmptyString(sSmtpPassword) )
				sSmtpPassword = Security.DecryptPassword(Application, sSmtpPassword);
			smtpClient = CreateSmtpClient(Application, sSmtpServer, nSmtpPort, bSmtpAuthReq, bSmtpSSL, sSmtpUser, sSmtpPassword, sX509Certificate);
		}

		public SplendidMailSmtp(HttpApplicationState Application, string sSmtpServer, int nSmtpPort, bool bSmtpAuthReq, bool bSmtpSSL)
		{
			string sSmtpUser        = Sql.ToString (Application["CONFIG.smtpuser"       ]);
			string sSmtpPassword    = Sql.ToString (Application["CONFIG.smtppass"       ]);
			string sX509Certificate = Sql.ToString (Application["CONFIG.smtpcertificate"]);
			if ( !Sql.IsEmptyString(sSmtpPassword) )
				sSmtpPassword = Security.DecryptPassword(Application, sSmtpPassword);
			if ( Sql.IsEmptyString(sSmtpServer) )
			{
				sSmtpServer   = Sql.ToString (Application["CONFIG.smtpserver"  ]);
				nSmtpPort     = Sql.ToInteger(Application["CONFIG.smtpport"    ]);
				bSmtpAuthReq  = Sql.ToBoolean(Application["CONFIG.smtpauth_req"]);
				bSmtpSSL      = Sql.ToBoolean(Application["CONFIG.smtpssl"     ]);
			}
			smtpClient = CreateSmtpClient(Application, sSmtpServer, nSmtpPort, bSmtpAuthReq, bSmtpSSL, sSmtpUser, sSmtpPassword, sX509Certificate);
		}

		public SplendidMailSmtp(HttpApplicationState Application, string sSmtpServer, int nSmtpPort, bool bSmtpAuthReq, bool bSmtpSSL, string sSmtpUser, string sSmtpPassword, string sX509Certificate)
		{
			smtpClient = CreateSmtpClient(Application, sSmtpServer, nSmtpPort, bSmtpAuthReq, bSmtpSSL, sSmtpUser, sSmtpPassword, sX509Certificate);
		}

		// 07/19/2010 Paul.  Create a new method so we can provide a way to skip the decryption of the system password. 
		// 07/18/2013 Paul.  Add support for multiple outbound emails. 
		private SmtpClient CreateSmtpClient(HttpApplicationState Application, string sSmtpServer, int nSmtpPort, bool bSmtpAuthReq, bool bSmtpSSL, string sSmtpUser, string sSmtpPassword, string sX509Certificate)
		{
			// 01/12/2008 Paul.  We must decrypt the password before using it. 
			// 02/02/2017 Paul.  Password is always in non-encrypted format. 
			//if ( !Sql.IsEmptyString(sSmtpPassword) )
			//{
			//	sSmtpPassword = Security.DecryptPassword(Application, sSmtpPassword);
			//}
			if ( Sql.IsEmptyString(sSmtpServer) )
				sSmtpServer = "127.0.0.1";
			if ( nSmtpPort == 0 )
				nSmtpPort = 25;

			// 04/17/2006 Paul.  Use config value for SMTP server. 
			// 12/21/2006 Paul.  Allow the use of SMTP servers that require authentication. 
			// 07/21/2013 Paul.  Gmail should use 587 and not 465 with EnableSsl. 
			// http://stackoverflow.com/questions/1082216/gmail-smtp-via-c-sharp-net-errors-on-all-ports
			SmtpClient client = new SmtpClient(sSmtpServer, nSmtpPort);
			client.Timeout = 60 * 1000;
			// 01/12/2008 Paul.  Use SMTP SSL flag to support Gmail. 
			if ( bSmtpSSL )
			{
				client.EnableSsl = true;
				// 11/16/2009 Paul.  One of our Live clients would like to use a client certificate for SMTP. 
				// 07/19/2010 Paul.  We are not going to support user certificates at this time. 
				if ( Sql.IsEmptyString(sSmtpPassword) && !Sql.IsEmptyString(sX509Certificate) )
				{
					try
					{
						X509Certificate cert = HttpRuntime.Cache.Get("SMTP.X509Certificate") as X509Certificate;
						if ( cert == null )
						{
							const string sCertHeader = "-----BEGIN CERTIFICATE-----";
							const string sCertFooter = "-----END CERTIFICATE-----";
							sX509Certificate = sX509Certificate.Trim();
							if (sX509Certificate.StartsWith(sCertHeader) && sX509Certificate.EndsWith(sCertFooter))
							{
								sX509Certificate = sX509Certificate.Substring(sCertHeader.Length, sX509Certificate.Length - sCertHeader.Length - sCertFooter.Length);
								byte[] byPKS8  = Convert.FromBase64String(sX509Certificate.Trim());
								
								cert = new X509Certificate(byPKS8);
							}
							else
							{
								throw(new Exception("Invalid X509 Certificate.  Missing BEGIN CERTIFICATE or END CERTIFICATE."));
							}
							HttpRuntime.Cache.Insert("SMTP.X509Certificate", cert, null, SplendidCache.DefaultCacheExpiration(), System.Web.Caching.Cache.NoSlidingExpiration);
						}
						if ( cert != null )
							client.ClientCertificates.Add(cert);
					}
					catch(Exception ex)
					{
						SplendidError.SystemMessage(Application, "Error", new StackTrace(true).GetFrame(0), "Failed to add SMTP certificate to email: " + Utils.ExpandException(ex));
					}
				}
			}
			// 07/19/2010 Paul.  Use the user credentials if provided. 
			if ( bSmtpAuthReq && !Sql.IsEmptyString(sSmtpPassword) )
				client.Credentials = new NetworkCredential(sSmtpUser, sSmtpPassword);
			else
				client.UseDefaultCredentials = true;
			return client;
		}

		override public void Send(MailMessage mail)
		{
			smtpClient.Send(mail);
		}
	}
}

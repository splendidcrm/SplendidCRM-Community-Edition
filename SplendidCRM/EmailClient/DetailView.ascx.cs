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
using System.Xml;
using System.Text;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.EmailClient
{
	/// <summary>
	/// Summary description for DetailView.
	/// </summary>
	public class DetailView : SplendidControl
	{
		protected Label    lblError           ;
		protected Label    txtFROM            ;
		protected Label    txtNAME            ;
		protected Label    txtDATE_START      ;
		protected Label    txtTO_ADDRS        ;
		protected Label    txtCC_ADDRS        ;
		protected Label    txtDESCRIPTION     ;
		protected Literal  litINTERNET_HEADERS;
		
		protected TableRow trFROM             ;
		protected TableRow trNAME             ;
		protected TableRow trDATE_START       ;
		protected TableRow trTO_ADDRS         ;
		protected TableRow trCC_ADDRS         ;
		protected TableRow trINTERNET_HEADERS ;
		protected TableRow trATTACHMENTS      ;
		protected DataGrid grdATTACHMENTS     ;
		protected Repeater rptATTACHMENTS     ;

		public CommandEventHandler Command;

		public string FROM
		{
			get { return txtFROM.Text; }
			set { txtFROM.Text = value; }
		}

		public string NAME
		{
			get { return txtNAME.Text; }
			set { txtNAME.Text = value; }
		}

		public string DATE_START
		{
			get { return txtDATE_START.Text; }
			set { txtDATE_START.Text = value; }
		}

		public string TO_ADDRS
		{
			get { return txtTO_ADDRS.Text; }
			set { txtTO_ADDRS.Text = value; }
		}

		public string CC_ADDRS
		{
			get { return txtCC_ADDRS.Text; }
			set
			{
				txtCC_ADDRS.Text = value;
				trCC_ADDRS.Visible = !Sql.IsEmptyString(txtCC_ADDRS.Text);
			}
		}

		public string DESCRIPTION
		{
			get { return txtDESCRIPTION.Text; }
			set { txtDESCRIPTION.Text = value; }
		}

		public string INTERNET_HEADERS
		{
			get { return litINTERNET_HEADERS.Text; }
			set
			{
				try
				{
					XmlDocument xml = new XmlDocument();
					// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
					// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
					// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
					xml.XmlResolver = null;
					xml.LoadXml(value);

					StringBuilder sb = new StringBuilder();
					sb.AppendLine("<table class=\"tabDetailView\">");
					XmlNodeList nlHeaders = xml.SelectNodes("Headers/Header");
					foreach ( XmlNode xHeader in nlHeaders )
					{
						string sName  = XmlUtil.SelectSingleNode(xHeader, "Name" );
						string sValue = XmlUtil.SelectSingleNode(xHeader, "Value");
						if ( L10n.IsLanguageRTL() )
							sName = ":" + sName;
						else
							sName = sName + ":";
						sb.AppendLine("	<tr>");
						sb.AppendLine("		<td width=\"15%\" class=\"EmailDetailViewDL\">" + sName + "</td>");
						// 07/17/2010 Paul.  Make sure not to encode the <br />. 
						sb.AppendLine("		<td width=\"85%\" class=\"EmailDetailViewDF\">" + HttpUtility.HtmlEncode(sValue).Replace("\n", "<br />\n") + "</td>");
						sb.AppendLine("	</tr>");
					}
					sb.AppendLine("</table>");
					litINTERNET_HEADERS.Text = sb.ToString();
				}
				catch
				{
				}
			}
		}

		// 11/06/2010 Paul.  Return the Attachments so that we can show embedded images or download the attachments. 
		public DataTable ATTACHMENTS
		{
			set
			{
				// 11/06/2010 Paul.  First make sure to clear the previous data source. 
				grdATTACHMENTS.DataSource = null;
				grdATTACHMENTS.DataBind();
				rptATTACHMENTS.DataSource = null;
				rptATTACHMENTS.DataBind();
				if ( value != null )
				{
					DataView vwAttachments = new DataView(value);
#if DEBUG
					grdATTACHMENTS.DataSource = vwAttachments;
					grdATTACHMENTS.DataBind();
#else
					// 11/06/2010 Paul.  Exclude the Inline images from the list of download links. 
					vwAttachments.RowFilter = "IsInline = 'False'";
#endif
					rptATTACHMENTS.DataSource = vwAttachments;
					rptATTACHMENTS.DataBind();
					trATTACHMENTS.Visible = true;
				}
			}
		}


		public void ClearForm()
		{
			txtFROM            .Text = String.Empty;
			txtNAME            .Text = String.Empty;
			txtDATE_START      .Text = String.Empty;
			txtTO_ADDRS        .Text = String.Empty;
			txtCC_ADDRS        .Text = String.Empty;
			txtDESCRIPTION     .Text = String.Empty;
			litINTERNET_HEADERS.Text = String.Empty;
			trFROM            .Visible = true ;
			trNAME            .Visible = true ;
			trDATE_START      .Visible = true ;
			trTO_ADDRS        .Visible = true ;
			trCC_ADDRS        .Visible = false;
			trINTERNET_HEADERS.Visible = false;
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "ShowHeaders" )
				{
					trINTERNET_HEADERS.Visible = !trINTERNET_HEADERS.Visible;
					// 05/30/2010 Paul.  I like seeing the original header in addition to the raw headers. 
					//trFROM            .Visible = !trINTERNET_HEADERS.Visible;
					//trNAME            .Visible = !trINTERNET_HEADERS.Visible;
					//trDATE_START      .Visible = !trINTERNET_HEADERS.Visible;
					//trTO_ADDRS        .Visible = !trINTERNET_HEADERS.Visible;
					//trCC_ADDRS        .Visible = !trINTERNET_HEADERS.Visible && !Sql.IsEmptyString(txtCC_ADDRS.Text);
				}
				// 07/17/2010 Paul.  Always send the command to the parent so that it can rebind the grid, 
				// otherwise the pagination disappears and the selection fails. 
				if ( Command != null )
					Command(this, e);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
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
			m_sMODULE = "EmailClient";
		}
		#endregion
	}
}


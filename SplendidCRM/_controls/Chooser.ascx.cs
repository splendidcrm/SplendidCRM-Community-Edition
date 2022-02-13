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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Xml;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for Chooser.
	/// </summary>
	public class Chooser : SplendidControl
	{
		protected string          sChooserTitle    ;
		protected string          sLeftTitle       ;
		protected string          sRightTitle      ;
		public    HtmlInputHidden txtLeft          ;
		public    HtmlInputHidden txtRight         ;
		public    ListBox         lstLeft          ;
		public    ListBox         lstRight         ;
		protected TableCell       tdSpacerUpDown   ;
		protected TableCell       tdSpacerLeftRight;
		protected TableCell       tdMoveUpDown     ;
		protected TableCell       tdMoveLeftRight  ;

		public string ChooserTitle
		{
			get
			{
				return sChooserTitle;
			}
			set
			{
				sChooserTitle = value;
			}
		}

		public string LeftTitle
		{
			get
			{
				return sLeftTitle;
			}
			set
			{
				sLeftTitle = value;
			}
		}

		public string RightTitle
		{
			get
			{
				return sRightTitle;
			}
			set
			{
				sRightTitle = value;
			}
		}

		public bool Enabled
		{
			get
			{
				return lstLeft.Enabled;
			}
			set
			{
				lstLeft .Enabled = value;
				lstRight.Enabled = value;
				tdSpacerUpDown.Visible    = value;
				tdSpacerLeftRight.Visible = value;
				tdMoveUpDown.Visible      = value;
				tdMoveLeftRight.Visible   = value;
			}
		}

		public ListBox LeftListBox
		{
			get
			{
				return lstLeft;
			}
		}

		public ListBox RightListBox
		{
			get
			{
				return lstRight;
			}
		}

		public DataTable LeftValuesTable
		{
			get
			{
				return ValuesTable(txtLeft.Value);
			}
		}

		public string LeftValues
		{
			get
			{
				StringBuilder sb = new StringBuilder();
				DataTable dt = LeftValuesTable;
				if ( dt != null )
				{
					foreach ( DataRow row in dt.Rows )
					{
						if ( sb.Length > 0 )
							sb.Append(",");
						sb.Append(Sql.ToString(row["value"]));
					}
				}
				return sb.ToString();
			}
		}

		public DataTable RightValuesTable
		{
			get
			{
				return ValuesTable(txtRight.Value);
			}
		}

		public string RightValues
		{
			get
			{
				StringBuilder sb = new StringBuilder();
				DataTable dt = RightValuesTable;
				if ( dt != null )
				{
					foreach ( DataRow row in dt.Rows )
					{
						if ( sb.Length > 0 )
							sb.Append(",");
						sb.Append(Sql.ToString(row["value"]));
					}
				}
				return sb.ToString();
			}
		}

		private DataTable ValuesTable(string sXml)
		{
			DataTable dt = null;
			try
			{
				if ( !Sql.IsEmptyString(sXml) )
				{
					XmlDocument xml = new XmlDocument();
					// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
					// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
					// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
					xml.XmlResolver = null;
					xml.LoadXml(sXml);
					dt = XmlUtil.CreateDataTable(xml.DocumentElement, "list", new string[] {"text", "value"});
				}
			}
			catch
			{
			}
			return dt;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// Put user code to initialize the page here
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
		}
		#endregion
	}
}


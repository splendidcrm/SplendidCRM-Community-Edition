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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.DynamicLayout.DetailViews
{
	/// <summary>
	///		Summary description for NewRecord.
	/// </summary>
	public class NewRecord : DynamicLayout.NewRecord
	{
		protected TextBox            txtDATA_FORMAT ;
		protected TextBox            txtURL_FIELD   ;
		protected TextBox            txtURL_FORMAT  ;
		protected TextBox            txtURL_TARGET  ;
		protected TextBox            txtCOLSPAN     ;
		// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
		protected TextBox            txtTOOL_TIP    ;
		// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
		protected TextBox            txtPARENT_FIELD;
		protected TableRow           trDATA_LABEL   ;
		protected TableRow           trDATA_FIELD   ;
		protected TableRow           trDATA_FORMAT  ;
		protected TableRow           trURL_FIELD    ;
		protected TableRow           trURL_FORMAT   ;
		protected TableRow           trURL_TARGET   ;
		protected TableRow           trMODULE_TYPE  ;
		protected TableRow           trLIST_NAME    ;
		protected TableRow           trCOLSPAN      ;
		protected TableRow           trTOOL_TIP     ;
		protected TableRow           trPARENT_FIELD ;
		protected Label              lblURL_TARGET  ;
		protected HiddenField        txtLAYOUT_FIELD_ID;
		protected Button             btnLAYOUT_FIELD;

		public override void Clear()
		{
			base.Clear();
			txtDATA_FORMAT.Text  = String.Empty;
			txtURL_FIELD  .Text  = String.Empty;
			txtURL_FORMAT .Text  = String.Empty;
			txtURL_TARGET .Text  = String.Empty;
			txtCOLSPAN    .Text  = String.Empty;
			txtTOOL_TIP   .Text  = String.Empty;
			// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
			txtPARENT_FIELD.Text = String.Empty;
			if ( lstMODULE_TYPE.Items.Count > 0 )
				lstMODULE_TYPE.SelectedIndex = 0;
		}

		public string DATA_FORMAT
		{
			get { return txtDATA_FORMAT.Text; }
			set { txtDATA_FORMAT.Text = value; }
		}

		public string URL_FIELD
		{
			get { return txtURL_FIELD.Text; }
			set { txtURL_FIELD.Text = value; }
		}

		public string URL_FORMAT
		{
			get { return txtURL_FORMAT.Text; }
			set { txtURL_FORMAT.Text = value; }
		}

		public string URL_TARGET
		{
			get { return txtURL_TARGET.Text; }
			set { txtURL_TARGET.Text = value; }
		}

		public int COLSPAN
		{
			get { return Sql.ToInteger(txtCOLSPAN.Text); }
			set
			{
				// 08/02/2010 Paul.  -1 is a valid value. 
				if ( value >= -1 )
					txtCOLSPAN.Text = value.ToString();
				else
					txtCOLSPAN.Text = String.Empty;
			}
		}

		// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
		public string TOOL_TIP
		{
			get { return txtTOOL_TIP.Text; }
			set { txtTOOL_TIP.Text = value; }
		}

		public string PARENT_FIELD
		{
			get { return Regex.Replace(txtPARENT_FIELD.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtPARENT_FIELD.Text = value; }
		}

		// 04/11/2011 Paul.  Add support for Dynamic Layout popups.
		protected void btnLAYOUT_FIELD_Click(object sender, EventArgs e)
		{
			Guid gID = Sql.ToGuid(txtLAYOUT_FIELD_ID.Value);
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *                         " + ControlChars.CrLf
					     + "  from vwDETAILVIEWS_FIELDS      " + ControlChars.CrLf
					     + " where ID = @ID                  " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ID", gID);
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								// 04/11/2011 Paul.  Copy all fields except ID and index. 
								//this.FIELD_ID    = Sql.ToGuid   (rdr["ID"             ]);
								//this.FIELD_INDEX = Sql.ToInteger(rdr["FIELD_INDEX"    ]);
								this.FIELD_TYPE  = Sql.ToString (rdr["FIELD_TYPE"     ]);
								this.DATA_LABEL  = Sql.ToString (rdr["DATA_LABEL"     ]);
								this.DATA_FIELD  = Sql.ToString (rdr["DATA_FIELD"     ]);
								this.DATA_FORMAT = Sql.ToString (rdr["DATA_FORMAT"    ]);
								this.URL_FIELD   = Sql.ToString (rdr["URL_FIELD"      ]);
								this.URL_FORMAT  = Sql.ToString (rdr["URL_FORMAT"     ]);
								this.URL_TARGET  = Sql.ToString (rdr["URL_TARGET"     ]);
								this.COLSPAN     = Sql.ToInteger(rdr["COLSPAN"        ]);
								this.LIST_NAME   = Sql.ToString (rdr["LIST_NAME"      ]);
								this.TOOL_TIP    = Sql.ToString (rdr["TOOL_TIP"       ]);
								this.MODULE_TYPE = Sql.ToString (rdr["MODULE_TYPE"    ]);
								this.PARENT_FIELD= Sql.ToString (rdr["PARENT_FIELD"   ]);
								this.lstFIELD_TYPE_Changed(null, null);
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				lblError.Text = ex.Message;
			}
			txtLAYOUT_FIELD_ID.Value = String.Empty;
		}

		// 05/17/2010 Paul.  We need to be able to refresh the visibility flags. 
		public override void lstFIELD_TYPE_Changed(Object sender, EventArgs e)
		{
			switch ( lstFIELD_TYPE.SelectedValue )
			{
				// 08/02/2010 Paul.  Show the URL fields for a string so that we can add a LinkedIn icon. 
				// 08/02/2010 Paul.  The javascript will be moved to a separate record. 
				// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
				case "String"    :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = true ;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = true ;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = true ;  trPARENT_FIELD.Visible = true ;  break;
				// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
				case "ModuleLink":  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = true ;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "TextBox"   :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = true ;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 05/14/2016 Paul.  Add Tags module. 
				case "Tags"      :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = false;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 04/20/2012 Paul.  Show the Module Type for a HyperLink. 
				case "HyperLink" :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = true ;  trURL_FIELD.Visible = true ;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "CheckBox"  :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = false;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				case "Button"    :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = true ;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 02/22/2022 Paul.  Allow image to be formatted. 
				case "Image"     :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = true;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 05/27/2016 Paul.  File type should have been added in 2010 when first supported. 
				case "File"      :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = false;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				case "Blank"     :  trDATA_LABEL.Visible = false;  trDATA_FIELD.Visible = false;  trDATA_FORMAT.Visible = false;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = false;  trTOOL_TIP.Visible = false;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				case "Line"      :  trDATA_LABEL.Visible = false;  trDATA_FIELD.Visible = false;  trDATA_FORMAT.Visible = false;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = false;  trTOOL_TIP.Visible = false;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				case "IFrame"    :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = true ;  trURL_FIELD.Visible = true ;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = true ;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 08/02/2010 Paul.  The javascript will be moved to a separate record. 
				case "JavaScript":  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = false;  trURL_FIELD.Visible = true ;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = false;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 09/02/2012 Paul.  A separator is just like a blank. 
				// 09/16/2012 Paul.  The data field can be used as the table id. 
				// 09/20/2012 Paul.  Data Format will store initial visibility state. 
				case "Separator" :  trDATA_LABEL.Visible = false;  trDATA_FIELD.Visible = true ;  trDATA_FORMAT.Visible = true ;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = false;  trTOOL_TIP.Visible = false;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				case "Header"    :  trDATA_LABEL.Visible = true ;  trDATA_FIELD.Visible = false;  trDATA_FORMAT.Visible = false;  trURL_FIELD.Visible = false;  trURL_FORMAT.Visible = trURL_FIELD.Visible;  trURL_TARGET.Visible = trURL_FIELD.Visible;  trLIST_NAME.Visible = false;  trCOLSPAN.Visible = true ;  trTOOL_TIP.Visible = false;  trMODULE_TYPE.Visible = false;  trPARENT_FIELD.Visible = false;  break;
			}
			// 08/02/2010 Paul.  Not sure why, but there are times when we set the Visible flag to true, but it rejects the setting and stays false. 
			//trDATA_FIELD.Visible = trDATA_LABEL.Visible;
			// 09/12/2009 Paul.  Set default format. 
			if ( lstFIELD_TYPE.SelectedValue == "String" && Sql.IsEmptyString(txtDATA_FORMAT.Text) )
			{
				txtDATA_FORMAT.Text = "{0}";
			}
			if ( lstFIELD_TYPE.SelectedValue == "IFrame" )
			{
				lblURL_TARGET.Text = L10n.Term("DynamicLayout.LBL_IFRAME_HEIGHT");
				// 06/16/2010 Paul.  Set the default height to 200. 
				int nValue = 0;
				if ( !Int32.TryParse(txtURL_TARGET.Text, out nValue) )
					txtURL_TARGET.Text = "200";
			}
			else
			{
				lblURL_TARGET.Text = L10n.Term("DynamicLayout.LBL_URL_TARGET");
				// 08/02/2010 Paul.  Don't clear the target.  It is also being used by JavaScript. 
				//txtURL_TARGET.Text = "";
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
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


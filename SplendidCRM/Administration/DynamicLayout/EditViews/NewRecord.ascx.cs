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

namespace SplendidCRM.Administration.DynamicLayout.EditViews
{
	/// <summary>
	///		Summary description for NewRecord.
	/// </summary>
	public class NewRecord : DynamicLayout.NewRecord
	{
		// 01/19/2010 Paul.  Add support for new DATA_FORMAT field. 
		protected TextBox            txtDATA_FORMAT            ;
		protected CheckBox           chkDATA_REQUIRED          ;  // All except blank
		protected CheckBox           chkUI_REQUIRED            ;  // All except blank
		protected TextBox            txtDISPLAY_FIELD          ;  // ChangeButton, ModulePopup
		protected TextBox            txtONCLICK_SCRIPT         ;  // ChangeButton, ModulePopup
		protected TextBox            txtFORMAT_SCRIPT          ;  // None
		protected TextBox            txtFORMAT_TAB_INDEX       ;  // All except blank
		protected TextBox            txtFORMAT_MAX_LENGTH      ;  // TextBox, Password, File
		protected TextBox            txtFORMAT_SIZE            ;  // TextBox, Password, File
		protected TextBox            txtFORMAT_ROWS            ;  // TextBox, ListBox, Radio, CheckBoxList
		protected TextBox            txtFORMAT_COLUMNS         ;  // TextBox
		protected TextBox            txtCOLSPAN                ;  // All except blank
		protected TextBox            txtROWSPAN                ;  // AddressButtons
		// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
		protected TextBox            txtTOOL_TIP               ;
		// 09/12/2009 Paul.  Add FIELD_VALIDATOR so that they can be disabled. 
		protected DropDownList       lstFIELD_VALIDATOR        ;  // TextBox
		protected TextBox            txtFIELD_VALIDATOR_MESSAGE;  // TextBox
		// 09/13/2010 Paul.  Add relationship fields. 
		protected TextBox            txtRELATED_SOURCE_MODULE_NAME  ;
		protected TextBox            txtRELATED_SOURCE_VIEW_NAME    ;
		protected TextBox            txtRELATED_SOURCE_ID_FIELD     ;
		protected TextBox            txtRELATED_SOURCE_NAME_FIELD   ;
		protected TextBox            txtRELATED_VIEW_NAME           ;
		protected TextBox            txtRELATED_ID_FIELD            ;
		protected TextBox            txtRELATED_NAME_FIELD          ;
		protected TextBox            txtRELATED_JOIN_FIELD          ;
		// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
		protected TextBox            txtPARENT_FIELD                ;

		protected TableRow           trDATA_FIELD        ;  // All except blank
		protected TableRow           trDATA_LABEL        ;  // All except hidden and blank
		protected TableRow           trDATA_FORMAT       ;
		protected TableRow           trDATA_REQUIRED     ;  // All except blank
		protected TableRow           trUI_REQUIRED       ;  // All except blank
		protected TableRow           trDISPLAY_FIELD     ;  // ChangeButton, ModulePopup
		protected TableRow           trONCLICK_SCRIPT    ;  // ChangeButton, ModulePopup
		// 05/17/2009 Paul.  Add support for a generic module popup. 
		protected TableRow           trMODULE_TYPE       ;  // ModulePopup, ModuleAutoComplete
		protected TableRow           trFORMAT_SCRIPT     ;  // 09/16/2012 Paul.  Unused. 
		protected TableRow           trFORMAT_MAX_LENGTH ;  // TextBox, Password, File
		protected TableRow           trFORMAT_SIZE       ;  // TextBox, Password, File
		protected TableRow           trFORMAT_COLUMNS    ;  // TextBox, Password, File
		// 02/05/2008 Paul.  trFORMAT_ROWS is a union of trTEXT and trLIST_NAME. 
		protected TableRow           trFORMAT_ROWS       ;  // TextBox, ListBox, Radio, CheckBoxList
		protected TableRow           trLIST_NAME         ;  // ListBox, Radio, CheckBoxList
		protected TableRow           trFORMAT_TAB_INDEX  ;  // All except blank
		protected TableRow           trCOLSPAN           ;  // All except blank
		protected TableRow           trROWSPAN           ;  // All except blank
		protected TableRow           trFIELD_VALIDATOR1  ;  // TextBox
		protected TableRow           trFIELD_VALIDATOR2  ;  // TextBox
		protected TableRow           trTOOL_TIP          ;  // All except blank. 
		protected TableRow           trRELATED1          ;  // Only related. 
		protected TableRow           trRELATED2          ;  // Only related. 
		protected TableRow           trRELATED3          ;  // Only related. 
		protected TableRow           trRELATED4          ;  // Only related. 
		protected TableRow           trRELATED5          ;  // Only related. 
		protected TableRow           trRELATED6          ;  // Only related. 
		protected TableRow           trRELATED7          ;  // Only related. 
		protected TableRow           trRELATED8          ;  // Only related. 
		protected TableRow           trPARENT_FIELD      ;  // Only ListBox. 
		protected HiddenField        txtLAYOUT_FIELD_ID  ;
		protected Button             btnLAYOUT_FIELD     ;

		public override void Clear()
		{
			base.Clear();
			txtDATA_FORMAT            .Text    = String.Empty;
			txtDISPLAY_FIELD          .Text    = String.Empty;
			txtONCLICK_SCRIPT         .Text    = String.Empty;
			txtFORMAT_SCRIPT          .Text    = String.Empty;
			txtFORMAT_TAB_INDEX       .Text    = String.Empty;
			txtFORMAT_MAX_LENGTH      .Text    = String.Empty;
			txtFORMAT_SIZE            .Text    = String.Empty;
			txtFORMAT_ROWS            .Text    = String.Empty;
			txtFORMAT_COLUMNS         .Text    = String.Empty;
			txtCOLSPAN                .Text    = String.Empty;
			txtROWSPAN                .Text    = String.Empty;
			txtTOOL_TIP               .Text    = String.Empty;
			txtFIELD_VALIDATOR_MESSAGE.Text    = String.Empty;
			chkDATA_REQUIRED          .Checked = false;
			chkUI_REQUIRED            .Checked = false;
			lstFIELD_VALIDATOR.SelectedIndex = 0;
			if ( lstMODULE_TYPE.Items.Count > 0 )
				lstMODULE_TYPE.SelectedIndex = 0;
			// 09/13/2010 Paul.  Add relationship fields. 
			txtRELATED_SOURCE_MODULE_NAME  .Text    = String.Empty;
			txtRELATED_SOURCE_VIEW_NAME    .Text    = String.Empty;
			txtRELATED_SOURCE_ID_FIELD     .Text    = String.Empty;
			txtRELATED_SOURCE_NAME_FIELD   .Text    = String.Empty;
			txtRELATED_VIEW_NAME           .Text    = String.Empty;
			txtRELATED_ID_FIELD            .Text    = String.Empty;
			txtRELATED_NAME_FIELD          .Text    = String.Empty;
			txtRELATED_JOIN_FIELD          .Text    = String.Empty;
			// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
			txtPARENT_FIELD                .Text    = String.Empty;
		}

		public string DATA_FORMAT
		{
			get { return txtDATA_FORMAT.Text; }
			set { txtDATA_FORMAT.Text = value; }
		}

		public string DISPLAY_FIELD
		{
			get { return txtDISPLAY_FIELD.Text; }
			set { txtDISPLAY_FIELD.Text = value; }
		}

		public string ONCLICK_SCRIPT
		{
			get { return txtONCLICK_SCRIPT.Text; }
			set { txtONCLICK_SCRIPT.Text = value; }
		}

		public Guid FIELD_VALIDATOR_ID
		{
			get { return Sql.ToGuid(lstFIELD_VALIDATOR.SelectedValue); }
			set
			{
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstFIELD_VALIDATOR, value.ToString());
				}
				catch
				{
				}
			}
		}

		public string FIELD_VALIDATOR_MESSAGE
		{
			get { return txtFIELD_VALIDATOR_MESSAGE.Text; }
			set { txtFIELD_VALIDATOR_MESSAGE.Text = value; }
		}

		public string FORMAT_SCRIPT
		{
			get { return txtFORMAT_SCRIPT.Text; }
			set { txtFORMAT_SCRIPT.Text = value; }
		}

		public int FORMAT_TAB_INDEX
		{
			get { return Sql.ToInteger(txtFORMAT_TAB_INDEX.Text); }
			set
			{
				if ( value > 0 )
					txtFORMAT_TAB_INDEX.Text = value.ToString();
				else
					txtFORMAT_TAB_INDEX.Text = String.Empty;
			}
		}

		public int FORMAT_MAX_LENGTH
		{
			get { return Sql.ToInteger(txtFORMAT_MAX_LENGTH.Text); }
			set
			{
				if ( value > 0 )
					txtFORMAT_MAX_LENGTH.Text = value.ToString();
				else
					txtFORMAT_MAX_LENGTH.Text = String.Empty;
			}
		}

		public int FORMAT_SIZE
		{
			get { return Sql.ToInteger(txtFORMAT_SIZE.Text); }
			set
			{
				if ( value > 0 )
					txtFORMAT_SIZE.Text = value.ToString();
				else
					txtFORMAT_SIZE.Text = String.Empty;
			}
		}

		public int FORMAT_ROWS
		{
			get { return Sql.ToInteger(txtFORMAT_ROWS.Text); }
			set
			{
				if ( value > 0 )
					txtFORMAT_ROWS.Text = value.ToString();
				else
					txtFORMAT_ROWS.Text = String.Empty;
			}
		}

		public int FORMAT_COLUMNS
		{
			get { return Sql.ToInteger(txtFORMAT_COLUMNS.Text); }
			set
			{
				if ( value > 0 )
					txtFORMAT_COLUMNS.Text = value.ToString();
				else
					txtFORMAT_COLUMNS.Text = String.Empty;
			}
		}

		public int COLSPAN
		{
			get { return Sql.ToInteger(txtCOLSPAN.Text); }
			set
			{
				// 09/30/2012 Paul.  This seems like an old bug.  -1 is used with Saluation and First Name. 
				if ( value > 0 || value == -1 )
					txtCOLSPAN.Text = value.ToString();
				else
					txtCOLSPAN.Text = String.Empty;
			}
		}

		public int ROWSPAN
		{
			get { return Sql.ToInteger(txtROWSPAN.Text); }
			set
			{
				if ( value > 0 )
					txtROWSPAN.Text = value.ToString();
				else
					txtROWSPAN.Text = String.Empty;
			}
		}

		// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
		public string TOOL_TIP
		{
			get { return txtTOOL_TIP.Text; }
			set { txtTOOL_TIP.Text = value; }
		}

		public bool DATA_REQUIRED
		{
			get { return chkDATA_REQUIRED.Checked; }
			set { chkDATA_REQUIRED.Checked = value; }
		}

		public bool UI_REQUIRED
		{
			get { return chkUI_REQUIRED.Checked; }
			set { chkUI_REQUIRED.Checked = value; }
		}

		// 09/13/2010 Paul.  Add relationship fields. 
		public string RELATED_SOURCE_MODULE_NAME
		{
			get { return Regex.Replace(txtRELATED_SOURCE_MODULE_NAME.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtRELATED_SOURCE_MODULE_NAME.Text = value; }
		}
		public string RELATED_SOURCE_VIEW_NAME
		{
			get { return Regex.Replace(txtRELATED_SOURCE_VIEW_NAME.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtRELATED_SOURCE_VIEW_NAME.Text = value; }
		}
		public string RELATED_SOURCE_ID_FIELD
		{
			get { return Regex.Replace(txtRELATED_SOURCE_ID_FIELD.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtRELATED_SOURCE_ID_FIELD.Text = value; }
		}
		public string RELATED_SOURCE_NAME_FIELD
		{
			get { return Regex.Replace(txtRELATED_SOURCE_NAME_FIELD.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtRELATED_SOURCE_NAME_FIELD.Text = value; }
		}
		public string RELATED_VIEW_NAME
		{
			get { return Regex.Replace(txtRELATED_VIEW_NAME.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtRELATED_VIEW_NAME.Text = value; }
		}
		public string RELATED_ID_FIELD
		{
			get { return Regex.Replace(txtRELATED_ID_FIELD.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtRELATED_ID_FIELD.Text = value; }
		}
		public string RELATED_NAME_FIELD
		{
			get { return Regex.Replace(txtRELATED_NAME_FIELD.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtRELATED_NAME_FIELD.Text = value; }
		}
		public string RELATED_JOIN_FIELD
		{
			get { return Regex.Replace(txtRELATED_JOIN_FIELD.Text, @"[^A-Za-z0-9_]", ""); }
			set { txtRELATED_JOIN_FIELD.Text = value; }
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
					     + "  from vwEDITVIEWS_FIELDS        " + ControlChars.CrLf
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
								//this.FIELD_ID                     = Sql.ToGuid   (rdr["ID"                          ]);
								//this.FIELD_INDEX                  = Sql.ToInteger(rdr["FIELD_INDEX"                 ]);
								this.FIELD_TYPE                   = Sql.ToString (rdr["FIELD_TYPE"                  ]);
								this.DATA_LABEL                   = Sql.ToString (rdr["DATA_LABEL"                  ]);
								this.DATA_FIELD                   = Sql.ToString (rdr["DATA_FIELD"                  ]);
								this.DATA_FORMAT                  = Sql.ToString (rdr["DATA_FORMAT"                 ]);
								this.DISPLAY_FIELD                = Sql.ToString (rdr["DISPLAY_FIELD"               ]);
								this.LIST_NAME                    = Sql.ToString (rdr["LIST_NAME"                   ]);
								this.DATA_REQUIRED                = Sql.ToBoolean(rdr["DATA_REQUIRED"               ]);
								this.UI_REQUIRED                  = Sql.ToBoolean(rdr["UI_REQUIRED"                 ]);
								this.ONCLICK_SCRIPT               = Sql.ToString (rdr["ONCLICK_SCRIPT"              ]);
								this.FORMAT_SCRIPT                = Sql.ToString (rdr["FORMAT_SCRIPT"               ]);
								this.FORMAT_TAB_INDEX             = Sql.ToInteger(rdr["FORMAT_TAB_INDEX"            ]);
								this.FORMAT_MAX_LENGTH            = Sql.ToInteger(rdr["FORMAT_MAX_LENGTH"           ]);
								this.FORMAT_SIZE                  = Sql.ToInteger(rdr["FORMAT_SIZE"                 ]);
								this.FORMAT_ROWS                  = Sql.ToInteger(rdr["FORMAT_ROWS"                 ]);
								this.FORMAT_COLUMNS               = Sql.ToInteger(rdr["FORMAT_COLUMNS"              ]);
								this.COLSPAN                      = Sql.ToInteger(rdr["COLSPAN"                     ]);
								this.ROWSPAN                      = Sql.ToInteger(rdr["ROWSPAN"                     ]);
								this.MODULE_TYPE                  = Sql.ToString (rdr["MODULE_TYPE"                 ]);
								this.TOOL_TIP                     = Sql.ToString (rdr["TOOL_TIP"                    ]);
								this.FIELD_VALIDATOR_ID           = Sql.ToGuid   (rdr["FIELD_VALIDATOR_ID"          ]);
								this.FIELD_VALIDATOR_MESSAGE      = Sql.ToString (rdr["FIELD_VALIDATOR_MESSAGE"     ]);
								this.RELATED_SOURCE_MODULE_NAME   = Sql.ToString (rdr["RELATED_SOURCE_MODULE_NAME"  ]);
								this.RELATED_SOURCE_VIEW_NAME     = Sql.ToString (rdr["RELATED_SOURCE_VIEW_NAME"    ]);
								this.RELATED_SOURCE_ID_FIELD      = Sql.ToString (rdr["RELATED_SOURCE_ID_FIELD"     ]);
								this.RELATED_SOURCE_NAME_FIELD    = Sql.ToString (rdr["RELATED_SOURCE_NAME_FIELD"   ]);
								this.RELATED_VIEW_NAME            = Sql.ToString (rdr["RELATED_VIEW_NAME"           ]);
								this.RELATED_ID_FIELD             = Sql.ToString (rdr["RELATED_ID_FIELD"            ]);
								this.RELATED_NAME_FIELD           = Sql.ToString (rdr["RELATED_NAME_FIELD"          ]);
								this.RELATED_JOIN_FIELD           = Sql.ToString (rdr["RELATED_JOIN_FIELD"          ]);
								this.PARENT_FIELD                 = Sql.ToString (rdr["PARENT_FIELD"                ]);
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

		// 09/12/2009 Paul.  Provide default messages for common validators. 
		protected virtual void lstFIELD_VALIDATOR_Changed(Object sender, EventArgs e)
		{
			switch ( lstFIELD_VALIDATOR.SelectedItem.Text )
			{
				case ""                            :  txtFIELD_VALIDATOR_MESSAGE.Text = ""                                    ;  break;
				case "Phone Number"                :  txtFIELD_VALIDATOR_MESSAGE.Text = ".ERR_INVALID_PHONE_NUMBER"           ;  break;
				case "Email Address"               :  txtFIELD_VALIDATOR_MESSAGE.Text = ".ERR_INVALID_EMAIL_ADDRESS"          ;  break;
				case "Positive Decimal"            :  txtFIELD_VALIDATOR_MESSAGE.Text = ".ERR_INVALID_POSITIVE_DECIMAL"       ;  break;
				case "URL"                         :  txtFIELD_VALIDATOR_MESSAGE.Text = ".ERR_INVALID_URL"                    ;  break;
				// 07/06/2017 Paul.  Add missing validator messages. 
				case "Integer"                     :  txtFIELD_VALIDATOR_MESSAGE.Text = ".ERR_INVALID_INTEGER"                ;  break;
				case "Positive Decimal with Commas":  txtFIELD_VALIDATOR_MESSAGE.Text = ".ERR_INVALID_POSITIVE_DECIMAL_COMMAS";  break;
				case "Twitter Message"             :  txtFIELD_VALIDATOR_MESSAGE.Text = ".ERR_TWITTER_MESSAGE"                ;  break;
				case "Twitter Track"               :  txtFIELD_VALIDATOR_MESSAGE.Text = ".ERR_TWITTER_TRACK"                  ;  break;
			}
		}

		// 05/17/2010 Paul.  We need to be able to refresh the visibility flags. 
		public override void lstFIELD_TYPE_Changed(Object sender, EventArgs e)
		{
			// 02/05/2008 Paul.  trFORMAT_ROWS is a union of trTEXT and trLIST_NAME. 
			// 01/19/2010 Paul.  Add support for new DATA_FORMAT field. 
			// 09/16/2012 Paul.  ONCLICK_SCRIPT is valid for ListBox, Radio, CheckBoxList, RelatedListBox, RelateCheckBoxList, CheckBox 
			switch ( lstFIELD_TYPE.SelectedValue )
			{
				case "TextBox"            :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = true ;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = true ;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = true ;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 04/02/2009 Paul.  Add support for FCKEditor to the EditView. 
				case "HtmlEditor"         :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = true ;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 10/07/2010 Paul.  Allow a format for a label.  Also show module type. 
				case "Label"              :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = true ;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = true ;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
				// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
				case "ListBox"            :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = true ;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = true ;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = true ;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = true ;  break;
				// 06/16/2010 Paul.  Radio is just like a ListBox, except for the UI. 
				case "Radio"              :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = true ;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = true ;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 06/16/2010 Paul.  CheckBoxList is just like a ListBox, except for the UI. 
				// 01/06/2018 Paul.  DATA_FORMAT is visible for CheckBoxList. 
				case "CheckBoxList"       :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = true ;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = true ;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = true ;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 09/20/2010 Paul.  Related are just like CheckBoxList. 
				case "RelatedListBox"     :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = true ;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = true ;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "RelatedCheckBoxList":  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = true ;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = true ;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "RelatedSelect"      :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = true ;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "CheckBox"           :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = true ;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "ChangeButton"       :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = true ;  trONCLICK_SCRIPT.Visible = true ;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 05/17/2009 Paul.  Add support for a generic module popup. 
				// 08/04/2010 Paul.  DATA_FORMAT is used to store AutoComplete and UseContextKey flags. 
				case "ModulePopup"        :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = true ;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = true ;  trONCLICK_SCRIPT.Visible = true ;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = true ;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 09/02/2009 Paul.  Add support for ModuleAutoComplete. 
				case "ModuleAutoComplete" :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = true ;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = true ;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 08/26/2009 Paul.  Add support for dynamic teams. 
				case "TeamSelect"         :  trDATA_FIELD.Visible = false;  trDATA_LABEL.Visible = false;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = false;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				case "UserSelect"         :  trDATA_FIELD.Visible = false;  trDATA_LABEL.Visible = false;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = false;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 05/12/2016 Paul.  Add Tags module. 
				case "TagSelect"          :  trDATA_FIELD.Visible = false;  trDATA_LABEL.Visible = false;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = false;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 06/07/2017 Paul.  Add NAICSCodes module. 
				case "NAICSCodeSelect"    :  trDATA_FIELD.Visible = false;  trDATA_LABEL.Visible = false;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = false;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "DatePicker"         :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "DateRange"          :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "DateTimeEdit"       :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				// 06/20/2009 Paul.  Add DateTimeNewRecord so that the NewRecord forms can use the Dynamic rendering. 
				case "DateTimeNewRecord"  :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "DateTimePicker"     :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "Image"              :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = true ;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "File"               :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = true ;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "Password"           :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = true ;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "AddressButtons"     :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
				case "Blank"              :  trDATA_FIELD.Visible = false;  trDATA_LABEL.Visible = false;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = false;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 02/28/2008 Paul.  Hidden field only shows general fields. 
				case "Hidden"             :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = false;  trDATA_FORMAT.Visible = false;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = false;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 09/02/2012 Paul.  A separator is just like a blank. 
				// 09/16/2012 Paul.  The data field can be used as the table id. 
				// 09/20/2012 Paul.  Data Format will store initial visibility state. 
				case "Separator"          :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = false;  trDATA_FORMAT.Visible = true ;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = false;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				case "Header"             :  trDATA_FIELD.Visible = false;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = true ;  trDATA_REQUIRED.Visible = false;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = false;  trFORMAT_ROWS.Visible = false; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = false;  trTOOL_TIP.Visible = false;  trPARENT_FIELD.Visible = false;  break;
				// 04/13/2016 Paul.  Add ZipCode lookup. 
				case "ZipCodePopup"       :  trDATA_FIELD.Visible = true ;  trDATA_LABEL.Visible = true ;  trDATA_FORMAT.Visible = true ;  trDATA_REQUIRED.Visible = true ;  trDISPLAY_FIELD.Visible = false;  trONCLICK_SCRIPT.Visible = false;  trFORMAT_SCRIPT.Visible = false;  trFORMAT_MAX_LENGTH.Visible = true ;  trFORMAT_ROWS.Visible = true ; trLIST_NAME.Visible = false;  trFORMAT_TAB_INDEX.Visible = true ;  trMODULE_TYPE.Visible = false;  trFIELD_VALIDATOR1.Visible = true ;  trTOOL_TIP.Visible = true ;  trPARENT_FIELD.Visible = false;  break;
			}
			// 09/16/2012 Paul.  Rename REQUIRED1 and REQUIRED2 to DATA_REQUIRED and UI_REQUIRED.  
			trUI_REQUIRED     .Visible = trDATA_REQUIRED    .Visible;
			// 09/16/2012 Paul.  Rename CHANGE1 and CHANGE2 to DISPLAY_FIELD and ONCLICK_SCRIPT.  
			//trONCLICK_SCRIPT  .Visible = trDISPLAY_FIELD   .Visible;
			// 09/16/2012 Paul.  Rename TEXT1, TEXT2 and TEXT3 to FORMAT_MAX_LENGTH, FORMAT_SIZE and FORMAT_COLUMNS. 
			// 07/23/2014 Paul.  Allow customization of the size of a ModulePopup text field. 
			trFORMAT_SIZE     .Visible = trFORMAT_MAX_LENGTH.Visible || lstFIELD_TYPE.SelectedValue == "ModulePopup" || lstFIELD_TYPE.SelectedValue == "ChangeButton";
			trFORMAT_COLUMNS  .Visible = trFORMAT_MAX_LENGTH.Visible;
			// 09/16/2012 Paul.  Rename GENERAL1, GENERAL2 and GENERAL3 to FORMAT_TAB_INDEX, COLSPAN and ROWSPAN. 
			trCOLSPAN         .Visible = trFORMAT_TAB_INDEX .Visible;
			trROWSPAN         .Visible = trFORMAT_TAB_INDEX .Visible;
			trFIELD_VALIDATOR2.Visible = trFIELD_VALIDATOR1 .Visible;
			trRELATED1        .Visible = lstFIELD_TYPE.SelectedValue.StartsWith("Related");
			trRELATED2        .Visible = trRELATED1         .Visible;
			trRELATED3        .Visible = trRELATED1         .Visible;
			trRELATED4        .Visible = trRELATED1         .Visible;
			trRELATED5        .Visible = trRELATED1         .Visible;
			trRELATED6        .Visible = trRELATED1         .Visible;
			trRELATED7        .Visible = trRELATED1         .Visible;
			trRELATED8        .Visible = trRELATED1         .Visible;
			if ( lstFIELD_TYPE.SelectedValue == "TeamSelect" )
			{
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstDATA_LABEL, ".LBL_TEAM_SET_NAME");
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstDATA_FIELD, "TEAM_SET_NAME");
					lstMODULE_TYPE.SelectedValue = "";
				}
				catch
				{
				}
			}
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			else if ( lstFIELD_TYPE.SelectedValue == "UserSelect" )
			{
				try
				{
					Utils.SetSelectedValue(lstDATA_LABEL, ".LBL_ASSIGNED_SET_NAME");
					Utils.SetSelectedValue(lstDATA_FIELD, "ASSIGNED_SET_NAME");
					lstMODULE_TYPE.SelectedValue = "";
				}
				catch
				{
				}
			}
			// 05/12/2016 Paul.  Add Tags module. 
			else if ( lstFIELD_TYPE.SelectedValue == "TagSelect" )
			{
				try
				{
					Utils.SetSelectedValue(lstDATA_LABEL, ".LBL_TAG_SET_NAME");
					Utils.SetSelectedValue(lstDATA_FIELD, "TAG_SET_NAME");
					lstMODULE_TYPE.SelectedValue = "";
				}
				catch
				{
				}
			}
			// 06/07/2017 Paul.  Add NAICSCodes module. 
			else if ( lstFIELD_TYPE.SelectedValue == "NAICSCodeSelect" )
			{
				try
				{
					Utils.SetSelectedValue(lstDATA_LABEL, "NAICSCodes.LBL_NAICS_SET_NAME");
					Utils.SetSelectedValue(lstDATA_FIELD, "NAICS_SET_NAME");
					lstMODULE_TYPE.SelectedValue = "";
				}
				catch
				{
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					if ( !this.IsPostBack || lstFIELD_VALIDATOR.Items.Count == 0 )
					{
						string sSQL;
						sSQL = "select ID                " + ControlChars.CrLf
						     + "     , NAME              " + ControlChars.CrLf
						     + "  from vwFIELD_VALIDATORS" + ControlChars.CrLf
						     + " order by NAME           " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								DataTable dt = new DataTable();
								da.Fill(dt);
								dt.Rows.InsertAt(dt.NewRow(), 0);
								lstFIELD_VALIDATOR.DataSource = dt.DefaultView;
								lstFIELD_VALIDATOR.DataBind();
							}
						}
					}
				}
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
		}
		#endregion
	}
}


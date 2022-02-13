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

namespace SplendidCRM.Administration.DynamicLayout.GridViews
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewRecord : DynamicLayout.NewRecord
	{
		// 10/23/2012 Kevin.  Allow me to pass data format for gridview bound columns. 
		protected TextBox                    txtDATA_FORMAT               ;
		protected CheckBox                   chkFREE_FORM_FORMAT          ;
		protected DropDownList               lstDATA_FORMAT               ;
		protected TextBox                    txtITEMSTYLE_WIDTH           ;
		protected TextBox                    txtITEMSTYLE_CSSCLASS        ;
		protected DropDownList               lstITEMSTYLE_HORIZONTAL_ALIGN;
		protected DropDownList               lstITEMSTYLE_VERTICAL_ALIGN  ;
		protected CheckBox                   chkITEMSTYLE_WRAP            ;
		protected TextBox                    txtURL_FIELD                 ;
		protected TextBox                    txtURL_FORMAT                ;
		protected TextBox                    txtURL_TARGET                ;
		protected TextBox                    txtURL_MODULE                ;
		protected TextBox                    txtURL_ASSIGNED_FIELD        ;
		// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
		protected TextBox                    txtPARENT_FIELD              ;
		protected TableRow                   trURL_FIELD                  ;
		protected TableRow                   trURL_FORMAT                 ;
		protected TableRow                   trURL_TARGET                 ;
		protected TableRow                   trURL_MODULE                 ;
		protected TableRow                   trURL_ASSIGNED_FIELD         ;
		protected TableRow                   trMODULE_TYPE                ;
		protected TableRow                   trPARENT_FIELD               ;
		protected HiddenField                txtLAYOUT_FIELD_ID           ;
		protected Button                     btnLAYOUT_FIELD              ;

		public override void Clear()
		{
			base.Clear();
			// 10/23/2012 Kevin.  Allow me to pass data format for gridview bound columns. 
			txtDATA_FORMAT       .Text  = String.Empty;
			chkFREE_FORM_FORMAT  .Checked = false;
			txtDATA_FIELD        .Text  = String.Empty;
			txtITEMSTYLE_WIDTH   .Text  = String.Empty;
			txtITEMSTYLE_CSSCLASS.Text  = String.Empty;
			txtURL_FIELD         .Text  = String.Empty;
			txtURL_FORMAT        .Text  = String.Empty;
			txtURL_TARGET        .Text  = String.Empty;
			txtURL_MODULE        .Text  = String.Empty;
			txtURL_ASSIGNED_FIELD.Text  = String.Empty;
			// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
			txtPARENT_FIELD      .Text  = String.Empty;
			lstDATA_FORMAT               .SelectedIndex = 0;
			lstITEMSTYLE_HORIZONTAL_ALIGN.SelectedIndex = 0;
			lstITEMSTYLE_VERTICAL_ALIGN  .SelectedIndex = 0;
			chkITEMSTYLE_WRAP.Checked = false;
			if ( lstMODULE_TYPE.Items.Count > 0 )
				lstMODULE_TYPE.SelectedIndex = 0;
		}

		// 10/23/2012 Kevin.  Allow me to pass data format for gridview bound columns. 
		public string DATA_FORMAT
		{
			get
			{
				if ( chkFREE_FORM_FORMAT.Checked )
					return txtDATA_FORMAT.Text;
				else
					return lstDATA_FORMAT.SelectedValue;
			}
			set
			{
				ListItem itm = lstDATA_FORMAT.Items.FindByValue(value);
				if ( itm == null )
				{
					txtDATA_FORMAT.Text = value;
					chkFREE_FORM_FORMAT.Checked = true;
					lstFIELD_TYPE_Changed(null, null);
				}
				else
				{
					try
					{
						txtDATA_FORMAT.Text = value;
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstDATA_FORMAT, value);
						chkFREE_FORM_FORMAT.Checked = false;
						lstFIELD_TYPE_Changed(null, null);
					}
					catch
					{
						txtDATA_FORMAT.Text = value;
						chkFREE_FORM_FORMAT.Checked = true;
					}
				}
				chkFREE_FORM_FORMAT_CheckedChanged(null, null);
			}
		}

		public string ITEMSTYLE_WIDTH
		{
			get { return txtITEMSTYLE_WIDTH.Text; }
			set { txtITEMSTYLE_WIDTH.Text = value; }
		}

		public string ITEMSTYLE_CSSCLASS
		{
			get { return txtITEMSTYLE_CSSCLASS.Text; }
			set { txtITEMSTYLE_CSSCLASS.Text = value; }
		}

		public string ITEMSTYLE_HORIZONTAL_ALIGN
		{
			get
			{
				return lstITEMSTYLE_HORIZONTAL_ALIGN.SelectedValue;
			}
			set
			{
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstITEMSTYLE_HORIZONTAL_ALIGN, value);
				}
				catch
				{
				}
			}
		}

		public string ITEMSTYLE_VERTICAL_ALIGN
		{
			get
			{
				return lstITEMSTYLE_VERTICAL_ALIGN.SelectedValue;
			}
			set
			{
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstITEMSTYLE_VERTICAL_ALIGN, value);
				}
				catch
				{
				}
			}
		}

		public bool ITEMSTYLE_WRAP
		{
			get { return chkITEMSTYLE_WRAP.Checked; }
			set { chkITEMSTYLE_WRAP.Checked = value; }
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

		public string URL_MODULE
		{
			get { return txtURL_MODULE.Text; }
			set { txtURL_MODULE.Text = value; }
		}

		public string URL_ASSIGNED_FIELD
		{
			get { return txtURL_ASSIGNED_FIELD.Text; }
			set { txtURL_ASSIGNED_FIELD.Text = value; }
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
					     + "  from vwGRIDVIEWS_COLUMNS       " + ControlChars.CrLf
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
								//this.FIELD_ID                   = Sql.ToGuid   (rdr["ID"                        ]);
								//this.FIELD_INDEX                = Sql.ToInteger(rdr["COLUMN_INDEX"              ]);
								this.FIELD_TYPE                 = Sql.ToString (rdr["COLUMN_TYPE"               ]);
								this.DATA_FORMAT                = Sql.ToString (rdr["DATA_FORMAT"               ]);
								this.DATA_LABEL                 = Sql.ToString (rdr["HEADER_TEXT"               ]);
								this.DATA_FIELD                 = Sql.ToString (rdr["DATA_FIELD"                ]);
								this.SORT_EXPRESSION            = Sql.ToString (rdr["SORT_EXPRESSION"           ]);
								this.ITEMSTYLE_WIDTH            = Sql.ToString (rdr["ITEMSTYLE_WIDTH"           ]);
								this.ITEMSTYLE_CSSCLASS         = Sql.ToString (rdr["ITEMSTYLE_CSSCLASS"        ]);
								this.ITEMSTYLE_HORIZONTAL_ALIGN = Sql.ToString (rdr["ITEMSTYLE_HORIZONTAL_ALIGN"]);
								this.ITEMSTYLE_VERTICAL_ALIGN   = Sql.ToString (rdr["ITEMSTYLE_VERTICAL_ALIGN"  ]);
								this.ITEMSTYLE_WRAP             = Sql.ToBoolean(rdr["ITEMSTYLE_WRAP"            ]);
								this.URL_FIELD                  = Sql.ToString (rdr["URL_FIELD"                 ]);
								this.URL_FORMAT                 = Sql.ToString (rdr["URL_FORMAT"                ]);
								this.URL_TARGET                 = Sql.ToString (rdr["URL_TARGET"                ]);
								this.URL_MODULE                 = Sql.ToString (rdr["URL_MODULE"                ]);
								this.URL_ASSIGNED_FIELD         = Sql.ToString (rdr["URL_ASSIGNED_FIELD"        ]);
								this.LIST_NAME                  = Sql.ToString (rdr["LIST_NAME"                 ]);
								this.MODULE_TYPE                = Sql.ToString (rdr["MODULE_TYPE"               ]);
								this.PARENT_FIELD               = Sql.ToString (rdr["PARENT_FIELD"              ]);
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
			// 06/19/2010 Paul.  JavaScript data format show show URL Field, Format and Target. 
			// 08/02/2010 Paul.  The Hover control is very similar to a JavaScript control. 
			// 02/28/2014 Paul.  JavaImage is just like JavaScript, but shows an icon. 
			// 03/01/2014 Paul.  ImageButton is just like JavaScript, but shows an icon and has a command event. 
			trURL_FIELD         .Visible = (lstFIELD_TYPE.SelectedValue == "HyperLinkColumn" || lstDATA_FORMAT.SelectedValue == "HyperLink" || lstDATA_FORMAT.SelectedValue == "JavaScript" || lstDATA_FORMAT.SelectedValue == "Hover" || lstDATA_FORMAT.SelectedValue == "JavaImage" || lstDATA_FORMAT.SelectedValue == "ImageButton");
			// 08/15/2014 Paul.  Show the URL_FORMAT for Images so that we can point to the EmailImages URL. 
			trURL_FORMAT        .Visible = (lstFIELD_TYPE.SelectedValue == "HyperLinkColumn" || lstDATA_FORMAT.SelectedValue == "HyperLink" || lstDATA_FORMAT.SelectedValue == "JavaScript" || lstDATA_FORMAT.SelectedValue == "Hover" || lstDATA_FORMAT.SelectedValue == "JavaImage" || lstDATA_FORMAT.SelectedValue == "ImageButton" || lstDATA_FORMAT.SelectedValue == "Image");
			trURL_TARGET        .Visible = (lstFIELD_TYPE.SelectedValue == "HyperLinkColumn" || lstDATA_FORMAT.SelectedValue == "HyperLink" || lstDATA_FORMAT.SelectedValue == "JavaScript" || lstDATA_FORMAT.SelectedValue == "Hover" || lstDATA_FORMAT.SelectedValue == "JavaImage" || lstDATA_FORMAT.SelectedValue == "ImageButton");
			trURL_MODULE        .Visible = (lstFIELD_TYPE.SelectedValue == "HyperLinkColumn" || lstDATA_FORMAT.SelectedValue == "HyperLink");
			trURL_ASSIGNED_FIELD.Visible = (lstFIELD_TYPE.SelectedValue == "HyperLinkColumn" || lstDATA_FORMAT.SelectedValue == "HyperLink");
			// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
			trPARENT_FIELD      .Visible = (lstFIELD_TYPE.SelectedValue == "HyperLinkColumn" || lstDATA_FORMAT.SelectedValue == "HyperLink");
			// 02/17/2010 Paul.  The Module Type only applies to TemplateColumn HyperLink. 
			trMODULE_TYPE.Visible = (lstFIELD_TYPE.SelectedValue == "TemplateColumn"  && lstDATA_FORMAT.SelectedValue == "HyperLink");
		}

		// 10/23/2012 Kevin.  Allow me to pass data format for gridview bound columns. 
		protected void chkFREE_FORM_FORMAT_CheckedChanged(Object sender, EventArgs e)
		{
			if ( !chkFREE_FORM_FORMAT.Checked )
			{
				// 01/10/2006 Paul.  Validate the ability to turn off free form.
				txtDATA_FORMAT.Text = txtDATA_FORMAT.Text.Trim();
				ListItem itm = lstDATA_FORMAT.Items.FindByValue(txtDATA_FORMAT.Text);
				if ( itm == null )
				{
					chkFREE_FORM_FORMAT.Checked = true;
				}
				else
				{
					try
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstDATA_FORMAT, txtDATA_FORMAT.Text);
					}
					catch
					{
						// 01/10/2006 Paul.  If there is an error, then go back to free form. 
						chkFREE_FORM_FORMAT.Checked = true;
					}
				}
			}
			txtDATA_FORMAT.Visible =  chkFREE_FORM_FORMAT.Checked;
			lstDATA_FORMAT.Visible = !chkFREE_FORM_FORMAT.Checked;
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


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

namespace SplendidCRM.Administration.DynamicLayout
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewRecord : SplendidControl
	{
		public CommandEventHandler Command ;

		protected string             sMODULE_NAME      ;
		protected string             sVIEW_NAME        ;

		protected Label              lblError          ;
		protected HiddenField        txtFIELD_ID       ;
		protected Label              txtFIELD_INDEX    ;
		protected DropDownList       lstFIELD_TYPE     ;
		protected TextBox            txtDATA_LABEL     ;
		protected DropDownList       lstDATA_LABEL     ;
		protected TextBox            txtDATA_FIELD     ;
		protected DropDownList       lstDATA_FIELD     ;
		// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
		protected DropDownList       lstMODULE_TYPE    ;  // ModulePopup only on EditView.  String and HyperLink only on DetailView. 
		protected DropDownList       lstLIST_NAME      ;
		protected CheckBox           chkFREE_FORM_LABEL;
		protected CheckBox           chkFREE_FORM_DATA ;
		protected DropDownList       lstSORT_EXPRESSION;

		//protected RequiredFieldValidator     reqNAME        ;

		public virtual void Clear()
		{
			txtFIELD_ID   .Value = String.Empty;
			txtFIELD_INDEX.Text  = String.Empty;
			txtDATA_LABEL .Text  = String.Empty;
			txtDATA_FIELD .Text  = String.Empty;
			chkFREE_FORM_LABEL.Checked = false;
			chkFREE_FORM_DATA .Checked = false;
			// 04/19/2009 Paul.  When clearing the NewRecord control, we must also reset the data field listbox. 
			txtDATA_FIELD.Visible =  chkFREE_FORM_DATA.Checked;
			lstDATA_FIELD.Visible = !chkFREE_FORM_DATA.Checked;
			txtDATA_LABEL.Visible =  chkFREE_FORM_LABEL.Checked;
			lstDATA_LABEL.Visible = !chkFREE_FORM_LABEL.Checked;

			// 07/27/2010 Paul.  ClearSelection should be safer than SelectedIndex. 
			lstFIELD_TYPE.ClearSelection();
			lstDATA_LABEL.ClearSelection();
			lstDATA_FIELD.ClearSelection();
			lstLIST_NAME .ClearSelection();
			if ( lstSORT_EXPRESSION != null )
				lstSORT_EXPRESSION.ClearSelection();
			lstMODULE_TYPE.ClearSelection();
			this.Visible = false;
			// 05/17/2010 Paul.  Make sure to update the visibility flags. 
			lstFIELD_TYPE_Changed(null, null);
		}

		public string MODULE_NAME
		{
			get
			{
				return sMODULE_NAME;
			}
			set
			{
				sMODULE_NAME = value;
				lstDATA_LABEL_Bind();
			}
		}

		public string VIEW_NAME
		{
			get
			{
				return sVIEW_NAME;
			}
			set
			{
				sVIEW_NAME = value;
				lstDATA_FIELD_Bind();
			}
		}

		public string FIELD_TYPE
		{
			get
			{
				return lstFIELD_TYPE.SelectedValue;
			}
			set
			{
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstFIELD_TYPE, value);
					lstFIELD_TYPE_Changed(null, null);
				}
				catch
				{
				}
			}
		}

		public Guid FIELD_ID
		{
			get { return Sql.ToGuid(txtFIELD_ID.Value); }
			set { txtFIELD_ID.Value = value.ToString(); }
		}

		public int FIELD_INDEX
		{
			get
			{
				if ( txtFIELD_INDEX.Text == String.Empty )
					return -1;
				else
					return Sql.ToInteger(txtFIELD_INDEX.Text);
			}
			set
			{
				if ( value == -1 )
					txtFIELD_INDEX.Text = String.Empty;
				else
					txtFIELD_INDEX.Text = value.ToString();
			}
		}

		public string DATA_LABEL
		{
			get
			{
				if ( chkFREE_FORM_LABEL.Checked )
					return txtDATA_LABEL.Text;
				else
					return lstDATA_LABEL.SelectedValue;
			}
			set
			{
				// 01/10/2006 Paul.  Always try and select the label from the list. 
				txtDATA_LABEL.Text = value;
				// 08/19/2010 Paul.  Check the list before assigning the value. 
				// 09/13/2010 Paul.  SetSelectedValue will not throw an exception.  If not found, manually check the free form flag. 
				if ( Utils.SetSelectedValue(lstDATA_LABEL, value) )
				{
					chkFREE_FORM_LABEL.Checked = false;
				}
				else
				{
					// 01/10/2006 Paul.  If value does not exist, then go to free form. 
					txtDATA_LABEL.Text = value;
					chkFREE_FORM_LABEL.Checked = true;
				}
				chkFREE_FORM_LABEL_CheckedChanged(null, null);
			}
		}

		public string DATA_FIELD
		{
			get
			{
				if ( chkFREE_FORM_DATA.Checked )
					return txtDATA_FIELD.Text;
				else
					return lstDATA_FIELD.SelectedValue;
			}
			set
			{
				if ( value.IndexOf(" ") >= 0 || value.IndexOf(".") >= 0 )
				{
					txtDATA_FIELD.Text = value;
					chkFREE_FORM_DATA.Checked = true;
				}
				else
				{
					try
					{
						txtDATA_FIELD.Text = value;
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstDATA_FIELD, value);
						chkFREE_FORM_DATA.Checked = false;
					}
					catch
					{
						txtDATA_FIELD.Text = value;
						chkFREE_FORM_DATA.Checked = true;
					}
				}
				chkFREE_FORM_DATA_CheckedChanged(null, null);
			}
		}

		public string LIST_NAME
		{
			get
			{
				return lstLIST_NAME.SelectedValue;
			}
			set
			{
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstLIST_NAME, value);
				}
				catch
				{
				}
			}
		}

		// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
		public string MODULE_TYPE
		{
			get { return lstMODULE_TYPE.SelectedValue; }
			set
			{
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstMODULE_TYPE, value);
				}
				catch
				{
				}
			}
		}

		public string SORT_EXPRESSION
		{
			get
			{
				return lstSORT_EXPRESSION.SelectedValue;
			}
			set
			{
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstSORT_EXPRESSION, value);
				}
				catch
				{
				}
			}
		}

		// 05/17/2010 Paul.  We need to be able to refresh the visibility flags. 
		public virtual void lstFIELD_TYPE_Changed(Object sender, EventArgs e)
		{
		}

		protected void chkFREE_FORM_LABEL_CheckedChanged(Object sender, EventArgs e)
		{
			if ( !chkFREE_FORM_LABEL.Checked )
			{
				// 01/10/2006 Paul.  Validate the ability to turn off free form.
				txtDATA_LABEL.Text = txtDATA_LABEL.Text.Trim();
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstDATA_LABEL, txtDATA_LABEL.Text);
				}
				catch
				{
					// 01/10/2006 Paul.  If there is an error, then go back to free form. 
					chkFREE_FORM_LABEL.Checked = true;
				}
			}
			txtDATA_LABEL.Visible =  chkFREE_FORM_LABEL.Checked;
			lstDATA_LABEL.Visible = !chkFREE_FORM_LABEL.Checked;
		}

		protected void chkFREE_FORM_DATA_CheckedChanged(Object sender, EventArgs e)
		{
			if ( !chkFREE_FORM_DATA.Checked )
			{
				// 01/10/2006 Paul.  Validate the ability to turn off free form.
				txtDATA_FIELD.Text = txtDATA_FIELD.Text.Trim();
				if ( txtDATA_FIELD.Text.IndexOf(" ") >= 0 || txtDATA_FIELD.Text.IndexOf(".") >= 0 )
				{
					chkFREE_FORM_DATA.Checked = true;
				}
				else
				{
					try
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstDATA_FIELD, txtDATA_FIELD.Text);
					}
					catch
					{
						// 01/10/2006 Paul.  If there is an error, then go back to free form. 
						chkFREE_FORM_DATA.Checked = true;
					}
				}
			}
			txtDATA_FIELD.Visible =  chkFREE_FORM_DATA.Checked;
			lstDATA_FIELD.Visible = !chkFREE_FORM_DATA.Checked;
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "NewRecord.Save" || e.CommandName == "NewRecord.Cancel" )
			{
				//reqNAME.Enabled = true;
				//reqNAME.Validate();
				if ( Page.IsValid )
				{
					Guid gID = Guid.Empty;
					try
					{
						if ( Command != null )
							Command(this, e) ;
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
					}
				}
			}
		}

		protected void lstDATA_LABEL_Bind()
		{
			DataTable dt = null;
			if ( !Sql.IsEmptyString(sMODULE_NAME) && sMODULE_NAME != Sql.ToString(ViewState["LAST_MODULE_NAME"]) )
			{
				try
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL;
						sSQL = "select NAME                      " + ControlChars.CrLf
						     + "     , DISPLAY_NAME              " + ControlChars.CrLf
						     + "     , MODULE_NAME               " + ControlChars.CrLf
						     + "  from vwTERMINOLOGY_LayoutLabel " + ControlChars.CrLf
						     + " where MODULE_NAME is null       " + ControlChars.CrLf
						     + "    or MODULE_NAME = @MODULE_NAME" + ControlChars.CrLf
						     + " order by NAME                   " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@MODULE_NAME", sMODULE_NAME);
						
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								dt = new DataTable();
								da.Fill(dt);
								dt.Rows.InsertAt(dt.NewRow(), 0);
								//ViewState["vwTERMINOLOGY_Labels"] = dt;
								ViewState["LAST_MODULE_NAME"] = sMODULE_NAME;
								lstDATA_LABEL.DataSource = dt;
								lstDATA_LABEL.DataBind();
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
		}

		protected void lstDATA_FIELD_Bind()
		{
			DataTable dt = null;
			if ( !Sql.IsEmptyString(sVIEW_NAME) && sVIEW_NAME != Sql.ToString(ViewState["LAST_VIEW_NAME"]) )
			{
				try
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL;
						// 02/29/2008 Niall.  Some SQL Server 2005 installations require matching case for the parameters. 
						// Since we force the parameter to be uppercase, we must also make it uppercase in the command text. 
						sSQL = "select *                       " + ControlChars.CrLf
						     + "  from vwSqlColumns            " + ControlChars.CrLf
						     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
						     + " order by ColumnName           " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							// 09/02/2008 Paul.  Standardize the case of metadata tables to uppercase.  PostgreSQL defaults to lowercase. 
							Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sVIEW_NAME));
						
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								dt = new DataTable();
								da.Fill(dt);
								dt.Rows.InsertAt(dt.NewRow(), 0);
								ViewState["vwSqlColumns_Fields"] = dt;
								ViewState["LAST_VIEW_NAME"     ] = sVIEW_NAME;
								lstDATA_FIELD.DataSource = dt;
								lstDATA_FIELD.DataBind();
								if ( lstSORT_EXPRESSION != null )
								{
									lstSORT_EXPRESSION.DataSource = dt;
									lstSORT_EXPRESSION.DataBind();
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
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					if ( !this.IsPostBack || lstLIST_NAME.Items.Count == 0 )
					{
						string sSQL;
						sSQL = "select LIST_NAME             " + ControlChars.CrLf
						     + "  from vwTERMINOLOGY_PickList" + ControlChars.CrLf
						     + " order by LIST_NAME          " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								DataTable dt = new DataTable();
								da.Fill(dt);
								// 01/07/2006 Paul.  Having a problem with manual list inserts getting lost.  Try modifying the table. 
								// 07/15/2007 Paul.  There are a bunch more cached lists that need to be added. 
								// 08/17/2007 Paul.  We forgot to include the blank string.  
								// Without the blank string, all data fields would need to be associated with a list, which is a major problem. 
								// 11/19/2008 Paul.  Use the CustomCaches list to prevent any future omissions.
								// 10/04/2015 Paul.  Changed custom caches to a dynamic list. 
								for ( int i = 0; i < SplendidCache.CustomCaches.Count; i++ )
								{
									DataRow row = dt.NewRow();
									row["LIST_NAME"] = SplendidCache.CustomCaches[i].Name;
									dt.Rows.InsertAt(row, i);
								}
								// 12/04/2008 Paul.  Add the blank string back. 
								dt.Rows.InsertAt(dt.NewRow(), 0);
								lstLIST_NAME.DataSource = dt.DefaultView;
								lstLIST_NAME.DataBind();
							}
						}
						lstFIELD_TYPE_Changed(null, null);
					}
					// 02/16/2010 Paul.  Dynamically populate the module list. 
					if ( !this.IsPostBack || lstMODULE_TYPE.Items.Count == 0 )
					{
						/*
						string sSQL;
						sSQL = "select MODULE_NAME          " + ControlChars.CrLf
						     + "  from vwMODULES_LayoutViews" + ControlChars.CrLf
						     + " order by MODULE_NAME       " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								DataTable dt = new DataTable();
								da.Fill(dt);
								// 02/16/2010 Paul.  Add the blank string back. 
								dt.Rows.InsertAt(dt.NewRow(), 0);
								lstMODULE_TYPE.DataSource = dt.DefaultView;
								lstMODULE_TYPE.DataBind();
							}
						}
						*/
						// 11/10/2011 Paul.  vwMODULES_LayoutViews requires the Report Enabled flag.  Using ModulesPopup is a better solution. 
						DataTable dtModules = SplendidCache.ModulesPopups(this.Context).Copy();
						// 04/20/2012 Paul.  Need to set HAS_POPUP to 1. 
						DataRow rowEmpty = dtModules.NewRow();
						rowEmpty["HAS_POPUP"] = 1;
						dtModules.Rows.InsertAt(rowEmpty, 0);
						DataView vwModules = new DataView(dtModules);
						vwModules.RowFilter = "HAS_POPUP = 1";
						lstMODULE_TYPE.DataSource = vwModules;
						lstMODULE_TYPE.DataBind();
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
			// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
			//this.DataBind();  // Need to bind so that Text of the Button gets updated. 
			//reqNAME.ErrorMessage = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("DynamicLayout.LBL_DATA_NAME") + "<br>";
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


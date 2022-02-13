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
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Xml;
using System.Diagnostics;
using System.Globalization;

namespace SplendidCRM.Administration.Currencies
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;
		// 01/13/2010 Paul.  Add footer buttons. 
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected Guid            gID                          ;
		protected TextBox         txtNAME                      ;
		protected TextBox         txtSYMBOL                    ;
		protected TextBox         txtISO4217                   ;
		protected TextBox         txtCONVERSION_RATE           ;
		protected DropDownList    lstSTATUS                    ;
		protected RequiredFieldValidator reqNAME           ;
		protected RequiredFieldValidator reqSYMBOL         ;
		protected RequiredFieldValidator reqISO4217        ;
		protected RequiredFieldValidator reqCONVERSION_RATE;
		protected RegularExpressionValidator regCONVERSION_RATE;

		protected _controls.ListHeader ctlListHeader ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				try
				{
					if ( Page.IsValid )
					{
						// 09/09/2009 Paul.  Use the new function to get the table name. 
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									float dCONVERSION_RATE = float.Parse(txtCONVERSION_RATE.Text, NumberStyles.AllowDecimalPoint);
									// 05/10/2006 Paul.  Sql.ToFloat() was having a problem when an alternate decimal point is used. 
									SqlProcs.spCURRENCIES_Update
										( ref gID
										, txtNAME.Text
										, txtSYMBOL.Text
										, txtISO4217.Text
										, dCONVERSION_RATE
										, lstSTATUS.SelectedValue
										, trn
										);
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									trn.Commit();
									// 04/20/2006 Paul.  Make sure to clear the cache. 
									Cache.Remove("vwCURRENCIES_LISTBOX");
									// 07/07/2007 Paul.  The currency in the application scope needs to be updated. 
									// 11/10/2008 Paul.  PayPal uses the ISO value. 
									// 04/30/2016 Paul.  Require the Application so that we can get the base currency. 
									Currency C10n = new Currency
										( Application
										, gID
										, txtNAME.Text
										, txtSYMBOL.Text
										, txtISO4217.Text
										, dCONVERSION_RATE
										);
									Application["CURRENCY." + C10n.ID.ToString()] = C10n;
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
						}
						Response.Redirect("default.aspx");
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("default.aspx");
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Currencies.LBL_CURRENCY"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();  // 09/03/2005 Paul. DataBind is required in order for the RequiredFieldValidators to work. 
				// 07/02/2006 Paul.  The required fields need to be bound manually. 
				reqNAME.DataBind();
				reqSYMBOL.DataBind();
				reqISO4217.DataBind();
				reqCONVERSION_RATE.DataBind();
				// 10/18/2010 Paul.  The required fields need to be bound manually. 
				regCONVERSION_RATE.DataBind();
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);

					// 10/20/2013 Paul.  Lists are no longer module-specific. 
					lstSTATUS.DataSource = SplendidCache.List("currency_status_dom");
					lstSTATUS.DataBind();
					
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *                " + ControlChars.CrLf
							     + "  from vwCURRENCIES_Edit" + ControlChars.CrLf
							     + " where ID = @ID         " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AddParameter(cmd, "@ID", gDuplicateID);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AddParameter(cmd, "@ID", gID);
								}
								con.Open();

								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											txtNAME          .Text  = Sql.ToString(rdr["NAME"         ]);
											ctlListHeader    .Title = L10n.Term("Currencies.LBL_CURRENCY") + ": " + txtNAME.Text;
											SetPageTitle(L10n.Term("Currencies.LBL_MODULE_NAME") + " - " + txtNAME.Text);
											txtSYMBOL.Text          = Sql.ToString(rdr["SYMBOL"         ]);
											txtISO4217.Text         = Sql.ToString(rdr["ISO4217"        ]);
											txtCONVERSION_RATE.Text = Sql.ToString(rdr["CONVERSION_RATE"]);
											try
											{
												// 08/19/2010 Paul.  Check the list before assigning the value. 
												Utils.SetSelectedValue(lstSTATUS, Sql.ToString(rdr["STATUS"]));
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
										}
									}
								}
							}
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
			// 04/14/2008 Paul.  Need to handle the button events. 
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Currencies";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
			}
		}
		#endregion
	}
}


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

namespace SplendidCRM.Administration.Terminology
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		// 01/13/2010 Paul.  Add footer buttons. 
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected Guid                       gID                ;
		protected TextBox                    txtNAME            ;
		protected TextBox                    txtDISPLAY_NAME    ;
		protected DropDownList               lstLANGUAGE        ;
		protected DropDownList               lstMODULE_NAME     ;
		protected DropDownList               lstLIST_NAME       ;
		protected TextBox                    txtLIST_ORDER      ;
		protected RequiredFieldValidator     reqNAME            ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				if ( Page.IsValid )
				{
					reqNAME.Enabled = true;
					reqNAME.Validate();
					if ( Page.IsValid )
					{
						Guid gID = Guid.Empty;
						try
						{
							SqlProcs.spTERMINOLOGY_Update(txtNAME.Text, lstLANGUAGE.SelectedValue, lstMODULE_NAME.SelectedValue, lstLIST_NAME.SelectedValue, Sql.ToInteger(txtLIST_ORDER.Text), txtDISPLAY_NAME.Text);
							// 01/16/2006 Paul.  Update language cache. 
							if ( Sql.IsEmptyString(lstLIST_NAME.SelectedValue) )
								L10N.SetTerm(lstLANGUAGE.SelectedValue, lstMODULE_NAME.SelectedValue, txtNAME.Text, txtDISPLAY_NAME.Text);
							else
								L10N.SetTerm(lstLANGUAGE.SelectedValue, lstMODULE_NAME.SelectedValue, lstLIST_NAME.SelectedValue, txtNAME.Text, txtDISPLAY_NAME.Text);
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							ctlDynamicButtons.ErrorText = ex.Message;
							return;
						}
					}
					Response.Redirect("default.aspx");
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("default.aspx");
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList.Terminology"));
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
				// 10/18/2010 Paul.  The required fields need to be bound manually. 
				reqNAME.DataBind();
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);

					lstLANGUAGE.DataSource = SplendidCache.Languages();
					lstLANGUAGE.DataBind();

					lstMODULE_NAME.DataSource = SplendidCache.Modules();
					lstMODULE_NAME.DataBind();
					lstMODULE_NAME.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));

					lstLIST_NAME  .DataSource = SplendidCache.TerminologyPickLists();
					lstLIST_NAME  .DataBind();
					lstLIST_NAME  .Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));

					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *                 " + ControlChars.CrLf
							     + "  from vwTERMINOLOGY_Edit" + ControlChars.CrLf
							     + " where ID = @ID          " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@ID", gID);
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
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList.Terminology") + " - " + ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;

											// 01/20/2006 Paul.  Don't allow the name to be changed.  Require a new term. 
											txtNAME.ReadOnly = true;

											txtNAME        .Text = Sql.ToString(rdr["NAME"        ]);
											txtDISPLAY_NAME.Text = Sql.ToString(rdr["DISPLAY_NAME"]);
											if ( Sql.ToInteger(rdr["LIST_ORDER"]) > 0 )
												txtLIST_ORDER.Text = Sql.ToString(rdr["LIST_ORDER"]);
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetSelectedValue(lstLANGUAGE, L10N.NormalizeCulture(Sql.ToString(rdr["LANG"])));
											string sMODULE_NAME = Sql.ToString(rdr["MODULE_NAME"]);
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											// 08/31/2010 Paul.  SetSelectedValue will return false and not throw an exception if not found. 
											if ( !Utils.SetSelectedValue(lstMODULE_NAME, sMODULE_NAME) )
											{
												// 01/12/2006 Paul.  If module does not exist in our table, then add it to prevent data loss. 
												lstMODULE_NAME.Items.Add(sMODULE_NAME);
												// 08/19/2010 Paul.  Check the list before assigning the value. 
												Utils.SetSelectedValue(lstMODULE_NAME, sMODULE_NAME);
											}
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetSelectedValue(lstLIST_NAME, Sql.ToString(rdr["LIST_NAME"]));
										}
									}
								}
							}
						}
					}
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList.Administration") + " - " + ctlDynamicButtons.Title);
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
			// CODEGEN: This Task is required by the ASP.NET Web Form Designer.
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Terminology";
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


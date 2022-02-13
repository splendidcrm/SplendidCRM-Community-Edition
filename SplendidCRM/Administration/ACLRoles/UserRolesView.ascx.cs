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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.ACLRoles
{
	/// <summary>
	///		Summary description for UserRolesView.
	/// </summary>
	public class UserRolesView : SplendidControl
	{
		protected DataView           vwMain         ;
		protected SplendidGrid       grdMain        ;
		protected Label              lblError       ;
		protected HtmlInputHidden    txtROLE_ID     ;
		protected AccessView         ctlAccessView  ;
		protected DropDownList       lstUSERS       ;
		protected Button             btnSelectRole  ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "Search":
					{
						break;
					}
					case "Roles.Edit":
					{
						Guid gROLE_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/Administration/ACLRoles/edit.aspx?ID=" + gROLE_ID.ToString());
						break;
					}
					case "Roles.Remove":
					{
						Guid gUSER_ID = Sql.ToGuid(lstUSERS.SelectedValue);
						Guid gROLE_ID = Sql.ToGuid(e.CommandArgument);
						SqlProcs.spACL_ROLES_USERS_Delete(gROLE_ID, gUSER_ID);
						// 05/03/2006 Paul.  Don't redirect so that the selected user will not change. 
						//Response.Redirect("RolesByUser.aspx");
						// 05/03/2006 Paul.  We do have to rebind after the modification. 
						BindGrid();
						// 12/07/2006 Paul.  We need to rebind the access view after changing the roles. 
						ctlAccessView.BindGrid();
						break;
					}
					default:
						throw(new Exception("Unknown command: " + e.CommandName));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		protected void BindGrid()
		{
			Guid gUSER_ID = Sql.ToGuid(lstUSERS.SelectedValue);
			if ( Sql.IsEmptyGuid(gUSER_ID) )
			{
				ctlAccessView.Visible = false;
				btnSelectRole.Visible = false;
				grdMain.Visible = false;
				return;
			}
			ctlAccessView.USER_ID = gUSER_ID;
			ctlAccessView.Visible = true;
			btnSelectRole.Visible = true;
			grdMain.Visible = true;

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				sSQL = "select *                 " + ControlChars.CrLf
				     + "  from vwUSERS_ACL_ROLES " + ControlChars.CrLf
				     + " where 1 = 1             " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AppendParameter(cmd, gUSER_ID, "USER_ID");

					if ( bDebug )
						RegisterClientScriptBlock("vwUSER_ACL_ROLES", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								// 05/03/2006 Paul.  Always bind, so that we don't have to redirect to show changes. 
								//if ( !IsPostBack )
								{
									grdMain.SortColumn = "ROLE_NAME";
									grdMain.SortOrder  = "asc" ;
									grdMain.ApplySort();
									grdMain.DataBind();
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
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}
			if ( !IsPostBack )
			{
				lstUSERS.DataSource = SplendidCache.AssignedUser();
				lstUSERS.DataBind();
				lstUSERS.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
			}

			Guid gUSER_ID = Sql.ToGuid(lstUSERS.SelectedValue);
			if ( !Sql.IsEmptyString(txtROLE_ID.Value) && !Sql.IsEmptyGuid(gUSER_ID) )
			{
				try
				{
					SqlProcs.spUSERS_ACL_ROLES_MassUpdate(gUSER_ID, txtROLE_ID.Value);
					// 05/03/2006 Paul.  Don't redirect so that the selected user will not change. 
					//Response.Redirect("RolesByUser.aspx");
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblError.Text = ex.Message;
				}
			}
			BindGrid();

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
			m_sMODULE = "Users";
		}
		#endregion
	}
}


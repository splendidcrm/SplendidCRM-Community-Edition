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

namespace SplendidCRM.ProspectLists
{
	/// <summary>
	///		Summary description for Users.
	/// </summary>
	public class Users : SubPanelControl
	{
		// 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
		protected _controls.SubPanelButtons ctlDynamicButtons;
		protected UniqueStringCollection arrSelectFields;
		protected Guid            gID            ;
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected HtmlInputHidden txtUSER_ID     ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "Users.Edit":
					{
						Guid gUSER_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/Users/edit.aspx?ID=" + gUSER_ID.ToString());
						break;
					}
					case "Users.Remove":
					{
						Guid gUSER_ID = Sql.ToGuid(e.CommandArgument);
						if ( bEditView )
						{
							this.DeleteEditViewRelationship(gUSER_ID);
						}
						else
						{
							SqlProcs.spPROSPECT_LISTS_USERS_Delete(gID, gUSER_ID);
						}
						//Response.Redirect("view.aspx?ID=" + gID.ToString());
						// 05/16/2008 Paul.  Instead of redirecting, just rebind the grid and AJAX will repaint. 
						BindGrid();
						break;
					}
					default:
						throw(new Exception("Unknown command: " + e.CommandName));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void BindGrid()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
					if ( bEditView && IsPostBack && arrUPDATED.Count > 0 )
					{
						arrSelectFields.Remove("USER_ID"                  );
						arrSelectFields.Remove("USER_NAME"                );
						arrSelectFields.Remove("PROSPECT_LIST_ID"         );
						arrSelectFields.Remove("PROSPECT_LIST_NAME"       );
						arrSelectFields.Remove("PROSPECT_ASSIGNED_USER_ID");
						arrSelectFields.Remove("PROSPECT_DYNAMIC_LIST"    );
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + "     , ID                         as USER_ID                  " + ControlChars.CrLf
						     + "     , NAME                       as USER_NAME                " + ControlChars.CrLf
						     + "     , @PROSPECT_LIST_ID          as PROSPECT_LIST_ID         " + ControlChars.CrLf
						     + "     , @PROSPECT_LIST_NAME        as PROSPECT_LIST_NAME       " + ControlChars.CrLf
						     + "     , @PROSPECT_ASSIGNED_USER_ID as PROSPECT_ASSIGNED_USER_ID" + ControlChars.CrLf
						     + "     , @PROSPECT_DYNAMIC_LIST     as PROSPECT_DYNAMIC_LIST    " + ControlChars.CrLf
						     + "  from vwUSERS" + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@PROSPECT_LIST_ID"         , gID);
						Sql.AddParameter(cmd, "@PROSPECT_LIST_NAME"       , Sql.ToString (Page.Items["NAME"                 ]));
						Sql.AddParameter(cmd, "@PROSPECT_ASSIGNED_USER_ID", Sql.ToGuid   (Page.Items["ASSIGNED_USER_ID"     ]));
						Sql.AddParameter(cmd, "@PROSPECT_DYNAMIC_LIST"    , Sql.ToBoolean(Page.Items["PROSPECT_DYNAMIC_LIST"]));
						// 06/26/2018 Paul.  Missing filter. 
						Security.Filter(cmd, m_sMODULE, "list");
						Sql.AppendParameter(cmd, arrUPDATED.ToArray(), "ID");
					}
					else
					{
						// 04/26/2008 Paul.  Build the list of fields to use in the select clause.
						// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
						m_sVIEW_NAME = "vwPROSPECT_LISTS_USERS";
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
						     + "  from " + m_sVIEW_NAME + ControlChars.CrLf
						     + " where 1 = 1"           + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Sql.AppendParameter(cmd, gID, "PROSPECT_LIST_ID");
					}
					// 04/26/2008 Paul.  Move Last Sort to the database.
					cmd.CommandText += grdMain.OrderByClause("FULL_NAME", "asc");

					if ( bDebug )
						RegisterClientScriptBlock("vwPROSPECT_LISTS_USERS", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								// 03/07/2013 Paul.  Apply business rules to subpanel. 
								this.ApplyGridViewRules("ProspectLists." + m_sMODULE, dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								// 09/05/2005 Paul.  LinkButton controls will not fire an event unless the the grid is bound. 
								// 04/25/2008 Paul.  Enable sorting of sub panel. 
								// 04/26/2008 Paul.  Move Last Sort to the database.
								grdMain.DataBind();
								// 01/27/2010 Paul.  In EditView mode, we need a list of existing relationships. 
								if ( bEditView && !IsPostBack )
								{
									this.CreateEditViewRelationships(dt, "USER_ID");
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
			}
		}

		// 01/27/2010 Paul.  This method is only calld when in EditMode. 
		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			UniqueGuidCollection arrDELETED = this.GetDeletedEditViewRelationships();
			foreach ( Guid gDELETE_ID in arrDELETED )
			{
				if ( !Sql.IsEmptyGuid(gDELETE_ID) )
					SqlProcs.spPROSPECT_LISTS_USERS_Delete(gPARENT_ID, gDELETE_ID, trn);
			}

			UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
			foreach ( Guid gUPDATE_ID in arrUPDATED )
			{
				if ( !Sql.IsEmptyGuid(gUPDATE_ID) )
					SqlProcs.spPROSPECT_LISTS_USERS_Update(gPARENT_ID, gUPDATE_ID, trn);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			gID = Sql.ToGuid(Request["ID"]);
			if ( !Sql.IsEmptyString(txtUSER_ID.Value) )
			{
				try
				{
					// 10/04/2006 Paul.  ValidateIDs can throw an exception. 
					string[] arrID = txtUSER_ID.Value.Split(',');
					if ( arrID != null )
					{
						if ( bEditView )
						{
							this.UpdateEditViewRelationship(arrID);
						}
						else
						{
							// 06/11/2009 Paul.  Use a stack to run the update in blocks of under 200 IDs. 
							//string sIDs = Utils.ValidateIDs(arrID);
							System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "list", arrID, "USERS");
							if ( stk.Count > 0 )
							{
								DbProviderFactory dbf = DbProviderFactories.GetFactory();
								using ( IDbConnection con = dbf.CreateConnection() )
								{
									con.Open();
									// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
									using ( IDbTransaction trn = Sql.BeginTransaction(con) )
									{
										try
										{
											while ( stk.Count > 0 )
											{
												string sIDs = Utils.BuildMassIDs(stk);
												SqlProcs.spPROSPECT_LISTS_USERS_MassUpdate(sIDs, gID, trn);
											}
											trn.Commit();
										}
										catch(Exception ex)
										{
											trn.Rollback();
											throw(new Exception(ex.Message, ex.InnerException));
										}
									}
								}
								// 05/16/2008 Paul.  Instead of redirecting, just rebind the grid and AJAX will repaint. 
								//Response.Redirect("view.aspx?ID=" + gID.ToString());
								// 05/16/2008 Paul.  If we are not going to redirect,then we must clear the value. 
								txtUSER_ID.Value = String.Empty;
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
			try
			{
				BindGrid();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}

			if ( !IsPostBack )
			{
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
				// 04/28/2008 Paul.  Make use of dynamic buttons. 
				Guid gASSIGNED_USER_ID = Sql.ToGuid(Page.Items["ASSIGNED_USER_ID"]);
				ctlDynamicButtons.AppendButtons("ProspectLists." + m_sMODULE, gASSIGNED_USER_ID, gID);
				// 01/10/2010 Paul.  Disable the Create and Select buttons if this is a dynamic list. 
				bool bDYNAMIC_LIST = Sql.ToBoolean(Page.Items["DYNAMIC_LIST"]);
				if ( bDYNAMIC_LIST )
					ctlDynamicButtons.DisableAll();
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Users";
			// 04/26/2008 Paul.  We need to build a list of the fields used by the search clause. 
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("DATE_ENTERED"             );
			arrSelectFields.Add("USER_ID"                  );
			arrSelectFields.Add("FULL_NAME"                );
			arrSelectFields.Add("PROSPECT_ASSIGNED_USER_ID");
			// 01/10/2010 Paul.  New field that is used to determine if the Remove link is displayed. 
			arrSelectFields.Add("PROSPECT_DYNAMIC_LIST"    );
			// 11/26/2005 Paul.  Add fields early so that sort events will get called. 
			this.AppendGridColumns(grdMain, "ProspectLists." + m_sMODULE, arrSelectFields);
			// 04/28/2008 Paul.  Make use of dynamic buttons. 
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("ProspectLists." + m_sMODULE, Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}


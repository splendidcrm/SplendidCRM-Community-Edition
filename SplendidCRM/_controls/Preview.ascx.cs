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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM._controls
{
	/// <summary>
	/// Summary description for Preview.
	/// </summary>
	public class Preview : SplendidControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;

		protected HiddenField hidPREVIEW_ID    ;
		// 06/07/2015 Paul.  Module will change with preview from subpanel. 
		protected HiddenField hidPREVIEW_MODULE;
		protected Guid        gID              ;
		protected HtmlTable   tblMain          ;

		protected UniqueStringCollection arrSelectFields;
		protected SplendidGrid  grdStream      ;

		public string Module
		{
			get { return hidPREVIEW_MODULE.Value; }
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Edit" )
				{
					Response.Redirect("~/" + m_sMODULE + "/edit.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Duplicate" )
				{
					Response.Redirect("~/" + m_sMODULE + "/edit.aspx?DuplicateID=" + gID.ToString());
				}
				else if ( e.CommandName == "Delete" )
				{
					// 06/07/2015 Paul.  We need to code a generic delete. 
					//SqlProcs.spACCOUNTS_Delete(gID);
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "SortGrid" )
				{
					grdStream.SetSortFields(e.CommandArgument as string[]);
					arrSelectFields.AddFields(grdStream.SortColumn);
				}
				else
				{
					throw(new Exception("Unknown command: " + e.CommandName));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void grdStream_OnSelectMethod(int nCurrentPageIndex, int nPageSize)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
					cmd.CommandText = "  from vw" + sTABLE_NAME + "_STREAM" + ControlChars.CrLf;
					Security.Filter(cmd, m_sMODULE, "list");
					cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
					                + cmd.CommandText;
					if ( nPageSize > 0 )
					{
						Sql.PageResults(cmd, "vwSTREAM", grdStream.OrderByClause(), nCurrentPageIndex, nPageSize);
					}
					else
					{
						cmd.CommandText += grdStream.OrderByClause();
					}
					
					if ( bDebug )
						RegisterClientScriptBlock("SQLPaged", Sql.ClientScriptBlock(cmd));
					
					if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								grdStream.DataSource = dt.DefaultView;
							}
						}
					}
				}
			}
		}

		// 06/29/2018 Paul.  Pass ArchiveView flag. 
		public void LoadPreview(string sMODULE_NAME, Guid gID, bool bArchiveView)
		{
			try
			{
				if ( !Sql.IsEmptyGuid(gID) && !Sql.IsEmptyString(sMODULE_NAME) )
				{
					hidPREVIEW_ID    .Value = gID.ToString();
					hidPREVIEW_MODULE.Value = sMODULE_NAME;
					m_sMODULE = sMODULE_NAME;
					string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
					// 06/29/2018 Paul.  Pass ArchiveView flag. 
					m_sVIEW_NAME = "vw" + sTABLE_NAME;
					if ( bArchiveView )
					{
						if ( SplendidCache.ArchiveViewExists(m_sVIEW_NAME) )
						{
							m_sVIEW_NAME += "_ARCHIVE";
							this.LayoutDetailView = this.LayoutDetailView.Replace("DetailView", "ArchiveView");
						}
						else
						{
							m_sVIEW_NAME += "_Edit";
						}
					}
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL ;
						sSQL = "select *"               + ControlChars.CrLf
						     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Security.Filter(cmd, m_sMODULE, "view");
							Sql.AppendParameter(cmd, gID, "ID", false);
							con.Open();

							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dtCurrent = new DataTable() )
								{
									da.Fill(dtCurrent);
									if ( dtCurrent.Rows.Count > 0 )
									{
										DataRow rdr = dtCurrent.Rows[0];
										this.ApplyDetailViewPreLoadEventRules(m_sMODULE + "." + LayoutDetailView, rdr);
										
										// 03/09/2014 Paul.  We need to make the table visible as it might remember the previous visibility state. 
										tblMain.Visible = true;
										tblMain.Rows.Clear();
										this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, rdr);
										ctlDynamicButtons.Visible = true;
										ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
										this.ApplyDetailViewPostLoadEventRules(m_sMODULE + "." + LayoutDetailView, rdr);
									}
									else
									{
										ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
										ctlDynamicButtons.DisableAll();
										ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
									}
								}
							}
						}
						// 09/25/2015  Paul.  Seems slow, so always paginate. 
						//if ( Crm.Config.allow_custom_paging() && Crm.Modules.CustomPaging(m_sMODULE) )
						//{
						//	grdStream.AllowCustomPaging = true;
						//	grdStream.SelectMethod     += new SelectMethodHandler(grdStream_OnSelectMethod);
						//}
						// 04/28/2017 Paul.  Only enable if all streams enabled. 
						if ( Sql.ToBoolean(Application["Modules." + m_sMODULE + ".StreamEnabled"]) && Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]) )
						{
							grdStream.Visible = true;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								grdStream.OrderByClause("STREAM_DATE desc, STREAM_VERSION desc", String.Empty);
								
								cmd.CommandText = "  from vw" + sTABLE_NAME + "_STREAM" + ControlChars.CrLf;
								Security.Filter(cmd, m_sMODULE, "list");
								Sql.AppendParameter(cmd, gID, "ID");
								if ( grdStream.AllowCustomPaging )
								{
									cmd.CommandText = "select count(*)" + ControlChars.CrLf
									                + cmd.CommandText;
									
									if ( bDebug )
										RegisterClientScriptBlock("vwSTREAM", Sql.ClientScriptBlock(cmd));
									
									if ( PrintView || IsPostBack )
									{
										grdStream.VirtualItemCount = Sql.ToInteger(cmd.ExecuteScalar());
									}
								}
								else
								{
									cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
									                + cmd.CommandText
									                + grdStream.OrderByClause();
									
									if ( bDebug )
										RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
									
									if ( PrintView || IsPostBack )
									{
										using ( DbDataAdapter da = dbf.CreateDataAdapter() )
										{
											((IDbDataAdapter)da).SelectCommand = cmd;
											using ( DataTable dt = new DataTable() )
											{
												da.Fill(dt);
												grdStream.DataSource = dt.DefaultView ;
												grdStream.DataBind();
											}
										}
									}
								}
							}
						}
					}
				}
				else
				{
					if ( !Sql.IsEmptyString(m_sMODULE) )
					{
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
						ctlDynamicButtons.DisableAll();
						this.Visible = false;
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			this.Visible = !Sql.IsEmptyString(m_sMODULE) && (SplendidCRM.Security.GetUserAccess(m_sMODULE, "view") >= 0);
			if ( !this.Visible )
				return;

			if ( this.IsTrackingViewState )
			{
				gID = Sql.ToGuid(hidPREVIEW_ID.Value);
			}
			else
			{
				gID = Sql.ToGuid(Request[hidPREVIEW_ID.UniqueID]);
			}
			LoadPreview(m_sMODULE, gID, false);
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = Sql.ToString(Request.Form[hidPREVIEW_MODULE.UniqueID]);
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"                   );
			arrSelectFields.Add("AUDIT_ID"             );
			arrSelectFields.Add("STREAM_DATE"          );
			arrSelectFields.Add("STREAM_ACTION"        );
			arrSelectFields.Add("STREAM_COLUMNS"       );
			arrSelectFields.Add("STREAM_RELATED_ID"    );
			arrSelectFields.Add("STREAM_RELATED_MODULE");
			arrSelectFields.Add("STREAM_RELATED_NAME"  );
			arrSelectFields.Add("NAME"                 );
			arrSelectFields.Add("CREATED_BY_ID"        );
			arrSelectFields.Add("CREATED_BY"           );
			arrSelectFields.Add("CREATED_BY_PICTURE"   );
			arrSelectFields.Add("ASSIGNED_USER_ID"     );
			// 04/28/2017 Paul.  Only enable if all streams enabled. 
			if ( Sql.ToBoolean(Application["Modules." + m_sMODULE + ".StreamEnabled"]) && Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]) )
			{
				grdStream.Visible = true;
				SplendidDynamic.GridColumns("ActivityStream." + LayoutListView, arrSelectFields, null);
			}
			if ( IsPostBack )
			{
				if ( !Sql.IsEmptyString(m_sMODULE) )
				{
					this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, null);
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
				}
			}
		}
		#endregion
	}
}


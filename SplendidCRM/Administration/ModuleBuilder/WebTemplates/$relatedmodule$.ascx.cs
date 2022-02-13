using System;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.$modulename$
{
//$sqlprocs$
	/// <summary>
	///		Summary description for $relatedmodule$.
	/// </summary>
	public class $relatedmodule$ : SubPanelControl
	{
		protected _controls.SubPanelButtons ctlDynamicButtons;
		protected _controls.SearchView     ctlSearchView    ;
		protected UniqueStringCollection arrSelectFields;
		protected Guid            gID            ;
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected HtmlInputHidden txt$relatedtablesingular$_ID      ;
		protected Button          btnCreateInline   ;
		protected Panel           pnlNewRecordInline;
		protected SplendidCRM.$relatedmodule$.NewRecord ctlNewRecord   ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "$relatedmodule$.Edit":
					{
						Guid g$relatedtablesingular$_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/$relatedmodule$/edit.aspx?ID=" + g$relatedtablesingular$_ID.ToString());
						break;
					}
					case "$relatedmodule$.Remove":
					{
						Guid g$relatedtablesingular$_ID = Sql.ToGuid(e.CommandArgument);
						if ( bEditView )
						{
							this.DeleteEditViewRelationship(g$relatedtablesingular$_ID);
						}
						else
						{
							SqlProcs.sp$tablename$_$relatedtable$_Delete(gID, g$relatedtablesingular$_ID);
						}
						BindGrid();
						break;
					}
					case "$relatedmodule$.Create":
						if ( this.IsMobile || Sql.ToBoolean(Application["CONFIG.disable_editview_inline"]) )
							Response.Redirect("~/" + m_sMODULE + "/edit.aspx?PARENT_ID=" + gID.ToString());
						else
						{
							pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "inline");
							ctlDynamicButtons.HideAll();
						}
						break;
					case "NewRecord.Cancel":
						pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
						ctlDynamicButtons.ShowAll();
						break;
					case "NewRecord.FullForm":
						Response.Redirect("~/" + m_sMODULE + "/edit.aspx?PARENT_ID=" + gID.ToString());
						break;
					case "NewRecord":
					{
						Guid g$relatedtable$_ID = Sql.ToGuid(e.CommandArgument);
						if ( !Sql.IsEmptyGuid(g$relatedtable$_ID) )
						{
							SqlProcs.sp$tablename$_$relatedtable$_Update(gID, g$relatedtable$_ID);
							Response.Redirect(Request.RawUrl);
						}
						else
						{
							pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
							ctlDynamicButtons.ShowAll();
						}
						break;
					}
					case "$relatedmodule$.Search":
						ctlSearchView.Visible = !ctlSearchView.Visible;
						break;
					case "Search":
						break;
					case "Clear":
						BindGrid();
						break;
					case "SortGrid":
						break;
					case "Preview":
						if ( Page.Master is SplendidMaster )
						{
							CommandEventArgs ePreview = new CommandEventArgs(e.CommandName, new PreviewData(m_sMODULE, Sql.ToGuid(e.CommandArgument)));
							(Page.Master as SplendidMaster).Page_Command(sender, ePreview);
						}
						break;
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
				con.Open();
				string sSQL;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
					if ( bEditView && IsPostBack && arrUPDATED.Count > 0 )
					{
						arrSelectFields.Remove("$relatedtablesingular$_ID"                  );
						arrSelectFields.Remove("$relatedtablesingular$_NAME"                );
						arrSelectFields.Remove("$tablenamesingular$_ID"              );
						arrSelectFields.Remove("$tablenamesingular$_NAME"            );
						arrSelectFields.Remove("$tablenamesingular$_ASSIGNED_USER_ID");
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + "     , ID                        as $relatedtablesingular$_ID                  " + ControlChars.CrLf
						     + "     , NAME                      as $relatedtablesingular$_NAME                " + ControlChars.CrLf
						     + "     , @$tablenamesingular$_ID               as $tablenamesingular$_ID              " + ControlChars.CrLf
						     + "     , @$tablenamesingular$_NAME             as $tablenamesingular$_NAME            " + ControlChars.CrLf
						     + "     , @$tablenamesingular$_ASSIGNED_USER_ID as $tablenamesingular$_ASSIGNED_USER_ID" + ControlChars.CrLf
						     + "  from vw$relatedtable$" + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@$tablenamesingular$_ID"              , gID);
						Sql.AddParameter(cmd, "@$tablenamesingular$_NAME"            , Sql.ToString(Page.Items["NAME"            ]));
						Sql.AddParameter(cmd, "@$tablenamesingular$_ASSIGNED_USER_ID", Sql.ToGuid  (Page.Items["ASSIGNED_USER_ID"]));
						Security.Filter(cmd, m_sMODULE, "list");
						Sql.AppendParameter(cmd, arrUPDATED.ToArray(), "ID");
					}
					else
					{
						sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
						     + "  from vw$tablename$_$relatedtable$" + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Security.Filter(cmd, m_sMODULE, "list");
						Sql.AppendParameter(cmd, gID, "$tablenamesingular$_ID");
					}
					ctlSearchView.SqlSearchClause(cmd);
					cmd.CommandText += grdMain.OrderByClause("DATE_ENTERED", "desc");

					if ( bDebug )
						RegisterClientScriptBlock("vw$tablename$_$relatedtable$", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								this.ApplyGridViewRules("$modulename$." + m_sMODULE, dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								grdMain.DataBind();
								if ( bEditView && !IsPostBack )
								{
									this.CreateEditViewRelationships(dt, "$relatedtablesingular$_ID");
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
					SqlProcs.sp$tablename$_$relatedtable$_Delete(gPARENT_ID, gDELETE_ID, trn);
			}

			UniqueGuidCollection arrUPDATED = this.GetUpdatedEditViewRelationships();
			foreach ( Guid gUPDATE_ID in arrUPDATED )
			{
				if ( !Sql.IsEmptyGuid(gUPDATE_ID) )
					SqlProcs.sp$tablename$_$relatedtable$_Update(gPARENT_ID, gUPDATE_ID, trn);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			gID = Sql.ToGuid(Request["ID"]);
			Guid g$relatedtablesingular$_ID = Sql.ToGuid(txt$relatedtablesingular$_ID.Value);
			if ( !Sql.IsEmptyGuid(g$relatedtablesingular$_ID) )
			{
				try
				{
					if ( bEditView )
					{
						this.UpdateEditViewRelationship(g$relatedtablesingular$_ID);
					}
					else
					{
						SqlProcs.sp$tablename$_$relatedtable$_Update(gID, g$relatedtablesingular$_ID);
					}
					txt$relatedtablesingular$_ID.Value = String.Empty;
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
				Guid gASSIGNED_USER_ID = Sql.ToGuid(Page.Items["ASSIGNED_USER_ID"]);
				ctlDynamicButtons.AppendButtons("$modulename$." + m_sMODULE, gASSIGNED_USER_ID, gID);
				ctlNewRecord.PARENT_ID    = gID;
				ctlNewRecord.PARENT_TYPE = "$modulename$";
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
			ctlNewRecord.Command      += new CommandEventHandler(Page_Command);
			ctlSearchView.Command     += new CommandEventHandler(Page_Command);
			m_sMODULE = "$relatedmodule$";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("DATE_ENTERED"            );
			arrSelectFields.Add("PENDING_PROCESS_ID"      );
			arrSelectFields.Add("$relatedtablesingular$_ID"                  );
			bool bModuleIsAssigned = Sql.ToBoolean(Application["Modules." + m_sMODULE + ".Assigned"]);
			if ( bModuleIsAssigned )
				arrSelectFields.Add("ASSIGNED_USER_ID"        );
			arrSelectFields.Add("$tablenamesingular$_ASSIGNED_USER_ID");
			this.AppendGridColumns(grdMain, "$modulename$." + m_sMODULE, arrSelectFields, Page_Command);
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("$modulename$." + m_sMODULE, Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}

using System;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.$modulename$
{
	/// <summary>
	///		Summary description for ActivityStream.
	/// </summary>
	public class ActivityStream : SubPanelControl
	{
		protected _controls.SubPanelButtons              ctlDynamicButtons;
		protected SplendidCRM.ActivityStream.SearchBasic ctlSearchView    ;
		protected SplendidCRM.ActivityStream.NewRecord   ctlNewRecord     ;
		protected UniqueStringCollection arrSelectFields;
		protected Guid            gID            ;
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected Button          btnCreateInline   ;
		protected Panel           pnlNewRecordInline;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "ActivityStream.Create":
						pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "inline");
						ctlDynamicButtons.HideAll();
						break;
					case "InsertPost":
						pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
						ctlDynamicButtons.ShowAll();
						BindGrid();
						break;
					case "NewRecord.Cancel":
						pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
						ctlDynamicButtons.ShowAll();
						break;
					case "NewRecord":
						Response.Redirect(Request.RawUrl);
						break;
					case "ActivityStream.Search":
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
					string sTABLE_NAME = SplendidCRM.Crm.Modules.TableName(m_sMODULE);
					sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
					     + "  from vw" + sTABLE_NAME + "_STREAM" + ControlChars.CrLf;
					cmd.CommandText = sSQL;
					Security.Filter(cmd, m_sMODULE, "list");
					Sql.AppendParameter(cmd, gID, "ID");
					ctlSearchView.SqlSearchClause(cmd);
					cmd.CommandText += grdMain.OrderByClause("STREAM_DATE desc, STREAM_VERSION desc", String.Empty);

					if ( bDebug )
						RegisterClientScriptBlock("vw" + sTABLE_NAME + "_STREAM", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								this.ApplyGridViewRules("ActivityStream." + m_sMODULE, dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								grdMain.DataBind();
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

		private void Page_Load(object sender, System.EventArgs e)
		{
			this.Visible = this.StreamEnabled();
			if ( !this.Visible )
				return;

			gID = Sql.ToGuid(Request["ID"]);
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
				ctlDynamicButtons.AppendButtons("ActivityStream.Subpanel", gASSIGNED_USER_ID, gID);
				ctlNewRecord.PARENT_ID = gID;
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
			m_sMODULE = "$modulename$";
			ctlNewRecord.Module = m_sMODULE;
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
			SplendidDynamic.GridColumns(m_sMODULE + ".ActivityStream." + LayoutListView, arrSelectFields, null);
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("ActivityStream.Subpanel", Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}


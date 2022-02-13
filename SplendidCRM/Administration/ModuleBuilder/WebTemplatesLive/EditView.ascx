<%@ Control Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.SplendidControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Diagnostics" %>
<script runat="server">
//$sqlprocs$

		protected Guid            gID                          ;
		protected bool            bInlineEditMode              = false;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" || e.CommandName == "SaveDuplicate" || e.CommandName == "SaveConcurrency" )
			{
				try
				{
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView);
					
					if ( plcSubPanel.Visible )
					{
						foreach ( Control ctl in plcSubPanel.Controls )
						{
							InlineEditControl ctlSubPanel = ctl as InlineEditControl;
							if ( ctlSubPanel != null )
							{
								ctlSubPanel.ValidateEditViewFields();
							}
						}
					}
					if ( Page.IsValid )
					{
						string sTABLE_NAME = SplendidCRM.Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								sSQL = "select *           " + ControlChars.CrLf
								     + "  from vw$tablename$_Edit" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Security.Filter(cmd, m_sMODULE, "edit");
									Sql.AppendParameter(cmd, gID, "ID", false);
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											rowCurrent = dtCurrent.Rows[0];
											DateTime dtLAST_DATE_MODIFIED = Sql.ToDateTime(ViewState["LAST_DATE_MODIFIED"]);
											if ( Sql.ToBoolean(Application["CONFIG.enable_concurrency_check"])  && (e.CommandName != "SaveConcurrency") && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
											{
												ctlDynamicButtons.ShowButton("SaveConcurrency", true);
												ctlFooterButtons .ShowButton("SaveConcurrency", true);
												throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED)));
											}
										}
										else
										{
											gID = Guid.Empty;
										}
									}
								}
							}

							this.ApplyEditViewPreSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
							bool bDUPLICATE_CHECHING_ENABLED = Sql.ToBoolean(Application["CONFIG.enable_duplicate_check"]) && Sql.ToBoolean(Application["Modules." + m_sMODULE + ".DuplicateCheckingEnabled"]) && (e.CommandName != "SaveDuplicate");
							if ( bDUPLICATE_CHECHING_ENABLED )
							{
								if ( Utils.DuplicateCheck(Application, con, m_sMODULE, gID, this, rowCurrent) > 0 )
								{
									ctlDynamicButtons.ShowButton("SaveDuplicate", true);
									ctlFooterButtons .ShowButton("SaveDuplicate", true);
									throw(new Exception(L10n.Term(".ERR_DUPLICATE_EXCEPTION")));
								}
							}
							
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
$callupdateprocedure$
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									SplendidCRM.SqlProcs.spTRACKER_Update
										( Security.USER_ID
										, m_sMODULE
										, gID
										, new SplendidCRM.DynamicControl(this, rowCurrent, "NAME").Text
										, "save"
										, trn
										);
									if ( plcSubPanel.Visible )
									{
										foreach ( Control ctl in plcSubPanel.Controls )
										{
											InlineEditControl ctlSubPanel = ctl as InlineEditControl;
											if ( ctlSubPanel != null )
											{
												ctlSubPanel.Save(gID, m_sMODULE, trn);
											}
										}
									}
									trn.Commit();
									SplendidCache.ClearFavorites();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
							// 02/09/2015 Paul.  Need to specify the SplendidCRM namespace when not using code-behinds. 
							rowCurrent = SplendidCRM.Crm.Modules.ItemEdit(m_sMODULE, gID);
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
						}
						
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
						else
							Response.Redirect("view.aspx?ID=" + gID.ToString());
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
				if ( Sql.IsEmptyGuid(gID) )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *           " + ControlChars.CrLf
							     + "  from vw$tablename$_Edit" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, m_sMODULE, "edit");
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AppendParameter(cmd, gDuplicateID, "ID", false);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AppendParameter(cmd, gID, "ID", false);
								}
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
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
											
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;

											bool bModuleIsAssigned  = Sql.ToBoolean(Application["Modules." + m_sMODULE + ".Assigned"]);
											Guid gASSIGNED_USER_ID = Guid.Empty;
											if ( bModuleIsAssigned )
												gASSIGNED_USER_ID = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);

											this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, rdr);
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, gASSIGNED_USER_ID, rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, gASSIGNED_USER_ID, rdr);
											TextBox txtNAME = this.FindControl("NAME") as TextBox;
											if ( txtNAME != null )
												txtNAME.Focus();

											ViewState ["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"   ]);
											ViewState ["NAME"              ] = Sql.ToString  (rdr["NAME"            ]);
											ViewState ["ASSIGNED_USER_ID"  ] = gASSIGNED_USER_ID;
											Page.Items["NAME"              ] = ViewState ["NAME"            ];
											Page.Items["ASSIGNED_USER_ID"  ] = ViewState ["ASSIGNED_USER_ID"];
											
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
										}
										else
										{
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlFooterButtons .DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
											plcSubPanel.Visible = false;
										}
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						TextBox txtNAME = this.FindControl("NAME") as TextBox;
						if ( txtNAME != null )
							txtNAME.Focus();
						if ( bInlineEditMode )
							plcSubPanel.Visible = false;
						
						this.ApplyEditViewNewEventRules(m_sMODULE + "." + LayoutEditView);
					}
				}
				else
				{
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
					Page.Items["NAME"            ] = ViewState ["NAME"            ];
					Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

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
			m_sMODULE = "$modulename$";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				Page.Validators.Add(new RulesValidator(this));
			}
		}
</script>
<div id="divEditView" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="$modulename$" EnablePrint="false" HelpName="EditView" EnableHelp="true" Runat="Server" />

	<asp:HiddenField ID="LAYOUT_EDIT_VIEW" Runat="server" />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblMain" class="tabEditView" runat="server">
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<div id="divEditSubPanel">
		<asp:PlaceHolder ID="plcSubPanel" Runat="server" />
	</div>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

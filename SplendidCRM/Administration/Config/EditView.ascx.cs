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

namespace SplendidCRM.Administration.Config
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

		protected Guid          gID        ;
		protected TextBox       txtNAME    ;
		protected TextBox       txtCATEGORY;
		protected TextBox       txtVALUE   ;
		protected TableRow      trImage    ;
		protected HtmlInputFile fileIMAGE  ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				if ( Page.IsValid )
				{
					try
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 02/16/2006 Paul.  Trim the Name and Category, but not the Value.
							string sNAME      = txtNAME    .Text.Trim();
							string sCATEGORY  = txtCATEGORY.Text.Trim();
							string sVALUE     = txtVALUE   .Text;
							string sOLD_VALUE = Sql.ToString(Application["CONFIG." + sNAME]);
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 11/11/2008 Paul.  Display an error message if max users is being edited. 
									if ( String.Compare(sNAME, "max_users", true) == 0 )
										throw(new Exception(L10n.Term("Config.ERR_CANNOT_EDIT_MAX_USERS")));
									
									// 01/07/2013 Paul.  Config values ending in .Encrypted are encrypted. 
									if ( sNAME.EndsWith(".Encrypted") )
									{
										Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
										Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
										string sENCRYPTED_VALUE = Security.EncryptPassword(sVALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
										if ( Security.DecryptPassword(sENCRYPTED_VALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sVALUE )
											throw(new Exception("Decryption failed"));
										sVALUE = sENCRYPTED_VALUE;
									}
									
									// 08/09/2009 Paul.  Allow an image to be uploaded and used in the config area. 
									if ( trImage.Visible )
									{
										Guid   gImageID  = Guid.Empty;
										string sFILENAME = String.Empty;
										SplendidCRM.FileBrowser.FileWorkerUtils.LoadImage(ref gImageID, ref sFILENAME, fileIMAGE.UniqueID, trn);
										if ( !Sql.IsEmptyGuid(gImageID) )
										{
											sVALUE = "~/Images/EmailImage.aspx?ID=" + gImageID.ToString();
										}
									}
									SqlProcs.spCONFIG_Update(sCATEGORY, sNAME, sVALUE);
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
							if ( sOLD_VALUE != sVALUE )
							{
								// 10/26/2019 Paul.  Only update application cache if successful. 
								Application["CONFIG." + sNAME] = sVALUE;
								// 10/26/2019 Paul.  Clear React cache. 
								HttpRuntime.Cache.Remove("vwCONFIG.ReactClient");
								// 10/10/2015 Paul.  Provide a way to disable streams.  When disabled, just remove the triggers and keep the data. 
								if ( String.Compare(sNAME, "enable_activity_streams") == 0 )
								{
									if ( Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]) )
										SqlProcs.spSqlBuildAllStreamTriggers();
									else
										SqlProcs.spSqlDropAllStreamTriggers();
								}
								// 12/12/2017 Paul.  If the archive database changes, then rebuild the module settings. 
								if ( String.Compare(sNAME, "Archive.Database") == 0 )
								{
									SqlProcs.spSqlDropAllArchiveViews();
									SplendidInit.InitModules(Context);
								}
							}
						}
					}
					catch(Exception ex)
					{
						ctlDynamicButtons.ErrorText = ex.Message;
						return;
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
			SetPageTitle(L10n.Term(".moduleList.Administration"));
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
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);

					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *            " + ControlChars.CrLf
							     + "  from vwCONFIG_Edit" + ControlChars.CrLf
							     + " where ID = @ID     " + ControlChars.CrLf;
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
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList.Administration") + " - " + ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;

											txtNAME.ReadOnly = true;
											txtNAME    .Text = Sql.ToString(rdr["NAME"    ]);
											txtCATEGORY.Text = Sql.ToString(rdr["CATEGORY"]);
											// 01/07/2013 Paul.  Config values ending in .Encrypted are encrypted. 
											if ( !txtNAME.Text.EndsWith(".Encrypted") )
												txtVALUE   .Text = Sql.ToString(rdr["VALUE"   ]);

											trImage.Visible = txtNAME.Text.EndsWith("_image");
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
					SetPageTitle(L10n.Term(".moduleList.Config") + " - " + ctlDynamicButtons.Title);
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
			m_sMODULE = "Config";
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


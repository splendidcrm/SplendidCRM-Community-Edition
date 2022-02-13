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

namespace SplendidCRM.Help
{
	/// <summary>
	/// Summary description for DetailView.
	/// </summary>
	public class DetailView : SplendidControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected Literal lblDISPLAY_TEXT;

		protected Guid        gID              ;
		protected string      sPageTitle       ;
		protected string      sNAME            ;
		protected string      sMODULE          ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Edit" )
				{
					Response.Redirect("edit.aspx?ID=" + gID.ToString() + "&NAME=" + sNAME + "&MODULE=" + sMODULE);
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
			sNAME   = Sql.ToString(Request["NAME"  ]);
			sMODULE = Sql.ToString(Request["MODULE"]);
			sPageTitle = L10n.Term(".moduleList." + sMODULE) + " - " + L10n.Term(".LNK_HELP");
			Utils.SetPageTitle(Page, sPageTitle);
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL ;
					sSQL = "select *                         " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY_HELP        " + ControlChars.CrLf
					     + " where LANG        = @LANG       " + ControlChars.CrLf
					     + "   and MODULE_NAME = @MODULE_NAME" + ControlChars.CrLf
					     + "   and NAME        = @NAME       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LANG"       , L10n.NAME);
						Sql.AddParameter(cmd, "@MODULE_NAME", sMODULE  );
						Sql.AddParameter(cmd, "@NAME"       , sNAME    );
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
									gID     = Sql.ToGuid  (rdr["ID"         ]);
									sNAME   = Sql.ToString(rdr["NAME"       ]);
									sMODULE = Sql.ToString(rdr["MODULE_NAME"]);
									sPageTitle = L10n.Term(".moduleList." + sMODULE) + " - " + L10n.Term(".LNK_HELP");
									Utils.SetPageTitle(Page, sPageTitle);
									lblDISPLAY_TEXT.Text = Sql.ToString(rdr["DISPLAY_TEXT"]);
									// 06/24/2008 Paul.  Help text does not have an assigned user id. 
									if ( !IsPostBack )
									{
										ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, rdr);
									}
								}
								else
								{
									if ( !IsPostBack )
									{
										ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
										// 12/09/2010 Paul.  Not sure why we were disabling the edit button. 
										// If the help does not exist, we should be able to create it. 
										//ctlDynamicButtons.ShowButton("Edit", false);
									}
								}
								// 10/25/2006 Paul.  There is a config flag to disable the wiki entirely. 
								// 01/29/2011 Paul.  We can only change visibility after the button has been created. 
								ctlDynamicButtons.ShowButton("Edit", Sql.ToBoolean(Application["CONFIG.enable_help_wiki"]));
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
			if ( !IsPostBack )
			{
				// 06/09/2006 Paul.  The primary data binding will now only occur in the ASPX pages so that this is only one per cycle. 
				//Page.DataBind();
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Help";
			if ( IsPostBack )
			{
				// 06/24/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
			}
		}
		#endregion
	}
}


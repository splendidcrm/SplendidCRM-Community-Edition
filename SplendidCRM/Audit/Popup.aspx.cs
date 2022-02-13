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
using System.Text;
using System.Collections;
using System.Collections.Specialized;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Audit
{
	/// <summary>
	/// Summary description for Popup.
	/// </summary>
	public class Popup : SplendidPopup
	{
		protected Guid          gID            ;
		protected string        sModule        ;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblTitle       ;
		protected Label         lblError       ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					// 10/13/2005 Paul.  Make sure to clear the page index prior to applying search. 
					grdMain.CurrentPageIndex = 0;
					grdMain.ApplySort();
					grdMain.DataBind();
				}
				// 12/14/2007 Paul.  We need to capture the sort event from the SearchView. 
				else if ( e.CommandName == "SortGrid" )
				{
					grdMain.SetSortFields(e.CommandArgument as string[]);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		// 10/31/2021 Paul.  Moved BuildChangesTable to ModuleUtils from Audit/Popup. 

		// 10/31/2021 Paul.  Moved GetAuditData to ModuleUtils from Audit/Popup. 

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				gID     = Sql.ToGuid  (Request["ID"    ]);
				sModule = Sql.ToString(Request["Module"]);
				// 10/28/2019 Paul.  Protect against precompile error. 
				if ( !Sql.IsEmptyString(sModule) && !Sql.IsEmptyGuid(gID) )
				{
					string sNAME = String.Empty;
					StringBuilder sbSQLCode = new StringBuilder();
					// 10/31/2021 Paul.  Moved GetAuditData to ModuleUtils from Audit/Popup. 
					DataTable dtChanges = ModuleUtils.Audit.GetAuditData(Application, L10n, T10n, sModule, gID, ref sNAME, sbSQLCode);
					// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
					lblTitle.Text = L10n.Term(".moduleList." + sModule) + ": " + HttpUtility.HtmlEncode(sNAME);
					SetPageTitle(L10n.Term(".moduleList." + sModule) + " - " + sNAME);
					string sDebugSQL = "<script type=\"text/javascript\">sDebugSQL += '" + Sql.EscapeJavaScript(sbSQLCode.ToString() + ";") + "';</script>";
					if ( bDebug )
						Page.ClientScript.RegisterClientScriptBlock(System.Type.GetType("System.String"), "SQLCode", sDebugSQL);

					vwMain = new DataView(dtChanges);
					vwMain.Sort = "DATE_CREATED desc, FIELD_NAME asc";
					grdMain.DataSource = vwMain ;
					if ( !IsPostBack )
					{
						grdMain.DataBind();
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
			if ( !IsPostBack )
			{
				// 06/09/2006 Paul.  The primary data binding will now only occur in the ASPX pages so that this is only one per cycle. 
				// 03/11/2008 Paul.  Move the primary binding to SplendidPage. 
				//Page DataBind();
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
		}
		#endregion
	}
}


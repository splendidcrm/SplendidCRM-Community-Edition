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
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.Optimization;
using System.Diagnostics;
using System.Globalization;

namespace SplendidCRM.Calendar.html5
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		public DateTimeFormatInfo DateTimeFormat
		{
			get { return System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat; }
		}

		// 01/30/2016 Paul.  Add Parent and Description. 
		protected void BuildTerminologyListScript(StringBuilder sb, string sListName)
		{
			sb.AppendLine("TERMINOLOGY_LISTS['" + sListName + "'] = [];");
			int nMAX_NAME = 0;
			System.Data.DataTable dt = SplendidCache.List(sListName);
			foreach ( System.Data.DataRow row in dt.Rows )
			{
				string sNAME = Sql.ToString(row["NAME"]);
				nMAX_NAME = Math.Max(nMAX_NAME, sNAME.Length);
			}
			foreach ( System.Data.DataRow row in dt.Rows )
			{
				string sNAME = Sql.ToString(row["NAME"]);
				if ( sListName == "record_type_display" )
				{
					int nACLACCESS = Security.GetUserAccess(sNAME, "list");
					if ( Sql.ToBoolean(Application["Modules." + sNAME + ".RestEnabled"]) && nACLACCESS > 0 )
						sb.AppendLine("TERMINOLOGY_LISTS['" + sListName + "'].push('" + Sql.EscapeJavaScript(sNAME) + "'" + Strings.Space(nMAX_NAME - sNAME.Length) + ");");
				}
				else
				{
					sb.AppendLine("TERMINOLOGY_LISTS['" + sListName + "'].push('" + Sql.EscapeJavaScript(sNAME) + "'" + Strings.Space(nMAX_NAME - sNAME.Length) + ");");
				}
			}
			foreach ( System.Data.DataRow row in dt.Rows )
			{
				string sNAME         = Sql.ToString(row["NAME"        ]);
				string sDISPLAY_NAME = Sql.ToString(row["DISPLAY_NAME"]);
				if ( sListName == "record_type_display" )
				{
					int nACLACCESS = Security.GetUserAccess(sNAME, "list");
					if ( Sql.ToBoolean(Application["Modules." + sNAME + ".RestEnabled"]) && nACLACCESS > 0 )
						sb.AppendLine("TERMINOLOGY['." + sListName + "." + sNAME + "'" + Strings.Space(nMAX_NAME - sNAME.Length) + "] = '" + Sql.EscapeJavaScript(L10n.Term(sDISPLAY_NAME)) + "';");
				}
				else
				{
					sb.AppendLine("TERMINOLOGY['." + sListName + "." + sNAME + "'" + Strings.Space(nMAX_NAME - sNAME.Length) + "] = '" + Sql.EscapeJavaScript(L10n.Term(sDISPLAY_NAME)) + "';");
				}
			}
			if ( sListName == "record_type_display" )
			{
				foreach ( System.Data.DataRow row in dt.Rows )
				{
					string sNAME = Sql.ToString(row["NAME"]);
					int nACLACCESS = Security.GetUserAccess(sNAME, "list");
					if ( Sql.ToBoolean(Application["Modules." + sNAME + ".RestEnabled"]) && nACLACCESS > 0 )
						sb.AppendLine("TERMINOLOGY['" + sNAME + ".LBL_LIST_FORM_TITLE'" + Strings.Space(nMAX_NAME - sNAME.Length) + " ] = '" + Sql.EscapeJavaScript(L10n.Term(sNAME + ".LBL_LIST_FORM_TITLE")) + "';");
				}
			}
		}

		protected string BuildTerminologyListScripts()
		{
			StringBuilder sb = new StringBuilder();
			BuildTerminologyListScript(sb, "record_type_display");
			System.Data.DataTable dt = SplendidCache.List("record_type_display");
			foreach ( System.Data.DataRow row in dt.Rows )
			{
				string sNAME = Sql.ToString(row["NAME"]);
				int nACLACCESS = Security.GetUserAccess(sNAME, "list");
				if ( Sql.ToBoolean(Application["Modules." + sNAME + ".RestEnabled"]) && nACLACCESS > 0 )
				{
					DataTable dtFields = SplendidCache.EditViewFields(sNAME + ".SearchPopup");
					foreach ( DataRow rowEdit in dtFields.Rows )
					{
						string sFIELD_TYPE = Sql.ToString(rowEdit["FIELD_TYPE"]);
						if ( String.Compare(sFIELD_TYPE, "ListBox", true) == 0 )
						{
							string sCACHE_NAME = Sql.ToString (rowEdit["CACHE_NAME"]);
							BuildTerminologyListScript(sb, sCACHE_NAME);
						}
					}
					dtFields = SplendidCache.GridViewColumns(sNAME + ".ListView");
					foreach ( DataRow rowList in dtFields.Rows )
					{
						string sLIST_NAME = Sql.ToString (rowList["LIST_NAME"]);
						if ( !Sql.IsEmptyString(sLIST_NAME) )
						{
							BuildTerminologyListScript(sb, sLIST_NAME);
						}
					}
				}
			}
			return sb.ToString();
		}
		
		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_MODULE_TITLE"));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
				// 08/25/2013 Paul.  jQuery now registered in the master pages. 
				//HtmlLink cssJQuery = new HtmlLink();
				//cssJQuery.Attributes.Add("href" , "~/html5/jQuery/jquery-ui-1.9.1.custom.css");
				//cssJQuery.Attributes.Add("type" , "text/css"  );
				//cssJQuery.Attributes.Add("rel"  , "stylesheet");
				//Page.Header.Controls.Add(cssJQuery);
				
				// 07/01/2017 Paul.  Simplify stylesheet references. 
				Sql.AddStyleSheet(this.Page, "~/html5/FullCalendar/fullcalendar.css"      );
				Sql.AddStyleSheet(this.Page, "~/html5/FullCalendar/fullcalendar.print.css");
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				string sBundleName = "~/Calendar/html5/SplendidScriptsCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidScripts = new Bundle(sBundleName);
				// 08/25/2013 Paul.  jQuery now registered in the master pages. 
				bndSplendidScripts.Include("~/html5/jQuery/jquery-ui-timepicker-addon.js");
				// 02/22/2013 Paul.  Can't use min FullCalendar as we have customized the code. 
				bndSplendidScripts.Include("~/html5/FullCalendar/fullcalendar.js"    );
				bndSplendidScripts.Include("~/html5/FullCalendar/gcal.js"            );
				BundleTable.Bundles.Add(bndSplendidScripts);
				Sql.AddScriptReference(mgrAjax, sBundleName);

				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/Calendar/html5/SplendidUICombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidUI = new Bundle(sBundleName);
				bndSplendidUI.Include("~/html5/Utility.js"                      );
				bndSplendidUI.Include("~/html5/SplendidScripts/ListView.js"     );
				bndSplendidUI.Include("~/html5/SplendidScripts/EditView.js"     );
				bndSplendidUI.Include("~/html5/SplendidUI/Formatting.js"        );
				bndSplendidUI.Include("~/html5/SplendidUI/Sql.js"               );
				// 01/30/2016 Paul.  Add Parent and Description. 
				bndSplendidUI.Include("~/html5/SplendidUI/CalendarViewUI.js"    );
				bndSplendidUI.Include("~/html5/SplendidUI/PopupViewUI.js"       );
				bndSplendidUI.Include("~/html5/SplendidUI/ListViewUI.js"        );
				bndSplendidUI.Include("~/html5/SplendidUI/EditViewUI.js"        );
				bndSplendidUI.Include("~/html5/SplendidUI/SearchViewUI.js"      );
				bndSplendidUI.Include("~/html5/SplendidUI/SplendidInitUI.js"    );
				BundleTable.Bundles.Add(bndSplendidUI);
				Sql.AddScriptReference(mgrAjax, sBundleName);
				
				/*
				// 08/25/2013 Paul.  jQuery now registered in the master pages. 
				//if ( !mgrAjax.Scripts.Contains(scrJQuery        ) ) mgrAjax.Scripts.Add(scrJQuery        );
				//if ( !mgrAjax.Scripts.Contains(scrJQueryUI      ) ) mgrAjax.Scripts.Add(scrJQueryUI      );
				if ( !mgrAjax.Scripts.Contains(scrTimePicker    ) ) mgrAjax.Scripts.Add(scrTimePicker    );
				if ( !mgrAjax.Scripts.Contains(scrFullCalendar  ) ) mgrAjax.Scripts.Add(scrFullCalendar  );
				if ( !mgrAjax.Scripts.Contains(scrGoogleCalUtil ) ) mgrAjax.Scripts.Add(scrGoogleCalUtil );
				// 08/28/2013 Paul.  json2.js now registered in the master pages. 
				//if ( !mgrAjax.Scripts.Contains(scrJSON          ) ) mgrAjax.Scripts.Add(scrJSON          );
				if ( !mgrAjax.Scripts.Contains(scrCalendarViewUI) ) mgrAjax.Scripts.Add(scrCalendarViewUI);
				if ( !mgrAjax.Scripts.Contains(scrUtility       ) ) mgrAjax.Scripts.Add(scrUtility       );
				if ( !mgrAjax.Scripts.Contains(scrFormatting    ) ) mgrAjax.Scripts.Add(scrFormatting    );
				if ( !mgrAjax.Scripts.Contains(scrSQL           ) ) mgrAjax.Scripts.Add(scrSQL           );
				// 01/30/2016 Paul.  Add Parent and Description. 
				if ( !mgrAjax.Scripts.Contains(scrPopupViewUI   ) ) mgrAjax.Scripts.Add(scrPopupViewUI   );
				if ( !mgrAjax.Scripts.Contains(scrListViewUI    ) ) mgrAjax.Scripts.Add(scrListViewUI    );
				if ( !mgrAjax.Scripts.Contains(scrEditViewUI    ) ) mgrAjax.Scripts.Add(scrEditViewUI    );
				if ( !mgrAjax.Scripts.Contains(scrSearchViewUI  ) ) mgrAjax.Scripts.Add(scrSearchViewUI  );
				if ( !mgrAjax.Scripts.Contains(scrSplendidInitUI) ) mgrAjax.Scripts.Add(scrSplendidInitUI);
				if ( !mgrAjax.Scripts.Contains(scrListView      ) ) mgrAjax.Scripts.Add(scrListView      );
				if ( !mgrAjax.Scripts.Contains(scrEditView      ) ) mgrAjax.Scripts.Add(scrEditView      );
				*/
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
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
			m_sMODULE = "Calendar";
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}


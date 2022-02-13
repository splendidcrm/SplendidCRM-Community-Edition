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
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for DashletHeader.
	/// </summary>
	public class DashletHeader : SplendidControl
	{
		protected string sTitle       = String.Empty;
		protected string sDivEditName = String.Empty;
		protected bool   bShowCommandTitles = false;
		protected Label  lblTitle    ;
		// 04/23/2016 Paul.  How dashlets to be disabled. 
		protected ImageButton imgRefresh;
		protected LinkButton  bntRefresh;
		protected ImageButton imgEdit   ;
		protected LinkButton  bntEdit   ;
		protected ImageButton imgRemove ;
		protected LinkButton  bntRemove ;

		public CommandEventHandler Command ;

		public bool ShowEdit
		{
			get { return !Sql.IsEmptyString(sDivEditName); }
		}

		public string Title
		{
			get { return sTitle; }
			set { sTitle = value; }
		}

		public string DivEditName
		{
			get { return sDivEditName; }
			set { sDivEditName = value; }
		}

		public bool ShowCommandTitles
		{
			get { return bShowCommandTitles; }
			set { bShowCommandTitles = value; }
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			// 06/21/2009 Paul.  We need to be able to send the Refresh event to the parent. 
			if ( Command != null )
				Command(this, e) ;
		}
		
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 04/23/2016 Paul.  How dashlets to be disabled. 
			if ( !IsPostBack )
			{
				imgRemove.Visible = !Sql.ToBoolean(Application["CONFIG.disable_add_dashlets"]);
				// 10/02/2016 Paul.  Need to include ShowCommandTitles as this will over-write the inline condition. 
				bntRemove.Visible = !Sql.ToBoolean(Application["CONFIG.disable_add_dashlets"]) && ShowCommandTitles;
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
		}
		#endregion
	}
}


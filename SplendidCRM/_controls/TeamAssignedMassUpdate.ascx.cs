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

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for TeamAssignedMassUpdate.
	/// </summary>
	public class TeamAssignedMassUpdate : SplendidControl
	{
		protected bool         bShowAssigned      = true;
		protected HiddenField  ASSIGNED_USER_ID   ;
		protected HiddenField  TEAM_ID            ;
		protected TeamSelect   ctlTeamSelect      ;

		public bool ShowAssigned
		{
			get { return bShowAssigned; }
			set { bShowAssigned = value; }
		}

		public Guid ASSIGNED_USER
		{
			get
			{
				return Sql.ToGuid(ASSIGNED_USER_ID.Value);
			}
		}

		public Guid PRIMARY_TEAM_ID
		{
			get
			{
				if ( Crm.Config.enable_dynamic_teams() )
				{
					// 08/30/2009 Paul.  Use a separate call to get the primary so that we don't 
					// over-write the primary unless the user specifically wants that. 
					return ctlTeamSelect.PRIMARY_TEAM_ID;
				}
				return Sql.ToGuid(TEAM_ID.Value);
			}
		}

		public string TEAM_SET_LIST
		{
			get
			{
				if ( Crm.Config.enable_dynamic_teams() )
					return ctlTeamSelect.TEAM_SET_LIST;
				return String.Empty;
			}
		}

		public bool ADD_TEAM_SET
		{
			get
			{
				if ( Crm.Config.enable_dynamic_teams() )
					return ctlTeamSelect.ADD_TEAM_SET;
				return false;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 09/11/2007 Paul.  If neither the assigned nor the team are visbile, then hide the entire user control. 
			if ( !bShowAssigned && !Crm.Config.enable_team_management() )
				this.Visible = false;
			
			if ( !IsPostBack )
			{
				ctlTeamSelect.LoadLineItems(Guid.Empty, false);
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


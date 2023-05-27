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
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using Twilio.Clients;
using Twilio.Rest.Api.V2010.Account;

namespace SplendidCRM.Administration.Twilio
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected SearchBasic   ctlSearchBasic                     ;
		protected HtmlTable     tblMain                            ;
		protected DataGrid      grdMain                            ;
		protected Label         lblError                           ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Clear" )
				{
					ctlSearchBasic.ClearForm();
					Cache.Remove("Twilio.Messages");
					grdMain.CurrentPageIndex = 0;
				}
				else if ( e.CommandName == "Search" )
				{
					Cache.Remove("Twilio.Messages");
					grdMain.CurrentPageIndex = 0;
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text += ex.Message;
			}
			try
			{
				Bind(true);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text += ex.Message;
			}
		}

		protected void OnPageIndexChanged(Object sender, DataGridPageChangedEventArgs e)
		{
			Cache.Remove("Twilio.Messages");
			grdMain.CurrentPageIndex = e.NewPageIndex;
			Bind(true);
		}

		private void Bind(bool bBind)
		{
			if ( !Sql.IsEmptyString(Context.Application["CONFIG.Twilio.AccountSID"]) && !Sql.IsEmptyString(Context.Application["CONFIG.Twilio.AuthToken"]) )
			{
				List<MessageResource> result = Cache.Get("Twilio.Messages") as List<MessageResource>;
				if ( result == null )
				{
					result = TwilioManager.ListMessages(Application, ctlSearchBasic.DATE_SENT, ctlSearchBasic.FROM_NUMBER, ctlSearchBasic.TO_NUMBER, grdMain.CurrentPageIndex);
					Cache.Insert("Twilio.Messages", result, null, DateTime.Now.AddMinutes(1), System.Web.Caching.Cache.NoSlidingExpiration);
					//grdMain.AllowCustomPaging = true;
					//grdMain.VirtualItemCount  = result.Total;
					//grdMain.PageSize          = result.PageSize;
					grdMain.DataSource        = result;
				}
				if ( bBind )
				{
					grdMain.DataBind();
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
			{
				Parent.DataBind();
				return;
			}

			try
			{
				if ( !IsPostBack )
				{
					Cache.Remove("Twilio.Messages");
					ctlSearchBasic.FROM_NUMBER  = Sql.ToString(Application["CONFIG.Twilio.FromPhone"]);
				}
				Bind(!IsPostBack);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = Utils.ExpandException(ex);
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
			ctlSearchBasic.Command += new CommandEventHandler(Page_Command);
			grdMain.PageIndexChanged += new DataGridPageChangedEventHandler(OnPageIndexChanged);
			m_sMODULE = "Twilio";
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

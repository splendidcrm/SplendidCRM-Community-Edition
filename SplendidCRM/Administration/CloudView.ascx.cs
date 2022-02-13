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

namespace SplendidCRM.Administration
{
	/// <summary>
	///		Summary description for CloudView.
	/// </summary>
	public class CloudView : SplendidControl
	{
		protected Image     imgGOOGLE;
		protected HyperLink lnkGOOGLE;
		protected Label     lblGOOGLE;

		protected Image     imgQuickBooks;
		protected HyperLink lnkQuickBooks;
		protected Label     lblQuickBooks;

		protected Image     imgHubSpot;
		protected HyperLink lnkHubSpot;
		protected Label     lblHubSpot;

		protected Image     imgiContact;
		protected HyperLink lnkiContact;
		protected Label     lbliContact;

		protected Image     imgConstantContact;
		protected HyperLink lnkConstantContact;
		protected Label     lblConstantContact;

		protected Image     imgMarketo;
		protected HyperLink lnkMarketo;
		protected Label     lblMarketo;

		protected Image     imgGetResponse;
		protected HyperLink lnkGetResponse;
		protected Label     lblGetResponse;

		protected Image     imgMailChimp;
		protected HyperLink lnkMailChimp;
		protected Label     lblMailChimp;

		protected Image     imgPardot;
		protected HyperLink lnkPardot;
		protected Label     lblPardot;

		protected Image     imgWatson;
		protected HyperLink lnkWatson;
		protected Label     lblWatson;

		protected Image     imgPhoneBurner;
		protected HyperLink lnkPhoneBurner;
		protected Label     lblPhoneBurner;

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				imgGOOGLE.Visible = Utils.CachedFileExists(Context, lnkGOOGLE.NavigateUrl);
				lnkGOOGLE.Visible = imgGOOGLE.Visible;
				lblGOOGLE.Visible = imgGOOGLE.Visible;
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				imgQuickBooks.Visible = Utils.CachedFileExists(Context, lnkQuickBooks.NavigateUrl);
				lnkQuickBooks.Visible = imgQuickBooks.Visible;
				lblQuickBooks.Visible = imgQuickBooks.Visible;
				// 04/27/2015 Paul.  Add support for HubSpot to Professional or higher. 
				imgHubSpot.Visible = Utils.CachedFileExists(Context, lnkHubSpot.NavigateUrl);
				lnkHubSpot.Visible = imgHubSpot.Visible;
				lblHubSpot.Visible = imgHubSpot.Visible;
				// 06/28/2015 Paul.  Add support for iContact to Professional or higher. 
				imgiContact.Visible = Utils.CachedFileExists(Context, lnkiContact.NavigateUrl);
				lnkiContact.Visible = imgiContact.Visible;
				lbliContact.Visible = imgiContact.Visible;
				// 06/28/2015 Paul.  Add support for ConstantContact to Professional or higher. 
				imgConstantContact.Visible = Utils.CachedFileExists(Context, lnkConstantContact.NavigateUrl);
				lnkConstantContact.Visible = imgConstantContact.Visible;
				lblConstantContact.Visible = imgConstantContact.Visible;
				// 06/28/2015 Paul.  Add support for Marketo to Professional or higher. 
				imgMarketo.Visible = Utils.CachedFileExists(Context, lnkMarketo.NavigateUrl);
				lnkMarketo.Visible = imgMarketo.Visible;
				lblMarketo.Visible = imgMarketo.Visible;
				// 06/28/2015 Paul.  Add support for GetResponse to Professional or higher. 
				imgGetResponse.Visible = Utils.CachedFileExists(Context, lnkGetResponse.NavigateUrl);
				// 06/28/2015 Paul.  We are not ready to support GetResponse. 
#if !DEBUG
				imgGetResponse.Visible = false;
#endif
				lnkGetResponse.Visible = imgGetResponse.Visible;
				lblGetResponse.Visible = imgGetResponse.Visible;
				// 04/30/2016 Paul.  Add support MailChimp. 
				imgMailChimp.Visible = Utils.CachedFileExists(Context, lnkMailChimp.NavigateUrl);
				lnkMailChimp.Visible = imgMailChimp.Visible;
				lblMailChimp.Visible = imgMailChimp.Visible;
				// 07/15/2017 Paul.  Add support Pardot. 
				imgPardot.Visible = Utils.CachedFileExists(Context, lnkPardot.NavigateUrl);
				lnkPardot.Visible = imgPardot.Visible;
				lblPardot.Visible = imgPardot.Visible;
				// 01/25/2018 Paul.  Add support Watson. 
				imgWatson.Visible = Utils.CachedFileExists(Context, lnkWatson.NavigateUrl);
				lnkWatson.Visible = imgWatson.Visible;
				lblWatson.Visible = imgWatson.Visible;
				// 09/11/2020 Paul.  Add support PhoneBurner. 
				imgPhoneBurner.Visible = Utils.CachedFileExists(Context, lnkPhoneBurner.NavigateUrl);
				lnkPhoneBurner.Visible = imgPhoneBurner.Visible;
				lblPhoneBurner.Visible = imgPhoneBurner.Visible;
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


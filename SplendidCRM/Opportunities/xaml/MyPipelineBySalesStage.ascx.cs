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
using System.Xml;
using System.Data;
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace SplendidCRM.Opportunities.xaml
{
	/// <summary>
	///		Summary description for MyPipelineBySalesStage.
	/// </summary>
	public class MyPipelineBySalesStage : PipelineBySalesStage
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 09/21/2008 Paul.  Mono does not support Silverlight inline XAML at this time. 
			// 09/22/2008 Paul.  The Mono exception code was moved to enable_silverlight(). 
			if ( !Crm.Config.enable_silverlight() )
			{
				this.Visible = false;
				return;
			}
			// 09/11/2008 Paul.  Silverlight requires that all numeric values need to be in US format. 
			// Reset the culture before binding/rendering so that all the numeric conversions will be automatic. 
			// All currencies should already be converted to text, so there should not be an impact. 
			// 01/11/2009 Paul.  We need to save and restore the previous culture as there are other controls on the page. 
			// 10/13/2010 Paul.  Move the culture fix higher up so that all numeric ToString() operations are in English. 
			System.Globalization.CultureInfo ciCurrent = System.Threading.Thread.CurrentThread.CurrentCulture;
			try
			{
				System.Globalization.CultureInfo ciEnglish = System.Globalization.CultureInfo.CreateSpecificCulture("en-US");
				ciEnglish.DateTimeFormat.ShortDatePattern = ciCurrent.DateTimeFormat.ShortDatePattern;
				ciEnglish.DateTimeFormat.ShortTimePattern = ciCurrent.DateTimeFormat.ShortTimePattern;
				ciEnglish.NumberFormat.CurrencySymbol     = ciCurrent.NumberFormat.CurrencySymbol;
				System.Threading.Thread.CurrentThread.CurrentCulture   = ciEnglish;
				System.Threading.Thread.CurrentThread.CurrentUICulture = ciEnglish;
				this.DataBind();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message);
			}
			finally
			{
				System.Threading.Thread.CurrentThread.CurrentCulture   = ciCurrent;
				System.Threading.Thread.CurrentThread.CurrentUICulture = ciCurrent;
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
			// 02/11/2008 Paul.  GetCurrent is a better way to get the Ajax manager. 
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			if ( mgrAjax != null && Crm.Config.enable_silverlight() )
			{
				ScriptReference scrSilverlight          = new ScriptReference ("~/Include/Silverlight/Silverlight.js"        );
				mgrAjax.Scripts.Add(scrSilverlight         );
			}
		}
		
		/// <summary>
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			nGridWidth  = 160;
		}
		#endregion
	}
}


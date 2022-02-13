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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Globalization;
using System.Threading;
using System.Diagnostics;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for TimePicker.
	/// </summary>
	public class TimePicker : SplendidControl
	{
		protected int          nMinutesIncrement = 5;
		private   DateTime     dtValue  = DateTime.MinValue;
		protected DropDownList lstHOUR      ;
		protected DropDownList lstMINUTE    ;
		protected DropDownList lstMERIDIEM  ;
		protected Label        lblTIMEFORMAT;

		public System.EventHandler Changed ;

		protected void Date_Changed(object sender, System.EventArgs e)
		{
			if ( Changed != null )
				Changed(this, e) ;
		}

		public int MinutesIncrement
		{
			get
			{
				return nMinutesIncrement;
			}
			set
			{
				nMinutesIncrement = value;
				if ( nMinutesIncrement <= 0 )
					nMinutesIncrement = 1;
			}
		}

		public bool AutoPostBack
		{
			get
			{
				return lstHOUR.AutoPostBack;
			}
			set
			{
				lstHOUR    .AutoPostBack = value;
				lstMINUTE  .AutoPostBack = value;
				lstMERIDIEM.AutoPostBack = value;
			}
		}

		public DateTime Value
		{
			get
			{
				// 12/31/2007 Paul.  Exit early if neither value was specified. 
				// If only one value is specified, then the other is assumed to be 0. 
				if ( lstHOUR.SelectedValue == "" && lstMINUTE.SelectedValue == "" )
					return DateTime.MinValue;
				// 12/31/2007 Paul.  Use 1900 as the base year because that is the minimum for SQL Server.  .NET can go down to 00/00/0000. 
				dtValue = new DateTime(1900, 1, 1);
				bool b12Hour = lstMERIDIEM.Visible;
				if ( b12Hour )
				{
					if ( lstMERIDIEM.SelectedValue == "PM" )
					{
						if ( lstHOUR.SelectedValue == "12" )
							dtValue = dtValue.AddHours(12);
						else if ( lstHOUR.SelectedValue != "" )
							dtValue = dtValue.AddHours(12 + Sql.ToInteger(lstHOUR.SelectedValue));
						if ( lstMINUTE.SelectedValue != "" )
							dtValue = dtValue.AddMinutes(Sql.ToInteger(lstMINUTE.SelectedValue));
					}
					else
					{
						if ( lstHOUR.SelectedValue != "12" && lstHOUR.SelectedValue != "" )
							dtValue = dtValue.AddHours(Sql.ToInteger(lstHOUR.SelectedValue));
						if ( lstMINUTE.SelectedValue != "" )
							dtValue = dtValue.AddMinutes(Sql.ToInteger(lstMINUTE.SelectedValue));
					}
				}
				else
				{
					if ( lstHOUR.SelectedValue != "" )
						dtValue = dtValue.AddHours  (Sql.ToInteger(lstHOUR  .SelectedValue));
					if ( lstMINUTE.SelectedValue != "" )
						dtValue = dtValue.AddMinutes(Sql.ToInteger(lstMINUTE.SelectedValue));
				}
				return dtValue;
			}
			set
			{
				dtValue = value;
				SetDate();
			}
		}

		public short TabIndex
		{
			get
			{
				return lstHOUR.TabIndex;
			}
			set
			{
				lstHOUR    .TabIndex = value;
				lstMINUTE  .TabIndex = value;
				lstMERIDIEM.TabIndex = value;
			}
		}

		public bool Enabled
		{
			set
			{
				lstHOUR    .Enabled = value;
				lstMINUTE  .Enabled = value;
				lstMERIDIEM.Enabled = value;
			}
		}

		private void SetDate()
		{
			// 03/10/2006 Paul.  Make sure to only populate the list once. 
			// We populate inside SetDate because we need the list to have values before the value can be set. 
			if ( lstMINUTE.Items.Count == 0 )
			{
				for ( int nMinute = 0 ; nMinute < 60 ; nMinute += nMinutesIncrement )
				{
					lstMINUTE.Items.Add(new ListItem(nMinute.ToString("00"), nMinute.ToString("00")));
				}
				// 01/26/2008 Paul.  Move the empty string to the top. 
				lstMINUTE.Items.Insert(0, new ListItem("--", ""));
			}
			string sTimeFormat = Sql.ToString(Session["USER_SETTINGS/TIMEFORMAT"]);
			bool b12Hour = (sTimeFormat.IndexOf("tt") >= 0);
			// 03/10/2006 Paul.  Make sure to only populate the list once. 
			// We populate inside SetDate because we need the list to have values before the value can be set. 
			if ( lstHOUR.Items.Count == 0 )
			{
				if ( b12Hour )
				{
					for ( int nHour = 1 ; nHour <= 12 ; nHour++ )
					{
						// 01/26/2008 Paul.  Make sure that 12 is first. 
						if ( nHour == 12 )
							lstHOUR.Items.Insert(0, new ListItem(nHour.ToString("00"), nHour.ToString("00")));
						else
							lstHOUR.Items.Add(new ListItem(nHour.ToString("00"), nHour.ToString("00")));
					}
					lstHOUR.Items.Insert(0, new ListItem("--", ""));
					lstMERIDIEM.Visible = true;
				}
				else
				{
					for ( int nHour = 0 ; nHour < 24 ; nHour++ )
					{
						lstHOUR.Items.Add(new ListItem(nHour.ToString("00"), nHour.ToString("00")));
					}
					lstHOUR.Items.Insert(0, new ListItem("--", ""));
					lstMERIDIEM.Visible = false;
				}
			}
			if ( dtValue > DateTime.MinValue )
			{
				try
				{
					int nMinutes = dtValue.Minute;
					if ( nMinutesIncrement == 1 )
					{
						lstMINUTE.SelectedValue = nMinutes.ToString("00");
					}
					else
					{
						for ( int nMinute = 0 ; nMinute < 60 ; nMinute += nMinutesIncrement )
						{
							if ( nMinutes <= (nMinute + nMinutesIncrement / 2) )
							{
								lstMINUTE.SelectedValue = nMinute.ToString("00");
								break;
							}
						}
					}
					
					int nHours = dtValue.Hour;
					if ( b12Hour )
					{
						// 07/11/2006 Paul.  The Meridiem dropdown needs to be populated before we set its value. 
						lstMERIDIEM_Bind();
						if ( nHours >= 12 )
						{
							nHours -= 12;
							lstMERIDIEM.SelectedValue = "PM";
						}
						else
						{
							lstMERIDIEM.SelectedValue = "AM";
						}
						if ( nHours == 0 )
							lstHOUR.SelectedValue = (12).ToString("00");
						else
							lstHOUR.SelectedValue = nHours.ToString("00");
					}
					else
					{
						lstHOUR.SelectedValue = nHours.ToString("00");
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
			}
			else
			{
				// 12/31/2007 Paul.  For a new record, default to Nothing. 
				// 01/26/2008 Paul.  Nothing was moved to the top. 
				//lstMINUTE.SelectedIndex = lstHOUR.Items.Count - 1;
				//lstHOUR.SelectedIndex = lstHOUR.Items.Count - 1;
			}
		}

		// 11/11/2010 Paul.  Provide a way to disable validation in a rule. 
		public void Validate()
		{
			Validate(true);
		}

		public void Validate(bool bEnabled)
		{
		}

		// 07/11/2006 Paul.  The Meridiem dropdown may need to be populated before Page_Load. 
		private void lstMERIDIEM_Bind()
		{
			if ( lstMERIDIEM.Items.Count == 0 )
			{
				DateTimeFormatInfo oDateInfo = Thread.CurrentThread.CurrentCulture.DateTimeFormat;
				lstMERIDIEM.Items.Add(new ListItem(oDateInfo.AMDesignator, "AM"));
				lstMERIDIEM.Items.Add(new ListItem(oDateInfo.PMDesignator, "PM"));
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !Page.IsPostBack )
			{
				DateTime dt1100PM = DateTime.Today.AddHours(23);
				lblTIMEFORMAT.Text = "(" + dt1100PM.ToShortTimeString() + ")";
				
				lstMERIDIEM_Bind();
				SetDate();
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


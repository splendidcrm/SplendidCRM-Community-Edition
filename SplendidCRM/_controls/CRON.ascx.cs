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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Threading;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for CRON.
	/// </summary>
	public class CRON : SplendidControl
	{
		protected Panel           pnlCRONValue   ;
		protected CheckBox        chkCRONShow    ;
		protected TextBox         CRON_MINUTES   ;
		protected TextBox         CRON_HOURS     ;
		protected TextBox         CRON_DAYOFMONTH;
		protected TextBox         CRON_MONTHS    ;
		protected TextBox         CRON_DAYOFWEEK ;
		protected Label           lblCRON_MESSAGE;

		protected RadioButtonList radFREQUENCY   ;
		protected Label           lblMINUTES     ;
		protected ListBox         lstMINUTES     ;
		protected Label           lblHOURS       ;
		protected ListBox         lstHOURS       ;
		protected Label           lblDAYOFMONTH  ;
		protected ListBox         lstDAYOFMONTH  ;
		protected CheckBoxList    chkDAYOFWEEK   ;
		protected CheckBoxList    chkMONTHS      ;

		public string Value
		{
			get
			{
				return CRON_MINUTES.Text + "::" + CRON_HOURS.Text + "::" + CRON_DAYOFMONTH.Text + "::" + CRON_MONTHS.Text + "::" + CRON_DAYOFWEEK.Text;
			}
			set
			{
				string sJOB_INTERVAL = value;
				sJOB_INTERVAL = sJOB_INTERVAL.Replace(" ", "");
				string[] arrCRON    = sJOB_INTERVAL.Replace("::", "|").Split('|');
				// minute  hour  dayOfMonth  month  dayOfWeek
				CRON_MINUTES   .Text = (arrCRON.Length > 0) ? arrCRON[0] : "*";
				CRON_HOURS     .Text = (arrCRON.Length > 1) ? arrCRON[1] : "*";
				CRON_DAYOFMONTH.Text = (arrCRON.Length > 2) ? arrCRON[2] : "*";
				CRON_MONTHS    .Text = (arrCRON.Length > 3) ? arrCRON[3] : "*";
				CRON_DAYOFWEEK .Text = (arrCRON.Length > 4) ? arrCRON[4] : "*";
				// 06/26/2010 Paul.  Display the CRON plain-text message. 
				CRON_Changed(null, null);
			}
		}

		public short TabIndex
		{
			get
			{
				return CRON_MINUTES.TabIndex;
			}
			set
			{
				CRON_MINUTES   .TabIndex = value;
				CRON_HOURS     .TabIndex = value;
				CRON_DAYOFMONTH.TabIndex = value;
				CRON_MONTHS    .TabIndex = value;
				CRON_DAYOFWEEK .TabIndex = value;
			}
		}

		public void Clear()
		{
			CRON_MINUTES   .Text = "*";
			CRON_HOURS     .Text = "*";
			CRON_DAYOFMONTH.Text = "*";
			CRON_MONTHS    .Text = "*";
			CRON_DAYOFWEEK .Text = "*";
		}

		public void Validate()
		{
			CRON_MINUTES   .Text = CRON_MINUTES   .Text.Trim();
			CRON_HOURS     .Text = CRON_HOURS     .Text.Trim();
			CRON_DAYOFMONTH.Text = CRON_DAYOFMONTH.Text.Trim();
			CRON_MONTHS    .Text = CRON_MONTHS    .Text.Trim();
			CRON_DAYOFWEEK .Text = CRON_DAYOFWEEK .Text.Trim();
			if ( Sql.IsEmptyString(CRON_MINUTES   .Text) ) CRON_MINUTES   .Text = "*";
			if ( Sql.IsEmptyString(CRON_HOURS     .Text) ) CRON_HOURS     .Text = "*";
			if ( Sql.IsEmptyString(CRON_DAYOFMONTH.Text) ) CRON_DAYOFMONTH.Text = "*";
			if ( Sql.IsEmptyString(CRON_MONTHS    .Text) ) CRON_MONTHS    .Text = "*";
			if ( Sql.IsEmptyString(CRON_DAYOFWEEK .Text) ) CRON_DAYOFWEEK .Text = "*";
		}

		protected void CRON_Changed(object sender, System.EventArgs e)
		{
			CRON_MINUTES   .Text = CRON_MINUTES   .Text.Trim();
			CRON_HOURS     .Text = CRON_HOURS     .Text.Trim();
			CRON_DAYOFMONTH.Text = CRON_DAYOFMONTH.Text.Trim();
			CRON_MONTHS    .Text = CRON_MONTHS    .Text.Trim();
			CRON_DAYOFWEEK .Text = CRON_DAYOFWEEK .Text.Trim();
			if ( Sql.IsEmptyString(CRON_MINUTES   .Text) ) CRON_MINUTES   .Text = "*";
			if ( Sql.IsEmptyString(CRON_HOURS     .Text) ) CRON_HOURS     .Text = "*";
			if ( Sql.IsEmptyString(CRON_DAYOFMONTH.Text) ) CRON_DAYOFMONTH.Text = "*";
			if ( Sql.IsEmptyString(CRON_MONTHS    .Text) ) CRON_MONTHS    .Text = "*";
			if ( Sql.IsEmptyString(CRON_DAYOFWEEK .Text) ) CRON_DAYOFWEEK .Text = "*";
			lblCRON_MESSAGE.Text = SchedulerUtils.CronDescription(L10n, this.Value);

			if ( lstMINUTES.Items.Count == 0 )
			{
				for ( int i = 0; i < 60; i += 5 )
				{
					ListItem item = new ListItem(i.ToString("00"), i.ToString());
					lstMINUTES.Items.Add(item);
				}
			}
			if ( lstHOURS.Items.Count == 0 )
			{
				for ( int i = 0; i < 24; i++ )
				{
					ListItem item = new ListItem(i.ToString("00"), i.ToString());
					lstHOURS.Items.Add(item);
				}
			}
			if ( lstDAYOFMONTH.Items.Count == 0 )
			{
				for ( int i = 1; i <= 31; i++ )
				{
					ListItem item = new ListItem(i.ToString("00"), i.ToString());
					lstDAYOFMONTH.Items.Add(item);
				}
			}
			if ( chkDAYOFWEEK.Items.Count == 0 )
			{
				chkDAYOFWEEK.DataSource = SplendidCache.List("scheduler_day_dom");
				chkDAYOFWEEK.DataBind();
			}
			if ( chkMONTHS.Items.Count == 0 )
			{
				chkMONTHS.DataSource = SplendidCache.List("scheduler_month_dom");
				chkMONTHS.DataBind();
			}
			SetCRONValue(lstMINUTES   , CRON_MINUTES   .Text);
			SetCRONValue(lstHOURS     , CRON_HOURS     .Text);
			SetCRONValue(lstDAYOFMONTH, CRON_DAYOFMONTH.Text);
			SetCRONValue(chkDAYOFWEEK , CRON_DAYOFWEEK .Text);
			SetCRONValue(chkMONTHS    , CRON_MONTHS    .Text);
			SetFrequency();
		}

		#region CRON Value
		protected void SetFrequency()
		{
			try
			{
				if ( CRON_DAYOFMONTH.Text == "*" && CRON_DAYOFWEEK.Text == "*" && CRON_MONTHS.Text == "*" )
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(radFREQUENCY, "Daily");
				}
				else if ( CRON_DAYOFMONTH.Text == "*" && CRON_DAYOFWEEK.Text != "*"  && CRON_MONTHS.Text == "*")
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(radFREQUENCY, "Weekly");
				}
				else if ( CRON_DAYOFMONTH.Text != "*" && CRON_DAYOFWEEK.Text == "*" && CRON_MONTHS.Text == "*" )
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(radFREQUENCY, "Monthly");
				}
				else if ( CRON_DAYOFMONTH.Text != "*" && CRON_DAYOFWEEK.Text == "*" && CRON_MONTHS.Text != "*" )
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(radFREQUENCY, "Yearly");
				}
			}
			catch
			{
			}
			lblDAYOFMONTH.Visible = true;
			lstDAYOFMONTH.Visible = true;
			chkDAYOFWEEK .Visible = true;
			chkMONTHS    .Visible = true;
			switch ( radFREQUENCY.SelectedValue )
			{
				case "Daily"  :
					lblDAYOFMONTH.Visible = false;
					lstDAYOFMONTH.Visible = false;
					chkDAYOFWEEK .Visible = false;
					chkMONTHS    .Visible = false;
					break;
				case "Weekly" :
					chkMONTHS    .Visible = false;
					break;
				case "Monthly":
					chkDAYOFWEEK .Visible = false;
					break;
				case "Yearly" :
					chkDAYOFWEEK .Visible = false;
					break;
			}
		}

		protected void SetCRONValue(ListControl lst, string sValue)
		{
			if ( sValue == "*" )
			{
				foreach ( ListItem item in lst.Items )
					item.Selected = true;
			}
			else
			{
				foreach ( ListItem item in lst.Items )
					item.Selected = false;
				
				string[] arrCommaSep = sValue.Split(',');
				foreach ( string sParam in arrCommaSep )
				{
					string[] arrRange = sParam.Split('-');
					if ( arrRange.Length > 1 )
					{
						int nStart = 0;
						int nEnd   = 0;
						if ( Int32.TryParse(arrRange[0], out nStart) && Int32.TryParse(arrRange[1], out nEnd) )
						{
							if ( nStart <= nEnd )
							{
								for ( int nParam = nStart; nParam <= nEnd; nParam++ )
								{
									ListItem item = lst.Items.FindByValue(nParam.ToString());
									if ( item != null )
										item.Selected = true;
								}
							}
						}
					}
					else
					{
						int nParam = 0;
						if ( Int32.TryParse(arrRange[0], out nParam) )
						{
							ListItem item = lst.Items.FindByValue(nParam.ToString());
							if ( item != null )
								item.Selected = true;
						}
					}
				}
			}
		}

		protected string BuildCRONValue(ListControl lst)
		{
			StringBuilder sb = new StringBuilder();
			int  nStart      = -1;
			int  nEnd        = -1;
			bool bRangeStart = false;
			for ( int i = 0; i < lst.Items.Count; i++ )
			{
				ListItem item = lst.Items[i];
				if ( item.Selected )
				{
					if ( !bRangeStart )
					{
						nStart      = i;
						nEnd        = i;
						bRangeStart = true;
					}
					else
					{
						nEnd = i;
					}
				}
				else if ( bRangeStart )
				{
					if ( sb.Length > 0 )
						sb.Append(',');
					if ( nEnd > nStart )
						sb.Append(lst.Items[nStart].Value + "-" + lst.Items[nEnd].Value);
					else
						sb.Append(lst.Items[nStart].Value);
					nStart      = -1;
					nEnd        = -1;
					bRangeStart = false;
				}
			}
			if ( bRangeStart )
			{
				if ( sb.Length > 0 )
					sb.Append(',');
				if ( nEnd > nStart )
					sb.Append(lst.Items[nStart].Value + "-" + lst.Items[nEnd].Value);
				else
					sb.Append(lst.Items[nStart].Value);
				nStart      = -1;
				nEnd        = -1;
				bRangeStart = false;
			}
			return sb.ToString();
		}
		#endregion

		protected void radFREQUENCY_SelectedIndexChanged(object sender, EventArgs e)
		{
			switch ( radFREQUENCY.SelectedValue )
			{
				case "Daily"  :
					CRON_MINUTES   .Text = "0";
					CRON_HOURS     .Text = DateTime.Now.Hour.ToString();
					CRON_DAYOFMONTH.Text = "*";
					CRON_DAYOFWEEK .Text = "*";
					CRON_MONTHS    .Text = "*";
					break;
				case "Weekly" :
					CRON_MINUTES   .Text = "0";
					CRON_HOURS     .Text = DateTime.Now.Hour.ToString();
					CRON_DAYOFMONTH.Text = "*";
					CRON_DAYOFWEEK .Text = ((int) DateTime.Now.DayOfWeek).ToString();
					CRON_MONTHS    .Text = "*";
					break;
				case "Monthly":
					CRON_DAYOFMONTH.Text = DateTime.Now.Day.ToString();
					CRON_DAYOFWEEK .Text = "*";
					CRON_MONTHS    .Text = "*";
					break;
				case "Yearly" :
					CRON_DAYOFMONTH.Text = DateTime.Now.Day.ToString();
					CRON_DAYOFWEEK .Text = "*";
					CRON_MONTHS    .Text = DateTime.Now.Month.ToString();
					break;
			}
			CRON_Changed(null, null);
		}

		protected void lstMINUTES_SelectedIndexChanged(object sender, EventArgs e)
		{
			CRON_MINUTES.Text = BuildCRONValue(lstMINUTES);
			if ( CRON_MINUTES.Text == "0-55" || CRON_MINUTES.Text == String.Empty )
			{
				CRON_MINUTES.Text = "*";
			}
			SetFrequency();
			lblCRON_MESSAGE.Text = SchedulerUtils.CronDescription(L10n, this.Value);
		}

		protected void lstHOURS_SelectedIndexChanged(object sender, EventArgs e)
		{
			CRON_HOURS.Text = BuildCRONValue(lstHOURS);
			if ( CRON_HOURS.Text == "0-23" || CRON_HOURS.Text == String.Empty )
			{
				CRON_HOURS.Text = "*";
			}
			SetFrequency();
			lblCRON_MESSAGE.Text = SchedulerUtils.CronDescription(L10n, this.Value);
		}

		protected void lstDAYOFMONTH_SelectedIndexChanged(object sender, EventArgs e)
		{
			CRON_DAYOFMONTH.Text = BuildCRONValue(lstDAYOFMONTH);
			if ( CRON_DAYOFMONTH.Text == "0-31" || CRON_DAYOFMONTH.Text == String.Empty )
			{
				CRON_DAYOFMONTH.Text = "*";
			}
			SetFrequency();
			lblCRON_MESSAGE.Text = SchedulerUtils.CronDescription(L10n, this.Value);
		}

		protected void chkDAYOFWEEK_SelectedIndexChanged(object sender, EventArgs e)
		{
			CRON_DAYOFWEEK.Text = BuildCRONValue(chkDAYOFWEEK);
			if ( CRON_DAYOFWEEK.Text == "0-6" || CRON_DAYOFWEEK.Text == String.Empty )
			{
				CRON_DAYOFWEEK.Text = "*";
			}
			SetFrequency();
			lblCRON_MESSAGE.Text = SchedulerUtils.CronDescription(L10n, this.Value);
		}

		protected void chkMONTHS_SelectedIndexChanged(object sender, EventArgs e)
		{
			CRON_MONTHS.Text = BuildCRONValue(chkMONTHS);
			if ( CRON_MONTHS.Text == "1-12" || CRON_MONTHS.Text == String.Empty )
			{
				CRON_MONTHS.Text = "*";
			}
			SetFrequency();
			lblCRON_MESSAGE.Text = SchedulerUtils.CronDescription(L10n, this.Value);
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			//reqDATE.ErrorMessage = L10n.Term(".ERR_REQUIRED_FIELD");
			//valDATE.ErrorMessage = L10n.Term(".ERR_INVALID_DATE");

			if ( !IsPostBack )
			{
				lblCRON_MESSAGE.Text = L10n.Term("Schedulers.LBL_CRONTAB_EXAMPLES");
				radFREQUENCY.DataSource = SplendidCache.List("scheduler_frequency_dom");
				radFREQUENCY.DataBind();
				CRON_Changed(null, null);
			}
			pnlCRONValue.DataBind();
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


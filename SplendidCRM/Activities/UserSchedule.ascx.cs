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
using System.Globalization;

namespace SplendidCRM.Activities
{
	/// <summary>
	///		Summary description for UserSchedule.
	/// </summary>
	public class UserSchedule : SplendidControl
	{
		protected Label         lblError         ;
		protected PlaceHolder   plcSchedulingRows;
		protected HtmlTable     tblSchedule      ;
		protected DateTime      dtSCHEDULE_START ;
		protected DateTime      dtSCHEDULE_END   ;
		protected DateTime      dtDATE_START = DateTime.MinValue;
		protected DateTime      dtDATE_END   = DateTime.MaxValue;
		protected Guid          gUSER_ID         ;

		public CommandEventHandler Command ;

		public DateTime DATE_START
		{
			get
			{
				return dtDATE_START;
			}
			set
			{
				dtDATE_START = value;
			}
		}
		
		public DateTime DATE_END
		{
			get
			{
				return dtDATE_END;
			}
			set
			{
				dtDATE_END = value;
			}
		}

		public Guid USER_ID
		{
			get
			{
				return gUSER_ID;
			}
			set
			{
				gUSER_ID = value;
			}
		}
		
		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( Command != null )
					Command(this, e) ;
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void AddInvitee(Guid gUSER_ID)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				string sFULL_NAME    = String.Empty;
				string sINVITEE_TYPE = String.Empty;
				sSQL = "select *         " + ControlChars.CrLf
				     + "  from vwINVITEES" + ControlChars.CrLf
				     + " where ID = @ID  " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@ID", gUSER_ID);

					if ( bDebug )
						RegisterClientScriptBlock("vwINVITEES", Sql.ClientScriptBlock(cmd));

					using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
					{
						if ( rdr.Read() )
						{
							sFULL_NAME    = Sql.ToString(rdr["FULL_NAME"   ]);
							sINVITEE_TYPE = Sql.ToString(rdr["INVITEE_TYPE"]);
						}
					}
				}
				sSQL = "select *                                                       " + ControlChars.CrLf
				     + "  from vwACTIVITIES_List                                       " + ControlChars.CrLf
				     + " where ASSIGNED_USER_ID = @ASSIGNED_USER_ID                    " + ControlChars.CrLf
				     + "   and (   DATE_START >= @DATE_START and DATE_START < @DATE_END" + ControlChars.CrLf
				     + "        or DATE_END   >= @DATE_START and DATE_END   < @DATE_END" + ControlChars.CrLf
				     + "        or DATE_START <  @DATE_START and DATE_END   > @DATE_END" + ControlChars.CrLf
				     + "       )                                                       " + ControlChars.CrLf
				     + " order by DATE_START asc, NAME asc                             " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", gUSER_ID        );
					Sql.AddParameter(cmd, "@DATE_START"      , T10n.ToServerTime(dtSCHEDULE_START));
					Sql.AddParameter(cmd, "@DATE_END"        , T10n.ToServerTime(dtSCHEDULE_END  ));

					if ( bDebug )
						RegisterClientScriptBlock("vwACTIVITIES_List", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								HtmlTableRow rowInvitee = new HtmlTableRow();
								tblSchedule.Rows.Add(rowInvitee);
								rowInvitee.Attributes.Add("class", "schedulerAttendeeRow");
								if ( dt.Rows.Count > 0 )
								{
									DataView vwMain = new DataView(dt);
									CultureInfo ciEnglish = CultureInfo.CreateSpecificCulture("en-US");
									for(DateTime dtHOUR_START = dtSCHEDULE_START; dtHOUR_START < dtSCHEDULE_END ; dtHOUR_START = dtHOUR_START.AddMinutes(15) )
									{
										DateTime dtHOUR_END   = dtHOUR_START.AddMinutes(15);
										DateTime dtHOUR_START_ServerTime = T10n.ToServerTime(dtHOUR_START);
										DateTime dtHOUR_END_ServerTime   = T10n.ToServerTime(dtHOUR_END  );
										// 09/27/2005 Paul.  System.Data.DataColumn.Expression documentation has description how to define dates and strings. 
										// 08/08/2006 Paul.  Use the same ServerTime logic as DayGrid.ascx.cs to solve date formatting issues on international systems. 
										string sHOUR_START_ServerTime = dtHOUR_START_ServerTime.ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat);
										string sHOUR_END_ServerTime   = dtHOUR_END_ServerTime  .ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat);
										vwMain.RowFilter = "   DATE_START >= #" + sHOUR_START_ServerTime + "# and DATE_START <  #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf
										                 + "or DATE_END   >  #" + sHOUR_START_ServerTime + "# and DATE_END   <= #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf
										                 + "or DATE_START <  #" + sHOUR_START_ServerTime + "# and DATE_END   >  #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf;
#if DEBUG
//										RegisterClientScriptBlock("vwACTIVITIES_List" + dtHOUR_START.ToOADate().ToString(), Sql.EscapeJavaScript(vwMain.RowFilter));
#endif
										HtmlTableCell cellInvitee = new HtmlTableCell();
										rowInvitee.Cells.Add(cellInvitee);
										// 07/23/2014 Paul.  listView.td style is interferring with scheduler styles, so manually apply. 
										string sStyle = String.Empty;
										if ( dtHOUR_START == dtDATE_END )
											sStyle += "padding: 0px 0px 0px 0px; border-top: 1px solid #dddddd; border-left: 4px solid #ff0000; border-bottom: 1px solid #dddddd; border-right: 1px solid #dddddd; background-color: #eeeeee; width: 15px;";
										else if ( dtHOUR_START == dtDATE_START )
											sStyle += "padding: 0px 0px 0px 0px; border-top: 1px solid #dddddd; border-left: 4px solid #75af4f; border-bottom: 1px solid #dddddd; border-right: 1px solid #dddddd; background-color: #eeeeee; width: 15px;";
										else
											sStyle += "padding: 0px 0px 0px 0px; border: 1px solid #dddddd; background-color: #eeeeee; width: 15px;";
										if ( vwMain.Count > 0 )
										{
											if ( dtHOUR_START >= dtDATE_START && dtHOUR_START < dtDATE_END )
												sStyle += "BACKGROUND-COLOR: #aa4d4d;";
											else
												sStyle += "BACKGROUND-COLOR: #4d5eaa;";
										}
										else
										{
											if ( dtHOUR_START >= dtDATE_START && dtHOUR_START < dtDATE_END )
												sStyle += "BACKGROUND-COLOR: #ffffff;";
										}
										cellInvitee.Attributes.Add("style", sStyle);
									}
								}
								else
								{
									for(DateTime dtHOUR_START = dtSCHEDULE_START; dtHOUR_START < dtSCHEDULE_END ; dtHOUR_START = dtHOUR_START.AddMinutes(15) )
									{
										DateTime dtHOUR_END   = dtHOUR_START.AddMinutes(15);
										HtmlTableCell cellInvitee = new HtmlTableCell();
										rowInvitee.Cells.Add(cellInvitee);
										// 07/23/2014 Paul.  listView.td style is interferring with scheduler styles, so manually apply. 
										string sStyle = String.Empty;
										if ( dtHOUR_START == dtDATE_END )
											sStyle += "padding: 0px 0px 0px 0px; border-top: 1px solid #dddddd; border-left: 4px solid #ff0000; border-bottom: 1px solid #dddddd; border-right: 1px solid #dddddd; background-color: #eeeeee; width: 15px;";
										else if ( dtHOUR_START == dtDATE_START )
											sStyle += "padding: 0px 0px 0px 0px; border-top: 1px solid #dddddd; border-left: 4px solid #75af4f; border-bottom: 1px solid #dddddd; border-right: 1px solid #dddddd; background-color: #eeeeee; width: 15px;";
										else
											sStyle += "padding: 0px 0px 0px 0px; border: 1px solid #dddddd; background-color: #eeeeee; width: 15px;";
										if ( dtHOUR_START >= dtDATE_START && dtHOUR_START < dtDATE_END )
											sStyle += "BACKGROUND-COLOR: #ffffff;";
										cellInvitee.Attributes.Add("style", sStyle);
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
					}
				}
			}
		}

		public void BuildSchedule()
		{
			try
			{
				dtSCHEDULE_START = new DateTime(dtDATE_START.Year, dtDATE_START.Month, dtDATE_START.Day, dtDATE_START.Hour, 0, 0, 0);
				// 01/16/2006 Paul.  Date may not allow adding hours.  It may already be at the minimum.  Just ignore the error. 
				dtSCHEDULE_START = dtSCHEDULE_START.AddHours(-4);
				dtSCHEDULE_END   = dtSCHEDULE_START.AddHours(9);
			}
			catch
			{
				return;
			}
			try
			{
				tblSchedule.Rows.Clear();
				
				HtmlTableRow  rowTime = new HtmlTableRow();
				tblSchedule.Rows.Add(rowTime);
				for(DateTime dtHOUR_START = dtSCHEDULE_START; dtHOUR_START < dtSCHEDULE_END ; dtHOUR_START = dtHOUR_START.AddHours(1) )
				{
					HtmlTableCell cellTime = new HtmlTableCell();
					cellTime.Attributes.Add("style", "padding-left: 4px; text-align: left;");
					cellTime.ColSpan = 4;
					cellTime.InnerText = dtHOUR_START.ToShortTimeString();
					rowTime.Cells.Add(cellTime);
				}
				if ( !Sql.IsEmptyGuid(gUSER_ID) )
				{
					AddInvitee(gUSER_ID);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		public override void DataBind()
		{
			base.DataBind();
			if ( !Sql.IsEmptyGuid(gUSER_ID) )
			{
				BuildSchedule();
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
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


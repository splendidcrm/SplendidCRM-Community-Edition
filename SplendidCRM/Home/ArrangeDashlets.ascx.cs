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

namespace SplendidCRM.Home
{
	/// <summary>
	///		Summary description for ArrangeDashlets.
	/// </summary>
	public class ArrangeDashlets : SplendidControl
	{
		protected DataView        vwMain       ;
		protected SplendidGrid    grdMain      ;
		protected Label           lblError     ;
		protected HtmlInputHidden txtINSERT    ;
		protected HtmlInputHidden txtKEY       ;
		protected HtmlInputHidden txtVALUE     ;
		protected HiddenField     txtINDEX     ;
		protected HiddenField     txtDASHLET_ID;
		protected string          sDetailView  ;
		protected string          sCategory    ;

		public string DetailView
		{
			get { return sDetailView; }
			set { sDetailView = value; }
		}

		public string Category
		{
			get { return sCategory; }
			set { sCategory = value; }
		}

		protected string DetailViewClientName
		{
			get { return sDetailView.Replace(".", "_"); }
		}

		protected void grdMain_ItemCreated(object sender, DataGridItemEventArgs e)
		{
			if ( e.Item.ItemType == ListItemType.Header || e.Item.ItemType == ListItemType.Footer )
			{
				e.Item.CssClass += " nodrag nodrop";
			}
			else if ( e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem )
			{
				DataRowView row = e.Item.DataItem as DataRowView;
				if ( row != null )
				{
					if ( !Sql.ToBoolean(row["DASHLET_ENABLED"]) )
						e.Item.CssClass += " nodrag nodrop";
				}
			}
		}

		protected void txtINDEX_ValueChanged(object sender, EventArgs e)
		{
			try
			{
				string[] arrValueChanged = txtINDEX.Value.Split(',');
				if ( arrValueChanged.Length < 2 )
					throw(new Exception("Invalid changed values: " + txtINDEX.Value));
				
				txtINDEX.Value = String.Empty;
				int nOLD_VALUE = Sql.ToInteger(arrValueChanged[0]);
				int nNEW_VALUE = Sql.ToInteger(arrValueChanged[1]);
				//lblError.Text = "(" + nOLD_VALUE.ToString() + ", " + nNEW_VALUE.ToString() + ")";
				if ( nOLD_VALUE < 0 )
					throw(new Exception("OldIndex cannot be negative."));
				if ( nNEW_VALUE < 0 )
					throw(new Exception("NewIndex cannot be negative."));
				if ( nOLD_VALUE >= vwMain.Count )
					throw(new Exception("OldIndex cannot exceed " + vwMain.Count.ToString()));
				if ( nNEW_VALUE >= vwMain.Count )
					throw(new Exception("NewIndex cannot exceed " + vwMain.Count.ToString()));
				
				int nOLD_INDEX = Sql.ToInteger(vwMain[nOLD_VALUE]["DASHLET_ORDER"]);
				int nNEW_INDEX = Sql.ToInteger(vwMain[nNEW_VALUE]["DASHLET_ORDER"]);
				SqlProcs.spDASHLETS_USERS_MoveItem(Security.USER_ID, sDetailView, nOLD_INDEX, nNEW_INDEX);
				//lblError.Text += "(" + nOLD_INDEX.ToString() + ", " + nNEW_INDEX.ToString() + ")";
				
				SplendidCache.ClearUserDashlets(sDetailView);
				DETAILVIEWS_USERS_BindData(true);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				Guid gID = Sql.ToGuid(e.CommandArgument);
				if ( Sql.IsEmptyGuid(gID) )
					throw(new Exception("Unspecified argument"));
				if ( e.CommandName == "Dashlets.MoveUp" )
				{
					SqlProcs.spDASHLETS_USERS_MoveUp(gID);
					SplendidCache.ClearUserDashlets(sDetailView);
				}
				else if ( e.CommandName == "Dashlets.MoveDown" )
				{
					SqlProcs.spDASHLETS_USERS_MoveDown(gID);
					SplendidCache.ClearUserDashlets(sDetailView);
				}
				else if ( e.CommandName == "Dashlets.Disable" )
				{
					SqlProcs.spDASHLETS_USERS_Disable(gID);
					SplendidCache.ClearUserDashlets(sDetailView);
				}
				else if ( e.CommandName == "Dashlets.Enable" )
				{
					SqlProcs.spDASHLETS_USERS_Enable(gID);
					SplendidCache.ClearUserDashlets(sDetailView);
				}
				else if ( e.CommandName == "Dashlets.Delete" )
				{
					SqlProcs.spDASHLETS_USERS_Delete(gID);
					SplendidCache.ClearUserDashlets(sDetailView);
				}
				DETAILVIEWS_USERS_BindData(true);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void DETAILVIEWS_USERS_BindData(bool bBind)
		{
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					// 08/01/2009 Paul.  Make sure to only show items assigned to this user. 
					sSQL = "select *                                             " + ControlChars.CrLf
					     + "  from vwDASHLETS_USERS                              " + ControlChars.CrLf
					     + " where ASSIGNED_USER_ID = @ASSIGNED_USER_ID          " + ControlChars.CrLf
					     + "   and DETAIL_NAME      = @DETAIL_NAME               " + ControlChars.CrLf
					     + " order by DASHLET_ENABLED, DASHLET_ORDER, MODULE_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", Security.USER_ID);
						Sql.AddParameter(cmd, "@DETAIL_NAME"     , sDetailView     );

						if ( bDebug )
							RegisterClientScriptBlock("SQLCode." + sDetailView, Sql.ClientScriptBlock(cmd));

						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								if ( bBind )
									grdMain.DataBind();
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

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				if ( !Sql.IsEmptyString(txtDASHLET_ID.Value) )
				{
					SqlProcs.spDASHLETS_USERS_MassUpdate(txtDASHLET_ID.Value, Security.USER_ID, sDetailView);
					// 01/24/2010 Paul.  Not sure why we did not need to clear before now. 
					SplendidCache.ClearUserDashlets(sDetailView);
					txtDASHLET_ID.Value = String.Empty;
				}
				if ( !IsPostBack )
				{
					// Must bind in order for LinkButton to get the argument. 
					// 08/19/2010 Paul.  Remove the binding as it seems to interfere with the drag table. 
					//Page.DataBind();
					// 07/11/2009 Paul.  The DETAILVIEWS_USERS may not be populated for this user, so always call Init. 
					SqlProcs.spDASHLETS_USERS_Init(Security.USER_ID, sDetailView);
				}
				// 08/19/2010 Paul.  Lets experiment with jQuery drag and drop. 
				ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
				// 08/25/2013 Paul.  jQuery now registered in the master pages. 
				//ScriptReference  scrJQuery         = new ScriptReference ("~/Include/javascript/jquery-1.4.2.min.js"   );
				ScriptReference  scrJQueryTableDnD = new ScriptReference ("~/Include/javascript/jquery.tablednd_0_5.js");
				//if ( !mgrAjax.Scripts.Contains(scrJQuery) )
				//	mgrAjax.Scripts.Add(scrJQuery);
				if ( !mgrAjax.Scripts.Contains(scrJQueryTableDnD) )
					mgrAjax.Scripts.Add(scrJQueryTableDnD);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
			DETAILVIEWS_USERS_BindData(true);
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
			grdMain.ItemCreated += new DataGridItemEventHandler(grdMain_ItemCreated);
			txtINDEX.ValueChanged += new EventHandler(txtINDEX_ValueChanged);
		}
		#endregion
	}
}


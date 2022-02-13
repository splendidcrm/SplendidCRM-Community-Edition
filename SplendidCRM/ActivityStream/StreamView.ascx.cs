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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.ActivityStream
{
	/// <summary>
	///		Summary description for StreamView.
	/// </summary>
	public class StreamView : SplendidControl
	{
		#region Properties
		protected _controls.HeaderButtons ctlModuleHeader;
		protected SearchBasic             ctlSearchBasic ;
		protected NewRecord               ctlNewRecord   ;
		protected Panel                   pnlNewRecordInline;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected List<String>  arrStreamModules;
		protected bool          bShowSearchDialog = true;
		protected bool          bShowHeader       = true;
		protected bool          bRecentActivity   = false;

		public string Module
		{
			get { return m_sMODULE; }
			set { m_sMODULE = value; }
		}

		public bool ShowSearchDialog
		{
			get { return bShowSearchDialog; }
			set { bShowSearchDialog = value; }
		}

		public bool ShowHeader
		{
			get { return bShowHeader; }
			set { bShowHeader = value; }
		}

		public bool RecentActivity
		{
			get { return bRecentActivity; }
			set { bRecentActivity = value; }
		}

		#endregion

		public StreamView()
		{
			m_sMODULE = "ActivityStream";
		}

		public static string StreamFormatDescription(string sModule, L10N L10n, TimeZone T10n, object DataItem)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			DataRowView row = DataItem as DataRowView;
			string sSTREAM_ACTION        = Sql.ToString(row["STREAM_ACTION"]).ToUpper();
			if ( Sql.IsEmptyString(sSTREAM_ACTION) )
				sSTREAM_ACTION = "UPDATED";
			
			string sSTREAM_TEMPLATE_FORMAT = L10n.Term(sModule + ".LBL_STREAM_FORMAT_" + sSTREAM_ACTION);
			string sSTREAM_TEMPLATE_FIELDS = L10n.Term(sModule + ".LBL_STREAM_FIELDS_" + sSTREAM_ACTION);
			// 09/25/2015 Paul.  The two are a match set, so if either does not exist, then use default. 
			if ( (sSTREAM_TEMPLATE_FORMAT == sModule + ".LBL_STREAM_FORMAT_" + sSTREAM_ACTION) || (sSTREAM_TEMPLATE_FIELDS == sModule + ".LBL_STREAM_FIELDS_" + sSTREAM_ACTION) )
			{
				if ( sSTREAM_ACTION == "CREATED" )
				{
					sSTREAM_TEMPLATE_FORMAT = "{0} <a href=\"~/" + sModule + "/view.aspx?ID={1}\">{2}</a> {3}.";
					sSTREAM_TEMPLATE_FIELDS = "ActivityStream.LBL_CREATED ID NAME .moduleListSingular." + sModule;
				}
				else if ( sSTREAM_ACTION == "UPDATED" )
				{
					sSTREAM_TEMPLATE_FORMAT = "{0} <span class=\"ActivityStreamUpdateFields\">{1}</span> on <a href=\"~/" + sModule + "/view.aspx?ID={2}\">{3}</a>.";
					sSTREAM_TEMPLATE_FIELDS = "ActivityStream.LBL_UPDATED STREAM_COLUMNS ID NAME";
				}
				else if ( sSTREAM_ACTION == "DELETED" )
				{
					sSTREAM_TEMPLATE_FORMAT = "{0} {1} {2}.";
					sSTREAM_TEMPLATE_FIELDS = "ActivityStream.LBL_DELETED NAME .moduleListSingular." + sModule;
				}
				else if ( sSTREAM_ACTION == "POST" )
				{
					sSTREAM_TEMPLATE_FORMAT = "{0}";
					sSTREAM_TEMPLATE_FIELDS = "NAME";
				}
				else if ( sSTREAM_ACTION == "LINKED" )
				{
					sSTREAM_TEMPLATE_FORMAT = "{0} <a href=\"~/" + sModule + "/view.aspx?ID={1}\">{2}</a> {3} {4} <a href=\"~/{5}/view.aspx?ID={6}\">{7}</a>.";
					sSTREAM_TEMPLATE_FIELDS = "ActivityStream.LBL_LINKED ID NAME ActivityStream.LBL_TO .moduleListSingular.STREAM_RELATED_MODULE STREAM_RELATED_MODULE STREAM_RELATED_ID STREAM_RELATED_NAME";
				}
				else if ( sSTREAM_ACTION == "UNLINKED" )
				{
					sSTREAM_TEMPLATE_FORMAT = "{0} <a href=\"~/" + sModule + "/view.aspx?ID={1}\">{2}</a> {3} {4} <a href=\"~/{5}/view.aspx?ID={6}\">{7}</a>.";
					sSTREAM_TEMPLATE_FIELDS = "ActivityStream.LBL_UNLINKED ID NAME ActivityStream.LBL_FROM .moduleListSingular.STREAM_RELATED_MODULE STREAM_RELATED_MODULE STREAM_RELATED_ID STREAM_RELATED_NAME";
				}
			}
			sSTREAM_TEMPLATE_FORMAT = sSTREAM_TEMPLATE_FORMAT.Replace("~/", Sql.ToString(Application["rootURL"]));
			
			string[] arrDATA_FIELD = sSTREAM_TEMPLATE_FIELDS.Split(' ');
			object[] objDATA_FIELD = new object[arrDATA_FIELD.Length];
			for ( int i = 0 ; i < arrDATA_FIELD.Length; i++ )
			{
				if ( arrDATA_FIELD[i].IndexOf(".") >= 0 )
				{
					if ( arrDATA_FIELD[i] == ".moduleListSingular.STREAM_RELATED_MODULE" )
					{
						string sSTREAM_RELATED_MODULE = Sql.ToString(row["STREAM_RELATED_MODULE"]);
						objDATA_FIELD[i] = L10n.Term(".moduleListSingular." + sSTREAM_RELATED_MODULE);
					}
					else
					{
						objDATA_FIELD[i] = L10n.Term(arrDATA_FIELD[i]);
					}
				}
				else if ( arrDATA_FIELD[i] == "STREAM_COLUMNS" )
				{
					if ( sSTREAM_ACTION == "UPDATED" )
					{
						objDATA_FIELD[i] = L10n.Term("ActivityStream.LBL_NONE");
						if ( !Sql.IsEmptyString(row[arrDATA_FIELD[i]]) )
						{
							StringBuilder sb = new StringBuilder();
							string[] arrSTREAM_COLUMNS = Sql.ToString(row[arrDATA_FIELD[i]]).Split(' ');
							for ( int j = 0; j < arrSTREAM_COLUMNS.Length && j < 5; j++ )
							{
								if ( sb.Length > 0 )
									sb.Append(", ");
								sb.Append(Utils.TableColumnName(L10n, sModule, arrSTREAM_COLUMNS[j]));
							}
							if ( arrSTREAM_COLUMNS.Length > 5 )
								sb.Append(", " + L10n.Term("ActivityStream.LBL_MORE"));
							objDATA_FIELD[i] = sb.ToString();
						}
					}
					else
					{
						objDATA_FIELD[i] = String.Empty;
					}
				}
				else if ( !Sql.IsEmptyString(arrDATA_FIELD[i]) )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sModule, arrDATA_FIELD[i], Guid.Empty);
					if ( !acl.IsReadable() )
						objDATA_FIELD[i] = String.Empty;
					else if ( row[arrDATA_FIELD[i]] != DBNull.Value )
					{
						if ( row[arrDATA_FIELD[i]].GetType() == Type.GetType("System.DateTime") )
							objDATA_FIELD[i] = T10n.FromServerTime(row[arrDATA_FIELD[i]]);
						else if ( row[arrDATA_FIELD[i]].GetType() == typeof(System.String) )
						{
							string sDATA_VALUE = Sql.ToString(row[arrDATA_FIELD[i]]);
							objDATA_FIELD[i] = sDATA_VALUE;
							if ( sDATA_VALUE == "{Erased}" && (arrDATA_FIELD[i] == "NAME" || arrDATA_FIELD[i] == "STREAM_RELATED_NAME") )
							{
								objDATA_FIELD[i] = "<span class=\"Erased\">" + L10n.Term("DataPrivacy.LBL_ERASED_VALUE") + "</span>";
							}
							else
							{
								objDATA_FIELD[i] = HttpUtility.HtmlEncode(objDATA_FIELD[i]);
							}
						}
						else
							objDATA_FIELD[i] = row[arrDATA_FIELD[i]];
					}
					else
						objDATA_FIELD[i] = String.Empty;
				}
			}
			string sDESCRIPTION = String.Empty;
			try
			{
				sDESCRIPTION = String.Format(sSTREAM_TEMPLATE_FORMAT, objDATA_FIELD);
			}
			catch(Exception ex)
			{
				sDESCRIPTION = ex.Message;
			}
			return sDESCRIPTION;
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					grdMain.CurrentPageIndex = 0;
					grdMain.DataBind();
				}
				else if ( e.CommandName == "SortGrid" )
				{
					grdMain.SetSortFields(e.CommandArgument as string[]);
					arrSelectFields.AddFields(grdMain.SortColumn);
				}
				else
				{
					grdMain.DataBind();
					if ( Page.Master is SplendidMaster )
						(Page.Master as SplendidMaster).Page_Command(sender, e);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		public void RebindMain()
		{
			grdMain.DataBind();
		}

		protected void grdMain_OnSelectMethod(int nCurrentPageIndex, int nPageSize)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					// 06/02/2016 Paul.  Activities views will use new function that accepts an array of modules. 
					m_sVIEW_NAME = (m_sMODULE == "ActivityStream" ? "vwACTIVITY_STREAMS" : "vw" + Crm.Modules.TableName(m_sMODULE) + "_STREAM");
					cmd.CommandText = "  from " + m_sVIEW_NAME + ControlChars.CrLf;
					// 12/03/2017 Paul.  Module name field needs to be a parameter because it can change between MODULE_NAME and ACTIVITY_TYPE. 
					Security.Filter(cmd, arrStreamModules.ToArray(), "list", "ASSIGNED_USER_ID", "STREAM_RELATED_MODULE");
					string sASSIGNEDPlaceholder = Sql.NextPlaceholder(cmd, "ASSIGNED_USER_ID");
					cmd.CommandText += "   and (  CREATED_BY_ID     = @CREATED_BY_ID   " + ControlChars.CrLf;
					cmd.CommandText += "        or ASSIGNED_USER_ID = @" + sASSIGNEDPlaceholder + ControlChars.CrLf;
					cmd.CommandText += "        or ID in (select FAVORITE_RECORD_ID     from vwSUGARFAVORITES where FAVORITE_USER_ID     = @FAVORITE_USER_ID    " + (m_sMODULE == "ActivityStream" ? String.Empty : " and FAVORITE_MODULE          = @FAVORITE_MODULE         ") + ")" + ControlChars.CrLf;
					cmd.CommandText += "        or ID in (select SUBSCRIPTION_PARENT_ID from vwSUBSCRIPTIONS  where SUBSCRIPTION_USER_ID = @SUBSCRIPTION_USER_ID" + (m_sMODULE == "ActivityStream" ? String.Empty : " and SUBSCRIPTION_PARENT_TYPE = @SUBSCRIPTION_PARENT_TYPE") + ")" + ControlChars.CrLf;
					cmd.CommandText += "       )" + ControlChars.CrLf;
					Sql.AddParameter(cmd, "@CREATED_BY_ID"           , Security.USER_ID);
					Sql.AddParameter(cmd, "@" + sASSIGNEDPlaceholder, Security.USER_ID);
					Sql.AddParameter(cmd, "@FAVORITE_USER_ID"        , Security.USER_ID);
					if ( m_sMODULE != "ActivityStream" )
						Sql.AddParameter(cmd, "@FAVORITE_MODULE"         , m_sMODULE       );
					Sql.AddParameter(cmd, "@SUBSCRIPTION_USER_ID"    , Security.USER_ID);
					if ( m_sMODULE != "ActivityStream" )
						Sql.AddParameter(cmd, "@SUBSCRIPTION_PARENT_TYPE", m_sMODULE       );
					ctlSearchBasic.SqlSearchClause(cmd);
					if ( bRecentActivity )
					{
						int nRecentActivityDays = Sql.ToInteger(Application["CONFIG.ActivityStream.RecentActivityDays"]);
						if ( nRecentActivityDays == 0 )
							nRecentActivityDays = 7;
						cmd.CommandText += "   and STREAM_DATE > @STREAM_DATE" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@STREAM_DATE", DateTime.Now.AddDays(-nRecentActivityDays));
					}
					
					cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
					                + cmd.CommandText;
					if ( nPageSize > 0 )
					{
						Sql.PageResults(cmd, m_sVIEW_NAME, grdMain.OrderByClause(), nCurrentPageIndex, nPageSize);
					}
					else
					{
						cmd.CommandText += grdMain.OrderByClause();
					}
					
					if ( bDebug )
						RegisterClientScriptBlock("vwACTIVITY_STREAMS_Select", Sql.ClientScriptBlock(cmd));
					
					if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
							}
						}
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 06/15/2016 Paul.  Only set page title when showing header.  This will prevent dashlet from changing home page title. 
			if ( bShowHeader && !bRecentActivity )
				SetPageTitle(L10n.Term(".LBL_ACTIVITY_STREAM"));
			// 01/03/2017 Paul.  Allow the CONFIG enable_activity_streams setting to disable subpanel. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0) && this.StreamEnabled();
			if ( !this.Visible )
				return;

			try
			{
				// 09/25/2015  Paul.  Seems slow, so always paginate. 
				//if ( Crm.Config.allow_custom_paging() && Crm.Modules.CustomPaging(m_sMODULE) )
				{
					grdMain.AllowCustomPaging = true;
					grdMain.SelectMethod     += new SelectMethodHandler(grdMain_OnSelectMethod);
				}
				
				arrStreamModules = SplendidCache.StreamModulesArray(Security.USER_ID);
				pnlNewRecordInline.Visible = (m_sMODULE != "ActivityStream") && !PrintView;
				if ( this.IsMobile && grdMain.Columns.Count > 0 )
					grdMain.Columns[0].Visible = false;
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						grdMain.OrderByClause("STREAM_DATE desc, STREAM_VERSION desc", String.Empty);
						// 06/02/2016 Paul.  Activities views will use new function that accepts an array of modules. 
						m_sVIEW_NAME = (m_sMODULE == "ActivityStream" ? "vwACTIVITY_STREAMS" : "vw" + Crm.Modules.TableName(m_sMODULE) + "_STREAM");
						cmd.CommandText = "  from " + m_sVIEW_NAME + ControlChars.CrLf;
						// 12/03/2017 Paul.  Module name field needs to be a parameter because it can change between MODULE_NAME and ACTIVITY_TYPE. 
						Security.Filter(cmd, arrStreamModules.ToArray(), "list", "ASSIGNED_USER_ID", "STREAM_RELATED_MODULE");
						string sASSIGNEDPlaceholder = Sql.NextPlaceholder(cmd, "ASSIGNED_USER_ID");
						cmd.CommandText += "   and (  CREATED_BY_ID     = @CREATED_BY_ID   " + ControlChars.CrLf;
						cmd.CommandText += "        or ASSIGNED_USER_ID = @" + sASSIGNEDPlaceholder + ControlChars.CrLf;
						cmd.CommandText += "        or ID in (select FAVORITE_RECORD_ID     from vwSUGARFAVORITES where FAVORITE_USER_ID     = @FAVORITE_USER_ID    " + (m_sMODULE == "ActivityStream" ? String.Empty : " and FAVORITE_MODULE          = @FAVORITE_MODULE         ") + ")" + ControlChars.CrLf;
						cmd.CommandText += "        or ID in (select SUBSCRIPTION_PARENT_ID from vwSUBSCRIPTIONS  where SUBSCRIPTION_USER_ID = @SUBSCRIPTION_USER_ID" + (m_sMODULE == "ActivityStream" ? String.Empty : " and SUBSCRIPTION_PARENT_TYPE = @SUBSCRIPTION_PARENT_TYPE") + ")" + ControlChars.CrLf;
						cmd.CommandText += "       )" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@CREATED_BY_ID"           , Security.USER_ID);
						Sql.AddParameter(cmd, "@" + sASSIGNEDPlaceholder, Security.USER_ID);
						Sql.AddParameter(cmd, "@FAVORITE_USER_ID"        , Security.USER_ID);
						if ( m_sMODULE != "ActivityStream" )
							Sql.AddParameter(cmd, "@FAVORITE_MODULE"         , m_sMODULE       );
						Sql.AddParameter(cmd, "@SUBSCRIPTION_USER_ID"    , Security.USER_ID);
						if ( m_sMODULE != "ActivityStream" )
							Sql.AddParameter(cmd, "@SUBSCRIPTION_PARENT_TYPE", m_sMODULE       );
						ctlSearchBasic.SqlSearchClause(cmd);
						if ( bRecentActivity )
						{
							int nRecentActivityDays = Sql.ToInteger(Application["CONFIG.ActivityStream.RecentActivityDays"]);
							if ( nRecentActivityDays == 0 )
								nRecentActivityDays = 7;
							cmd.CommandText += "   and STREAM_DATE > @STREAM_DATE" + ControlChars.CrLf;
							Sql.AddParameter(cmd, "@STREAM_DATE", DateTime.Now.AddDays(-nRecentActivityDays));
						}
						
						if ( m_sMODULE == "ActivityStream" )
							arrSelectFields.Add("MODULE_NAME");
						else
							arrSelectFields.Add("\'" + m_sMODULE + "\' as MODULE_NAME");
						if ( grdMain.AllowCustomPaging )
						{
							cmd.CommandText = "select count(*)" + ControlChars.CrLf
							                + cmd.CommandText;
							
							if ( bDebug )
								RegisterClientScriptBlock("vwACTIVITY_STREAMS_Count", Sql.ClientScriptBlock(cmd));
							
							if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
							{
								grdMain.VirtualItemCount = Sql.ToInteger(cmd.ExecuteScalar());
							}
						}
						else
						{
							cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
							                + cmd.CommandText
							                + grdMain.OrderByClause();
							
							if ( bDebug )
								RegisterClientScriptBlock("vwACTIVITY_STREAMS", Sql.ClientScriptBlock(cmd));
							
							if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
							{
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dt = new DataTable() )
									{
										da.Fill(dt);
										// 11/22/2010 Paul.  Apply Business Rules. 
										this.ApplyGridViewRules("ActivityStream." + LayoutListView, dt);
										
										vwMain = dt.DefaultView;
										grdMain.DataSource = vwMain ;
									}
								}
							}
						}
					}
				}
				if ( !IsPostBack )
				{
					grdMain.DataBind();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
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
			ctlNewRecord.Command += new CommandEventHandler(Page_Command);
			ctlSearchBasic.Module = m_sMODULE;
			ctlNewRecord.Module = m_sMODULE;
			// 07/30/2016 Paul.  Only set menu when showing header.  This will prevent dashlet from changing home page title. 
			if ( !bRecentActivity )
				SetMenu(m_sMODULE);
			ctlModuleHeader.Module = m_sMODULE;
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"                   );
			arrSelectFields.Add("AUDIT_ID"             );
			arrSelectFields.Add("STREAM_DATE"          );
			arrSelectFields.Add("STREAM_ACTION"        );
			arrSelectFields.Add("STREAM_COLUMNS"       );
			arrSelectFields.Add("STREAM_RELATED_ID"    );
			arrSelectFields.Add("STREAM_RELATED_MODULE");
			arrSelectFields.Add("STREAM_RELATED_NAME"  );
			arrSelectFields.Add("NAME"                 );
			arrSelectFields.Add("CREATED_BY_ID"        );
			arrSelectFields.Add("CREATED_BY"           );
			arrSelectFields.Add("CREATED_BY_PICTURE"   );
			arrSelectFields.Add("ASSIGNED_USER_ID"     );
			SplendidDynamic.GridColumns(m_sMODULE + ".ActivityStream." + LayoutListView, arrSelectFields, null);
			if ( SplendidDynamic.StackedLayout(Page.Theme) )
			{
				ctlModuleHeader.Command += new CommandEventHandler(Page_Command);
				ctlModuleHeader.AppendButtons(m_sMODULE + "." + LayoutListView, Guid.Empty, null);
				grdMain.IsMobile       = this.IsMobile;
				grdMain.Command       += new CommandEventHandler(Page_Command);
			}
		}
		#endregion
	}
}


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

namespace SplendidCRM.Campaigns
{
	/// <summary>
	///		Summary description for CampaignTrackers.
	/// </summary>
	public class CampaignTrackers : SubPanelControl
	{
		// 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. 
		protected _controls.SubPanelButtons ctlDynamicButtons;
		protected UniqueStringCollection arrSelectFields;
		protected Guid            gID                ;
		protected DataView        vwMain             ;
		protected SplendidGrid    grdMain            ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "CampaignTrackers.Create":
						Response.Redirect("~/CampaignTrackers/edit.aspx?CAMPAIGN_ID=" + gID.ToString());
						break;
					case "CampaignTrackers.Edit":
					{
						Guid gCAMPAIGN_TRKR_ID = Sql.ToGuid(e.CommandArgument);
						Response.Redirect("~/CampaignTrackers/edit.aspx?ID=" + gCAMPAIGN_TRKR_ID.ToString() + "&CAMPAIGN_ID=" + gID.ToString());
						break;
					}
					case "CampaignTrackers.Remove":
					{
						Guid gCAMPAIGN_TRKR_ID = Sql.ToGuid(e.CommandArgument);
						if ( bEditView )
						{
							this.DeleteEditViewRelationship(gCAMPAIGN_TRKR_ID);
						}
						else
						{
							SqlProcs.spCAMPAIGN_TRKRS_Delete(gCAMPAIGN_TRKR_ID);
						}
						//Response.Redirect("view.aspx?ID=" + gID.ToString());
						// 05/16/2008 Paul.  Instead of redirecting, just rebind the grid and AJAX will repaint. 
						BindGrid();
						break;
					}
					default:
						throw(new Exception("Unknown command: " + e.CommandName));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void BindGrid()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				// 04/26/2008 Paul.  Build the list of fields to use in the select clause.
				// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
				m_sVIEW_NAME = "vwCAMPAIGNS_CAMPAIGN_TRKRS";
				sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
				     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
				     + "  from " + m_sVIEW_NAME + ControlChars.CrLf
				     + " where 1 = 1"           + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AppendParameter(cmd, gID, "CAMPAIGN_ID");
					// 04/26/2008 Paul.  Move Last Sort to the database.
					cmd.CommandText += grdMain.OrderByClause("DATE_ENTERED", "desc");

					if ( bDebug )
						RegisterClientScriptBlock("vwCAMPAIGNS_CAMPAIGN_TRKRS", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								// 03/07/2013 Paul.  Apply business rules to subpanel. 
								this.ApplyGridViewRules("Campaigns." + m_sMODULE, dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								// 04/25/2008 Paul.  Enable sorting of sub panel. 
								// 04/26/2008 Paul.  Move Last Sort to the database.
								grdMain.DataBind();
								if ( this.Visible )
								{
									// 01/27/2010 Paul.  In EditView mode, we need a list of existing relationships. 
									if ( bEditView && !IsPostBack )
									{
										this.CreateEditViewRelationships(dt, "ID");
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
					}
				}
			}
		}

		// 01/27/2010 Paul.  This method is only calld when in EditMode. 
		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			UniqueGuidCollection arrDELETED = this.GetDeletedEditViewRelationships();
			foreach ( Guid gDELETE_ID in arrDELETED )
			{
				if ( !Sql.IsEmptyGuid(gDELETE_ID) )
					SqlProcs.spCAMPAIGN_TRKRS_Delete(gDELETE_ID, trn);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			gID = Sql.ToGuid(Request["ID"]);
			try
			{
				// 08/27/2012 Paul.  Use the Page.Items to get the campaign type. 
				string sCAMPAIGN_TYPE = Sql.ToString(Page.Items["CAMPAIGN_TYPE"]);
				// 07/08/2007 Paul.  Only show this relationship if this is an Email Campaign. 
				this.Visible = (sCAMPAIGN_TYPE == "Email");
				BindGrid();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}

			if ( !IsPostBack )
			{
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
				// 04/28/2008 Paul.  Make use of dynamic buttons. 
				Guid gASSIGNED_USER_ID = Sql.ToGuid(Page.Items["ASSIGNED_USER_ID"]);
				ctlDynamicButtons.AppendButtons("Campaigns." + m_sMODULE, gASSIGNED_USER_ID, gID);
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "CampaignTrackers";
			// 04/26/2008 Paul.  We need to build a list of the fields used by the search clause. 
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"                       );
			arrSelectFields.Add("DATE_ENTERED"             );
			arrSelectFields.Add("CAMPAIGN_ASSIGNED_USER_ID");
			// 11/26/2005 Paul.  Add fields early so that sort events will get called. 
			this.AppendGridColumns(grdMain, "Campaigns." + m_sMODULE, arrSelectFields);
			// 04/28/2008 Paul.  Make use of dynamic buttons. 
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("Campaigns." + m_sMODULE, Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}


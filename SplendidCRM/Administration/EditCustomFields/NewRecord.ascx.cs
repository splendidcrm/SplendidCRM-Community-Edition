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
using System.Text.RegularExpressions;
using System.Diagnostics;

namespace SplendidCRM.Administration.EditCustomFields
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewRecord : SplendidControl
	{
		public CommandEventHandler Command ;
		protected _controls.ListHeader ctlListHeader;

		protected HtmlGenericControl         divNewRecord       ;
		protected Label                      lblError           ;
		protected HtmlTableRow               trDROPDOWN_LIST    ;
		// 02/02/2021 Paul.  Move preview to separate row. 
		protected HtmlTableRow               trDROPDOWN_LIST_PREVIEW;
		protected DataView                   vwPICK_LIST_VALUES ;
		protected DataGrid                   grdPICK_LIST_VALUES;
		protected string                     sMODULE_NAME       ;
		protected TextBox                    txtNAME            ;
		protected TextBox                    txtLABEL           ;
		protected DropDownList               lstDATA_TYPE       ;
		protected HtmlTableRow               trMAX_SIZE         ;
		protected TextBox                    txtMAX_SIZE        ;
		protected CheckBox                   chkREQUIRED        ;
		protected TextBox                    txtDEFAULT_VALUE   ;
		protected CheckBox                   chkAUDITED         ;
		protected DropDownList               lstDROPDOWN_LIST   ;
		protected RequiredFieldValidator     reqNAME            ;
		protected RegularExpressionValidator regNAME            ;

		public string MODULE_NAME
		{
			get
			{
				return sMODULE_NAME;
			}
			set
			{
				sMODULE_NAME = value;
				// 01/06/2008 Paul.  HeaderLeft replaced the header to this control.
				// 05/17/2010 Paul.  Change to ListHeader now that NewRecord has been moved below the ListView. 
				ctlListHeader.Title = L10n.Term("EditCustomFields.LBL_ADD_FIELD") + " " + L10n.Term(".moduleList." + sMODULE_NAME);
				// 02/13/2007 Paul.  Web1.4 is having a problem displaying this control.  
				if ( !Sql.IsEmptyString(sMODULE_NAME) )
					divNewRecord.Visible = true;
			}
		}

		public void Clear()
		{
			txtNAME         .Text = String.Empty;
			txtLABEL        .Text = String.Empty;
			txtMAX_SIZE     .Text = String.Empty;
			txtDEFAULT_VALUE.Text = String.Empty;
			lstDATA_TYPE.SelectedIndex = 0;
			chkREQUIRED.Checked = false;
			chkAUDITED .Checked = false;
			trDROPDOWN_LIST.Visible = false;
			// 02/02/2021 Paul.  Move preview to separate row. 
			trDROPDOWN_LIST_PREVIEW.Visible = false;
			trMAX_SIZE.Visible = true;
			
			// 03/18/2010 Paul.  We are having trouble hiding the NewRecord control. 
			// Updating the Visible flag here solves the problem. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
		}

		// 10/31/2021 Paul.  Move RecompileViews to ModuleUtils. 

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "NewRecord" )
			{
				txtNAME .Text = txtNAME .Text.Trim();
				txtLABEL.Text = txtLABEL.Text.Trim();

				if ( Sql.IsEmptyString(txtLABEL.Text) )
					txtLABEL.Text = txtNAME.Text;
				Regex r = new Regex(@"[^\w]+");
				txtNAME .Text = r.Replace(txtNAME .Text, "_");

				// 01/11/2006 Paul.  The label does not need to be validated because it will become the term display name. 
				reqNAME .Enabled = true;
				regNAME .Enabled = true;
				reqNAME .Validate();
				regNAME .Validate();
				if ( Page.IsValid )
				{
					Guid gID = Guid.Empty;
					try
					{
						// 01/11/2006 Paul.  The label needs to be stored in the TERMINOLOGY table. 
						// 05/20/2007 Paul.  The Label term is no longer used.  The label term must be derived from the field name 
						// in order for the reporting area to work properly.  The reporting area assumes that the label is the of the format "LBL_" + Name + "_C". 
						string sLABEL_TERM = String.Empty;  // r.Replace(txtLABEL.Text, "_");
						// 04/24/2006 Paul.  Upgrade to SugarCRM 4.2 Schema. 
						// 04/24/2006 Paul.  We don't support MassUpdate at this time. 

						// 07/18/2006 Paul.  Manually create the command so that we can increase the timeout. 
						// 07/18/2006 Paul.  Keep the original procedure call so that we will get a compiler error if something changes. 
						bool bIncreaseTimeout = true;
						if ( !bIncreaseTimeout )
						{
							// 03/11/2016 Paul.  Allow disable recompile so that we can do in the background. 
							SqlProcs.spFIELDS_META_DATA_Insert(ref gID, txtNAME.Text, txtLABEL.Text, sLABEL_TERM, sMODULE_NAME, lstDATA_TYPE.SelectedValue, Sql.ToInteger(txtMAX_SIZE.Text), chkREQUIRED.Checked, chkAUDITED.Checked, txtDEFAULT_VALUE.Text, lstDROPDOWN_LIST.SelectedValue, false, true);
						}
						else
						{
							string sNAME            = txtNAME.Text                   ;
							string sLABEL           = txtLABEL.Text                  ;
							string sCUSTOM_MODULE   = sMODULE_NAME                   ;
							string sDATA_TYPE       = lstDATA_TYPE.SelectedValue     ;
							Int32 nMAX_SIZE         = Sql.ToInteger(txtMAX_SIZE.Text);
							bool bREQUIRED          = chkREQUIRED.Checked            ;
							bool bAUDITED           = chkAUDITED.Checked             ;
							string sDEFAULT_VALUE   = txtDEFAULT_VALUE.Text          ;
							string sDROPDOWN_LIST   = lstDROPDOWN_LIST.SelectedValue ;
							bool bMASS_UPDATE       = false                          ;
							DbProviderFactory dbf = DbProviderFactories.GetFactory();
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
								using ( IDbTransaction trn = Sql.BeginTransaction(con) )
								{
									try
									{
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											cmd.Transaction = trn;
											cmd.CommandType = CommandType.StoredProcedure;
											cmd.CommandText = "spFIELDS_META_DATA_Insert";
											// 07/18/2006 Paul.  Tripple the default timeout.  The operation was timing-out on QA machines and on the demo server. 
											// 02/03/2007 Paul.  Increase timeout to 5 minutes.  It should not take that long, but some users are reporting a timeout. 
											// 07/01/2008 Paul.  Let the function run forever. 
											// 03/11/2016 Paul.  Allow disable recompile so that we can do in the background. 
											cmd.CommandTimeout = 0;
											IDbDataParameter parID               = Sql.AddParameter(cmd, "@ID"              , gID                );
											IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID",  Security.USER_ID  );
											IDbDataParameter parNAME             = Sql.AddParameter(cmd, "@NAME"            , sNAME              , 255);
											IDbDataParameter parLABEL            = Sql.AddParameter(cmd, "@LABEL"           , sLABEL             , 255);
											IDbDataParameter parLABEL_TERM       = Sql.AddParameter(cmd, "@LABEL_TERM"      , sLABEL_TERM        , 255);
											IDbDataParameter parCUSTOM_MODULE    = Sql.AddParameter(cmd, "@CUSTOM_MODULE"   , sCUSTOM_MODULE     , 255);
											IDbDataParameter parDATA_TYPE        = Sql.AddParameter(cmd, "@DATA_TYPE"       , sDATA_TYPE         , 255);
											IDbDataParameter parMAX_SIZE         = Sql.AddParameter(cmd, "@MAX_SIZE"        , nMAX_SIZE          );
											IDbDataParameter parREQUIRED         = Sql.AddParameter(cmd, "@REQUIRED"        , bREQUIRED          );
											IDbDataParameter parAUDITED          = Sql.AddParameter(cmd, "@AUDITED"         , bAUDITED           );
											IDbDataParameter parDEFAULT_VALUE    = Sql.AddParameter(cmd, "@DEFAULT_VALUE"   , sDEFAULT_VALUE     , 255);
											IDbDataParameter parDROPDOWN_LIST    = Sql.AddParameter(cmd, "@DROPDOWN_LIST"   , sDROPDOWN_LIST     ,  50);
											IDbDataParameter parMASS_UPDATE      = Sql.AddParameter(cmd, "@MASS_UPDATE"     , bMASS_UPDATE       );
											IDbDataParameter parDISABLE_RECOMPILE= Sql.AddParameter(cmd, "@DISABLE_RECOMPILE", true              );
											parID.Direction = ParameterDirection.InputOutput;
											cmd.ExecuteNonQuery();
											gID = Sql.ToGuid(parID.Value);
										}
										trn.Commit();
									}
									catch(Exception ex)
									{
										trn.Rollback();
										throw(new Exception(ex.Message, ex.InnerException));
									}
								}
							}
							// 12/12/2009 Paul.  Only update the semantic model if this is the Enterprise or Professional edition. 
							// 11/06/2015 Paul.  Add support for the Ultimate edition. 
							//string sServiceLevel = Sql.ToString(Application["CONFIG.service_level"]).ToLower();
							//if ( sServiceLevel == "enterprise" || sServiceLevel == "professional" || sServiceLevel == "ultimate" )
							//{
							//	// 12/12/2009 Paul.  Update the Semantic Model in a background thread. 
							//	System.Threading.Thread t = new System.Threading.Thread(Utils.UpdateSemanticModel);
							//	t.Start(this.Context);
							//}
							// 03/11/2016 Paul.  Recompile in the background, then update the Semantic Model. 
							if ( Application["System.Recompile.Start"] == null )
							{
								// 10/31/2021 Paul.  Moved RecompileViews to ModuleUtils. 
								System.Threading.Thread t = new System.Threading.Thread(ModuleUtils.EditCustomFields.RecompileViews);
								t.Start(this.Context);
							}
							else
							{
								Application["System.Recompile.Restart"] = true;
							}
						}
						// 01/11/2006 Paul.  Add term to the local cache.  Always default to english. 
						//Application["en-US." + sMODULE_NAME + "." + sLABEL_TERM] = txtLABEL.Text;
						// 04/05/2006 Paul.  A _C is appended to the term in the procedure.  Do so here as well. 
						// 05/20/2007 Paul.  The label is also prepended with LBL_.  This is a requirement for the reporting system. 
						// 05/20/2007 Paul.  The Label term is no longer used.  The label term must be derived from the field name 
						// in order for the reporting area to work properly.  The reporting area assumes that the label is the of the format "LBL_" + Name + "_C". 
						L10N.SetTerm("en-US", sMODULE_NAME, "LBL_" + txtNAME.Text.ToUpper() + "_C", txtLABEL.Text);
						// 01/10/2006 Paul.  Clear the cache. 
						//SplendidCache.ClearFieldsMetaData(sMODULE_NAME);
						// 06/03/2008 Paul.  We need to reload the entire application cache as there are many possible cached items. 
						// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
						SplendidInit.InitApp(HttpContext.Current);
						Clear();
						if ( Command != null )
							Command(this, e) ;
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
					}
				}
			}
		}
		
		protected void lstDATA_TYPE_Changed(Object sender, EventArgs e)
		{
			trDROPDOWN_LIST.Visible = (lstDATA_TYPE.SelectedValue == "enum");
			// 02/02/2021 Paul.  Move preview to separate row. 
			trDROPDOWN_LIST_PREVIEW.Visible = (lstDATA_TYPE.SelectedValue == "enum");
			trMAX_SIZE.Visible = (lstDATA_TYPE.SelectedValue == "varchar");
			lstDROPDOWN_LIST_Changed(null, null);
		}

		protected void lstDROPDOWN_LIST_Changed(Object sender, EventArgs e)
		{
			try
			{
				if ( trDROPDOWN_LIST.Visible )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL;
						sSQL = "select NAME                         " + ControlChars.CrLf
						     + "     , DISPLAY_NAME                 " + ControlChars.CrLf
						     + "  from vwTERMINOLOGY                " + ControlChars.CrLf
						     + " where lower(LIST_NAME) = @LIST_NAME" + ControlChars.CrLf
						     + "   and lower(LANG     ) = @LANG     " + ControlChars.CrLf
						     + " order by LIST_ORDER                " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							// 03/06/2006 Paul.  Oracle is case sensitive, and we modify the case of L10n.NAME to be lower. 
							Sql.AddParameter(cmd, "@LIST_NAME", lstDROPDOWN_LIST.SelectedValue.ToLower());
							Sql.AddParameter(cmd, "@LANG"     , L10n.NAME.ToLower());
							
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								DataTable dt = new DataTable();
								da.Fill(dt);
								vwPICK_LIST_VALUES = dt.DefaultView;
								grdPICK_LIST_VALUES.DataSource = vwPICK_LIST_VALUES ;
								grdPICK_LIST_VALUES.DataBind();
							}
						}
					}
				}
				else
				{
					lstDROPDOWN_LIST.SelectedIndex = 0;
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
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				divNewRecord.Visible = false;
				return;
			}
			
			if ( !this.IsPostBack )
			{
				try
				{
					// 01/10/2007 Paul.  Use cached data to populate the pick list. 
					lstDROPDOWN_LIST.DataSource = SplendidCache.TerminologyPickLists();
					lstDROPDOWN_LIST.DataBind();
					lstDROPDOWN_LIST_Changed(null, null);
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblError.Text = ex.Message;
				}
			}
			// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
			//this.DataBind();  // Need to bind so that Text of the Button gets updated. 
			reqNAME .ErrorMessage = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("EditCustomFields.COLUMN_TITLE_NAME" ) + "<br>";
			regNAME .ErrorMessage = L10n.Term("EditCustomFields.LBL_INVALID_FIELD_NAME" ) + "<br>";
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
			m_sMODULE = "EditCustomFields";
		}
		#endregion
	}
}


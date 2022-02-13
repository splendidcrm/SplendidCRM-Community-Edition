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
using System.IO;
using System.Xml;
using System.Text;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Workflow.Activities.Rules;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Diagnostics;
// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
using CKEditor.NET;

namespace SplendidCRM
{
// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
	// 03/11/2014 Paul.  Provide a way to control the dynamic buttons. 
	public class SafeDynamicButtons
	{
		// 03/27/2016 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlDynamicButtons;
		protected SplendidControl ctlPARENT ;
		protected DataRow         rowCurrent;

		public SafeDynamicButtons(SplendidControl ctlPARENT, DataRow row)
		{
			this.ctlPARENT  = ctlPARENT ;
			this.rowCurrent = row       ;
			// 03/27/2016 Paul.  Combine ModuleHeader and DynamicButtons. 
			this.ctlDynamicButtons = ctlPARENT.FindControl("ctlDynamicButtons") as _controls.HeaderButtons;
		}

		public SafeDynamicButtons(SplendidControl ctlPARENT, string sNAME, DataRow row)
		{
			this.ctlPARENT  = ctlPARENT ;
			this.rowCurrent = row       ;
			// 03/27/2016 Paul.  Combine ModuleHeader and DynamicButtons. 
			this.ctlDynamicButtons = ctlPARENT.FindControl(sNAME) as _controls.HeaderButtons;
		}

		public void DisableAll()
		{
			if ( this.ctlDynamicButtons != null )
				this.ctlDynamicButtons.DisableAll();
		}

		public void HideAll()
		{
			if ( this.ctlDynamicButtons != null )
				this.ctlDynamicButtons.HideAll();
		}

		public void ShowAll()
		{
			if ( this.ctlDynamicButtons != null )
				this.ctlDynamicButtons.ShowAll();
		}

		public void ShowButton(string sCommandName, bool bVisible)
		{
			if ( this.ctlDynamicButtons != null )
				this.ctlDynamicButtons.ShowButton(sCommandName, bVisible);
		}

		public void EnableButton(string sCommandName, bool bEnabled)
		{
			if ( this.ctlDynamicButtons != null )
				this.ctlDynamicButtons.EnableButton(sCommandName, bEnabled);
		}

		public void SetButtonText(string sCommandName, string sText)
		{
			if ( this.ctlDynamicButtons != null )
				this.ctlDynamicButtons.SetButtonText(sCommandName, sText);
		}

		// 03/24/2016.  Provide a way to disable HyperLinks. 
		public void ShowHyperLink(string sURL, bool bVisible)
		{
			if ( this.ctlDynamicButtons != null )
				this.ctlDynamicButtons.ShowHyperLink(sURL, bVisible);
		}

		// 03/24/2016 Paul.  We want to be able to change an order pdf per language. 
		public void ReplaceHyperLinkString(string sOldValue, string sNewValue)
		{
			if ( this.ctlDynamicButtons != null )
				this.ctlDynamicButtons.ReplaceHyperLinkString(sOldValue, sNewValue);
		}

		public bool ShowRequired
		{
			get
			{
				if ( this.ctlDynamicButtons != null )
					return this.ctlDynamicButtons.ShowRequired;
				else
					return false;
			}
			set
			{
				if ( this.ctlDynamicButtons != null )
					this.ctlDynamicButtons.ShowRequired = value;
			}
		}

		public bool ShowError
		{
			get
			{
				if ( this.ctlDynamicButtons != null )
					return this.ctlDynamicButtons.ShowError;
				else
					return false;
			}
			set
			{
				if ( this.ctlDynamicButtons != null )
					this.ctlDynamicButtons.ShowError = value;
			}
		}

		public string ErrorText
		{
			get
			{
				if ( this.ctlDynamicButtons != null )
					return this.ctlDynamicButtons.ErrorText;
				else
					return String.Empty;
			}
			set
			{
				if ( this.ctlDynamicButtons != null )
					this.ctlDynamicButtons.ErrorText = value;
			}
		}

		public string ErrorClass
		{
			get
			{
				if ( this.ctlDynamicButtons != null )
					return this.ctlDynamicButtons.ErrorClass;
				else
					return String.Empty;
			}
			set
			{
				if ( this.ctlDynamicButtons != null )
					this.ctlDynamicButtons.ErrorClass = value;
			}
		}

	}

	// 08/16/2017 Paul.  Add ability to apply a business rule to a button. 
	public class DynamicButtonThis : SqlObj
	{
		private Control ctl;
		private L10N    L10n;

		public DynamicButtonThis(Control ctl, L10N L10n)
		{
			this.ctl  = ctl;
			this.L10n = L10n;
		}

		public HttpRequest Request
		{
			get
			{
				return HttpContext.Current.Request;
			}
		}

		public bool Visible
		{
			get { return ctl.Visible; }
			set { ctl.Visible = value; }
		}

		public string ClientID
		{
			get { return ctl.ClientID; }
		}

		public bool Enabled
		{
			get
			{
				if ( ctl is Button )
					return (ctl as Button).Enabled;
				else if ( ctl is HyperLink )
					return (ctl as HyperLink).Enabled;
				return false;
			}
			set
			{
				if ( ctl is Button )
					(ctl as Button).Enabled = value;
				else if ( ctl is HyperLink )
					(ctl as HyperLink).Enabled = value;
			}
		}

		public string Text
		{
			get
			{
				if ( ctl is Button )
					return (ctl as Button).Text;
				else if ( ctl is HyperLink )
					return (ctl as HyperLink).Text;
				return String.Empty;
			}
			set
			{
				if ( ctl is Button )
					(ctl as Button).Text = value;
				else if ( ctl is HyperLink )
					(ctl as HyperLink).Text = value;
			}
		}

		public string CssClass
		{
			get
			{
				if ( ctl is Button )
					return (ctl as Button).CssClass;
				else if ( ctl is HyperLink )
					return (ctl as HyperLink).CssClass;
				return String.Empty;
			}
			set
			{
				if ( ctl is Button )
					(ctl as Button).CssClass = value;
				else if ( ctl is HyperLink )
					(ctl as HyperLink).CssClass = value;
			}
		}

		public string ListTerm(string sListName, string oField)
		{
			return Sql.ToString(L10n.Term(sListName, oField));
		}

		public string Term(string sEntryName)
		{
			return L10n.Term(sEntryName);
		}

		public bool UserIsAdmin()
		{
			return SplendidCRM.Security.IS_ADMIN;
		}

		public string UserLanguage()
		{
			return Sql.ToString (HttpContext.Current.Session["USER_SETTINGS/CULTURE"]);
		}

		public int UserModuleAccess(string sMODULE, string sACCESS_TYPE)
		{
			return SplendidCRM.Security.GetUserAccess(sMODULE, sACCESS_TYPE);
		}

		public bool UserRoleAccess(string sROLE_NAME)
		{
			return Security.GetACLRoleAccess(sROLE_NAME);
		}

		public bool UserTeamAccess(string sTEAM_NAME)
		{
			return Security.GetTeamAccess(sTEAM_NAME);
		}

		public Guid USER_ID()
		{
			return SplendidCRM.Security.USER_ID;
		}

		public string USER_NAME()
		{
			return SplendidCRM.Security.USER_NAME;
		}

		public string FULL_NAME()
		{
			return SplendidCRM.Security.FULL_NAME;
		}

		public Guid TEAM_ID()
		{
			return SplendidCRM.Security.TEAM_ID;
		}

		public string TEAM_NAME()
		{
			return SplendidCRM.Security.TEAM_NAME;
		}

	}
#endif
	// 11/10/2010 Paul.  Make sure to add the RulesValidator early in the pipeline. 
	public class RulesValidator : IValidator
	{
		protected SplendidControl Container;

		public RulesValidator(SplendidControl Container)
		{
			this.Container = Container;
		}

		// 11/10/2010 Paul.  We can return the error, but it does not get displayed because we do not have a summary control. 
		public string ErrorMessage
		{
			get { return Container.RulesErrorMessage; }
			set { Container.RulesErrorMessage = value; }
		}

		public bool IsValid
		{
			get { return Container.RulesIsValid; }
			set { Container.RulesIsValid = value; }
		}

		public void Validate()
		{
		}
	}

	public class SplendidControlThis : SqlObj
	{
		private SplendidControl Container;
		private L10N            L10n     ;
		private DataRow         Row      ;
		private DataTable       Table    ;
		private string          Module   ;
		
		public SplendidControlThis(SplendidControl Container, string sModule, DataRow Row)
		{
			this.Container = Container;
			this.Module    = sModule  ;
			this.Row       = Row      ;
			if ( Row != null )
				this.Table = Row.Table;
			this.L10n      = Container.GetL10n();
		}

		public SplendidControlThis(SplendidControl Container, string sModule, DataTable Table)
		{
			this.Container = Container;
			this.Module    = sModule  ;
			this.Table     = Table    ;
			this.L10n      = Container.GetL10n();
		}

		public object this[string columnName]
		{
			get
			{
				if ( Row != null )
					return Row[columnName];
				return null;
			}
			set
			{
				if ( Row != null )
					Row[columnName] = value;
			}
		}

		// 04/06/2016 Paul.  We want to have a way to pass information from code behind to workflow. 
		public object GetPageItem(string sItemName)
		{
			object obj = null;
			if ( Container != null && Container.Page != null && Container.Page.Items != null )
			{
				obj = Container.Page.Items[sItemName];
			}
			return obj;
		}

		// 02/15/2014 Paul.  Provide access to the Request object so that we can determine if the record is new. 
		public HttpRequest Request
		{
			get
			{
				return HttpContext.Current.Request;
			}
		}

		public void AddColumn(string columnName, string typeName)
		{
			if ( Table != null )
			{
				if ( !Table.Columns.Contains(columnName) )
				{
					if ( Sql.IsEmptyString(typeName) )
						Table.Columns.Add(columnName);
					else
						Table.Columns.Add(columnName, Type.GetType(typeName));
				}
			}
		}

		// http://msdn.microsoft.com/en-us/library/system.data.datacolumn.expression(v=VS.80).aspx
		public void AddColumnExpression(string columnName, string typeName, string sExpression)
		{
			if ( Table != null )
			{
				if ( !Table.Columns.Contains(columnName) )
				{
					Table.Columns.Add(columnName, Type.GetType(typeName), sExpression);
				}
			}
		}

// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
		public DynamicControl GetDynamicControl(string columnName)
		{
			return new DynamicControl(Container, columnName);
		}

		// 03/11/2014 Paul.  Provide a way to control the dynamic buttons. 
		public SafeDynamicButtons GetDynamicButtons()
		{
			return new SafeDynamicButtons(this.Container, this.Row);
		}

		public SafeDynamicButtons GetDynamicButtons(string sName)
		{
			return new SafeDynamicButtons(this.Container, sName, this.Row);
		}

		public string ListTerm(string sListName, string oField)
		{
			return Sql.ToString(L10n.Term(sListName, oField));
		}

		public string Term(string sEntryName)
		{
			return L10n.Term(sEntryName);
		}

		public string RedirectURL
		{
			get { return Container.RulesRedirectURL; }
			set { Container.RulesRedirectURL = value; }
		}

		public string ErrorMessage
		{
			get { return Container.RulesErrorMessage; }
			set { Container.RulesErrorMessage = value; }
		}

		public bool IsValid
		{
			get { return Container.RulesIsValid; }
			set { Container.RulesIsValid = value; }
		}

		// 11/14/2013 Paul.  A customer wants to hide a row if it matches a certain criteria. 
		public void Delete()
		{
			if ( Row != null )
			{
				Row.Delete();
			}
		}

		// 02/13/2013 Paul.  Allow the business rules to change the layout. 
		public string LayoutListView
		{
			get { return Container.LayoutListView; }
			set { Container.LayoutListView = value; }
		}

		public string LayoutEditView
		{
			get { return Container.LayoutEditView; }
			set { Container.LayoutEditView = value; }
		}

		public string LayoutDetailView
		{
			get { return Container.LayoutDetailView; }
			set { Container.LayoutDetailView = value; }
		}

		// 11/10/2010 Paul.  Throwing an exception will be the preferred method of displaying an error. 
		public void Throw(string sMessage)
		{
			throw(new Exception(sMessage));
		}

		public bool UserIsAdmin()
		{
			return SplendidCRM.Security.IS_ADMIN;
		}

		// 03/24/2016 Paul.  We want to be able to change an order pdf per language. 
		public string UserLanguage()
		{
			return Sql.ToString (HttpContext.Current.Session["USER_SETTINGS/CULTURE"]);
		}

		public int UserModuleAccess(string sACCESS_TYPE)
		{
			return SplendidCRM.Security.GetUserAccess(Module, sACCESS_TYPE);
		}

		public bool UserRoleAccess(string sROLE_NAME)
		{
			return Security.GetACLRoleAccess(sROLE_NAME);
		}

		public bool UserTeamAccess(string sTEAM_NAME)
		{
			return Security.GetTeamAccess(sTEAM_NAME);
		}

		public bool UserFieldIsReadable(string sFIELD_NAME, Guid gASSIGNED_USER_ID)
		{
			Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, sFIELD_NAME, gASSIGNED_USER_ID);
			return acl.IsReadable();
		}

		public bool UserFieldIsWriteable(string sFIELD_NAME, Guid gASSIGNED_USER_ID)
		{
			Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, sFIELD_NAME, gASSIGNED_USER_ID);
			return acl.IsWriteable();
		}

		public void LayoutShowButton(string sCommandName, bool bVisible)
		{
			_controls.DynamicButtons ctlDynamicButtons = Container.FindControl("ctlDynamicButtons") as _controls.DynamicButtons;
			_controls.DynamicButtons ctlFooterButtons  = Container.FindControl("ctlFooterButtons" ) as _controls.DynamicButtons;
			if ( ctlDynamicButtons != null )
				ctlDynamicButtons.ShowButton(sCommandName, bVisible);
			if ( ctlFooterButtons != null )
				ctlFooterButtons .ShowButton(sCommandName, bVisible);
		}

		public void LayoutEnableButton(string sCommandName, bool bEnabled)
		{
			_controls.DynamicButtons ctlDynamicButtons = Container.FindControl("ctlDynamicButtons") as _controls.DynamicButtons;
			_controls.DynamicButtons ctlFooterButtons  = Container.FindControl("ctlFooterButtons" ) as _controls.DynamicButtons;
			if ( ctlDynamicButtons != null )
				ctlDynamicButtons.EnableButton(sCommandName, bEnabled);
			if ( ctlFooterButtons != null )
				ctlFooterButtons .EnableButton(sCommandName, bEnabled);
		}

		public void LayoutShowField(string sDATA_FIELD, bool bVisible)
		{
			Control ctl = Container.FindControl(sDATA_FIELD);
			if ( ctl != null )
				ctl.Visible = bVisible;
			ctl = Container.FindControl(sDATA_FIELD + "_LABEL");
			if ( ctl != null )
				ctl.Visible = bVisible;
			ctl = Container.FindControl(sDATA_FIELD + "_PARENT_TYPE");
			if ( ctl != null )
				ctl.Visible = bVisible;
			ctl = Container.FindControl(sDATA_FIELD + "_btnChange");
			if ( ctl != null )
				ctl.Visible = bVisible;
			ctl = Container.FindControl(sDATA_FIELD + "_btnClear");
			if ( ctl != null )
				ctl.Visible = bVisible;
			ctl = Container.FindControl(sDATA_FIELD + "_TOOLTIP_IMAGE");
			if ( ctl != null )
				ctl.Visible = bVisible;
			ctl = Container.FindControl(sDATA_FIELD + "_TOOLTIP_PANEL");
			if ( ctl != null )
				ctl.Visible = bVisible;
		}

		public void LayoutEnableField(string sDATA_FIELD, bool bEnabled)
		{
			Control ctl = Container.FindControl(sDATA_FIELD);
			if ( ctl != null )
			{
				if ( ctl is TextBox )
					(ctl as TextBox).Enabled = bEnabled;
				// 11/11/2010 Paul.  The FCKeditor cannot be disabled, so just hide. 
				// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
				else if ( ctl is CKEditorControl )
					(ctl as CKEditorControl).Visible = bEnabled;
				else if ( ctl is ListControl )
					(ctl as ListControl).Enabled = bEnabled;
				else if ( ctl is CheckBox )
					(ctl as CheckBox).Enabled = bEnabled;
				else if ( ctl is HtmlInputButton )
					(ctl as HtmlInputButton).Disabled = !bEnabled;
				else if ( ctl is HtmlInputFile )
					(ctl as HtmlInputFile).Disabled = !bEnabled;
				else if ( ctl is _controls.DatePicker )
					(ctl as _controls.DatePicker).Enabled = bEnabled;
				else if ( ctl is _controls.DateTimePicker )
					(ctl as _controls.DateTimePicker).Enabled = bEnabled;
				else if ( ctl is _controls.TimePicker )
					(ctl as _controls.TimePicker).Enabled = bEnabled;
				else if ( ctl is _controls.DateTimeEdit )
					(ctl as _controls.DateTimeEdit).Enabled = bEnabled;
				else if ( ctl is _controls.TeamSelect )
					(ctl as _controls.TeamSelect).Enabled = bEnabled;
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( ctl is _controls.UserSelect )
					(ctl as _controls.UserSelect).Enabled = bEnabled;
				// 05/12/2016 Paul.  Add Tags module. 
				else if ( ctl is _controls.TagSelect )
					(ctl as _controls.TagSelect).Enabled = bEnabled;
				// 06/07/2017 Paul.  Add NAICSCodes module. 
				else if ( ctl is _controls.NAICSCodeSelect )
					(ctl as _controls.NAICSCodeSelect).Enabled = bEnabled;
				else if ( ctl is _controls.KBTagSelect )
					(ctl as _controls.KBTagSelect).Enabled = bEnabled;
			}
		}

		public void LayoutRequiredField(string sDATA_FIELD, bool bRequired)
		{
			Control req = Container.FindControl(sDATA_FIELD + "_REQUIRED");
			if ( req != null )
			{
				if ( req is RequiredFieldValidator )
					(req as RequiredFieldValidator).Enabled = bRequired;
				else if ( req is RequiredFieldValidatorForHiddenInputs )
					(req as RequiredFieldValidatorForHiddenInputs).Enabled = bRequired;
			}
			else
			{
				Control ctl = Container.FindControl(sDATA_FIELD);
				if ( ctl != null )
				{
					if ( ctl is _controls.DatePicker )
						(ctl as _controls.DatePicker).Validate(bRequired);
					else if ( ctl is _controls.DateTimePicker )
						(ctl as _controls.DateTimePicker).Validate(bRequired);
					else if ( ctl is _controls.TimePicker )
						(ctl as _controls.TimePicker).Validate(bRequired);
					else if ( ctl is _controls.DateTimeEdit )
						(ctl as _controls.DateTimeEdit).Validate(bRequired);
					else if ( ctl is _controls.TeamSelect )
						(ctl as _controls.TeamSelect).Validate(bRequired);
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( ctl is _controls.UserSelect )
						(ctl as _controls.UserSelect).Validate(bRequired);
					// 05/12/2016 Paul.  Add Tags module. 
					else if ( ctl is _controls.TagSelect )
						(ctl as _controls.TagSelect).Validate(bRequired);
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( ctl is _controls.NAICSCodeSelect )
						(ctl as _controls.NAICSCodeSelect).Validate(bRequired);
					else if ( ctl is _controls.KBTagSelect )
						(ctl as _controls.KBTagSelect).Validate(bRequired);
				}
			}
		}
#endif

		// 07/05/2012 Paul.  Provide access to the current user. 
		public Guid USER_ID()
		{
			return SplendidCRM.Security.USER_ID;
		}

		public string USER_NAME()
		{
			return SplendidCRM.Security.USER_NAME;
		}

		public string FULL_NAME()
		{
			return SplendidCRM.Security.FULL_NAME;
		}

		public Guid TEAM_ID()
		{
			return SplendidCRM.Security.TEAM_ID;
		}

		public string TEAM_NAME()
		{
			return SplendidCRM.Security.TEAM_NAME;
		}

		// 05/12/2013 Paul.  Provide a way to decrypt inside a business rule.  
		// The business rules do not have access to the config variables, so the Guid values will need to be hard-coded in the rule. 
		public string DecryptPassword(string sPASSWORD, Guid gKEY, Guid gIV)
		{
			return SplendidCRM.Security.DecryptPassword(sPASSWORD, gKEY, gIV);
		}
	}

	public class SplendidWizardThis : SqlObj
	{
		private SplendidControl Container;
		private L10N            L10n             ;
		private DataRow         Row              ;
		private string          Module           ;
		private Guid            gASSIGNED_USER_ID;
		
		// 04/27/2018 Paul.  We need to be able to generate an error message. 
		public SplendidWizardThis(SplendidControl Container, L10N L10n, string sModule, DataRow Row)
		{
			this.Container         = Container ;
			this.L10n              = L10n      ;
			this.Row               = Row       ;
			this.Module            = sModule   ;
			this.gASSIGNED_USER_ID = Guid.Empty;
			if ( Row.Table != null && Row.Table.Columns.Contains("ASSIGNED_USER_ID") )
				gASSIGNED_USER_ID = Sql.ToGuid(Row["ASSIGNED_USER_ID"]);
		}
		
		public object this[string columnName]
		{
			get
			{
				bool bIsReadable  = true;
				if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(columnName) )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, columnName, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}
				if ( bIsReadable )
					return Row[columnName];
				else
					return DBNull.Value;
			}
			set
			{
				bool bIsWriteable = true;
				if ( SplendidInit.bEnableACLFieldSecurity )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, columnName, gASSIGNED_USER_ID);
					bIsWriteable = acl.IsWriteable();
				}
				if ( bIsWriteable )
					Row[columnName] = value;
			}
		}

		public string ListTerm(string sListName, string oField)
		{
			return Sql.ToString(L10n.Term(sListName, oField));
		}

		public string Term(string sEntryName)
		{
			return L10n.Term(sEntryName);
		}

		// 07/05/2012 Paul.  Provide access to the current user. 
		public Guid USER_ID()
		{
			return SplendidCRM.Security.USER_ID;
		}

		public string USER_NAME()
		{
			return SplendidCRM.Security.USER_NAME;
		}

		public string FULL_NAME()
		{
			return SplendidCRM.Security.FULL_NAME;
		}

		public Guid TEAM_ID()
		{
			return SplendidCRM.Security.TEAM_ID;
		}

		public string TEAM_NAME()
		{
			return SplendidCRM.Security.TEAM_NAME;
		}

		// 04/27/2018 Paul.  We need to be able to generate an error message. 
		public string ErrorMessage
		{
			get { return Container.RulesErrorMessage; }
			set { Container.RulesErrorMessage = value; }
		}
	}

	// 09/17/2013 Paul.  Add Business Rules to import. 
	public class SplendidImportThis : SqlObj
	{
		private SplendidControl Container;
		private L10N            L10n             ;
		private DataRow         Row              ;
		private IDbCommand      Import           ;
		private IDbCommand      ImportCSTM       ;
		private string          Module           ;
		private Guid            gASSIGNED_USER_ID;
		
		// 04/27/2018 Paul.  We need to be able to generate an error message. 
		public SplendidImportThis(SplendidControl Container, L10N L10n, string sModule, DataRow Row, IDbCommand cmdImport, IDbCommand cmdImportCSTM)
		{
			this.Container         = Container    ;
			this.L10n              = L10n         ;
			this.Row               = Row          ;
			this.Import            = cmdImport    ;
			this.ImportCSTM        = cmdImportCSTM;
			this.Module            = sModule      ;
			this.gASSIGNED_USER_ID = Guid.Empty   ;
			
			IDbDataParameter par = Sql.FindParameter(cmdImport, "ASSIGNED_USER_ID");
			if ( par != null )
				gASSIGNED_USER_ID = Sql.ToGuid(par.Value);
		}
		
		public object this[string columnName]
		{
			get
			{
				bool bIsReadable  = true;
				if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(columnName) )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, columnName, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}
				if ( bIsReadable )
				{
					IDbDataParameter par = Sql.FindParameter(Import, columnName);
					if ( par != null )
					{
						return par.Value;
					}
					else if ( ImportCSTM != null )
					{
						par = Sql.FindParameter(ImportCSTM, columnName);
						if ( par != null )
							return par.Value;
					}
				}
				return DBNull.Value;
			}
			set
			{
				bool bIsWriteable = true;
				if ( SplendidInit.bEnableACLFieldSecurity )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, columnName, gASSIGNED_USER_ID);
					bIsWriteable = acl.IsWriteable();
				}
				if ( bIsWriteable )
				{
					IDbDataParameter par = Sql.FindParameter(Import, columnName);
					if ( par != null )
					{
						Sql.SetParameter(par, value);
					}
					if ( ImportCSTM != null )
					{
						// 09/17/2013 Paul.  If setting the ID, then also set the related custom field ID. 
						if ( String.Compare(columnName, "ID", true) == 0 )
							columnName = "ID_C";
						par = Sql.FindParameter(ImportCSTM, columnName);
						if ( par != null )
							Sql.SetParameter(par, value);
					}
					// 09/17/2013 Paul.  The Row is displayed in the Results tab while the parameters are used to update the database. 
					Row[columnName] = value;
				}
			}
		}

		public string ListTerm(string sListName, string oField)
		{
			return Sql.ToString(L10n.Term(sListName, oField));
		}

		public string Term(string sEntryName)
		{
			return L10n.Term(sEntryName);
		}

		// 07/05/2012 Paul.  Provide access to the current user. 
		public Guid USER_ID()
		{
			return SplendidCRM.Security.USER_ID;
		}

		public string USER_NAME()
		{
			return SplendidCRM.Security.USER_NAME;
		}

		public string FULL_NAME()
		{
			return SplendidCRM.Security.FULL_NAME;
		}

		public Guid TEAM_ID()
		{
			return SplendidCRM.Security.TEAM_ID;
		}

		public string TEAM_NAME()
		{
			return SplendidCRM.Security.TEAM_NAME;
		}

		// 04/27/2018 Paul.  We need to be able to generate an error message. 
		public string ErrorMessage
		{
			get { return Container.RulesErrorMessage; }
			set { Container.RulesErrorMessage = value; }
		}
	}

	public class SplendidReportThis : SqlObj
	{
		private HttpApplicationState Application ;
		private L10N            L10n             ;
		private DataRow         Row              ;
		private DataTable       Table            ;
		private string          Module           ;
		private Guid            gASSIGNED_USER_ID;
		
		public SplendidReportThis(HttpApplicationState Application, L10N L10n, string sModule, DataRow Row)
		{
			this.Application       = Application;
			this.L10n              = L10n       ;
			this.Module            = sModule    ;
			this.Row               = Row        ;
			this.gASSIGNED_USER_ID = Guid.Empty ;
			if ( Row != null )
			{
				this.Table = Row.Table;
				if ( Table != null && Table.Columns.Contains("ASSIGNED_USER_ID") )
					gASSIGNED_USER_ID = Sql.ToGuid(Row["ASSIGNED_USER_ID"]);
			}
		}

		public SplendidReportThis(HttpApplicationState Application, L10N L10n, string sModule, DataTable Table)
		{
			this.Application       = Application;
			this.L10n              = L10n       ;
			this.Module            = sModule    ;
			this.Table             = Table      ;
			this.gASSIGNED_USER_ID = Guid.Empty ;
		}

		public object this[string columnName]
		{
			get
			{
				bool bIsReadable  = true;
				if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(columnName) )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, columnName, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}
				if ( bIsReadable )
					return Row[columnName];
				else
					return DBNull.Value;
			}
			set
			{
				bool bIsWriteable = true;
				if ( SplendidInit.bEnableACLFieldSecurity )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, columnName, gASSIGNED_USER_ID);
					bIsWriteable = acl.IsWriteable();
				}
				if ( bIsWriteable )
					Row[columnName] = value;
			}
		}

		public void AddColumn(string columnName, string typeName)
		{
			if ( Table != null )
			{
				if ( !Table.Columns.Contains(columnName) )
				{
					if ( Sql.IsEmptyString(typeName) )
						Table.Columns.Add(columnName);
					else
						Table.Columns.Add(columnName, Type.GetType(typeName));
				}
			}
		}

		// http://msdn.microsoft.com/en-us/library/system.data.datacolumn.expression(v=VS.80).aspx
		public void AddColumnExpression(string columnName, string typeName, string sExpression)
		{
			if ( Table != null )
			{
				if ( !Table.Columns.Contains(columnName) )
				{
					Table.Columns.Add(columnName, Type.GetType(typeName), sExpression);
				}
			}
		}

		public string ListTerm(string sListName, string oField)
		{
			// 12/04/2010 Paul.  We need to use the static version of Term as a report can get rendered inside a workflow, which has issues accessing the context. 
			//return Sql.ToString(L10n.Term(sListName, oField));
			return Sql.ToString(L10N.Term(Application, L10n.NAME, sListName, oField));
		}

		public string Term(string sEntryName)
		{
			// 12/04/2010 Paul.  We need to use the static version of Term as a report can get rendered inside a workflow, which has issues accessing the context. 
			//return L10n.Term(sEntryName);
			return L10N.Term(Application, L10n.NAME, sEntryName);
		}

		// 11/10/2010 Paul.  Throwing an exception will be the preferred method of displaying an error. 
		public void Throw(string sMessage)
		{
			throw(new Exception(sMessage));
		}

		public bool UserIsAdmin()
		{
			return SplendidCRM.Security.IS_ADMIN;
		}

		public int UserModuleAccess(string sACCESS_TYPE)
		{
			return SplendidCRM.Security.GetUserAccess(Module, sACCESS_TYPE);
		}

		public bool UserRoleAccess(string sROLE_NAME)
		{
			return Security.GetACLRoleAccess(sROLE_NAME);
		}

		public bool UserTeamAccess(string sTEAM_NAME)
		{
			return Security.GetTeamAccess(sTEAM_NAME);
		}

		public bool UserFieldIsReadable(string sFIELD_NAME, Guid gASSIGNED_USER_ID)
		{
			Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, sFIELD_NAME, gASSIGNED_USER_ID);
			return acl.IsReadable();
		}

		public bool UserFieldIsWriteable(string sFIELD_NAME, Guid gASSIGNED_USER_ID)
		{
			Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(Module, sFIELD_NAME, gASSIGNED_USER_ID);
			return acl.IsWriteable();
		}

		// 07/05/2012 Paul.  Provide access to the current user. 
		public Guid USER_ID()
		{
			return SplendidCRM.Security.USER_ID;
		}

		public string USER_NAME()
		{
			return SplendidCRM.Security.USER_NAME;
		}

		public string FULL_NAME()
		{
			return SplendidCRM.Security.FULL_NAME;
		}

		public Guid TEAM_ID()
		{
			return SplendidCRM.Security.TEAM_ID;
		}

		public string TEAM_NAME()
		{
			return SplendidCRM.Security.TEAM_NAME;
		}
	}

	// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
	// http://www.codeproject.com/Articles/12675/How-to-reuse-the-Windows-Workflow-Foundation-WF-co
	// 09/16/2013 Paul.  ITypeProvider is obsolete in .NET 4.5, but we have not found the alternative. 
#pragma warning disable 618
	public class SplendidRulesTypeProvider : System.Workflow.ComponentModel.Compiler.ITypeProvider
	{
		public event EventHandler TypeLoadErrorsChanged;
		public event EventHandler TypesChanged         ;
		private Dictionary<string, Type> availableTypes;
		private Dictionary<object, Exception> typeErrors;
		private List<System.Reflection.Assembly> availableAssemblies;

		public SplendidRulesTypeProvider()
		{
			typeErrors     = new Dictionary<object, Exception>();
			availableAssemblies = new List<System.Reflection.Assembly>();
			availableAssemblies.Add(this.GetType().Assembly);
			
			availableTypes = new Dictionary<string, Type>();
			availableTypes.Add(typeof(System.Boolean ).FullName, typeof(System.Boolean ));
			availableTypes.Add(typeof(System.Byte    ).FullName, typeof(System.Byte    ));
			availableTypes.Add(typeof(System.Char    ).FullName, typeof(System.Char    ));
			availableTypes.Add(typeof(System.DateTime).FullName, typeof(System.DateTime));
			availableTypes.Add(typeof(System.Decimal ).FullName, typeof(System.Decimal ));
			availableTypes.Add(typeof(System.Double  ).FullName, typeof(System.Double  ));
			availableTypes.Add(typeof(System.Guid    ).FullName, typeof(System.Guid    ));
			availableTypes.Add(typeof(System.Int16   ).FullName, typeof(System.Int16   ));
			availableTypes.Add(typeof(System.Int32   ).FullName, typeof(System.Int32   ));
			availableTypes.Add(typeof(System.Int64   ).FullName, typeof(System.Int64   ));
			availableTypes.Add(typeof(System.SByte   ).FullName, typeof(System.SByte   ));
			availableTypes.Add(typeof(System.Single  ).FullName, typeof(System.Single  ));
			availableTypes.Add(typeof(System.String  ).FullName, typeof(System.String  ));
			availableTypes.Add(typeof(System.TimeSpan).FullName, typeof(System.TimeSpan));
			availableTypes.Add(typeof(System.UInt16  ).FullName, typeof(System.UInt16  ));
			availableTypes.Add(typeof(System.UInt32  ).FullName, typeof(System.UInt32  ));
			availableTypes.Add(typeof(System.UInt64  ).FullName, typeof(System.UInt64  ));
			availableTypes.Add(typeof(System.DBNull  ).FullName, typeof(System.DBNull  ));
// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
			// 03/11/2014 Paul.  Provide a way to control the dynamic buttons. 
			availableTypes.Add(typeof(SafeDynamicButtons).FullName, typeof(SafeDynamicButtons));
#endif
			// 12/12/2012 Paul.  Use TypesChanged to avoid a compiler warning; 
			if ( TypesChanged != null )
				TypesChanged(this, null);
		}

		public Type GetType(string name, bool throwOnError)
		{
			if ( String.IsNullOrEmpty(name) )
			{
				return null;
			}

			if ( availableTypes.ContainsKey(name) )
			{
				Type type = availableTypes[name];
				return type;
			}
			else
			{
				if ( !typeErrors.ContainsKey(name) )
				{
					typeErrors.Add(name, new Exception("SplendidRulesTypeProvider: " + name + " is not a supported data type. "));
				}
				if ( throwOnError )
				{
					throw new TypeLoadException();
				}
				else
				{
					if ( TypeLoadErrorsChanged != null )
					{
						try
						{
							EventArgs args = new EventArgs();
							TypeLoadErrorsChanged(this, args);
						}
						catch
						{
						}
					}
					return null;
				}
			}
		}

		public Type GetType(string name)
		{
			return GetType(name, false);
		}

		public Type[] GetTypes() 
		{
			Type[] result = new Type[availableTypes.Count];
			availableTypes.Values.CopyTo(result, 0);
			return result;
		}

		public System.Reflection.Assembly LocalAssembly
		{
			get { return this.GetType().Assembly; }
		}

		public IDictionary<object, Exception> TypeLoadErrors
		{
			get { return typeErrors; }
		}

		public ICollection<System.Reflection.Assembly> ReferencedAssemblies
		{
			get { return availableAssemblies; }
		}
	}
#pragma warning restore 618

	/// <summary>
	/// Summary description for RulesUtil.
	/// </summary>
	public class RulesUtil
	{
		public static RuleSet Deserialize(string sXOML)
		{
			RuleSet rules = null;
			using ( StringReader stm = new StringReader(sXOML) )
			{
				using ( XmlTextReader xrdr = new XmlTextReader(stm) )
				{
					WorkflowMarkupSerializer serializer = new WorkflowMarkupSerializer();
					rules = (RuleSet) serializer.Deserialize(xrdr);
				}
			}
			return rules;
		}

		public static string Serialize(RuleSet rules)
		{
			StringBuilder sbXOML = new StringBuilder();
			using ( StringWriter wtr = new StringWriter(sbXOML, System.Globalization.CultureInfo.InvariantCulture) )
			{
				using ( XmlTextWriter xwtr = new XmlTextWriter(wtr) )
				{
					WorkflowMarkupSerializer serializer = new WorkflowMarkupSerializer();
					serializer.Serialize(xwtr, rules);
				}
			}
			return sbXOML.ToString();
		}

		// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
		public static void RulesValidate(Guid gID, string sRULE_NAME, int nPRIORITY, string sREEVALUATION, bool bACTIVE, string sCONDITION, string sTHEN_ACTIONS, string sELSE_ACTIONS, Type thisType, SplendidRulesTypeProvider typeProvider)
		{
			RuleSet        rules      = new RuleSet("RuleSet 1");
			RuleValidation validation = new RuleValidation(thisType, typeProvider);
			RulesParser    parser     = new RulesParser(validation);
			RuleExpressionCondition condition      = parser.ParseCondition    (sCONDITION   );
			List<RuleAction>        lstThenActions = parser.ParseStatementList(sTHEN_ACTIONS);
			List<RuleAction>        lstElseActions = parser.ParseStatementList(sELSE_ACTIONS);

			System.Workflow.Activities.Rules.Rule r = new System.Workflow.Activities.Rules.Rule(sRULE_NAME, condition, lstThenActions, lstElseActions);
			r.Priority = nPRIORITY;
			r.Active   = bACTIVE  ;
			//r.ReevaluationBehavior = (RuleReevaluationBehavior) Enum.Parse(typeof(RuleReevaluationBehavior), sREEVALUATION);
			// 12/04/2010 Paul.  Play it safe and never-reevaluate. 
			r.ReevaluationBehavior = RuleReevaluationBehavior.Never;
			rules.Rules.Add(r);
			rules.Validate(validation);
			if ( validation.Errors.HasErrors )
			{
				throw(new Exception(GetValidationErrors(validation)));
			}
		}

		public static string GetValidationErrors(RuleValidation validation)
		{
			StringBuilder sbErrors = new StringBuilder();
			foreach ( ValidationError err in validation.Errors )
			{
				sbErrors.AppendLine(err.ErrorText);
			}
			return sbErrors.ToString();
		}

		public static RuleSet BuildRuleSet(DataTable dtRules, RuleValidation validation)
		{
			RuleSet        rules = new RuleSet("RuleSet 1");
			RulesParser    parser = new RulesParser(validation);

			DataView vwRules = new DataView(dtRules);
			vwRules.RowFilter = "ACTIVE = 1";
			vwRules.Sort      = "PRIORITY asc";
			foreach ( DataRowView row in vwRules )
			{
				string sRULE_NAME    = Sql.ToString (row["RULE_NAME"   ]);
				int    nPRIORITY     = Sql.ToInteger(row["PRIORITY"    ]);
				string sREEVALUATION = Sql.ToString (row["REEVALUATION"]);
				bool   bACTIVE       = Sql.ToBoolean(row["ACTIVE"      ]);
				string sCONDITION    = Sql.ToString (row["CONDITION"   ]);
				string sTHEN_ACTIONS = Sql.ToString (row["THEN_ACTIONS"]);
				string sELSE_ACTIONS = Sql.ToString (row["ELSE_ACTIONS"]);
				
				RuleExpressionCondition condition      = parser.ParseCondition    (sCONDITION   );
				List<RuleAction>        lstThenActions = parser.ParseStatementList(sTHEN_ACTIONS);
				List<RuleAction>        lstElseActions = parser.ParseStatementList(sELSE_ACTIONS);
				System.Workflow.Activities.Rules.Rule r = new System.Workflow.Activities.Rules.Rule(sRULE_NAME, condition, lstThenActions, lstElseActions);
				r.Priority = nPRIORITY;
				r.Active   = bACTIVE  ;
				//r.ReevaluationBehavior = (RuleReevaluationBehavior) Enum.Parse(typeof(RuleReevaluationBehavior), sREEVALUATION);
				// 12/04/2010 Paul.  Play it safe and never-reevaluate. 
				r.ReevaluationBehavior = RuleReevaluationBehavior.Never;
				rules.Rules.Add(r);
			}
			rules.Validate(validation);
			if ( validation.Errors.HasErrors )
			{
				throw(new Exception(RulesUtil.GetValidationErrors(validation)));
			}
			return rules;
		}

		// 08/16/2017 Paul.  Single action business rule. 
		public static RuleSet BuildRuleSet(string sTHEN_ACTIONS, RuleValidation validation)
		{
			RuleSet        rules = new RuleSet("RuleSet 1");
			RulesParser    parser = new RulesParser(validation);
			
			string sRULE_NAME    = "Rule 1";
			string sCONDITION    = "true";
			string sELSE_ACTIONS = String.Empty;
			
			RuleExpressionCondition condition      = parser.ParseCondition    (sCONDITION   );
			List<RuleAction>        lstThenActions = parser.ParseStatementList(sTHEN_ACTIONS);
			List<RuleAction>        lstElseActions = parser.ParseStatementList(sELSE_ACTIONS);
			System.Workflow.Activities.Rules.Rule r = new System.Workflow.Activities.Rules.Rule(sRULE_NAME, condition, lstThenActions, lstElseActions);
			r.Priority = 1;
			r.Active   = true;
			r.ReevaluationBehavior = RuleReevaluationBehavior.Never;
			rules.Rules.Add(r);
			
			rules.Validate(validation);
			if ( validation.Errors.HasErrors )
			{
				throw(new Exception(RulesUtil.GetValidationErrors(validation)));
			}
			return rules;
		}

		// 06/02/2021 Paul.  React client needs to share code. 
		public static DataTable BuildRuleDataTable(Dictionary<string, object> dictRulesXml)
		{
			DataTable dtRules = new DataTable();
			DataColumn colID           = new DataColumn("ID"          , typeof(System.Guid   ));
			DataColumn colRULE_NAME    = new DataColumn("RULE_NAME"   , typeof(System.String ));
			DataColumn colPRIORITY     = new DataColumn("PRIORITY"    , typeof(System.Int32  ));
			DataColumn colREEVALUATION = new DataColumn("REEVALUATION", typeof(System.String ));
			DataColumn colACTIVE       = new DataColumn("ACTIVE"      , typeof(System.Boolean));
			DataColumn colCONDITION    = new DataColumn("CONDITION"   , typeof(System.String ));
			DataColumn colTHEN_ACTIONS = new DataColumn("THEN_ACTIONS", typeof(System.String ));
			DataColumn colELSE_ACTIONS = new DataColumn("ELSE_ACTIONS", typeof(System.String ));
			dtRules.Columns.Add(colID          );
			dtRules.Columns.Add(colRULE_NAME   );
			dtRules.Columns.Add(colPRIORITY    );
			dtRules.Columns.Add(colREEVALUATION);
			dtRules.Columns.Add(colACTIVE      );
			dtRules.Columns.Add(colCONDITION   );
			dtRules.Columns.Add(colTHEN_ACTIONS);
			dtRules.Columns.Add(colELSE_ACTIONS);
			if ( dictRulesXml != null )
			{
				if ( dictRulesXml.ContainsKey("NewDataSet") )
				{
					Dictionary<string, object> dictNewDataSet = dictRulesXml["NewDataSet"] as Dictionary<string, object>;
					if ( dictNewDataSet != null )
					{
						if ( dictNewDataSet.ContainsKey("Table1") )
						{
							System.Collections.ArrayList lstTable1 = dictNewDataSet["Table1"] as System.Collections.ArrayList;
							if ( lstTable1 != null )
							{
								foreach ( Dictionary<string, object> dictRule in lstTable1 )
								{
									DataRow row = dtRules.NewRow();
									dtRules.Rows.Add(row);
									row["ID"          ] = (dictRule.ContainsKey("ID"          ) ? Sql.ToString(dictRule["ID"          ]) : String.Empty);
									row["RULE_NAME"   ] = (dictRule.ContainsKey("RULE_NAME"   ) ? Sql.ToString(dictRule["RULE_NAME"   ]) : String.Empty);
									row["PRIORITY"    ] = (dictRule.ContainsKey("PRIORITY"    ) ? Sql.ToString(dictRule["PRIORITY"    ]) : String.Empty);
									row["REEVALUATION"] = (dictRule.ContainsKey("REEVALUATION") ? Sql.ToString(dictRule["REEVALUATION"]) : String.Empty);
									row["ACTIVE"      ] = (dictRule.ContainsKey("ACTIVE"      ) ? Sql.ToString(dictRule["ACTIVE"      ]) : String.Empty);
									row["CONDITION"   ] = (dictRule.ContainsKey("CONDITION"   ) ? Sql.ToString(dictRule["CONDITION"   ]) : String.Empty);
									row["THEN_ACTIONS"] = (dictRule.ContainsKey("THEN_ACTIONS") ? Sql.ToString(dictRule["THEN_ACTIONS"]) : String.Empty);
									row["ELSE_ACTIONS"] = (dictRule.ContainsKey("ELSE_ACTIONS") ? Sql.ToString(dictRule["ELSE_ACTIONS"]) : String.Empty);
								}
							}
						}
					}
				}
			}
			return dtRules;
		}
	}
}


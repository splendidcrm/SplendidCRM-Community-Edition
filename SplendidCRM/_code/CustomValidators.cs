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
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using SplendidCRM._controls;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for CustomValidators.
	/// </summary>
	public class RequiredFieldValidatorForCheckBoxLists : System.Web.UI.WebControls.BaseValidator 
	{
		private ListControl lst;

		public RequiredFieldValidatorForCheckBoxLists()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			Control ctl = FindControl(ControlToValidate);

			if ( ctl != null )
			{
				lst = (ListControl) ctl;
				return (lst != null) ;
			}
			else 
				return false;  // raise exception
		}

		protected override bool EvaluateIsValid()
		{
			return lst.SelectedIndex != -1;
		}
	}

	public class RequiredFieldValidatorForDropDownList : System.Web.UI.WebControls.BaseValidator 
	{
		private DropDownList lst;

		public RequiredFieldValidatorForDropDownList()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			Control ctl = FindControl(ControlToValidate);

			if ( ctl != null )
			{
				// 03/24/2018 Paul.  Change the type of the cast so that ListBox will be allowed. 
				lst = ctl as DropDownList;
				return (lst != null) ;
			}
			else 
				return false;  // raise exception
		}

		protected override bool EvaluateIsValid()
		{
			// 03/14/2006 Paul.  Use SelectedValue to determine if the dropdown is valid. 
			// Using a dropdown validator is not required because we only use the -- None -- first item when not required. 
			return !Sql.IsEmptyString(lst.SelectedValue);
		}
	}

	public class RequiredFieldValidatorForHiddenInputs : System.Web.UI.WebControls.BaseValidator 
	{
		// 12/03/2007 Paul.  The hidden field could be HtmlInputHidden or HiddenField. 
		private Control hid;

		public RequiredFieldValidatorForHiddenInputs()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			Control ctl = FindControl(ControlToValidate);
			if ( ctl != null )
			{
				hid = ctl;
				return (hid.GetType() == typeof(System.Web.UI.HtmlControls.HtmlInputHidden) || hid.GetType() == typeof(System.Web.UI.WebControls.HiddenField)) ;
			}
			else 
				return false;  // raise exception
		}

		protected override bool EvaluateIsValid()
		{
			if ( hid.GetType() == typeof(System.Web.UI.HtmlControls.HtmlInputHidden) )
				return !Sql.IsEmptyString((hid as HtmlInputHidden).Value) ;
			else if ( hid.GetType() == typeof(System.Web.UI.WebControls.HiddenField) )
				return !Sql.IsEmptyString((hid as HiddenField).Value) ;
			else
				return true;
		}
	}

	public class DateValidator : System.Web.UI.WebControls.BaseValidator 
	{
		private TextBox txt;

		public DateValidator()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			Control ctl = FindControl(ControlToValidate);

			if ( ctl != null )
			{
				txt = (TextBox) ctl;
				return (txt != null) ;
			}
			else 
				return false;  // raise exception
		}

		protected override bool EvaluateIsValid()
		{
			// 10/13/2005 Paul.  An empty string is treated as a valid date.  A separate RequiredFieldValidator is required to handle this condition. 
			return (txt.Text.Trim() == String.Empty) || Information.IsDate(txt.Text);
		}
	}

	public class TimeValidator : System.Web.UI.WebControls.BaseValidator 
	{
		private TextBox txt;

		public TimeValidator()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			Control ctl = FindControl(ControlToValidate);

			if ( ctl != null )
			{
				txt = (TextBox) ctl;
				return (txt != null) ;
			}
			else 
				return false;  // raise exception
		}

		protected override bool EvaluateIsValid()
		{
			// 03/03/2006 Paul.  An empty string is treated as a valid date.  A separate RequiredFieldValidator is required to handle this condition. 
			// 03/03/2006 Paul.  Validate with a prepended date so that it will fail if the user also supplies a date. 
			return (txt.Text.Trim() == String.Empty) || Information.IsDate(DateTime.Now.ToShortDateString() + " " + txt.Text);
		}
	}

	public class DatePickerValidator : System.Web.UI.WebControls.BaseValidator 
	{
		private DatePicker ctlDate;

		public DatePickerValidator()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			Control ctl = FindControl(ControlToValidate);

			if ( ctl != null )
			{
				ctlDate = (DatePicker) ctl;
				return (ctlDate != null) ;
			}
			else 
				return false;  // raise exception
		}

		protected override bool EvaluateIsValid()
		{
			// 03/03/2006 Paul.  An empty string is treated as a valid date.  A separate RequiredFieldValidator is required to handle this condition. 
			return (ctlDate.DateText.Trim() == String.Empty) || Information.IsDate(ctlDate.DateText);
		}
	}

	public class RequiredFieldValidatorForDatePicker : System.Web.UI.WebControls.BaseValidator 
	{
		private DatePicker ctlDate;

		public RequiredFieldValidatorForDatePicker()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			Control ctl = FindControl(ControlToValidate);

			if ( ctl != null )
			{
				ctlDate = (DatePicker) ctl;
				return (ctlDate != null) ;
			}
			else 
				return false;  // raise exception
		}

		protected override bool EvaluateIsValid()
		{
			return !Sql.IsEmptyString(ctlDate.DateText) ;
		}
	}

	public class RequiredFieldValidatorForTeamSelect : System.Web.UI.WebControls.BaseValidator 
	{
		private TeamSelect ctlTeamSelect;

		public RequiredFieldValidatorForTeamSelect()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			// 09/21/2009 Paul.  The ControlToValidate field is not used. 
			ctlTeamSelect = this.NamingContainer as TeamSelect;
			return (ctlTeamSelect != null) ;
		}

		protected override bool EvaluateIsValid()
		{
			return ctlTeamSelect != null && !Sql.IsEmptyString(ctlTeamSelect.TEAM_SET_LIST);
		}
	}

	// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	public class RequiredFieldValidatorForUserSelect : System.Web.UI.WebControls.BaseValidator 
	{
		private UserSelect ctlUserSelect;

		public RequiredFieldValidatorForUserSelect()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			ctlUserSelect = this.NamingContainer as UserSelect;
			return (ctlUserSelect != null) ;
		}

		protected override bool EvaluateIsValid()
		{
			return ctlUserSelect != null && !Sql.IsEmptyString(ctlUserSelect.ASSIGNED_SET_LIST);
		}
	}

	public class RequiredFieldValidatorForNAICSCodeSelect : System.Web.UI.WebControls.BaseValidator 
	{
		private NAICSCodeSelect ctlNAICSCodeSelect;

		public RequiredFieldValidatorForNAICSCodeSelect()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			ctlNAICSCodeSelect = this.NamingContainer as NAICSCodeSelect;
			return (ctlNAICSCodeSelect != null) ;
		}

		protected override bool EvaluateIsValid()
		{
			return ctlNAICSCodeSelect != null && !Sql.IsEmptyString(ctlNAICSCodeSelect.NAICS_SET_NAME);
		}
	}


	// 05/12/2016 Paul.  Add Tags module. 
	public class RequiredFieldValidatorForTagSelect : System.Web.UI.WebControls.BaseValidator 
	{
		private TagSelect ctlTagSelect;

		public RequiredFieldValidatorForTagSelect()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			// 09/21/2009 Paul.  The ControlToValidate field is not used. 
			ctlTagSelect = this.NamingContainer as TagSelect;
			return (ctlTagSelect != null) ;
		}

		protected override bool EvaluateIsValid()
		{
			return ctlTagSelect != null && !Sql.IsEmptyString(ctlTagSelect.TAG_SET_NAME);
		}
	}

	public class RequiredFieldValidatorForKBTagSelect : System.Web.UI.WebControls.BaseValidator 
	{
		private KBTagSelect ctlKBTagSelect;

		public RequiredFieldValidatorForKBTagSelect()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			// 09/21/2009 Paul.  The ControlToValidate field is not used. 
			ctlKBTagSelect = this.NamingContainer as KBTagSelect;
			return (ctlKBTagSelect != null) ;
		}

		protected override bool EvaluateIsValid()
		{
			return ctlKBTagSelect != null && !Sql.IsEmptyString(ctlKBTagSelect.KBTAG_SET_LIST);
		}
	}

	public class RequiredFieldValidatorForRelatedSelect : System.Web.UI.WebControls.BaseValidator 
	{
		private RelatedSelect ctlRelatedSelect;

		public RequiredFieldValidatorForRelatedSelect()
		{
			base.EnableClientScript = false;
		}

		protected override bool ControlPropertiesValid()
		{
			// 09/21/2009 Paul.  The ControlToValidate field is not used. 
			ctlRelatedSelect = this.NamingContainer as RelatedSelect;
			return (ctlRelatedSelect != null) ;
		}

		protected override bool EvaluateIsValid()
		{
			return ctlRelatedSelect != null && !Sql.IsEmptyString(ctlRelatedSelect.RELATED_SET_LIST);
		}
	}

}



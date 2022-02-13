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
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;
using System.Web.UI;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Globalization;

#region Assembly Resource Attribute
[assembly: System.Web.UI.WebResource("SplendidCRM.Users.SplendidPasswordExtenderBehavior.js", "text/javascript")]
#endregion

namespace SplendidCRM
{
	[TargetControlType(typeof(TextBox))]
	[AjaxControlToolkit.ClientScriptResource("Sys.Extended.UI.SplendidPasswordExtenderBehavior", "SplendidCRM.Users.SplendidPasswordExtenderBehavior.js")]
	[AjaxControlToolkit.RequiredScript(typeof(AjaxControlToolkit.CommonToolkitScripts))]
	public class SplendidPassword : AjaxControlToolkit.ExtenderControlBase
	{
		private const int    TXT_INDICATORS_MIN_COUNT     =   2;  // Minimum number of textual descriptions
		private const int    TXT_INDICATORS_MAX_COUNT     =  10;  // Maximum number of textual descriptions.
		private const char   TXT_INDICATOR_DELIMITER      = ';';  // Text indicators are delimited with a semi colon

		private const string _sRemainingCharactersDefault = "{0} more characters"                ;
		private const string _sRemainingNumbersDefault    = "{0} more numbers"                   ;
		private const string _sRemainingLowerCaseDefault  = "{0} more lower case characters"     ;
		private const string _sRemainingUpperCaseDefault  = "{0} more upper case characters"     ;
		private const string _sRemainingSymbolsDefault    = "{0} symbol characters"              ;
		private const string _sRemainingMixedCaseDefault  = "{0} more mixed case characters"     ;
		private const string _sSatisfiedDefault           = "Nothing more required"              ;

		/// <summary>
		/// The preferred or ideal length of the password. Passwords could be less than this amount but wont reach the 100% calculation
		/// if less than this count. This is used to calculate 50% of the percentage strength of the password
		/// </summary>
		/// <example>Ideally, a password should be 20 characters in length to be a strong password.</example>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue(0)]
		public int PreferredPasswordLength
		{
			get { return GetPropertyValue("PreferredPasswordLength", 0); }
			set { SetPropertyValue("PreferredPasswordLength", value); }
		}

		/// <summary>
		/// The minimum number if numeric characters required. If there are less than this property, then the password is not
		/// considered strong. If there are equal to or more than this value, then this will contribute 15% to the overall
		/// password strength percentage value.
		/// </summary>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue(0)]
		public int MinimumNumericCharacters
		{
			get { return GetPropertyValue("MinimumNumericCharacters", 0); }
			set { SetPropertyValue("MinimumNumericCharacters", value); }
		}

		/// <summary>
		/// The Css class that is used to display the image for showing the password requirements to meet.
		/// This is used so that the user can click on this image and get a display on what is required to make the
		/// password strong according to the current properties.
		/// </summary>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string HelpHandleCssClass
		{
			get { return GetPropertyValue("HelpHandleCssClass", String.Empty); }
			set { SetPropertyValue("HelpHandleCssClass", value); }
		}

		/// <summary>
		/// The position that the help handle is displayed
		/// </summary>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("AboveSide")]
		public string HelpHandlePosition
		{
			get { return GetPropertyValue("HelpHandlePosition", "AboveSide"); }
			set { SetPropertyValue("HelpHandlePosition", value); }
		}

		[IDReferenceProperty(typeof(Label))]
		[DefaultValue("")]
		[AjaxControlToolkit.ExtenderControlProperty()]
		public string HelpStatusLabelID
		{
			get { return GetPropertyValue("HelpStatusLabelID", String.Empty); }
			set { SetPropertyValue("HelpStatusLabelID", value); }
		}

		/// <summary>
		/// The minimum number of symbol characters required (e.g. %^&* etc..). If there are less than this property, then the password is not
		/// considered strong. If there are equal to or more than this value, then this will contribute 15% to the overall
		/// password strength percentage value.
		/// </summary>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue(0)]
		public int MinimumSymbolCharacters
		{
			get { return GetPropertyValue("MinimumSymbolCharacters", 0); }
			set { SetPropertyValue("MinimumSymbolCharacters", value); }
		}

		/// <summary>
		/// CSS class to apply to the control
		/// </summary>
		[DefaultValue(null)]
		[AjaxControlToolkit.ExtenderControlProperty()]
		public string TextCssClass
		{
			get { return GetPropertyValue("TextCssClass", (string)null); }
			set { SetPropertyValue("TextCssClass", value); }
		}

		[DefaultValue(null)]
		[AjaxControlToolkit.ExtenderControlProperty()]
		public string BarBorderCssClass
		{
			get { return GetPropertyValue("BarBorderCssClass", (string)null); }
			set { SetPropertyValue("BarBorderCssClass", value); }
		}

		[DefaultValue(null)]
		[AjaxControlToolkit.ExtenderControlProperty()]
		public string BarIndicatorCssClass
		{
			get { return GetPropertyValue("BarIndicatorCssClass", (string)null); }
			set { SetPropertyValue("BarIndicatorCssClass", value); }
		}

		/// <summary>
		/// The text prefixed to the password strength display value when using text display mode
		/// </summary>
		[DefaultValue("")]
		[AjaxControlToolkit.ExtenderControlProperty()]
		public string PrefixText
		{
			get { return GetPropertyValue("PrefixText", "Strength: "); }
			set { SetPropertyValue("PrefixText", value); }
		}

		[DefaultValue(AjaxControlToolkit.DisplayPosition.RightSide)]
		[AjaxControlToolkit.ExtenderControlProperty()]
		public AjaxControlToolkit.DisplayPosition DisplayPosition
		{
			get { return GetPropertyValue("DisplayPosition", AjaxControlToolkit.DisplayPosition.RightSide); }
			set { SetPropertyValue("DisplayPosition", value); }
		}

		/// <summary>
		/// A property that is either Bar (as in progress bar indicating password strength) or
		/// text (i.e. low, medium, high, excellent for strength).
		/// </summary>
		[DefaultValue(AjaxControlToolkit.StrengthIndicatorTypes.Text)]
		[AjaxControlToolkit.ExtenderControlProperty()]
		public AjaxControlToolkit.StrengthIndicatorTypes StrengthIndicatorType
		{
			get { return GetPropertyValue("StrengthIndicatorType", AjaxControlToolkit.StrengthIndicatorTypes.Text); }
			set { SetPropertyValue("StrengthIndicatorType", value); }
		}

		/// <summary>
		/// The Calculation ratios or "weightings" used when calculating a passwords strength.
		/// Must be a string with 4 elements separated by a semi colon.
		/// Default is '50;15;15;20' which represents
		/// ... Password Length: 50%
		/// ... Meets Numerics requirements : 15%
		/// ... Meets Casing requirements: 15%
		/// ... Meets Symbol character requirements: 20%
		/// </summary>
		/// <remarks>Total of 4 elements must equal 100</remarks>
		[DefaultValue("")]
		[AjaxControlToolkit.ExtenderControlProperty()]
		public string CalculationWeightings
		{
			get { return GetPropertyValue("CalculationWeightings", String.Empty); }
			set
			{
				if ( String.IsNullOrEmpty(value) )
				{
					SetPropertyValue("CalculationWeightings", value);
				}
				else
				{
					int total = 0;
					if ( null != value )
					{
						string[] tmpList = value.Split(';');
						foreach ( string val in tmpList )
						{
							int tmpVal;
							if ( int.TryParse(val, NumberStyles.Integer, CultureInfo.InvariantCulture, out tmpVal) )
								total += tmpVal;
						}
					}
					if ( total == 100 )
						SetPropertyValue("CalculationWeightings", value);
					else
						throw new ArgumentException("There must be 4 Calculation Weighting items which must total 100");
				}
			}
		}

		/// <summary>
		/// A semi-colon delimited string that specifies the string descriptions for the password strength when using a textual display.
		/// </summary>
		/// <example>None;Weak;Medium;Strong;Excellent</example>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string TextStrengthDescriptions
		{
			get { return GetPropertyValue("TextStrengthDescriptions", String.Empty); }
			set
			{
				bool valid = false;
				if ( !string.IsNullOrEmpty(value) )
				{
					string[] txtItems = value.Split(TXT_INDICATOR_DELIMITER);
					if ( txtItems.Length >= TXT_INDICATORS_MIN_COUNT && txtItems.Length <= TXT_INDICATORS_MAX_COUNT )
					{
						valid = true;
					}
				}
				if ( valid )
				{
					SetPropertyValue("TextStrengthDescriptions", value);
				}
				else
				{
					string msg = string.Format(CultureInfo.CurrentCulture, "Invalid property specification for TextStrengthDescriptions property. Must be a string delimited with '{0}', contain a minimum of {1} entries, and a maximum of {2}.", TXT_INDICATOR_DELIMITER, TXT_INDICATORS_MIN_COUNT, TXT_INDICATORS_MAX_COUNT);
					throw new ArgumentException(msg);
				}
			}
		}

		/// <summary>
		/// A semi-colon delimited string that specifies the styles applicable to each
		/// string descriptions for the password strength when using a textual display.
		/// </summary>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string StrengthStyles
		{
			get { return GetPropertyValue("StrengthStyles", String.Empty); }
			set
			{
				bool valid = false;
				if ( !string.IsNullOrEmpty(value) )
				{
					string[] styleItems = value.Split(TXT_INDICATOR_DELIMITER);
					if ( styleItems.Length <= TXT_INDICATORS_MAX_COUNT )
					{
						valid = true;
					}
				}
				if ( valid )
				{
					SetPropertyValue("StrengthStyles", value);
				}
				else
				{
					string msg = string.Format(CultureInfo.CurrentCulture, "Invalid property specification for StrengthStyles property. Must match the number of entries for the TextStrengthDescriptions property.");
					throw new ArgumentException(msg);
				}
			}
		}

		/// <summary>
		/// If the <see cref="RequiresUpperAndLowerCaseCharacters"/> property is true, then this property determines the
		/// minimum lower case characters that are required. The default value is 0 which means this property is not
		/// in effect and there is no minimum limit.
		/// </summary>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue(0)]
		public int MinimumLowerCaseCharacters
		{
			get { return GetPropertyValue("MinimumLowerCaseCharacters", 0); }
			set { SetPropertyValue("MinimumLowerCaseCharacters",value); }
		}

		/// <summary>
		/// If the <see cref="RequiresUpperAndLowerCaseCharacters"/> property is true, then this property determines the
		/// minimum upper case characters that are required. The default value is 0 which means this property is not
		/// in effect and there is no minimum limit.
		/// </summary>
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue(0)]
		public int MinimumUpperCaseCharacters
		{
			get { return GetPropertyValue("MinimumUpperCaseCharacters", 0); }
			set { SetPropertyValue("MinimumUpperCaseCharacters",value); }
		}

		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string SymbolCharacters
		{
			get { return GetPropertyValue("SymbolCharacters", String.Empty); }
			set { SetPropertyValue("SymbolCharacters", value); }
		}

		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue(1)]
		public int ComplexityNumber
		{
			get { return GetPropertyValue("ComplexityNumber", 1); }
			set
			{
				if ( value > 4 )
					value = 4;
				else if ( value < 0 )
					value = 0;
				SetPropertyValue("ComplexityNumber", value);
			}
		}

		// 02/19/2011 Paul.  Messages are now external. 
		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string MessageRemainingCharacters
		{
			get { return GetPropertyValue("MessageRemainingCharacters", _sRemainingCharactersDefault); }
			set { SetPropertyValue("MessageRemainingCharacters", value); }
		}

		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string MessageRemainingNumbers
		{
			get { return GetPropertyValue("MessageRemainingNumbers", _sRemainingNumbersDefault); }
			set { SetPropertyValue("MessageRemainingNumbers", value); }
		}

		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string MessageRemainingLowerCase
		{
			get { return GetPropertyValue("MessageRemainingLowerCase", _sRemainingLowerCaseDefault); }
			set { SetPropertyValue("MessageRemainingLowerCase", value); }
		}

		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string MessageRemainingUpperCase
		{
			get { return GetPropertyValue("MessageRemainingUpperCase", _sRemainingUpperCaseDefault); }
			set { SetPropertyValue("MessageRemainingUpperCase", value); }
		}

		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string MessageRemainingSymbols
		{
			get { return GetPropertyValue("MessageRemainingSymbols", _sRemainingSymbolsDefault); }
			set { SetPropertyValue("MessageRemainingSymbols", value); }
		}

		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string MessageRemainingMixedCase
		{
			get { return GetPropertyValue("MessageRemainingMixedCase", _sRemainingMixedCaseDefault); }
			set { SetPropertyValue("MessageRemainingMixedCase", value); }
		}

		[AjaxControlToolkit.ExtenderControlProperty()]
		[DefaultValue("")]
		public string MessageSatisfied
		{
			get { return GetPropertyValue("MessageSatisfied", _sSatisfiedDefault); }
			set { SetPropertyValue("MessageSatisfied", value); }
		}

		public bool IsValid(string pwd, ref string pwdRequirements)
		{
			pwd = pwd.Trim();
			int complexity = 0;

			//***********************************************
			// Length Criteria
			if ( pwd.Length < this.PreferredPasswordLength )
				pwdRequirements = String.Format(this.MessageRemainingCharacters, this.PreferredPasswordLength - pwd.Length);

			//***********************************************
			// Numeric Criteria
			// Does it contain numbers?
			if ( this.MinimumNumericCharacters > 0 )
			{
				Regex numbersRegex = new Regex("[0-9]");
				int numCount = numbersRegex.Matches(pwd).Count;
				if ( numCount >= this.MinimumNumericCharacters )
				{
					complexity++;
				}
				else
				{
					if ( pwdRequirements != String.Empty )
						pwdRequirements += ", ";
					pwdRequirements += String.Format(this.MessageRemainingNumbers, this.MinimumNumericCharacters - numCount);
				}
			}

			//***********************************************
			// Casing Criteria
			// Does it contain lowercase AND uppercase Text
			if ( this.MinimumLowerCaseCharacters > 0 && this.MinimumUpperCaseCharacters > 0 )
			{
				Regex lowercaseRegex = new Regex("[a-z]");
				Regex uppercaseRegex = new Regex("[A-Z]");
				int numLower = lowercaseRegex.Matches(pwd).Count;
				// 01/09/2022 Paul.  Was not counting upper case characters properly. 
				int numUpper = uppercaseRegex.Matches(pwd).Count;
				if ( numLower > 0 || numUpper > 0 )
				{
					if ( this.MinimumLowerCaseCharacters > 0 && numLower >= this.MinimumLowerCaseCharacters )
					{
						complexity++;
					}
					else 
					{
						if ( pwdRequirements != String.Empty )
							pwdRequirements += ", ";
						pwdRequirements += String.Format(this.MessageRemainingLowerCase, this.MinimumLowerCaseCharacters - numLower);
					}
					if ( this.MinimumUpperCaseCharacters > 0 && numUpper >= this.MinimumUpperCaseCharacters )
					{
						complexity++;
					}
					else
					{
						if ( pwdRequirements != String.Empty )
							pwdRequirements += ", ";
						pwdRequirements += String.Format(this.MessageRemainingUpperCase, this.MinimumUpperCaseCharacters - numUpper);
					}
				}
				else
				{
					if ( pwdRequirements != String.Empty )
						pwdRequirements += ", ";
					// 01/09/2022 Paul.  Need to foramt the string with the minimum number. 
					pwdRequirements += String.Format(this.MessageRemainingMixedCase, this.MinimumLowerCaseCharacters + this.MinimumUpperCaseCharacters);
				}
			}
			else if ( this.MinimumLowerCaseCharacters > 0 || this.MinimumUpperCaseCharacters > 0 )
			{
				Regex mixedRegex = new Regex("[a-z,A-Z]");
				int numMixed = mixedRegex.Matches(pwd).Count;
				if ( numMixed >= (this.MinimumLowerCaseCharacters + this.MinimumUpperCaseCharacters) )
				{
					complexity++;
				}
				else
				{
					if ( pwdRequirements != String.Empty )
						pwdRequirements += ", ";
					pwdRequirements += String.Format(this.MessageRemainingMixedCase, this.MinimumLowerCaseCharacters + this.MinimumUpperCaseCharacters);
				}
			}

			//***********************************************
			// Symbol Criteria
			// Does it contain any special symbols?
			if ( this.MinimumSymbolCharacters > 0 )
			{
				Regex symbolRegex = null;
				if ( this.SymbolCharacters != null && this.SymbolCharacters != String.Empty )
				{
					// http://www.regular-expressions.info/characters.html
					Regex specialRegex = new Regex(@"[\+\-\!\(\)\{\}\[\]\^\" + "\"" + @"\~\*\:\?\\]|&&|\|\|");
					// 03/05/2011 Paul.  Fix issue with escaping the symbol characters. 
					string _escapedSymbolCharacters = specialRegex.Replace(this.SymbolCharacters, @"\$0");
					symbolRegex = new Regex("[" + _escapedSymbolCharacters + "]");
				}
				else
				{
					symbolRegex = new Regex("[^a-z,A-Z,0-9,\x20]");  // related to work item 1034
				}
				
				int numCount = symbolRegex.Matches(pwd).Count;
				if ( numCount >= this.MinimumSymbolCharacters )
				{
					complexity++;
				}
				else
				{
					if ( pwdRequirements != String.Empty )
						pwdRequirements += ", ";
					pwdRequirements += String.Format(this.MessageRemainingSymbols, this.MinimumSymbolCharacters - numCount);
				}
			}
			// 02/20/2011 Paul.  If the password meets the complexity requiements, then ignore the other failures. 
			if ( pwd.Length >= this.PreferredPasswordLength && complexity >= this.ComplexityNumber )
				pwdRequirements = String.Empty;
			return Sql.IsEmptyString(pwdRequirements);
		}
	}
}


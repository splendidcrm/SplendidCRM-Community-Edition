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

namespace SplendidCRM
{
	public class KeySortDropDownList : System.Web.UI.WebControls.DropDownList
	{
		protected override void OnPreRender(EventArgs e)
		{
			base.OnPreRender(e);
			this.Attributes.Add("onkeypress", "return KeySortDropDownList_onkeypress(this, false)");
			// 10/16/2015 Paul.  fireEvent is not supported in IE 11. 
			// https://msdn.microsoft.com/en-us/library/ff986080(v=vs.85).aspx
			string sFireEvent = "if(document.createEvent) {var evt = document.createEvent('HTMLEvents'); evt.initEvent('change',true,false); this.dispatchEvent(evt); } else if ( this.fireEvent ) { this.fireEvent('onChange'); }";
			this.Attributes.Add("onkeydown" , "if (window.event.keyCode == 13||window.event.keyCode == 9||window.event.keyCode == 27){" + sFireEvent + " onchangefired=true;}");
			this.Attributes.Add("onclick"   , "if (this.selectedIndex!=" + this.SelectedIndex + " && onchangefired==false) {" + sFireEvent + " onchangefired=true;}");
			// 01/13/2010 Paul.  KeySortDropDownList is causing OnChange will always fire when tabbed-away. 
			// This onblur could be the cause, but we are not ready to research the issue further.  
			// It was only an issue in the PARENT_TYPE dropdown, so we will simply not use the KeySort in the Parent Type area. 
			this.Attributes.Add("onblur"    , "if (this.selectedIndex!=" + this.SelectedIndex + " && onchangefired==false) {" + sFireEvent + "}");
		}
	}
}



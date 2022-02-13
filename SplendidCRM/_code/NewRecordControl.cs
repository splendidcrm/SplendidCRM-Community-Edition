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
using System.Web.UI.WebControls;

namespace SplendidCRM
{
	public class NewRecordControl : InlineEditControl
	{
		protected string sEditView          = "NewRecord";
		protected Unit   uWidth             = new Unit("100%");
		protected bool   bShowTopButtons    = false;
		protected bool   bShowBottomButtons = true ;
		protected bool   bShowHeader        = true ;
		protected bool   bShowInlineHeader  = false;
		protected bool   bShowFullForm      = false;
		protected bool   bShowCancel        = false;

		// 05/06/2010 Paul.  We need a common way to attach a command from the Toolbar. 
		public CommandEventHandler Command     ;
		// 06/04/2010 Paul.  Generate a load event so that the fields can be populated. 
		public EventHandler        EditViewLoad;

		// 05/05/2010 Paul.  We need a common way to access the parent from the Toolbar. 
		public Guid PARENT_ID
		{
			get
			{
				// 02/21/2010 Paul.  An EditView Inline will use the ViewState, and a NewRecord Inline will use the Request. 
				Guid gPARENT_ID = Sql.ToGuid(ViewState["PARENT_ID"]);
				if ( Sql.IsEmptyGuid(gPARENT_ID) )
					gPARENT_ID = Sql.ToGuid(Request["PARENT_ID"]);
				return gPARENT_ID;
			}
			set
			{
				ViewState["PARENT_ID"] = value;
			}
		}

		public string PARENT_TYPE
		{
			get { return Sql.ToString(ViewState["PARENT_TYPE"]); }
			set { ViewState["PARENT_TYPE"] = value; }
		}

		// 04/19/2010 Paul.  Allow the EditView to be redefined. 
		public string EditView
		{
			get { return sEditView; }
			set { sEditView = value; }
		}

		public Unit Width
		{
			get { return uWidth; }
			set { uWidth = value; }
		}

		public bool ShowTopButtons
		{
			get { return bShowTopButtons; }
			set { bShowTopButtons = value; }
		}

		public bool ShowBottomButtons
		{
			get { return bShowBottomButtons; }
			set { bShowBottomButtons = value; }
		}

		public bool ShowHeader
		{
			get { return bShowHeader; }
			set { bShowHeader = value; }
		}

		public bool ShowInlineHeader
		{
			get { return bShowInlineHeader; }
			set { bShowInlineHeader = value; }
		}

		public bool ShowCancel
		{
			get { return bShowCancel; }
			set { bShowCancel = value; }
		}

		public bool ShowFullForm
		{
			get { return bShowFullForm; }
			set { bShowFullForm = value; }
		}
	}
}


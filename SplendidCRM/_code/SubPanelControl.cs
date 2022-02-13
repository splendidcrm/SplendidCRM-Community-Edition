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

namespace SplendidCRM
{
	public class SubPanelControl : InlineEditControl
	{
		protected bool bEditView;

		public bool IsEditView
		{
			get { return bEditView; }
			set { bEditView = value; }
		}

		protected UniqueGuidCollection GetDeletedEditViewRelationships()
		{
			UniqueGuidCollection arrDELETED = ViewState[m_sMODULE + ".Deleted"] as UniqueGuidCollection;
			if ( arrDELETED == null )
				arrDELETED = new UniqueGuidCollection();
			return arrDELETED;
		}

		protected UniqueGuidCollection GetUpdatedEditViewRelationships()
		{
			UniqueGuidCollection arrUPDATED = ViewState[m_sMODULE + ".Updated"] as UniqueGuidCollection;
			if ( arrUPDATED == null )
				arrUPDATED = new UniqueGuidCollection();
			return arrUPDATED;
		}

		protected void DeleteEditViewRelationship(Guid gDELETE_ID)
		{
			// 01/27/2010 Paul.  Keep a separate list of removed items. 
			UniqueGuidCollection arrDELETED = GetDeletedEditViewRelationships();
			arrDELETED.Add(gDELETE_ID);
			ViewState[m_sMODULE + ".Deleted"] = arrDELETED;
			
			UniqueGuidCollection arrUPDATED = ViewState[m_sMODULE + ".Updated"] as UniqueGuidCollection;
			if ( arrUPDATED != null )
			{
				arrUPDATED.Remove(gDELETE_ID);
				ViewState[m_sMODULE + ".Updated"] = arrUPDATED;
			}
		}

		protected void UpdateEditViewRelationship(Guid gUPDATE_ID)
		{
			UniqueGuidCollection arrUPDATED = GetUpdatedEditViewRelationships();
			arrUPDATED.Add(gUPDATE_ID);
			ViewState[m_sMODULE + ".Updated"] = arrUPDATED;
			
			// 01/27/2010 Paul.  Just in case the user is adding back a record that he previous removed. 
			UniqueGuidCollection arrDELETED = ViewState[m_sMODULE + ".Deleted"] as UniqueGuidCollection;
			if ( arrDELETED != null )
			{
				arrDELETED.Remove(gUPDATE_ID);
				ViewState[m_sMODULE + ".Deleted"] = arrDELETED;
			}
		}

		protected void UpdateEditViewRelationship(string[] arrID)
		{
			UniqueGuidCollection arrUPDATED = GetUpdatedEditViewRelationships();
			foreach(string item in arrID)
			{
				Guid gUPDATE_ID = Sql.ToGuid(item);
				arrUPDATED.Add(gUPDATE_ID);
			}
			ViewState[m_sMODULE + ".Updated"] = arrUPDATED;
			
			UniqueGuidCollection arrDELETED = ViewState[m_sMODULE + ".Deleted"] as UniqueGuidCollection;
			if ( arrDELETED != null )
			{
				foreach(string item in arrID)
				{
					Guid gUPDATE_ID = Sql.ToGuid(item);
					arrDELETED.Remove(gUPDATE_ID);
				}
				ViewState[m_sMODULE + ".Deleted"] = arrDELETED;
			}
		}

		protected void CreateEditViewRelationships(DataTable dt, string sPrimaryField)
		{
			UniqueGuidCollection arrUPDATED = new UniqueGuidCollection();
			foreach ( DataRow row in dt.Rows )
			{
				Guid gUPDATE_ID = Sql.ToGuid(row[sPrimaryField]);
				arrUPDATED.Add(gUPDATE_ID);
			}
			ViewState[m_sMODULE + ".Updated"] = arrUPDATED;
		}
	}
}


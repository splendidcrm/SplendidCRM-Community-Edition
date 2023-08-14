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
using System.Text;
using System.Collections.Generic;
using System.Collections.Specialized;
using Spring.Json;

namespace Spring.Social.Office365.Api
{
	[Serializable]
	public class OutlookCategory : Entity
	{
		#region Properties
		public String              DisplayName      { get; set; }
		public String              Color            { get; set; }
		#endregion

		public OutlookCategory()
		{
			this.ODataType = "microsoft.graph.outlookCategory";
		}

		public static DataTable CreateTable()
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("id"                      , Type.GetType("System.String"  ));
			return dt;
		}

		public void SetRow(DataRow row)
		{
			for ( int i = 0; i < row.Table.Columns.Count; i++ )
			{
				row[i] = DBNull.Value;
			}
			row["id"  ] = this.Id;
		}

		public static DataRow ConvertToRow(OutlookCategory obj)
		{
			DataTable dt = OutlookCategory.CreateTable();
			DataRow row = dt.NewRow();
			obj.SetRow(row);
			return row;
		}

		public static DataTable ConvertToTable(IList<OutlookCategory> categories)
		{
			DataTable dt = OutlookCategory.CreateTable();
			if ( categories != null )
			{
				foreach ( OutlookCategory category in categories )
				{
					DataRow row = dt.NewRow();
					dt.Rows.Add(row);
					category.SetRow(row);
				}
			}
			return dt;
		}
	}

	public class OutlookCategoryPagination
	{
		public IList<OutlookCategory>  categories     { get; set; }
		public int                     count          { get; set; }
	}
}

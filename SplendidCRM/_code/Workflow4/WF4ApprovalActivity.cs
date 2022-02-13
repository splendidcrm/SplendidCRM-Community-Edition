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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Runtime.Serialization;
using System.Xml;
using System.Web;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.ComponentModel;
using System.Diagnostics;

namespace SplendidCRM
{
	public class WF4ApprovalResponse
	{
		public string BookmarkName { get; set; }
		public Guid   USER_ID      { get; set; }
		public string RESPONSE     { get; set; }
		public string XML          { get; set; }
	}

	public class WF4ApprovalActivity
	{
		public static void Approve(HttpApplicationState Application, L10N L10n, Guid gID, Guid gUSER_ID)
		{
		}

		public static void Reject(HttpApplicationState Application, Guid gID, Guid gUSER_ID)
		{
		}

		public static void Route(HttpApplicationState Application, L10N L10n, Guid gID, Guid gUSER_ID)
		{
		}

		public static void Claim(HttpApplicationState Application, Guid gID, Guid gUSER_ID)
		{
		}

		public static void Cancel(HttpApplicationState Application, Guid gID, Guid gUSER_ID)
		{
		}

		public static void ChangeProcessUser(HttpApplicationState Application, Guid gID, Guid gPROCESS_USER_ID, string sPROCESS_NOTES)
		{
		}

		public static void ChangeAssignedUser(HttpApplicationState Application, Guid gID, Guid gASSIGNED_USER_ID, string sPROCESS_NOTES)
		{
		}

		public static void Filter(HttpApplicationState Application, IDbCommand cmd, Guid gUSER_ID)
		{
		}

		public static bool GetProcessStatus(HttpApplicationState Application, L10N L10n, Guid gPENDING_PROCESS_ID, ref string sProcessStatus, ref bool bShowApprove, ref bool bShowReject, ref bool bShowRoute, ref bool bShowClaim, ref string sUSER_TASK_TYPE, ref Guid gPROCESS_USER_ID, ref Guid gASSIGNED_TEAM_ID, ref Guid gPROCESS_TEAM_ID)
		{
			return false;
		}

		public static bool IsProcessPending(System.Web.UI.WebControls.DataGridItem Container)
		{
			return false;
		}

		public static void ApplyEditViewPostLoadEventRules(HttpApplicationState Application, L10N L10n, string sEDIT_NAME, SplendidControl parent, DataRow row)
		{
		}

		public static void ApplyEditViewPreSaveEventRules(HttpApplicationState Application, L10N L10n, string sEDIT_NAME, SplendidControl parent, DataRow row)
		{
		}

		public static void ValidateRequiredFields(HttpApplicationState Application, L10N L10n, Guid gPENDING_PROCESS_ID)
		{
		}
	}
}

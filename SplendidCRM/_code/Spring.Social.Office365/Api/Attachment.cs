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
using System.Data;
using System.Text;
using System.Collections.Generic;
using System.Collections.Specialized;
using Spring.Json;

namespace Spring.Social.Office365.Api
{
	public class Attachment : Entity
	{
		// ItemAttachment fields. 
		public String            ContentType          { get; set; }
		public String            Name                 { get; set; }
		public long?             Size                 { get; set; }
		public bool?             IsInline             { get; set; }
		public DateTimeOffset?   LastModifiedDateTime { get; set; }
		// FileAttachment fields. 
		public String            ContentId            { get; set; }
		public String            ContentLocation      { get; set; }
		public byte[]            ContentBytes         { get; set; }  // base64

		public Attachment()
		{
			this.ODataType = "#microsoft.graph.fileAttachment";
		}

		public Attachment(string sName, string sContentType, Stream stmContent)
		{
			this.ODataType = "#microsoft.graph.fileAttachment";
			this.Name         = sName       ;
			this.ContentType  = sContentType;
			this.ContentBytes = new byte[stmContent.Length];
			// 03/01/2021 Paul.  Size is required. 
			this.Size         = stmContent.Length;
			// 03/01/2021 paul.  IsInline is required. 
			this.IsInline     = false;
			stmContent.Seek(0, SeekOrigin.Begin);
			stmContent.Read (this.ContentBytes, 0, (int) stmContent.Length);
		}
	}
}

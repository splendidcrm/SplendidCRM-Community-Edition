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
using System.Web;
using System.Diagnostics;

namespace SplendidCRM.FileBrowser
{
	public class FileWorkerUtils
	{
		// 11/06/2010 Paul.  Move LoadFile() to Crm.EmailImages. 

		public static void LoadImage(ref Guid gImageID, ref string sFILENAME, IDbTransaction trn)
		{
			// 04/26/2012 Paul.  CKEditor change the name to upload. 
			LoadImage(ref gImageID, ref sFILENAME, "upload", trn);
		}

		// 08/09/2009 Paul.  We need to allow the field name to be a parameter so that this code can be reused. 
		public static void LoadImage(ref Guid gImageID, ref string sFILENAME, string sHTML_FIELD_NAME, IDbTransaction trn)
		{
			gImageID = Guid.Empty;
			HttpPostedFile pstIMAGE  = HttpContext.Current.Request.Files[sHTML_FIELD_NAME];
			if ( pstIMAGE != null )
			{
				long lFileSize      = pstIMAGE.ContentLength;
				long lUploadMaxSize = Sql.ToLong(HttpContext.Current.Application["CONFIG.upload_maxsize"]);
				if ( (lUploadMaxSize > 0) && (lFileSize > lUploadMaxSize) )
				{
					throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
				}
				// 04/13/2005 Paul.  File may not have been provided. 
				if ( pstIMAGE.FileName.Length > 0 )
				{
					sFILENAME              = Path.GetFileName (pstIMAGE.FileName);
					string sFILE_EXT       = Path.GetExtension(sFILENAME);
					string sFILE_MIME_TYPE = pstIMAGE.ContentType;
					
					SqlProcs.spEMAIL_IMAGES_Insert
						( ref gImageID
						, Guid.Empty // gParentID
						, sFILENAME
						, sFILE_EXT
						, sFILE_MIME_TYPE
						, trn
						);
					// 09/06/2008 Paul.  PostgreSQL does not require that we stream the bytes, so lets explore doing this for all platforms. 
					// 10/18/2009 Paul.  Move blob logic to LoadFile. 
					Crm.EmailImages.LoadFile(gImageID, pstIMAGE.InputStream, trn);
				}
			}
		}
	}
}


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
 *********************************************************************************************************************/
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'DOCUMENT_REVISIONS_CSTM' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.DOCUMENT_REVISIONS_CSTM';
	Create Table dbo.DOCUMENT_REVISIONS_CSTM
		( ID_C                               uniqueidentifier not null constraint PK_DOCUMENT_REVISIONS_CSTM primary key
		)
  end
GO



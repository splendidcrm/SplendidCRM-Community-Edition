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
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'RULES' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.RULES';
	Create Table dbo.RULES
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_RULES primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, ASSIGNED_USER_ID                   uniqueidentifier null
		, TEAM_ID                            uniqueidentifier null
		, TEAM_SET_ID                        uniqueidentifier null
		, NAME                               nvarchar(150) null
		, MODULE_NAME                        nvarchar(25) null
		, RULE_TYPE                          nvarchar(25) null
		, DESCRIPTION                        nvarchar(max) null
		, FILTER_SQL                         nvarchar(max) null
		, FILTER_XML                         nvarchar(max) null
		, RULES_XML                          nvarchar(max) null
		, XOML                               nvarchar(max) null
		)

	-- 10/30/2010 Paul.  Include the name in the index as the NAME is used in vwDETAILVIEWS and vwEDITVIEWS. 
	create index IDX_RULES_ID_NAME on dbo.RULES (ID, DELETED, NAME)
  end
GO


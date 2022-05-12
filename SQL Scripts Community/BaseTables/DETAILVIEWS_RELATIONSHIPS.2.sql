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
-- 09/08/2007 Paul.  Allow relationships to be disabled. 
-- 09/08/2007 Paul.  Allow nulls in relationship order field. 
-- 09/08/2007 Paul.  We need a title when we migrate to WebParts. 
-- 09/24/2009 Paul.  The new Silverlight charts exceeded the control name length of 50. 
-- 10/28/2009 Paul.  Add UTC date to allow this table to sync. 
-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
-- 03/20/2016 Paul.  Increase PRIMARY_FIELD size to 255 to support OfficeAddin. 
-- 03/30/2022 Paul.  Add Insight fields. 
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.DETAILVIEWS_RELATIONSHIPS';
	Create Table dbo.DETAILVIEWS_RELATIONSHIPS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_DETAILVIEWS_RELATIONSHIPS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, DETAIL_NAME                        nvarchar( 50) not null
		, MODULE_NAME                        nvarchar( 50) null
		, CONTROL_NAME                       nvarchar(100) null
		, RELATIONSHIP_ORDER                 int null
		, RELATIONSHIP_ENABLED               bit null default(1)
		, TITLE                              nvarchar(100) null
		, TABLE_NAME                         nvarchar(50) null
		, PRIMARY_FIELD                      nvarchar(255) null
		, SORT_FIELD                         nvarchar(50) null
		, SORT_DIRECTION                     nvarchar(10) null
		, INSIGHT_LABEL                      nvarchar(100) null
		, INSIGHT_OPERATOR                   nvarchar(2000) null
		, INSIGHT_VIEW                       nvarchar(50) null
		)

	create index IDX_DETAILVIEWS_RELATIONSHIPS_DETAIL_NAME on dbo.DETAILVIEWS_RELATIONSHIPS (DETAIL_NAME, DELETED, RELATIONSHIP_ENABLED)
  end
GO




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
-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'RELATIONSHIP_ENABLED') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add RELATIONSHIP_ENABLED bit null default(1)';
	alter table DETAILVIEWS_RELATIONSHIPS add RELATIONSHIP_ENABLED bit null default(1);

	exec ( 'update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ENABLED = 1
		 where RELATIONSHIP_ENABLED is null');
end -- if;
GO

-- 09/08/2007 Paul.  Allow nulls in relationship order field. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'RELATIONSHIP_ORDER' and IS_NULLABLE = 'NO') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS alter column RELATIONSHIP_ORDER int null';
	alter table DETAILVIEWS_RELATIONSHIPS alter column RELATIONSHIP_ORDER int null;
end -- if;
GO

-- 09/08/2007 Paul.  We need a title when we migrate to WebParts. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'TITLE') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add TITLE nvarchar(100) null';
	alter table DETAILVIEWS_RELATIONSHIPS add TITLE nvarchar(100) null;

	exec ( 'update DETAILVIEWS_RELATIONSHIPS
		   set TITLE = MODULE_NAME + N''.LBL_MODULE_NAME''
		 where TITLE is null');
end -- if;
GO

-- 09/24/2009 Paul.  The new Silverlight charts exceeded the control name length of 50. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'CONTROL_NAME' and CHARACTER_MAXIMUM_LENGTH < 100) begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS alter column CONTROL_NAME nvarchar(100) not null';
	alter table DETAILVIEWS_RELATIONSHIPS alter column CONTROL_NAME nvarchar(100) not null;
end -- if;
GO

-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'TABLE_NAME') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add TABLE_NAME nvarchar(50) null';
	alter table DETAILVIEWS_RELATIONSHIPS add TABLE_NAME nvarchar(50) null;

	exec ( 'update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME   = N''vw'' + upper(replace(DETAIL_NAME, N''.DetailView'', N''_'')) + upper(CONTROL_NAME)
		 where DETAIL_NAME  like N''%.DetailView''
		   and CONTROL_NAME not like N''~/%''
		   and TABLE_NAME   is null');
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'PRIMARY_FIELD') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add PRIMARY_FIELD nvarchar(50) null';
	alter table DETAILVIEWS_RELATIONSHIPS add PRIMARY_FIELD nvarchar(50) null;

	exec ( 'update DETAILVIEWS_RELATIONSHIPS
		   set PRIMARY_FIELD = (case when charindex(N''ies.DetailView'', DETAIL_NAME) > 0 then upper(replace(DETAIL_NAME, N''ies.DetailView'', N'''')) + N''Y_ID''
		                             when charindex(N''s.DetailView''  , DETAIL_NAME) > 0 then upper(replace(DETAIL_NAME, N''s.DetailView''  , N'''')) + N''_ID''
		                        else upper(replace(DETAIL_NAME, N''.DetailView'', N'''')) + N''_ID''
		                        end)
		 where DETAIL_NAME   like N''%.DetailView''
		   and CONTROL_NAME  not like N''~/%''
		   and PRIMARY_FIELD is null
		   and TABLE_NAME    is not null');
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'SORT_FIELD') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add SORT_FIELD nvarchar(50) null';
	alter table DETAILVIEWS_RELATIONSHIPS add SORT_FIELD nvarchar(50) null;

	-- 10/14/2012 Paul.  Sort by Contact Name, Lead Name and Prospect Name. 
	exec ( 'update DETAILVIEWS_RELATIONSHIPS
		   set SORT_FIELD   = (case when substring(MODULE_NAME, len(MODULE_NAME) - 2, 3) = N''ies'' then upper(substring(MODULE_NAME, 1, len(MODULE_NAME) - 3)) + N''Y_NAME''
		                            when substring(MODULE_NAME, len(MODULE_NAME)    , 1) = N''s''   then upper(substring(MODULE_NAME, 1, len(MODULE_NAME) - 1)) + N''_NAME''
		                       else upper(MODULE_NAME) + N''_NAME''
		                       end)
		 where DETAIL_NAME  like N''%.DetailView''
		   and CONTROL_NAME in (N''Contacts'', N''Leads'', N''Prospects'')
		   and SORT_FIELD   is null
		   and TABLE_NAME   is not null');

	exec ( 'update DETAILVIEWS_RELATIONSHIPS
		   set SORT_FIELD   = N''DATE_ENTERED''
		 where DETAIL_NAME  like N''%.DetailView''
		   and CONTROL_NAME not like N''~/%''
		   and SORT_FIELD   is null
		   and TABLE_NAME   is not null');
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'SORT_DIRECTION') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add SORT_DIRECTION nvarchar(10) null';
	alter table DETAILVIEWS_RELATIONSHIPS add SORT_DIRECTION nvarchar(10) null;

	-- 10/14/2012 Paul.  Sort by Contact Name, Lead Name and Prospect Name. 
	exec ( 'update DETAILVIEWS_RELATIONSHIPS
		   set SORT_DIRECTION = N''asc''
		 where DETAIL_NAME    like N''%.DetailView''
		   and CONTROL_NAME   in (N''Contacts'', N''Leads'', N''Prospects'')
		   and SORT_DIRECTION is null
		   and TABLE_NAME     is not null');

	exec ( 'update DETAILVIEWS_RELATIONSHIPS
		   set SORT_DIRECTION = N''desc''
		 where DETAIL_NAME    like N''%.DetailView''
		   and CONTROL_NAME   not like N''~/%''
		   and SORT_DIRECTION is null
		   and TABLE_NAME     is not null');
end -- if;
GO

-- 03/20/2016 Paul.  Increase PRIMARY_FIELD size to 255 to support OfficeAddin. 
if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'PRIMARY_FIELD' and CHARACTER_MAXIMUM_LENGTH < 255) begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS alter column PRIMARY_FIELD nvarchar(255) null';
	alter table DETAILVIEWS_RELATIONSHIPS alter column PRIMARY_FIELD nvarchar(255) null;
end -- if;
GO

-- 03/30/2022 Paul.  Add Insight fields. 
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'INSIGHT_OPERATOR') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add INSIGHT_OPERATOR nvarchar(2000) null';
	alter table DETAILVIEWS_RELATIONSHIPS add INSIGHT_OPERATOR nvarchar(2000) null;
	-- alter table DETAILVIEWS_RELATIONSHIPS alter column INSIGHT_OPERATOR nvarchar(2000) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'INSIGHT_VIEW') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add INSIGHT_VIEW nvarchar(50) null';
	alter table DETAILVIEWS_RELATIONSHIPS add INSIGHT_VIEW nvarchar(50) null;
end -- if;
GO

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'DETAILVIEWS_RELATIONSHIPS' and COLUMN_NAME = 'INSIGHT_LABEL') begin -- then
	print 'alter table DETAILVIEWS_RELATIONSHIPS add INSIGHT_LABEL nvarchar(100) null';
	alter table DETAILVIEWS_RELATIONSHIPS add INSIGHT_LABEL nvarchar(100) null;
end -- if;
GO


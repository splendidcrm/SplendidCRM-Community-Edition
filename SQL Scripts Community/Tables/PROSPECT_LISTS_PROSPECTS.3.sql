
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
-- 04/21/2006 Paul.  RELATED_ID was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  RELATED_TYPE was added in SugarCRM 4.0.
-- 04/21/2006 Paul.  PROSPECT_ID was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  CONTACT_ID was dropped in SugarCRM 4.0.
-- 04/21/2006 Paul.  LEAD_ID was dropped in SugarCRM 4.0.
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS_PROSPECTS' and COLUMN_NAME = 'RELATED_ID') begin -- then
	print 'alter table PROSPECT_LISTS_PROSPECTS add RELATED_ID uniqueidentifier null';
	alter table PROSPECT_LISTS_PROSPECTS add RELATED_ID   uniqueidentifier null;
	alter table PROSPECT_LISTS_PROSPECTS add RELATED_TYPE nvarchar(25) null;

	create index IDX_PROSPECT_LISTS_PROSPECTS_RELATED on dbo.PROSPECT_LISTS_PROSPECTS (RELATED_ID, RELATED_TYPE);
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS_PROSPECTS' and COLUMN_NAME = 'PROSPECT_ID') begin -- then
	print 'alter table PROSPECT_LISTS_PROSPECTS drop column PROSPECT_ID';
	execute ('update PROSPECT_LISTS_PROSPECTS set RELATED_ID = PROSPECT_ID, RELATED_TYPE = ''Prospects'' where PROSPECT_ID is not null');

	alter table dbo.PROSPECT_LISTS_PROSPECTS drop constraint FK_PROSPECT_LISTS_PROSPECTS_PROSPECT_ID;
	if exists (select * from sys.indexes where name = 'IDX_PROSPECT_LISTS_PROSPECTS_PROSPECT_ID') begin -- then
		drop index IDX_PROSPECT_LISTS_PROSPECTS_PROSPECT_ID on PROSPECT_LISTS_PROSPECTS;
	end -- if;
	alter table PROSPECT_LISTS_PROSPECTS drop column PROSPECT_ID;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS_PROSPECTS' and COLUMN_NAME = 'CONTACT_ID') begin -- then
	print 'alter table PROSPECT_LISTS_PROSPECTS drop column CONTACT_ID';
	execute ('update PROSPECT_LISTS_PROSPECTS set RELATED_ID = CONTACT_ID , RELATED_TYPE = ''Contacts'' where CONTACT_ID is not null');

	alter table dbo.PROSPECT_LISTS_PROSPECTS drop constraint FK_PROSPECT_LISTS_PROSPECTS_CONTACT_ID ;
	if exists (select * from sys.indexes where name = 'IDX_PROSPECT_LISTS_PROSPECTS_CONTACT_ID') begin -- then
		drop index IDX_PROSPECT_LISTS_PROSPECTS_CONTACT_ID on PROSPECT_LISTS_PROSPECTS;
	end -- if;
	alter table PROSPECT_LISTS_PROSPECTS drop column CONTACT_ID;
end -- if;
GO

if exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'PROSPECT_LISTS_PROSPECTS' and COLUMN_NAME = 'LEAD_ID') begin -- then
	print 'alter table PROSPECT_LISTS_PROSPECTS drop column LEAD_ID';
	execute ('update PROSPECT_LISTS_PROSPECTS set RELATED_ID = LEAD_ID, RELATED_TYPE = ''Leads'' where LEAD_ID is not null');

	alter table dbo.PROSPECT_LISTS_PROSPECTS drop constraint FK_PROSPECT_LISTS_PROSPECTS_LEAD_ID    ;
	if exists (select * from sys.indexes where name = 'IDX_PROSPECT_LISTS_PROSPECTS_LEAD_ID') begin -- then
		drop index IDX_PROSPECT_LISTS_PROSPECTS_LEAD_ID on PROSPECT_LISTS_PROSPECTS;
	end -- if;
	alter table PROSPECT_LISTS_PROSPECTS drop column LEAD_ID;
end -- if;
GO



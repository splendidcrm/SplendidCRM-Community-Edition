
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
-- 01/13/2008 Paul.  Add the reply name so that this lis can be used by the email manager. 
-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'INBOUND_EMAIL_AUTOREPLY' and COLUMN_NAME = 'AUTOREPLIED_NAME') begin -- then
	print 'alter table INBOUND_EMAIL_AUTOREPLY add AUTOREPLIED_NAME nvarchar(100) null';
	alter table INBOUND_EMAIL_AUTOREPLY add AUTOREPLIED_NAME nvarchar(100) null;
end -- if;
GO

if exists (select * from sys.indexes where name = 'IDX_INBOUND_EMAIL_AUTOREPLY_TO') begin -- then
	print 'drop index IDX_INBOUND_EMAIL_AUTOREPLY_TO';
	drop index IDX_INBOUND_EMAIL_AUTOREPLY_TO on INBOUND_EMAIL_AUTOREPLY;
end -- if;
GO

if not exists (select * from sys.indexes where name = 'IDX_INBOUND_EMAIL') begin -- then
	-- drop index IDX_INBOUND_EMAIL on dbo.INBOUND_EMAIL_AUTOREPLY;
	print 'create index IDX_INBOUND_EMAIL';
	create index IDX_INBOUND_EMAIL on dbo.INBOUND_EMAIL_AUTOREPLY (AUTOREPLIED_TO, DATE_ENTERED, DELETED, AUTOREPLIED_NAME);
end -- if;
GO


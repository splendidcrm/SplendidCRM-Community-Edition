

print 'SqlBuildAllStreamTables';

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
-- 09/27/2015 Paul.  Don't create the audit tables on an Offline Client database. 
-- 06/04/2021 Paul.  Do not create the stream tables if they system has been disabled. 
if dbo.fnCONFIG_Boolean('enable_activity_streams') = 1 begin -- then
	if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SYSTEM_SYNC_CONFIG' and TABLE_TYPE = 'BASE TABLE') begin -- then
		exec dbo.spSqlBuildAllStreamTables ;
	end -- if;
end -- if;
GO

-- 10/10/2015 Paul.  Provide a way to disable streams.  When disabled, just remove the triggers and keep the data. 
if dbo.fnCONFIG_Boolean('enable_activity_streams') = 0 begin -- then
	print 'spSqlDropAllStreamTriggers';
	exec dbo.spSqlDropAllStreamTriggers ;
end -- if;
GO

-- exec dbo.spSqlBuildAllStreamTriggers ;
-- select name from sys.triggers where name like 'tr%_Ins_STREAM' order by name;


/* -- #if Oracle
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			StoO_selcnt := 0;
		WHEN OTHERS THEN
			RAISE;
	END;
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spSqlBuildAllStreamTables_Data()
/

call dbo.spSqlDropProcedure('spSqlBuildAllStreamTables_Data')
/

-- #endif IBM_DB2 */


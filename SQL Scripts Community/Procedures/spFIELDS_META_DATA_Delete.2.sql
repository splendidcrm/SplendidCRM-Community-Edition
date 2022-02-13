if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spFIELDS_META_DATA_Delete' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spFIELDS_META_DATA_Delete;
GO


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
-- 01/02/2008 Paul.  Make sure to remove the column from the triggers. 
-- 11/17/2008 Paul.  We need to update the audit views for the workflow engine. 
-- 08/07/2013 Paul.  Add Oracle Exception. 
-- 04/18/2016 Paul.  Allow disable recompile so that we can do in the background. 
-- 02/25/2017 Paul.  We need to refresh Stream views. 
-- 11/18/2017 Paul.  Correct to use @TABLE_NAME instead of @CUSTOM_TABLE. 
-- 12/18/2017 Paul.  Add Archive access right. 
-- 07/27/2018 Paul.  We need to update the Custom table not the main table. 
Create Procedure dbo.spFIELDS_META_DATA_Delete
	( @ID                uniqueidentifier
	, @MODIFIED_USER_ID  uniqueidentifier
	, @DISABLE_RECOMPILE bit = null
	)
as
  begin
	set nocount on
	
	declare @CUSTOM_MODULE      nvarchar(255);
	declare @CUSTOM_TABLE       nvarchar(255);
	-- 12/18/2017 Paul.  Add Archive access right. 
	declare @ARCHIVE_TABLE      nvarchar(255);
	declare @ARCHIVE_DATABASE   nvarchar(50);
	declare @EXISTS             bit;
	declare @NAME               nvarchar(255);
	declare @TABLE_NAME         nvarchar(255);

	if exists(select * from FIELDS_META_DATA where ID = @ID and DELETED = 0) begin -- then
		-- BEGIN Oracle Exception
			select @CUSTOM_MODULE = CUSTOM_MODULE
			     , @NAME          = NAME
			  from FIELDS_META_DATA
			 where ID             = @ID
			   and DELETED        = 0;
		-- END Oracle Exception

			
		set @CUSTOM_TABLE = dbo.fnCustomTableName(@CUSTOM_MODULE);
		-- 01/06/2006 Paul.  Try and drop the column first as it is more likely to fail than the update statement. 
		exec dbo.spSqlTableDropColumn @CUSTOM_TABLE, @NAME;
	
		if @@ERROR = 0 begin -- then
		-- BEGIN Oracle Exception
			update FIELDS_META_DATA
			   set DELETED          = 1
			     , DATE_MODIFIED    = getdate()
			     , DATE_MODIFIED_UTC= getutcdate()
			     , MODIFIED_USER_ID = @MODIFIED_USER_ID
			 where ID               = @ID
			   and DELETED          = 0;
		-- END Oracle Exception
		end -- if;
	
		-- 01/06/2006 Paul.  If successful deleting a field, then refresh all views. 
		if @@ERROR = 0 begin -- then
			-- 01/02/2008 Paul.  Make sure to remove the column from the triggers. 
			if exists(select * from vwSqlTablesAudited where TABLE_NAME = @CUSTOM_TABLE) begin -- then
				--exec dbo.spSqlBuildAuditTable   @CUSTOM_TABLE;
				exec dbo.spSqlBuildAuditTrigger @CUSTOM_TABLE;

			end -- if;
			-- 11/17/2008 Paul.  We need to update the audit views for the workflow engine. 
			-- BEGIN Oracle Exception
				select @TABLE_NAME = TABLE_NAME
				  from vwMODULES
				 where MODULE_NAME = @CUSTOM_MODULE;
			-- END Oracle Exception
			if @TABLE_NAME is not null begin -- then
				if exists(select * from vwSqlTablesAudited where TABLE_NAME = @TABLE_NAME) begin -- then
					exec dbo.spSqlBuildAuditView @TABLE_NAME;
				end -- if;
				
				-- 02/25/2017 Paul.  We need to refresh Stream views. 
				-- 11/18/2017 Paul.  Correct to use @TABLE_NAME instead of @CUSTOM_TABLE. 
				if exists(select * from vwSqlTablesStreamed where TABLE_NAME = @TABLE_NAME) begin -- then
					if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fn' + @TABLE_NAME + '_AUDIT_Columns') begin -- then
						exec dbo.spSqlBuildStreamFunction @TABLE_NAME;
					end -- if;
					if exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'vw' + @TABLE_NAME + '_STREAM') begin -- then
						exec dbo.spSqlBuildStreamView @TABLE_NAME;
					end -- if;
				end -- if;
				
				-- 12/18/2017 Paul.  Add Archive access right. 
				set @ARCHIVE_TABLE = @TABLE_NAME + '_ARCHIVE';
				set @ARCHIVE_DATABASE = dbo.fnCONFIG_String('Archive.Database');
				exec dbo.spSqlTableExists @EXISTS out, @ARCHIVE_TABLE, @ARCHIVE_DATABASE;
				if @EXISTS = 1 begin -- then
					-- 07/27/2018 Paul.  We need to update the Custom table not the main table. 
					exec dbo.spSqlBuildArchiveTable @CUSTOM_TABLE, @ARCHIVE_DATABASE;
					exec dbo.spSqlBuildArchiveView  @TABLE_NAME, @ARCHIVE_DATABASE;
				end -- if;
			end -- if;
			-- 04/18/2016 Paul.  Allow disable recompile so that we can do in the background. 
			if isnull(@DISABLE_RECOMPILE, 0) = 0 begin -- then
				exec dbo.spSqlRefreshAllViews ;
			end -- if;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spFIELDS_META_DATA_Delete to public;
GO


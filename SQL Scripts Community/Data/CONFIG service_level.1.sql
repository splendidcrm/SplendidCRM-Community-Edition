

print 'CONFIG ServiceLevel';
GO

set nocount on;
GO

exec dbo.spCONFIG_InsertOnly null, 'system', 'service_level'   , 'Community';
GO

-- 11/30/2008 Paul.  Service level name changed from Basic to Community. 
if exists(select * from CONFIG where NAME = 'service_level' and cast(VALUE as nvarchar(20)) = 'Basic' and DELETED = 0) begin -- then
	print 'Service level name has changed from Basic to Community.';
	update CONFIG
	   set VALUE  = 'Community'
	 where NAME   = 'service_level'
	   and cast(VALUE as nvarchar(20)) = 'Basic'
	   and DELETED = 0;
end -- if;
GO

-- 06/10/2023 Paul.  Correct service name change. 
if exists(select * from CONFIG where NAME = 'service_level' and cast(VALUE as nvarchar(20)) = 'Builder' and DELETED = 0) begin -- then
	print 'Service level name has changed from Builder to Community.';
	update CONFIG
	   set VALUE  = 'Community'
	 where NAME   = 'service_level'
	   and cast(VALUE as nvarchar(20)) = 'Builder'
	   and DELETED = 0;
end -- if;
GO

set nocount off;
GO

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

call dbo.spCONFIG_ServiceLevel()
/

call dbo.spSqlDropProcedure('spCONFIG_ServiceLevel')
/

-- #endif IBM_DB2 */


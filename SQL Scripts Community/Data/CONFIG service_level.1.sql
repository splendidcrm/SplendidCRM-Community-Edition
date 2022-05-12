

print 'CONFIG ServiceLevel';
GO

set nocount on;
GO

exec dbo.spCONFIG_InsertOnly null, 'system', 'service_level'   , 'Builder';
GO

-- 02/04/2022 Paul.  Service level name changed from Community to Builder. 
if exists(select * from CONFIG where NAME = 'service_level' and cast(VALUE as nvarchar(20)) = 'Community' and DELETED = 0) begin -- then
	print 'Service level name has changed from Community to Builder.';
	update CONFIG
	   set VALUE  = 'Builder'
	 where NAME   = 'service_level'
	   and cast(VALUE as nvarchar(20)) = 'Community'
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


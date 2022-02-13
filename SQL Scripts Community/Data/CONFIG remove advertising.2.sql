

print N'CONFIG Remove Advertising';
GO

set nocount on;
GO

-- 05/18/2009 Paul.  Remove Google advertising. 
if exists(select * from CONFIG where NAME = N'header_banner' and DELETED = 0 and VALUE like N'%pub-8191890858854346%') begin -- then
	print N'CONFIG Remove header_banner';
	update CONFIG
	   set VALUE            = null
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = N'header_banner'
	   and DELETED          = 0
	   and VALUE            like N'%pub-8191890858854346%';
end -- if;

if exists(select * from CONFIG where NAME = 'home_right_banner' and DELETED = 0 and VALUE like N'%pub-8191890858854346%') begin -- then
	print N'CONFIG Remove home_right_banner';
	update CONFIG
	   set VALUE            = null
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = N'home_right_banner'
	   and DELETED          = 0
	   and VALUE            like N'%pub-8191890858854346%';
end -- if;

if exists(select * from CONFIG where NAME = N'advertising' and DELETED = 0 and VALUE like N'%conference call services%') begin -- then
	print N'CONFIG Remove advertising';
	update CONFIG
	   set VALUE            = null
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where NAME             = N'advertising'
	   and DELETED          = 0
	   and VALUE            like N'%conference call services%';
end -- if;


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

call dbo.spCONFIG_RemoveAdvertising()
/

call dbo.spSqlDropProcedure('spCONFIG_RemoveAdvertising')
/

-- #endif IBM_DB2 */


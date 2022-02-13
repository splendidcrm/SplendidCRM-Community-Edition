

set nocount on;

-- 01/19/2010 Paul.  We are having a big problem with douplicate entries in the countries_dom. 
if exists(select * from vwTERMINOLOGY_LIST_DUPLICATES where LANG = N'en-US' and LIST_NAME = N'countries_dom') begin -- then
	print 'There were duplicates in the Countries list.  The list will be recreated.';
	delete from TERMINOLOGY
	 where LANG      = N'en-US'
	   and LIST_NAME = N'countries_dom';
end -- if;
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

call dbo.spTERMINOLOGY_delete_countries()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_delete_countries')
/

-- #endif IBM_DB2 */


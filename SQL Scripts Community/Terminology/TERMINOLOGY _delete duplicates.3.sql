

set nocount on;

-- 05/18/2006 Paul.  Some lists have duplicate names. 
-- Mark for deletion the list item with the lower order value. 
-- 07/08/2006 Paul.  Use a view to simplify this logic.
-- 07/08/2006 Paul.  DB2 and Oracle are both having a problem with the inner join in an update clause. 
-- 07/08/2006 Paul.  Solve the problem by using the TERMINOLOGY.ID in an IN clause. 
-- 01/01/2008 Paul.  It is potentially dangerous to use a while loop, so don't delete more than 100 at a time. 
-- 11/23/2009 Paul.  Increase to 250.  A customer had a bunch of countries_dom and moduleList duplicates. 
-- 12/28/2009 Paul.  The NAME will be null for report lists. 
-- 01/19/2010 Paul.  Add status to help debug problem with duplicates. 

declare @DELETE_ID          uniqueidentifier;
declare @DELETE_STATUS      nvarchar(1000);
declare @DELETED_DUPLICATES int;
set @DELETED_DUPLICATES = 0;
while @DELETED_DUPLICATES < 250 and exists(select * from vwTERMINOLOGY_LIST_DUPLICATES) begin -- then
	select @DELETE_ID     = ID
	     , @DELETE_STATUS = N'Deleting ' + isnull(MODULE_NAME, '') + N'.' + LIST_NAME + N'.' + NAME + N' (' + cast(LIST_ORDER as nvarchar(10)) + N')'
	  from TERMINOLOGY
	 where ID in (select top 1 TERMINOLOGY.ID
	                from       TERMINOLOGY
	               inner join  vwTERMINOLOGY_LIST_DUPLICATES
	                       on  vwTERMINOLOGY_LIST_DUPLICATES.LANG       = TERMINOLOGY.LANG
	                      and (vwTERMINOLOGY_LIST_DUPLICATES.NAME       = TERMINOLOGY.NAME       or (vwTERMINOLOGY_LIST_DUPLICATES.NAME       is null and TERMINOLOGY.NAME       is null))
	                      and (vwTERMINOLOGY_LIST_DUPLICATES.LIST_NAME  = TERMINOLOGY.LIST_NAME  )
	                      and (vwTERMINOLOGY_LIST_DUPLICATES.LIST_ORDER = TERMINOLOGY.LIST_ORDER or (vwTERMINOLOGY_LIST_DUPLICATES.LIST_ORDER is null and TERMINOLOGY.LIST_ORDER is null))
	                where TERMINOLOGY.DELETED = 0
	             );
	print @DELETE_STATUS;
	update TERMINOLOGY
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where ID                = @DELETE_ID;
	set @DELETED_DUPLICATES = @DELETED_DUPLICATES + 1;
end -- while;
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

call dbo.spTERMINOLOGY_delete_dups()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_delete_dups')
/

-- #endif IBM_DB2 */




declare @ID         uniqueidentifier;
declare @EDIT_NAME  nvarchar(50);
declare @DATA_FIELD nvarchar(100);
/* -- #if IBM_DB2
declare in_FETCH_STATUS int;
-- #endif IBM_DB2 */

declare DUPLICATE_CURSOR cursor for
select EDIT_NAME
     , DATA_FIELD
  from EDITVIEWS_FIELDS
 where DATA_FIELD = 'FAVORITE_RECORD_ID'
   and DEFAULT_VIEW = 0
   and DELETED = 0
 group by EDIT_NAME, DATA_FIELD
 having count(*) > 1;

/* -- #if IBM_DB2
declare continue handler for not found
	set in_FETCH_STATUS = 1;
set in_FETCH_STATUS = 0;
-- #endif IBM_DB2 */

-- 12/29/2016 Paul.  Need to delete duplicate FAVORITE_RECORD_ID records. 
if exists(select EDIT_NAME, DATA_FIELD from EDITVIEWS_FIELDS where DATA_FIELD = 'FAVORITE_RECORD_ID' and DEFAULT_VIEW = 0 and DELETED = 0 group by EDIT_NAME, DATA_FIELD having count(*) > 1) begin -- then
	open DUPLICATE_CURSOR;
	fetch next from DUPLICATE_CURSOR into @EDIT_NAME, @DATA_FIELD;
	while @@FETCH_STATUS = 0 begin -- do
		select top 1 @ID = ID
		  from EDITVIEWS_FIELDS
		 where DATA_FIELD   = 'FAVORITE_RECORD_ID'
		   and DEFAULT_VIEW = 0
		   and DELETED      = 0
		 order by DATE_ENTERED desc;
		print N'Remote duplicate field ' + @EDIT_NAME + '.' + @DATA_FIELD;
		update EDITVIEWS_FIELDS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where ID                = @ID;
		fetch next from DUPLICATE_CURSOR into @EDIT_NAME, @DATA_FIELD;
	end -- while;
	close DUPLICATE_CURSOR;
end -- if;
deallocate DUPLICATE_CURSOR;
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

call dbo.spEDITVIEWS_FIELDS_maintenance()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_maintenance')
/

-- #endif IBM_DB2 */


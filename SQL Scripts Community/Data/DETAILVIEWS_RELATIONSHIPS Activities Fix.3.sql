

set nocount on;
GO


-- 11/30/2012 Paul.  Use separate panels for Open Activities and History Activities as the HTML5 Offline Client does not allow for a single Activities panel that combines both. 
if exists(select DETAILVIEWS_RELATIONSHIPS_A.DETAIL_NAME
	  from      DETAILVIEWS_RELATIONSHIPS                          DETAILVIEWS_RELATIONSHIPS_A
	 inner join DETAILVIEWS_RELATIONSHIPS                          DETAILVIEWS_RELATIONSHIPS_O
	         on DETAILVIEWS_RELATIONSHIPS_O.DETAIL_NAME          = DETAILVIEWS_RELATIONSHIPS_A.DETAIL_NAME
	        and DETAILVIEWS_RELATIONSHIPS_O.CONTROL_NAME         = N'ActivitiesOpen'
	        and DETAILVIEWS_RELATIONSHIPS_O.RELATIONSHIP_ENABLED = 0
	        and DETAILVIEWS_RELATIONSHIPS_O.RELATIONSHIP_ORDER   > 0
	        and DETAILVIEWS_RELATIONSHIPS_O.DELETED              = 0
	 inner join DETAILVIEWS_RELATIONSHIPS                          DETAILVIEWS_RELATIONSHIPS_H
	         on DETAILVIEWS_RELATIONSHIPS_H.DETAIL_NAME          = DETAILVIEWS_RELATIONSHIPS_A.DETAIL_NAME
	        and DETAILVIEWS_RELATIONSHIPS_H.CONTROL_NAME         = N'ActivitiesHistory'
	        and DETAILVIEWS_RELATIONSHIPS_H.RELATIONSHIP_ENABLED = 0
	        and DETAILVIEWS_RELATIONSHIPS_H.RELATIONSHIP_ORDER   > 1
	        and DETAILVIEWS_RELATIONSHIPS_H.DELETED              = 0
	 where DETAILVIEWS_RELATIONSHIPS_A.CONTROL_NAME         = N'Activities'
	   and DETAILVIEWS_RELATIONSHIPS_A.RELATIONSHIP_ENABLED = 1
	   and DETAILVIEWS_RELATIONSHIPS_A.RELATIONSHIP_ORDER   < 2
	   and DETAILVIEWS_RELATIONSHIPS_A.DELETED              = 0) begin -- then
	--print 'Change Activities to ActivitiesOpen and ActivitiesHistory';
	declare @DETAIL_NAME nvarchar(50);
	declare ACTIVITIES_CURSOR cursor static for
	select DETAILVIEWS_RELATIONSHIPS_A.DETAIL_NAME
	  from      DETAILVIEWS_RELATIONSHIPS                          DETAILVIEWS_RELATIONSHIPS_A
	 inner join DETAILVIEWS_RELATIONSHIPS                          DETAILVIEWS_RELATIONSHIPS_O
	         on DETAILVIEWS_RELATIONSHIPS_O.DETAIL_NAME          = DETAILVIEWS_RELATIONSHIPS_A.DETAIL_NAME
	        and DETAILVIEWS_RELATIONSHIPS_O.CONTROL_NAME         = N'ActivitiesOpen'
	        and DETAILVIEWS_RELATIONSHIPS_O.RELATIONSHIP_ENABLED = 0
	        and DETAILVIEWS_RELATIONSHIPS_O.RELATIONSHIP_ORDER   > 0
	        and DETAILVIEWS_RELATIONSHIPS_O.DELETED              = 0
	 inner join DETAILVIEWS_RELATIONSHIPS                          DETAILVIEWS_RELATIONSHIPS_H
	         on DETAILVIEWS_RELATIONSHIPS_H.DETAIL_NAME          = DETAILVIEWS_RELATIONSHIPS_A.DETAIL_NAME
	        and DETAILVIEWS_RELATIONSHIPS_H.CONTROL_NAME         = N'ActivitiesHistory'
	        and DETAILVIEWS_RELATIONSHIPS_H.RELATIONSHIP_ENABLED = 0
	        and DETAILVIEWS_RELATIONSHIPS_H.RELATIONSHIP_ORDER   > 1
	        and DETAILVIEWS_RELATIONSHIPS_H.DELETED              = 0
	 where DETAILVIEWS_RELATIONSHIPS_A.CONTROL_NAME         = N'Activities'
	   and DETAILVIEWS_RELATIONSHIPS_A.RELATIONSHIP_ENABLED = 1
	   and DETAILVIEWS_RELATIONSHIPS_A.RELATIONSHIP_ORDER   < 2
	   and DETAILVIEWS_RELATIONSHIPS_A.DELETED              = 0
	 order by DETAILVIEWS_RELATIONSHIPS_A.DETAIL_NAME;

	open ACTIVITIES_CURSOR;
	fetch next from ACTIVITIES_CURSOR into @DETAIL_NAME;
	while @@FETCH_STATUS = 0 begin -- while
		print @DETAIL_NAME + ': Change Activities to ActivitiesOpen and ActivitiesHistory';
		-- 11/30/2012 Paul.  Update all records for the view, enabling Open and History while disabling Activities and shifting the position of all other records to make space. 
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER   = (case CONTROL_NAME when N'ActivitiesOpen' then 0 when N'ActivitiesHistory' then 1 when N'Activities' then 1 else RELATIONSHIP_ORDER + 1 end)
		     , RELATIONSHIP_ENABLED = (case CONTROL_NAME when N'ActivitiesOpen' then 1 when N'ActivitiesHistory' then 1 when N'Activities' then 0 else RELATIONSHIP_ENABLED   end)
		     , DATE_MODIFIED        = getdate()
		     , DATE_MODIFIED_UTC    = getutcdate()
		     , MODIFIED_USER_ID     = null
		 where DETAIL_NAME          = @DETAIL_NAME
		   and DELETED              = 0;
		fetch next from ACTIVITIES_CURSOR into @DETAIL_NAME;
	end -- while;
	close ACTIVITIES_CURSOR;
	deallocate ACTIVITIES_CURSOR;
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

call dbo.spDETAILVIEWS_RELATIONSHIPS_Fix()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_RELATIONSHIPS_Fix')
/

-- #endif IBM_DB2 */


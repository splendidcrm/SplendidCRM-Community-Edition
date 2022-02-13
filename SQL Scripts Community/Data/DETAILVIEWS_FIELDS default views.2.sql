

set nocount on;
GO

if exists(select distinct DETAILVIEWS_FIELDS.DETAIL_NAME
            from           DETAILVIEWS_FIELDS
           left outer join DETAILVIEWS_FIELDS DETAILVIEWS_FIELDS_DEFAULTS
                        on DETAILVIEWS_FIELDS_DEFAULTS.DETAIL_NAME    = DETAILVIEWS_FIELDS.DETAIL_NAME
                       and DETAILVIEWS_FIELDS_DEFAULTS.DEFAULT_VIEW = 1
                       and DETAILVIEWS_FIELDS_DEFAULTS.DELETED      = 0
           where DETAILVIEWS_FIELDS_DEFAULTS.ID is null
             and DETAILVIEWS_FIELDS.DELETED = 0) begin -- then

	-- 09/19/2012 Paul.  Add new fields.  Should have done this long ago. 
	insert into DETAILVIEWS_FIELDS(ID, DEFAULT_VIEW, CREATED_BY, DATE_ENTERED, MODIFIED_USER_ID, DATE_MODIFIED, DATE_MODIFIED_UTC, DETAIL_NAME, FIELD_INDEX, FIELD_TYPE, DATA_LABEL, DATA_FIELD, DATA_FORMAT, URL_FIELD, URL_FORMAT, URL_TARGET, LIST_NAME, COLSPAN, MODULE_TYPE, TOOL_TIP, PARENT_FIELD)
	select                    newid(), 1           , CREATED_BY, DATE_ENTERED, MODIFIED_USER_ID, DATE_MODIFIED, DATE_MODIFIED_UTC, DETAIL_NAME, FIELD_INDEX, FIELD_TYPE, DATA_LABEL, DATA_FIELD, DATA_FORMAT, URL_FIELD, URL_FORMAT, URL_TARGET, LIST_NAME, COLSPAN, MODULE_TYPE, TOOL_TIP, PARENT_FIELD
	  from DETAILVIEWS_FIELDS
	 where DELETED = 0
	   and DETAIL_NAME in (select distinct DETAILVIEWS_FIELDS.DETAIL_NAME
	                       from           DETAILVIEWS_FIELDS
	                      left outer join DETAILVIEWS_FIELDS DETAILVIEWS_FIELDS_DEFAULTS
	                                   on DETAILVIEWS_FIELDS_DEFAULTS.DETAIL_NAME    = DETAILVIEWS_FIELDS.DETAIL_NAME
	                                  and DETAILVIEWS_FIELDS_DEFAULTS.DEFAULT_VIEW = 1
	                                  and DETAILVIEWS_FIELDS_DEFAULTS.DELETED      = 0
	                      where DETAILVIEWS_FIELDS_DEFAULTS.ID is null
	                        and DETAILVIEWS_FIELDS.DELETED = 0);
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

call dbo.spDETAILVIEWS_FIELDS_DefaultViews()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_DefaultViews')
/

-- #endif IBM_DB2 */

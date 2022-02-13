

set nocount on;
GO

-- 05/09/2008 Paul.  Campaign tracker data does not contain ASSIGNED_USER_ID fields.
-- 04/08/2010 Paul.  There was a problem running this code as part of GRIDVIEWS_COLUMNS SubPanel defaults.1.sql, so move to a separate file. 
if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME like 'Campaigns.Track%' and URL_ASSIGNED_FIELD in ('ASSIGNED_USER_ID', 'RELATED_ASSIGNED_USER_ID') and DELETED = 0) begin -- then
	print 'Campaign tracker data does not contain ASSIGNED_USER_ID fields.';
	update GRIDVIEWS_COLUMNS
	   set URL_ASSIGNED_FIELD = null
	     , DATE_MODIFIED      = getdate()
	     , MODIFIED_USER_ID   = null
	 where GRID_NAME          like 'Campaigns.Track%'
	   and URL_ASSIGNED_FIELD in ('ASSIGNED_USER_ID', 'RELATED_ASSIGNED_USER_ID') 
	   and DELETED            = 0;
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

call dbo.spGRIDVIEWS_COLUMNS_CampaignsFix()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_CampaignsFix')
/

-- #endif IBM_DB2 */


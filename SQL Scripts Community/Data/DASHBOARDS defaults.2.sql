

print 'DASHBOARDS defaults';
GO

set nocount on;
GO

-- Default Dashboard. 
exec dbo.spDASHBOARDS_InsertOnly '8C5CC275-84E4-428B-AB4D-C3C6F63546B9', null, '17BB7135-2B95-42DC-85DE-842CAFF927A0', 'Default Dashboard', 'Dashboard';

if not exists(select * from DASHBOARDS_PANELS where DASHBOARD_ID = '8C5CC275-84E4-428B-AB4D-C3C6F63546B9') begin -- then
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '8C5CC275-84E4-428B-AB4D-C3C6F63546B9', 'Pipeline By Sales Stage'      , 1, 0, 12;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '8C5CC275-84E4-428B-AB4D-C3C6F63546B9', 'Opp By Lead Source By Outcome', 2, 1, 12;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '8C5CC275-84E4-428B-AB4D-C3C6F63546B9', 'Pipeline By Month By Outcome' , 3, 2, 12;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '8C5CC275-84E4-428B-AB4D-C3C6F63546B9', 'Opp By Lead Source'           , 4, 3, 12;
end -- if;
GO

-- Default Home Dashboard. 
exec dbo.spDASHBOARDS_InsertOnly '1F369A3E-B11E-482A-B6CB-7C27CCC79717', null, '17BB7135-2B95-42DC-85DE-842CAFF927A0', 'Default Home Dashboard', 'Home';

if not exists(select * from DASHBOARDS_PANELS where DASHBOARD_ID = '1F369A3E-B11E-482A-B6CB-7C27CCC79717') begin -- then
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '1F369A3E-B11E-482A-B6CB-7C27CCC79717', 'My Calls'                     , 1, 0,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '1F369A3E-B11E-482A-B6CB-7C27CCC79717', 'My Cases'                     , 2, 0,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '1F369A3E-B11E-482A-B6CB-7C27CCC79717', 'My Meetings'                  , 3, 1,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '1F369A3E-B11E-482A-B6CB-7C27CCC79717', 'My Opportunities'             , 4, 1,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '1F369A3E-B11E-482A-B6CB-7C27CCC79717', 'My Leads'                     , 5, 2,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '1F369A3E-B11E-482A-B6CB-7C27CCC79717', 'My Accounts'                  , 6, 2,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '1F369A3E-B11E-482A-B6CB-7C27CCC79717', 'My Pipeline By Sales Stage'   , 7, 3,  6;
end -- if;
GO

-- Default Favorites Dashboard. 
exec dbo.spDASHBOARDS_InsertOnly '94BD48FC-A7BF-411D-9638-08A93258510C', null, '17BB7135-2B95-42DC-85DE-842CAFF927A0', 'Favorites Dashboard', 'Home';

if not exists(select * from DASHBOARDS_PANELS where DASHBOARD_ID = '94BD48FC-A7BF-411D-9638-08A93258510C') begin -- then
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '94BD48FC-A7BF-411D-9638-08A93258510C', 'My Favorite Accounts'                  , 0, 0,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '94BD48FC-A7BF-411D-9638-08A93258510C', 'My Favorite Contacts'                  , 1, 0,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '94BD48FC-A7BF-411D-9638-08A93258510C', 'My Favorite Leads'                     , 2, 1,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '94BD48FC-A7BF-411D-9638-08A93258510C', 'My Favorite Opportunities'             , 3, 1,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '94BD48FC-A7BF-411D-9638-08A93258510C', 'My Favorite Cases'                     , 4, 2,  6;
	exec dbo.spDASHBOARDS_PANELS_InsertOnly '94BD48FC-A7BF-411D-9638-08A93258510C', 'My Favorite Bugs'                      , 5, 2,  6;
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

call dbo.spDASHBOARDS_Defaults()
/

call dbo.spSqlDropProcedure('spDASHBOARDS_Defaults')
/

-- #endif IBM_DB2 */


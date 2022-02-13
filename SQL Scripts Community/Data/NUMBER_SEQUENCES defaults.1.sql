

print 'NUMBER_SEQUENCES defaults';
GO

set nocount on;
GO

-- 08/20/2010 Paul.  Might as well use NULL for alpha prefix and suffix. 
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'ACCOUNTS.ACCOUNT_NUMBER'   , null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'BUGS.BUG_NUMBER'           , null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'CASES.CASE_NUMBER'         , null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'EMAILMAN.EMAILMAN_NUMBER'  , null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'CAMPAIGN_TRKRS.TRACKER_KEY', null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'CAMPAIGNS.TRACKER_KEY'     , null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'PROSPECTS.TRACKER_KEY'     , null, null, 1, 0, 0;
-- 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'CONTACTS.CONTACT_NUMBER'         , null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'LEADS.LEAD_NUMBER'               , null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'PROSPECTS.PROSPECT_NUMBER'       , null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'OPPORTUNITIES.OPPORTUNITY_NUMBER', null, null, 1, 0, 0;
exec dbo.spNUMBER_SEQUENCES_InsertOnly null, N'CAMPAIGNS.CAMPAIGN_NUMBER'       , null, null, 1, 0, 0;
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

call dbo.spNUMBER_SEQUENCES_Defaults()
/

call dbo.spSqlDropProcedure('spNUMBER_SEQUENCES_Defaults')
/

-- #endif IBM_DB2 */

 
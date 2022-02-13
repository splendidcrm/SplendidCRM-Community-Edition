

print 'CONFIG Logo';
GO

set nocount on;
GO

exec dbo.spCONFIG_InsertOnly null, 'system', 'header_logo_image' , 'SplendidCRM_Logo.gif';
exec dbo.spCONFIG_InsertOnly null, 'system', 'header_logo_width' , '207';
exec dbo.spCONFIG_InsertOnly null, 'system', 'header_logo_height', '60';
exec dbo.spCONFIG_InsertOnly null, 'system', 'header_logo_style' , 'margin-left: 10px';
-- 07/24/2006 Paul.  We need a way to change the header background. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'header_background' , 'images/header_bg.gif';
-- 01/26/2014 Paul.  Atlantic theme header logo. 
exec dbo.spCONFIG_InsertOnly null, 'system', 'header_home_image' , '~/Include/images/SplendidCRM_Icon.gif';
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

call dbo.spCONFIG_Logo()
/

call dbo.spSqlDropProcedure('spCONFIG_Logo')
/

-- #endif IBM_DB2 */


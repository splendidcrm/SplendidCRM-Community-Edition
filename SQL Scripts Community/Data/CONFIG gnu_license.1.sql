

print 'CONFIG License';
GO

set nocount on;
GO

exec dbo.spCONFIG_InsertOnly null, 'system', 'gnu_license', '<p>This program is free software: you can redistribute it and/or modify it under the terms of the 
<a href="http://www.gnu.org/licenses/agpl.txt">GNU Affero General Public License</a> as published by the 
<a href="http://www.gnu.org/licenses/">Free Software Foundation</a>, either version 3 
of the License, or (at your option) any later version.</p>

<p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the <a href="http://www.gnu.org/licenses/agpl.txt">GNU Affero General Public License</a> for more details.</p>
';

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

call dbo.spCONFIG_License()
/

call dbo.spSqlDropProcedure('spCONFIG_License')
/

-- #endif IBM_DB2 */


if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwACL_ACCESS_ByModule')
	Drop View dbo.vwACL_ACCESS_ByModule;
GO


/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 *********************************************************************************************************************/
-- 04/26/2006 Paul.  Get the minimum ACLACCESS just in case vwACL_ACTIONS contains multiple records. 
-- Normally, we would use a unique index on the ACL_ACTIONS table, but we cannot because 
-- near identical rows are allowed because of the use of the DELETED flag. 
-- 12/05/2006 Paul.  iFrames should not be excluded because the My Portal tab can be disabled and edited. 
-- 02/03/2009 Paul.  Exclude Teams from role management. 
-- 03/09/2010 Paul.  Allow IS_ADMIN and Team Management so that they can be managed separately. 
-- 04/17/2016 Paul.  Allow Calendar to be disabled. 
-- 09/26/2017 Paul.  Add Archive access right. 
-- 01/11/2019 Paul.  Activities should not be excluded as started treating Activities separately on 06/02/2016. 
Create View dbo.vwACL_ACCESS_ByModule
as
select vwMODULES.MODULE_NAME
     , vwMODULES.DISPLAY_NAME
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'admin' ),  1) as ACLACCESS_ADMIN 
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'access'), 89) as ACLACCESS_ACCESS
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'view'  ), 90) as ACLACCESS_VIEW  
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'list'  ), 90) as ACLACCESS_LIST  
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'edit'  ), 90) as ACLACCESS_EDIT  
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'delete'), 90) as ACLACCESS_DELETE
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'import'), 90) as ACLACCESS_IMPORT
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'export'), 90) as ACLACCESS_EXPORT
     , isnull((select min(ACLACCESS) from vwACL_ACTIONS where CATEGORY = vwMODULES.MODULE_NAME and NAME = N'archive'), 90) as ACLACCESS_ARCHIVE
     , vwMODULES.IS_ADMIN
  from vwMODULES
 where vwMODULES.MODULE_NAME not in (N'Home')
GO

Grant Select on dbo.vwACL_ACCESS_ByModule to public;
GO



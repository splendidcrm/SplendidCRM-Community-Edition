if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONTACTS_List')
	Drop View dbo.vwCONTACTS_List;
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
-- 02/27/2006 Paul.  Added DATE_MODIFIED. 
-- 08/12/2021 Paul.  Add Machine Learning prediction fields. 
Create View dbo.vwCONTACTS_List
as
select vwCONTACTS.*
     , CONTACTS_PREDICTIONS.PROBABILITY
     , CONTACTS_PREDICTIONS.SCORE
     , CONTACTS_PREDICTIONS.PREDICTION
  from vwCONTACTS
  left outer join CONTACTS_PREDICTIONS
               on CONTACTS_PREDICTIONS.CONTACT_ID  = vwCONTACTS.ID
              and CONTACTS_PREDICTIONS.DELETED     = 0

GO

Grant Select on dbo.vwCONTACTS_List to public;
GO



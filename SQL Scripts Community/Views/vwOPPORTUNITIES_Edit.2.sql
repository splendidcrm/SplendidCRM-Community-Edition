if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwOPPORTUNITIES_Edit')
	Drop View dbo.vwOPPORTUNITIES_Edit;
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
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/12/2021 Paul.  Add Machine Learning prediction fields. 
Create View dbo.vwOPPORTUNITIES_Edit
as
select vwOPPORTUNITIES.*
     , OPPORTUNITIES_PREDICTIONS.PROBABILITY AS ML_PROBABILITY
     , OPPORTUNITIES_PREDICTIONS.SCORE
     , OPPORTUNITIES_PREDICTIONS.PREDICTION
  from vwOPPORTUNITIES
  left outer join OPPORTUNITIES_PREDICTIONS
               on OPPORTUNITIES_PREDICTIONS.OPPORTUNITY_ID = vwOPPORTUNITIES.ID
              and OPPORTUNITIES_PREDICTIONS.DELETED        = 0

GO

Grant Select on dbo.vwOPPORTUNITIES_Edit to public;
GO



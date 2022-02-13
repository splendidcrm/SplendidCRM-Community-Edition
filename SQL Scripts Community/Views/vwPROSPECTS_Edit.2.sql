if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwPROSPECTS_Edit')
	Drop View dbo.vwPROSPECTS_Edit;
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
Create View dbo.vwPROSPECTS_Edit
as
select vwPROSPECTS.*
     , dbo.fnFullAddressHtml(vwPROSPECTS.PRIMARY_ADDRESS_STREET, vwPROSPECTS.PRIMARY_ADDRESS_CITY, vwPROSPECTS.PRIMARY_ADDRESS_STATE, vwPROSPECTS.PRIMARY_ADDRESS_POSTALCODE, vwPROSPECTS.PRIMARY_ADDRESS_COUNTRY) as PRIMARY_ADDRESS_HTML
     , dbo.fnFullAddressHtml(vwPROSPECTS.ALT_ADDRESS_STREET    , vwPROSPECTS.ALT_ADDRESS_CITY    , vwPROSPECTS.ALT_ADDRESS_STATE    , vwPROSPECTS.ALT_ADDRESS_POSTALCODE    , vwPROSPECTS.ALT_ADDRESS_COUNTRY    ) as ALT_ADDRESS_HTML
     , PROSPECTS_PREDICTIONS.PROBABILITY
     , PROSPECTS_PREDICTIONS.SCORE
     , PROSPECTS_PREDICTIONS.PREDICTION
  from            vwPROSPECTS
  left outer join PROSPECTS
               on PROSPECTS.ID = vwPROSPECTS.ID
  left outer join PROSPECTS_PREDICTIONS
               on PROSPECTS_PREDICTIONS.PROSPECT_ID = vwPROSPECTS.ID
              and PROSPECTS_PREDICTIONS.DELETED     = 0

GO

Grant Select on dbo.vwPROSPECTS_Edit to public;
GO



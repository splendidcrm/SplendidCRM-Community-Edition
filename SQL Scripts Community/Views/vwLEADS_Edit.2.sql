if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwLEADS_Edit')
	Drop View dbo.vwLEADS_Edit;
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
-- 07/27/2006 Paul.  LEAD_SOURCE_DESCRIPTION was moved to the base view because it is used in several SubPanels. 
-- 11/08/2008 Paul.  Move description to base view. 
-- 08/12/2021 Paul.  Add Machine Learning prediction fields. 
Create View dbo.vwLEADS_Edit
as
select vwLEADS.*
     , dbo.fnFullAddressHtml(vwLEADS.PRIMARY_ADDRESS_STREET, vwLEADS.PRIMARY_ADDRESS_CITY, vwLEADS.PRIMARY_ADDRESS_STATE, vwLEADS.PRIMARY_ADDRESS_POSTALCODE, vwLEADS.PRIMARY_ADDRESS_COUNTRY) as PRIMARY_ADDRESS_HTML
     , dbo.fnFullAddressHtml(vwLEADS.ALT_ADDRESS_STREET    , vwLEADS.ALT_ADDRESS_CITY    , vwLEADS.ALT_ADDRESS_STATE    , vwLEADS.ALT_ADDRESS_POSTALCODE    , vwLEADS.ALT_ADDRESS_COUNTRY    ) as ALT_ADDRESS_HTML
     , LEADS_PREDICTIONS.PROBABILITY
     , LEADS_PREDICTIONS.SCORE
     , LEADS_PREDICTIONS.PREDICTION
  from            vwLEADS
  left outer join LEADS
               on LEADS.ID = vwLEADS.ID
  left outer join LEADS_PREDICTIONS
               on LEADS_PREDICTIONS.LEAD_ID     = vwLEADS.ID
              and LEADS_PREDICTIONS.DELETED     = 0

GO

Grant Select on dbo.vwLEADS_Edit to public;
GO



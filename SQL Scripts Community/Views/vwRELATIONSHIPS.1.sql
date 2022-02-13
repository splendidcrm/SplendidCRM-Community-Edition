if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwRELATIONSHIPS')
	Drop View dbo.vwRELATIONSHIPS;
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
Create View dbo.vwRELATIONSHIPS
as
select ID
     , RELATIONSHIP_NAME             
     , LHS_MODULE                    
     , LHS_TABLE                     
     , LHS_KEY                       
     , RHS_MODULE                    
     , RHS_TABLE                     
     , RHS_KEY                       
     , JOIN_TABLE                    
     , JOIN_KEY_LHS                  
     , JOIN_KEY_RHS                  
     , RELATIONSHIP_TYPE             
     , RELATIONSHIP_ROLE_COLUMN      
     , RELATIONSHIP_ROLE_COLUMN_VALUE
     , REVERSE                       
  from RELATIONSHIPS
 where DELETED = 0

GO

Grant Select on dbo.vwRELATIONSHIPS to public;
GO



if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'fnTERMINOLOGY_ConvertToTerm' and ROUTINE_TYPE = 'FUNCTION')
	Drop Function dbo.fnTERMINOLOGY_ConvertToTerm;
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
-- 12/29/2009 Paul.  Field name might be just Postalcode, so remove the leading space. 
Create Function dbo.fnTERMINOLOGY_ConvertToTerm(@COLUMN_NAME nvarchar(255))
returns nvarchar(255)
as
  begin
	declare @CUSTOM_NAME  nvarchar(255);
	declare @CurrentPosR  int;
	declare @NextPosR     int;
	set @CUSTOM_NAME = lower(@COLUMN_NAME);
	set @CUSTOM_NAME = upper(left(@CUSTOM_NAME, 1)) + substring(@CUSTOM_NAME, 2, len(@COLUMN_NAME));

	set @CurrentPosR = 1;
	while charindex('_', @CUSTOM_NAME,  @CurrentPosR) > 0 begin -- do
		set @NextPosR = charindex('_', @CUSTOM_NAME,  @CurrentPosR);
		set @CUSTOM_NAME = left(@CUSTOM_NAME, @NextPosR-1) + ' ' + upper(substring(@CUSTOM_NAME, @NextPosR+1, 1)) + substring(@CUSTOM_NAME, @NextPosR+2, len(@COLUMN_NAME));
		set @CurrentPosR = @NextPosR+1;
	end -- while;
	if @CUSTOM_NAME = 'Id' begin -- then
		set @CUSTOM_NAME = 'ID';
	end else if @CUSTOM_NAME = 'Id C' begin -- then
		set @CUSTOM_NAME = 'ID_C';
	end else if right(@CUSTOM_NAME, 3) = ' Id' begin -- then
		set @CUSTOM_NAME = left(@CUSTOM_NAME, len(@CUSTOM_NAME)-3) + ' ID';
	end else if right(@CUSTOM_NAME, 4) = ' Utc' begin -- then
		set @CUSTOM_NAME = left(@CUSTOM_NAME, len(@CUSTOM_NAME)-4) + ' UTC';
	end else if right(@CUSTOM_NAME, 4) = ' Url' begin -- then
		set @CUSTOM_NAME = left(@CUSTOM_NAME, len(@CUSTOM_NAME)-4) + ' URL';
	end else if right(@CUSTOM_NAME, 5) = ' Urls' begin -- then
		set @CUSTOM_NAME = left(@CUSTOM_NAME, len(@CUSTOM_NAME)-5) + ' URLs';
	end else if right(@CUSTOM_NAME, 5) = ' Html' begin -- then
		set @CUSTOM_NAME = left(@CUSTOM_NAME, len(@CUSTOM_NAME)-5);
	end else if right(@CUSTOM_NAME, 10) = 'Postalcode' begin -- then
		set @CUSTOM_NAME = left(@CUSTOM_NAME, len(@CUSTOM_NAME)-10) + 'Postal Code';
	end else if right(@CUSTOM_NAME, 8) = 'Usdollar' begin -- then
		set @CUSTOM_NAME = left(@CUSTOM_NAME, len(@CUSTOM_NAME)-8) + 'US Dollar';
	end else begin
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'CampaignLog'           , 'Campaign Log'            );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'CampaignTracker'       , 'Campaign Tracker'        );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'ContractType'          , 'Contract Type'           );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'CreditCard'            , 'Credit Card'             );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'EmailMan'              , 'Email Manager'           );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'EmailMarketing'        , 'Email Marketing'         );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'EmailTemplate'         , 'Email Template'          );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'iFrame'                , 'My Portal'               );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'InboundEmail'          , 'Inbound Email'           );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'KBDocument'            , 'Knowledgebase Document'  );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'KBTag'                 , 'Knowledgebase Tag'       );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'ProductCategories'     , 'Product Categories'      );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'ProductTemplates'      , 'Product Catalog'         );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'ProductType'           , 'Product Type'            );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'ProjectTask'           , 'Project Task'            );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'ProspectList'          , 'Prospect List'           );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'Prospect'              , 'Target'                  );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'SystemLog'             , 'System Log'              );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'TaxRate'               , 'Tax Rate'                );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'TeamNotice'            , 'Team Notice'             );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'UserLogin'             , 'User Login'              );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, ' List List'            , ' Lists'                  );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'ACLRoles'              , 'ACL Roles'               );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'ForumTopics'           , 'Forum Topics'            );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'SavedSearch'           , 'Saved Search'            );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'DynamicLayout'         , 'Dynamic Layout'          );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'QuotesLineItems'       , 'Quotes Line Items'       );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'SimpleStorage'         , 'Simple Storage'          );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'FlexiblePayments'      , 'Flexible Payments'       );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'SimpleStorage'         , 'Simple Storage'          );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'OrdersLineItems'       , 'Orders Line Items'       );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'InvoicesLineItems'     , 'Invoices Line Items'     );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'WorkflowTriggerShells' , 'Workflow Conditions'     );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'WorkflowActionShells'  , 'Workflow Actions'        );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'WorkflowAlertShells'   , 'Workflow Alerts'         );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'WorkflowAlertTemplates', 'Workflow Alert Templates');
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'DynamicButtons'        , 'Dynamic Buttons'         );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'EditCustomFields'      , 'Edit Custom Fields'      );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'PaymentGateway'        , 'Payment Gateway'         );
		set @CUSTOM_NAME = replace(@CUSTOM_NAME, 'FieldValidators'       , 'Field Validators'        );
	end -- if;
	return @CUSTOM_NAME;
  end
GO

Grant Execute on dbo.fnTERMINOLOGY_ConvertToTerm to public
GO


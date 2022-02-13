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
-- Drop Table dbo.PROSPECTS_PREDICTIONS;
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'PROSPECTS_PREDICTIONS' and TABLE_TYPE = 'BASE TABLE')
  begin
	print 'Create Table dbo.PROSPECTS_PREDICTIONS';
	Create Table dbo.PROSPECTS_PREDICTIONS
		( ID                                 uniqueidentifier not null default(newid()) constraint PK_PROSPECTS_PREDICTIONS primary key
		, DELETED                            bit not null default(0)
		, CREATED_BY                         uniqueidentifier null
		, DATE_ENTERED                       datetime not null default(getdate())
		, MODIFIED_USER_ID                   uniqueidentifier null
		, DATE_MODIFIED                      datetime not null default(getdate())
		, DATE_MODIFIED_UTC                  datetime null default(getutcdate())

		, PROSPECT_ID                        uniqueidentifier not null
		, MACHINE_LEARNING_MODEL_ID          uniqueidentifier not null
		, PROBABILITY                        float null
		, SCORE                              float null
		, PREDICTED_LABEL                    bit null
		, PREDICTION                         nvarchar(50) null
		)

	create index IDX_PROSPECTS_PREDICTIONS_PROSPECT_ID on dbo.PROSPECTS_PREDICTIONS (PROSPECT_ID, DELETED) include (PROBABILITY, SCORE, PREDICTION)
  end
GO



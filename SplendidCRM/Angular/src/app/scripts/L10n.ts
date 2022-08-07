/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import { Injectable             } from '@angular/core'                      ;
import { SplendidCacheService   } from '../scripts/SplendidCache'           ;
import Sql                        from '../scripts/Sql'                     ;

@Injectable({
	providedIn: 'root'
})
export class L10nService
{
	constructor(protected SplendidCache: SplendidCacheService)
	{
	}

	public GetList(sLIST_NAME: string)
	{
		return this.SplendidCache.TerminologyList(sLIST_NAME);
	}

	// 02/22/2013 Paul.  We need a way to get the list values, such as month names. 
	public GetListTerms(sLIST_NAME: string)
	{
		var arrTerms = new Array();
		var arrList  = this.SplendidCache.TerminologyList(sLIST_NAME);
		if ( arrList != null )
		{
			for ( var i = 0; i < arrList.length; i++ )
			{
				var sEntryName = '.' + sLIST_NAME + '.' + arrList[i];
				var sTerm = this.SplendidCache.Terminology(sEntryName);
				if ( sTerm == null )
					sTerm = '';
				arrTerms.push(sTerm);
			}
		}
		return arrTerms;
	}

	public Term(sEntryName: string)
	{
		try
		{
			var sTerm = this.SplendidCache.Terminology(sEntryName);
			if ( sTerm == null )
			{
				if ( sEntryName != '+' && this.SplendidCache.IsInitialized )
				{
					console.log('Term not found: ' + sEntryName);
				}
				return sEntryName;
			}
			return sTerm;
		}
		catch(error)
		{
			// 12/31/2017 Paul.  Change from alert to error. 
			console.error(this.constructor.name + '.Term ' + sEntryName, error);
		}
		return sEntryName;
	}

	// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
	public ListTerm(sLIST_NAME: string, sNAME: string)
	{
		// 06/19/2020 Paul.  L10n.Term() function to return empty string if name is empty. 
		// 07/12/2021 Paul.  There are some lists that have NULL as the first item. (survey_question_validation, bpmn_duration_units, dom_sms_opt_in_search, saved_reports_dom). 
		// 07/12/2021 Paul.  Not ready to make a breaking change at this time.  Instead, just correct at location of use. 
		if ( Sql.IsEmptyString(sNAME) )
			return '';
		let sEntryName: string = '.' + sLIST_NAME + '.' + Sql.ToString(sNAME);
		// 07/14/2019 Paul.  SQL Server returns booleans as 1 and 0, but the web server is returning true/false.  Convert back. 
		if ( typeof sNAME == 'boolean' )
		{
			sEntryName = '.' + sLIST_NAME + '.' + (sNAME ? '1' : '0');
		}
		try
		{
			var sTerm = this.SplendidCache.Terminology(sEntryName);
			if ( sTerm == null )
			{
				if ( !Sql.IsEmptyString(sNAME) )
				{
					if ( this.SplendidCache.IsInitialized )
					{
						//console.log('Term not found: ' + sEntryName);
					}
					return sEntryName;
				}
				else
				{
					sTerm = '';
				}
			}
			return sTerm;
		}
		catch(error)
		{
			console.error(this.constructor.name + '.ListTerm ' + sLIST_NAME + ' ' + sNAME, error);
		}
		return sEntryName;
	}

	public BuildTermName(sModule: string, sColumnName: string)
	{
		// 05/16/2016 Paul.  Add Tags module. 
		// 08/20/2016 Paul.  PENDING_PROCESS_ID should be a global term. 
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
		// 07/18/2018 Paul.  Add LBL_ARCHIVE_BY. 
		let sTERM_NAME: string = '';
		if (  sColumnName == 'ID'              
		   || sColumnName == 'DELETED'         
		   || sColumnName == 'CREATED_BY'      
		   || sColumnName == 'CREATED_BY_ID'   
		   || sColumnName == 'CREATED_BY_NAME' 
		   || sColumnName == 'DATE_ENTERED'    
		   || sColumnName == 'MODIFIED_USER_ID'
		   || sColumnName == 'DATE_MODIFIED'   
		   || sColumnName == 'DATE_MODIFIED_UTC'
		   || sColumnName == 'MODIFIED_BY'     
		   || sColumnName == 'MODIFIED_USER_ID'  
		   || sColumnName == 'MODIFIED_BY_NAME'
		   || sColumnName == 'ASSIGNED_USER_ID'
		   || sColumnName == 'ASSIGNED_TO'     
		   || sColumnName == 'ASSIGNED_TO_NAME'
		   || sColumnName == 'TEAM_ID'         
		   || sColumnName == 'TEAM_NAME'       
		   || sColumnName == 'TEAM_SET_ID'     
		   || sColumnName == 'TEAM_SET_NAME'   
		   || sColumnName == 'TEAM_SET_LIST'   
		   || sColumnName == 'ASSIGNED_SET_ID'  
		   || sColumnName == 'ASSIGNED_SET_NAME'
		   || sColumnName == 'ASSIGNED_SET_LIST'
		   || sColumnName == 'ID_C'            
		   || sColumnName == 'AUDIT_ID'        
		   || sColumnName == 'AUDIT_ACTION'    
		   || sColumnName == 'AUDIT_DATE'      
		   || sColumnName == 'AUDIT_COLUMNS'   
		   || sColumnName == 'AUDIT_TABLE'     
		   || sColumnName == 'AUDIT_TOKEN'     
		   || sColumnName == 'LAST_ACTIVITY_DATE'
		   || sColumnName == 'TAG_SET_NAME'    
		   || sColumnName == 'PENDING_PROCESS_ID'
		   || sColumnName == 'ARCHIVE_BY'      
		   || sColumnName == 'ARCHIVE_BY_NAME' 
		   || sColumnName == 'ARCHIVE_DATE_UTC'
		   || sColumnName == 'ARCHIVE_USER_ID' 
		   || sColumnName == 'ARCHIVE_VIEW'    
			)
		{
			sTERM_NAME = '.LBL_' + sColumnName;
		}
		else
		{
			sTERM_NAME = sModule + '.LBL_' + sColumnName;
		}
		return sTERM_NAME;
	}

	public TableColumnName(sModule: string, sColumnName: string)
	{
		try
		{
			let sTERM_NAME = this.BuildTermName(sModule, sColumnName);
			if ( this.SplendidCache.Terminology(sTERM_NAME) != null )
				sColumnName = this.SplendidCache.Terminology(sTERM_NAME);
			return sColumnName;
		}
		catch(error)
		{
			console.error(this.constructor.name + '.TableColumnName ' + sModule + ' ' + sColumnName, error);
		}
		return sColumnName;
	}
}

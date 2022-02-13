

-- 12/04/2005 Paul.  Create Admin user with password of admin. 
-- Having a well-known password should not be an issue as most customers are expected to use NTLM. 
-- 04/21/2006 Paul.  IS_GROUP was added in SugarCRM 4.0.
-- 09/13/2010 Paul.  Add values for default parameters for EffiProz. 
-- 07/08/2011 Paul.  Add values for default parameters for EffiProz. 
-- 11/09/2012 Paul.  Format the procedure to identify procedure parameters. 
-- 03/22/2013 Paul.  Admin might have a different ID. 
-- 11/16/2013 Paul.  Add the new fields. Set default theme to Atlantic. 
-- 07/25/2015 Paul.  Set default theme to Seven. 
-- 09/03/2017 Paul.  Add nulls for, PICTURE and MAIL_ fields. 
-- 01/21/2018 Paul.  Leave THEME blank so that the default team will be used. 
if not exists(select * from USERS where ID = '00000000-0000-0000-0000-000000000001' or USER_NAME = 'admin') begin -- then
	print 'USERS admin';
/* -- #if IBM_DB2
	exec dbo.spUSERS_Update
		  in_USER_ID                             -- ID
		, '00000000-0000-0000-0000-000000000001' -- MODIFIED_USER_ID
		, 'admin'         -- USER_NAME                
		, null            -- FIRST_NAME               
		, 'Administrator' -- LAST_NAME                
		, null            -- REPORTS_TO_ID            
		, 1               -- IS_ADMIN                 
		, 1               -- RECEIVE_NOTIFICATIONS    
		, null            -- DESCRIPTION              
		, 'Administrator' -- TITLE                    
		, null            -- DEPARTMENT               
		, null            -- PHONE_HOME               
		, null            -- PHONE_MOBILE             
		, null            -- PHONE_WORK               
		, null            -- PHONE_OTHER              
		, null            -- PHONE_FAX                
		, null            -- EMAIL1                   
		, null            -- EMAIL2                   
		, 'Active'        -- STATUS                   
		, null            -- ADDRESS_STREET           
		, null            -- ADDRESS_CITY             
		, null            -- ADDRESS_STATE            
		, null            -- ADDRESS_POSTALCODE       
		, null            -- ADDRESS_COUNTRY          
		, null            -- USER_PREFERENCES         
		, 0               -- PORTAL_ONLY              
		, null            -- EMPLOYEE_STATUS          
		, null            -- MESSENGER_ID             
		, null            -- MESSENGER_TYPE           
		, null            -- PARENT_TYPE              
		, null            -- PARENT_ID                
		, null            -- IS_GROUP                 
		, null            -- DEFAULT_TEAM             
		, null            -- IS_ADMIN_DELEGATE        
		, null            -- MAIL_SMTPUSER            
		, null            -- MAIL_SMTPPASS            
		, null            -- SYSTEM_GENERATED_PASSWORD
		, null            -- GOOGLEAPPS_SYNC_CONTACTS 
		, null            -- GOOGLEAPPS_SYNC_CALENDAR 
		, null            -- GOOGLEAPPS_USERNAME      
		, null            -- GOOGLEAPPS_PASSWORD      
		, null            -- FACEBOOK_ID              
		, null            -- ICLOUD_SYNC_CONTACTS     
		, null            -- ICLOUD_SYNC_CALENDAR     
		, null            -- ICLOUD_USERNAME          
		, null            -- ICLOUD_PASSWORD          
		, null            -- THEME                    
		, null            -- DATE_FORMAT              
		, null            -- TIME_FORMAT              
		, null            -- LANG                     
		, null            -- CURRENCY_ID              
		, null            -- TIMEZONE_ID              
		, null            -- SAVE_QUERY               
		, null            -- GROUP_TABS               
		, null            -- SUBPANEL_TABS            
		, null            -- EXTENSION                
		, null            -- SMS_OPT_IN               
		, null            -- PICTURE          
		, null            -- MAIL_SMTPSERVER  
		, null            -- MAIL_SMTPPORT    
		, null            -- MAIL_SMTPAUTH_REQ
		, null            -- MAIL_SMTPSSL     
		, null            -- MAIL_SENDTYPE    
		;
-- #endif IBM_DB2 */
/* -- #if Oracle
	exec dbo.spUSERS_Update
		  in_USER_ID                             -- ID
		, '00000000-0000-0000-0000-000000000001' -- MODIFIED_USER_ID
		, 'admin'         -- USER_NAME                
		, null            -- FIRST_NAME               
		, 'Administrator' -- LAST_NAME                
		, null            -- REPORTS_TO_ID            
		, 1               -- IS_ADMIN                 
		, 1               -- RECEIVE_NOTIFICATIONS    
		, null            -- DESCRIPTION              
		, 'Administrator' -- TITLE                    
		, null            -- DEPARTMENT               
		, null            -- PHONE_HOME               
		, null            -- PHONE_MOBILE             
		, null            -- PHONE_WORK               
		, null            -- PHONE_OTHER              
		, null            -- PHONE_FAX                
		, null            -- EMAIL1                   
		, null            -- EMAIL2                   
		, 'Active'        -- STATUS                   
		, null            -- ADDRESS_STREET           
		, null            -- ADDRESS_CITY             
		, null            -- ADDRESS_STATE            
		, null            -- ADDRESS_POSTALCODE       
		, null            -- ADDRESS_COUNTRY          
		, null            -- USER_PREFERENCES         
		, 0               -- PORTAL_ONLY              
		, null            -- EMPLOYEE_STATUS          
		, null            -- MESSENGER_ID             
		, null            -- MESSENGER_TYPE           
		, null            -- PARENT_TYPE              
		, null            -- PARENT_ID                
		, null            -- IS_GROUP                 
		, null            -- DEFAULT_TEAM             
		, null            -- IS_ADMIN_DELEGATE        
		, null            -- MAIL_SMTPUSER            
		, null            -- MAIL_SMTPPASS            
		, null            -- SYSTEM_GENERATED_PASSWORD
		, null            -- GOOGLEAPPS_SYNC_CONTACTS 
		, null            -- GOOGLEAPPS_SYNC_CALENDAR 
		, null            -- GOOGLEAPPS_USERNAME      
		, null            -- GOOGLEAPPS_PASSWORD      
		, null            -- FACEBOOK_ID              
		, null            -- ICLOUD_SYNC_CONTACTS     
		, null            -- ICLOUD_SYNC_CALENDAR     
		, null            -- ICLOUD_USERNAME          
		, null            -- ICLOUD_PASSWORD          
		, null            -- THEME                    
		, null            -- DATE_FORMAT              
		, null            -- TIME_FORMAT              
		, null            -- LANG                     
		, null            -- CURRENCY_ID              
		, null            -- TIMEZONE_ID              
		, null            -- SAVE_QUERY               
		, null            -- GROUP_TABS               
		, null            -- SUBPANEL_TABS            
		, null            -- EXTENSION                
		, null            -- SMS_OPT_IN               
		, null            -- PICTURE          
		, null            -- MAIL_SMTPSERVER  
		, null            -- MAIL_SMTPPORT    
		, null            -- MAIL_SMTPAUTH_REQ
		, null            -- MAIL_SMTPSSL     
		, null            -- MAIL_SENDTYPE    
		;
-- #endif Oracle */
-- #if SQL_Server /*
	exec dbo.spUSERS_Update
		  '00000000-0000-0000-0000-000000000001' -- ID
		, '00000000-0000-0000-0000-000000000001' -- MODIFIED_USER_ID
		, 'admin'         -- USER_NAME                
		, null            -- FIRST_NAME               
		, 'Administrator' -- LAST_NAME                
		, null            -- REPORTS_TO_ID            
		, 1               -- IS_ADMIN                 
		, 1               -- RECEIVE_NOTIFICATIONS    
		, null            -- DESCRIPTION              
		, 'Administrator' -- TITLE                    
		, null            -- DEPARTMENT               
		, null            -- PHONE_HOME               
		, null            -- PHONE_MOBILE             
		, null            -- PHONE_WORK               
		, null            -- PHONE_OTHER              
		, null            -- PHONE_FAX                
		, null            -- EMAIL1                   
		, null            -- EMAIL2                   
		, 'Active'        -- STATUS                   
		, null            -- ADDRESS_STREET           
		, null            -- ADDRESS_CITY             
		, null            -- ADDRESS_STATE            
		, null            -- ADDRESS_POSTALCODE       
		, null            -- ADDRESS_COUNTRY          
		, null            -- USER_PREFERENCES         
		, 0               -- PORTAL_ONLY              
		, null            -- EMPLOYEE_STATUS          
		, null            -- MESSENGER_ID             
		, null            -- MESSENGER_TYPE           
		, null            -- PARENT_TYPE              
		, null            -- PARENT_ID                
		, null            -- IS_GROUP                 
		, null            -- DEFAULT_TEAM             
		, null            -- IS_ADMIN_DELEGATE        
		, null            -- MAIL_SMTPUSER            
		, null            -- MAIL_SMTPPASS            
		, null            -- SYSTEM_GENERATED_PASSWORD
		, null            -- GOOGLEAPPS_SYNC_CONTACTS 
		, null            -- GOOGLEAPPS_SYNC_CALENDAR 
		, null            -- GOOGLEAPPS_USERNAME      
		, null            -- GOOGLEAPPS_PASSWORD      
		, null            -- FACEBOOK_ID              
		, null            -- ICLOUD_SYNC_CONTACTS     
		, null            -- ICLOUD_SYNC_CALENDAR     
		, null            -- ICLOUD_USERNAME          
		, null            -- ICLOUD_PASSWORD          
		, null            -- THEME                    
		, null            -- DATE_FORMAT              
		, null            -- TIME_FORMAT              
		, null            -- LANG                     
		, null            -- CURRENCY_ID              
		, null            -- TIMEZONE_ID              
		, null            -- SAVE_QUERY               
		, null            -- GROUP_TABS               
		, null            -- SUBPANEL_TABS            
		, null            -- EXTENSION                
		, null            -- SMS_OPT_IN               
		, null            -- PICTURE          
		, null            -- MAIL_SMTPSERVER  
		, null            -- MAIL_SMTPPORT    
		, null            -- MAIL_SMTPAUTH_REQ
		, null            -- MAIL_SMTPSSL     
		, null            -- MAIL_SENDTYPE    
		;
-- #endif SQL_Server */
	exec dbo.spUSERS_PasswordUpdate '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '21232f297a57a5a743894a0e4a801fc3';
end -- if;
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

call dbo.spUSERS_admin()
/

call dbo.spSqlDropProcedure('spUSERS_admin')
/

-- #endif IBM_DB2 */


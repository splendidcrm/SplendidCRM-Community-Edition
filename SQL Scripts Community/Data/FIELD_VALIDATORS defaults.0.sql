

print 'FIELD_VALIDATORS Defaults';
GO

set nocount on;
GO

-- http://www.regexlib.com/
-- Expression :  ^(?:(?:[\+]?(?<CountryCode>[\d]{1,3}(?:[ ]+|[\-.])))?[(]?(?<AreaCode>[\d]{3})[\-/)]?(?:[ ]+)?)?(?<Number>[a-zA-Z2-9][a-zA-Z0-9 \-.]{6,})(?:(?:[ ]+|[xX]|(i:ext[\.]?)){1,2}(?<Ext>[\d]{1,5}))?$
-- Description:  This allows the formatting of most phone numbers.
-- Matches    :  [1-800-DISCOVER], [(610) 310-5555 x5555], [533-1123]
-- Non-Matches:  [1 533-1123], [553334], [66/12343]
-- exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'Phone Number', '^(?:(?:[\+]?(?<CountryCode>[\d]{1,3}(?:[ ]+|[\-.])))?[(]?(?<AreaCode>[\d]{3})[\-/)]?(?:[ ]+)?)?(?<Number>[a-zA-Z2-9][a-zA-Z0-9 \-.]{6,})(?:(?:[ ]+|[xX]|(i:ext[\.]?)){1,2}(?<Ext>[\d]{1,5}))?$';

-- Expression :  ^((?:(?:[\+]?(?<CountryCode>[\d]{1,3}(?:[ ]+|[\-.])))?[(]?(?<AreaCode>\d{1,3})[\-/)]?(?:[ ]+)?)?(?<Number>[a-zA-Z1-9][a-zA-Z0-9 \-.]{6,}))?(?:(?:[ ]+|[xX]|(i:ext[\.]?)){0,2}(?<Ext>[\d]{1,5}))?$
-- Description:  Modified from above making the following updates:
--               - Area Code can be 1 number in australia if country code is specified. Ie '+61 8 9300 0000' will now validate
--               - China (I think it is) has numbers starting with 1, previously only accepted numbers starting 3-9
--               - 1-5 numbers will be validated as a extension, allowing phone numbers such as 115
-- Matches    :  [+61 8 9300 0000] [115] 
exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'Phone Number', '^((?:(?:[\+]?(?<CountryCode>[\d]{1,3}(?:[ ]+|[\-.])))?[(]?(?<AreaCode>\d{1,3})[\-/)]?(?:[ ]+)?)?(?<Number>[a-zA-Z1-9][a-zA-Z0-9 \-.]{6,}))?(?:(?:[ ]+|[xX]|(i:ext[\.]?)){0,2}(?<Ext>[\d]{1,5}))?$';

-- http://www.regexlib.com/
-- Expression :  ^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$
-- Description:  The most complete email validation routine I could come up with. It verifies that: - Only letters, numbers and email acceptable symbols (+, _, -, .) are allowed - No two different symbols may follow each other - Cannot begin with a symbol - Ending domain ...
-- Matches    :  [g_s+gav@com.com], [gav@gav.com], [jim@jim.c.dc.ca]
-- Non-Matches:  [gs_.gs@com.com], [gav@gav.c], [jim@--c.ca]
-- 01/26/2020 Paul.  Maximum top level domain according to RFC 1034 is 64 characters. 
exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'Email Address', '^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,63}$';
if exists(select * from FIELD_VALIDATORS where NAME = 'Email Address' and REGULAR_EXPRESSION like '%.[[]a-zA-Z]{2,6}$') begin -- then
	update FIELD_VALIDATORS
	   set REGULAR_EXPRESSION = '^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,63}$'
	     , DATE_MODIFIED      = getdate()
	     , DATE_MODIFIED_UTC  = getutcdate()
	 where NAME               = 'Email Address'
	   and REGULAR_EXPRESSION like '%.[[]a-zA-Z]{2,6}$'
end -- if;

-- http://www.regexlib.com/
-- Expression :  (^\d*\.?\d*[0-9]+\d*$)|(^[0-9]+\d*\.\d*$)
-- Description:  This matches all positive decimal values. There was one here already which claimed to but would fail on value 0.00 which is positive AFAIK...  
-- Matches    :  [0.00], [1.23], [4.56]
-- Non-Matches:  [-1.03], [-0.01], [-0.00]
exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'Positive Decimal', '(^\d*\.?\d*[0-9]+\d*$)|(^[0-9]+\d*\.\d*$)';

-- 08/11/2014 Paul.  Positive Decimal with Commas
-- http://www.regexlib.com/
-- Expression :  (^(((\d{1,3})(,\d{3})*)|(\d+))(.\d+)?$)
-- Description:  validates numbers, with or without decimal places, and comma 1000 separators.
-- Matches    :  [9999999], [99999.99999], [99,999,999.9999]
-- Non-Matches:  [9999.], [9,99,99999.999], [999.9999.9999]
exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'Positive Decimal with Commas', '(^(((\d{1,3})(,\d{3})*)|(\d+))(.\d+)?$)';

-- http://www.regexlib.com/
-- Expression :  ^http\://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$
-- Description:  Verifies URLs. Checks for the leading protocol, a good looking domain (two or three letter TLD; no invalid characters in domain) and a somwhat reasonable file path.
-- Matches    :  http://psychopop.org | http://www.edsroom.com/newUser.asp | http://unpleasant.jarrin.net/markov/inde
-- Non-Matches:  ftp://psychopop.org | http://www.edsroom/ | http://un/pleasant.jarrin.net/markov/index.asp
exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'URL', '^http\://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$';

-- 08/05/2010 Paul.  Add integer for Release List Order. 
-- http://www.regexlib.com/
-- Expression :  ^\d*$  (^\d+$ is similar but would not allow blank strings)
-- Description:  Positive integer value.
-- Matches    :  [123], [10], [54]
-- Non-Matches:  [-54], [54.234], [abc]
exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'Integer', '(^\d*$)';
-- 07/06/2017 Paul.  Correct integer validator. It was previously set to be the same as the Positive Decimal validator. 
if exists(select * from FIELD_VALIDATORS where NAME = 'Integer' and REGULAR_EXPRESSION = '(^\d*\.?\d*[0-9]+\d*$)|(^[0-9]+\d*\.\d*$)' and DELETED = 0) begin -- then
	update FIELD_VALIDATORS
	   set REGULAR_EXPRESSION = '(^\d*$)'
	     , DATE_MODIFIED      = getdate()
	     , DATE_MODIFIED_UTC  = getutcdate()
	     , MODIFIED_USER_ID   = null
	 where NAME               = 'Integer'
	   and REGULAR_EXPRESSION = '(^\d*\.?\d*[0-9]+\d*$)|(^[0-9]+\d*\.\d*$)'
	   and DELETED            = 0;
end -- if;

-- 10/23/2013 Paul.  Add Twitter message length validation. 
-- http://www.informatik.uni-hamburg.de/RZ/software/perl/manual/pod/perlre.html#DESCRIPTION
-- Expression :  ^[\s\S]{1,140}$
-- Description:  Match any whitespace and any non-whitespace character. 
exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'Twitter Message', '(^[\s\S]{1,140}$)';

-- 10/26/2013 Paul.  Add Twitter track length validation. 
-- Expression :  ^[\s\S^,]{1,60}$
-- Description:  Match any whitespace and any non-whitespace character. 
exec dbo.spFIELD_VALIDATORS_InsertRegEx null, 'Twitter Track', '(^[\s\S^,]{1,60}$)';

set nocount off;
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

call dbo.spFIELD_VALIDATORS_Defaults()
/

call dbo.spSqlDropProcedure('spFIELD_VALIDATORS_Defaults')
/

-- #endif IBM_DB2 */


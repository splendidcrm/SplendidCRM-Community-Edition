

print 'LANGUAGES.2';
GO

-- 05/19/2008 Paul.  Unicode strings must be marked as such, otherwise unicode will go in as ???.
-- 05/20/2008 Paul.  The configuration wizard allows languages to be enabled, so we can default to disabling these.
-- 04/06/2010 Paul.  Add support for Farsi/Persian. 
-- 08/01/2013 Paul.  We are using Microsoft Translator instead of Google, so the supported languages have changed. 
-- http://msdn.microsoft.com/en-us/library/hh456380.aspx
exec dbo.spLANGUAGES_InsertOnly N'ar-SA'     ,  1025, 0, N'العربية (المملكة العربية السعودية)', N'Arabic (Saudi Arabia)';
exec dbo.spLANGUAGES_InsertOnly N'bg-BG'     ,  1026, 0, N'български (България)', N'Bulgarian (Bulgaria)';
exec dbo.spLANGUAGES_InsertOnly N'ca-ES'     ,  1027, 0, N'català (català)', N'Catalan (Catalan)';
exec dbo.spLANGUAGES_InsertOnly N'zh-TW'     ,  1028, 0, N'中文(繁體) (台灣)', N'Chinese (Taiwan)';
exec dbo.spLANGUAGES_InsertOnly N'zh-CN'     ,  2052, 0, N'中文(简体) (中华人民共和国)', N'Chinese (People''s Republic of China)';
exec dbo.spLANGUAGES_InsertOnly N'cs-CZ'     ,  1029, 0, N'čeština (Česká republika)', N'Czech (Czech Republic)';
exec dbo.spLANGUAGES_InsertOnly N'da-DK'     ,  1030, 0, N'dansk (Danmark)', N'Danish (Denmark)';
exec dbo.spLANGUAGES_InsertOnly N'nl-NL'     ,  1043, 0, N'Nederlands (Nederland)', N'Dutch (Netherlands)';
exec dbo.spLANGUAGES_InsertOnly N'en-US'     ,  1033, 1, N'English (United States)', N'English (United States)';
exec dbo.spLANGUAGES_InsertOnly N'en-AU'     ,  3081, 1, N'English (Australia)', N'English (Australia)';
exec dbo.spLANGUAGES_InsertOnly N'en-CA'     ,  4105, 1, N'English (Canada)', N'English (Canada)';
exec dbo.spLANGUAGES_InsertOnly N'en-GB'     ,  2057, 1, N'English (United Kingdom)', N'English (United Kingdom)';
exec dbo.spLANGUAGES_InsertOnly N'et-EE'     ,  1061, 0, N'eesti (Eesti)', N'Estonian (Estonia)';
exec dbo.spLANGUAGES_InsertOnly N'fa-IR'     ,  1065, 0, N'فارسى (ايران)', N'Persian (Iran)';
exec dbo.spLANGUAGES_InsertOnly N'fi-FI'     ,  1035, 0, N'suomi (Suomi)', N'Finnish (Finland)';
exec dbo.spLANGUAGES_InsertOnly N'fr-FR'     ,  1036, 0, N'français (France)', N'French (France)';
exec dbo.spLANGUAGES_InsertOnly N'de-DE'     ,  1031, 0, N'Deutsch (Deutschland)', N'German (Germany)';
exec dbo.spLANGUAGES_InsertOnly N'de-CH'     ,  2055, 0, N'Deutsch (Schweiz)', N'German (Switzerland)';
exec dbo.spLANGUAGES_InsertOnly N'de-AT'     ,  3079, 0, N'Deutsch (Österreich)', N'German (Austria)';
exec dbo.spLANGUAGES_InsertOnly N'el-GR'     ,  1032, 0, N'ελληνικά (Ελλάδα)', N'Greek (Greece)';
exec dbo.spLANGUAGES_InsertOnly N'he-IL'     ,  1037, 0, N'עברית (ישראל)', N'Hebrew (Israel)';
exec dbo.spLANGUAGES_InsertOnly N'hi-IN'     ,  1081, 0, N'हिंदी (भारत)', N'Hindi (India)';
exec dbo.spLANGUAGES_InsertOnly N'hu-HU'     ,  1038, 0, N'Magyar (Magyarország)', N'Hungarian (Hungary)';
exec dbo.spLANGUAGES_InsertOnly N'id-ID'     ,  1057, 0, N'Bahasa Indonesia (Indonesia)', N'Indonesian (Indonesia)';
exec dbo.spLANGUAGES_InsertOnly N'it-IT'     ,  1040, 0, N'italiano (Italia)', N'Italian (Italy)';
exec dbo.spLANGUAGES_InsertOnly N'ja-JP'     ,  1041, 0, N'日本語 (日本)', N'Japanese (Japan)';
exec dbo.spLANGUAGES_InsertOnly N'ko-KR'     ,  1042, 0, N'한국어 (대한민국)', N'Korean (Korea)';
exec dbo.spLANGUAGES_InsertOnly N'lv-LV'     ,  1062, 0, N'latviešu (Latvija)', N'Latvian (Latvia)';
exec dbo.spLANGUAGES_InsertOnly N'lt-LT'     ,  1063, 0, N'lietuvių (Lietuva)', N'Lithuanian (Lithuania)';
exec dbo.spLANGUAGES_InsertOnly N'ms-MY'     ,  1086, 0, N'Bahasa Malaysia (Malaysia)', 'Malay (Malaysia)';
exec dbo.spLANGUAGES_InsertOnly N'nb-NO'     ,  1044, 0, N'norsk (bokmål) (Norge)', N'Norwegian (Bokmål) (Norway)';
exec dbo.spLANGUAGES_InsertOnly N'nn-NO'     ,  2068, 0, N'norsk (nynorsk) (Noreg)', N'Norwegian (Nynorsk) (Norway)';
exec dbo.spLANGUAGES_InsertOnly N'pl-PL'     ,  1045, 0, N'polski (Polska)', N'Polish (Poland)';
exec dbo.spLANGUAGES_InsertOnly N'pt-PT'     ,  2070, 0, N'português (Portugal)', N'Portuguese (Portugal)';
exec dbo.spLANGUAGES_InsertOnly N'pt-BR'     ,  1046, 0, N'Português (Brasil)', N'Portuguese (Brazil)';
exec dbo.spLANGUAGES_InsertOnly N'ro-RO'     ,  1048, 0, N'română (România)', N'Romanian (Romania)';
exec dbo.spLANGUAGES_InsertOnly N'ru-RU'     ,  1049, 0, N'русский (Россия)', N'Russian (Russia)';
exec dbo.spLANGUAGES_InsertOnly N'sk-SK'     ,  1051, 0, N'slovenčina (Slovenská republika)', N'Slovak (Slovakia)';
exec dbo.spLANGUAGES_InsertOnly N'sl-SI'     ,  1060, 0, N'slovenski (Slovenija)', N'Slovenian (Slovenia)';
exec dbo.spLANGUAGES_InsertOnly N'es-ES'     ,  3082, 0, N'español (España)', N'Spanish (Spain)';
exec dbo.spLANGUAGES_InsertOnly N'es-VE'     ,  8202, 0, N'Español (Republica Bolivariana de Venezuela)', N'Spanish (Venezuela)';
exec dbo.spLANGUAGES_InsertOnly N'sv-SE'     ,  1053, 0, N'svenska (Sverige)', N'Swedish (Sweden)';
exec dbo.spLANGUAGES_InsertOnly N'th-TH'     ,  1054, 0, N'ไทย (ไทย)', N'Thai (Thailand)';
exec dbo.spLANGUAGES_InsertOnly N'tr-TR'     ,  1055, 0, N'Türkçe (Türkiye)', N'Turkish (Turkey)';
exec dbo.spLANGUAGES_InsertOnly N'uk-UA'     ,  1058, 0, N'україньска (Україна)', N'Ukrainian (Ukraine)';
exec dbo.spLANGUAGES_InsertOnly N'ur-PK'     ,  1056, 0, N'اُردو (پاکستان)', 'Urdu (Islamic Republic of Pakistan)';
exec dbo.spLANGUAGES_InsertOnly N'vi-VN'     ,  1066, 0, N'Tiếng Việt Nam (Việt Nam)', N'Vietnamese (Viet Nam)';
GO

-- 08/01/2013 Paul.  We are using Microsoft Translator instead of Google, so the supported languages have changed. 
--exec dbo.spLANGUAGES_InsertOnly N'gl-ES'     ,  1110, 0, N'galego (galego)', N'Galician (Galician)';
--exec dbo.spLANGUAGES_InsertOnly N'sq-AL'     ,  1052, 0, N'shqipe (Shqipëria)', N'Albanian (Albania)';
--if exists(select * from vwLANGUAGES where NAME = 'fil-PH') begin -- then
--	if not exists(select * from vwTERMINOLOGY where LANG = 'fil-PH') begin -- then
--		print 'LANGUAGES: Deleting fil-PH';
--		exec dbo.spLANGUAGES_Delete null, 'fil-PH';
--	end -- if;
--end -- if;
if exists(select * from vwLANGUAGES where NAME = 'gl-ES') begin -- then
	if not exists(select * from vwTERMINOLOGY where LANG = 'gl-ES') begin -- then
		print 'LANGUAGES: Deleting gl-ES';
		exec dbo.spLANGUAGES_Delete null, 'gl-ES';
	end -- if;
end -- if;
--if exists(select * from vwLANGUAGES where NAME = 'hr-HR') begin -- then
--	if not exists(select * from vwTERMINOLOGY where LANG = 'hr-HR') begin -- then
--		print 'LANGUAGES: Deleting hr-HR';
--		exec dbo.spLANGUAGES_Delete null, 'hr-HR';
--	end -- if;
--end -- if;
--if exists(select * from vwLANGUAGES where NAME = 'mt-MT') begin -- then
--	if not exists(select * from vwTERMINOLOGY where LANG = 'mt-MT') begin -- then
--		print 'LANGUAGES: Deleting mt-MT';
--		exec dbo.spLANGUAGES_Delete null, 'mt-MT';
--	end -- if;
--end -- if;
if exists(select * from vwLANGUAGES where NAME = 'sq-AL') begin -- then
	if not exists(select * from vwTERMINOLOGY where LANG = 'sq-AL') begin -- then
		print 'LANGUAGES: Deleting sq-AL';
		exec dbo.spLANGUAGES_Delete null, 'sq-AL';
	end -- if;
end -- if;
GO

-- 07/21/2017 Paul.  New languages supported by MS Translator. 
exec dbo.spLANGUAGES_InsertOnly 'af-ZA'      ,  1078, 0, 'Afrikaans (Suid-Afrika)', 'Afrikaans (South Africa)'
exec dbo.spLANGUAGES_InsertOnly 'bn-BD'      ,  2117, 0, 'বাংলা (বাংলাদেশ)', 'Bangla (Bangladesh)'
exec dbo.spLANGUAGES_InsertOnly 'bs-Latn'    ,  5146, 0, 'bosanski (Bosna i Hercegovina)', 'Bosnian (Latin, Bosnia and Herzegovina)'
exec dbo.spLANGUAGES_InsertOnly 'hr-HR'      ,  1050, 0, 'hrvatski (Hrvatska)', 'Croatian (Croatia)'
exec dbo.spLANGUAGES_InsertOnly 'fil-PH'     ,  1124, 0, 'Filipino (Pilipinas)', 'Filipino (Philippines)'
exec dbo.spLANGUAGES_InsertOnly 'sw-KE'      ,  1089, 0, 'Kiswahili (Kenya)', 'Kiswahili (Kenya)'
exec dbo.spLANGUAGES_InsertOnly 'mt-MT'      ,  1082, 0, 'Malti (Malta)', 'Maltese (Malta)'
exec dbo.spLANGUAGES_InsertOnly 'sr-Cyrl'    ,  4096, 0, 'српски (Косово)', 'Serbian (Cyrillic, Kosovo)'
exec dbo.spLANGUAGES_InsertOnly 'sr-Latn'    ,  9242, 0, 'srpski (Srbija)', 'Serbian (Latin, Serbia)'
exec dbo.spLANGUAGES_InsertOnly 'cy-GB'      ,  1106, 0, 'Cymraeg (Y Deyrnas Unedig)', 'Welsh (United Kingdom)'
-- 07/21/2017 Paul.  Unknown languages supported by MS Translator. 
-- yue, fj, ht, mww, tlh, tlh-Qaak, yua, otq, sm, ty
GO

-- 08/01/2013 Paul.  We are using Microsoft T
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

call dbo.spLANGUAGES_Defaults()
/

call dbo.spSqlDropProcedure('spLANGUAGES_Defaults')
/

-- #endif IBM_DB2 */


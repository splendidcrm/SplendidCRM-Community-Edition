

print 'TIMEZONES 2007 Updates';
GO
-- delete TIMEZONES
set nocount on;
GO

-- 02/22/2007 Paul.  2007 time zone update for Microsoft Windows operating systems
-- http://support.microsoft.com/kb/928388

-- 02/22/2007 Paul.  Only update the timezone data that has changed. This is informational as spTIMEZONES_UpdateByName has been modified to only update a record if it has changed. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+04:30) Kabul'                                            , 'Afghanistan Standard Time'      , '', 'Afghanistan Daylight Time'      , '', -270, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-09:00) Alaska'                                           , 'Alaskan Standard Time'          , '', 'Alaskan Daylight Time'          , '', 540, 0, -60, 0, 11, 1, 0, 2, 0, 0, 3, 2, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+03:00) Kuwait, Riyadh'                                   , 'Arab Standard Time'             , '', 'Arab Daylight Time'             , '', -180, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+04:00) Abu Dhabi, Muscat'                                , 'Arabian Standard Time'          , '', 'Arabian Daylight Time'          , '', -240, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+03:00) Baghdad'                                          , 'Arabic Standard Time'           , '', 'Arabic Daylight Time'           , '', -180, 0, -60, 0, 10, 1, 0, 4, 0, 0, 4, 1, 0, 3, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-04:00) Atlantic Time (Canada)'                           , 'Atlantic Standard Time'         , '', 'Atlantic Daylight Time'         , '', 240, 0, -60, 0, 11, 1, 0, 2, 0, 0, 3, 2, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+09:30) Darwin'                                           , 'AUS Central Standard Time'      , '', 'AUS Central Daylight Time'      , '', -570, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+10:00) Canberra, Melbourne, Sydney'                      , 'AUS Eastern Standard Time'      , '', 'AUS Eastern Daylight Time'      , '', -600, 0, -60, 0, 3, 5, 0, 3, 0, 0, 10, 5, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT+04:00) Baku'                                             , 'Azerbaijan Standard Time'       , '', 'Azerbaijan Daylight Time'       , '', -240, 0, -60, 0, 10, 5, 0, 5, 0, 0, 3, 5, 0, 4, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-01:00) Azores'                                           , 'Azores Standard Time'           , '', 'Azores Daylight Time'           , '', 60, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-06:00) Saskatchewan'                                     , 'Canada Central Standard Time'   , '', 'Canada Central Daylight Time'   , '', 360, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-01:00) Cape Verde Is.'                                   , 'Cape Verde Standard Time'       , '', 'Cape Verde Daylight Time'       , '', 60, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
-- 04/08/2010 Paul.  Yerevan changes in 2010. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+04:00) Yerevan'                                          , 'Caucasus Standard Time'         , '', 'Caucasus Daylight Time'         , '', -240, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+09:30) Adelaide'                                         , 'Cen. Australia Standard Time'   , '', 'Cen. Australia Daylight Time'   , '', -570, 0, -60, 0, 3, 5, 0, 3, 0, 0, 10, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-06:00) Central America'                                  , 'Central America Standard Time'  , '', 'Central America Daylight Time'  , '', 360, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+06:00) Astana, Dhaka'                                    , 'Central Asia Standard Time'     , '', 'Central Asia Daylight Time'     , '', -360, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-04:00) Manaus'                                           , 'Central Brazilian Standard Time', '', 'Central Brazilian Daylight Time', '', 240, 0, -60, 0, 2, 5, 0, 0, 0, 0, 11, 1, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague', 'Central Europe Standard Time'   , '', 'Central Europe Daylight Time'   , '', -60, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+01:00) Sarajevo, Skopje, Warsaw, Zagreb'                 , 'Central European Standard Time' , '', 'Central European Daylight Time' , '', -60, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+11:00) Magadan, Solomon Is., New Caledonia'              , 'Central Pacific Standard Time'  , '', 'Central Pacific Daylight Time'  , '', -660, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-06:00) Central Time (US & Canada)'                       , 'Central Standard Time'          , '', 'Central Daylight Time'          , '', 360, 0, -60, 0, 11, 1, 0, 2, 0, 0, 3, 2, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-06:00) Guadalajara, Mexico City, Monterrey - New'        , 'Central Standard Time (Mexico)' , '', 'Central Daylight Time (Mexico)' , '', 360, 0, -60, 0, 10, 5, 0, 2, 0, 0, 4, 1, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+08:00) Beijing, Chongqing, Hong Kong, Urumqi'            , 'China Standard Time'            , '', 'China Daylight Time'            , '', -480, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-12:00) International Date Line West'                     , 'Dateline Standard Time'         , '', 'Dateline Daylight Time'         , '', 720, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+03:00) Nairobi'                                          , 'E. Africa Standard Time'        , '', 'E. Africa Daylight Time'        , '', -180, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+10:00) Brisbane'                                         , 'E. Australia Standard Time'     , '', 'E. Australia Daylight Time'     , '', -600, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Minsk'                                            , 'E. Europe Standard Time'        , '', 'E. Europe Daylight Time'        , '', -120, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
-- 04/08/2010 Paul.  Brasilia changes in 2010. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-03:00) Brasilia'                                         , 'E. South America Standard Time' , '', 'E. South America Daylight Time' , '', 180, 0, -60, 0, 2, 5, 0, 0, 0, 0, 11, 1, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-05:00) Eastern Time (US & Canada)'                       , 'Eastern Standard Time'          , '', 'Eastern Daylight Time'          , '', 300, 0, -60, 0, 11, 1, 0, 2, 0, 0, 3, 2, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Cairo'                                            , 'Egypt Standard Time'            , '', 'Egypt Daylight Time'            , '', -120, 0, -60, 0, 9, 5, 4, 23, 59, 0, 4, 5, 4, 23, 59;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+05:00) Ekaterinburg'                                     , 'Ekaterinburg Standard Time'     , '', 'Ekaterinburg Daylight Time'     , '', -300, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+12:00) Fiji, Kamchatka, Marshall Is.'                    , 'Fiji Standard Time'             , '', 'Fiji Daylight Time'             , '', -720, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius'    , 'FLE Standard Time'              , '', 'FLE Daylight Time'              , '', -120, 0, -60, 0, 10, 5, 0, 4, 0, 0, 3, 5, 0, 3, 0;
-- 04/08/2010 Paul.  Tbilisi changes in 2010. 
-- exec dbo.spTIMEZONES_UpdateByName null, '(GMT+03:00) Tbilisi'                                          , 'Georgian Standard Time'         , '', 'Georgian Daylight Time'         , '', -180, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London', 'GMT Standard Time'              , '', 'GMT Daylight Time'              , '', 0, 0, -60, 0, 10, 5, 0, 2, 0, 0, 3, 5, 0, 1, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-03:00) Greenland'                                        , 'Greenland Standard Time'        , '', 'Greenland Daylight Time'        , '', 180, 0, -60, 0, 10, 5, 0, 2, 0, 0, 4, 1, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT) Casablanca, Monrovia, Reykjavik'                        , 'Greenwich Standard Time'        , '', 'Greenwich Daylight Time'        , '', 0, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Athens, Bucharest, Istanbul'                      , 'GTB Standard Time'              , '', 'GTB Daylight Time'              , '', -120, 0, -60, 0, 10, 5, 0, 4, 0, 0, 3, 5, 0, 3, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-10:00) Hawaii'                                           , 'Hawaiian Standard Time'         , '', 'Hawaiian Daylight Time'         , '', 600, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi'              , 'India Standard Time'            , '', 'India Daylight Time'            , '', -330, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
-- 04/08/2010 Paul.  Tehran changes in 2010. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+03:30) Tehran'                                           , 'Iran Standard Time'             , '', 'Iran Daylight Time'             , '', -210, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
-- 04/08/2010 Paul.  Jerusalem changes in 2010. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Jerusalem'                                        , 'Jerusalem Standard Time'        , '', 'Jerusalem Daylight Time'        , '', -120, 0, -60, 0, 9, 3, 0, 2, 0, 0, 3, 5, 5, 2, 0;
-- 04/08/2010 Paul.  Amman changes in 2010. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Amman'                                            , 'Jordan Standard Time'           , '', 'Jordan Daylight Time'           , '', -120, 0, -60, 0, 9, 5, 5, 1, 0, 0, 3, 5, 4, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+09:00) Seoul'                                            , 'Korea Standard Time'            , '', 'Korea Daylight Time'            , '', -540, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-06:00) Guadalajara, Mexico City, Monterrey - Old'        , 'Mexico Standard Time'           , '', 'Mexico Daylight Time'           , '', 360, 0, -60, 0, 10, 5, 0, 2, 0, 0, 4, 1, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-07:00) Chihuahua, La Paz, Mazatlan - Old'                , 'Mexico Standard Time 2'         , '', 'Mexico Daylight Time 2'         , '', 420, 0, -60, 0, 10, 5, 0, 2, 0, 0, 4, 1, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-02:00) Mid-Atlantic'                                     , 'Mid-Atlantic Standard Time'     , '', 'Mid-Atlantic Daylight Time'     , '', 120, 0, -60, 0, 9, 5, 0, 2, 0, 0, 3, 5, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Beirut'                                           , 'Middle East Standard Time'      , '', 'Middle East Daylight Time'      , '', -120, 0, -60, 0, 10, 5, 6, 23, 59, 0, 3, 5, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-03:00) Montevideo'                                       , 'Montevideo Standard Time'       , '', 'Montevideo Daylight Time'       , '', 180, 0, -60, 0, 3, 2, 0, 2, 0, 0, 10, 1, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-07:00) Mountain Time (US & Canada)'                      , 'Mountain Standard Time'         , '', 'Mountain Daylight Time'         , '', 420, 0, -60, 0, 11, 1, 0, 2, 0, 0, 3, 2, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-07:00) Chihuahua, La Paz, Mazatlan - New'                , 'Mountain Standard Time (Mexico)', '', 'Mountain Daylight Time (Mexico)', '', 420, 0, -60, 0, 10, 5, 0, 2, 0, 0, 4, 1, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT+06:30) Yangon (Rangoon)'                                 , 'Myanmar Standard Time'          , '', 'Myanmar Daylight Time'          , '', -390, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+06:00) Almaty, Novosibirsk'                              , 'N. Central Asia Standard Time'  , '', 'N. Central Asia Daylight Time'  , '', -360, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Windhoek'                                         , 'Namibia Standard Time'          , '', 'Namibia Daylight Time'          , '', -120, 0, 60, 0, 9, 1, 0, 2, 0, 0, 4, 1, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+05:45) Kathmandu'                                        , 'Nepal Standard Time'            , '', 'Nepal Daylight Time'            , '', -345, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
-- 04/08/2010 Paul.  Auckland changes in 2010. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+12:00) Auckland, Wellington'                             , 'New Zealand Standard Time'      , '', 'New Zealand Daylight Time'      , '', -720, 0, -60, 0, 3, 3, 0, 3, 0, 0, 10, 1, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-03:30) Newfoundland'                                     , 'Newfoundland Standard Time'     , '', 'Newfoundland Daylight Time'     , '', 210, 0, -60, 0, 11, 1, 0, 0, 1, 0, 3, 2, 0, 0, 1;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+08:00) Irkutsk, Ulaan Bataar'                            , 'North Asia East Standard Time'  , '', 'North Asia East Daylight Time'  , '', -480, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+07:00) Krasnoyarsk'                                      , 'North Asia Standard Time'       , '', 'North Asia Daylight Time'       , '', -420, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-04:00) Santiago'                                         , 'Pacific SA Standard Time'       , '', 'Pacific SA Daylight Time'       , '', 240, 0, -60, 0, 3, 2, 6, 23, 59, 0, 10, 2, 6, 23, 59;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT-08:00) Pacific Time (US & Canada)'                       , 'Pacific Standard Time'          , '', 'Pacific Daylight Time'          , '', 480, 0, -60, 0, 11, 1, 0, 2, 0, 0, 3, 2, 0, 2, 0;
-- 04/08/2010 Paul.  Tijuana changes in 2010. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-08:00) Tijuana, Baja California'                         , 'Pacific Standard Time (Mexico)' , '', 'Pacific Daylight Time (Mexico)' , '', 480, 0, -60, 0, 10, 5, 0, 2, 0, 0, 4, 1, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+01:00) Brussels, Copenhagen, Madrid, Paris'              , 'Romance Standard Time'          , '', 'Romance Daylight Time'          , '', -60, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+03:00) Moscow, St. Petersburg, Volgograd'                , 'Russian Standard Time'          , '', 'Russian Daylight Time'          , '', -180, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-03:00) Buenos Aires, Georgetown'                         , 'SA Eastern Standard Time'       , '', 'SA Eastern Daylight Time'       , '', 180, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-05:00) Bogota, Lima, Quito, Rio Branco'                  , 'SA Pacific Standard Time'       , '', 'SA Pacific Daylight Time'       , '', 300, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-04:00) Caracas, La Paz'                                  , 'SA Western Standard Time'       , '', 'SA Western Daylight Time'       , '', 240, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-11:00) Midway Island, Samoa'                             , 'Samoa Standard Time'            , '', 'Samoa Daylight Time'            , '', 660, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+07:00) Bangkok, Hanoi, Jakarta'                          , 'SE Asia Standard Time'          , '', 'SE Asia Daylight Time'          , '', -420, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+08:00) Kuala Lumpur, Singapore'                          , 'Malay Peninsula Standard Time'  , '', 'Malay Peninsula Daylight Time'  , '', -480, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+02:00) Harare, Pretoria'                                 , 'South Africa Standard Time'     , '', 'South Africa Daylight Time'     , '', -120, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
exec dbo.spTIMEZONES_UpdateByName null, '(GMT+05:30) Sri Jayawardenepura'                              , 'Sri Lanka Standard Time'        , '', 'Sri Lanka Daylight Time'        , '', -330, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+08:00) Taipei'                                           , 'Taipei Standard Time'           , '', 'Taipei Daylight Time'           , '', -480, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+10:00) Hobart'                                           , 'Tasmania Standard Time'         , '', 'Tasmania Daylight Time'         , '', -600, 0, -60, 0, 3, 5, 0, 3, 0, 0, 10, 1, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+09:00) Osaka, Sapporo, Tokyo'                            , 'Tokyo Standard Time'            , '', 'Tokyo Daylight Time'            , '', -540, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+13:00) Nuku''alofa'                                       , 'Tonga Standard Time'            , '', 'Tonga Daylight Time'            , '', -780, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-05:00) Indiana (East)'                                   , 'US Eastern Standard Time'       , '', 'US Eastern Daylight Time'       , '', 300, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT-07:00) Arizona'                                          , 'US Mountain Standard Time'      , '', 'US Mountain Daylight Time'      , '', 420, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+10:00) Vladivostok'                                      , 'Vladivostok Standard Time'      , '', 'Vladivostok Daylight Time'      , '', -600, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
-- 04/08/2010 Paul.  Perth changes in 2010. 
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+08:00) Perth'                                            , 'W. Australia Standard Time'     , '', 'W. Australia Daylight Time'     , '', -480, 0, -60, 0, 3, 5, 0, 3, 0, 0, 10, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+01:00) West Central Africa'                              , 'W. Central Africa Standard Time', '', 'W. Central Africa Daylight Time', '', -60, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna' , 'W. Europe Standard Time'        , '', 'W. Europe Daylight Time'        , '', -60, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+05:00) Islamabad, Karachi, Tashkent'                     , 'West Asia Standard Time'        , '', 'West Asia Daylight Time'        , '', -300, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+10:00) Guam, Port Moresby'                               , 'West Pacific Standard Time'     , '', 'West Pacific Daylight Time'     , '', -600, 0, -60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
--exec dbo.spTIMEZONES_UpdateByName null, '(GMT+09:00) Yakutsk'                                          , 'Yakutsk Standard Time'          , '', 'Yakutsk Daylight Time'          , '', -540, 0, -60, 0, 10, 5, 0, 3, 0, 0, 3, 5, 0, 2, 0;
GO


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

call dbo.spTIMEZONES_2007Updates()
/

call dbo.spSqlDropProcedure('spTIMEZONES_2007Updates')
/

-- #endif IBM_DB2 */


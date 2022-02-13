

print 'CURRENCIES defaults';
GO

set nocount on;
GO

-- http://www.id3.org/iso4217.html
-- http://www.xe.com/iso4217.php
-- http://www.xe.com/symbols.php
exec dbo.spCURRENCIES_InsertOnly 'E340202E-6291-4071-B327-A34CB4DF239B', null, N'U.S. Dollar'                        , N'$', N'USD', 1.0, N'Active';
-- 05/01/2016 Paul.  We are going to prepopulate the currency table so that we can be sure to get the supported ISO values correct. 
exec dbo.spCURRENCIES_InsertOnlyByISO N'United Arab Emirates Dirham'        , N'د.إ ', N'AED', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Afghan Afghani'                     , N'؋', N'AFN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Albanian Lek'                       , N'Lek', N'ALL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Armenian Dram'                      , N'', N'AMD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Netherlands Antillean Guilder'      , N'ƒ', N'ANG', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Angolan Kwanza'                     , N'Kz', N'AOA', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Argentine Peso'                     , N'$', N'ARS', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Australian Dollar'                  , N'$', N'AUD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Aruban Florin'                      , N'ƒ', N'AWG', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Azerbaijani Manat'                  , N'ман', N'AZN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bosnia-Herzegovina Convertible Mark', N'KM', N'BAM', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Barbadian Dollar'                   , N'$', N'BBD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bangladeshi Taka'                   , N'Tk', N'BDT', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bulgarian Lev'                      , N'лв', N'BGN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bahraini Dinar'                     , N'BD', N'BHD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Burundian Franc'                    , N'', N'BIF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bermudan Dollar'                    , N'$', N'BMD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Brunei Dollar'                      , N'$', N'BND', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bolivian Boliviano'                 , N'$b', N'BOB', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Brazilian Real'                     , N'R$', N'BRL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bahamian Dollar'                    , N'$', N'BSD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bitcoin'                            , N'', N'BTC', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Bhutanese Ngultrum'                 , N'', N'BTN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Botswanan Pula'                     , N'P', N'BWP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Belarusian Ruble'                   , N'p.', N'BYR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Belize Dollar'                      , N'BZ$', N'BZD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Canadian Dollar'                    , N'$', N'CAD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Congolese Franc'                    , N'', N'CDF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Swiss Franc'                        , N'', N'CHF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Chilean Unit of Account (UF)'       , N'', N'CLF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Chilean Peso'                       , N'$', N'CLP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Chinese Yuan'                       , N'¥', N'CNY', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Colombian Peso'                     , N'$', N'COP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Costa Rican Colón'                  , N'₡', N'CRC', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Cuban Convertible Peso'             , N'CUC$', N'CUC', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Cuban Peso'                         , N'₱', N'CUP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Cape Verdean Escudo'                , N'$', N'CVE', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Czech Republic Koruna'              , N'Kč', N'CZK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Djiboutian Franc'                   , N'', N'DJF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Danish Krone'                       , N'kr', N'DKK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Dominican Peso'                     , N'RD$', N'DOP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Algerian Dinar'                     , N'', N'DZD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Estonian Kroon'                     , N'', N'EEK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Egyptian Pound'                     , N'£', N'EGP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Eritrean Nakfa'                     , N'£', N'ERN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Ethiopian Birr'                     , N'Br', N'ETB', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Euro'                               , N'€', N'EUR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Fijian Dollar'                      , N'$', N'FJD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Falkland Islands Pound'             , N'£', N'FKP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'British Pound Sterling'             , N'£', N'GBP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Georgian Lari'                      , N'', N'GEL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Guernsey Pound'                     , N'£', N'GGP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Ghanaian Cedi'                      , N'¢', N'GHS', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Gibraltar Pound'                    , N'£', N'GIP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Gambian Dalasi'                     , N'', N'GMD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Guinean Franc'                      , N'', N'GNF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Guatemalan Quetzal'                 , N'Q', N'GTQ', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Guyanaese Dollar'                   , N'$', N'GYD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Hong Kong Dollar'                   , N'$', N'HKD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Honduran Lempira'                   , N'L', N'HNL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Croatian Kuna'                      , N'kn', N'HRK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Haitian Gourde'                     , N'G', N'HTG', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Hungarian Forint'                   , N'Ft', N'HUF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Indonesian Rupiah'                  , N'Rp', N'IDR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Israeli New Sheqel'                 , N'₪', N'ILS', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Manx pound'                         , N'£', N'IMP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Indian Rupee'                       , N'₹', N'INR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Iraqi Dinar'                        , N'د.ع', N'IQD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Iranian Rial'                       , N'﷼', N'IRR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Icelandic Króna'                    , N'kr', N'ISK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Jersey Pound'                       , N'£', N'JEP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Jamaican Dollar'                    , N'J$', N'JMD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Jordanian Dinar'                    , N'', N'JOD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Japanese Yen'                       , N'¥', N'JPY', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Kenyan Shilling'                    , N'KSh', N'KES', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Kyrgystani Som'                     , N'лв', N'KGS', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Cambodian Riel'                     , N'៛', N'KHR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Comorian Franc'                     , N'', N'KMF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'North Korean Won'                   , N'₩', N'KPW', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'South Korean Won'                   , N'₩', N'KRW', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Kuwaiti Dinar'                      , N'ك', N'KWD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Cayman Islands Dollar'              , N'$', N'KYD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Kazakhstani Tenge'                  , N'лв', N'KZT', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Laotian Kip'                        , N'₭', N'LAK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Lebanese Pound'                     , N'£', N'LBP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Sri Lankan Rupee'                   , N'₨', N'LKR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Liberian Dollar'                    , N'$', N'LRD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Lesotho Loti'                       , N'', N'LSL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Lithuanian Litas'                   , N'', N'LTL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Latvian Lats'                       , N'', N'LVL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Libyan Dinar'                       , N'LD', N'LYD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Moroccan Dirham'                    , N'', N'MAD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Moldovan Leu'                       , N'', N'MDL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Malagasy Ariary'                    , N'Ar', N'MGA', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Macedonian Denar'                   , N'ден', N'MKD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Myanma Kyat'                        , N'K', N'MMK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Mongolian Tugrik'                   , N'₮', N'MNT', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Macanese Pataca'                    , N'MOP$', N'MOP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Mauritanian Ouguiya'                , N'', N'MRO', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Mauritian Rupee'                    , N'₨', N'MUR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Maldivian Rufiyaa'                  , N'', N'MVR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Malawian Kwacha'                    , N'MK', N'MWK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Mexican Peso'                       , N'$', N'MXN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Malaysian Ringgit'                  , N'RM', N'MYR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Mozambican Metical'                 , N'MT', N'MZN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Namibian Dollar'                    , N'$', N'NAD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Nigerian Naira'                     , N'₦', N'NGN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Nicaraguan Córdoba'                 , N'C$', N'NIO', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Norwegian Krone'                    , N'kr', N'NOK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Nepalese Rupee'                     , N'₨', N'NPR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'New Zealand Dollar'                 , N'$', N'NZD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Omani Rial'                         , N'﷼', N'OMR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Panamanian Balboa'                  , N'B/.', N'PAB', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Peruvian Nuevo Sol'                 , N'S/.', N'PEN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Papua New Guinean Kina'             , N'K', N'PGK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Philippine Peso'                    , N'₱', N'PHP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Pakistani Rupee'                    , N'₨', N'PKR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Polish Zloty'                       , N'zł', N'PLN', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Paraguayan Guarani'                 , N'Gs', N'PYG', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Qatari Rial'                        , N'﷼', N'QAR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Romanian Leu'                       , N'lei', N'RON', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Serbian Dinar'                      , N'Дин.', N'RSD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Russian Ruble'                      , N'руб', N'RUB', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Rwandan Franc'                      , N'', N'RWF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Saudi Riyal'                        , N'﷼', N'SAR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Solomon Islands Dollar'             , N'$', N'SBD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Seychellois Rupee'                  , N'₨', N'SCR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Sudanese Pound'                     , N'', N'SDG', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Swedish Krona'                      , N'kr', N'SEK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Singapore Dollar'                   , N'$', N'SGD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Saint Helena Pound'                 , N'£', N'SHP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Sierra Leonean Leone'               , N'Le', N'SLL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Somali Shilling'                    , N'S', N'SOS', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Surinamese Dollar'                  , N'$', N'SRD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'São Tomé and Príncipe Dobra'        , N'', N'STD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Salvadoran Colón'                   , N'$', N'SVC', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Syrian Pound'                       , N'£', N'SYP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Swazi Lilangeni'                    , N'', N'SZL', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Thai Baht'                          , N'฿', N'THB', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Tajikistani Somoni'                 , N'', N'TJS', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Turkmenistani Manat'                , N'', N'TMT', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Tunisian Dinar'                     , N'', N'TND', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Tongan Pa?anga'                     , N'T$', N'TOP', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Turkish Lira'                       , N'', N'TRY', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Trinidad and Tobago Dollar'         , N'TT$', N'TTD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'New Taiwan Dollar'                  , N'NT$', N'TWD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Tanzanian Shilling'                 , N'', N'TZS', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Ukrainian Hryvnia'                  , N'₴', N'UAH', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Ugandan Shilling'                   , N'', N'UGX', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Uruguayan Peso'                     , N'$U', N'UYU', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Uzbekistan Som'                     , N'лв', N'UZS', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Venezuelan Bolívar Fuerte'          , N'Bs', N'VEF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Vietnamese Dong'                    , N'₫', N'VND', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Vanuatu Vatu'                       , N'VT', N'VUV', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Samoan Tala'                        , N'$', N'WST', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'CFA Franc BEAC'                     , N'', N'XAF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Silver (troy ounce)'                , N'', N'XAG', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Gold (troy ounce)'                  , N'', N'XAU', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'East Caribbean Dollar'              , N'$', N'XCD', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Special Drawing Rights'             , N'', N'XDR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'CFA Franc BCEAO'                    , N'', N'XOF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'CFP Franc'                          , N'', N'XPF', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Yemeni Rial'                        , N'﷼', N'YER', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'South African Rand'                 , N'R', N'ZAR', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Zambian Kwacha (pre-2013)'          , N'', N'ZMK', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Zambian Kwacha'                     , N'ZK', N'ZMW', 1.0, N'Inactive';
exec dbo.spCURRENCIES_InsertOnlyByISO N'Zimbabwean Dollar'                  , N'Z$', N'ZWL', 1.0, N'Inactive';
GO

-- 05/01/2016 Paul.  New search requires non-null STATUS. 
if exists(select * from CURRENCIES where STATUS is null) begin -- then
	update CURRENCIES
	   set STATUS            = N'Active'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where STATUS            is null;
end -- if;
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

call dbo.spCURRENCIES_Defaults()
/

call dbo.spSqlDropProcedure('spCURRENCIES_Defaults')
/

-- #endif IBM_DB2 */


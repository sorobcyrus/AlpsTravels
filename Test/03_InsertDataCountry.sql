/***************************************************************************************************
File: 03_InsertDataCountry.sql
----------------------------------------------------------------------------------------------------
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Inserts needed data to table Alps.Location 
Call by:        TBD, Add hoc
Steps:          N/A 
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText VARCHAR(MAX),      
        @Message   VARCHAR(255),   
        @StartTime DATETIME,
        @SP        VARCHAR(50)

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = 'Script-03_InsertDataCountry';
SET @StartTime = GETDATE();
    
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed INSERT table Country table.';

INSERT INTO Alps.Country
    (CountryID, Name)
VALUES
    (001, 'Afghanistan'),
    (002, 'Albania'),
    (003, 'Algeria'),
    (004, 'American Samoa'),
    (005, 'Andorra'),
    (006, 'Angola'),
    (007, 'Anguilla'),
    (008, 'Antarctica'),
    (009, 'Antigua and Barbuda'),
    (010, 'Argentina'),
    (011, 'Armenia'),
    (012, 'Aruba'),
    (013, 'Australia'),
    (014, 'Austria'),
    (015, 'Azerbaijan'),
    (016, 'Bahamas'),
    (017, 'Bahrain'),
    (018, 'Bangladesh'),
    (019, 'Barbados'),
    (020, 'Belarus'),
    (021, 'Belgium'),
    (022, 'Belize'),
    (023, 'Benin'),
    (024, 'Bermuda'),
    (025, 'Bhutan'),
    (026, 'Bolivia'),
    (027, 'Bonaire'),
    (028, 'Bosnia and Herzegovina'),
    (029, 'Botswana'),
    (030, 'Bouvet Island'),
    (031, 'Brazil'),
    (032, 'Brunei Darussalam'),
    (033, 'Bulgaria'),
    (034, 'Burkina Faso'),
    (035, 'Burundi'),
    (036, 'Cambodia'),
    (037, 'Cameroon'),
    (038, 'Canada'),
    (039, 'Cape Verde'),
    (040, 'Cayman Islands'),
    (041, 'Central African Republic'),
    (042, 'Chad'),
    (043, 'Chile'),
    (044, 'China'),
    (045, 'Colombia'),
    (046, 'Comoros'),
    (047, 'Congo'),
    (048, 'Costa Rica'),
    (049, 'Croatia'),
    (050, 'Cuba'),
    (051, 'Cyprus'),
    (052, 'Czech Republic'),
    (053, 'Denmark'),
    (054, 'Djibouti'),
    (055, 'Dominica'),
    (056, 'Dominican Republic'),
    (057, 'Ecuador'),
    (058, 'Egypt'),
    (059, 'El Salvador'),
    (060, 'Equatorial Guinea'),
    (061, 'Eritrea'),
    (062, 'Estonia'),
    (063, 'Ethiopia'),
    (064, 'Fiji'),
    (065, 'Finland'),
    (066, 'France'),
    (067, 'Gabon'),
    (068, 'Gambia'),
    (069, 'Georgia'),
    (070, 'Germany'),
    (071, 'Ghana'),
    (072, 'Gibraltar'),
    (073, 'Greece'),
    (074, 'Greenland'),
    (075, 'Grenada'),
    (076, 'Guadeloupe'),
    (077, 'Guam'),
    (078, 'Guatemala'),
    (079, 'Guernsey'),
    (080, 'Guinea'),
    (081, 'Guinea-Bissau'),
    (082, 'Guyana'),
    (083, 'Haiti'),
    (084, 'Vatican'),
    (085, 'Honduras'),
    (086, 'Hong Kong'),
    (087, 'Hungary'),
    (088, 'Iceland'),
    (089, 'India'),
    (090, 'Indonesia'),
    (091, 'Iran'),
    (092, 'Iraq'),
    (093, 'Ireland'),
    (094, 'Israel'),
    (095, 'Italy'),
    (096, 'Jamaica'),
    (097, 'Japan'),
    (098, 'Jersey'),
    (099, 'Jordan'),
    (100, 'Kazakhstan'),
    (101, 'Kenya'),
    (102, 'Kiribati'),
    (103, 'Korea-North'),
    (104, 'Korea-South'),
    (105, 'Kuwait'),
    (106, 'Kyrgyzstan'),
    (107, 'Lao'),
    (108, 'Latvia'),
    (109, 'Lebanon'),
    (110, 'Lesotho'),
    (111, 'Liberia'),
    (112, 'Libya'),
    (113, 'Liechtenstein'),
    (114, 'Lithuania'),
    (115, 'Luxembourg'),
    (116, 'Macao'),
    (117, 'Macedonia'),
    (118, 'Madagascar'),
    (119, 'Malawi'),
    (120, 'Malaysia'),
    (121, 'Maldives'),
    (122, 'Mali'),
    (123, 'Malta'),
    (124, 'Marshall Islands'),
    (125, 'Martinique'),
    (126, 'Mauritania'),
    (127, 'Mauritius'),
    (128, 'Mayotte'),
    (129, 'Mexico'),
    (130, 'Moldova'),
    (131, 'Monaco'),
    (132, 'Mongolia'),
    (133, 'Montenegro'),
    (134, 'Montserrat'),
    (135, 'Morocco'),
    (136, 'Mozambique'),
    (137, 'Myanmar'),
    (138, 'Namibia'),
    (139, 'Nauru'),
    (140, 'Nepal'),
    (141, 'Netherlands'),
    (142, 'New Caledonia'),
    (143, 'New Zealand'),
    (144, 'Nicaragua'),
    (145, 'Niger'),
    (146, 'Nigeria'),
    (147, 'Niue'),
    (148, 'Norway'),
    (149, 'Oman'),
    (150, 'Pakistan'),
    (151, 'Palau'),
    (152, 'Palestine'),
    (153, 'Panama'),
    (154, 'Papua New Guinea'),
    (155, 'Paraguay'),
    (156, 'Peru'),
    (157, 'Philippines'),
    (158, 'Pitcairn'),
    (159, 'Poland'),
    (160, 'Portugal'),
    (161, 'Puerto Rico'),
    (162, 'Qatar'),
    (163, 'Romania'),
    (164, 'Russia'),
    (165, 'Rwanda'),
    (166, 'Samoa'),
    (167, 'San Marino'),
    (168, 'Saudi Arabia'),
    (169, 'Senegal'),
    (170, 'Serbia'),
    (171, 'Seychelles'),
    (172, 'Sierra Leone'),
    (173, 'Singapore'),
    (174, 'Slovakia'),
    (175, 'Slovenia'),
    (176, 'Somalia'),
    (177, 'South Africa'),
    (178, 'South Sudan'),
    (179, 'Spain'),
    (180, 'Sri Lanka'),
    (181, 'Sudan'),
    (182, 'Suriname'),
    (183, 'Swaziland'),
    (184, 'Sweden'),
    (185, 'Switzerland'),
    (186, 'Syria'),
    (187, 'Taiwan'),
    (188, 'Tajikistan'),
    (189, 'Tanzania'),
    (190, 'Thailand'),
    (191, 'Timor-Leste'),
    (192, 'Togo'),
    (193, 'Tokelau'),
    (194, 'Tonga'),
    (195, 'Trinidad and Tobago'),
    (196, 'Tunisia'),
    (197, 'Turkey'),
    (198, 'Turkmenistan'),
    (199, 'Tuvalu'),
    (200, 'Uganda'),
    (201, 'Ukraine'),
    (202, 'United Arab Emirates'),
    (203, 'United Kingdom'),
    (204, 'United States'),
    (205, 'Uruguay'),
    (206, 'Uzbekistan'),
    (207, 'Vanuatu'),
    (208, 'Venezuela'),
    (209, 'Viet Nam'),
    (210, 'Western Sahara'),
    (211, 'Yemen'),
    (212, 'Zambia'),
    (213, 'Zimbabwe'),
    (255, 'TBD')

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Country';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '   
   + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));   
RAISERROR(@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'End',
   @Message = @Message;

END TRY

BEGIN CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

SET @ErrorText = 'Error: '+CONVERT(VARCHAR,ISNULL(ERROR_NUMBER(),'NULL'))      
                  +', Severity = '+CONVERT(VARCHAR,ISNULL(ERROR_SEVERITY(),'NULL'))      
                  +', State = '+CONVERT(VARCHAR,ISNULL(ERROR_STATE(),'NULL'))      
                  +', Line = '+CONVERT(VARCHAR,ISNULL(ERROR_LINE(),'NULL'))      
                  +', Procedure = '+CONVERT(VARCHAR,ISNULL(ERROR_PROCEDURE(),'NULL'))      
                  +', Server Error Message = '+CONVERT(VARCHAR(100),ISNULL(ERROR_MESSAGE(),'NULL'))      
                  +', SP Defined Error Text = '+@ErrorText;

EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Error',
   @Message = @ErrorText;

RAISERROR(@ErrorText,18,127) WITH NOWAIT;
END CATCH;      

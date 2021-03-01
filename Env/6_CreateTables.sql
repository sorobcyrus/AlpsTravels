CREATE OR ALTER PROCEDURE Alps.CreateTables
AS
/***************************************************************************************************
File: CreateTables.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.CreateTables
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Creates all needed Alps tables  
Call by:        TBD, UI, Add hoc
Steps:          NA
Parameter(s):   None
Usage:          EXEC Alps.CreateTables
****************************************************************************************************
SUMMARY OF CHANGES
Date			Author				Comments 
------------------- ------------------- ------------------------------------------------------------
2020-12-01		Sorob Cyrus			Starting 2016 - SP1 - We can use CREATE OR ALTER, instead of DROP and CREATE 
									Also using THROW, instead of RAISERROR
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText VARCHAR(MAX),      
        @Message   VARCHAR(255),   
        @StartTime DATETIME,
        @SP        VARCHAR(50)

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';  

SET @SP = OBJECT_NAME(@@PROCID)
SET @StartTime = GETDATE();    
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');  
 
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
    @Status = 'Start',
    @Message = @Message;
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table Alps.Customer.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'Alps.Customer') AND type in (N'U'))
BEGIN
		SET @Message = 'Table Alps.Customer already exist, skipping....';
		RAISERROR(@Message, 0,1) WITH NOWAIT;
		EXEC Alps.InsertHistory @SP = @SP,
			@Status = 'Run',
			@Message = @Message;
END
ELSE
BEGIN
	    CREATE TABLE Alps.Customer
    (
        CustomerID INT NOT NULL,
        CountryID TINYINT NOT NULL,
        Email NVARCHAR(50) NOT NULL,
        FirstName NVARCHAR(50) NOT NULL,
        LastName NVARCHAR(50) NOT NULL,
        ID NVARCHAR(20) NOT NULL,
        Tel1 NVARCHAR(20) NULL,
        Tel2 NVARCHAR(20) NULL,
        Website NVARCHAR(50) NULL,
        Address NVARCHAR(250) NULL,
        Note NVARCHAR(250) NULL,
        CONSTRAINT PK_Customer_CustomerID PRIMARY KEY CLUSTERED (CustomerID),
        CONSTRAINT UK_Customer_Email UNIQUE (Email)
    );

    SET @Message = 'Completed CREATE TABLE Alps.Customer.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table Alps.Country.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'Alps.Country') AND type in (N'U'))
BEGIN
    SET @Message = 'Table Alps.Country already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Alps.Country
    (
        CountryID	TINYINT			NOT NULL,
        [Name]		NVARCHAR(50)	NOT NULL,
        CONSTRAINT PK_CustomerCountry_CountryID PRIMARY KEY CLUSTERED (CountryID),
        CONSTRAINT UK_CustomerCountry_Name UNIQUE (Name)
    )
    SET @Message = 'Completed CREATE TABLE Alps.Country.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table Alps.Order.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'Alps.Order') AND type in (N'U'))
BEGIN
    SET @Message = 'Table Alps.Order already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Alps.[Order]
    (
        OrderID			INT				NOT NULL,
        CustomerID		INT				NOT NULL,
        OrderStatusID	TINYINT			NOT NULL,
        OrderDate		DATETIME		NOT NULL,
        FinalDate		DATETIME		NULL,
        TotalAmount		MONEY			NOT NULL,
        Note			NVARCHAR(250)	NULL,
        CONSTRAINT PK_Order_OrderID PRIMARY KEY CLUSTERED (OrderID),
        CONSTRAINT CK_Order_TotalAmount CHECK (TotalAmount >= 0)
    )
    SET @Message = 'Completed CREATE TABLE Alps.Order.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table Alps.OrderDetail.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'Alps.OrderDetail') AND type in (N'U'))
BEGIN
    SET @Message = 'Table Alps.OrderDetail already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Alps.OrderDetail
    (
        OrderID		INT				NOT NULL,
        LocationID	TINYINT			NOT NULL,
        PackageID	TINYINT			NOT NULL,
        UnitPrice	MONEY			NOT NULL,
        Quantity	TINYINT			NOT NULL,
        Note		NVARCHAR(250)	NULL,
        CONSTRAINT PK_OrderDetail_OrderIDLocationIDPackageID PRIMARY KEY CLUSTERED (OrderID, LocationID, PackageID),
        CONSTRAINT CK_OrderDetail_UnitPrice CHECK (UnitPrice >= 0),
        CONSTRAINT CK_OrderDetail_Quantity CHECK (Quantity >= 0)
    )
    SET @Message = 'Completed CREATE TABLE Alps.OrderDetail.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table Alps.Package.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'Alps.Package') AND type in (N'U'))
BEGIN
    SET @Message = 'Table Alps.Package already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Alps.Package
    (
        PackageID	TINYINT			NOT NULL,
        [Name]		NVARCHAR(100)	NOT NULL,
        UnitPrice	MONEY			NOT NULL,
        Note		VARCHAR(250)	NULL,
        CONSTRAINT PK_Package_PackageID PRIMARY KEY CLUSTERED (PackageID),
        CONSTRAINT UK_Package_Name UNIQUE (Name),
        CONSTRAINT CK_Package_UnitPrice CHECK (UnitPrice >= 0)
    )
    SET @Message = 'Completed CREATE TABLE Alps.Package.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed CREATE Table Alps.OrderStatus.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'Alps.OrderStatus') AND type in (N'U'))
BEGIN
    SET @Message = 'Table Alps.OrderStatus already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Alps.OrderStatus
    (
        OrderStatusID	TINYINT			NOT NULL,
        [Name]			NVARCHAR(50)	NOT NULL,
        CONSTRAINT PK_OrderStatus_OrderStatusID PRIMARY KEY CLUSTERED (OrderStatusID),
        CONSTRAINT UK_OrderStatus_Name UNIQUE (Name)
    )
    SET @Message = 'Completed CREATE TABLE Alps.OrderStatus.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed CREATE Table Alps.Location.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'Alps.Location') AND type in (N'U'))
BEGIN
    SET @Message = 'Table Alps.Location already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Alps.Location
    (
        LocationID	TINYINT			NOT NULL,
        [Name]		NVARCHAR(50)	NOT NULL,
        CONSTRAINT PK_Location_LocationID PRIMARY KEY CLUSTERED (LocationID),
        CONSTRAINT UK_Location_Name UNIQUE (Name)
    )
    SET @Message = 'Completed CREATE TABLE Alps.Location.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table Alps.CustomerOrder.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'Alps.CustomerOrder') AND type in (N'U'))
BEGIN
    SET @Message = 'Table Alps.CustomerOrder already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE Alps.CustomerOrder
    (
        Email		NVARCHAR(50)	NOT NULL,
        LocationID	TINYINT			NOT NULL,
        PackageID	TINYINT			NOT NULL,
        UnitPrice	MONEY			NOT NULL,
        Quantity	TINYINT			NOT NULL,
        Note		NVARCHAR(250)	NULL
    )
    SET @Message = 'Completed CREATE TABLE Alps.CustomerOrder.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------


SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '   
   + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));   
RAISERROR(@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
    @Status = 'End',
    @Message = @Message

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
   @Message = @ErrorText

RAISERROR(@ErrorText,18,127) WITH NOWAIT;
END CATCH;      


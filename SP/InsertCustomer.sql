----------------------------------------------------------------------------------------------------
-- PRE 2016 version, we need to check and drop Proc if already there
----------------------------------------------------------------------------------------------------
IF EXISTS (
SELECT *
FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'Alps'
    AND SPECIFIC_NAME = N'InsertCustomer'
    AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE Alps.InsertCustomer
GO

----------------------------------------------------------------------------------------------------
-- CREATE OR ALTER PROCEDURE Alps.DeleteCustomer 
-- 2016+ version doesn't require Checking and dropping the proc 
----------------------------------------------------------------------------------------------------
CREATE PROCEDURE Alps.InsertCustomer
    @CustomerID INT,
    @CountryID  TINYINT,
    @Email      NVARCHAR(50),
    @FirstName  NVARCHAR(50),
    @LastName   NVARCHAR(50),
    @ID         NVARCHAR(20),
    @Tel1       NVARCHAR(20) = NULL,
    @Tel2       NVARCHAR(20) = NULL,
    @Website    NVARCHAR(50) = NULL,
    @Address    NVARCHAR(250) = NULL,
    @Note       NVARCHAR(250) = NULL
AS
/***************************************************************************************************
File: InsertCustomer.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.InsertCustomer
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Insert a Customer
Call by:        Alps.AddOrder, Add hoc

Steps:          1- Check the @CountryID for RI issue in Alps.Country table
                2- Error out if @Email already is in table Alps.Customer
                3- Error out if @CustomerID <= 10000000
                4- Insert to table Alps.Customer

Parameter(s):   @CountryID  
                @Email      
                @FirstName  
                @LastName   
                @ID         
                @Tel1       NULL
                @Tel2       NULL
                @Website    NULL
                @Address    NULL
                @Note       NULL

Usage:          Alps.InsertCustomer @CustomerID = 100001052,
                                      @CountryID = 91,
                                      @Email = '100001052@xyz.com',
                                      @FirstName = 'TBD',
                                      @LastName = 'TBD',
                                      @ID = 'TBD'
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText   VARCHAR(MAX),      
        @Message     VARCHAR(255),    
        @StartTime   DATETIME,
        @SP          VARCHAR(50)

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = OBJECT_NAME(@@PROCID);
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed to SELECT from table CustomerCountry!';

-- Check to give a friendly error for RI Issue.
IF NOT EXISTS(SELECT 1
	FROM Alps.Country
	WHERE CountryID = @CountryID)
BEGIN
    SET @ErrorText = 'CountryID = ' + CONVERT(VARCHAR(10), @CountryID) + ' not found in table Country! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed to SELECT from table Customer!';
IF EXISTS(SELECT 1
FROM Alps.Customer
WHERE Email = @Email)
BEGIN
    SET @ErrorText = 'Email = ' + @Email + ' already is in table Customer! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed check for variable @CustomerID!';
IF @CustomerID <= 10000000
BEGIN
    SET @ErrorText = 'CustomerID = ' + CONVERT(VARCHAR(10), @CustomerID) + ' This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Customer!';
INSERT INTO Alps.Customer
    (CustomerID, CountryID, Email, FirstName, LastName, ID, Tel1, Tel2, Website, Address, Note)
VALUES
    (@CustomerID, @CountryID, @Email, @FirstName, @LastName, @ID, @Tel1, @Tel2, @Website, @Address, @Note)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Customer using CustomerID = ' + CONVERT(VARCHAR(10), @CustomerID) ;   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '    
      + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR (@Message, 0,1) WITH NOWAIT;    
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
   --THROW 66000, @ErrorText, 1;	-- 2016+
END CATCH;      


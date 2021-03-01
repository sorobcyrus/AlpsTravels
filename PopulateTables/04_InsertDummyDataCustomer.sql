/***************************************************************************************************
File: 04_InsertDummyDataCustomer.sql
----------------------------------------------------------------------------------------------------
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Inserts dummy data to table Alps.Customer
Call by:        TBD, Add hoc
Steps:          N/A 
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText  VARCHAR(MAX),      
        @Message    VARCHAR(255),   
        @StartTime  DATETIME,
        @SP         VARCHAR(50),
        @CustomerID INT,
        @CountryID  TINYINT,
        @Email      NVARCHAR(50),
        @FirstName  NVARCHAR(50),
        @LastName   NVARCHAR(50),
        @ID         NVARCHAR(20),
        @Counter    TINYINT,
        @MaxCounter TINYINT

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = 'Script-04_InsertDummyDataCustomer';
SET @StartTime = GETDATE();    

SET @CountryID = 0;
SET @Email = SPACE(0);
SET @FirstName = SPACE(0);
SET @LastName = SPACE(0);
SET @ID = SPACE(0);
SET @Counter = 1
SET @MaxCounter = 50

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed SELECT from table Parameter!';

SET @CustomerID = (SELECT NumValue
FROM Alps.Parameter
WHERE NAME = 'StartCustomerID');
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed INSERT table Customer table.';

WHILE @Counter <= @MaxCounter
BEGIN
    SET @Email = CONVERT(varchar(10), @CustomerID) + '@xyz.com';
    SET @FirstName = 'FirstName' + CONVERT(varchar(10), @Counter) + SPACE(1) + CONVERT(varchar(10), @CustomerID);
    SET @LastName = 'LastName' + CONVERT(varchar(10), @Counter) + SPACE(1) + CONVERT(varchar(10), @CustomerID);
    SET @ID = 'ID' + SPACE(1) + CONVERT(varchar(10), @CustomerID);

    -- Norway
    IF @Counter > 0 AND @Counter <= 10
        SET @CountryID = 148;
    ELSE
    -- USA
    IF @Counter > 10 AND @Counter <= 20
        SET @CountryID = 204;
    ELSE
    -- Germany
    IF @Counter > 20 AND @Counter <= 30
        SET @CountryID = 070;
    ELSE
    -- France
    IF @Counter > 30 AND @Counter <= 40
        SET @CountryID = 066;
    ELSE
        SET @CountryID = 91;

    INSERT INTO Alps.Customer
        (CustomerID, CountryID, Email, FirstName, LastName, ID)
    VALUES
        (@CustomerID, @CountryID, @Email, @FirstName, @LastName, @ID);

    SET @Counter += 1;
    SET @CustomerID +=1;
END;

SET @Message = 'Completed INSERT' + SPACE(1) + CONVERT(varchar(10), @MaxCounter) + SPACE(1) + 'Rows of Dummy Data to table Customer';   
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

END
TRY

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

CREATE OR ALTER PROCEDURE Alps.InsertPackage
    @Name       NVARCHAR(50),
    @UnitPrice  MONEY,
    @Note       NVARCHAR(50) = NULL
AS
/***************************************************************************************************
File: InsertPackage.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.InsertPackage
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Insert a Package
Call by:        UI, Add hoc

Steps:          1- Check the @Name for RI issue in Alps.Package
                2- Get Max PackageID by calling SP Alps.GetMaxPackageID
                3- Error out if @PackageID <= 0
                4- Insert to table Alps.Package

Parameter(s):   @Name
                @UnitPrice
                @Note

Usage:          Alps.InsertPackage @Name = 'Test1',
                                     @UnitPrice = 500,
                                     @Note = NULL
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText   VARCHAR(MAX),      
        @Message     VARCHAR(255),    
        @StartTime   DATETIME,
        @SP          VARCHAR(50),
        @PackageID   TINYINT;

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
SET @ErrorText = 'Failed to SELECT from table Package!';
IF EXISTS(SELECT 1
FROM Alps.Package
WHERE Name = @Name)
BEGIN
    SET @ErrorText = 'Name = ' + @Name + ' already is in table Package! This is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed Calling SP GetMaxPackageID!';
-- Call SP
EXEC Alps.GetMaxPackageID @MaxPackageID = @PackageID OUTPUT;

SET @Message = 'PackageID = ' + CONVERT(VARCHAR(10), @PackageID) + ' is the return value from SP Alps.GetMaxPackageID.';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message

SET @ErrorText = 'Failed check for variable @PackageID!';
-- Check for value
IF @PackageID <= 0
BEGIN
    SET @ErrorText = 'PackageID = ' + CONVERT(VARCHAR(10), @PackageID) + ' This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Package!';
INSERT INTO Alps.Package
    (PackageID, Name, UnitPrice, Note)
VALUES
    (@PackageID, @Name, @UnitPrice, @Note)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Package using PackageID = ' + CONVERT(VARCHAR(10), @PackageID) ;   
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
END CATCH;      


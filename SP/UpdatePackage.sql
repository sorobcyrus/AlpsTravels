CREATE OR ALTER PROCEDURE Alps.UpdatePackage
    @PackageID TINYINT,
    @Name  NVARCHAR(50) = NULL,
    @UnitPrice MONEY = NULL,
    @Note NVARCHAR(250) = NULL
AS
/***************************************************************************************************
File: UpdatePackage.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.UpdatePackage
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Updatre a Package
Call by:        UI, Add hoc

Steps:          1- Check the @PackageID for RI issue in Alps.Package table
                2- Update table Alps.Package

Parameter(s):   @PackageID
                @Name      NULL
                @UnitPrice NULL
                @Note      NULL

Usage:          EXEC Alps.UpdatePackage @PackageID = 25,
                                          @Name = 'Some update test1';
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
   @Message = @Message;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed to SELECT from table Package!';
IF NOT EXISTS(SELECT 1
	FROM Alps.Package
	WHERE PackageID = @PackageID)
BEGIN
    SET @ErrorText = 'Did not find the Package! PackageID = ' + CONVERT(VARCHAR(10), @PackageID) + ' not found in table Package! Please check the PackageID and try again. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Package!';

UPDATE Alps.Package
SET Name = ISNULL(@Name, Name),
    UnitPrice = ISNULL(@UnitPrice, UnitPrice),
    Note = ISNULL(@Note, Note)
WHERE PackageID = @PackageID
SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed UPDATE to table Package using PackageID = ' + CONVERT(VARCHAR(10), @PackageID) ;   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '    
      + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR (@Message, 0,1) WITH NOWAIT;    
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


CREATE OR ALTER PROCEDURE Alps.DeletePackage
   @PackageID TINYINT
AS
/***************************************************************************************************
File: DeletePackage.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.DeletePackage
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Deletes a Package
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @PackageID
Usage:          Alps.DeletePackage 26
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

SET @SP = OBJECT_NAME(@@PROCID);
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed DELETE from Package table.';

IF(NOT EXISTS(SELECT 1
FROM Alps.Package))
BEGIN
   SET @ErrorText = 'Package table is Empty Rasing Error!';
   RAISERROR(@ErrorText, 16,1);
END;

DELETE FROM Alps.Package
WHERE PackageID = @PackageID;
IF @@ROWCOUNT = 0  
BEGIN
   SET @ErrorText = 'PackageID = ' + CONVERT(VARCHAR(10), @PackageID) + ' Not found! Rasing Error!';
   RAISERROR(@ErrorText, 16,1);
END;

SET @Message = 'Completed DELETE from Package table for PackageID = ' + CONVERT(VARCHAR(10), @PackageID) ;   
RAISERROR(@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message
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


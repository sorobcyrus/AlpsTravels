CREATE OR ALTER PROCEDURE Alps.UpdateLocation
   @LocationID TINYINT,
   @Name  NVARCHAR(50) = NULL
AS
/***************************************************************************************************
File: UpdateLocation.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.UpdateLocation
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Update a Location
Call by:        UI, Add hoc

Steps:          1- Check the @LocationID for RI issue in Alps.Location table
                2- Update Alps.Location table

Parameter(s):   @LocationID
                @Name NULL

Usage:          EXEC Alps.UpdateLocation @LocationID = 19,
                                           @Name = 'Some update test1'
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
SET @ErrorText = 'Failed to SELECT from table Location!';
IF NOT EXISTS(SELECT 1
	FROM Alps.Location
	WHERE LocationID = @LocationID)
BEGIN
   SET @ErrorText = 'Did not find the Location! LocationID = ' + CONVERT(VARCHAR(10), @LocationID) + ' not found in table Location! Please check the LocationID and try again. Rasing Error!';
   RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Location!';
UPDATE Alps.Location
SET Name = ISNULL(@Name, Name)
WHERE LocationID = @LocationID
SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed UPDATE to table Location using LocationID = ' + CONVERT(VARCHAR(10), @LocationID) ;   
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


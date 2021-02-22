CREATE OR ALTER PROCEDURE Alps.InsertOrderStatus
	@OrderStatusID	TINYINT,
    @Name			NVARCHAR(50)
AS
/***************************************************************************************************
File: InsertOrderStatus.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.InsertOrderStatus
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Insert Order Status lookup table
Call by:        UI, Add hoc

Steps:          1- Check the @Name for RI issue in Alps.OrderStatus
                2- Get Max StatusID by calling SP Alps.GetMaxStatusID
                3- Error out if @StatusID <= 0
                4- Insert to table Alps.OrderStatus

Parameter(s):   @OrderStatusID
				@Name
                

Usage:          Alps.OrderStatus	@OrderStatusID = 1,
									@Name = 'Test1'
                                     
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
        @StatusID   TINYINT;

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
SET @ErrorText = 'Failed to SELECT from table OrderStatus!';
IF EXISTS(SELECT 1
	FROM Alps.OrderStatus
	WHERE Name = @Name)
BEGIN
    SET @ErrorText = 'Name = ' + @Name + ' already is in table OrderStatus! This is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed Calling SP GetMaxOrderStatusID!';
-- Call SP
EXEC Alps.GetMaxOrderStatusID @MaxOrderStatusID = @StatusID OUTPUT;

SET @Message = 'StatusID = ' + CONVERT(VARCHAR(10), @StatusID) + ' is the return value from SP Alps.GetMaxStatusID.';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message

SET @ErrorText = 'Failed check for variable @StatusID!';
-- Check for value
IF @StatusID <= 0
BEGIN
    SET @ErrorText = 'StatusID = ' + CONVERT(VARCHAR(10), @StatusID) + ' This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table OrderStatus!';
INSERT INTO Alps.OrderStatus
    (OrderStatusID, Name)
VALUES
    (@StatusID, @Name)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table IrderStatus using StatusID = ' + CONVERT(VARCHAR(10), @StatusID) ;   
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

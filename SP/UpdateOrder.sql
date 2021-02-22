CREATE OR ALTER PROCEDURE Alps.UpdateOrder
    @OrderID        INT,
    @CustomerID     INT = NULL,
    @OrderStatusID  TINYINT = NULL,
    @OrderDate      DATETIME = NULL,
    @FinalDate      DATETIME = NULL,
    @TotalAmount    MONEY = NULL,
    @Note           NVARCHAR(250) = NULL
AS
/***************************************************************************************************
File: UpdateOrder.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.UpdateOrder
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Updatre an Order
Call by:        UI, Add hoc

Steps:          1- Check the @OrderID for RI issue in Alps.[Order] table
                2- Update table Alps.[Order]

Parameter(s):   @OrderID
                @CustomerID    NULL
                @OrderStatusID NULL
                @OrderDate     NULL
                @FinalDate     NULL
                @TotalAmount   NULL
                @Note          NULL

Usage:          EXEC Alps.UpdateOrder @OrderID = 100001001,
                                        @CustomerID = 100001002,
                                        @OrderStatusID = 1,
                                        @OrderDate     = '2019/08/25',
                                        @FinalDate     = NULL,
                                        @TotalAmount   = 6000,
                                        @Note          = 'Some stuff';
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
        @RowCount    INT;

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @RowCount = 0;
SET @SP = OBJECT_NAME(@@PROCID);
SET @StartTime = GETDATE();
    
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed to SELECT from table Order!';
IF NOT EXISTS(SELECT 1
FROM Alps.[Order]
WHERE OrderID = @OrderID)
BEGIN
    SET @ErrorText = 'Did not find the Order! OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' not found in table Order! Please check the OrderID and try again. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed UPDATE to table [Order]!';
UPDATE Alps.[Order]
SET CustomerID = ISNULL(@CustomerID, CustomerID),
    OrderStatusID = ISNULL(@OrderStatusID, OrderStatusID),
    OrderDate = ISNULL(@OrderDate, OrderDate),
    FinalDate = ISNULL(@FinalDate, FinalDate),
    TotalAmount = ISNULL(@TotalAmount, TotalAmount),
    Note = ISNULL(@Note, Note)
WHERE OrderID = @OrderID
SET @RowCount = @@ROWCOUNT
IF @RowCount <> 1  
BEGIN
    SET @ErrorText = CONVERT(VARCHAR(10), @RowCount) + ' rows effected! OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' Should be only one row! UNEXPECTED RESULT! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END
ELSE
BEGIN
    SET @Message = CONVERT(VARCHAR(10), @RowCount) + ' rows effected. Completed UPDATE to table Order using OrderID = ' + CONVERT(VARCHAR(10), @OrderID);
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
    @Status = 'Run',
    @Message = @Message;
END
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


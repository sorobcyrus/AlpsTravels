CREATE OR ALTER PROCEDURE Alps.InsertOrder
    @OrderID     INT,
    @CustomerID  INT,
    @TotalAmount MONEY,
	@Note        NVARCHAR(250) = NULL
AS
/***************************************************************************************************
File: InsertOrder.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.InsertOrder
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Insert an order
Call by:        Alps.AddOrder, Add hoc

Steps:          1- Check the @CustomerID for RI issue in Alps.Customertable
                2- Error out if @TotalAmount < 0
                3- Insert to table Alps.[Order]

Parameter(s):   @OrderID
                @CustomerID
                @TotalAmount

Usage:          Alps.InsertOrder @OrderID = 100001003,
                                   @CustomerID = 100001001,
                                   @TotalAmount = 5000 
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
SET @ErrorText = 'Failed SELECT from table Customer!';
-- Check to give a friendly error for RI Issue.
IF NOT EXISTS(SELECT 1
FROM Alps.Customer
WHERE CustomerID = @CustomerID)
BEGIN
    SET @ErrorText = 'CustomerID = ' + CONVERT(VARCHAR(10), @CustomerID) + ' not found in table Customer! This is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed check for variable @TotalAmount!';
-- Check for value
IF @TotalAmount < 0
BEGIN
    SET @ErrorText = 'TotalAmout = ' + CONVERT(VARCHAR(10), @TotalAmount) + ' This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Order!';
INSERT INTO Alps.[Order]
    (OrderID, CustomerID, OrderStatusID, OrderDate, TotalAmount, Note)
VALUES
    (@OrderID, @CustomerID, 1, GETDATE(), @TotalAmount, @Note)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Order using OrderID = ' + CONVERT(VARCHAR(10), @OrderID) ;   
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


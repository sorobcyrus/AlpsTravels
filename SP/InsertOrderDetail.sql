CREATE OR ALTER PROCEDURE Alps.InsertOrderDetail
    @OrderID	INT,
    @LocationID TINYINT,
    @PackageID  TINYINT,
    @UnitPrice  MONEY,
    @Quantity   TINYINT,
	@Note       NVARCHAR(250) = NULL
AS
/***************************************************************************************************
File: InsertOrderDetail.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.InsertOrderDetail
Create Date:    2020-11-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Insert an order detail 
Call by:        Alps.AddOrder, Add hoc

Steps:          1- Check the @OrderID for RI issue in Alps.[Order]
                2- Check the @LocationID for RI issue in Alps.Location
                3- Check the @PackageID for RI issue in Alps.Package
                4- Error out if @UnitPrice < 0
                5- Error out if @Quantity < 0
                6- Insert to table Alps.OrderDetail

Parameter(s):   @OrderID
                @LocationID
                @PackageID
                @UnitPrice
                @Quantity

Usage:          Alps.InsertOrderDetail @OrderID = 100001003,
                                         @LocationID = 01,
                                         @PackageID = 01,
                                         @UnitPrice = 300, 
                                         @Quantity = 1
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
-- Check to give a friendly error for RI Issue.
IF NOT EXISTS(SELECT 1
FROM Alps.[Order]
WHERE OrderID = @OrderID)
BEGIN
    SET @ErrorText = 'OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' not found in table Order! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

-- Check to give a friendly error for RI Issue.
IF NOT EXISTS(SELECT 1
FROM Alps.Location
WHERE LocationID = @LocationID)
BEGIN
    SET @ErrorText = 'LocationID = ' + CONVERT(VARCHAR(10), @LocationID) + ' not found in table Location! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

-- Check to give a friendly error for RI Issue.
IF NOT EXISTS(SELECT 1
FROM Alps.Package
WHERE PackageID = @PackageID)
BEGIN
    SET @ErrorText = 'PackageID = ' + CONVERT(VARCHAR(10), @PackageID) + ' not found in table Package! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

-- Check for value
IF @UnitPrice < 0
BEGIN
    SET @ErrorText = 'UnitPrice = ' + CONVERT(VARCHAR(10), @UnitPrice) + '. This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

-- Check for value
IF @Quantity < 0
BEGIN
    SET @ErrorText = 'Quantity = ' + CONVERT(VARCHAR(10), @Quantity) + '. This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table OrderDetail!';
INSERT INTO Alps.OrderDetail
    (OrderID, LocationID, PackageID, UnitPrice, Quantity, Note)
VALUES
    (@OrderID, @LocationID, @PackageID, @UnitPrice, @Quantity, @Note)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table OrderDetail using OrderID = ' + CONVERT(VARCHAR(10), @OrderID);   
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


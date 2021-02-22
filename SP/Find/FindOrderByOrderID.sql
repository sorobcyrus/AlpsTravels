CREATE OR ALTER PROCEDURE Alps.FindOrderByOrderID
    @OrderID INT
AS
/***************************************************************************************************
File: FindOrderByOrderID.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.FindOrderByOrderID
Create Date:    2020-09-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Finds Orders by OrderID 
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @OrderID
Usage:          Alps.FindOrderByOrderID 100001001
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
SET @ErrorText = 'Failed to SELECT from tables!';

-- Make sure we have the OrderID.
IF NOT EXISTS(SELECT 1
	FROM Alps.[Order]
	WHERE OrderID = @OrderID)
BEGIN
    SET @ErrorText = 'OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' not found in table Order! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed to SELECT from table Order!';
SELECT OD.OrderID,
    OS.Name AS OrderStatus,
    CU.CustomerID,
    CU.FirstName AS CustomerFirstName,
    CU.LastName AS CustomerLastName,
    CO.Name AS CustomerCountry,
    P.Name AS PackageName,
    OD.UnitPrice,
    OD.Quantity,
    OD.Note AS OrderDetailNote,
    O.OrderDate,
    O.FinalDate,
    O.TotalAmount,
    O.Note AS OrderNote
FROM Alps.OrderDetail AS OD WITH (NOLOCK)
    INNER JOIN Alps.[Order] AS O WITH (NOLOCK)
    ON OD.OrderID =  O.OrderID
    INNER JOIN Alps.Package AS P WITH (NOLOCK)
    ON OD.PackageID = P.PackageID
    INNER JOIN Alps.Location AS L WITH (NOLOCK)
    ON OD.LocationID = L.LocationID
    INNER JOIN Alps.Customer AS CU WITH (NOLOCK)
    ON O.CustomerID = CU.CustomerID
    INNER JOIN Alps.Country AS CO WITH (NOLOCK)
    ON CU.CountryID = CO.CountryID
    INNER JOIN Alps.OrderStatus AS OS WITH (NOLOCK)
    ON O.OrderStatusID = OS.OrderStatusID
WHERE O.OrderID = @OrderID;
SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed SELECT from table Order using OrderID = ' + CONVERT(VARCHAR(10), @OrderID) ;   
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


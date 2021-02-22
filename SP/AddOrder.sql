CREATE OR ALTER PROCEDURE Alps.AddOrder
AS
/***************************************************************************************************
File: AddOrder.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.AddOrder
Create Date:    2020-09-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Add an order 
Call by:        TBD, UI, Add hoc

Steps:          1- Quit if Alps.CustomerOrder table is empty 
                2- Error out if there is more than one distinct Email in Alps.CustomerOrder table
                3- Get the Customer order from Alps.CustomerOrder table
                4- Check to see if we have the customer 
                    - If we do not have the customer, call SP Alps.GetMaxCustomerID and
                    SP Alps.InsertCustomer to add the new customer.
                5- Add the order by calling SP Alps.InsertOrder and SP Alps.InsertOrderDetail by
                    looping through table variable @CUstomerOrder
                6- Truncate table Alps.CustomerOrder

Parameter(s):   None
Usage:          EXEC Alps.AddOrder
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

        @RowsToProcess  INT,
        @CurrentRow     INT,

        @RowCount       INT,

        @NoEmail        INT,

        @CustomerID     INT,
        @OrderID        INT,

        @CountryID_TBD  TINYINT,

        @Email          NVARCHAR(50),
        @LocationID     TINYINT,
        @PackageID      TINYINT,
        @UnitPrice      MONEY,
        @Quantity       TINYINT,
        @Note           NVARCHAR(250),

        @TotalAmount      MONEY,
        @TotalTotalAmount MONEY;

DECLARE @CUstomerOrder TABLE (
    RowID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Email NVARCHAR(50) NOT NULL,
    LocationID TINYINT NOT NULL,
    PackageID TINYINT NOT NULL,
    UnitPrice MONEY NOT NULL,
    Quantity TINYINT NOT NULL,
    Note NVARCHAR(250) NULL);

BEGIN TRY;
SET @RowCount = 0;
SET @NoEmail = 0;
SET @TotalAmount = 0;
SET @TotalTotalAmount = 0;
SET @CountryID_TBD = 255;
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = OBJECT_NAME(@@PROCID);
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message

-------------------------------------------------------------------------------
-- Skip if there is no order
IF(NOT EXISTS(SELECT 1
FROM Alps.CustomerOrder))
BEGIN
    SET @Message = 'CustomerOrder table is Empty, SKipping the SP ...';
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
    @Status = 'Run',
    @Message = @Message;
    RETURN;
END;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed SELECT from CustomerOrder table.';

-- Making sure each order has only one Email
SELECT @NoEmail = COUNT(DISTINCT Email)
FROM Alps.CustomerOrder;
IF @NoEmail <> 1  
BEGIN
    SET @ErrorText = CONVERT(VARCHAR(10), @NoEmail) + ' rows effected on count DISTINCT Email from CustomerOrder! should be only one! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed SELECT on assigning the value for @Email from CustomerOrder table.';

-- Get the Email
SELECT @Email = MAX(Email)
FROM Alps.CustomerOrder;
SET @Message = 'Email = ' + @Email + ' in CustomerOrder table.';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;

-------------------------------------------------------------------------------
-- BEGIN TRANSACTION;
-------------------------------------------------------------------------------

-- See if we have the customer
SELECT @CustomerID = CustomerID
FROM Alps.Customer
WHERE Email = @Email;
SET @RowCount = @@ROWCOUNT

IF @RowCount = 1  
BEGIN
    SET @Message = 'CustomerID = ' + CONVERT(VARCHAR(10), @CustomerID) + ' Email = ' + @Email + ' found in table Customer table. No need to add the customer.';
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE IF @RowCount = 0
BEGIN
    SET @Message = 'Email = ' + @Email + ' not found in table Customer table. Need to add the customer.';
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
                              @Status = 'Run',
                              @Message = @Message;

    SET @ErrorText = 'Failed Calling SP GetMaxCustomerID!';
    EXEC Alps.GetMaxCustomerID @MaxCustomerID = @CustomerID OUTPUT;

    SET @Message = 'CustomerID = ' + CONVERT(VARCHAR(10), @CustomerID) + ' is the return value from SP Alps.GetMaxCustomerID.';
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
                              @Status = 'Run',
                              @Message = @Message

    SET @ErrorText = 'Failed Calling SP InsertCustomer!';
    EXEC Alps.InsertCustomer @CustomerID = @CustomerID,
                               @CountryID = @CountryID_TBD,
                               @Email = @Email,
                               @FirstName = 'TBD',
                               @LastName = 'TBD',
                               @ID = 'TBD'
    SET @Message = 'Completed adding the Customer.';
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    SET @ErrorText = CONVERT(VARCHAR(10), @RowCount) + ' rows effected! CustomerID = ' + CONVERT(VARCHAR(10), @CustomerID) + ' Email = ' + @Email + ' UNEXPECTED RESULT! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed INSERT from CustomerOrder table.';

INSERT INTO @CUstomerOrder
    (Email, LocationID, PackageID, UnitPrice, Quantity, Note)
SELECT Email, LocationID, PackageID, UnitPrice, Quantity, Note
FROM Alps.CustomerOrder
SET @RowsToProcess=@@ROWCOUNT

IF @RowsToProcess = 0
BEGIN
    SET @ErrorText = 'CustomerOrder table is Empty! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed SELECT from @CustomerOrder table.';

-- https://stackoverflow.com/questions/1578198/can-i-loop-through-a-table-variable-in-t-sql
SET @CurrentRow = 0
WHILE @CurrentRow < @RowsToProcess
BEGIN
    SET @CurrentRow = @CurrentRow + 1

    SELECT @Email = Email,
        @LocationID = LocationID,
        @PackageID = PackageID,
        @UnitPrice = UnitPrice,
        @Quantity = Quantity,
        @Note = Note
    FROM @CUstomerOrder
    WHERE RowID=@CurrentRow

    SET @ErrorText = 'Failed check for variable @TotalAmount!';
    SET @TotalAmount =  (@Quantity * @UnitPrice)
    IF @TotalAmount <= 0
    BEGIN
        SET @ErrorText = 'TotalAmout = ' + CONVERT(VARCHAR(10), @TotalAmount) + ' This value is not acceptable. Rasing Error!';
        RAISERROR(@ErrorText, 16,1);
    END;

    SET @TotalTotalAmount = @TotalTotalAmount + @TotalAmount;

    IF @CurrentRow = 1
    BEGIN
        SET @ErrorText = 'Failed Calling SP GetMaxOrderID!';
        EXEC Alps.GetMaxOrderID @MaxOrderID = @OrderID OUTPUT;

        SET @Message = 'OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' is the return value from SP Alps.GetMaxOrderID.';
        RAISERROR (@Message, 0,1) WITH NOWAIT;
        EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;

        SET @ErrorText = 'Failed Calling SP InsertOrder!';
        EXEC Alps.InsertOrder @OrderID = @OrderID,
                                @CustomerID = @CustomerID,
                                @TotalAmount = @TotalAmount;

        SET @Message = 'Completed adding the Order in Order table.';
        RAISERROR (@Message, 0,1) WITH NOWAIT;
        EXEC Alps.InsertHistory @SP = @SP,
            @Status = 'Run',
            @Message = @Message;
    END

    SET @ErrorText = 'Failed Calling SP InsertOrderDetail!';
    EXEC Alps.InsertOrderDetail @OrderID = @OrderID,
                                  @LocationID = @LocationID,
                                  @PackageID = @PackageID,
                                  @UnitPrice = @UnitPrice,
                                  @Quantity = @Quantity

    SET @Message = 'Completed adding the Order in OrderDetil table.';
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC Alps.InsertHistory @SP = @SP,
                              @Status = 'Run',
                              @Message = @Message;
END

SET @ErrorText = 'Failed Calling SP UpdateOrder!';
EXEC Alps.UpdateOrder @OrderID = @OrderID,
                        @TotalAmount = @TotalTotalAmount
SET @Message = 'Completed UPDATE the Order for Total Amount.';
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
    @Status = 'Run',
    @Message = @Message;

SET @ErrorText = 'Failed TRUNCATE TABLE CustomerOrder!';
TRUNCATE TABLE Alps.CustomerOrder;
SET @Message = 'TRUNCATE TABLE CustomerOrder.';
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
    @Status = 'Run',
    @Message = @Message;

-------------------------------------------------------------------------------
-- COMMIT TRANSACTION;  
-------------------------------------------------------------------------------

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
   
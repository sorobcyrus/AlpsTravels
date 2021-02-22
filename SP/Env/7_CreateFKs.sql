IF EXISTS (
SELECT *
FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'Alps'
  AND SPECIFIC_NAME = N'CreateFKs'
  AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE Alps.CreateFKs
GO
CREATE PROCEDURE Alps.CreateFKs
AS
/***************************************************************************************************
File: CreateFKs.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.CreateFKs
Create Date:    2020-09-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Creates FKs for all needed Alps tables  
Call by:        TBD, UI, Add hoc
Steps:          NA
Parameter(s):   None
Usage:          EXEC Alps.CreateFKs
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
										Pre 2016 version
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText VARCHAR(MAX),      
        @Message   VARCHAR(255),   
        @StartTime DATETIME,
        @SP        VARCHAR(50)

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = OBJECT_NAME(@@PROCID)
SET @StartTime = GETDATE();
   
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
    @Status = 'Start',
    @Message = @Message;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed adding FOREIGN KEY for Table Alps.Customer.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'Alps.FK_Customer_Country_CountryID')
	AND parent_object_id = OBJECT_ID(N'Alps.Customer')
	)
BEGIN
  SET @Message = 'FOREIGN KEY for Table Alps.Customer already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Alps.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE Alps.Customer
	ADD CONSTRAINT FK_Customer_Country_CountryID FOREIGN KEY (CountryID)
    REFERENCES Alps.Country (CountryID);

  SET @Message = 'Completed adding FOREIGN KEY for TABLE Alps.Customer.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed adding FOREIGN KEY for Table Alps.Order.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'Alps.FK_Order_Customer_CustomerID')
	AND parent_object_id = OBJECT_ID(N'Alps.Order')
)
BEGIN
  SET @Message = 'FOREIGN KEY for Table Alps.Order already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE Alps.[Order]
   ADD CONSTRAINT FK_Order_Customer_CustomerID FOREIGN KEY (CustomerID)
      REFERENCES Alps.Customer (CustomerID),
   CONSTRAINT FK_Order_OrderStatus_OrderStatusID FOREIGN KEY (OrderStatusID)
      REFERENCES Alps.OrderStatus (OrderStatusID);

  SET @Message = 'Completed adding FOREIGN KEY for TABLE Alps.Order.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed adding FOREIGN KEY for Table Alps.OrderDetail.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'Alps.FK_OrderDetail_Order_OrderID')
	AND parent_object_id = OBJECT_ID(N'Alps.OrderDetail')
)
BEGIN
  SET @Message = 'FOREIGN KEY for Table Alps.OrderDetail already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE Alps.OrderDetail
   ADD CONSTRAINT FK_OrderDetail_Order_OrderID FOREIGN KEY (OrderID)
      REFERENCES Alps.[Order] (OrderID),
    CONSTRAINT FK_OrderDetail_Location_LocationID FOREIGN KEY (LocationID)
      REFERENCES Alps.[Location] (LocationID),
    CONSTRAINT FK_OrderDetail_Package_PackageID FOREIGN KEY (PackageID)
      REFERENCES Alps.[Package] (PackageID);

  SET @Message = 'Completed adding FOREIGN KEY for TABLE Alps.OrderDetail.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
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


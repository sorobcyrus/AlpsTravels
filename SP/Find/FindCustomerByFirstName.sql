CREATE OR ALTER PROCEDURE Alps.FindCustomerByFirstName
   @FirstName NVARCHAR(50)
AS
/***************************************************************************************************
File: FindCustomerByFirstName.sql
----------------------------------------------------------------------------------------------------
Procedure:      Alps.FindCustomerByFirstName
Create Date:    2020-09-01 (yyyy-mm-dd)
Author:         Sorob Cyrus
Description:    Finds a customer info by First Name 
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @FirstName
Usage:          Alps.FindCustomerByFirstName 'Fi'
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
SET @FirstName = RTRIM(@FirstName) + '%';

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC Alps.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed to SELECT from table Customer!';
SELECT CU.CustomerID,
   CU.FirstName,
   CU.LastName,
   CU.Email,
   CO.Name AS CountryName,
   CU.ID,
   CU.Tel1,
   CU.Tel2,
   CU.Website,
   CU.Address,
   CU.Note
FROM Alps.Customer AS CU WITH (NOLOCK)
   INNER JOIN Alps.Country CO WITH (NOLOCK)
   ON CU.CountryID = CO.CountryID
WHERE CU.FirstName LIKE @FirstName;
SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed SELECT from table Customer using FirstName = ' + @FirstName;   
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


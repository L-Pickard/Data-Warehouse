USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER  
    
 PROCEDURE [dbo].[Update fBrand Forecast Data]
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Timestamp DATETIME2(0)
            ,@Table NVARCHAR(50)
            ,@Action NVARCHAR(200)
            ,@Rows INTEGER
            ,@Status NVARCHAR(10)
            ,@Start_Date DATE
            ,@End_Date DATE
            ,@Error_Message NVARCHAR(1000);

        ALTER TABLE [Warehouse].[dbo].[fBrand Forecast] NOCHECK CONSTRAINT ALL;

        TRUNCATE TABLE [Warehouse].[dbo].[fBrand Forecast];

        BULK INSERT [Warehouse].[dbo].[fBrand Forecast]
        FROM 
            '\\WHServer\Users\eo.pickard\Desktop\Data-Warehouse\Update Scripts\Documents\FY 24-25 Brand Revenue Forecast Data.csv' 
            WITH (
                FIELDTERMINATOR = ','
                ,ROWTERMINATOR = '\n'
                ,FIRSTROW = 2
                );

        SELECT @Timestamp = GETDATE()
            ,@Table = 'fBrand Forecast'
            ,@Action = 'Update fBrand Forecast Table'
            ,@Rows = (
                SELECT COUNT(*)
                FROM [Warehouse].[dbo].[fBrand Forecast]
                )
            ,@Status = 'Success'
            ,@Start_Date = NULL
            ,@End_Date = NULL
            ,@Error_Message = NULL;

        EXEC [Insert Record Into Update Log] @Timestamp = @Timestamp
            ,@Table = @Table
            ,@Action = @Action
            ,@Rows = @Rows
            ,@Status = @Status
            ,@Start_Date = @Start_Date
            ,@End_Date = @End_Date
            ,@Error_Message = @Error_Message

        ALTER TABLE [Warehouse].[dbo].[fBrand Forecast] CHECK CONSTRAINT ALL;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF (XACT_STATE()) = - 1
        BEGIN
            --The below code enters a failure record into the update log table
            SELECT @Timestamp = GETDATE()
                ,@Table = 'fBrand Forecast'
                ,@Action = 'Update fBrand Forecast Table'
                ,@Rows = NULL
                ,@Status = 'Failure'
                ,@Start_Date = NULL
                ,@End_Date = NULL
                ,@Error_Message = (
                    SELECT CONCAT (
                            ERROR_NUMBER()
                            ,' - '
                            ,ERROR_MESSAGE()
                            )
                    )

            EXEC [Insert Record Into Update Log] @Timestamp = @Timestamp
                ,@Table = @Table
                ,@Action = @Action
                ,@Rows = @Rows
                ,@Status = @Status
                ,@Start_Date = @Start_Date
                ,@End_Date = @End_Date
                ,@Error_Message = @Error_Message;

            ROLLBACK TRANSACTION;
        END
    END CATCH
END
GO
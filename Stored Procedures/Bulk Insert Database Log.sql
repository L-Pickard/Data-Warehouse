USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER PROCEDURE [dbo].[Bulk Insert Database Log]
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @Log_File_Path NVARCHAR(80)
        ,@Rows_Inserted INT
        ,@Level NVARCHAR(10)
        -- ,@Truncate_Command NVARCHAR(300)
        ,@Table NVARCHAR(50)
        ,@Action NVARCHAR(500)
        ,@Message NVARCHAR(MAX)

    -- SET @Log_File_Path = 'C:\Users\leo.pickard\Desktop\Finance db\Database Log\finance_db.log'
    BEGIN TRY
        -- Enable advanced options
        -- EXEC sp_configure 'show advanced options'
        --     ,1;
        -- RECONFIGURE;
        -- -- Enable xp_cmdshell
        -- EXEC sp_configure 'xp_cmdshell'
        --     ,1;
        BEGIN TRANSACTION;

        BULK INSERT [dbo].[Database Log]
        FROM '\\WHServer\Users\leo.pickard\Desktop\Data-Warehouse\Database Log\finance_db.log' WITH (
                FIELDTERMINATOR = '~'
                ,ROWTERMINATOR = '\n'
                ,FIRSTROW = 2
                ,TABLOCK
                );

        -- SET @Rows_Inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT @Message = ERROR_MESSAGE()

        EXEC [dbo].[Insert Record Into Database Log] @Level = 'ERROR'
            ,@Table = 'Database Log'
            ,@Action = 'Bulk insert into new entries into database log table.'
            ,@Message = @Message
    END CATCH
        --     IF @Rows_Inserted > 0
        --     BEGIN
        --         RECONFIGURE;
        --         SET @Truncate_Command = 'echo. > "' + @Log_File_Path + '"';
        --         EXEC xp_cmdshell @Truncate_Command;
        --     END
        --             -- Disable xp_cmdshell
        --             -- EXEC sp_configure 'xp_cmdshell'
        --             --     ,0;
        --             -- RECONFIGURE;
        -- END
END
GO
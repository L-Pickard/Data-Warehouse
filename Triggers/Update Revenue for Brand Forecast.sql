USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER TRIGGER [dbo].[trg_UpdateRevenue] ON [dbo].[fBrand Forecast]
AFTER INSERT
    ,UPDATE
AS
BEGIN
    -- Update GBP Revenue

    UPDATE [fBrand Forecast]
    SET [GBP Revenue] = CASE 
            WHEN [Currency] = 'GBP'
                THEN [Revenue]
            ELSE [Revenue] * (
                    SELECT [Value]
                    FROM [fMonth Avg XR]
                    WHERE [fBrand Forecast].[Date] BETWEEN [Start Date]
                            AND [End Date]
                        AND [From Currency] = [fBrand Forecast].[Currency]
                        AND [To Currency] = 'GBP'
                    )
            END
        ,[EUR Revenue] = CASE 
            WHEN [Currency] = 'EUR'
                THEN [Revenue]
            ELSE [Revenue] * (
                    SELECT [Value]
                    FROM [fMonth Avg XR]
                    WHERE [fBrand Forecast].[Date] BETWEEN [Start Date]
                            AND [End Date]
                        AND [From Currency] = [fBrand Forecast].[Currency]
                        AND [To Currency] = 'EUR'
                    )
            END
        ,[USD Revenue] = CASE 
            WHEN [Currency] = 'USD'
                THEN [Revenue]
            ELSE [Revenue] * (
                    SELECT [Value]
                    FROM [fMonth Avg XR]
                    WHERE [fBrand Forecast].[Date] BETWEEN [Start Date]
                            AND [End Date]
                        AND [From Currency] = [fBrand Forecast].[Currency]
                        AND [To Currency] = 'USD'
                    )
            END;
END;
GO

ALTER TABLE [dbo].[fBrand Forecast] ENABLE TRIGGER [trg_UpdateRevenue]
GO
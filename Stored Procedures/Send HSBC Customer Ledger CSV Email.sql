USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[Send HSBC Customer Ledger CSV Email]
AS
/*===============================================================================================================================================
Project: HSBC - Shiner Ltd Customer Ledger Report
Language: T-SQL
Author: Leo Pickard
Version: 1.0
Date: 31/10/2024
=================================================================================================================================================
This stored procedure sends out the new HSBC - Shiner Ltd customer ledger email with an attached csv report.
=================================================================================================================================================*/
DECLARE @Date_String NVARCHAR(12)
    ,@Format_Dt AS NVARCHAR(19)
    ,@File_Path NVARCHAR(150)
    ,@Recipients VARCHAR(150)
    ,@Body NVARCHAR(MAX)
    ,@Subject AS NVARCHAR(78)

SET @Date_String = FORMAT(GETDATE(), 'dd.MM.yyyy')
SET @Format_Dt = FORMAT(GETDATE(), 'dd/MM/yyyy');
SET @File_Path = CONCAT (
        '//WHServer/Users/leo.pickard/Desktop/Automated Projects\HSBC\HSBC - Shiner Ltd Customer Ledger '
        ,@Date_String
        ,'.csv'
        )
SET @Recipients = '<********************************>'

SET @Subject = CONCAT_WS(' ', 'Shiner Ltd Customer Ledger - Universal Connector CSV - ', @Format_Dt);


SET @Body = '
<!DOCTYPE html>
<p style="font-family: Arial, Helvetica, Times, serif; font-size: 20px;">
  <strong>Shiner Ltd Customer Ledger - Universal Connector CSV</strong>
</p>
<p>&nbsp;</p>
<p style="font-family: Arial, Helvetica, Times, serif; font-size: 12px;">
  Please see the attached semicolon separated CSV file.
</p>'

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Reports'
    ,@recipients = @Recipients
    ,@body = @Body
    ,@subject = @Subject
    ,@from_address = '<reports@org.co.uk>'
    ,@reply_to = '<reports@org.co.uk>'
    ,@file_attachments = @File_Path
    ,@body_format = 'HTML';
GO
USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[fRedwood Update Error Email] AS

DECLARE @SalespersonCode NVARCHAR(30)
    ,@Email NVARCHAR(100)
    ,@Recipients VARCHAR(102)
    ,@Body NVARCHAR(MAX)
    ,@EmailDatetime AS NVARCHAR(19)
    ,@FormatDatetime AS NVARCHAR(19)
    ,@Subject AS NVARCHAR(78)

SET @EmailDatetime = FORMAT(GETDATE(), 'dd-MM-yyyy HH.mm')
SET @FormatDatetime = FORMAT(GETDATE(), 'dd/MM/yyyy HH:mm:ss')
SET @Recipients = (
        SELECT CAST(CONCAT (
                    '<'
                    ,'********************'
                    ,'>'
                    ) AS VARCHAR(102))
        )
SET @Subject = CONCAT (
        'fRedwood Table Update Error - '
        ,@FormatDatetime
        )
SET @body = 
    '<!DOCTYPE html>
<html>
<head>
<style>
h1 {
  font-family: Arial, Helvetica, Times, serif;
  font-size: 16px;
}

p {
  font-family: Arial, Helvetica, Times, serif;
  font-size: 14px;
}

</style>
</head>
<body>

<h1>fRedwood Table Update Error</h1>
<br>
<p>The fRedwood table has not been updated because the source file does not have a date modified of today  @ ' 
    + @FormatDatetime + '</p>'

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Reports'
    ,@recipients = @Recipients
    ,@body = @Body
    ,@subject = @Subject
    ,@from_address = '<reports@shiner.co.uk>'
    ,@reply_to = '<reports@shiner.co.uk>'
    ,@body_format = 'HTML';
GO

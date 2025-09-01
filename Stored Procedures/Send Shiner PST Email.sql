USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[Send Org PST Email]
AS
/*===============================================================================================================================================
Project: Org Group Potential Sell Through
Language: T-SQL
Author: Leo Pickard
Version: 1.0
Date: 15/08/2024
=================================================================================================================================================
This stored procedure sends out the new PST email with an attached formatted xlsx report. In this procedure we create a html table and append
the results of a query as the table rows, this table is a brand overview pst in the email body. The file attachment is created by a python script
which then calls this stored procedure during execution.
=================================================================================================================================================*/
DECLARE @Date_String NVARCHAR(12)
    ,@Format_Dt AS NVARCHAR(19)
    ,@File_Path NVARCHAR(150)
    ,@Recipients VARCHAR(150)
    ,@XML NVARCHAR(MAX)
    ,@Body NVARCHAR(MAX)
    ,@Subject AS NVARCHAR(78)

SET @Date_String = FORMAT(GETDATE(), 'dd.MM.yyyy')
SET @Format_Dt = FORMAT(GETDATE(), 'dd/MM/yyyy');
SET @File_Path = CONCAT (
        'C:\Users\leo.pickard\Desktop\Automated Projects\Org PST\Org PST '
        ,@Date_String
        ,'.xlsx'
        )
SET @Recipients = '<**************>;<**************>;<**************>'

SET @Subject = CONCAT_WS(' ', 'Org Potential Sell Through -', @Format_Dt);

WITH Sales_Orders
AS (
    SELECT [Item No]
        ,CASE 
            WHEN [Entity] = 'Org Ltd'
                AND [Customer No] NOT IN (
                      'CU110036' -- Org LLC (Management Recharge)
                    , 'CU110077' -- Org LLC
                    )
                THEN [Outstanding Qty]
            WHEN [Entity] = 'Org B.V'
                AND [Customer No] NOT IN (
                      'CU110036' -- Org LLC (Management Recharge)
                    , 'CU110077' -- Org LLC
                    , 'CU103500' -- Org Limited
                    )
                AND [Document No] NOT IN (
                    SELECT [Document No]
                    FROM [fOrderbook]
                    WHERE [Entity] = 'Org Ltd'
                        AND [Document No] IS NOT NULL
                    )
                THEN [Outstanding Qty]
            WHEN [Entity] = 'Org LLC'
                AND [Intercompany] = 0
                AND [Exclusion] = 0
                THEN [Outstanding Qty]
            ELSE 0
            END AS [Outstanding Qty]
    FROM [fOrderbook]
    )
    ,Purchase_Orders
AS (
    SELECT [Item No]
        ,SUM(CASE 
                WHEN [Entity] = 'Org B.V'
                    AND [Vendor No] = 'VE100927' -- Org Ltd - Back to Back
                    THEN 0
                ELSE [Outstanding Qty]
                END) AS [Outstanding Qty]
    FROM fPurchases
    GROUP BY [Item No]
    )
SELECT @XML = CAST((
            SELECT CASE 
                    WHEN it.[Brand Code] <> br.[Budget Category]
                        THEN br.[Budget Category]
                    ELSE br.[Brand Name]
                    END AS [td]
                ,''
                ,FORMAT(ISNULL(SUM(iv.[Free Stock]), 0), 'N0') AS [td]
                ,''
                ,FORMAT(ISNULL(SUM(iv.[Inventory]), 0), 'N0') AS [td]
                ,''
                ,FORMAT(ISNULL(SUM(po.[Outstanding Qty]), 0), 'N0') AS [td]
                ,''
                ,FORMAT(ISNULL(SUM(so.[Outstanding Qty]), 0), 'N0') AS [td]
                ,''
                ,FORMAT(ISNULL(SUM(sp.[Shipped in Last 180 Days]), 0), 'N0') AS [td]
                ,''
                ,FORMAT(CAST(ISNULL(SUM(sp.[Shipped in Last 180 Days]), 0.0) AS DECIMAL(20, 8)) / 6.0
                    , 'N2') AS [td]
                ,''
                ,ISNULL(FORMAT(CAST((
                                (
                                    ISNULL(SUM(iv.[Inventory]), 0) + ISNULL(SUM(po.
                                            [Outstanding Qty]), 0)
                                    ) - ISNULL(SUM(so.[Outstanding Qty]), 0)
                                ) AS DECIMAL(20, 8)) / NULLIF((CAST(SUM(sp.[Shipped in Last 180 Days]) AS DECIMAL(20, 8)) / 6.0
                                ), 0.0), 'N2'), ' ') AS [td]
            FROM [dItem] AS it
            LEFT JOIN [dBrand] AS br
                ON it.[Brand Code] = br.[Brand Code]
            LEFT JOIN (
                SELECT [Item No]
                    ,[Free Stock]
                    ,[Inventory]
                FROM [dInventory]
                ) AS iv
                ON it.[Item No] = iv.[Item No]
            LEFT JOIN (
                SELECT [Item No]
                    ,SUM([Shipped in Last 180 Days]) AS [Shipped in Last 180 Days]
                FROM [fShipped Qty]
                GROUP BY [Item No]
                ) AS sp
                ON it.[Item No] = sp.[Item No]
            LEFT JOIN Purchase_Orders AS po
                ON it.[Item No] = po.[Item No]
            LEFT JOIN (
                SELECT [Item No]
                    ,SUM([Outstanding Qty]) AS [Outstanding Qty]
                FROM Sales_Orders
                GROUP BY [Item No]
                ) AS so
                ON it.[Item No] = so.[Item No]
            WHERE (
                    ISNULL(iv.[Free Stock], 0) <> 0
                    OR ISNULL(po.[Outstanding Qty], 0) <> 0
                    OR ISNULL(so.[Outstanding Qty], 0) <> 0
                    OR ISNULL(sp.[Shipped in Last 180 Days], 0) <> 0
                    )
                AND it.[Brand Code] NOT IN ('', 'ONC', 'DTY', 'DEL', 'B2C', 'SHN', 'DLX', 'ECO', 'NHS'
                    )
            GROUP BY CASE 
                    WHEN it.[Brand Code] <> br.[Budget Category]
                        THEN br.[Budget Category]
                    ELSE br.[Brand Name]
                    END
            ORDER BY CASE 
                    WHEN it.[Brand Code] <> br.[Budget Category]
                        THEN br.[Budget Category]
                    ELSE br.[Brand Name]
                    END
            FOR XML PATH('tr')
                ,ELEMENTS
            ) AS NVARCHAR(MAX))

SET @Body = 
    '
<!DOCTYPE html>
<html>
<head>
<style>
h1 {
  font-family: Arial, Helvetica, Times, serif;
  font-size: 14px; /* Reduced from 16px */
}

p {
  font-family: Arial, Helvetica, Times, serif;
  font-size: 12px; /* Reduced from 14px */
}

.small-text {
  font-family: Arial, Helvetica, Times, serif;
  font-size: 8px;
}

#pst {
  font-family: Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
  max-width: 600px; /* Set a maximum width to make the table smaller */
}

#pst td, #pst th {
  border: 0.5px solid #000000;
  padding: 3px; /* Reduced from 5px */
  font-size: 8px; /* Reduced from 9px */
  text-align: center;
}

#pst tr:nth-child(even) {
  background-color: #f2f2f2;
}

#pst tr:hover {
  background-color: #C6EFCE;
  color: #006100;
}

#pst th {
  padding-top: 3px; /* Reduced from 5px */
  padding-bottom: 3px; /* Reduced from 5px */
  text-align: center;
  background-color: #808080;
  color: white;
  font-size: 9px; /* Reduced from 10px */
  border: 0.5px solid #000000;
  position: sticky;
  top: 0;
  z-index: 100;
}

</style>
</head>
<body>

<h1>Org Potential Sell Through - ' + @Format_Dt + '</h1>
<br/>
<p>Please see attached the new PST excel document, the below table shows a brand overview.</p>
<br/>

<table id="pst">
  <tr>
    <th>Brand Name</th>
    <th>Free Stock</th>
    <th>Inventory</th>
    <th>PO Qty</th>
    <th>SO Qty</th>
    <th>L180D</th>
    <th>30D Avg</th>
    <th>6M PST</th>
  </tr>
'
SET @Body = @Body + @XML + 
    '</table>
<p class="small-text">Excluded Brands: ONC, DTY, DEL, B2C, SHN, DLX, ECO, NHS</p>
<br/>
<h2 style="font-size: 10px; font-family: Arial, Helvetica, Times, serif;">PST Exclusions</h2>
<ul style="font-size: 9px; font-family: Arial, Helvetica, Times, serif;">
  <li>Org Ltd
    <ul>
    <br/>
      <li>Shipped Qtys
        <ul>
        <br/>
          <li>CU110036 Org LLC (Management Recharge)</li>
          <li>CU110077 Org LLC</li>
        </ul>
      </li>
      <br/>
      <li>Sales Order Qtys
        <ul>
        <br/>
          <li>CU110036 Org LLC (Management Recharge)</li>
          <li>CU110077 Org LLC</li>
        </ul>
      </li>
      <br/>
    </ul>
  </li>
  <br/>
  <li>Org B.V
    <ul>
    <br/>
      <li>Shipped Qtys
        <ul>
        <br/>
          <li>CU110036 Org LLC (Management Recharge)</li>
          <li>CU110077 Org LLC</li>
          <li>CU103500 Org Limited</li>
          <li>All B.V invoices where sales order number exists in Ltd</li>
        </ul>
      </li>
      <br/>
      <li>Sales Order Qtys
        <ul>
        <br/>
          <li>CU110036 Org LLC (Management Recharge)</li>
          <li>CU110077 Org LLC</li>
          <li>CU103500 Org Limited</li>
          <li>All B.V orders where sales order number exists in Ltd</li>
        </ul>
      </li>
      <br/>
      <li>Purchase Order Qtys
        <ul>
        <br/>
          <li>VE100927 Org Ltd - Back to Back</li>
        </ul>
      </li>
    </ul>
  </li>
  <br/>
  <li>Org LLC
    <ul>
    <br/>
      <li>Shipped Qtys
        <ul>
        <br/>
          <li>UC000650 Management Recharge Org Ltd</li>
          <li>UC000653 Management recharge Org EU BV</li>
          <li>UC000340 Org Marketing</li>
          <li>UC000458 Org Ltd</li>
        </ul>
      </li>
      <br/>
      <li>Sales Order Qtys
        <ul>
        <br/>
          <li>UC000650 Management Recharge Org Ltd</li>
          <li>UC000653 Management recharge Org EU BV</li>
          <li>UC000340 Org Marketing</li>
          <li>UC000458 Org Ltd</li>
        </ul>
      </li>
    </ul>
  </li>
</ul>
</body></html>'

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Reports'
    ,@recipients = @Recipients
    ,@body = @Body
    ,@subject = @Subject
    ,@from_address = '<reports@Org.co.uk>'
    ,@reply_to = '<reports@Org.co.uk>'
    ,@file_attachments = @File_Path
    ,@body_format = 'HTML';
GO
from SQL_Functions import (
    execute_sql_procedure,
    get_sql_dataframe,
    write_df_to_sql_db
)
from db_logger import write_to_log
from sqlalchemy.types import Integer, Date, NVARCHAR, DECIMAL
from pandas import concat
from datetime import datetime, timedelta
import os

def main():
    
    script_name = os.path.basename(__file__)
    
    try:
        
        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fGL Entry Collect Date SQL Query.sql",
            "r",
        ) as file:
            last_date_sql = file.read()

        date_statements = last_date_sql.split(";")

        last_date_sql_ltd = date_statements[0].strip()
        last_date_sql_bv = date_statements[1].strip()
        last_date_sql_llc = date_statements[2].strip()

        df_date_ltd = get_sql_dataframe(
            server = "WHServer",
            db = "Warehouse",
            table = "Increment Date",
            sql = last_date_sql_ltd,
            action = "Executed get last fGL Entry increment date query for Org Ltd.",
            script = script_name,
        )

        df_date_bv = get_sql_dataframe(
            server = "WHServer",
            db = "Warehouse",
            table = "Increment Date",
            sql = last_date_sql_bv,
            action = "Executed get last fGL Entry increment date query for Org B.V.",
            script = script_name,
        )

        df_date_llc = get_sql_dataframe(
            server = "WHServer",
            db = "Warehouse",
            table = "Increment Date",
            sql = last_date_sql_llc,
            action = "Executed get last fGL Entry increment date query for Org LLC.",
            script = script_name,
        )

        coldate_ltd = df_date_ltd["Collect Date fGL Entry"].iloc[0]
        coldate_bv = df_date_bv["Collect Date fGL Entry"].iloc[0]
        coldate_llc = df_date_llc["Collect Date fGL Entry"].iloc[0]

        date_ltd = datetime.strptime(coldate_ltd, "%Y-%m-%d")
        date_bv = datetime.strptime(coldate_bv, "%Y-%m-%d")
        date_llc = datetime.strptime(coldate_llc, "%Y-%m-%d")

        max_date = max(date_ltd, date_bv, date_llc)
        max_date_plus_one = max_date + timedelta(days=1)
        max_date_plus_one_str = max_date_plus_one.strftime("%Y-%m-%d")

        today = datetime.now()
        yesterday = today - timedelta(days=1)
        yesterday_formatted = yesterday.strftime("%Y-%m-%d")

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fGL Entry sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        sqlukeu_content = sqlukeu_content.replace("{COLDATE_LTD}", coldate_ltd)
        sqlukeu_content = sqlukeu_content.replace("{COLDATE_BV}", coldate_bv)

        df_sqlukeu = get_sql_dataframe(
            server = "UKEUServer",
            db = "LIVE",
            table = "fGL Entry",
            sql = sqlukeu_content,
            action = "Executed sqlukeu fGL Entry query.",
            script = script_name,
            start = coldate_ltd,
            end = yesterday_formatted
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fGL Entry sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        sqlus_content = sqlus_content.replace("{COLDATE_LLC}", coldate_llc)

        df_sqlus = get_sql_dataframe(
            server = "USServer",
            db = "LIVE_USA",
            table = "fGL Entry",
            sql = sqlus_content,
            action = "Executed sqlus fGL Entry query.",
            script = script_name,
            start = coldate_llc,
            end = yesterday_formatted
        )

        df_fGL_Entry = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        df_fGL_Entry["User ID"] = df_fGL_Entry["User ID"].str.replace(
            r"SHINER\\", "", regex=True
        )

        dtype_mapping = {
            "[Date Key]": Integer(),
            "[Posting Date]": Date(),
            "[Entity]": NVARCHAR(10),
            "[Entry No]": Integer(),
            "[GL Account No]": NVARCHAR(8),
            "[Document Type]": NVARCHAR(20),
            "[Document No]": NVARCHAR(30),
            "[Description]": NVARCHAR(100),
            "[User ID]": NVARCHAR(20),
            "[Source Code]": NVARCHAR(10),
            "[Source Type]": Integer(),
            "[Source No]": NVARCHAR(20),
            "[Balance Account No]": NVARCHAR(20),
            "[GBP Amount]": DECIMAL(20, 8),
            "[GBP VAT Amount]": DECIMAL(20, 8),
            "[GBP Debit Amount]": DECIMAL(20, 8),
            "[GBP Credit Amount]": DECIMAL(20, 8),
            "[GBP XR Date]": Date(),
            "[GBP XR]": DECIMAL(12, 8),
            "[EUR Amount]": DECIMAL(20, 8),
            "[EUR VAT Amount]": DECIMAL(20, 8),
            "[EUR Debit Amount]": DECIMAL(20, 8),
            "[EUR Credit Amount]": DECIMAL(20, 8),
            "[EUR XR Date]": Date(),
            "[EUR XR]": DECIMAL(12, 8),
            "[USD Amount]": DECIMAL(20, 8),
            "[USD VAT Amount]": DECIMAL(20, 8),
            "[USD Debit Amount]": DECIMAL(20, 8),
            "[USD Credit Amount]": DECIMAL(20, 8),
            "[USD XR Date]": Date(),
            "[USD XR]": DECIMAL(12, 8),
        }

        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "fGL Entry Staging",
            sql = "TRUNCATE TABLE [fGL Entry Staging];",
            action = "Execute truncate fGL Entry Staging table.",
            script = script_name
        )

        num_rows = len(df_fGL_Entry)

        write_df_to_sql_db(
            server = "WHServer",
            db = "Warehouse",
            table = "fGL Entry Staging",
            df = df_fGL_Entry,
            dtype = dtype_mapping,
            action = "Write dataframe to fGL Entry Staging table.",
            script = script_name,
            rows = num_rows,
            start = max_date_plus_one_str,
            end = yesterday_formatted
        )

        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "fGL Entry",
            sql = "EXEC [Insert New Rows Into fGL Entry];",
            action = "Execute [Insert New Rows Into fGL Entry] Procedure.",
            script = script_name,
            rows = num_rows,
            start = max_date_plus_one_str,
            end = yesterday_formatted
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="fGL Entry",
        action_txt = "Execute script to update fGL Entry table. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.")

if __name__ == "__main__":
    main()
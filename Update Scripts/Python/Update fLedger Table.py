from SQL_Functions import (
    execute_sql_procedure,
    get_sql_dataframe,
    write_df_to_sql_db
)
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR, INTEGER, DATE, DECIMAL
from pandas import concat
import os

def main():
    
    script_name = os.path.basename(__file__)
    
    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fLedger sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server = "Shinersqlukeu",
            db = "Nav_LIVE",
            table = "fLedger",
            sql = sqlukeu_content,
            action = "Executed sqlukeu fLedger query.",
            script = script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fLedger sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server = "USServer",
            db = "LIVE_USA",
            table = "fLedger",
            sql = sqlus_content,
            action = "Executed sqlus fLedger query.",
            script = script_name,
        )

        df_fLedger = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        num_rows = len(df_fLedger)

        dtype_mapping = {
            "[Posting Date]": DATE(),
            "[Entity]": NVARCHAR(10),
            "[Entry Type]": NVARCHAR(30),
            "[Brand Code]": NVARCHAR(3),
            "[Item No]": NVARCHAR(30),
            "[Location Code]": NVARCHAR(50),
            "[Quantity]": INTEGER(),
            "[Currency]": NVARCHAR(3),
            "[Cost Value]": DECIMAL(20, 8),
        }

        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "fLedger",
            sql = "EXEC [Clear fLedger Table];",
            action = "Execute truncate fLedger table.",
            script = script_name
        )

        write_df_to_sql_db(
            server = "WHServer",
            db = "Warehouse",
            table = "fLedger",
            df = df_fLedger,
            dtype = dtype_mapping,
            action = "Write dataframe to fLedger table.",
            script = script_name,
            rows = num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="dItem",
        action_txt = "Execute script to update dItem table. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.")

if __name__ == "__main__":
    main()

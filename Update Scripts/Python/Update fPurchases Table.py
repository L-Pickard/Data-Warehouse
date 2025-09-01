from SQL_Functions import (
    execute_sql_procedure,
    get_sql_dataframe,
    write_df_to_sql_db
)
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR, DECIMAL, DATE, INTEGER
from pandas import concat
from datetime import datetime
import os

def main():
    
    script_name = os.path.basename(__file__)
    
    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fPurchases sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server = "UKEUServer",
            db = "LIVE",
            table = "fPurchases",
            sql = sqlukeu_content,
            action = "Executed sqlukeu fPurchases query.",
            script = script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fPurchases sqlus Query.sql",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server = "USServer",
            db = "LIVE_USA",
            table = "fPurchases",
            sql = sqlus_content,
            action = "Executed sqlus fPurchases query.",
            script = script_name,
        )

        df_fPurchases = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        today_date = datetime.today().strftime('%Y-%m-%d')

        df_fPurchases['ETA Date'] = df_fPurchases['ETA Date'].replace('1753-01-01', today_date)
        
        df_fPurchases[['Item No', 'Vendor No']] = df_fPurchases[['Item No', 'Vendor No']].fillna('')

        num_rows = len(df_fPurchases)

        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "fPurchases",
            sql = "EXEC [Clear fPurchases Table];",
            action = "Execute truncate fPurchases table.",
            script = script_name
        )

        dtype_mapping = {
            "[Entity]": NVARCHAR(10),
            "[ETA Date]": DATE(),
            "[Document No]": NVARCHAR(30),
            "[Vendor No]": NVARCHAR(30),
            "[Location Code]": NVARCHAR(50),
            "[Your Reference]": NVARCHAR(100),
            "[Invoice No]": NVARCHAR(100),
            "[Item No]": NVARCHAR(30),
            "[Currency]": NVARCHAR(30),
            "[Quantity]": INTEGER(),
            "[Line Total]": DECIMAL(20, 8),
            "[Qty Received]": INTEGER(),
            "[Outstanding Qty]": INTEGER(),
            "[Outstanding Value]": DECIMAL(20, 8),
            "[Reserved Qty]": INTEGER(),
            "[PO Freestock]": INTEGER(),
        }

        write_df_to_sql_db(
            server = "WHServer",
            db = "Warehouse",
            table = "fPurchases",
            df = df_fPurchases,
            dtype = dtype_mapping,
            action = "Write dataframe to fPurchases table.",
            script = script_name,
            rows = num_rows
        )
        
        
        #df_fPurchases.to_csv("C:/Users/leo.pickard/Desktop/Dataframe CSV/fPurchases New.csv", index=False)

        print(f"{script_name} finished. Number of rows written: {num_rows}")
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="fPurchases",
        action_txt = "Execute script to update fPurchases table. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()
from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR, INTEGER, DECIMAL
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fShipped Qty NAV OG sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="UKEUServer",
            db="LIVE",
            table="fShipped Qty NAV OG",
            sql=sqlukeu_content,
            action="Executed sqlukeu fShipped Qty NAV OG Query",
            script=script_name,
        )

        num_rows = len(df_sqlukeu)

        dtype_mapping = {
            "[Entity]": NVARCHAR(10),
            "[Item No]": NVARCHAR(30),
            "[Shipped in Last 360 Days]": INTEGER(),
            "[Shipped in Last 180 Days]": INTEGER(),
            "[Shipped 331 to 360 Days Ago]": INTEGER(),
            "[Shipped 301 to 330 Days Ago]": INTEGER(),
            "[Shipped 271 to 300 Days Ago]": INTEGER(),
            "[Shipped 241 to 270 Days Ago]": INTEGER(),
            "[Shipped 211 to 240 Days Ago]": INTEGER(),
            "[Shipped 181 to 210 Days Ago]": INTEGER(),
            "[Shipped 151 to 180 Days Ago]": INTEGER(),
            "[Shipped 121 to 150 Days Ago]": INTEGER(),
            "[Shipped 91 to 120 Days Ago]": INTEGER(),
            "[Shipped 61 to 90 Days Ago]": INTEGER(),
            "[Shipped 31 to 60 Days Ago]": INTEGER(),
            "[Shipped 1 to 30 Days Ago]": INTEGER(),
            "[Shipped 30 Day Avg]": DECIMAL(20, 8),
            "[Shipped 30 Day Avg 6M]": DECIMAL(20, 8),
        }

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="fShipped Qty NAV OG",
            sql="EXEC [Finance].[dbo].[Clear fShipped Qty Table NAV OG];",
            action="Execute truncate fShipped Qty Table NAV OG table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="fShipped Qty NAV OG",
            df=df_sqlukeu,
            dtype=dtype_mapping,
            action="Write dataframe to fShipped Qty NAV OG table.",
            script=script_name,
            rows=num_rows,
        )
        
        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="fShipped Qty NAV OG",
            sql="EXEC [Update LLC fShipped Qty NAV OG Values];",
            action="Execute insert LLC values into fShipped Qty NAV OG table.",
            script=script_name,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="fShipped Qty Table NAV OG",
            action_txt="Execute script to update fShipped Qty Table NAV OG table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(
            f"{script_name} has ran into a critical error during execution. See log file."
        )

if __name__ == "__main__":
    main()
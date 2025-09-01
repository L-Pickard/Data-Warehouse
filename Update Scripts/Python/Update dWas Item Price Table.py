from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR, DATE, DECIMAL
from pandas import concat
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dWas Item Price sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="UKEUServer",
            db="LIVE",
            table="dWas Item Price",
            sql=sqlukeu_content,
            action="Executed sqlukeu dWas Item Price query.",
            script=script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dWas Item Price sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server="USServer",
            db="LIVE_USA",
            table="dWas Item Price",
            sql=sqlus_content,
            action="Executed sqlus dWas Item Price query.",
            script=script_name,
        )

        df_dWas_Price = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        df_dWas_Price = df_dWas_Price.dropna(subset=["Was Trade Price"])

        num_rows = len(df_dWas_Price)

        dtype_mapping = {
            "[Item No]": NVARCHAR(30),
            "[First Sold Date]": DATE(),
            "[Period End Date]": DATE(),
            "[Currency]": NVARCHAR(3),
            "[Was Trade Price]": DECIMAL(20, 8),
        }

        execute_sql_procedure(
            server="Shinersql18",
            db="Finance",
            table="dWas Item Price",
            sql="EXEC [Finance].[dbo].[Clear dWas Item Price]",
            action="Execute truncate dWas Item Price table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="dWas Item Price",
            df=df_dWas_Price,
            dtype=dtype_mapping,
            action="Write dataframe to dWas Item Price table.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dWas Item Price",
            action_txt="Execute script to update dWas Item Price table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()

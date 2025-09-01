from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import DATE, NVARCHAR, DECIMAL
from pandas import concat
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fExchange Rates sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="UKEUServer",
            db="LIVE",
            table="fExchange Rates",
            sql=sqlukeu_content,
            action="Executed sqlukeu fExchange Rates query.",
            script=script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fExchange Rates sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server="USServer",
            db="LIVE_USA",
            table="fExchange Rates",
            sql=sqlus_content,
            action="Executed sqlus fExchange Rates query.",
            script=script_name,
        )

        df_fExchange_Rates = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        num_rows = len(df_fExchange_Rates)

        dtype_mapping = {
            "[Entity]": NVARCHAR(10),
            "[Currency Code]": NVARCHAR(3),
            "[Relational Currency Code]": NVARCHAR(3),
            "[Starting Date]": DATE(),
            "[Exchange Rate Amount]": DECIMAL(20, 8),
        }

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="fExchange Rates",
            sql="EXEC [Clear fExchange Rates Table];",
            action="Execute truncate fExchange Rates table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="fExchange Rates",
            df=df_fExchange_Rates,
            dtype=dtype_mapping,
            action="Write dataframe to fExchange Rates table.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="fExchange Rates",
            action_txt="Execute script to update fExchange Rates table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()

from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR
from pandas import concat
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dSalesperson sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="UKEUServer",
            db="LIVE",
            table="dSalesperson",
            sql=sqlukeu_content,
            action="Executed sqlus dCountry query.",
            script=script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dSalesperson sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server="USServer",
            db="LIVE_USA",
            table="dSalesperson",
            sql=sqlus_content,
            action="Executed sqlus dCountry query.",
            script=script_name,
        )

        salesperson_codes_df_sqlukeu = set(df_sqlukeu["Salesperson Code"])

        df_sqlus = df_sqlus[~df_sqlus["Salesperson Code"].isin(salesperson_codes_df_sqlukeu)]

        df_dSalesperson = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        num_rows = len(df_dSalesperson)

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="dSalesperson",
            sql="EXEC [Clear dSalesperson Table];",
            action="Execute truncate dCountry table.",
            script=script_name,
        )

        dtype_mapping = {
            "[Salesperson Code]": NVARCHAR(30),
            "[Name]": NVARCHAR(100),
            "[E-Mail]": NVARCHAR(100),
        }

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="dSalesperson",
            df=df_dSalesperson,
            dtype=dtype_mapping,
            action="Write dataframe to dSalesperson table.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dSalesperson",
            action_txt="Execute script to update dSalesperson table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()

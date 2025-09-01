from SQL_Functions import execute_sql_procedure
from db_logger import write_to_log
import os
from datetime import datetime, date


def main():

    script_name = os.path.basename(__file__)

    file_path = "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Redwood/Export Inventory Item -Redwood- R00390.csv"

    try:

        file_modified_time = os.path.getmtime(file_path)

        file_modified_date = datetime.fromtimestamp(file_modified_time).date()

        today_date = date.today()

        if file_modified_date == today_date:

            execute_sql_procedure(
                server="WHServer",
                db="LIVE",
                table="fRedwood",
                sql="EXEC [Update fRedwood];",
                action="Execute fRedwood table update procedure.",
                script=script_name,
            )

            print(f"{script_name} finished. fRedwood Table has been updated.")

        else:

            execute_sql_procedure(
                server="WHServer",
                db="Warehouse",
                table="fRedwood",
                sql="EXEC [Finance].[dbo].[fRedwood Update Error Email];",
                action="Execute fRedwood table update email error procedure.",
                script=script_name,
            )

            print(f"{script_name} has ran into a critical error during execution. See log file.")

    except Exception as e:

        print(f"An error occurred: {e}")

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="fRedwood",
            sql="EXEC [Finance].[dbo].[fRedwood Update Error Email];",
            action="Execute fRedwood table update email error procedure.",
            script=script_name,
        )

        write_to_log(
            script_txt=script_name,
            table_txt="fRedwood",
            action_txt="Execute script to update fRedwood table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()

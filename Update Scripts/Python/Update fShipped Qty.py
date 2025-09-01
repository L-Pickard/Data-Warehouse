from SQL_Functions import execute_sql_procedure
from db_logger import write_to_log
import os

def main():
    
    try:
    
        script_name = os.path.basename(__file__)

        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "fShipped Qty",
            sql = "EXEC [dbo].[Update fShipped Qty]",
            action = "Execute [Update fShipped Qty] procedure.",
            script = script_name
        )

        print(f"{script_name} finished. [dbo].[fShipped Qty] has been updated.")
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="fShipped Qty",
        action_txt = "Execute script to update fShipped Qty table. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.") 

if __name__ == "__main__":
    main()
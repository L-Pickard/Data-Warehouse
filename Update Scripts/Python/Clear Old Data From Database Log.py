from SQL_Functions import execute_sql_procedure
from db_logger import write_to_log
import os

def main():
    
    script_name = os.path.basename(__file__)
    
    try:
        
        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "Database Log",
            sql = "EXEC [Clear Database Log Table];",
            action =  "Execute clear database log table procedure.",
            script = script_name
        )
        
        print(f"{script_name} finished. Old data has been deleted from update log." )
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="Database Log",
        action_txt = "Triggered clear database log table procedure.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during exection. See log file.")   
    
if __name__ == "__main__":
    main()
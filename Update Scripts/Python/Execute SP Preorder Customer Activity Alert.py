from pyodbc import connect


def execute_sql_procedure(server, database, sql):
    try:
        with connect(
            f"DRIVER={{SQL Server}};SERVER={server};DATABASE={database};Trust_Connection=yes;"
        ) as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql)
                conn.commit()
    except Exception as e:
        print(f"SQL execution error: {e}")


def get_first_value():
    try:
        with connect(
            "DRIVER={SQL Server};SERVER=shinersql18;DATABASE=LP_Toolbox;Trust_Connection=yes;"
        ) as conn:
            with conn.cursor() as cursor:
                query = """
                SELECT TOP 1 [Exec Flag]
                FROM [LP_Toolbox].[dbo].[Procedure Flag]
                WHERE [Procedure Name] = 'Preorder Customer Activity Alert';
                """
                cursor.execute(query)
                row = cursor.fetchone()
                if row:
                    return row[0]
                else:
                    return None
    except Exception as e:
        print(f"SQL execution error: {e}")
        return None


if __name__ == "__main__":

    procedure = "EXECUTE [Preorder Customer Activity Alert V2];"

    reset_bit = """
    UPDATE [LP_Toolbox].[dbo].[Procedure Flag]
    SET [Exec Flag] = 0
    WHERE [Procedure Name] = 'Preorder Customer Activity Alert';
    """

    if get_first_value() == 1:

        execute_sql_procedure("WHServer", "Finance", procedure)

        execute_sql_procedure("WHServer", "LP_Toolbox", reset_bit)
        
import pyodbc
import configparser
import pandas as pd


class dbwork:
    # Initializing the connection to the database
    # Reading parameters from config.ini file
    def __init__(self, db_type):
        config = configparser.ConfigParser()
        config.read('config.ini')
        self.db_type = db_type
        self.db_user = config[f'{db_type}']['db_user']
        self.db_password = config[f'{db_type}']['db_password']
        self.db_name = config[f'{db_type}']['db_name']
        self.db_server = config[f'{db_type}']['db_server']
        self.db_port = config[f'{db_type}']['db_port']
        self.db_driver = config[f'{db_type}']['db_driver']

        if self.db_type == 'SQL Server':
            with pyodbc.connect(f'DRIVER={self.db_driver};'
                                f'SERVER={self.db_server};'
                                f'DATABASE={self.db_name};'
                                f'UID={self.db_user};'
                                f'PWD={self.db_password};'
                                f'Trusted_Connection=no;', autocommit=True) as self.ctx:
                self.cursor = self.ctx.cursor()
        elif self.db_type == 'SQLite3':
            with pyodbc.connect(f"Driver=SQLite3 ODBC Driver;Database={self.db_name}", autocommit=True) as self.ctx:
                self.cursor = self.ctx.cursor()
        else:
            raise 'Wrong database name'

    # The method reads a table from the database and writes the contents to the dataframe
    def select(self, columns='*', table='sqlite_master'):
        return pd.read_sql(f'SELECT {columns} FROM {table};', self.ctx)

    # The method executes a SQL script and returns a dataframe with the result
    def query(self, sqlquery):
        return pd.read_sql(sqlquery, self.ctx)

    # The method reads data from a file
    def read_file(self, filename):
        with open(filename, 'r', encoding='utf-8') as f:
            read_data = f.read()
        return read_data

    # Closing a database connection
    def __exit__(self):
        self.cursor.close()
        self.ctx.commit()

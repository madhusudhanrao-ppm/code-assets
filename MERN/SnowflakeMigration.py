import snowflake.connector 
import oracledb
import pandas as pd

# Snowflake Connection Details
SNOWFLAKE_ACCOUNT = 'YOUR-ACCOUNT-NAME'  # Replace with your Snowflake account name
SNOWFLAKE_USER = 'YOUR-USERNAME'  # Replace with your Snowflake username
SNOWFLAKE_PASSWORD = 'YOUR-PASSWORD'  # Replace with your Snowflake password
SNOWFLAKE_WAREHOUSE = ''
SNOWFLAKE_DATABASE = 'YOUR_DATABASE'  # Replace with your Snowflake database name
SNOWFLAKE_SCHEMA = 'PUBLIC'
SNOWFLAKE_TABLE = 'YOUR_TABLE'  # Replace with your Snowflake table name

# Oracle Connection Details
ORACLE_USERNAME = 'YOUR-ORACLE-USERNAME'  # Replace with your Oracle username
ORACLE_PASSWORD = 'YOUR-ORACLE-PASSWORD'  # Replace with your Oracle password
ORACLE_HOST = 'YOUR-ORACLE-HOST'  # Replace with your Oracle host (IP or hostname)
ORACLE_PORT = 1521
ORACLE_SERVICE_NAME = 'FREEPDB1'
ORACLE_TABLE = 'YOUR_ORACLE_TABLE'  # Replace with your Oracle table name
 
# Function to read data from Snowflake table
def read_from_snowflake():
    # Establish Snowflake connection
    ctx = snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=SNOWFLAKE_ACCOUNT,
        warehouse=SNOWFLAKE_WAREHOUSE,
        database=SNOWFLAKE_DATABASE,
        schema=SNOWFLAKE_SCHEMA
    ) 
    # Create a cursor object
    cs = ctx.cursor() 
    # Execute query to read data from Snowflake table
    query = f"SELECT * FROM {SNOWFLAKE_TABLE}"
    cs.execute(query) 
    # Fetch all rows
    rows = cs.fetchall() 
    # Get column names
    col_names = [desc[0] for desc in cs.description] 
    # Create a pandas DataFrame
    df = pd.DataFrame(rows, columns=col_names) 
    # Close Snowflake connection
    cs.close()
    ctx.close() 
    return df

# Function to write data to Oracle table
def write_to_oracle(df):
    # Establish Oracle connection
    dsn = f"{ORACLE_HOST}:{ORACLE_PORT}/{ORACLE_SERVICE_NAME}"
    conn = oracledb.connect(user=ORACLE_USERNAME, password=ORACLE_PASSWORD, dsn=dsn) 
    # Create a cursor object
    cursor = conn.cursor() 
    # Create a list of tuples containing the data
    data = [tuple(row) for row in df.values.tolist()] 
    # Get column names
    col_names = ', '.join(df.columns.tolist())  
    # Create placeholders for the insert statement
    placeholders = ', '.join([':' + str(i+1) for i in range(len(df.columns))]) 
    # Execute insert statement
    query = f"INSERT INTO {ORACLE_TABLE} ({col_names}) VALUES ({placeholders})"
    cursor.executemany(query, data) 
    # Commit changes
    conn.commit() 
    # Close Oracle connection
    cursor.close()
    conn.close()

def main():
    # Read data from Snowflake table
    df = read_from_snowflake()

    # Write data to Oracle table
    write_to_oracle(df)

if __name__ == "__main__":
    main()

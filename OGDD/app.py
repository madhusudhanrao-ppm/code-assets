import cx_Oracle
import oracledb
import streamlit as st 
from streamlit_navigation_bar import st_navbar
import pandas as pd
import numpy as np

st.set_page_config(
    page_title = "FinserBank Demo",
    page_icon = "🦜🔗 FinserBank Demo"    
)

st.title ("🦜🔗 FinserBank Demo");
  
# Shard connection details
username = 'docuser'
password = 'YourPassword'
# dsn = '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=your_shard_host)(PORT=your_shard_port))(CONNECT_DATA=(SERVICE_NAME=your_shard_service_name)))'
dsn = '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=gsmhost.subnet1.primaryvcn.oraclevcn.com)(PORT=1522))(CONNECT_DATA=(SERVICE_NAME=GDS$CATALOG.oradbcloud)))'

# Establish a connection
connection = cx_Oracle.connect(username, password, dsn, encoding="UTF-8")

# Create a cursor
cursor = connection.cursor()

with connection.cursor() as cursor:
    sql = """select custid, FirstName, LastName, Class, CustProfile from bank_customers"""
    df = pd.DataFrame(cursor.execute(sql))
    df.columns = ['ID','First Name', 'Last Name', 'Class', 'Profile']
st.dataframe(df)

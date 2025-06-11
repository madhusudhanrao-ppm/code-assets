import cx_Oracle
import oracledb
import streamlit as st 
from streamlit_navigation_bar import st_navbar
import pandas as pd
import numpy as np

st.set_page_config(
    page_title = "Hello",
    page_icon = "🦜🔗 Bank Customers"    
)

st.title("Bank Customers in Shard2");

# Shard connection details
username = 'docuser'
password = 'YourPassword' 
dsn = '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=shardhost3)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=shard3)))'

# Establish a connection
connection = cx_Oracle.connect(username, password, dsn, encoding="UTF-8")

# Create a cursor

with connection.cursor() as cursor:
    sql = """select custid, FirstName, LastName, Class, CustProfile from bank_customers"""
    df = pd.DataFrame(cursor.execute(sql))
    df.columns = ['ID','First Name', 'Last Name', 'Class', 'Profile']
st.dataframe(df)

st.title("Bank Products");

with connection.cursor() as cursor2:
    sql = """select ProductId, Product_Name, Description from bank_products"""
    df = pd.DataFrame(cursor2.execute(sql))
    df.columns = ['ProductId','Product_Name', 'Description']
st.dataframe(df)

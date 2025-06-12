import streamlit as st
import cx_Oracle

# Database connection function
def connect_to_db():
    try:
        conn = cx_Oracle.connect(
            user = 'docuser',
            password = 'YourPassword', 
            dsn = '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=gsmhost.subnet1.primaryvcn.oraclevcn.com)(PORT=1522))(CONNECT_DATA=(SERVICE_NAME=GDS$CATALOG.oradbcloud)))'
        )
        return conn
    except cx_Oracle.Error as e:
        st.error(f"Failed to connect to database: {e}")
        return None

# Function to delete record from Bank_Customers table
def delete_customer(conn, cust_id):
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM Bank_Customers WHERE CustId = :1", (cust_id,))
        conn.commit()
        cur.close()
        return True
    except cx_Oracle.Error as e:
        st.error(f"Failed to delete record: {e}")
        return False

# Streamlit form
st.title("Delete Bank Customer Record")
with st.form("delete_form"):
    cust_id = st.text_input("Customer ID")
    submitted = st.form_submit_button("Delete Record")

if submitted:
    if cust_id:
        conn = connect_to_db()
        if conn:
            if delete_customer(conn, cust_id):
                st.success(f"Record with CustId {cust_id} deleted successfully!")
            else:
                st.error(f"Failed to delete record with CustId {cust_id}.")
            conn.close()
    else:
        st.warning("Please enter a Customer ID.")

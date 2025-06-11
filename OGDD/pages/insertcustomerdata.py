import streamlit as st
import cx_Oracle

# Database connection function
def connect_to_db():
    try:
        conn = cx_Oracle.connect(
            user="docuser",
            password="YourPassword",
            dsn="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=gsmhost.subnet1.primaryvcn.oraclevcn.com)(PORT=1522))(CONNECT_DATA=(SERVICE_NAME=GDS$CATALOG.oradbcloud)))"
        )
        return conn
    except cx_Oracle.Error as e:
        st.error(f"Failed to connect to database: {e}")
        return None

# Function to insert data into Bank_Customers table
def insert_customer(conn, customer_data):
    try:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO Bank_Customers (CustId, FirstName, LastName, Class, CustProfile)
            VALUES (:1, :2, :3, :4, :5)
        """, customer_data)
        conn.commit()
        cur.close()
        return True
    except cx_Oracle.Error as e:
        st.error(f"Failed to insert data: {e}")
        return False

# Streamlit form
st.title("Bank Customer Registration Form")
with st.form("customer_form"):
    cust_id = st.text_input("Customer ID")
    first_name = st.text_input("First Name")
    last_name = st.text_input("Last Name")
    class_ = st.selectbox("Class", ["Gold", "Silver", "Bronze"])
    cust_profile = st.text_area("Customer Profile (JSON)")
    submitted = st.form_submit_button("Submit")

if submitted:
    if cust_id and first_name and last_name and class_ and cust_profile:
        try:
            # Validate JSON
            import json
            json.loads(cust_profile)
        except json.JSONDecodeError:
            st.error("Invalid JSON in Customer Profile.")
        else:
            conn = connect_to_db()
            if conn:
                customer_data = (cust_id, first_name, last_name, class_, cust_profile)
                if insert_customer(conn, customer_data):
                    st.success("Customer data inserted successfully!")
                else:
                    st.error("Failed to insert customer data.")
                conn.close()
    else:
        st.warning("Please fill out all fields.")

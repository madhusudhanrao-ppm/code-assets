const express = require('express');
const oracledb = require('oracledb');
const app = express();
const cors = require('cors');

app.use(cors());
app.use(express.json());

const dbConfig = {
  user: 'demouser',
  password: '<Your-Password>',
  connectString: '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=FREEPDB1)))',
};

oracledb.autoCommit = true;

app.get('/api/customers', async (req, res) => {
  try {
    const conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute('SELECT * FROM bank_customers');
    res.json(result.rows.map((row) => ({
      id: row[0],
      customerName: row[1],
      gender: row[2],
      maritalStatus: row[3],
      streetAddress: row[4],
      city: row[5],
      state: row[6],
      phoneNumber: row[7],
      email: row[8],
    })));
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error fetching customers' });
  }
});

app.post('/api/customers', async (req, res) => {
  try {
    const conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `INSERT INTO bank_customers (
        customer_name,
        gender,
        marital_status,
        street_address,
        city,
        state,
        phone_number,
        email
      ) VALUES (
        :customerName,
        :gender,
        :maritalStatus,
        :streetAddress,
        :city,
        :state,
        :phoneNumber,
        :email
      ) RETURNING id INTO :id`,
      {
        customerName: req.body.customer_name,
        gender: req.body.gender,
        maritalStatus: req.body.marital_status,
        streetAddress: req.body.street_address,
        city: req.body.city,
        state: req.body.state,
        phoneNumber: req.body.phone_number,
        email: req.body.email,
        id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT },
      }
    );
    res.json({
      id: result.outBinds.id[0],
      customerName: req.body.customer_name,
      gender: req.body.gender,
      maritalStatus: req.body.marital_status,
      streetAddress: req.body.street_address,
      city: req.body.city,
      state: req.body.state,
      phoneNumber: req.body.phone_number,
      email: req.body.email,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error creating customer' });
  }
});

app.listen(3001, () => {
  console.log('Server listening on port 3001');
});

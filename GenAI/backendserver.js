const express = require('express');
const oracledb = require('oracledb');
const cors = require('cors'); 
const app = express();
app.use(cors());
app.use(express.json());

app.post('/insertData', async (req, res) => {
  try { 
    //Local Server
    const connection = await oracledb.getConnection({
      user: "<db-username>",
      password: "<db-password>",
      connectString:
        "(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-phoenix-1.oraclecloud.com))(connect_data=(service_name=wkrfs4xeqva1jcu_indadw_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))",
      walletLocation:
        "/<wallet-folder>/Wallet_IndADW",
      walletPassword: "<wallet-password>",
    }); 
 
    const sql =
      "INSERT INTO TASKS (NAME, IS_COMPLETED, PHOTOCLOB, MIMETYPE, PHOTONAME , EMAIL ) VALUES (:column1, :column2,  :column3 , :column4, :column5 , :column6)";
  
    const binds = {
      column1: req.body.column1,
      column2: req.body.column2,
      column3: req.body.column3,
      column4: req.body.column4,
      column5: req.body.column5,
      column6: req.body.column6,
    };

    const result = await connection.execute(sql, binds);
    res.json({
      message: "Data inserted successfully",
      rowsAffected: result.rowsAffected,
    });
    console.log("Rows inserted:", result.rowsAffected);
    await connection.commit();

    await connection.close();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to insert data' });
  }
});

app.listen(3001, () => {
  console.log('Server listening on port 3001');
});
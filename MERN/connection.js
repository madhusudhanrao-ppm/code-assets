import { MongoClient, ServerApiVersion } from "mongodb";

const URI = process.env.ATLAS_URI || "";
const client = new MongoClient(URI, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  },
});

try { 
  await client.connect(); 
  await client.db("mongodbuser").command({ ping: 1 });
  console.log("You have successfully connected!");
} catch (err) {
  console.error(err);
}
 
let db = client.db("mongodbuser111"); 
export default db;



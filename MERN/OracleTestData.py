import pymongo

myclient = pymongo.MongoClient("mongodb://mongodbuser:Welcome123456@MCH9O4DUSQ8HNJF-AISHUADB.adb.us-ashburn-1.oraclecloudapps.com:27017/mongodbuser?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true")
mydb = myclient["mongodbuser"]
mycol = mydb["customers"]

mydict = { "name": "John", "address": "Highway 37" }

x = mycol.insert_one(mydict)
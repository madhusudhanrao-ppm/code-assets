import pymongo

myclient = pymongo.MongoClient("mongodb+srv://username:pwd@cluster0.xxxx.mongodb.net/employees?retryWrites=true&w=majority")
mydb = myclient["mydatabase"]
mycol = mydb["customers"]

mydict = { "name": "John", "address": "Highway 37" }

x = mycol.insert_one(mydict)

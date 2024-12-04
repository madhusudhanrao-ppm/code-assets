import pymongo

myclient = pymongo.MongoClient("mongodb+srv://softwarearchitect73:r9HXPvn0JDvdrCFT@cluster0.dq86r.mongodb.net/employees?retryWrites=true&w=majority")
mydb = myclient["mydatabase"]
mycol = mydb["customers"]

mydict = { "name": "John", "address": "Highway 37" }

x = mycol.insert_one(mydict)
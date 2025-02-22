
// init-mongo.js
// This script initializes the database and creates an application user with limited privileges.
// It reads the credentials from environment variables using mongosh's os.getenv().

var dbName = os.getenv("APP_MONGO_DB");
db = db.getSiblingDB(dbName);

var appUser = os.getenv("APP_MONGO_USER");
var appPass = os.getenv("APP_MONGO_PASS");

db.createUser({
    user: appUser,
    pwd: appPass,
    roles: [
        {
            role: "readWrite",
            db: dbName
        }
    ]
});

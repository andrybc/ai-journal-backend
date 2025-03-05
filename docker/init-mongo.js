print("=== Starting MongoDB Initialization Script ===");
var dbName = "journaldb" || "journaldb";
db = db.getSiblingDB(dbName);
var appUser = "dbUser" || "dbUser";
var appPass = "dbUserPass" || "dbUserPass";
print("Using database: " + dbName);
print("Attempting to create user: " + appUser);
var result = db.createUser({
    user: appUser,
    pwd: appPass,
    roles: [{
        role: "readWrite",
        db: dbName
    }]
});
print("User creation result: " + JSON.stringify(result));
print("=== Finished MongoDB Initialization Script ===");

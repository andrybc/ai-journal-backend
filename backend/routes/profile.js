
const express = require("express");
const router = express.Router();
const profileController = require("../controllers/profileController");


// Route to create a new profile
router.post("/create-profile", profileController.createProfile);

// Route to delete a profile by ID
router.delete("/delete-profile/:profileId", profileController.deleteProfile);

// Route to update a profile by ID
router.put("/update-profile/:profileId", profileController.updateProfile);

// Route to read a profile by ID
router.get("/read-profile/:profileId", profileController.readProfile);



module.exports = router;

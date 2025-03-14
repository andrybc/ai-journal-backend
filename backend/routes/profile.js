const express = require("express");
const router = express.Router();
const profileController = require("../controllers/profileController");

router.post("/create-profile", profileController.createProfile);
router.delete("/delete-profile:profileId", profileController.deleteProfile);
router.put("/update-profile:profileId", profileController.updateProfile);
router.get("/read-profile:profileId", profileController.readProfile);

module.exports = router;

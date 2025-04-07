const express = require("express");
const router = express.Router();
const profileController = require("../controllers/profileController");
const authenticateToken = require("../middleware/authenticateToken");

router.post(
  "/create-profile",
  authenticateToken,
  profileController.createProfile,
);
router.delete(
  "/delete-profile/:profileId",
  authenticateToken,
  profileController.deleteProfile,
);
router.put(
  "/update-profile/:profileId",
  authenticateToken,
  profileController.updateProfile,
);
router.get(
  "/read-profile/:profileId",
  authenticateToken,
  profileController.readProfile,
);
router.get("/search", authenticateToken, profileController.searchProfiles);
router.get("/all/:userId", authenticateToken, profileController.getAllProfiles);
router.get(
  "/:userId/:profileId",
  authenticateToken,
  profileController.getProfileById,
);

module.exports = router;

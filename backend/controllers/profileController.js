const Profile = require('../models/summary');

// Create a new profile
exports.createProfile = async (req, res) => {
  try {
    const { profileTitle, profileContent, userId } = req.body;
    if (!profileTitle || !profileContent || !userId) {
      return res.status(400).json({ error: "Invalid input data" });
    }

    const newProfile = new Profile({
      profileTitle,
      profileContent,
      userId,
      notebookIDs: [] // Initially empty
    });

    await newProfile.save();

    res.status(200).json({ message: "Profile created successfully", profile: newProfile });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// Delete a profile by ID
exports.deleteProfile = async (req, res) => {
  try {
    const { profileId } = req.params;
    const deletedProfile = await Profile.findByIdAndDelete(profileId);
    if (!deletedProfile) {
      return res.status(404).json({ error: "Profile not found" });
    }
    res.status(200).json({ message: "Profile successfully deleted" });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// Update a profile by ID
exports.updateProfile = async (req, res) => {
  try {
    const { profileId } = req.params;
    const { profileTitle, profileContent, notebookIDs } = req.body;

    const updateData = { profileTitle, profileContent };
    if (notebookIDs) updateData.notebookIDs = notebookIDs;

    const updatedProfile = await Profile.findByIdAndUpdate(profileId, updateData, { new: true });
    if (!updatedProfile) {
      return res.status(404).json({ error: "Profile not found" });
    }
    res.status(200).json({ message: "Profile updated successfully", profile: updatedProfile });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// Read a profile by ID
exports.readProfile = async (req, res) => {
  try {
    const { profileId } = req.params;
    const profile = await Profile.findById(profileId);
    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }
    res.status(200).json({ message: "Profile retrieved", profile });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

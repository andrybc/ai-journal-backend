const Profile = require("../models/summary");
//const Notebook = require('../models/Notebook');

// create profile
exports.createProfile = async (req, res) => {
  try {
    const { tagId, userId } = req.body;
    if (!tagId || !Array.isArray(tagId) || tagId.length === 0 || !userId) {
      return res.status(400).json({ error: "Invalid input data" });
    }
    //TODO: implement AI to search content in notebooks
    const newProfile = new Profile({
      title,
      content,
      tagId,
      userId,
    });
    await newProfile.save();

    res
      .status(200)
      .json({ message: "Profile created successfully", profile: newProfile });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// delete profile
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

// update profile
exports.updateProfile = async (req, res) => {
  try {
    const { profileId } = req.params;
    const { title, content } = req.body;

    const updateProfile = await Profile.findByIdAndUpdate(
      profileId,
      { title, content },
      { new: true },
    );
    if (!updateProfile) {
      return res.status(404).json({ error: "Profile not found" });
    }
    res.status(200).json({ message: "Profile updated successfully" });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// read profile
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

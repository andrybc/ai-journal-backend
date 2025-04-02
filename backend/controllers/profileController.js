const Profile = require("../models/summary");

//const Notebook = require('../models/Notebook');

// create profile
exports.createProfile = async (req, res) => {
  try {
    const { title, content, notebookIDs = [], userId } = req.body;

    if (!title || !content || !userId) {
      return res.status(400).json({ error: "Invalid input data" });
    }

    if (notebookIDs && !Array.isArray(notebookIDs)) {
      return res.status(400).json({ error: "notebookIDs must be an array" });
    }

    // Further validation of notebookIDs can be added here

    const newProfile = new Profile({
      title,
      content,
      notebookIDs, // optional array of Notebook IDs
      userId,
    });

    await newProfile.save();

    res.status(200).json({
      message: "Profile created successfully",
      profile: newProfile,
    });
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

exports.searchProfiles = async (req, res) => {
  try {
    const { userId, query } = req.query;

    if (!userId || query === null) {
      return res
        .status(400)
        .json({ error: "Missing userId or query parameter" });
    }

    const profiles = await Profile.find({
      userId,
      $or: [
        { title: { $regex: query, $options: "i" } },
        { content: { $regex: query, $options: "i" } },
      ],
    }).select("_id title");

    res.status(200).json({
      message: "Search results retrieved",
      profiles,
    });
  } catch (error) {
    console.error("Error in searchProfiles:", error);
    res.status(500).json({ error: "Internal server error" }); // Generic server error
  }
};

exports.getProfileById = async (req, res) => {
  try {
    const { userId, profileId } = req.params;

    const profile = await Profile.findOne({
      _id: profileId,
      userId,
    });

    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.status(200).json({
      message: "Profile retrieved",
      profile,
    });
  } catch (error) {
    console.error("Error in getProfileById:", error);
    res.status(500).json({ error: "Internal server error" }); // Generic server error
  }
};

// GET /profile/all/:userId
exports.getAllProfiles = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({ error: "Missing userId parameter" });
    }

    const profiles = await Profile.find({ userId }).select(
      "_id title timeCreated",
    );

    res.status(200).json({
      message: "Profiles retrieved successfully",
      profiles,
    });
  } catch (error) {
    console.error("Error in getAllProfiles:", error);
    res.status(500).json({ error: "Internal server error" }); // Generic server error
  }
};

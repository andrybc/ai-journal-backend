const mongoose = require('mongoose');

const profileSchema = new mongoose.Schema({
  // The title of the profile is the tag (name) found by OpenAI
  profileTitle: {
    type: String,
    required: true,
    trim: true,
  },
  // Detailed profile fields from OpenAI:
  name: { type: String, default: null },
  age: { type: String, default: null },
  occupation: { type: String, default: null },
  location: { type: String, default: null },
  education: { type: String, default: null },
  interests: { type: [String], default: [] },
  hobbies: { type: [String], default: [] },
  skills: { type: [String], default: [] },
  experience: { type: String, default: null },
  personalityTraits: { type: [String], default: [] },
  goals: { type: String, default: null },
  challenges: { type: String, default: null },
  background: { type: String, default: null },
  affiliations: { type: [String], default: [] },
  socialMedia: {
    twitter: { type: String, default: null },
    linkedin: { type: String, default: null },
    facebook: { type: String, default: null },
    instagram: { type: String, default: null },
  },
  favoriteBooks: { type: [String], default: [] },
  favoriteMovies: { type: [String], default: [] },
  favoriteMusic: { type: [String], default: [] },
  additionalNotes: { type: String, default: null },

  // Reference to the User who owns this profile
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  // Array of notebook IDs that mention this tag/person
  notebookIDs: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: "Notebook",
  }],
  timeCreated: {
    type: Date,
    default: Date.now,
  },
  timeUpdated: {
    type: Date,
    default: Date.now,
  }
});

module.exports = mongoose.model('Profile', profileSchema);

const mongoose = require("mongoose");

// Define the Notebook schema
const notebookSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  content: {
    type: String,
    required: true,
    trim: true,
  },
  // Tags will be extracted from content (e.g., names) and updated via the profile service
  tags: [
    {
      type: String,
      trim: true,
    }
  ],
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  timeCreated: {
    type: Date,
    default: Date.now,
  },
  timeUpdated: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Notebook", notebookSchema);

const mongoose = require("mongoose");

// Define the summary schema
const summarySchema = new mongoose.Schema({
  summaryTitle: {
    type: String,
    required: true,
    trim: true,
  },
  summaryContent: {
    type: String,
    required: true,
    trim: true,
  },
  tagId: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Notebook",
    },
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

module.exports = mongoose.model("Summary", summarySchema);

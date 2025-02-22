
// require('dotenv').config();
// const express = require('express');
// const cors = require('cors');
// const bodyParser = require('body-parser');

// const app = express();

// // some middleware
// app.use(cors());
// app.use(bodyParser.json());
// app.use(bodyParser.urlencoded({ extended: true }));

// // template route
// app.get('/', (req, res) => {
//     res.send("Welcome to the Journal Organizer API");
// });

// // start the server on port 3000 or from the .env file
// const PORT = process.env.PORT || 3000;
// app.listen(PORT, () => {
//     console.log(`Server running on port ${PORT}`);
// });



// // CODE TESTING THE API BACK END
// const express = require('express');
// const app = express();
// const PORT = process.env.PORT || 3001;

// // Simple API endpoint
// app.get('/api/test', (req, res) => {
//     res.json({ message: "Hello from the API!" });
// });

// app.listen(PORT, () => {
//     console.log(`Backend API running on port ${PORT}`);
// });



// server.js
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');

const app = express();
app.use(express.json()); // Parse JSON request bodies

// Connection string from environment variable, or default to container settings
const mongoURI = process.env.MONGO_URI;

// Connect to MongoDB with Mongoose
mongoose.connect(mongoURI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("Connected to MongoDB"))
    .catch(err => console.error("MongoDB connection error:", err));

// Define a simple schema and model for a "Message"
const messageSchema = new mongoose.Schema({
    text: String,
    createdAt: { type: Date, default: Date.now }
});

const Message = mongoose.model('Message', messageSchema);

// Endpoint to write a message to the database
app.post('/api/messages', async (req, res) => {
    try {
        const { text } = req.body;
        if (!text) return res.status(400).json({ error: "Text is required" });

        const message = new Message({ text });
        await message.save();
        res.status(201).json({ message: "Message saved", data: message });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint to read messages from the database
app.get('/api/messages', async (req, res) => {
    try {
        const messages = await Message.find().sort({ createdAt: -1 });
        res.json({ messages });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// A simple test endpoint (already existing)
app.get('/api/test', (req, res) => {
    res.json({ message: "Hello from the API!" });
});

// Start the server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));


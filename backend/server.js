
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
// backend/server.js
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3001;

// Simple API endpoint
app.get('/api/test', (req, res) => {
    res.json({ message: "Hello from the API!" });
});

app.listen(PORT, () => {
    console.log(`Backend API running on port ${PORT}`);
});

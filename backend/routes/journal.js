const express = require('express');
const router = express.Router();
const notebookController = require('../controllers/notebookController');

router.post('/create-notebook', notebookController.createNotebook);

router.post('/update-notebook', notebookController.updateNotebook);

router.post('/create-notebook', notebookController.deleteNotebook);

router.post('/delete-notebook', notebookController.readNotebook);






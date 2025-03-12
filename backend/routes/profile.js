const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');

router.post('/create-profile', profileController.createProfile);
router.post('/delete-profile', profileController.deleteProfile);
router.post('/update-profile', profileController.updateProfile);
router.post('/read-profile', profileController.readProfile);
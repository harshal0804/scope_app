// user-service/routes/authRoutes.js
const express = require('express');
const router = express.Router();
const authController = require('../../user_service/controllers/authController');

router.post('/login', authController.login);
router.get('/seed', authController.seedUser);

module.exports = router;

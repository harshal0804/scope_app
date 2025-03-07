// import-service/routes/importRoutes.js
const express = require('express');
const router = express.Router();
const importController = require('../controllers/importController');

router.get('/', importController.getImports);
router.post('/', importController.newImport);
router.get('/seed', importController.seedImports);

module.exports = router;

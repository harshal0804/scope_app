const express = require('express');
const router = express.Router();
const distributionController = require('../controllers/distributionController');
const upload = require('../middleware/upload');

// Seed route for distribution orders (for demo/testing purposes)
router.get('/seed', distributionController.seedDistribution);

// Get distribution order by orderId
router.get('/:orderId', distributionController.getDistributionByOrderId);

// Get all distribution orders
router.get('/', distributionController.getAllDistributions);

// Add new distribution order (without file uploads)
router.post('/', distributionController.addDistribution);

// Add new distribution order with file uploads
router.post('/with-files', upload.array('files'), distributionController.addDistributionWithFiles);

// Alternate file upload endpoint
router.post('/upload', upload.array('files'), distributionController.uploadFiles);

// Get files for a given orderId
router.get('/files/:orderId', distributionController.getFiles);

// Serve static HTML upload page
router.get('/upload/:orderId/:trackingId', (req, res) => {
  const { orderId, trackingId } = req.params;
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Upload Documents for Order ${orderId}</title>
        <style>
          body { background: #1C1C1C; color: #fff; font-family: Arial, sans-serif; padding: 20px; }
          .container { max-width: 600px; margin: auto; }
          input[type="file"] { width: 100%; padding: 10px; margin: 20px 0; }
          button { background: #00796B; color: #fff; border: none; padding: 10px 20px; font-size: 16px; cursor: pointer; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Upload Documents for Order ${orderId}</h1>
          <p>Tracking ID: ${trackingId}</p>
          <form id="uploadForm" enctype="multipart/form-data" method="POST" action="/distribution/upload">
            <input type="hidden" name="orderId" value="${orderId}" />
            <input type="hidden" name="trackingId" value="${trackingId}" />
            <input type="file" name="files" multiple />
            <button type="submit">Upload Files</button>
          </form>
        </div>
      </body>
    </html>
  `);
});

module.exports = router;

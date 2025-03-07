// distribution-service/server.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const compression = require('compression');
const path = require('path');
const winston = require('winston');
const connectDB = require('./config/db');

const app = express();

// Middleware
app.use(helmet());
app.use(compression());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Logger configuration
const logger = winston.createLogger({
  level: 'info',
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'distribution-error.log', level: 'error' })
  ]
});

// Serve static files (for file uploads)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Connect to MongoDB
connectDB();

// Routes
app.use('/api/distribution', require('./routes/distributionRoutes'));

// Health check endpoint
app.get('/health', (req, res) => res.status(200).json({ status: 'Distribution Service is healthy' }));

const PORT = process.env.PORT || 3003;
app.listen(PORT, () => logger.info(`Distribution Service running on port ${PORT}`));

// import-service/server.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const compression = require('compression');
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
    new winston.transports.File({ filename: 'import-error.log', level: 'error' })
  ]
});

// Connect to MongoDB
connectDB();

// Routes
app.use('/api/import', require('./routes/importRoutes'));

// Health check endpoint
app.get('/health', (req, res) => res.status(200).json({ status: 'Import Service is healthy' }));

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => logger.info(`Import Service running on port ${PORT}`));

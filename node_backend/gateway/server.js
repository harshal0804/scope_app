// gateway/server.js
require('dotenv').config();
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const helmet = require('helmet');
const compression = require('compression');
const winston = require('winston');

const app = express();

// Global Middleware
app.use(helmet());
app.use(compression());

// Logger configuration
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.simple(),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'gateway-error.log', level: 'error' })
  ]
});

// Proxy configuration with proper path rewriting
app.use('/user', createProxyMiddleware({
  target: process.env.USER_SERVICE_URL || 'http://localhost:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/user': ''  // Remove "/user" prefix when forwarding
  }
}));

app.use('/import', createProxyMiddleware({
  target: process.env.IMPORT_SERVICE_URL || 'http://localhost:3002',
  changeOrigin: true,
  pathRewrite: {
    '^/import': ''  // Remove "/import" prefix when forwarding
  }
}));

app.use('/distribution', createProxyMiddleware({
  target: process.env.DISTRIBUTION_SERVICE_URL || 'http://localhost:3003',
  changeOrigin: true,
  pathRewrite: {
    '^/distribution': ''  // Remove "/distribution" prefix when forwarding
  }
}));

// Health check endpoint for Gateway
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'Gateway is healthy' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => logger.info(`Gateway running on port ${PORT}`));

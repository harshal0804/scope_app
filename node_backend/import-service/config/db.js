// import-service/config/db.js
const mongoose = require('mongoose');
const winston = require('winston');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      dbName: 'import'
    });
    winston.info('Import Service: MongoDB connected successfully');
  } catch (error) {
    winston.error('Import Service: MongoDB connection error:', error);
    process.exit(1);
  }
};

module.exports = connectDB;

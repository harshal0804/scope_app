// user-service/config/db.js
const mongoose = require('mongoose');
const winston = require('winston');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      dbName: 'user'
    });
    winston.info('User Service: MongoDB connected successfully');
  } catch (error) {
    winston.error('User Service: MongoDB connection error:', error);
    process.exit(1);
  }
};

module.exports = connectDB;

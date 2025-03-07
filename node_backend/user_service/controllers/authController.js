// user-service/controllers/authController.js
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const winston = require('winston');

exports.login = async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await User.findOne({ username });
    if (!user) {
      winston.error('Invalid username or password');
      return res.status(400).json({ message: 'Invalid username or password' });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      winston.error('Invalid username or password');
      return res.status(400).json({ message: 'Invalid username or password' });
    }
    winston.info('Login successful');
    res.status(200).json({ message: 'Login successful' });
  } catch (error) {
    winston.error('Server error during login', error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.seedUser = async (req, res) => {
  try {
    const hashedPassword = await bcrypt.hash('hp', 10);
    const newUser = new User({ username: 'harshal', password: hashedPassword });
    await newUser.save();
    res.status(201).json({ message: 'User seeded successfully' });
  } catch (error) {
    winston.error('Error seeding user', error);
    res.status(500).json({ message: 'Error seeding user' });
  }
};

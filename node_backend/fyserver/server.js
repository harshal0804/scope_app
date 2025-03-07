const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const dotenv = require('dotenv');
const multer = require('multer'); // For handling file uploads
const path = require('path');
const fs = require('fs');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;

app.get('/web', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static('uploads')); // Serve uploaded files

// Connect to MongoDB
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.log(err));

// User Schema
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  phone: { type: String },
  location: { type: String },
  profilePicture: { type: String },
});

const User = mongoose.model('User', userSchema);

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const orderId = req.body.orderId;
    const orderDir = path.join(__dirname, 'uploads', orderId);
    if (!fs.existsSync(orderDir)) {
      fs.mkdirSync(orderDir, { recursive: true }); // Create folder if it doesn't exist
    }
    cb(null, orderDir); // Save files in the order-specific folder
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname)); // Generate a unique filename
  },
});

const upload = multer({ storage });

// Routes
app.get('/', (req, res) => {
  res.send('Welcome to the FY Server');
});

// Seed Users
app.get('/seed', async (req, res) => {
  try {
    // Clear existing data
    await User.deleteMany({});
    console.log('Existing users deleted.');

    // Insert seed data
    const seedUsers = [
      {
        username: 'harshal',
        email: 'john.doe@example.com',
        password: '123',
        phone: '123-456-7890',
        location: 'New York',
        profilePicture: 'uploads/profile-pictures/john.jpg',
      },
      {
        username: 'jane_smith',
        email: 'jane.smith@example.com',
        password: 'password123',
        phone: '987-654-3210',
        location: 'Los Angeles',
        profilePicture: 'uploads/profile-pictures/jane.jpg',
      },
      {
        username: 'alice_wonder',
        email: 'alice.wonder@example.com',
        password: 'password123',
        phone: '555-555-5555',
        location: 'Chicago',
        profilePicture: 'uploads/profile-pictures/alice.jpg',
      },
    ];

    await User.insertMany(seedUsers);
    console.log('Seed data inserted successfully.');

    res.status(200).json({ message: 'Database seeded successfully!' });
  } catch (err) {
    console.error('Error seeding database:', err);
    res.status(500).json({ message: 'Error seeding database', error: err });
  }
});

// Register
app.post('/register', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    const user = new User({ username, email, password });
    await user.save();
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(400).json({ message: 'Error registering user', error: err });
  }
});

// Login
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(400).json({ message: 'Invalid username or password' });
    }

    if (password !== user.password) {
      return res.status(400).json({ message: 'Invalid username or password' });
    }

    // Return user data (excluding the password)
    res.status(200).json({
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        phone: user.phone,
        location: user.location,
        profilePicture: user.profilePicture,
      },
    });
  } catch (err) {
    res.status(500).json({ message: 'Error logging in', error: err });
  }
});

// Get User Profile
app.get('/users/get-user-by-id/:id', async (req, res) => {
  const userId = req.params.id;
  const user = await User.findById(userId); // Fetch user from the database
  if (user) {
    res.status(200).json(user);
  } else {
    res.status(404).json({ message: 'User not found' });
  }
});

// Update User Profile
app.put('/users/update-profile', async (req, res) => {
  const updatedData = req.body;
  const userId = updatedData.id; // Assuming you pass the user ID in the request body
  await User.findByIdAndUpdate(userId, updatedData); // Update user in the database
  res.status(200).json({ message: 'Profile updated successfully' });
});

// Upload Profile Picture
app.post('/users/upload-profile-image', upload.single('profilePicture'), async (req, res) => {
  const { userId } = req.body;
  const profilePicture = req.file.path;

  try {
    const user = await User.findByIdAndUpdate(
      userId,
      { profilePicture },
      { new: true }
    ).select('-password');
    res.status(200).json({ message: 'Profile image uploaded successfully', user });
  } catch (err) {
    res.status(400).json({ message: 'Error uploading profile image', error: err });
  }
});

//===========================================================================================================

// Distribution Schema
const distributionSchema = new mongoose.Schema({
  orderId: { type: String, required: true, unique: true },
  medicineName: { type: String, required: true },
  quantity: { type: Number, required: true },
  cost: { type: Number, required: true },
  length: { type: Number, required: true },
  width: { type: Number, required: true },
  height: { type: Number, required: true },
  unitWeight: { type: Number, required: true },
  totalWeight: { type: Number, required: true },
  supplierName: { type: String, required: true },
  customerName: { type: String, required: true },
  customerPhone: { type: String, required: true },
  customerEmail: { type: String, required: true },
  supplierLocation: { type: String, required: true },
  customerLocation: { type: String, required: true },
  supplierAddress: { type: String, required: true },
  customerAddress: { type: String, required: true },
  packageInfo: { type: String, required: true },
  specialInstructions: { type: String },
  status: { type: String, default: 'Pending' },
  trackingId: { type: String, required: true },
  locationHistory: [
    {
      status: { type: String, required: true },
      location: { type: String, required: true },
      timestamp: { type: Date, required: true },
    },
  ],
  shippingType: { type: String, required: true },
  vehicleNumber: { type: String },
  personName: { type: String },
  personPhone: { type: String },
  documents: [{ type: String }], // Array of file paths for uploaded documents
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Reference to the user who created the order
  createdAt: { type: Date, default: Date.now },
});

const Distribution = mongoose.model('Distribution', distributionSchema);

// Add Distribution Order
app.post('/distributionadd', async (req, res) => {
  const {
    orderId,
    medicineName,
    quantity,
    cost,
    length,
    width,
    height,
    unitWeight,
    totalWeight,
    supplierName,
    customerName,
    customerPhone,
    customerEmail,
    supplierLocation,
    customerLocation,
    supplierAddress,
    customerAddress,
    packageInfo,
    specialInstructions,
    trackingId,
    shippingType,
    vehicleNumber,
    personName,
    personPhone,
    documents,
    createdBy,
  } = req.body;

  try {
    const distribution = new Distribution({
      orderId,
      medicineName,
      quantity,
      cost,
      length,
      width,
      height,
      unitWeight,
      totalWeight,
      supplierName,
      customerName,
      customerPhone,
      customerEmail,
      supplierLocation,
      customerLocation,
      supplierAddress,
      customerAddress,
      packageInfo,
      specialInstructions,
      trackingId,
      shippingType,
      vehicleNumber,
      personName,
      personPhone,
      documents,
      createdBy,
    });

    await distribution.save();
    res.status(201).json({ message: 'Distribution order created successfully', distribution });
  } catch (err) {
    res.status(400).json({ message: 'Error creating distribution order', error: err });
  }
});

// Upload Documents for Distribution
app.post('/distribution/upload', upload.array('files'), async (req, res) => {
  const { orderId } = req.body;
  const files = req.files;

  try {
    const distribution = await Distribution.findOne({ orderId });
    if (!distribution) {
      return res.status(404).json({ message: 'Distribution order not found' });
    }

    // Save file paths to the distribution order
    files.forEach((file) => {
      distribution.documents.push(file.path);
    });

    await distribution.save();
    res.status(200).json({ message: 'Documents uploaded successfully', distribution });
  } catch (err) {
    console.error('Error uploading documents:', err);
    res.status(400).json({ message: 'Error uploading documents', error: err.message });
  }
});
//downlodind doc
app.get('/distribution/:orderId/download/:filename', (req, res) => {
  const { orderId, filename } = req.params;

  // Construct the file path
  const filePath = path.join(__dirname, 'uploads', orderId, filename);

  console.log('Requested file path:', filePath); // Debugging

  // Check if the file exists
  if (!fs.existsSync(filePath)) {
    console.error('File not found:', filePath); // Debugging
    return res.status(404).json({ message: 'File not found' });
  }

  // Set headers for file download
  res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
  res.setHeader('Content-Type', 'application/octet-stream');

  // Stream the file to the client
  const fileStream = fs.createReadStream(filePath);
  fileStream.pipe(res);

  // Handle errors during streaming
  fileStream.on('error', (err) => {
    console.error('Error streaming file:', err); // Debugging
    res.status(500).json({ message: 'Error downloading file', error: err.message });
  });
});
app.get('/distribution/:orderId/files', async (req, res) => {
  const { orderId } = req.params;

  try {
    // Find the distribution order by orderId
    const order = await Distribution.findOne({ orderId });

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Get the list of documents (file paths) associated with the order
    const files = order.documents;

    // Extract filenames from the file paths
    const fileList = files.map((filePath) => {
      return {
        filename: path.basename(filePath), // Extract the filename
        path: filePath, // Full file path
      };
    });

    res.status(200).json({ files: fileList });
  } catch (err) {
    console.error('Error fetching files:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});
// Get Distribution Orders
app.get('/distribution', async (req, res) => {
  try {
    const distributions = await Distribution.find({});
    res.status(200).json(distributions);
  } catch (err) {
    res.status(400).json({ message: 'Error fetching distribution orders', error: err });
  }
});

// Get Distribution Order by ID
app.get('/distribution/:orderId', async (req, res) => {
  try {
    const orderId = req.params.orderId;

    // Validate orderId
    if (!mongoose.Types.ObjectId.isValid(orderId)) {
      return res.status(400).json({ message: 'Invalid order ID' });
    }

    // Find the order by ID
    const order = await Distribution.findById(orderId);

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Convert locationHistory from Map to List (if needed)
    const locationHistoryList = order.locationHistory.map((history) => ({
      status: history.status,
      location: history.location,
      timestamp: history.timestamp,
    }));

    // Return the order data with locationHistory as an array
    res.status(200).json({
      ...order.toObject(),
      locationHistory: locationHistoryList,
    });
  } catch (err) {
    console.error('Error fetching order:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});


// Seed Distribution Orders
app.get('/seed1', async (req, res) => {
  try {
    // Clear existing data
    await Distribution.deleteMany({});

    // Example orders with location history
    const orders = [
      {
        orderId: 'ORD1234567863541',
        medicineName: 'purnima nnala',
        quantity: 100,
        cost: 500,
        length: 20,
        width: 15,
        height: 10,
        unitWeight: 0.5,
        totalWeight: 50,
        supplierName: 'MedSupplier Inc.',
        customerName: 'John Doe',
        customerPhone: '123-456-7890',
        customerEmail: 'harshalgadre@gmail.com',
        supplierLocation: '51.5074,-0.1278', // London coordinates
        customerLocation: '48.8566,2.3522', // Paris coordinates
        supplierAddress: '123 Supplier St, London, UK',
        customerAddress: '456 Customer Ave, Paris, France',
        packageInfo: 'Fragile',
        specialInstructions: 'Handle with care',
        status: 'Shipped',
        trackingId: 'TRK1234567890',
        shippingType: 'By Road',
        vehicleNumber: 'TRUCK123',
        personName: 'Driver Name',
        personPhone: '987-654-3210',
        documents: [],
        createdBy: '64f1b2c3e4d5f6a7b8c9d0e1', // Add createdBy field
        locationHistory: [
          {
            status: 'Pending',
            location: '51.5074,-0.1278', // London coordinates
            timestamp: '2023-10-01T10:00:00Z',
          },
          {
            status: 'Approved',
            location: '51.5074,-0.1278', // London coordinates
            timestamp: '2023-10-02T12:00:00Z',
          },
          {
            status: 'Shipped',
            location: '48.8566,2.3522', // Paris coordinates
            timestamp: '2023-10-03T14:00:00Z',
          },
        ],
      },
    ];

    // Insert orders into the database
    await Distribution.insertMany(orders);

    res.status(200).json({ message: 'Database seeded successfully', orders });
  } catch (err) {
    console.error('Error seeding database:', err);
    res.status(500).json({ message: 'Failed to seed database', error: err.message });
  }
});

//===============================================================================
//web update 

app.post('/distribution/id/:id/update-status', async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const order = await Distribution.findByIdAndUpdate(
      id,
      { status },
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    res.status(200).json(order);
  } catch (err) {
    console.error('Error updating order status:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});
app.post('/distribution/id/:id/update-details', async (req, res) => {
  const { id } = req.params;
  const { customerName, customerPhone, customerEmail, customerAddress } = req.body;

  try {
    const order = await Distribution.findByIdAndUpdate(
      id,
      { customerName, customerPhone, customerEmail, customerAddress },
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    res.status(200).json(order);
  } catch (err) {
    console.error('Error updating order details:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

app.post('/distribution/id/:id/update-location', async (req, res) => {
  const { id } = req.params;
  const { status, location } = req.body;

  try {
    const order = await Distribution.findByIdAndUpdate(
      id,
      {
        $push: {
          locationHistory: {
            status,
            location,
            timestamp: new Date(),
          },
        },
      },
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    res.status(200).json(order);
  } catch (err) {
    console.error('Error updating location history:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});
app.get('/distribution/id/:id', async (req, res) => {
  try {
    const id = req.params.id;

    // Validate MongoDB _id
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid MongoDB ID' });
    }

    // Find the order by _id
    const order = await Distribution.findById(id);

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Return the order data
    res.status(200).json(order);
  } catch (err) {
    console.error('Error fetching order:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});


//===========================================================================================================
// for import screen 
// Import Schema
const ImportSchema = new mongoose.Schema({
  orderId: { type: String, required: true, unique: true },
  medicineName: { type: String, required: true },
  quantity: { type: Number, required: true },
  cost: { type: Number, required: true },
  length: { type: Number, required: true },
  width: { type: Number, required: true },
  height: { type: Number, required: true },
  unitWeight: { type: Number, required: true },
  totalWeight: { type: Number, required: true },
  supplierName: { type: String, required: true },
  customerName: { type: String, required: true },
  customerPhone: { type: String, required: true },
  customerEmail: { type: String, required: true },
  supplierLocation: { type: String, required: true },
  customerLocation: { type: String, required: true },
  supplierAddress: { type: String, required: true },
  customerAddress: { type: String, required: true },
  packageInfo: { type: String, required: true },
  specialInstructions: { type: String },
  status: { type: String, default: 'Pending' },
  trackingId: { type: String, required: true },
  locationHistory: [
    {
      status: { type: String, required: true },
      location: { type: String, required: true },
      timestamp: { type: Date, required: true },
    },
  ],
  shippingType: { type: String, required: true },
  vehicleNumber: { type: String },
  personName: { type: String },
  personPhone: { type: String },
  documents: [{ type: String }], // Array of file paths for uploaded documents
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Reference to the user who created the order
  createdAt: { type: Date, default: Date.now },
});

const ImportO = mongoose.model('Import', ImportSchema);
app.post('/importadd', async (req, res) => {
  const {
    orderId,
    medicineName,
    quantity,
    cost,
    length,
    width,
    height,
    unitWeight,
    totalWeight,
    supplierName,
    customerName,
    customerPhone,
    customerEmail,
    supplierLocation,
    customerLocation,
    supplierAddress,
    customerAddress,
    packageInfo,
    specialInstructions,
    trackingId,
    shippingType,
    vehicleNumber,
    personName,
    personPhone,
    documents,
    createdBy,
  } = req.body;

  try {
    const ImportO = new ImportO({
      orderId,
      medicineName,
      quantity,
      cost,
      length,
      width,
      height,
      unitWeight,
      totalWeight,
      supplierName,
      customerName,
      customerPhone,
      customerEmail,
      supplierLocation,
      customerLocation,
      supplierAddress,
      customerAddress,
      packageInfo,
      specialInstructions,
      trackingId,
      shippingType,
      vehicleNumber,
      personName,
      personPhone,
      documents,
      createdBy,
    });

    await ImportO.save();
    res.status(201).json({ message: 'Distribution order created successfully', ImportO });
  } catch (err) {
    res.status(400).json({ message: 'Error creating distribution order', error: err });
  }
});
/// Upload Documents for Import
app.post('/import/upload', upload.array('files'), async (req, res) => {
  const { orderId } = req.body;
  const files = req.files;

  try {
    const distribution = await ImportO.findOne({ orderId });
    if (!ImportO) {
      return res.status(404).json({ message: 'Distribution order not found' });
    }

    // Save file paths to the distribution order
    files.forEach((file) => {
      ImportO.documents.push(file.path);
    });

    await ImportO.save();
    res.status(200).json({ message: 'Documents uploaded successfully', ImportO });
  } catch (err) {
    console.error('Error uploading documents:', err);
    res.status(400).json({ message: 'Error uploading documents', error: err.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
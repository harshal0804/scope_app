// distribution-service/controllers/distributionController.js
const Distribution = require('../models/Distribution');
const winston = require('winston');
const path = require('path');

exports.getDistributionByOrderId = async (req, res) => {
  const { orderId } = req.params;
  try {
    const distributionOrder = await Distribution.findOne({ orderNumber: orderId });
    if (!distributionOrder) {
      winston.error('Distribution order not found');
      return res.status(404).json({ message: 'Distribution order not found' });
    }
    res.status(200).json(distributionOrder);
  } catch (error) {
    winston.error('Error fetching distribution details', error);
    res.status(500).json({ message: 'Error fetching distribution details' });
  }
};

exports.getAllDistributions = async (req, res) => {
  try {
    const distributions = await Distribution.find();
    res.status(200).json(distributions);
  } catch (error) {
    winston.error('Error fetching distributions', error);
    res.status(500).json({ message: 'Error fetching distributions' });
  }
};

exports.addDistribution = async (req, res) => {
  try {
    const newOrder = new Distribution(req.body);
    await newOrder.save();
    res.status(200).json({ message: 'Order placed successfully', order: newOrder });
  } catch (error) {
    winston.error('Error placing distribution order', error);
    res.status(500).json({ message: 'Error placing order' });
  }
};

exports.addDistributionWithFiles = async (req, res) => {
  const files = req.files;
  try {
    const newOrder = new Distribution(req.body);
    await newOrder.save();
    if (files && files.length > 0) {
      const filePaths = files.map(file => file.path);
      newOrder.documents = filePaths.map(filePath => ({
        title: path.basename(filePath),
        status: 'pending'
      }));
      await newOrder.save();
    }
    res.status(200).json({ message: 'Order placed successfully', order: newOrder });
  } catch (error) {
    winston.error('Error placing distribution order with files', error);
    res.status(500).json({ message: 'Error placing order' });
  }
};

exports.uploadFiles = (req, res) => {
  const { orderId, trackingId } = req.body;
  const files = req.files;
  if (!files || files.length === 0) {
    winston.error('No files uploaded');
    return res.status(400).json({ message: 'No files uploaded' });
  }
  winston.info(`Files uploaded for Order ID: ${orderId} & Tracking ID: ${trackingId}`);
  res.status(200).json({
    message: `Files uploaded successfully for Order ID: ${orderId} & Tracking ID: ${trackingId}`,
    files: files.map(file => file.path)
  });
};

exports.getFiles = async (req, res) => {
  const orderId = req.params.orderId;
  const fs = require('fs').promises;
  const path = require('path');
  const uploadDir = path.join(__dirname, '..', 'uploads', orderId);

  try {
    // Check if the directory exists by trying to access it.
    await fs.access(uploadDir);
  } catch (error) {
    return res.status(404).json({ message: 'No files found for this order' });
  }

  try {
    const files = await fs.readdir(uploadDir);
    return res.status(200).json({ files });
  } catch (error) {
    console.error('Error reading files:', error);
    return res.status(500).json({ message: 'Error reading files' });
  }
};

exports.seedDistribution = async (req, res) => {
  try {
    const sampleData = [
      {
        orderNumber: 'DIST004',
        trackingNumber: 'TRK001',
        customerName: 'John Doe',
        shippingAddress: '123 Main St, Anytown, Country',
        contactPhone: '1234567890',
        contactEmail: 'john@example.com',
        status: 'Pending',
        orderDate: new Date(),
        productInfo: {
          description: 'Electronics - Mobile Phones and Accessories',
          quantity: 5,
          unitWeight: '500g',
          totalWeight: '2.5kg',
          dimensions: {
            length: 10,
            width: 5,
            height: 2,
            unit: 'cm'
          }
        },
        analysis: {
          weightDistribution: 'Even',
          shippingClass: 'Standard',
          handlingRequirements: ['Handle with care', 'Keep dry'],
          specialInstructions: 'No stacking; fragile items'
        },
        deliveryTimeline: [
          { event: 'Order Placed', date: new Date(), completed: true }
        ],
        documents: [
          { title: 'Invoice.pdf', status: 'approved' }
        ],
        location: { latitude: 12.34, longitude: 56.78 },
        signature: 'John Doe'
      },
      {
        orderNumber: 'DIST002',
        trackingNumber: 'TRK002',
        customerName: 'Jane Smith',
        shippingAddress: '456 Another St, OtherTown, Country',
        contactPhone: '9876543210',
        contactEmail: 'jane@example.com',
        status: 'Shipped',
        orderDate: new Date(),
        productInfo: {
          description: 'Furniture - Office Chairs and Desks',
          quantity: 2,
          unitWeight: '10kg',
          totalWeight: '20kg',
          dimensions: {
            length: 100,
            width: 50,
            height: 40,
            unit: 'cm'
          }
        },
        analysis: {
          weightDistribution: 'Heavy',
          shippingClass: 'Expedited',
          handlingRequirements: ['Fragile', 'Keep upright'],
          specialInstructions: 'Do not drop; careful handling required'
        },
        deliveryTimeline: [
          { event: 'Order Placed', date: new Date(), completed: true },
          { event: 'Shipped', date: new Date(), completed: true }
        ],
        documents: [
          { title: 'Invoice.pdf', status: 'approved' },
          { title: 'PackingList.pdf', status: 'approved' }
        ],
        location: { latitude: 23.45, longitude: 67.89 },
        signature: 'Jane Smith'
      },
      {
        orderNumber: 'DIST003',
        trackingNumber: 'TRK003',
        customerName: 'Acme Corp',
        shippingAddress: '789 Industrial Rd, Industrial City, Country',
        contactPhone: '5551234567',
        contactEmail: 'contact@acmecorp.com',
        status: 'Delivered',
        orderDate: new Date(),
        productInfo: {
          description: 'Industrial Parts - Heavy Machinery Components',
          quantity: 50,
          unitWeight: '2kg',
          totalWeight: '100kg',
          dimensions: {
            length: 30,
            width: 20,
            height: 15,
            unit: 'cm'
          }
        },
        analysis: {
          weightDistribution: 'Bulk',
          shippingClass: 'Freight',
          handlingRequirements: ['Requires forklift', 'Secure packaging'],
          specialInstructions: 'Call before delivery; ensure proper handling'
        },
        deliveryTimeline: [
          { event: 'Order Placed', date: new Date(), completed: true },
          { event: 'Shipped', date: new Date(), completed: true },
          { event: 'Delivered', date: new Date(), completed: true }
        ],
        documents: [
          { title: 'DeliveryNote.pdf', status: 'approved' }
        ],
        location: { latitude: 34.56, longitude: 78.90 },
        signature: 'Acme Corp'
      }
    ];
    
    await Distribution.insertMany(sampleData);
    res.status(201).json({ message: 'Sample distribution data seeded successfully' });
  } catch (error) {
    winston.error('Error seeding distribution data', error);
    res.status(500).json({ message: 'Error seeding distribution data' });
  }
};
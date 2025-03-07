// distribution-service/models/Distribution.js
const mongoose = require('mongoose');

const distributionSchema = new mongoose.Schema({
  orderNumber: { type: String, required: true, unique: true },
  trackingNumber: { type: String, required: true },
  customerName: { type: String, required: true },
  shippingAddress: { type: String, required: true },
  contactPhone: { type: String, required: true },
  contactEmail: { type: String, required: true },
  status: {
    type: String,
    required: true,
    enum: ['Pending', 'Shipped', 'In Transit', 'Out for Delivery', 'Delivered'],
    default: 'Pending'
  },
  orderDate: { type: Date, required: true, default: Date.now },
  productInfo: {
    description: { type: String, required: true },
    quantity: { type: Number, required: true },
    unitWeight: { type: String, required: true },
    totalWeight: { type: String, required: true },
    dimensions: {
      length: { type: Number, required: true },
      width: { type: Number, required: true },
      height: { type: Number, required: true },
      unit: { type: String, required: true }
    }
  },
  analysis: {
    weightDistribution: { type: String, required: true },
    shippingClass: { type: String, required: true },
    handlingRequirements: [{ type: String }],
    specialInstructions: { type: String }
  },
  deliveryTimeline: [
    {
      event: { type: String, required: true },
      date: { type: Date, required: true },
      completed: { type: Boolean, default: false }
    }
  ],
  documents: [
    {
      title: { type: String, required: true },
      status: {
        type: String,
        required: true,
        enum: ['approved', 'pending', 'rejected']
      }
    }
  ],
  location: {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true }
  },
  signature: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Distribution', distributionSchema);

// import-service/models/DrugImport.js
const mongoose = require('mongoose');

const drugImportSchema = new mongoose.Schema({
  orderNo: { type: String, required: true },
  drugName: { type: String, required: true },
  supplier: { type: String, required: true },
  date: { type: String, required: true },
  poNumber: { type: String, required: true },
  paymentMethod: { type: String, required: true },
  documents: { type: [String], required: true },
  status: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('DrugImport', drugImportSchema);

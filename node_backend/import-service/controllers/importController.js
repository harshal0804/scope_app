// import-service/controllers/importController.js
const DrugImport = require('../models/DrugImport');
const winston = require('winston');

exports.getImports = async (req, res) => {
  try {
    const imports = await DrugImport.find();
    res.status(200).json(imports);
  } catch (error) {
    winston.error('Error fetching imports', error);
    res.status(500).json({ message: 'Error fetching imports' });
  }
};

exports.newImport = async (req, res) => {
  try {
    const newImport = new DrugImport(req.body);
    await newImport.save();
    res.status(201).json(newImport);
  } catch (error) {
    winston.error('Error creating new import', error);
    res.status(500).json({ message: 'Error creating new import' });
  }
};

exports.seedImports = async (req, res) => {
  try {
    const demoData = [
      {
        orderNo: 'ORD001',
        drugName: 'Paracetamol',
        supplier: 'PharmaCorp',
        date: '2025-01-10',
        poNumber: 'PO12345',
        paymentMethod: 'Credit',
        documents: ['COA.pdf', 'Invoice.pdf'],
        status: 'Shipped'
      },
      {
        orderNo: 'ORD002',
        drugName: 'Ibuprofen',
        supplier: 'HealthCare Supplies',
        date: '2025-01-12',
        poNumber: 'PO12346',
        paymentMethod: 'Bank Transfer',
        documents: ['COA.pdf', 'Invoice.pdf'],
        status: 'In Customs'
      },
      {
        orderNo: 'ORD003',
        drugName: 'Amoxicillin',
        supplier: 'MedLife Ltd',
        date: '2025-01-15',
        poNumber: 'PO12347',
        paymentMethod: 'Cash',
        documents: ['COA.pdf', 'Invoice.pdf', 'Shipping Label.pdf'],
        status: 'Delivered'
      }
    ];
    await DrugImport.insertMany(demoData);
    res.status(201).json({ message: 'Demo drug data seeded successfully' });
  } catch (error) {
    winston.error('Error seeding import data', error);
    res.status(500).json({ message: 'Error seeding import data' });
  }
};

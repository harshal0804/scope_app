import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path_package;
import 'package:async/async.dart';
import 'dart:io';

class NewOrderScreen extends StatefulWidget {
  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isImportSelected = false;

  // Form Controllers
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController medicineNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController unitWeightController = TextEditingController();
  final TextEditingController totalWeightController = TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController customerEmailController = TextEditingController();
  final TextEditingController packageInfoController = TextEditingController();
  final TextEditingController specialInstructionsController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController personNameController = TextEditingController();
  final TextEditingController personPhoneController = TextEditingController();

  // Location Variables
  LatLng? _supplierLocation;
  LatLng? _customerLocation;
  String? _supplierAddress;
  String? _customerAddress;
  bool _isLoadingAddress = false;

  // File Upload Variables
  List<PlatformFile> _uploadedFiles = [];

  // Delivery Details
  String? _trackingId;
  String? _shippingType;
  bool _isByRoad = false;

  @override
  void initState() {
    super.initState();
    orderIdController.text = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    _trackingId = 'TRK${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Order'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildToggleButtons(),
              SizedBox(height: 16),
              _buildStepperContainer(),
              SizedBox(height: 24),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleButton('Import', _isImportSelected, () {
            setState(() => _isImportSelected = true);
          }),
          _buildToggleButton('Distribution', !_isImportSelected, () {
            setState(() => _isImportSelected = false);
          }),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.orange : Colors.grey[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepperContainer() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildStepperHeader(),
          SizedBox(height: 24),
          _buildCurrentStepContent(),
        ],
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStepperCircle(0, 'Order'),
              _buildStepperLine(),
              _buildStepperCircle(1, 'Package'),
              _buildStepperLine(),
              _buildStepperCircle(2, 'Location'),
              _buildStepperLine(),
              _buildStepperCircle(3, 'Documents'),
              _buildStepperLine(),
              _buildStepperCircle(4, 'Delivery'),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          ['Order Details', 'Package Info', 'Location Info', 'Upload Documents', 'Delivery Details'][_currentStep],
          style: TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStepperCircle(int step, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentStep >= step ? Colors.orange : Colors.grey[700],
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: _currentStep >= step ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepperLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey[600],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildOrderDetails();
      case 1:
        return _buildPackageDetails();
      case 2:
        return _buildLocationDetails();
      case 3:
        return _buildDocumentUploadSection();
      case 4:
        return _buildDeliveryDetails();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildOrderDetails() {
    return Column(
      children: [
        _buildReadOnlyField('Order ID', orderIdController),
        _buildTextField(medicineNameController, 'Medicine Name'),
        _buildNumberField(quantityController, 'Quantity'),
        _buildNumberField(costController, 'Cost per Unit'),
      ],
    );
  }

  Widget _buildPackageDetails() {
    return Column(
      children: [
        _buildNumberField(lengthController, 'Length (cm)'),
        _buildNumberField(widthController, 'Width (cm)'),
        _buildNumberField(heightController, 'Height (cm)'),
        _buildNumberField(unitWeightController, 'Unit Weight (kg)'),
        _buildNumberField(totalWeightController, 'Total Weight (kg)'),
        _buildTextField(packageInfoController, 'Package Info'),
        _buildTextField(specialInstructionsController, 'Special Instructions'),
        _buildStatusDropdown(),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: 'Order Placed',
      items: ['Order Placed', 'Shipping', 'In Transit', 'Delivered']
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          // Update status
        });
      },
      decoration: InputDecoration(
        labelText: 'Status',
        filled: true,
        fillColor: Colors.grey[700],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: Colors.grey[400]),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildLocationDetails() {
    return Column(
      children: [
        _buildTextField(supplierNameController, 'Supplier Name'),
        _buildTextField(customerNameController, 'Customer Name'),
        _buildTextField(customerPhoneController, 'Customer Phone'),
        _buildTextField(customerEmailController, 'Customer Email'),
        SizedBox(height: 24),
        _buildLocationSection('Supplier Location', _supplierLocation, _supplierAddress, (loc) => _updateSupplierLocation(loc)),
        SizedBox(height: 24),
        _buildLocationSection('Customer Location', _customerLocation, _customerAddress, (loc) => _updateCustomerLocation(loc)),
      ],
    );
  }

  Widget _buildDocumentUploadSection() {
    return Column(
      children: [
        Text(
          'Upload Documents (PDF, DOC)',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickFiles,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: Text(
            'Choose Files',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildUploadedFilesList(),
      ],
    );
  }

  Widget _buildDeliveryDetails() {
    return Column(
      children: [
        _buildReadOnlyField('Tracking ID', TextEditingController(text: _trackingId)),
        _buildShippingTypeCheckbox(),
        if (_isByRoad) ...[
          _buildTextField(vehicleNumberController, 'Vehicle Number'),
          _buildTextField(personNameController, 'Person Name'),
          _buildTextField(personPhoneController, 'Person Phone'),
        ],
      ],
    );
  }

  Widget _buildShippingTypeCheckbox() {
    return Column(
      children: [
        CheckboxListTile(
          title: Text('By Road', style: TextStyle(color: Colors.white)),
          value: _isByRoad,
          onChanged: (value) {
            setState(() {
              _isByRoad = value!;
              _shippingType = 'By Road'; // Set shipping type
            });
          },
          activeColor: Colors.orange,
        ),
        CheckboxListTile(
          title: Text('By Air', style: TextStyle(color: Colors.white)),
          value: !_isByRoad,
          onChanged: (value) {
            setState(() {
              _isByRoad = !value!;
              _shippingType = 'By Air'; // Set shipping type
            });
          },
          activeColor: Colors.orange,
        ),
      ],
    );
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _uploadedFiles.addAll(result.files);
      });
    }
  }

  Widget _buildUploadedFilesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _uploadedFiles.length,
      itemBuilder: (context, index) {
        final file = _uploadedFiles[index];
        return ListTile(
          leading: Icon(Icons.insert_drive_file, color: Colors.orange),
          title: Text(file.name, style: TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeFile(index),
          ),
        );
      },
    );
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  Widget _buildLocationSection(String title, LatLng? location, String? address, Function(LatLng) onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.orange,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _buildMapPicker(location, onUpdate),
        SizedBox(height: 12),
        _buildAddressDisplay(address),
      ],
    );
  }

  Widget _buildMapPicker(LatLng? location, Function(LatLng) onUpdate) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(51.509364, -0.128928),
          zoom: 10.0,
          onTap: (tapPosition, point) => onUpdate(point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          if (location != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: location,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_on, color: Colors.orange, size: 40),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAddressDisplay(String? address) {
    if (_isLoadingAddress) {
      return Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 12),
          Text('Fetching address...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }
    return address != null
        ? Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(address, style: TextStyle(color: Colors.white)),
    )
        : SizedBox.shrink();
  }

  Future<void> _updateSupplierLocation(LatLng location) async {
    setState(() {
      _supplierLocation = location;
      _supplierAddress = null;
    });
    await _fetchAddress(location, true);
  }

  Future<void> _updateCustomerLocation(LatLng location) async {
    setState(() {
      _customerLocation = location;
      _customerAddress = null;
    });
    await _fetchAddress(location, false);
  }

  Future<void> _fetchAddress(LatLng location, bool isSupplier) async {
    setState(() => _isLoadingAddress = true);
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] ?? 'Unknown location';
        setState(() {
          if (isSupplier) {
            _supplierAddress = address;
          } else {
            _customerAddress = address;
          }
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavigationButton('Back', _currentStep > 0 ? Colors.orange : Colors.grey,
            onPressed: _currentStep > 0 ? () => setState(() => _currentStep--) : null),
        _buildNavigationButton(
          _currentStep == 4 ? 'Submit' : 'Next',
          Colors.orange,
          onPressed: _handleNavigation,
        ),
      ],
    );
  }

  Widget _buildNavigationButton(String text, Color color, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _handleNavigation() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      if (_formKey.currentState!.validate()) {
        _submitOrder();
      }
    }
  }

  Future<void> _submitOrder() async {
    try {
      // Prepare the order data
      final orderData = {
        'orderId': orderIdController.text,
        'medicineName': medicineNameController.text,
        'quantity': quantityController.text,
        'cost': costController.text,
        'length': lengthController.text,
        'width': widthController.text,
        'height': heightController.text,
        'unitWeight': unitWeightController.text,
        'totalWeight': totalWeightController.text,
        'supplierName': supplierNameController.text,
        'customerName': customerNameController.text,
        'customerPhone': customerPhoneController.text,
        'customerEmail': customerEmailController.text,
        'supplierLocation': _supplierLocation != null
            ? '${_supplierLocation!.latitude},${_supplierLocation!.longitude}'
            : null,
        'customerLocation': _customerLocation != null
            ? '${_customerLocation!.latitude},${_customerLocation!.longitude}'
            : null,
        'supplierAddress': _supplierAddress,
        'customerAddress': _customerAddress,
        'packageInfo': packageInfoController.text,
        'specialInstructions': specialInstructionsController.text,
        'trackingId': _trackingId,
        'shippingType': _shippingType, // Ensure this is set
        'createdBy': '64f1b2c3e4d5f6a7b8c9d0e1', // Replace with a valid ObjectId
        'vehicleNumber': _isByRoad ? vehicleNumberController.text : null,
        'personName': _isByRoad ? personNameController.text : null,
        'personPhone': _isByRoad ? personPhoneController.text : null,
      };

      // Log the request payload
      print('Submitting order data: $orderData');

      // Determine the endpoint based on the toggle button
      final endpoint = _isImportSelected ? '/importadd' : '/distributionadd'; // Ensure this matches your server endpoint

      // Send the order data to the server
      final response = await http.post(
        Uri.parse('http://192.168.177.68:3000$endpoint'), // Ensure this URL is correct
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      // Log the response
      print('Server response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        // Upload files if any
        if (_uploadedFiles.isNotEmpty) {
          await _uploadFiles(orderIdController.text);
        }

        // Use the correct BuildContext from the widget
        _showConfirmationDialog(this.context);
      } else {
        throw Exception('Failed to submit order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting order: $e');
      // Use the correct BuildContext from the widget
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Failed to submit order: $e')),
      );
    }
  }

  Future<void> _uploadFiles(String orderId) async {
    try {
      for (var platformFile in _uploadedFiles) {
        // Convert PlatformFile to File
        final file = File(platformFile.path!);

        // Open the file stream
        var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));

        // Get the file length
        var length = await file.length();

        // Prepare the request
        var uri = Uri.parse('http://192.168.177.68:3000/distribution/upload');
        var request = http.MultipartRequest('POST', uri)
          ..fields['orderId'] = orderId
          ..files.add(http.MultipartFile(
            'files',
            stream,
            length,
            filename: path_package.basename(file.path),
          ));

        // Send the request
        var response = await request.send();

        // Check the response
        if (response.statusCode != 200) {
          throw Exception('Failed to upload file');
        }
      }
    } catch (e) {
      print('Error uploading files: $e');
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Failed to upload files')),
      );
    }
  }

  void _showConfirmationDialog(BuildContext buildContext) {
    showDialog(
      context: buildContext,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          'Order Submitted',
          style: TextStyle(color: Colors.orange),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${orderIdController.text}',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              'Medicine: ${medicineNameController.text}',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              'Total Weight: ${totalWeightController.text} kg',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[700],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.grey[400]),
        ),
        style: TextStyle(color: Colors.white),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[700],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.grey[400]),
        ),
        style: TextStyle(color: Colors.white),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[700],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.grey[400]),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
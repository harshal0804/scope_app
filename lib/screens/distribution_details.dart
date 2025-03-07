import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  OrderTrackingScreen({required this.orderId});

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  bool hasError = false;
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }
  }

  Future<void> fetchOrderDetails() async {
    print('Fetching details for Order ID: ${widget.orderId}');
    try {
      final url = Uri.parse('http://192.168.177.68:3000/distribution/${widget.orderId}');
      print('Request URL: $url');

      final response = await http.get(url);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          orderData = json.decode(response.body);
          isLoading = false;
        });
        calculateRoutePoints();
      } else {
        print('Failed to load order details. Status code: ${response.statusCode}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void calculateRoutePoints() {
    final supplierLocation = orderData!['supplierLocation'].split(',').map(double.parse).toList();
    final customerLocation = orderData!['customerLocation'].split(',').map(double.parse).toList();

    final start = LatLng(supplierLocation[0], supplierLocation[1]);
    final end = LatLng(customerLocation[0], customerLocation[1]);

    setState(() {
      routePoints = [start, end];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Tracking', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[500],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : hasError
          ? Center(
        child: Text(
          'Failed to load order details. Please check your connection and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700]),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetails(),
            SizedBox(height: 16),
            _buildCustomerDetails(),
            SizedBox(height: 16),
            _buildProductInfo(),
            SizedBox(height: 16),
            _buildShippingDetails(),
            SizedBox(height: 16),
            _buildMap(),
            SizedBox(height: 16),
            _buildStatusStepper(),
            SizedBox(height: 16),
            _buildDocuments(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    // Construct the URL with the dynamic orderId
    final String qrData = 'http://192.168.177.68:3000/web?id=${orderData!['_id']}';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // QR Code with the URL
                QrImageView(
                  data: qrData, // Pass the URL directly
                  version: QrVersions.auto,
                  size: 80.0,
                  foregroundColor: Colors.white,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${orderData!['orderId']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Tracking ID: ${orderData!['trackingId']}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildStatusBadge(orderData!['status']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor = status == "Delivered" ? Colors.green : Colors.orange;
    return Chip(
      label: Text(status, style: TextStyle(color: Colors.white)),
      backgroundColor: badgeColor,
    );
  }

  Widget _buildCustomerDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            _buildInfoItem('Name', orderData!['customerName']),
            _buildInfoItem('Phone', orderData!['customerPhone']),
            _buildInfoItem('Email', orderData!['customerEmail']),
            _buildInfoItem('Address', orderData!['customerAddress'], maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            _buildInfoItem('Medicine Name', orderData!['medicineName']),
            _buildInfoItem('Quantity', '${orderData!['quantity']} units'),
            _buildInfoItem('Unit Weight', '${orderData!['unitWeight']} kg'),
            _buildInfoItem('Total Weight', '${orderData!['totalWeight']} kg'),
            _buildInfoItem('Dimensions', '${orderData!['length']} x ${orderData!['width']} x ${orderData!['height']} cm'),
            _buildInfoItem('Package Info', orderData!['packageInfo']),
            _buildInfoItem('Special Instructions', orderData!['specialInstructions']),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            _buildInfoItem('Shipping Type', orderData!['shippingType']),
            _buildInfoItem('Supplier Name', orderData!['supplierName']),
            _buildInfoItem('Supplier Address', orderData!['supplierAddress'], maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    final supplierLocation = orderData!['supplierLocation'].split(',').map(double.parse).toList();
    final customerLocation = orderData!['customerLocation'].split(',').map(double.parse).toList();

    final supplierLatLng = LatLng(supplierLocation[0], supplierLocation[1]);
    final customerLatLng = LatLng(customerLocation[0], customerLocation[1]);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: supplierLatLng,
            initialZoom: 10.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: supplierLatLng,
                  child: Icon(Icons.location_on, color: Colors.orange, size: 30),
                ),
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: customerLatLng,
                  child: Icon(Icons.location_on, color: Colors.green, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper() {
    final locationHistory = orderData!['locationHistory'];
    final List<dynamic> historyList = locationHistory is Map
        ? locationHistory['type'] is List
        ? locationHistory['type']
        : []
        : locationHistory is List
        ? locationHistory
        : [];

    if (historyList.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[850],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'No location history available',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ...historyList.map((history) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.orange[500],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        history['status'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(left: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location: ${history['location']}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Time: ${history['timestamp']}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocuments() {
    // Ensure orderData is not null
    if (orderData == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[850],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No order data available',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    // Ensure documents is a List and not null
    final documents = orderData!['documents'] as List? ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            if (documents.isEmpty)
              Text(
                'No documents available',
                style: TextStyle(color: Colors.grey[400]),
              ),
            if (documents.isNotEmpty)
              ...documents.map((doc) {
                // Extract the file name from the path
                final fileName = doc.split('/').last;
                return ListTile(
                  title: Text(
                    fileName,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.download, color: Colors.white),
                    onPressed: () {
                      // Trigger download functionality
                      _downloadDocument(fileName);
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // Function to handle document download
  void _downloadDocument(String filePath) async {
    try {
      // Extract the filename from the full path
      final filename = filePath.split('/').last;

      // Get the application documents directory
      final dir = await getApplicationDocumentsDirectory();
      final localFilePath = '${dir.path}/$filename';

      // Construct the download URL
      final downloadUrl = 'http://192.168.177.68:3000/distribution/${widget.orderId}/download/$filename';

      print('Download URL: $downloadUrl'); // Debugging

      // Send a GET request to download the file
      final response = await http.get(Uri.parse(downloadUrl));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Save the file to the local path
        final file = File(localFilePath);
        await file.writeAsBytes(response.bodyBytes);

        print('File downloaded successfully to: $localFilePath');

        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded: $filename')),
        );
      } else {
        // Handle HTTP errors
        print('Failed to download file. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download file: HTTP ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Failed to download file: $e');

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: ${e.toString()}')),
      );
    }
  }
  Widget _buildInfoItem(String title, String value, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[400]),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
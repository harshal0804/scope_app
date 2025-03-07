import 'package:flutter/material.dart';
import 'package:fyjsproject/screens/distribution_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Order {
  final String id;
  final String orderId;
  final String medicineName;
  final int quantity;
  final double cost;
  final int length;
  final int width;
  final int height;
  final double unitWeight;
  final double totalWeight;
  final String supplierName;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String supplierLocation;
  final String customerLocation;
  final String supplierAddress;
  final String customerAddress;
  final String packageInfo;
  final String specialInstructions;
  final String trackingId;
  final String shippingType;
  final String? vehicleNumber;
  final String? personName;
  final String? personPhone;
  final List<String> documents;
  final String createdBy;
  final String createdAt;
  final String status;

  Order({
    required this.id,
    required this.orderId,
    required this.medicineName,
    required this.quantity,
    required this.cost,
    required this.length,
    required this.width,
    required this.height,
    required this.unitWeight,
    required this.totalWeight,
    required this.supplierName,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.supplierLocation,
    required this.customerLocation,
    required this.supplierAddress,
    required this.customerAddress,
    required this.packageInfo,
    required this.specialInstructions,
    required this.trackingId,
    required this.shippingType,
    this.vehicleNumber,
    this.personName,
    this.personPhone,
    required this.documents,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? 'N/A',
      orderId: json['orderId'] ?? 'N/A',
      medicineName: json['medicineName'] ?? 'Unknown Medicine',
      quantity: json['quantity'] ?? 0,
      cost: json['cost']?.toDouble() ?? 0.0,
      length: json['length'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      unitWeight: json['unitWeight']?.toDouble() ?? 0.0,
      totalWeight: json['totalWeight']?.toDouble() ?? 0.0,
      supplierName: json['supplierName'] ?? 'Unknown Supplier',
      customerName: json['customerName'] ?? 'Unknown Customer',
      customerPhone: json['customerPhone'] ?? 'N/A',
      customerEmail: json['customerEmail'] ?? 'N/A',
      supplierLocation: json['supplierLocation'] ?? 'N/A',
      customerLocation: json['customerLocation'] ?? 'N/A',
      supplierAddress: json['supplierAddress'] ?? 'N/A',
      customerAddress: json['customerAddress'] ?? 'N/A',
      packageInfo: json['packageInfo'] ?? 'N/A',
      specialInstructions: json['specialInstructions'] ?? 'N/A',
      trackingId: json['trackingId'] ?? 'N/A',
      shippingType: json['shippingType'] ?? 'N/A',
      vehicleNumber: json['vehicleNumber'],
      personName: json['personName'],
      personPhone: json['personPhone'],
      documents: List<String>.from(json['documents'] ?? []),
      createdBy: json['createdBy'] ?? 'N/A',
      createdAt: json['createdAt'] ?? 'N/A',
      status: json['status'] ?? 'Pending',
    );
  }
}

class DistributionScreen extends StatefulWidget {
  @override
  _DistributionScreenState createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  List<Order> _orders = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isImportSelected = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final endpoint = _isImportSelected ? '/import' : '/distribution';
      final response = await http.get(
        Uri.parse('http://192.168.177.68:3000$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          _orders = responseData.map((json) => Order.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Order> _getFilteredOrders() {
    return _orders.where((order) {
      final matchesSearch = order.orderId
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          order.customerName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' ||
          order.status.toLowerCase() == _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Map<String, int> _getStatusCounts() {
    final counts = {
      'Pending': 0,
      'Shipped': 0,
      'Delivered': 0,
      'Customs Clearance': 0,
      'In Transit': 0,
    };

    for (var order in _orders) {
      if (counts.containsKey(order.status)) {
        counts[order.status] = counts[order.status]! + 1;
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();
    final statusCounts = _getStatusCounts();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          _isImportSelected ? 'Import Management' : 'Distribution Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange[500],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildFilterChips(),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.orange))
                : filteredOrders.isEmpty
                ? Center(
              child: Text(
                'No orders found',
                style: TextStyle(color: Colors.grey[300]),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index], context), // Pass context here
            ),
          ),
          _buildStatusIndicator(statusCounts),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[500],
        onPressed: _fetchOrders,
        child: Icon(Icons.refresh),
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
            setState(() {
              _isImportSelected = true;
              _fetchOrders();
            });
          }),
          _buildToggleButton('Distribution', !_isImportSelected, () {
            setState(() {
              _isImportSelected = false;
              _fetchOrders();
            });
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

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by order ID or customer...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Shipped', 'Delivered', 'Customs Clearance', 'In Transit'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map((filter) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text(filter),
            selected: _selectedFilter == filter,
            selectedColor: Colors.orange[500],
            labelStyle: TextStyle(
              color: _selectedFilter == filter ? Colors.black : Colors.white,
            ),
            backgroundColor: Colors.grey[800],
            onSelected: (selected) => setState(
                    () => _selectedFilter = selected ? filter : 'All'),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order.orderId}',
                  style: TextStyle(
                    color: Colors.orange[500],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow('Customer:', order.customerName),
            _buildInfoRow('Medicine:', order.medicineName),
            _buildInfoRow('Quantity:', '${order.quantity} units'),
            _buildInfoRow('Tracking ID:', order.trackingId),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  order.shippingType == 'By Air' ? Icons.airplanemode_active : Icons.directions_car,
                  color: Colors.orange[500],
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  order.shippingType,
                  style: TextStyle(
                    color: Colors.orange[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to the OrderTrackingScreen with the MongoDB _id
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingScreen(orderId: order.id), // Use order.id (MongoDB _id)
                    ),
                  );
                },
                child: Text(
                  'View Details',
                  style: TextStyle(color: Colors.orange[500]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: Colors.orange[500],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(Map<String, int> statusCounts) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem('Pending', statusCounts['Pending'] ?? 0),
          _buildStatusItem('Shipped', statusCounts['Shipped'] ?? 0),
          _buildStatusItem('Delivered', statusCounts['Delivered'] ?? 0),
          _buildStatusItem('Customs', statusCounts['Customs Clearance'] ?? 0),
          _buildStatusItem('In Transit', statusCounts['In Transit'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.orange[500],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow[400]!;
      case 'shipped':
        return Colors.blue[400]!;
      case 'delivered':
        return Colors.green[400]!;
      case 'customs clearance':
        return Colors.purple[400]!;
      case 'in transit':
        return Colors.orange[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  // void _showOrderDetails(Order order) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.grey[800],
  //       title: Text('Order Details', style: TextStyle(color: Colors.orange[500])),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             _buildDetailItem('Order ID:', order.orderId),
  //             _buildDetailItem('Medicine:', order.medicineName),
  //             _buildDetailItem('Quantity:', '${order.quantity} units'),
  //             _buildDetailItem('Cost:', '\$${order.cost.toStringAsFixed(2)}'),
  //             _buildDetailItem('Supplier:', order.supplierName),
  //             _buildDetailItem('Customer:', order.customerName),
  //             _buildDetailItem('Tracking ID:', order.trackingId),
  //             _buildDetailItem('Shipping Type:', order.shippingType),
  //             _buildDetailItem('Vehicle Number:', order.vehicleNumber ?? 'N/A'),
  //             _buildDetailItem('Person Name:', order.personName ?? 'N/A'),
  //             _buildDetailItem('Person Phone:', order.personPhone ?? 'N/A'),
  //             _buildDetailItem('Special Instructions:', order.specialInstructions),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Close', style: TextStyle(color: Colors.orange[500])),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: Colors.orange[500],
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
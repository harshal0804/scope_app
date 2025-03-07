import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image upload
import 'dart:io'; // For handling file paths
import 'package:http/http.dart' as http; // For API calls
import 'package:fyjsproject/screens/login.dart'; // Import the LoginScreen
import 'dart:convert'; // For JSON encoding/decoding

class Profile extends StatefulWidget {


  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  File? _profileImage; // To store the selected image file

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Replace with your API endpoint and user ID/email
      final url = Uri.parse('http://192.168.177.68:3000/users/get-user-by-id/67c9df382882eaac92b18b0d'); // Example: Fetch user with ID 1
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data; // Store the fetched user data
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  void _logout() {
    // Delete the token (clear it from storage or state)
    // For now, we'll just print a message and navigate to the LoginScreen
    print("Token deleted. Logging out...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Store the selected image file
      });

      // Upload the image to the server (replace with your API call)
      await _uploadProfileImage(_profileImage!);
    }
  }

  // Function to upload the profile image to the server
  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      // Replace with your API endpoint
      final url = Uri.parse('http://192.168.177.68:3000/users/upload-profile-image');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('profilePicture', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        print("Profile image uploaded successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully')),
        );
      } else {
        throw Exception('Failed to upload profile image');
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading profile image: $e')),
      );
    }
  }

  void _showEditProfileAlert(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: userData?['username']);
    TextEditingController phoneController = TextEditingController(text: userData?['phone']);
    TextEditingController emailController = TextEditingController(text: userData?['email']);
    TextEditingController locationController = TextEditingController(text: userData?['location']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262626),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField('Name', nameController),
              _buildEditField('Phone', phoneController),
              _buildEditField('Email', emailController),
              _buildEditField('Location', locationController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () async {
                final updatedData = {
                  'username': nameController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'location': locationController.text,
                };

                // Call your API to update the profile
                await _updateProfile(updatedData);
                Navigator.pop(context);
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }


  // Function to update the profile via API
  Future<void> _updateProfile(Map<String, dynamic> updatedData) async {
    try {
      // Convert image to Base64 if it exists in the updatedData map
      if (updatedData.containsKey('image') && updatedData['image'] is File) {
        File imageFile = updatedData['image'];
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        updatedData['image'] = base64Image; // Replace the File with Base64 string
      }

      final url = Uri.parse('http://192.168.177.68:3000/users/update-profile');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        print("Profile updated successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );

        // Refresh user data
        fetchUserData();
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

// Example of picking an image and updating the profile
  Future<void> pickImageAndUpdateProfile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Map<String, dynamic> updatedData = {
        'name': 'New Name', // Example field
        'email': 'newemail@example.com', // Example field
        'image': imageFile, // Include the image file
      };

      await _updateProfile(updatedData);
    }
  }
  void _showOrderHistory(BuildContext context) {
    final List<Map<String, String>> demoOrders = [
      {'orderNumber': 'ORD123', 'date': '2023-10-01', 'status': 'Delivered'},
      {'orderNumber': 'ORD124', 'date': '2023-10-05', 'status': 'Pending'},
      {'orderNumber': 'ORD125', 'date': '2023-09-20', 'status': 'Shipped'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262626),
          title: const Text(
            'Order History',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: demoOrders.length,
              itemBuilder: (context, index) {
                final order = demoOrders[index];
                return ListTile(
                  title: Text(
                    'Order: ${order['orderNumber']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Date: ${order['date']} | Status: ${order['status']}',
                    style: const TextStyle(color: Color(0xFF878787)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentMethods(BuildContext context) {
    final List<Map<String, String>> demoPayments = [
      {'method': 'Credit Card', 'details': '**** **** **** 1234'},
      {'method': 'PayPal', 'details': 'user@example.com'},
      {'method': 'Bank Transfer', 'details': 'Account: 123456789'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262626),
          title: const Text(
            'Payment Methods',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: demoPayments.length,
              itemBuilder: (context, index) {
                final payment = demoPayments[index];
                return ListTile(
                  title: Text(
                    'Method: ${payment['method']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Details: ${payment['details']}',
                    style: const TextStyle(color: Color(0xFF878787)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151419),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back and Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF878787)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Color(0xFF878787),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48), // Placeholder for alignment
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Picture Section
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) // Use the selected image
                          : NetworkImage(userData?['profilePicture'] ?? 'https://via.placeholder.com/120x120')
                      as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _pickImage, // Open image picker
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF151419),
                          border: Border.all(color: const Color(0xFF262626), width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Color(0xFF878787), size: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userData?['username'] ?? 'Loading...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${userData?['email'] ?? ''} | ${userData?['phone'] ?? ''}',
                style: const TextStyle(
                  color: Color(0xFF878787),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Profile Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildProfileOption(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        _showSettingsAlert(context);
                      },
                    ),
                    const Divider(color: Color(0xFF262626), height: 1),
                    _buildProfileOption(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () {
                        _showEditProfileAlert(context);
                      },
                    ),
                    const Divider(color: Color(0xFF262626), height: 1),
                    _buildProfileOption(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: _logout,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Additional Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Order History',
                      subtitle: 'View your past orders',
                      icon: Icons.shopping_cart,
                      onTap: () {
                        _showOrderHistory(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Payment Methods',
                      subtitle: 'Manage your payment options',
                      icon: Icons.payment,
                      onTap: () {
                        _showPaymentMethods(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Support',
                      subtitle: 'Get help and support',
                      icon: Icons.support,
                      onTap: () {
                        // Navigate to Support
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF878787)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF878787), size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      color: const Color(0xFF262626),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF878787)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF878787),
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF878787), size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showSettingsAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262626),
          title: const Text(
            'App Permissions',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPermissionItem('Location', 'Used for tracking shipments'),
              _buildPermissionItem('Camera', 'Used for scanning barcodes'),
              _buildPermissionItem('Media', 'Used for uploading documents'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF878787),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
Widget _buildEditField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:fyjsproject/screens/distribute_new.dart';

import 'package:fyjsproject/screens/distribution_details.dart';
import 'package:fyjsproject/screens/home.dart';

import 'package:fyjsproject/screens/login.dart';
import 'package:fyjsproject/screens/profile.dart';


// Import OrdersPage
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        primaryColor: Colors.orange,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/distribution_details': (context) => OrderTrackingScreen(orderId: ''),
        '/profile': (context) => Profile(),

        '/distribution_new': (context) => NewOrderScreen(),

      },
    );
  }
}
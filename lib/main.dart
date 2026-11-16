import 'package:flutter/material.dart';

import 'screens/login_screen.dart'; // Import file dari folder screens

void main() {
  runApp(const AkuSehatApp());
}

class AkuSehatApp extends StatelessWidget {
  const AkuSehatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AkuSehat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F9D8A)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

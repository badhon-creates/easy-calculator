import 'package:flutter/material.dart';

void main() {
  runApp(const EasyCalculatorApp());
}

/// Root widget for Easy Calculator application.
class EasyCalculatorApp extends StatelessWidget {
  const EasyCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF64AFFA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF64AFFA),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1F1C1C),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const FoundationHomeScreen(),
    );
  }
}

/// Initial Phase 0 placeholder home screen to verify build and launch.
class FoundationHomeScreen extends StatelessWidget {
  const FoundationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Easy Calculator'), centerTitle: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_rounded, size: 72, color: Color(0xFF64AFFA)),
            SizedBox(height: 16),
            Text(
              'Easy Calculator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Phase 0 Foundation Verified',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

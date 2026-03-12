import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('.env loaded successfully');
    debugPrint('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
  } catch (e) {
    debugPrint('Failed to load .env: $e');
  }
  runApp(const FamilyMapApp());
}

class FamilyMapApp extends StatelessWidget {
  const FamilyMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0EA5E9)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

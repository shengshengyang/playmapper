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
    const seedColor = Color(0xFF0EA5E9);

    return MaterialApp(
      title: 'Family Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F6FA),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF2F6FA)),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E1E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E1E8)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

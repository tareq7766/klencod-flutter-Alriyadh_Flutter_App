import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlriyadhApp());
}

class AlriyadhApp extends StatelessWidget {
  const AlriyadhApp({super.key});

  static const Color cement = Color(0xFF39434A);
  static const Color orange = Color(0xFFD47A35);
  static const Color sand = Color(0xFFF5F2ED);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مصنع الرياض للبلك الأوتوماتيكي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: cement,
          secondary: orange,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: sand,
        appBarTheme: const AppBarTheme(
          backgroundColor: cement,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1.5,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: sand,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const HomeScreen(),
    );
  }
}
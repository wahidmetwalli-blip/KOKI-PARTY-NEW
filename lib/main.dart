
import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KokiPartyApp());
}

class KokiPartyApp extends StatelessWidget {
  const KokiPartyApp({super.key});

  static const Color background = Color(0xFF090711);
  static const Color gold = Color(0xFFFFD36A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KOKI PARTY',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        primaryColor: gold,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: Color(0xFF8957F5),
          surface: Color(0xFF191529),
        ),
        useMaterial3: true,
      ),
      home: const LuxuryAuthScreen(),
    );
  }
}

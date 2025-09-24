// lib/main.dart
import 'package:eshifa/admin.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const EshifaLabApp());
}

class EshifaLabApp extends StatelessWidget {
  const EshifaLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandSeed = Color(0xFFD7263D);
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: brandSeed,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mirabella eShifa Lab - Advanced Medical Testing',
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
          bodyColor: const Color(0xFF2C3E50),
          displayColor: const Color(0xFF2C3E50),
        ),
      ),
      // IMPORTANT: Register routes so Navigator.pushNamed('/admin') works
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/admin': (_) => const AdminGate(),
        '/login': (_) => const LoginPage(),
      },
    );
  }
}

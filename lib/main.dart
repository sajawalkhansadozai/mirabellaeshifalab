// lib/main.dart
import 'package:eshifa/admin.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (web config already includes measurementId)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ensure Analytics collection is enabled (good for regions without consent gating)
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // Small one-time test event to "wake" analytics on web builds
  await FirebaseAnalytics.instance.logEvent(name: 'dbg_ping');

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

    // Analytics instance + navigator observer for automatic screen_view
    final analytics = FirebaseAnalytics.instance;
    final observer = FirebaseAnalyticsObserver(analytics: analytics);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mirabella eShifa Lab - Advanced Medical Testing',
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
          bodyColor: const Color(0xFF2C3E50),
          displayColor: const Color(0xFF2C3E50),
        ),
      ),

      // IMPORTANT: routes registered so Navigator.pushNamed works
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/admin': (_) => const AdminGate(),
        '/login': (_) => const LoginPage(),
      },

      // 🔥 This enables automatic screen_view events on navigation
      navigatorObservers: [observer],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ForUMHUB/pages/login_page.dart';
import 'package:ForUMHUB/pages/search_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase using platform configs (google-services.json / GoogleService-Info.plist)
  // NOTE: Do NOT store API keys or secrets in repo. If you need to use custom options locally,
  // create a `lib/firebase_options_local.dart` (ignored) or use the FlutterFire CLI to generate
  // `firebase_options.dart` per platform.
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFFB8C00);
    const Color softBackground = Color(0xFFF8F9FA);

    return MaterialApp(
      title: 'ForUMhub',
      debugShowCheckedModeBanner: false,
      routes: {
        '/search': (context) => const SearchPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        // ADDED: Global Smooth Transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryOrange,
          primary: primaryOrange,
          secondary: const Color(0xFF8D2C2C),
          surface: Colors.white,
          background: softBackground,
        ),
        scaffoldBackgroundColor: softBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

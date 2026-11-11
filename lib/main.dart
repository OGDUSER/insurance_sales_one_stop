
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ============================================
// DATABASE
// ============================================

import 'database/database_helper.dart';

// ============================================
// AUTHENTICATION SCREENS
// ============================================

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_otp_screen.dart';
import 'screens/reset_password_screen.dart';

// ============================================
// DASHBOARD
// ============================================

import 'screens/dashboard_screen.dart';

// ============================================
// INSURANCE SERVICES
// ============================================

import 'screens/products_screen.dart';
import 'screens/quote_screen.dart';
import 'screens/application_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/notifications_screen.dart';

// ============================================
// ADMINISTRATION
// ============================================
import 'screens/admin_review_screen.dart';

// ============================================
// MAIN FUNCTION
// ============================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for desktop platforms.
  // Android and iOS use the normal sqflite package.

  if (Platform.isWindows ||
      Platform.isLinux ||
      Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize the database before opening screens.
  try {
    await DatabaseHelper.instance.database;
    debugPrint('HBF database initialized successfully');
  } catch (error) {
    debugPrint('Database initialization error: $error');
  }

  runApp(const HBFInsuranceApp());
}

// ============================================
// MAIN APPLICATION
// ============================================

class HBFInsuranceApp extends StatelessWidget {
  const HBFInsuranceApp({super.key});

  // HBF BRAND COLOURS

  static const Color hbfGreen = Color(0xFF005A3C);
  static const Color hbfMaroon = Color(0xFF800020);
  static const Color hbfGold = Color(0xFFD4A017);
  static const Color hbfCream = Color(0xFFF7F4EC);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HBF Insurance Sales One Stop',

      debugShowCheckedModeBanner: false,

      // ======================================
      // APPLICATION THEME
      // ======================================

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: hbfCream,

        colorScheme: ColorScheme.fromSeed(
          seedColor: hbfGreen,
          primary: hbfGreen,
          secondary: hbfGold,
          surface: hbfCream,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: hbfGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: hbfMaroon,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: hbfGreen,
              width: 2,
            ),
          ),
        ),

        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),

      // ======================================
      // FIRST SCREEN
      // ======================================

      initialRoute: '/login',

      // ======================================
      // ALL APPLICATION ROUTES
      // ======================================

      routes: {
        // LOGIN
        '/': (context) => const LoginScreen(),

        '/login': (context) => const LoginScreen(),

        // REGISTRATION
        '/register': (context) =>
        const RegisterScreen(),

        // DASHBOARD
        '/dashboard': (context) =>
        const AdminDashboardScreen(),

        // PASSWORD RECOVERY
        '/forgot-password': (context) =>
        const ForgotPasswordScreen(),

        '/verify-otp': (context) =>
        const VerifyOtpScreen(),

        '/reset-password': (context) =>
        const ResetPasswordScreen(),

        // INSURANCE PRODUCTS
        '/products': (context) =>
        const ProductsScreen(),

        // REQUEST QUOTATION
        '/quote': (context) =>
        const QuoteScreen(),

        // INSURANCE APPLICATION
        '/application': (context) =>
        const ApplicationScreen(),

        // UPLOAD DOCUMENTS
        '/upload': (context) =>
        const UploadScreen(),

        // TRACK APPLICATION
        '/tracking': (context) =>
        const TrackingScreen(),

        // NOTIFICATIONS
        '/notifications': (context) =>
        const NotificationsScreen(),

        // ADMINISTRATOR APPROVAL
        '/admin-review': (context) =>
        const AdminReviewScreen(),
      },

      // ======================================
      // UNKNOWN ROUTE HANDLING
      // ======================================

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Page Not Found'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 70,
                    color: hbfMaroon,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'Unknown page: ${settings.name}',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false,
                      );
                    },
                    child: const Text('GO TO LOGIN'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

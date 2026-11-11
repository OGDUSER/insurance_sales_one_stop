
import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  static const Color green = Color(0xFF005A3C);
  static const Color maroon = Color(0xFF800020);
  static const Color gold = Color(0xFFD4A017);

  String selectedRole = 'customer';

  bool hidePassword = true;
  bool isLoggingIn = false;

  // ======================================
  // LOGIN AUTHENTICATION
  // ======================================

  Future<void> login() async {
    if (isLoggingIn) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    setState(() {
      isLoggingIn = true;
    });

    try {
      final user = await DatabaseHelper.instance.loginUser(
        email,
        password,
      );

      if (!mounted) return;

      if (user == null) {
        // Check if this is an account awaiting approval.
        final existingUser =
        await DatabaseHelper.instance.findUserByEmail(email);

        if (!mounted) return;

        if (existingUser != null &&
            existingUser['account_status'] == 'pending_admin') {
          showMessage(
            'Your administrator account is awaiting approval.',
            maroon,
          );
        } else {
          showMessage(
            'Invalid email address or password.',
            Colors.red,
          );
        }
        return;
      }

      final role =
      user['role'].toString().trim().toLowerCase();

      final status =
      user['account_status'].toString().trim();

      // Only active accounts can log in.
      if (status != 'active') {
        showMessage(
          'Your account is not active.',
          Colors.red,
        );
        return;
      }

      // Ensure selected login type matches SQLite role.
      if (selectedRole != role) {
        showMessage(
          role == 'admin'
              ? 'This is an administrator account. '
              'Select Administrator to log in.'
              : 'This is a customer account. '
              'Select Customer to log in.',
          maroon,
        );
        return;
      }

      // Additional administrator verification.
      if (role == 'admin') {
        final userId = user['id'] as int;

        final authorised =
        await DatabaseHelper.instance.isAdmin(userId);

        if (!mounted) return;

        if (!authorised) {
          showMessage(
            'Administrator access denied.',
            Colors.red,
          );
          return;
        }
      }

      // Navigate to Dashboard with authenticated user.
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
            (route) => false,
        arguments: user,
      );
    } catch (error) {
      debugPrint('Login error: $error');

      if (!mounted) return;

      showMessage(
        'Login failed. Please try again.',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoggingIn = false;
        });
      }
    }
  }

  // ======================================
  // MESSAGE
  // ======================================

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ======================================
  // LOGIN SCREEN UI
  // ======================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/insurance_background.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  // HBF LOGO
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset(
                      'assets/images/insurance_logo.jpg',
                      width: 180,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'HBF LOGIN',
                    style: TextStyle(
                      color: green,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Insurance Sales One Stop',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ACCOUNT ROLE
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gold),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedRole,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Login As',
                        prefixIcon: Icon(
                          Icons.manage_accounts,
                          color: green,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'customer',
                          child: Text('Customer'),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Administrator'),
                        ),
                      ],
                      onChanged: isLoggingIn
                          ? null
                          : (value) {
                        if (value != null) {
                          setState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // EMAIL ADDRESS
                  TextFormField(
                    controller: emailController,
                    enabled: !isLoggingIn,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Email address is required';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(
                        Icons.email,
                        color: green,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD
                  TextFormField(
                    controller: passwordController,
                    enabled: !isLoggingIn,
                    obscureText: hidePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: green,
                      ),
                      suffixIcon: IconButton(
                        onPressed: isLoggingIn
                            ? null
                            : () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoggingIn
                          ? null
                          : () {
                        Navigator.pushNamed(
                          context,
                          '/forgot-password',
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: maroon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoggingIn ? null : login,
                      icon: isLoggingIn
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.login),
                      label: Text(
                        isLoggingIn
                            ? 'LOGGING IN...'
                            : 'LOGIN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // REGISTER NAVIGATION
                  TextButton(
                    onPressed: isLoggingIn
                        ? null
                        : () {
                      Navigator.pushNamed(
                        context,
                        '/register',
                      );
                    },
                    child: const Text(
                      'Do not have an account? Register',
                      style: TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'House of the Big Family',
                    style: TextStyle(
                      color: green,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ======================================
  // DISPOSE
  // ======================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

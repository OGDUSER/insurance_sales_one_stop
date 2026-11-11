
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  static const Color green = Color(0xFF005A3C);
  static const Color maroon = Color(0xFF800020);
  static const Color gold = Color(0xFFD4A017);

  String selectedRole = 'customer';
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isRegistering = false;

  // ======================================
  // VALIDATION
  // ======================================

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }

    if (value.trim().length < 3) {
      return 'Enter a valid full name';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final pattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Phone number must be exactly 10 digits';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must have at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ======================================
  // REGISTER USER
  // ======================================

  Future<void> register() async {
    if (isRegistering) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final role = selectedRole;

    setState(() {
      isRegistering = true;
    });

    try {
      final exists =
      await DatabaseHelper.instance.emailExists(email);

      if (!mounted) return;

      if (exists) {
        showMessage(
          'Email address is already registered.',
          Colors.red,
        );
        return;
      }

      await DatabaseHelper.instance.registerWithRole(
        fullName: name,
        email: email,
        phone: phone,
        password: password,
        selectedRole: role,
      );

      if (!mounted) return;

      final isAdmin = role == 'admin';

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  isAdmin
                      ? Icons.admin_panel_settings
                      : Icons.check_circle,
                  color: isAdmin ? maroon : green,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Registration Successful'),
                ),
              ],
            ),
            content: Text(
              isAdmin
                  ? 'Your administrator registration '
                  'has been submitted.\n\n'
                  'Your account must be approved '
                  'before you can log in as an administrator.'
                  : 'Your customer account has been '
                  'created successfully.\n\n'
                  'You can now log in.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('CONTINUE'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    } catch (error) {
      debugPrint('Registration error: $error');

      if (!mounted) return;

      showMessage(
        'Registration failed. Please try again.',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isRegistering = false;
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
      ),
    );
  }

  // ======================================
  // TEXT FIELD
  // ======================================

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        enabled: !isRegistering,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          prefixIcon: Icon(icon, color: green),
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ======================================
  // PASSWORD FIELD
  // ======================================

  Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool hidden,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        enabled: !isRegistering,
        obscureText: hidden,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock, color: green),
          suffixIcon: IconButton(
            onPressed: isRegistering ? null : toggle,
            icon: Icon(
              hidden
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
    );
  }

  // ======================================
  // SCREEN DESIGN
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
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/images/insurance_logo.jpg',
                      width: 160,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'HBF REGISTRATION',
                    style: TextStyle(
                      color: green,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'House of the Big Family',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ACCOUNT TYPE
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gold),
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Register As',
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
                          onChanged: isRegistering
                              ? null
                              : (value) {
                            if (value != null) {
                              setState(() {
                                selectedRole = value;
                              });
                            }
                          },
                        ),

                        if (selectedRole == 'admin')
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'Administrator accounts require approval.',
                              style: TextStyle(
                                color: maroon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  buildField(
                    controller: nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: validateName,
                  ),

                  buildField(
                    controller: emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),

                  // PHONE: NUMBERS ONLY, 10 DIGITS
                  buildField(
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    maxLength: 10,
                    validator: validatePhone,
                  ),

                  buildPasswordField(
                    controller: passwordController,
                    label: 'Password',
                    hidden: hidePassword,
                    toggle: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    validator: validatePassword,
                  ),

                  buildPasswordField(
                    controller: confirmPasswordController,
                    label: 'Confirm Password',
                    hidden: hideConfirmPassword,
                    toggle: () {
                      setState(() {
                        hideConfirmPassword =
                        !hideConfirmPassword;
                      });
                    },
                    validator: validateConfirmPassword,
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isRegistering ? null : register,
                      icon: isRegistering
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.person_add),
                      label: Text(
                        isRegistering
                            ? 'REGISTERING...'
                            : 'REGISTER',
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: isRegistering
                        ? null
                        : () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/login',
                      );
                    },
                    child: const Text(
                      'Already registered? Login',
                      style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

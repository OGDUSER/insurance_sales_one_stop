
import 'dart:math';

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  static const Color maroon = Color(0xFF900019);
  static const Color green = Color(0xFF005A3C);
  static const Color navy = Color(0xFF233451);
  static const Color lightBlue = Color(0xFFEAF4FF);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your registered email address';
    }

    final emailPattern =
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String _generateOtp() {
    final random = Random.secure();
    final number = random.nextInt(900000) + 100000;
    return number.toString();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim().toLowerCase();

    try {
      final user =
      await DatabaseHelper.instance.findUserByEmail(email);

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No account found with this email address.',
            ),
            backgroundColor: maroon,
          ),
        );
        return;
      }

      final otp = _generateOtp();

      // Save the OTP in the existing SQLite database.
      // This assumes savePasswordResetOtp accepts:
      // (String email, String otp)
      await DatabaseHelper.instance
          .savePasswordResetOtp(email, otp);

      if (!mounted) return;

      // DEVELOPMENT MODE ONLY:
      // The OTP is displayed because no email service
      // is connected to this local SQLite prototype.
      //
      // In production, send the OTP through a secure
      // server-side email service instead.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.mark_email_read, color: green),
                SizedBox(width: 8),
                Expanded(child: Text('OTP Generated')),
              ],
            ),
            content: Text(
              'Demo verification PIN: $otp\n\n'
                  'This PIN is shown for testing only. '
                  'It has not been emailed to you.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('CONTINUE'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/verify-otp',
        arguments: {'email': email},
      );
    } catch (error) {
      debugPrint('Forgot password error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to generate a verification PIN. '
                'Please try again.',
          ),
          backgroundColor: maroon,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      height: 205,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/insurance_background.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/insurance_logo.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: green,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'Enter your registered email address '
                      'to generate a one-time PIN '
                      'and reset your password.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    const titles = [
      'Enter Details',
      'Verify PIN',
      'Reset Password',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE0E5ED),
        ),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final active = index == 0;

          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: active
                      ? maroon
                      : const Color(0xFFD6DBE5),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  titles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? maroon : navy,
                    fontSize: 12,
                    fontWeight: active
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF0DDE1),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFFF9DEE3),
                  child: Icon(
                    Icons.mail_outline,
                    color: maroon,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 1: Enter Your Details',
                        style: TextStyle(
                          color: maroon,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Enter your registered email address '
                            'to receive a one-time PIN (OTP).',
                        style: TextStyle(
                          color: navy,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: _validateEmail,
              onFieldSubmitted: (_) {
                if (!_isLoading) _sendOtp();
              },
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                hintStyle: const TextStyle(
                  color: Color(0xFF8491A7),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: navy,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(11),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D9E7),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(11),
                  borderSide: const BorderSide(
                    color: Color(0xFFD1D9E7),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(11),
                  borderSide: const BorderSide(
                    color: maroon,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(11),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 15),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC8E0FF),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF2385F4),
            child: Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Information',
                  style: TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  '• A six-digit OTP will be generated.\n'
                      '• In demo mode, the OTP is shown on screen.\n'
                      '• The OTP is intended to expire after '
                      '10 minutes; expiry must be enforced '
                      'by the database helper.\n'
                      '• Real email delivery requires '
                      'a secure backend service.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Column(
      children: [
        const Text(
          'Remember your password?',
          style: TextStyle(
            color: navy,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          width: double.infinity,
          height: 49,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2385F4),
              side: const BorderSide(
                color: Color(0xFF78B5FF),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      appBar: AppBar(
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        title: const Text(
          'HBF INSURANCE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                children: [
                  _buildProgress(),
                  const SizedBox(height: 15),
                  _buildFormCard(),
                  const SizedBox(height: 15),
                  _buildInformationPanel(),
                  const SizedBox(height: 36),
                  _buildBackToLogin(),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

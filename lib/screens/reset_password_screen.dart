
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color maroon = Color(0xFF900019);
  static const Color green = Color(0xFF005A3C);
  static const Color navy = Color(0xFF233451);
  static const Color gold = Color(0xFFE5A000);

  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  String email = '';
  String otp = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      email = (args['email'] ?? '').toString().trim();
      otp = (args['otp'] ?? '').toString().trim();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get hasMinimumLength =>
      _passwordController.text.length >= 8;

  bool get hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(_passwordController.text);

  bool get hasLowercase =>
      RegExp(r'[a-z]').hasMatch(_passwordController.text);

  bool get hasNumber =>
      RegExp(r'[0-9]').hasMatch(_passwordController.text);

  bool get hasSpecialCharacter =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=;]')
          .hasMatch(_passwordController.text);

  bool get isStrongPassword =>
      hasMinimumLength &&
          hasUppercase &&
          hasLowercase &&
          hasNumber &&
          hasSpecialCharacter;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }

    if (!isStrongPassword) {
      return 'Password does not meet all requirements';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (email.isEmpty || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password recovery session is missing. '
                'Please request a new OTP.',
          ),
          backgroundColor: maroon,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Recheck OTP validity before changing the password.
      final verified = await DatabaseHelper.instance
          .verifyPasswordResetOtp(email, otp);

      if (!mounted) return;

      if (!verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your OTP is invalid or expired. '
                  'Please start password recovery again.',
            ),
            backgroundColor: maroon,
          ),
        );
        return;
      }

      final success = await DatabaseHelper.instance.resetPassword(
        email,
        _passwordController.text,
        otp: otp,
      );

      if (!mounted) return;

      if (success) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: green),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Password Reset Successful'),
                ),
              ],
            ),
            content: const Text(
              'Your password has been updated successfully. '
                  'You can now log in using your new password.',
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
          ),
        );

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to reset password. '
                  'Please try again.',
            ),
            backgroundColor: maroon,
          ),
        );
      }
    } catch (error) {
      debugPrint('Reset password error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An error occurred while resetting your password.',
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
      height: 190,
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
                  'Reset Password',
                  style: TextStyle(
                    color: green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create a new password for your account '
                      'to regain access to your HBF Insurance app.',
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
    );
  }

  Widget _buildProgress() {
    const labels = [
      'Enter Details',
      'Verify PIN',
      'Reset Password',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 8,
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
          final completed = index < 2;
          final active = index == 2;

          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: completed || active
                      ? maroon
                      : const Color(0xFFD6DBE5),
                  child: completed
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                      : Text(
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
                  labels[index],
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

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF8491A7),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: navy,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: navy,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color(0xFFD1D9E7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: maroon,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _requirementRow(String label, bool fulfilled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            fulfilled
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: fulfilled ? green : Colors.grey,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: navy,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC8E0FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: Color(0xFF2385F4),
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Password Requirements',
                  style: TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _requirementRow(
            'At least 8 characters',
            hasMinimumLength,
          ),
          _requirementRow(
            'One uppercase letter (A–Z)',
            hasUppercase,
          ),
          _requirementRow(
            'One lowercase letter (a–z)',
            hasLowercase,
          ),
          _requirementRow(
            'One number (0–9)',
            hasNumber,
          ),
          _requirementRow(
            'One special character (e.g. ! @ # \$ % ^ & *)',
            hasSpecialCharacter,
          ),
        ],
      ),
    );
  }

  Widget _buildResetCard() {
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
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFF9DEE3),
                  child: Icon(
                    Icons.lock,
                    color: maroon,
                    size: 27,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 3: Set a New Password',
                        style: TextStyle(
                          color: maroon,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Enter and confirm your new password below.',
                        style: TextStyle(
                          color: navy,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 23),
            _passwordField(
              controller: _passwordController,
              hint: 'New password',
              obscure: _hidePassword,
              validator: _validatePassword,
              onToggle: () {
                setState(() => _hidePassword = !_hidePassword);
              },
            ),
            const SizedBox(height: 15),
            _passwordField(
              controller: _confirmController,
              hint: 'Confirm new password',
              obscure: _hideConfirmPassword,
              validator: _validateConfirmPassword,
              onToggle: () {
                setState(
                      () => _hideConfirmPassword = !_hideConfirmPassword,
                );
              },
            ),
            const SizedBox(height: 20),
            _buildRequirements(),
            const SizedBox(height: 23),
            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reset Password',
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

  Widget _buildBackToLogin() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'OR',
                style: TextStyle(color: navy),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 18),
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
    if (email.isEmpty || otp.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: maroon,
          foregroundColor: Colors.white,
          title: const Text('Reset Password'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/forgot-password',
                    (route) => false,
              );
            },
            child: const Text('Start Password Recovery'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      appBar: AppBar(
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        title: const Text(
          'HBF INSURANCE',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                  _buildResetCard(),
                  const SizedBox(height: 19),
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

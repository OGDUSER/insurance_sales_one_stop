
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const Color maroon = Color(0xFF900019);
  static const Color green = Color(0xFF005A3C);
  static const Color navy = Color(0xFF233451);
  static const Color lightBlue = Color(0xFFEAF4FF);

  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> otpFocusNodes =
  List.generate(6, (_) => FocusNode());

  Timer? countdownTimer;
  DateTime? timerDeadline;

  int remainingSeconds = 600;
  bool isLoading = false;
  bool isResending = false;
  bool initialized = false;

  String email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initialized) return;
    initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map && args['email'] is String) {
      email = (args['email'] as String).trim().toLowerCase();
    }

    if (email.isNotEmpty) {
      startCountdown();
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in otpFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void startCountdown() {
    countdownTimer?.cancel();

    timerDeadline = DateTime.now().add(
      const Duration(minutes: 10),
    );

    setState(() => remainingSeconds = 600);

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final difference =
            timerDeadline!.difference(DateTime.now()).inSeconds;

        setState(() {
          remainingSeconds = difference > 0 ? difference : 0;
        });

        if (remainingSeconds == 0) {
          timer.cancel();
        }
      },
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get enteredOtp =>
      otpControllers.map((controller) => controller.text).join();

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? maroon : green,
      ),
    );
  }

  void clearOtp() {
    for (final controller in otpControllers) {
      controller.clear();
    }

    otpFocusNodes.first.requestFocus();
  }

  Future<void> verifyOtp() async {
    if (isLoading || isResending) return;

    if (enteredOtp.length != 6) {
      showMessage(
        'Please enter the complete 6-digit OTP.',
        error: true,
      );
      return;
    }

    if (remainingSeconds <= 0) {
      showMessage(
        'The OTP has expired. Please request a new PIN.',
        error: true,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final verified = await DatabaseHelper.instance
          .verifyPasswordResetOtp(email, enteredOtp);

      if (!mounted) return;

      if (!verified) {
        showMessage(
          'Invalid or expired OTP. Please try again.',
          error: true,
        );
        clearOtp();
        return;
      }

      countdownTimer?.cancel();

      Navigator.pushReplacementNamed(
        context,
        '/reset-password',
        arguments: {
          'email': email,
          'otp': enteredOtp,
        },
      );
    } catch (error) {
      debugPrint('OTP verification error: $error');

      showMessage(
        'Unable to verify OTP. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String generateOtp() {
    final random = Random.secure();
    final number = random.nextInt(900000) + 100000;
    return number.toString();
  }

  Future<void> resendOtp() async {
    if (isResending || isLoading) return;

    if (remainingSeconds > 0) {
      showMessage(
        'Please wait until the timer expires.',
        error: true,
      );
      return;
    }

    setState(() => isResending = true);

    try {
      final otp = generateOtp();

      await DatabaseHelper.instance
          .savePasswordResetOtp(email, otp);

      if (!mounted) return;

      clearOtp();
      startCountdown();

      // DEMO MODE ONLY:
      // No email service is connected.
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('New OTP Generated'),
          content: Text(
            'Your new demonstration OTP is: $otp\n\n'
                'This PIN is displayed for testing only. '
                'It has not been emailed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      );
    } catch (error) {
      debugPrint('Resend OTP error: $error');

      showMessage(
        'Unable to resend OTP. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => isResending = false);
      }
    }
  }

  Widget buildHeader() {
    return Container(
      height: 195,
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
                  'Verify OTP',
                  style: TextStyle(
                    color: green,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'Enter the 6-digit PIN generated '
                      'for your registered email address.',
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

  Widget buildProgress() {
    const labels = [
      'Enter Details',
      'Verify PIN',
      'Reset Password',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 17,
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
          final completed = index == 0;
          final active = index == 1;

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

  Widget otpBox(int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TextField(
          controller: otpControllers[index],
          focusNode: otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: Color(0xFFCAD5E5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: Color(0xFFCAD5E5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: maroon,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              otpFocusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              otpFocusNodes[index - 1].requestFocus();
            }

            if (enteredOtp.length == 6) {
              FocusScope.of(context).unfocus();
            }
          },
        ),
      ),
    );
  }

  Widget buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF0DDE1),
        ),
      ),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Step 2: Verify Your OTP',
                      style: TextStyle(
                        color: maroon,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Enter the six-digit verification PIN below.',
                      style: TextStyle(
                        color: navy,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          Row(
            children: List.generate(6, otpBox),
          ),
          const SizedBox(height: 19),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Time remaining: ',
                style: TextStyle(
                  color: navy,
                  fontSize: 14,
                ),
              ),
              Text(
                formattedTime,
                style: const TextStyle(
                  color: maroon,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Didn't receive the PIN?",
            style: TextStyle(
              color: navy,
              fontSize: 12,
            ),
          ),
          TextButton.icon(
            onPressed: remainingSeconds == 0 &&
                !isResending &&
                !isLoading
                ? resendOtp
                : null,
            icon: const Icon(Icons.refresh),
            label: const Text('Resend OTP'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton.icon(
              onPressed: isLoading || isResending
                  ? null
                  : verifyOtp,
              icon: isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.arrow_forward),
              label: Text(
                isLoading ? 'Verifying...' : 'Verify OTP',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInformationPanel() {
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• The OTP is valid for 10 minutes.\n'
                      '• In demo mode, the OTP is displayed '
                      'on the previous screen.\n'
                      '• You can request a new OTP when '
                      'the timer expires.\n'
                      '• Do not share your OTP with anyone.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackButton() {
    return Column(
      children: [
        const Text(
          'Entered the wrong email?',
          style: TextStyle(
            color: navy,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 49,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/forgot-password',
              );
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
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
    if (email.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verify OTP'),
          backgroundColor: maroon,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/forgot-password',
              );
            },
            child: const Text(
              'Start Password Recovery',
            ),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                children: [
                  buildProgress(),
                  const SizedBox(height: 15),
                  buildVerificationCard(),
                  const SizedBox(height: 15),
                  buildInformationPanel(),
                  const SizedBox(height: 35),
                  buildBackButton(),
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

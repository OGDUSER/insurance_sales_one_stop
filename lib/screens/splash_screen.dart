import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
          () {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/register',
          );
        }
      },
    );
  }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Image.asset(
                'assets/images/insurance_logo.jpg',
                width: 250,
              ),

              const SizedBox(height: 50),

              const CircularProgressIndicator(
                color: Color(0xFF005A3C),
              ),

              const SizedBox(height: 15),

              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF005A3C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
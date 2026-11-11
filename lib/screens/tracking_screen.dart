import 'package:flutter/material.dart';

class TrackingScreen
    extends StatelessWidget {

  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Application Status'),
        backgroundColor:
        const Color(0xFF005A3C),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(25),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              'Application Tracking',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Reference: INS0012026',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            status(
              Icons.check_circle,
              'Application Submitted',
              'Completed',
              true,
            ),

            status(
              Icons.check_circle,
              'Documents Received',
              'Completed',
              true,
            ),

            status(
              Icons.hourglass_top,
              'Application Review',
              'Under Review',
              true,
            ),

            status(
              Icons.radio_button_unchecked,
              'Final Decision',
              'Pending',
              false,
            ),

            status(
              Icons.radio_button_unchecked,
              'Policy Issued',
              'Pending',
              false,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  Navigator.pushNamed(
                    context,
                    '/notifications',
                  );
                },

                child: const Text(
                  'VIEW NOTIFICATIONS',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget status(
      IconData icon,
      String title,
      String subtitle,
      bool active,
      ) {

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(
          vertical: 5),

      leading: Icon(
        icon,
        size: 32,

        color: active
            ? const Color(0xFF005A3C)
            : Colors.grey,
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(subtitle),
    );
  }
}
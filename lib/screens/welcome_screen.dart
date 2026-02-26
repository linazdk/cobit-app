import 'package:flutter/material.dart';
import 'organization_list_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/cobitlogo.png',
              height: 90, // ajuste si besoin
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),

            const Text(
              "COBIT Toolkit",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 40),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrganizationListScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("Start", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const Text(
              "\nCOBIT® is a trademark belonging to ISACA. \nThis application is neither affiliated with nor endorsed by ISACA.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

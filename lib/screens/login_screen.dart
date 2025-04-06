import 'package:env_monitoring_dashboard/screens/environmental_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signInAnonymously();
                final userId = FirebaseAuth.instance.currentUser?.uid;
                print("✅ Logged in as $userId");
                if (userId != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EnvironmentalScreenWithLoginButton(
                            userId: userId,
                          ),
                    ),
                  );
                }
              },
              child: const Text("Login as Guest"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = await AuthService().signInWithGoogle();
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (user != null && userId != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EnvironmentalScreenWithLoginButton(
                            userId: userId,
                          ),
                    ),
                  );
                }
              },
              child: const Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }
}

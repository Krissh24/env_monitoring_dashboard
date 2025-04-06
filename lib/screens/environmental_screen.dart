import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/environmental_data.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

// Import the global variable
// Note: You'll need to expose this variable in your main.dart file
import '../main.dart' show firebaseInitialized;

class EnvironmentalScreenWithLoginButton extends StatefulWidget {
  final String userId;

  const EnvironmentalScreenWithLoginButton({super.key, required this.userId});

  @override
  _EnvironmentalScreenWithLoginButtonState createState() =>
      _EnvironmentalScreenWithLoginButtonState();
}

class _EnvironmentalScreenWithLoginButtonState
    extends State<EnvironmentalScreenWithLoginButton> {
  bool hasJoined = false;

  @override
  void initState() {
    super.initState();
    // No need to initialize Firebase again
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Builder(
        builder: (context) {
          // Check if Firebase is already initialized
          if (!firebaseInitialized && kIsWeb) {
            // For web, don't try to initialize again, just show error
            return const Center(
              child: Text(
                "Firebase initialization error. Please refresh the page.",
              ),
            );
          }

          // The rest of your UI
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFd4fc79), Color(0xFF96e6a1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Consumer<EnvironmentalData>(
              builder: (context, environmentalData, child) {
                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "🌍 Welcome Eco-Warrior!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Make small changes, create big impacts.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _buildCard(
                              icon: Icons.cloud,
                              label: "Weather",
                              onTap:
                                  () =>
                                      Navigator.pushNamed(context, '/weather'),
                            ),
                            _buildCard(
                              icon: Icons.insert_chart,
                              label: "Details",
                              onTap:
                                  () =>
                                      Navigator.pushNamed(context, '/details'),
                            ),
                            _buildCard(
                              icon: Icons.air,
                              label: "AQI",
                              onTap: () => Navigator.pushNamed(context, '/AQI'),
                            ),
                            _buildCard(
                              icon: Icons.menu_book,
                              label: "Knowledge",
                              onTap:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/knowledge',
                                  ),
                            ),
                            _buildCard(
                              icon: Icons.card_giftcard,
                              label: "Your Rewards",
                              onTap:
                                  () =>
                                      Navigator.pushNamed(context, '/rewards'),
                            ),
                            _buildCard(
                              icon: hasJoined ? Icons.nature : Icons.forest,
                              label:
                                  hasJoined
                                      ? "Green Journey"
                                      : "Join Initiative",
                              onTap: () {
                                Navigator.pushNamed(context, '/green').then((
                                  value,
                                ) {
                                  if (value == true) {
                                    setState(() => hasJoined = true);
                                  }
                                });
                              },
                            ),
                            _buildCard(
                              icon: user == null ? Icons.login : Icons.person,
                              label: user == null ? "Login" : "Profile",
                              onTap: () {
                                if (user == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProfilePage(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shadowColor: Colors.green.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.9),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green[700]),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

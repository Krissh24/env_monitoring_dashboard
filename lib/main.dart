import 'package:env_monitoring_dashboard/models/environmental_data.dart';
import 'package:env_monitoring_dashboard/screens/AQI_screen.dart';
import 'package:env_monitoring_dashboard/screens/details_screen.dart';
import 'package:env_monitoring_dashboard/screens/green_initiative_screen.dart';
import 'package:env_monitoring_dashboard/screens/reward_screen.dart';
import 'package:env_monitoring_dashboard/screens/weather_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/environmental_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/progress_provider.dart';
import 'screens/login_screen.dart';
import 'screens/knowledge_camp_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  await dotenv.load(fileName: "api.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => EnvironmentalData()),
      ],
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          final user = snapshot.data;

          if (user != null) {
            // 👇 Trigger loadUserProgress here
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<ProgressProvider>(
                context,
                listen: false,
              ).loadUserProgress(user.uid);
            });
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Environmental App',
            home:
                user != null
                    ? EnvironmentalScreenWithLoginButton(userId: user.uid)
                    : const LoginScreen(),
            routes: {
              '/details': (context) => const DetailsScreen(),
              '/AQI': (context) => const AQIScreen(),
              '/weather': (context) => const WeatherScreen(),
              '/green': (context) => const GreenInitiativeScreen(),
              '/login': (context) => const LoginScreen(),
              '/knowledge': (context) => KnowledgeCampScreen(),
              '/rewards': (context) => RewardsScreen(),
            },
          );
        },
      ),
    );
  }
}

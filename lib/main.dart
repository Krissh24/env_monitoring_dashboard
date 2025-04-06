import 'package:env_monitoring_dashboard/models/environmental_data.dart';
import 'package:env_monitoring_dashboard/screens/AQI_screen.dart';
import 'package:env_monitoring_dashboard/screens/details_screen.dart';
import 'package:env_monitoring_dashboard/screens/green_initiative_screen.dart';
import 'package:env_monitoring_dashboard/screens/reward_screen.dart';
import 'package:env_monitoring_dashboard/screens/weather_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/environmental_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/progress_provider.dart';
import 'screens/login_screen.dart';
import 'screens/knowledge_camp_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Create a global variable to track if Firebase is initialized
bool firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enhanced error logging for web
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('FLUTTER ERROR: ${details.exception}');
    print('STACK TRACE: ${details.stack}');
  };

  // Load environment variables with a try-catch
  try {
    if (!kIsWeb) {
      await dotenv.load(fileName: "api.env");
    }
  } catch (e) {
    print("Failed to load environment variables: $e");
  }

  // Initialize Firebase with proper web configuration
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCEJHNLxVEDu4vGdm2RM_yn-Kd-laE2Iwg",
          authDomain: "environment-monitoring-s-c26ff.firebaseapp.com",
          projectId: "environment-monitoring-s-c26ff",
          storageBucket: "environment-monitoring-s-c26ff.firebasestorage.app",
          messagingSenderId: "742928632721",
          appId: "1:742928632721:web:db1facec490e8b5a77e830",
          measurementId: "G-WHG8ELD6S8",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    firebaseInitialized = true;
    print("Firebase successfully initialized in main.dart");
  } catch (e) {
    print("Error initializing Firebase in main.dart: $e");
  }

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

          if (snapshot.hasError) {
            print("Auth stream error: ${snapshot.error}");
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text("Authentication Error: ${snapshot.error}"),
                ),
              ),
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

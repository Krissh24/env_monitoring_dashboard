import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, double> _progress = {};
  final Map<String, double> _userProgress = {};
  bool _isLoading = false;

  Map<String, double> get progress => _progress;
  Map<String, double> get userProgress => _userProgress;
  bool get isLoading => _isLoading;

  Future<void> loadUserProgress(String userId) async {
    if (userId.isEmpty) {
      print("⚠️ Warning: Attempted to load progress with empty userId");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print("📡 Fetching progress for user: $userId");

      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();

      print("📄 Snapshot exists: ${snapshot.exists}");

      if (snapshot.exists) {
        // Safely extract data with more verbose error handling
        try {
          var progressData = snapshot.get('progress');
          print("🔍 Raw progress data: $progressData");

          if (progressData != null) {
            // Convert to the right type with proper type checking
            if (progressData is Map) {
              _progress = {};
              // Safely convert each value to double
              progressData.forEach((key, value) {
                if (value is num) {
                  _progress[key.toString()] = value.toDouble();
                } else {
                  print("⚠️ Non-numeric value found for key '$key': $value");
                  _progress[key.toString()] = 0.0; // Default value
                }
              });
            } else {
              print("⚠️ Progress data is not a Map: $progressData");
              _progress = {};
            }
          } else {
            print("ℹ️ No progress data found, initializing empty map");
            _progress = {};
          }
        } catch (e) {
          print("❌ Error parsing progress data: $e");
          _progress = {};
        }
      } else {
        print("ℹ️ User document doesn't exist, creating default progress");
        _progress = {};
        // Optionally create the user document with default progress
        try {
          await _firestore.collection('users').doc(userId).set({
            'progress': {},
          }, SetOptions(merge: true));
          print("✅ Created new user document with empty progress");
        } catch (e) {
          print("❌ Failed to create user document: $e");
        }
      }
    } catch (e) {
      print("❌ Error loading progress: $e");
      _progress = {}; // Ensure we always have a valid map
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProgress(
    String userId,
    String challenge,
    double newProgress,
  ) async {
    if (userId.isEmpty) {
      print("❌ Cannot update progress: userId is empty");
      return;
    }

    print("✅ Updating progress for $userId: $challenge = $newProgress");

    try {
      // Make a defensive copy of the current progress
      Map<String, double> progressCopy = Map<String, double>.from(_progress);
      progressCopy[challenge] = newProgress;

      await _firestore.collection('users').doc(userId).set({
        'progress': progressCopy,
      }, SetOptions(merge: true));

      // Only update the local state if Firestore succeeded
      _progress = progressCopy;
      print("✅ Progress updated successfully");
    } catch (e) {
      print("❌ Error writing to Firestore: $e");
    }
    notifyListeners();
  }
}

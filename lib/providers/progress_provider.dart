import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, double> _progress = {};
  final Map<String, double> _userProgress = {};

  Map<String, double> get progress => _progress;
  Map<String, double> get userProgress => _userProgress;

  Future<void> loadUserProgress(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        _progress = Map<String, double>.from(snapshot.get('progress') ?? {});
      }
    } catch (e) {
      print("Error loading progress: $e");
    }
    notifyListeners();
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

    _progress[challenge] = newProgress;
    try {
      if (userId.isEmpty) {
        print("❌ Error: userId is empty");
        return;
      }
      await _firestore.collection('users').doc(userId).set({
        'progress': _progress,
      }, SetOptions(merge: true));
      print("✅ Progress updated successfully");
    } catch (e) {
      print("❌ Error writing to Firestore: $e");
    }
    notifyListeners();
  }
}

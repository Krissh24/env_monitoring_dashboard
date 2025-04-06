import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save or update user progress
  Future<void> saveUserProgress(String userId, Map<String, dynamic> progress) async {
    await _db.collection('users').doc(userId).set(progress, SetOptions(merge: true));
  }

  // Retrieve user progress
  Future<Map<String, dynamic>?> getUserProgress(String userId) async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }
}

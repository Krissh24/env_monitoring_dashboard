import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/progress_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "";
    final progress = Provider.of<ProgressProvider>(context).progress;

    int completedChallenges = progress.values.where((v) => v == 1.0).length;

    final Map<String, String> challengeTitles = {
      "reduce_plastic": "Reduce plastic use for a month",
      "plant_a_tree": "Plant a tree this week",
      "use_public_transport": "Use Public Transport for a month",
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              if (user!.isAnonymous) {
                await FirebaseAuth.instance.signOut();
              } else {
                await AuthService().signOutGoogle();
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (user?.photoURL != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            const SizedBox(height: 10),
            Text(
              user?.displayName ?? "Guest",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Completed Challenges:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;

                  if (data == null || !data.containsKey('progress')) {
                    return const Text("No challenges completed yet.");
                  }

                  final progressMap = Map<String, dynamic>.from(
                    data['progress'],
                  );
                  final completed =
                      progressMap.entries.where((e) => e.value == 1.0).toList();

                  if (completed.isEmpty) {
                    return const Text("No challenges completed yet.");
                  }

                  return ListView.builder(
                    itemCount: completed.length,
                    itemBuilder: (context, index) {
                      final entry = completed[index];
                      final title = challengeTitles[entry.key] ?? entry.key;
                      return ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(title),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

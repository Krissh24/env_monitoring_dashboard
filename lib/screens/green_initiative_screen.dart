import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import '../providers/progress_provider.dart';
import '../services/gemini_service.dart';

class GreenInitiativeScreen extends StatefulWidget {
  const GreenInitiativeScreen({super.key});

  @override
  _GreenInitiativeScreenState createState() => _GreenInitiativeScreenState();
}

class _GreenInitiativeScreenState extends State<GreenInitiativeScreen> {
  Future<String> getEcoImpactMessage(String challengeTitle) async {
    final prompt =
        "A user completed the challenge: '$challengeTitle'. "
        "Explain in a friendly tone what environmental impact it made.";

    final response = await GeminiService().getEcoImpact(
      prompt,
    ); // Use your service or Gemini API call
    return response;
  }

  late ProgressProvider progressProvider;
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  List<Map<String, dynamic>> challenges = [
    {
      "id": "plant_a_tree",
      "title": "Plant a tree this week",
      "progress": null,
      "singleTask": true,
    },
    {
      "id": "reduce_plastic",
      "title": "Reduce plastic use for a month",
      "progress": 0.0,
      "singleTask": false,
    },
    {
      "id": "use_public_transport",
      "title": "Use Public Transport for a month",
      "progress": 0.0,
      "singleTask": false,
    },
  ];

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        progressProvider = Provider.of<ProgressProvider>(
          context,
          listen: false,
        );

        progressProvider.loadUserProgress(user.uid).then((_) {
          setState(() {
            for (var challenge in challenges) {
              final challengeId = challenge["id"];
              if (progressProvider.progress.containsKey(challengeId)) {
                challenge["progress"] =
                    progressProvider.progress[challengeId] ?? 0.0;
              }
            }
          });
        });
      }
    });
  }

  void joinChallenge(int index) {
    setState(() {
      challenges[index]["progress"] =
          challenges[index]["singleTask"] ? 1.0 : 0.0;
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      progressProvider.updateProgress(
        userId,
        challenges[index]["id"],
        challenges[index]["progress"],
      );
      if (challenges[index]["singleTask"]) {
        _confettiController.play();
      }
    });
  }

  void updateProgress(int index) async {
    setState(() {
      if (challenges[index]["progress"] != null &&
          challenges[index]["progress"] is double) {
        challenges[index]["progress"] += 0.2;
        if (challenges[index]["progress"] > 1.0) {
          challenges[index]["progress"] = 1.0;
        }
        final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
        progressProvider.updateProgress(
          userId,
          challenges[index]["id"],
          challenges[index]["progress"],
        );
        if (challenges[index]["progress"] == 1.0) {
          _confettiController.play();
        }
      }
    });

    // 🎉 Trigger Gemini message if completed
    if (challenges[index]["progress"] == 1.0) {
      final message = await getEcoImpactMessage(challenges[index]["title"]);

      // 🪄 Show it as a dialog or snack
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("🌿 Eco Impact"),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Nice!"),
                  ),
                ],
              ),
        );
      }

      _confettiController.play(); // Optional celebration
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🌿 Green Initiative",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose an eco-friendly challenge to get started:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      var challenge = challenges[index];
                      bool completed = challenge["progress"] == 1.0;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                completed
                                    ? [
                                      Colors.green.shade100,
                                      Colors.green.shade50,
                                    ]
                                    : [Colors.white, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(2, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.eco_outlined,
                                    color:
                                        completed ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      challenge["title"],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            completed
                                                ? Colors.green.shade800
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (completed)
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Colors.green,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (!challenge["singleTask"] &&
                                  challenge["progress"] != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Progress: ${(challenge["progress"] * 100).toInt()}%",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: challenge["progress"],
                                        backgroundColor: Colors.grey.shade300,
                                        color: Colors.green,
                                        minHeight: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              Center(
                                child:
                                    challenge["progress"] == null
                                        ? ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade600,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () => joinChallenge(index),
                                          icon: const Icon(Icons.play_arrow),
                                          label: const Text(
                                            "Join",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        )
                                        : completed
                                        ? const Text(
                                          "🎉 Completed!",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        )
                                        : ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade600,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed:
                                              () => updateProgress(index),
                                          icon: const Icon(Icons.refresh),
                                          label: const Text(
                                            "Update Progress",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

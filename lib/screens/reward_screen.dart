import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> rewards = [
    {
      "title": "Plant 5 Trees",
      "points": 50,
      "icon": Icons.eco,
      "unlocked": true,
    },
    {
      "title": "Walk 10,000 steps",
      "points": 30,
      "icon": Icons.directions_walk,
      "unlocked": true,
    },
    {
      "title": "Avoid Plastic for a Day",
      "points": 20,
      "icon": Icons.no_drinks,
      "unlocked": false,
    },
    {
      "title": "Recycle 3 Items",
      "points": 40,
      "icon": Icons.recycling,
      "unlocked": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎁 Your Rewards'),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFd4fc79), Color(0xFF96e6a1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return _buildRewardCard(reward);
          },
        ),
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final unlocked = reward['unlocked'] as bool;

    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (unlocked)
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            reward['icon'],
            size: 40,
            color: unlocked ? Colors.green[700] : Colors.grey,
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: unlocked ? Colors.black87 : Colors.black54,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 18,
                      color: unlocked ? Colors.orange : Colors.grey,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "${reward['points']} points",
                      style: TextStyle(
                        color: unlocked ? Colors.orange[800] : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            unlocked ? Icons.check_circle : Icons.lock,
            color: unlocked ? Colors.green : Colors.grey,
            size: 28,
          ),
        ],
      ),
    );
  }
}

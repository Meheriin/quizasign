import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import '../services/database_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    const primaryColor = Color(0xFF4776E6);
    const accentColor = Color(0xFFFF512F);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: FadeInDown(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -50,
            child: FadeInLeft(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
          ),
          
          Column(
            children: [
              const SizedBox(height: 60),
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: Colors.white10),
                      ),
                      const Text(
                        'Hall of Fame',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              StreamBuilder<QuerySnapshot>(
                stream: dbService.getLeaderboard(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Expanded(child: Center(child: Text('No legends yet.', style: TextStyle(color: Colors.white))));
                  }

                  final docs = snapshot.data!.docs;

                  return Expanded(
                    child: Column(
                      children: [
                        // Podium Section
                        if (docs.length >= 3)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildPodiumPosition(docs[1], 2, const Color(0xFFC0C0C0), 0.85, 200),
                                _buildPodiumPosition(docs[0], 1, const Color(0xFFFFD700), 1.0, 0),
                                _buildPodiumPosition(docs[2], 3, const Color(0xFFCD7F32), 0.75, 400),
                              ],
                            ),
                          ),
                        const SizedBox(height: 40),
                        
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50),
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
                              ],
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                              physics: const BouncingScrollPhysics(),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;
                                return FadeInUp(
                                  delay: Duration(milliseconds: 400 + (index * 50)),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFF),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: primaryColor.withOpacity(0.05)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 35,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: index < 3 ? primaryColor : Colors.grey[400],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Hero(
                                          tag: 'leaderboard-${docs[index].id}',
                                          child: CircleAvatar(
                                            radius: 24,
                                            backgroundColor: primaryColor.withOpacity(0.1),
                                            backgroundImage: data['userPhoto'] != null ? NetworkImage(data['userPhoto']) : null,
                                            child: data['userPhoto'] == null ? const Icon(Icons.person, color: primaryColor) : null,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['userName'] ?? 'Explorer',
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E1E1E)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${data['quizzesPlayed'] ?? 0} Voyages',
                                                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            '${data['totalScore']}',
                                            style: const TextStyle(fontWeight: FontWeight.w900, color: primaryColor, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(QueryDocumentSnapshot doc, int rank, Color crownColor, double scale, int delay) {
    final data = doc.data() as Map<String, dynamic>;
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Transform.scale(
        scale: scale,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: [
                        if (rank == 1) BoxShadow(color: crownColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: rank == 1 ? 45 : 35,
                      backgroundColor: Colors.white,
                      backgroundImage: data['userPhoto'] != null ? NetworkImage(data['userPhoto']) : null,
                      child: data['userPhoto'] == null ? Icon(Icons.person, size: rank == 1 ? 40 : 30, color: const Color(0xFF7455F7)) : null,
                    ),
                  ),
                ),
                if (rank == 1) 
                  const Positioned(top: -10, child: Text('👑', style: TextStyle(fontSize: 24))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: crownColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data['userName']?.split(' ')[0] ?? 'Player',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
            ),
            Text(
              '${data['totalScore']} XP',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

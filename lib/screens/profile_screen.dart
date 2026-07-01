import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quizasign/services/auth_service.dart';
import 'package:quizasign/services/database_service.dart';
import 'package:quizasign/screens/leaderboard_screen.dart';
import 'package:quizasign/models/question_model.dart';
import 'package:quizasign/screens/review_answers_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();
    final dbService = DatabaseService();
    const primaryColor = Color(0xFF4776E6);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, user, authService),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: _buildStatsGrid(user),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSectionHeader(context, 'Performance History'),
                  ),
                  const SizedBox(height: 20),
                  _buildHistoryList(dbService),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, User? user, AuthService authService) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: const Color(0xFF7455F7),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () async {
            await authService.signOut();
            if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative Blobs
            Positioned(
              top: -50,
              left: -50,
              child: Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle)),
            ),
            Positioned(
              bottom: 40,
              right: -30,
              child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle)),
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                ZoomIn(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: Hero(
                      tag: 'profile-pic',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null ? const Icon(Icons.person, size: 60, color: Color(0xFF7455F7)) : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  child: Text(
                    user?.displayName ?? 'Scholar',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      user?.email ?? '',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(User? user) {
    if (user == null) return const SizedBox();
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('leaderboard').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        return Row(
          children: [
            Expanded(child: _buildStatCard('TOTAL XP', '${data?['totalScore'] ?? 0}', Icons.auto_fix_high_rounded, const Color(0xFF7455F7))),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('QUIZZES', '${data?['quizzesPlayed'] ?? 0}', Icons.psychology_rounded, const Color(0xFFF77866))),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E))),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey[400], letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E))),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
          child: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildHistoryList(DatabaseService db) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.getQuizHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.history_rounded, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text('No adventures yet!', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length.clamp(0, 6),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final evaluation = data['evaluation'] as List<dynamic>?;

            return FadeInRight(
              delay: Duration(milliseconds: 100 * index),
              child: GestureDetector(
                onTap: () {
                  if (evaluation != null && evaluation.isNotEmpty) {
                    final List<Question> qs = evaluation.map((e) => Question.fromJson(e['question'])).toList();
                    final List<int?> ans = evaluation.map((e) => e['userAnswer'] as int?).toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewAnswersScreen(questions: qs, userAnswers: ans),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detailed evaluation not available for this legacy result.')),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: const Color(0xFF4776E6).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                        child: const Center(child: Icon(Icons.workspace_premium_rounded, color: Color(0xFF4776E6))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['category'] ?? 'Quiz', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text(
                              data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16) : '',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                            child: Text('+${data['score']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 16)),
                          ),
                          const Text('View Review', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

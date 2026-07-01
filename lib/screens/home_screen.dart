import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:quizasign/providers/quiz_provider.dart';
import 'package:quizasign/screens/category_screen.dart';
import 'package:quizasign/screens/profile_screen.dart';
import 'package:quizasign/screens/leaderboard_screen.dart';
import 'package:quizasign/screens/quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<QuizProvider>().fetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const primaryColor = Color(0xFF4776E6);
    const secondaryColor = Color(0xFF8E54E9);
    const accentColor = Color(0xFFFF512F);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -150,
            right: -100,
            child: FadeInDown(
              duration: const Duration(seconds: 2),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [primaryColor.withOpacity(0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(context, user, primaryColor),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: _buildWelcomeText(user),
                        ),
                        const SizedBox(height: 30),
                        FadeInRight(
                          delay: const Duration(milliseconds: 200),
                          child: _buildFeaturedCard(context, primaryColor, secondaryColor, accentColor),
                        ),
                        const SizedBox(height: 40),
                        _buildSectionHeader('Explore course', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())), primaryColor),
                        const SizedBox(height: 20),
                        _buildCategoryScroll(context, primaryColor),
                        const SizedBox(height: 40),
                        _buildSectionHeader('Top Weavers', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())), primaryColor),
                        const SizedBox(height: 20),
                        _buildLeaderboardPreview(primaryColor, secondaryColor),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user, Color primaryColor) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false, // Left align title
      title: BounceInDown(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
          ).createShader(bounds),
          child: const Text(
            'MindLoom',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: ZoomIn(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: primaryColor,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Greetings, ${user?.displayName?.split(' ')[0] ?? 'Seeker'}!',
          style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Color primary, Color secondary, Color accent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // New deep purple gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.2,
              child: Icon(Icons.bolt_rounded, size: 220, color: Colors.white), // Lightning bolt for fast challenge
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Play and Win',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get Knowledge',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(12)),
                  child: const Text('FAST: 20s CHALLENGE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4A00E0),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Start Fast Quiz', style: TextStyle(fontWeight: FontWeight.w900)),
                      SizedBox(width: 8),
                      Icon(Icons.bolt_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E))),
        TextButton(
          onPressed: onTap,
          child: Text('View All', style: TextStyle(color: primary, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('math')) return Icons.calculate_rounded;
    if (name.contains('science')) return Icons.science_rounded;
    if (name.contains('physics')) return Icons.bolt_rounded;
    if (name.contains('biology')) return Icons.biotech_rounded;
    if (name.contains('general knowledge') || name.contains('gk')) return Icons.public_rounded;
    if (name.contains('history')) return Icons.history_edu_rounded;
    if (name.contains('tech')) return Icons.computer_rounded;
    if (name.contains('sport')) return Icons.sports_basketball_rounded;
    if (name.contains('geography')) return Icons.map_rounded;
    if (name.contains('art')) return Icons.palette_rounded;
    return Icons.auto_awesome_rounded;
  }

  Widget _buildCategoryScroll(BuildContext context, Color primary) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        final displayCategories = provider.categories.take(6).toList();

        return SizedBox(
          height: 135,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              final cat = displayCategories[index];
              return FadeInRight(
                delay: Duration(milliseconds: 100 * index),
                child: GestureDetector(
                  onTap: () {
                    provider.loadQuestions(id: cat.id, name: cat.name);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(categoryName: cat.name)));
                  },
                  child: Container(
                    width: 115,
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: const Color(0xFF4776E6).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Icon(
                            _getCategoryIcon(cat.name),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            cat.name,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardPreview(Color primary, Color secondary) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('leaderboard').orderBy('totalScore', descending: true).limit(3).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          
          return Column(
            children: List.generate(docs.length, (index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return FadeInLeft(
                delay: Duration(milliseconds: 400 + (index * 100)),
                child: Padding(
                  padding: EdgeInsets.only(bottom: index == docs.length - 1 ? 0 : 20),
                  child: Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: index == 0 ? const Color(0xFFFFD700).withOpacity(0.1) : const Color(0xFFF9FAFF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: index == 0 ? const Color(0xFFFFD700) : Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: primary.withOpacity(0.1),
                        backgroundImage: data['userPhoto'] != null ? NetworkImage(data['userPhoto']) : null,
                        child: data['userPhoto'] == null ? const Icon(Icons.person, size: 20) : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          data['userName'] ?? 'Explorer',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E1E1E)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${data['totalScore']} XP',
                          style: TextStyle(fontWeight: FontWeight.w900, color: primary, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

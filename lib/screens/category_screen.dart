import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quizasign/providers/quiz_provider.dart';
import 'package:quizasign/screens/quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<QuizProvider>().fetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4776E6);
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFF),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: Consumer<QuizProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: primaryColor));
                  
                  final filtered = provider.categories.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();
                  
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWeb ? 4 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final cat = filtered[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: _buildCategoryCard(context, cat, provider, primaryColor),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white12, padding: const EdgeInsets.all(12)),
              ),
              const Text('MindLoom Explore', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Choose Your Subject', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
          const SizedBox(height: 20),
          FadeInDown(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search knowledge path...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ),
        ],
      ),
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
    return Icons.auto_awesome_rounded; // Default icon
  }

  Widget _buildCategoryCard(BuildContext context, dynamic cat, QuizProvider provider, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            provider.loadQuestions(id: cat.id, name: cat.name);
            Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(categoryName: cat.name)));
          },
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(cat.name),
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  cat.name,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1E1E)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Text('Start Journey', style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

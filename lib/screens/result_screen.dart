import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:quizasign/providers/quiz_provider.dart';
import 'package:quizasign/screens/review_answers_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final totalMarks = provider.questions.fold<int>(0, (sum, q) => sum + q.mark);
    final percentage = (provider.score / totalMarks) * 100;
    const primaryColor = Color(0xFF4776E6);
    const accentColor = Color(0xFFFF512F);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                FadeInDown(
                  child: const Text(
                    'Quest Complete!',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(35),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          FadeInDown(
                            delay: const Duration(milliseconds: 300),
                            child: _buildCircularResult(provider, totalMarks, percentage, accentColor),
                          ),
                          const SizedBox(height: 50),
                          FadeInUp(
                            child: Text(
                              percentage >= 80 ? 'Mind Master! 🏆' : percentage >= 50 ? 'Loom Expert! 🧶' : 'Keep Growing! 🌱',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You\'ve woven ${provider.score} XP into your mind loom',
                            style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 50),
                          _buildStatRow('Knowledge Earned', '${provider.score} XP', Colors.green),
                          const SizedBox(height: 20),
                          _buildStatRow('Paths Explored', '${provider.questions.length} Qs', Colors.blue),
                          const SizedBox(height: 60),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewAnswersScreen())),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    side: const BorderSide(color: primaryColor, width: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                  child: const Text('Review Path', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900)),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    provider.resetQuiz();
                                    Navigator.popUntil(context, (route) => route.isFirst);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                  child: const Text('New Quest'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularResult(QuizProvider provider, int total, double percentage, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: provider.score / total,
            strokeWidth: 15,
            backgroundColor: const Color(0xFFF9FAFF),
            strokeCap: StrokeCap.round,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${percentage.toInt()}%',
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E), letterSpacing: -2),
            ),
            const Text(
              'INSIGHT',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E1E1E))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

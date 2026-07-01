import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/quiz_provider.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String categoryName;
  const QuizScreen({super.key, required this.categoryName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuizProvider>();
      provider.startTimer(() {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ResultScreen()),
          );
        }
      });
    });
  }

  void _startNewQuestionTimer() {
    // Global timer is handled in initState
  }

  void _handleAnswer(int index) {
    if (_selectedOption != null) return; // Prevent double tapping
    
    setState(() => _selectedOption = index);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final provider = context.read<QuizProvider>();
      provider.answerQuestion(index);
      setState(() => _selectedOption = null);
      
      if (provider.currentQuestionIndex >= provider.questions.length) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResultScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4776E6);
    
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        actions: [
          _buildTimerWidget(),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));
          if (provider.questions.isEmpty) return const Center(child: Text('No questions available.', style: TextStyle(color: Colors.white)));

          if (provider.currentQuestionIndex >= provider.questions.length) {
            return const SizedBox.shrink();
          }

          final question = provider.questions[provider.currentQuestionIndex];

          return Column(
            children: [
              const SizedBox(height: 20),
              _buildProgressBar(provider),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInRight(
                          key: ValueKey(provider.currentQuestionIndex),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QUESTION ${provider.currentQuestionIndex + 1}',
                                style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                question.question,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        ...List.generate(question.options.length, (index) {
                          final isSelected = _selectedOption == index;
                          return FadeInUp(
                            delay: Duration(milliseconds: 100 * index),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: InkWell(
                                onTap: () => _handleAnswer(index),
                                borderRadius: BorderRadius.circular(25),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryColor : const Color(0xFFF9FAFF),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.1), width: 2),
                                    boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))] : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? Colors.white : const Color(0xFF1E1E1E)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Text(
                                          question.options[index],
                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF1E1E1E)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimerWidget() {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                '${provider.timeLeft}s',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(QuizProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final progress = (provider.currentQuestionIndex + 1) / provider.questions.length;
          return Stack(
            children: [
              Container(
                height: 12,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 12,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF77866), Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    context.read<QuizProvider>().stopTimer();
    super.dispose();
  }
}

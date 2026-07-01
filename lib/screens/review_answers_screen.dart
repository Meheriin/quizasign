import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/quiz_provider.dart';
import '../models/question_model.dart';

class ReviewAnswersScreen extends StatelessWidget {
  final List<Question>? questions;
  final List<int?>? userAnswers;

  const ReviewAnswersScreen({super.key, this.questions, this.userAnswers});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    
    // Use passed data or fall back to provider (for immediate post-quiz review)
    final reviewQuestions = questions ?? provider.questions;
    final reviewUserAnswers = userAnswers ?? provider.userAnswers;
    
    const primaryColor = Color(0xFF4776E6);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        title: const Text('Path Review', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reviewQuestions.isEmpty 
          ? const Center(child: Text('No data to review'))
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        itemCount: reviewQuestions.length,
        itemBuilder: (context, index) {
          final question = reviewQuestions[index];
          final userAnswerIndex = reviewUserAnswers.length > index ? reviewUserAnswers[index] : null;
          final isCorrect = userAnswerIndex == question.answerIndex;

          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text('Step ${index + 1}', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                        if (userAnswerIndex == null || userAnswerIndex == -1)
                          const Text('SKIPPED', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 12))
                        else if (isCorrect)
                          const Icon(Icons.check_circle_rounded, color: Colors.green)
                        else
                          const Icon(Icons.cancel_rounded, color: Colors.red),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      question.question,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E), height: 1.3),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(question.options.length, (optionIndex) {
                      final option = question.options[optionIndex];
                      final isAnswer = optionIndex == question.answerIndex;
                      final isUserChoice = optionIndex == userAnswerIndex;

                      Color? bgColor = const Color(0xFFF9FAFF);
                      Color? textColor = const Color(0xFF1E1E1E);
                      IconData? icon;

                      if (isAnswer) {
                        bgColor = Colors.green[50];
                        textColor = Colors.green[700];
                        icon = Icons.check_circle_outline_rounded;
                      } else if (isUserChoice && !isCorrect) {
                        bgColor = Colors.red[50];
                        textColor = Colors.red[700];
                        icon = Icons.error_outline_rounded;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: (isAnswer || (isUserChoice && !isCorrect)) ? textColor!.withOpacity(0.2) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              String.fromCharCode(65 + optionIndex),
                              style: TextStyle(fontWeight: FontWeight.w900, color: textColor!.withOpacity(0.5)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(child: Text(option, style: TextStyle(fontWeight: FontWeight.w700, color: textColor))),
                            if (icon != null) Icon(icon, color: textColor, size: 20),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

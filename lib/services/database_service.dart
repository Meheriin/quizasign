import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // Save Quiz Result with Detailed Evaluation
  Future<void> saveQuizResult({
    required String categoryName,
    required int score,
    required int totalQuestions,
    List<Question>? questions,
    List<int?>? userAnswers,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Prepare detailed evaluation data
      List<Map<String, dynamic>> evaluation = [];
      if (questions != null && userAnswers != null) {
        for (int i = 0; i < questions.length; i++) {
          evaluation.add({
            'question': questions[i].toJson(),
            'userAnswer': userAnswers[i],
          });
        }
      }

      // Save result for the current user
      await _db.collection('users').doc(user.uid).collection('results').add({
        'category': categoryName,
        'score': score,
        'total': totalQuestions,
        'timestamp': FieldValue.serverTimestamp(),
        'evaluation': evaluation,
      });

      // Update global leaderboard data
      final leaderboardRef = _db.collection('leaderboard').doc(user.uid);
      final doc = await leaderboardRef.get();

      if (doc.exists) {
        await leaderboardRef.update({
          'totalScore': FieldValue.increment(score),
          'quizzesPlayed': FieldValue.increment(1),
          'lastPlayed': FieldValue.serverTimestamp(),
        });
      } else {
        await leaderboardRef.set({
          'userName': user.displayName ?? 'Anonymous',
          'userEmail': user.email,
          'userPhoto': user.photoURL,
          'totalScore': score,
          'quizzesPlayed': 1,
          'lastPlayed': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error saving result: $e');
    }
  }

  // Get Quiz History
  Stream<QuerySnapshot> getQuizHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('results')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get Leaderboard
  Stream<QuerySnapshot> getLeaderboard() {
    return _db
        .collection('leaderboard')
        .orderBy('totalScore', descending: true)
        .limit(20)
        .snapshots();
  }
}
